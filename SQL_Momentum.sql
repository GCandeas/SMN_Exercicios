--[10/10/2018] Eduardo: Vendas a partir de 2010
--EQL, CLIENTE, status, data ven, data confi
SELECT
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		st.Nom_StatusContVend,
		co.Dat_Venda,
		co.Dat_ConfirmaVenda
		
	FROM 
		dbo.GKSLT_Contratos co
	INNER JOIN 
		dbo.GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		dbo.GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		dbo.GKSLT_StatusContVend st
		ON co.Cod_StatusContVend = st.Cod_StatusContVend

	WHERE
		YEAR(co.Dat_Venda) >= 2010
		AND co.Cod_StatusContVend > 1

--[10/10/2018] Eduardo: Forma de Pagamento
--EQL, CLIENTE, status, data ven, data confi, forma pag
SELECT
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		st.Nom_StatusContVend,
		fo.Nom_ForPag,
		co.Dat_Venda,
		co.Dat_ConfirmaVenda
		
	FROM 
		dbo.GKSLT_Contratos co
	INNER JOIN 
		dbo.GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		dbo.GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		dbo.GKSLT_StatusContVend st
		ON co.Cod_StatusContVend = st.Cod_StatusContVend
	INNER JOIN
		dbo.GKSLT_FormaPagamento fo
		ON co.Cod_ForPag = fo.Cod_ForPag
		
	WHERE
		YEAR(co.Dat_Venda) = 2008
		AND co.Cod_StatusContVend > 1

--[10/10/2018] Eduardo: Lotes doados a partir de 2005 por empreendimento
--EQL, CLIENTE, status, data ven, data confi, forma pag, doacao
SELECT
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		em.Nom_Empr,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		st.Nom_StatusContVend,
		fo.Nom_ForPag,
		si.Nom_SisVen,
		co.Dat_Venda,
		co.Dat_ConfirmaVenda
		
	FROM 
		dbo.GKSLT_Contratos co
	INNER JOIN 
		dbo.GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		dbo.GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		dbo.GKSLT_StatusContVend st
		ON co.Cod_StatusContVend = st.Cod_StatusContVend
	INNER JOIN
		dbo.GKSLT_FormaPagamento fo
		ON co.Cod_ForPag = fo.Cod_ForPag
	INNER JOIN
		dbo.GKSLT_SistemaVenda si
		ON co.Cod_SisVen = si.Cod_SisVen
	INNER JOIN
		dbo.GKSLT_Empreendimentos em
		ON lo.Num_Empr = em.Num_Empr
		
	WHERE
		YEAR(co.Dat_Venda) = 2008
		AND co.Cod_StatusContVend = 2
		AND co.Cod_SisVen = 2
		OR co.Cod_SisVen = 7
		OR co.Cod_SisVen = 8

--[10/10/2018] Eduardo: Retornar todos os clientes ativos que compraram lotes a partir de 2008
--Caso o cliente possuía outro lote ativo antes da compra em 2008, retornar os lotes em outra coluna.

--dados brutos
SELECT
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		st.Nom_StatusContVend,
		co.Dat_Venda,
		co.Dat_ConfirmaVenda
	INTO
		clientes_dados#
	FROM 
		dbo.GKSLT_Contratos co WITH(NOLOCK)
	INNER JOIN 
		dbo.GKSLT_Clientes cl WITH(NOLOCK)
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		dbo.GKSLT_Lotes lo WITH(NOLOCK)
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		dbo.GKSLT_StatusContVend st WITH(NOLOCK)
		ON co.Cod_StatusContVend = st.Cod_StatusContVend

	WHERE
		co.Cod_StatusContVend = 2

--dados anteriores a 2008
SELECT
		DISTINCT da.Num_CliCPFCNPJ,
		SUBSTRING(eq.EQLs,1,LEN(eq.EQLs) - 1) AS ANTIGOS
	INTO
		clientes_eqls#
	FROM
		clientes_dados# da
CROSS APPLY(
	SELECT 
			(an.EQL + '; ')
		FROM
			clientes_dados# an
		WHERE
			da.Num_CliCPFCNPJ = an.Num_CliCPFCNPJ
			AND an.Dat_Venda < '2008-01-01'
		FOR XML PATH('')
		) eq (EQLs)

--unificando as tabelas
SELECT 
		cl.*,
		ant.ANTIGOS
	FROM 
		clientes_dados# cl
	LEFT JOIN
		clientes_eqls# ant
		ON cl.Num_CliCPFCNPJ = ant.Num_CliCPFCNPJ
	WHERE
		YEAR(cl.Dat_Venda) >= 2008
	ORDER BY 
		cl.Nom_Cli

DROP TABLE clientes_dados#
DROP TABLE clientes_eqls#


--[10/10/2018] Eduardo: Levantamento das vendas a partir de 01/2008 com a 1ª parcela de terra paga.
--Todas as vendas **a partir de 01/2018. **
--Onde a 1ª parcela de terra (Cod_TipParc = 3) está quitada, mas possui alguma parcela de sinal ou corretagem (97 e 99) em aberto.

--dados brutos
SELECT 
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		tp.Cod_TipParc,
		co.Num_Contr,
		pa.Num_Parc,
		bp.Ind_BaixaEfet,
		pa.Dat_Pagto,
		co.Dat_Venda
	INTO
		dados#
	FROM 
		GKSLT_Contratos co
	INNER JOIN
		GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		GKSLT_Parcelas pa
		ON co.Num_Contr = pa.Num_Contr
	INNER JOIN
		GKSLT_TiposParcelas tp
		ON pa.Cod_TipParc = tp.Cod_TipParc
	INNER JOIN
		GKSLT_TiposBaixaParcela bp
		ON pa.Cod_TipBaiPar = bp.Cod_TipBaiPar
	WHERE
		co.Dat_Venda >= '2008-01-01'

--prieira parcela terra paga
SELECT 
		da.*
	INTO
		contratos_pg#
	FROM
		dados# da
	WHERE
		da.Num_Parc = 1 
		AND da.Cod_TipParc = 3 
		AND da.Ind_BaixaEfet = 'S'

--unificando as tabelas
SELECT 
		da.EQL,
		da.Nom_Cli,
		da.Num_CliCPFCNPJ,
		da.Cod_TipParc,
		da.Num_Contr,
		da.Dat_Pagto,
		da.Dat_Venda
	FROM
		dados# da
	INNER JOIN
		contratos_pg# cp
		ON da.Num_Contr = cp.Num_Contr
	WHERE
		da.Ind_BaixaEfet  = 'N'
		AND (da.Cod_TipParc = 97 OR da.Cod_TipParc = 99)

DROP TABLE dados#
DROP TABLE contratos_pg#


--[10/10/2018] Eduardo: Contratos vendidos a partir de 2010 com parcela de corretagem vencida a mais de 30 dias.

--dados brutos
SELECT 
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		tp.Cod_TipParc,
		co.Num_Contr,
		pa.Num_Parc,
		bp.Ind_BaixaEfet,
		pa.Dat_Pagto,
		pa.Dat_Venc,
		co.Dat_Venda
	INTO
		dados#
	FROM 
		GKSLT_Contratos co
	INNER JOIN
		GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		GKSLT_Parcelas pa
		ON co.Num_Contr = pa.Num_Contr
	INNER JOIN
		GKSLT_TiposParcelas tp
		ON pa.Cod_TipParc = tp.Cod_TipParc
	INNER JOIN
		GKSLT_TiposBaixaParcela bp
		ON pa.Cod_TipBaiPar = bp.Cod_TipBaiPar
	WHERE
		co.Dat_Venda >= '2010-01-01'

--trabalhando os dados
SELECT *
	FROM 
		dados# da
	WHERE
		da.Cod_TipParc = 97
		AND da.Ind_BaixaEfet = 'N'
		AND DATEDIFF(DAY,da.Dat_Venc,GETDATE()) > 30

DROP TABLE dados#

--07 - [10/10/2018] Eduardo: Levantamento dos clientes com divida de contribuição social.
--Regras: 
--Contratos vendidos a partir de 03/04/2017. 
--Parcela de Contribuição Social em atraso cod=21: 
--De 10 a 16 dias
--De 17 a 19 dias
--De 20 a 32 dias
--Acima de 33 dias

--dados brutos
SELECT 
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		tp.Cod_TipParc,
		pa.Cod_TipBaiPar,
		co.Num_Contr,
		pa.Num_Parc,
		pa.Dat_Pagto,
		pa.Dat_Venc,
		co.Dat_Venda
	INTO
		dados#
	FROM 
		GKSLT_Contratos co
	INNER JOIN
		GKSLT_Clientes cl
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		GKSLT_Lotes lo
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		GKSLT_Parcelas pa
		ON co.Num_Contr = pa.Num_Contr
	INNER JOIN
		GKSLT_TiposParcelas tp
		ON pa.Cod_TipParc = tp.Cod_TipParc
	WHERE
		co.Dat_Venda >= '2017-03-04'

--ordenando os dados 
SELECT 
		ROW_NUMBER()OVER(PARTITION BY da.Num_Contr ORDER BY da.Num_Parc) AS 'row_c',
		da.*
	INTO
		row_contrato#
	FROM
		dados# da
	WHERE
		da.Cod_TipParc = 21
		AND da.Cod_TipBaiPar IS NULL

--visualização
SELECT 
		CASE
			WHEN (DATEDIFF(DAY, co.Dat_Venc, GETDATE()) > 10 AND DATEDIFF(DAY, co.Dat_Venc, GETDATE()) <= 16)
				THEN 'De 10 a 16 dias'
			WHEN (DATEDIFF(DAY, co.Dat_Venc, GETDATE()) > 17 AND DATEDIFF(DAY, co.Dat_Venc, GETDATE()) <= 19)
				THEN 'De 17 a 19 dias'
			WHEN (DATEDIFF(DAY, co.Dat_Venc, GETDATE()) > 19 AND DATEDIFF(DAY, co.Dat_Venc, GETDATE()) <= 32)
				THEN 'De 20 a 32 dias'
			WHEN (DATEDIFF(DAY, co.Dat_Venc, GETDATE()) > 32)
				THEN 'Acima de 32 dias'
			ELSE
				NULL
		END AS atraso,
		co.EQL,
		co.Num_CliCPFCNPJ,
		co.Nom_Cli
		
	FROM
		row_contrato# co
	WHERE
		co.row_c = 1

DROP TABLE dados#
DROP TABLE row_contrato#

--08 - [10/10/2018] Eduardo: Clientes Inadimplentes
--Desenvolver levantamento de todos os clientes que estão inadimplentes, que compraram em 2008

--EQL, CPF, Cliente, Data da Venda, Qtd Parcelas Inadimplentes, 
--Venc. e Tipo de Parcela Mais antiga Vencida, Valor Total do Débito.

SELECT 
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		tp.Cod_TipParc,
		co.Num_Contr,
		pa.Num_Parc,
		pa.Vlr_Parc,
		pa.Num_ChavParc,
		pa.Cod_TipBaiPar,
		sc.Nom_StatusContVend,
		co.Cod_StatusContVend,
		pa.Dat_Pagto,
		pa.Dat_Venc,
		co.Dat_Venda
	INTO
		#dados
	FROM 
		GKSLT_Contratos co WITH(NOLOCK)
	INNER JOIN
		GKSLT_Clientes cl WITH(NOLOCK)
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		GKSLT_Lotes lo WITH(NOLOCK)
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		GKSLT_Parcelas pa WITH(NOLOCK)
		ON co.Num_Contr = pa.Num_Contr
	INNER JOIN
		GKSLT_TiposParcelas tp WITH(NOLOCK)
		ON pa.Cod_TipParc = tp.Cod_TipParc
	INNER JOIN
		GKSLT_StatusContVend sc WITH(NOLOCK)
		ON co.Cod_StatusContVend = sc.Cod_StatusContVend
	WHERE
		co.Dat_Venda >= '2008-01-01'
		AND co.Dat_Venda <= '2008-31-12'
		AND (sc.Cod_StatusContVend = 2 OR sc.Cod_StatusContVend = 3 OR sc.Cod_StatusContVend = 4)

--valor das parcelas em atraso
SELECT 
		da.Num_CliCPFCNPJ,
		da.Num_Contr,
		SUM(da.Vlr_Parc) AS valor,
		COUNT(da.Num_CliCPFCNPJ) AS numero_parcelas
	INTO
		#parcelas_atraso
	FROM
		#dados da
	WHERE
		da.Cod_TipBaiPar IS NULL
	GROUP BY 
		da.Num_CliCPFCNPJ,
		da.Num_Contr
	ORDER BY
		Num_CliCPFCNPJ

--parcela mais antiga
SELECT
		ROW_NUMBER()OVER(PARTITION BY da.Num_CliCPFCNPJ, da.Num_Contr ORDER BY da.Dat_Venc, Num_ChavParc) AS row_parcela,
		da.Num_ChavParc
	INTO
		#antiga
	FROM 
		#dados da
	WHERE
		da.Cod_TipBaiPar IS NULL
			
--visualização do resultado unificando as tabelas
SELECT 
		da.EQL,
		da.Num_CliCPFCNPJ,
		da.Nom_Cli,
		da.Nom_StatusContVend,
		da.Dat_Venda,
		pa.numero_parcelas,
		da.Dat_Venc,
		da.Cod_TipParc,
		pa.valor
	FROM 
		#dados da
	INNER JOIN
		#parcelas_atraso pa
		ON da.Num_CliCPFCNPJ = pa.Num_CliCPFCNPJ AND da.Num_Contr = pa.Num_Contr
	INNER JOIN 
		#antiga an
		ON da.Num_ChavParc = an.Num_ChavParc
		
	WHERE
		an.row_parcela = 1
	ORDER BY
		da.Nom_Cli

DROP TABLE #dados
DROP TABLE #parcelas_atraso
DROP TABLE #antiga
		
--09 - [10/10/2018] Eduardo: Levantamento da forma de pagamento das vendas de 2010.
--**Todos os empreendimentos**
--**Data da Venda: 01/01/2010 até hoje ** 
--Retornar a forma de pagamento das parcelas de sinal e corretagem, se dinheiro, cheque, cartão (quantas vezes).

SELECT 
		(CONVERT(VARCHAR(50),lo.Num_Empr) + '-' + lo.Cod_Quadra + '-' + CONVERT(VARCHAR(50),lo.Cod_Lot)) AS EQL,
		cl.Nom_Cli,
		cl.Num_CliCPFCNPJ,
		tp.Cod_TipParc,
		co.Num_Contr,
		pa.Num_Parc,
		pa.Vlr_Parc,
		pa.Num_ChavParc,
		pa.Cod_TipBaiPar,
		bp.Nom_TipBaiPar,
		sc.Nom_StatusContVend,
		co.Cod_StatusContVend,
		pa.Dat_Pagto,
		pa.Dat_Venc,
		co.Dat_Venda
	INTO
		#dados
	FROM 
		GKSLT_Contratos co WITH(NOLOCK)
	INNER JOIN
		GKSLT_Clientes cl WITH(NOLOCK)
		ON co.Num_CliCPFCNPJ = cl.Num_CliCPFCNPJ
	INNER JOIN
		GKSLT_Lotes lo WITH(NOLOCK)
		ON co.Num_ChavLot = lo.Num_ChavLot
	INNER JOIN
		GKSLT_Parcelas pa WITH(NOLOCK)
		ON co.Num_Contr = pa.Num_Contr
	INNER JOIN
		GKSLT_TiposParcelas tp WITH(NOLOCK)
		ON pa.Cod_TipParc = tp.Cod_TipParc
	INNER JOIN
		GKSLT_TiposBaixaParcela bp
		ON pa.Cod_TipBaiPar = bp.Cod_TipBaiPar
	INNER JOIN
		GKSLT_StatusContVend sc WITH(NOLOCK)
		ON co.Cod_StatusContVend = sc.Cod_StatusContVend
	WHERE
		co.Dat_Venda >= '2010-01-01'
		AND bp.Ind_BaixaEfet = 'S'
		AND (tp.Cod_TipParc = 97 OR tp.Cod_TipParc = 99)
		AND (sc.Cod_StatusContVend = 2 OR sc.Cod_StatusContVend = 3 OR sc.Cod_StatusContVend = 4)

--contagem por tipo de pagamento e apresentação
SELECT 
		da.EQL,
		da.Nom_Cli,
		da.Num_CliCPFCNPJ,
		COUNT(
			CASE
				WHEN da.Cod_TipBaiPar = 1  
					THEN 1
				ELSE NULL
			END
		) AS boleto,
		COUNT(
			CASE
				WHEN da.Cod_TipBaiPar = 3 
					THEN 1
				ELSE NULL
			END
		) AS débito_automático,
		COUNT(
			CASE
				WHEN da.Cod_TipBaiPar = 4  
					THEN 1
				ELSE NULL
			END
		) AS caixa_operacional,
		COUNT(
			CASE
				WHEN da.Cod_TipBaiPar = 5 
					THEN 1
				ELSE NULL
			END
		) AS cheque,
		COUNT(
			CASE
				WHEN da.Cod_TipBaiPar = 2
					THEN 1
				ELSE NULL
			END
		) AS cartão
	FROM 
		#dados da
	GROUP BY
		da.EQL,
		da.Nom_Cli,
		da.Num_CliCPFCNPJ

DROP TABLE #dados

--10 - [10/10/2018] Eduardo: Levantamento de contratos vendidos em 2010 que possuem negociação.