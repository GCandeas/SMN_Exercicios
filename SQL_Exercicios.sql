USE DadosAerios

select ocorrencia.cate from ocorrencia
--	  Acidentes:
--    Detalhamento
SELECT 
		oc.codigo_ocorrencia,
		SUBSTRING(detalhes,1,LEN(detalhes)-1) AS detalhamento
	FROM ocorrencia oc WITH(NOLOCK)
	CROSS APPLY(
		SELECT
				(fa.fator_detalhe_fato + ' ')
			FROM fatorcontribuinte fa WITH(NOLOCK)
			WHERE oc.codigo_ocorrencia = fa.codigo_ocorrencia
				AND oc.ocorrencia_classificacao = 'ACIDENTE'
				AND fa.fator_detalhe_fato <> ' '
			FOR XML PATH('')
		) de (detalhes)
	WHERE detalhes IS NOT NULL

--    Qtd. por fabricante
SELECT
		ae.aeronave_fabricante,
		COUNT(ae.aeronave_fabricante) as quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
	GROUP BY ae.aeronave_fabricante
	ORDER BY quantia DESC

--    Qtd. por tipo de veiculo
SELECT
		ae.aeronave_tipo_veiculo,
		COUNT(ae.aeronave_tipo_veiculo) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
	GROUP BY ae.aeronave_tipo_veiculo
	ORDER BY quantia DESC

--    Qtd. por quantidade de motor
SELECT
		ae.aeronave_motor_quantidade,
		COUNT(ae.aeronave_motor_quantidade) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
	GROUP BY ae.aeronave_motor_quantidade
	ORDER BY quantia DESC

--    Qtd. por categoria
SELECT
		ae.aeronave_operador_categoria,
		COUNT(ae.aeronave_operador_categoria) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
	GROUP BY ae.aeronave_operador_categoria
	ORDER BY quantia DESC

--    Qtd. por Ano de Fabricação
SELECT
		ae.aeronave_ano_fabricacao,
		COUNT(ae.aeronave_ano_fabricacao) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
	GROUP BY ae.aeronave_ano_fabricacao
	ORDER BY ae.aeronave_ano_fabricacao DESC

--Ocorrencias:
--Detalhamento
SELECT 
		oc.codigo_ocorrencia,
		SUBSTRING(detalhes,1,LEN(detalhes)-1) AS detalhamento
	FROM ocorrencia oc WITH(NOLOCK)
	CROSS APPLY(
		SELECT
				(fa.fator_detalhe_fato + ' ')
			FROM fatorcontribuinte fa WITH(NOLOCK)
			WHERE oc.codigo_ocorrencia = fa.codigo_ocorrencia
				AND fa.fator_detalhe_fato <> ' '
			FOR XML PATH('')
		) de (detalhes)
	WHERE detalhes IS NOT NULL

-- Qtd. por tipo
SELECT
		ae.aeronave_tipo_veiculo,
		COUNT(ae.aeronave_tipo_veiculo) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	GROUP BY ae.aeronave_tipo_veiculo
	ORDER BY quantia DESC

-- Qtd. por categoria
SELECT
		ae.aeronave_operador_categoria,
		COUNT(ae.aeronave_operador_categoria) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	INNER JOIN aeronave ae WITH(NOLOCK)
		ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
	GROUP BY ae.aeronave_operador_categoria
	ORDER BY quantia DESC

-- Qtd. por UF
SELECT
		oc.ocorrencia_uf,
		COUNT(oc.ocorrencia_uf) AS quantia
	FROM ocorrencia oc WITH(NOLOCK)
	GROUP BY oc.ocorrencia_uf
	ORDER BY quantia DESC

--Levantar Acidentes e Incidentes por UF
SELECT 
		oc.ocorrencia_uf,
		acidente.acidentes,
		incidente.incidentes
	FROM ocorrencia oc
	INNER JOIN (SELECT
						COUNT(oc.ocorrencia_uf) AS acidentes,
						oc.ocorrencia_uf AS uf
					FROM ocorrencia oc
					WHERE oc.ocorrencia_classificacao = 'ACIDENTE'
					GROUP BY oc.ocorrencia_uf
				) acidente
	ON oc.ocorrencia_uf = acidente.uf
	INNER JOIN (SELECT
						COUNT(oc.ocorrencia_uf) AS incidentes,
						oc.ocorrencia_uf AS uf
					FROM ocorrencia oc
					WHERE oc.ocorrencia_classificacao = 'INCIDENTE'
					GROUP BY oc.ocorrencia_uf
				) incidente
	ON oc.ocorrencia_uf = incidente.uf
	GROUP BY oc.ocorrencia_uf,acidente.acidentes,incidente.incidentes
	ORDER BY oc.ocorrencia_uf

--Levantamento das Ocorrências por Hora
SELECT 
		(CONVERT(VARCHAR(3),hora.horarios) + 'h') AS hora,
		acidente.acidentes,
		incidente.incidentes,
		grave.graves
	FROM(SELECT
				DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario))) AS horarios
			FROM ocorrencia oc
		) hora
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS acidentes,
					DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario))) AS horarios
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'ACIDENTE'
				GROUP BY DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario)))
			) acidente
			ON hora.horarios = acidente.horarios
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS incidentes,
					DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario))) AS horarios
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'INCIDENTE'
				GROUP BY DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario)))
			) incidente
			ON hora.horarios = incidente.horarios
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS graves,
					DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario))) AS horarios
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'INCIDENTE GRAVE'
				GROUP BY DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario)))
			) grave
			ON hora.horarios = grave.horarios

	GROUP BY hora.horarios, acidente.acidentes, incidente.incidentes, grave.graves
	ORDER BY hora.horarios

--Levantamento das Ocorrências por Dia				
SELECT 
		dia.dias,
		acidente.acidentes,
		incidente.incidentes,
		grave.graves
	FROM(SELECT
				DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia))) AS dias
			FROM ocorrencia oc
		) dia
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS acidentes,
					DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia))) AS dias
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'ACIDENTE'
				GROUP BY DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia)))
			) acidente
			ON dia.dias = acidente.dias
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS incidentes,
					DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia))) AS dias
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'INCIDENTE'
				GROUP BY DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia)))
			) incidente
			ON dia.dias = incidente.dias
	INNER JOIN(SELECT
					COUNT(oc.ocorrencia_horario) AS graves,
					DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia))) AS dias
				FROM ocorrencia oc
				WHERE  oc.ocorrencia_classificacao = 'INCIDENTE GRAVE'
				GROUP BY DATEPART(DAY,(CONVERT(DATE, oc.ocorrencia_dia)))
			) grave
			ON dia.dias = grave.dias

	GROUP BY dia.dias, acidente.acidentes, incidente.incidentes, grave.graves
	ORDER BY dia.dias

--Levantamento das Ocorrências por Ano
SELECT
		(YEAR(CONVERT(DATE, oc.ocorrencia_dia))) AS ano,
		COUNT(
			CASE
				WHEN oc.ocorrencia_classificacao = 'ACIDENTE' 
					THEN 1
			END
			) AS acidente,
		COUNT(
			CASE
				WHEN oc.ocorrencia_classificacao = 'INCIDENTE' 
					THEN 1
			END
			) AS incidente,
		COUNT(
			CASE
				WHEN oc.ocorrencia_classificacao = 'INCIDENTE GRAVE' 
					THEN 1
			END
			) AS grave
	FROM ocorrencia oc WITH(NOLOCK)
	GROUP BY (YEAR(CONVERT(DATE, oc.ocorrencia_dia)))
	ORDER BY ano

--Levantamento das Ocorrências por UF
SELECT 
		oc.ocorrencia_uf,
		MIN(CASE
			WHEN  oc.ocorrencia_classificacao = 'ACIDENTE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS primeiro_acidente, 
		MAX(CASE
			WHEN  oc.ocorrencia_classificacao = 'ACIDENTE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS ultimo_acidente,
		MIN(CASE
			WHEN  oc.ocorrencia_classificacao = 'INCIDENTE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS primeiro_incidente, 
		MAX(CASE
			WHEN  oc.ocorrencia_classificacao = 'INCIDENTE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS ultimo_incidente,
		MIN(CASE
			WHEN  oc.ocorrencia_classificacao = 'INCIDENTE GRAVE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS primeiro_grave, 
		MAX(CASE
			WHEN  oc.ocorrencia_classificacao = 'INCIDENTE GRAVE'
				THEN CONVERT(DATE, oc.ocorrencia_dia)
		END) AS ultimo_grave
			
	FROM ocorrencia oc WITH(NOLOCK)
	GROUP BY oc.ocorrencia_uf
	ORDER BY oc.ocorrencia_uf

-- Levantamento das Ocorrências por Tipo de Operação e Nível de Dano
SELECT
		ae.aeronave_tipo_operacao,
		COUNT(CASE
			WHEN ae.aeronave_nivel_dano = 'SUBSTANCIAL'
				THEN 1
		END) AS substancial,
		COUNT(CASE
			WHEN ae.aeronave_nivel_dano = 'NENHUM'
				THEN 1
		END) AS nenhum,
		COUNT(CASE
			WHEN ae.aeronave_nivel_dano = 'LEVE'
				THEN 1
		END) AS leve,
		COUNT(CASE
			WHEN ae.aeronave_nivel_dano = 'DESTRUÍDA'
				THEN 1
		END) AS destruida,
		COUNT(CASE
			WHEN ae.aeronave_nivel_dano = 'INDETERMINADO'
				THEN 1
		END) AS indeterminado
	FROM aeronave ae WITH(NOLOCK)
	GROUP BY ae.aeronave_tipo_operacao

--Levantamento das Aeronaves por Sguimento e Ano de Acidente e Estado
--		Script Python

--Levantamento das Aeronaves por Ano de Acidente e Nível de Dano
DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[dano]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),ae.aeronave_nivel_dano) AS [dano] 
		FROM aeronave ae WITH(NOLOCK)
		WHERE ae.aeronave_nivel_dano <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT 
				ano, ' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(ae.aeronave_nivel_dano) AS cont,
						ae.aeronave_nivel_dano,
						YEAR(CONVERT(DATE, oc.ocorrencia_dia)) AS ano
					FROM ocorrencia oc WITH(NOLOCK)
					INNER JOIN aeronave ae WITH(NOLOCK)
						ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
					GROUP BY ae.aeronave_nivel_dano, (CONVERT(DATE, oc.ocorrencia_dia))
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.aeronave_nivel_dano IN ('+@SQL+')) AS pivo
			ORDER BY ano'
PRINT @SQL
EXEC(@SQL)

--Levantamento das Ocorrências por Nível de Dano e Área de Fator
DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[dano]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),ae.aeronave_nivel_dano) AS [dano] 
		FROM aeronave ae WITH(NOLOCK)
		WHERE ae.aeronave_nivel_dano <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT 
				fator, ' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(ae.aeronave_nivel_dano) AS cont,
						ae.aeronave_nivel_dano,
						fa.fator_area AS fator
					FROM aeronave ae WITH(NOLOCK)
					INNER JOIN fatorcontribuinte fa WITH(NOLOCK)
						ON ae.codigo_ocorrencia = fa.codigo_ocorrencia
					GROUP BY ae.aeronave_nivel_dano, fa.fator_area
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.aeronave_nivel_dano IN ('+@SQL+')) AS pivo
			ORDER BY fator'
PRINT @SQL
EXEC(@SQL)

--Levantamento das Ocorrências por Classificação da Ocorrência e Área de Fator
DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[class]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),oc.ocorrencia_classificacao) AS [class] 
		FROM ocorrencia oc WITH(NOLOCK)
		WHERE oc.ocorrencia_classificacao <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT 
				fator, ' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(oc.ocorrencia_classificacao) AS cont,
						oc.ocorrencia_classificacao,
						fa.fator_area AS fator
					FROM ocorrencia oc WITH(NOLOCK)
					INNER JOIN fatorcontribuinte fa WITH(NOLOCK)
						ON oc.codigo_ocorrencia = fa.codigo_ocorrencia
					GROUP BY oc.ocorrencia_classificacao, fa.fator_area
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.ocorrencia_classificacao IN ('+@SQL+')) AS pivo
			ORDER BY fator'
PRINT @SQL
EXEC(@SQL)

--Levantamento das Ocorrências por Classificação da Ocorrência e Quantidade de Fatalidades
DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[class]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),oc.ocorrencia_classificacao) AS [class] 
		FROM ocorrencia oc WITH(NOLOCK)
		WHERE oc.ocorrencia_classificacao <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT ' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(ae.total_fatalidades) AS cont,
						oc.ocorrencia_classificacao
					FROM ocorrencia oc
					INNER JOIN aeronave ae 
						ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
					GROUP BY oc.ocorrencia_classificacao
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.ocorrencia_classificacao IN ('+@SQL+')) AS pivo'
PRINT @SQL
EXEC(@SQL)

--Levantamento Fabricante da Aeronave por Fatalidades
SELECT 
		ae.aeronave_fabricante AS fabricante,
		SUM(ae.total_fatalidades) AS fatalidades
	FROM aeronave ae
	GROUP BY ae.aeronave_fabricante
	ORDER BY fatalidades DESC

--Levantamento das Ocorrências por Fabricante da Aeronave por Classificação da Ocorrência
DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[class]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),oc.ocorrencia_classificacao) AS [class] 
		FROM ocorrencia oc WITH(NOLOCK)
		WHERE oc.ocorrencia_classificacao <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT 
				fabricante,' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(oc.ocorrencia_classificacao) AS cont,
						oc.ocorrencia_classificacao,
						ae.aeronave_fabricante AS fabricante
					FROM ocorrencia oc
					INNER JOIN aeronave ae 
						ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
					GROUP BY oc.ocorrencia_classificacao, ae.aeronave_fabricante
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.ocorrencia_classificacao IN ('+@SQL+')) AS pivo
			ORDER BY fabricante'

PRINT @SQL
EXEC(@SQL)

--Levantamento Fabricantes e todas as suas Categorias de Ocorrências
select distinct oc.ocorrencia_tipo_categoria from ocorrencia oc

DECLARE @SQL VARCHAR(MAX)
SET @SQL = ''
SELECT 
		@SQL = @SQL +'['+[vetor].[tipo]+'],'
	FROM (SELECT 
			DISTINCT CONVERT(VARCHAR(50),oc.ocorrencia_tipo_categoria) AS [tipo] 
		FROM ocorrencia oc WITH(NOLOCK)
		WHERE oc.ocorrencia_classificacao <> '') vetor
		
SET @SQL = LEFT(@SQL, len(@SQL)-1)

SET @SQL = 'SELECT 
				fabricante,' 
				+@SQL+ 
			' FROM(SELECT
						COUNT(oc.ocorrencia_tipo_categoria) AS cont,
						oc.ocorrencia_tipo_categoria,
						ae.aeronave_fabricante AS fabricante
					FROM ocorrencia oc
					INNER JOIN aeronave ae 
						ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
					GROUP BY oc.ocorrencia_tipo_categoria, ae.aeronave_fabricante
			)aux
			PIVOT(SUM(aux.cont)
				FOR aux.ocorrencia_tipo_categoria IN ('+@SQL+')) AS pivo
			ORDER BY fabricante'

PRINT @SQL
EXEC(@SQL)

--Levantar Média de Ocorrências por Mês e Ano
CREATE TABLE #temp_ocorrencias_ano (
	ano integer null,
	janeiro integer null,
	fevereiro integer null,
	março integer null,
	abril integer null,
	maio integer null,
	junho integer null,
	julho integer null,
	agosto integer null,
	setembro integer null,
	outubro integer null,
	novembro integer null,
	dezembro integer null,
	total_ano integer
)

INSERT INTO #temp_ocorrencias_ano (
									ano, 
									janeiro, 
									fevereiro,
									março,
									abril,
									maio,
									junho,
									julho,
									agosto,
									setembro,
									outubro,
									novembro,
									dezembro,
									total_ano)
					(SELECT 
							YEAR(CONVERT(DATE, oc.ocorrencia_dia)) AS ano,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 1
									THEN 1
							END) AS janeiro,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 2
									THEN 1
							END) AS fevereiro,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 3
									THEN 1
							END) AS marco,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 4
									THEN 1
							END) AS abril,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 5
									THEN 1
							END) AS maio,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 6
									THEN 1
							END) AS junho,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 7
									THEN 1
							END) AS julho,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 8
									THEN 1
							END) AS agosto,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 9
									THEN 1
							END) AS setembro,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 10
									THEN 1
							END) AS outubro,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 11
									THEN 1
							END) AS novenbro,
							COUNT(CASE
								WHEN MONTH(CONVERT(DATE, oc.ocorrencia_dia)) = 12
									THEN 1
							END) AS dezembro,
							COUNT(oc.codigo_ocorrencia) AS total_ano
						FROM ocorrencia oc
						GROUP BY YEAR(CONVERT(DATE, oc.ocorrencia_dia)))

SELECT
		temp.ano, 
		temp.janeiro, 
		temp.fevereiro,
		temp.março,
		temp.abril,
		temp.maio,
		temp.junho,
		temp.julho,
		temp.agosto,
		temp.setembro,
		temp.outubro,
		temp.novembro,
		temp.dezembro,
		temp.total_ano,
		CONVERT(DECIMAL(5,2), temp.total_ano)/12 AS media_ano
	FROM #temp_ocorrencias_ano temp
UNION
SELECT
		NULL AS ano,
		SUM(CONVERT(DECIMAL(4,2), temp.janeiro))/11 AS janeiro,
		SUM(CONVERT(DECIMAL(4,2), temp.fevereiro))/11 AS fevereiro,
		SUM(CONVERT(DECIMAL(4,2), temp.março))/11 AS março,
		SUM(CONVERT(DECIMAL(4,2), temp.abril))/11 AS abril,
		SUM(CONVERT(DECIMAL(4,2), temp.maio))/11 AS maio,
		SUM(CONVERT(DECIMAL(4,2), temp.junho))/11 AS junho,
		SUM(CONVERT(DECIMAL(4,2), temp.julho))/11 AS julho,
		SUM(CONVERT(DECIMAL(4,2), temp.agosto))/11 AS agosto,
		SUM(CONVERT(DECIMAL(4,2), temp.setembro))/11 AS setembro,
		SUM(CONVERT(DECIMAL(4,2), temp.outubro))/11 AS outubro,
		SUM(CONVERT(DECIMAL(4,2), temp.novembro))/11 AS novembro,
		SUM(CONVERT(DECIMAL(4,2), temp.dezembro))/11 AS dezembro,
		NULL AS total_ano, 
		NULL AS media_ano
	FROM #temp_ocorrencias_ano temp
ORDER BY ano DESC

--Levantar Média de Fatalidades por Hora (sem minutos)
CREATE TABLE #temp_fatalidades_data (
	dia DATETIME NULL,
	hora INTEGER NULL,
	fatalidades DECIMAL(5,2) NULL
	)

INSERT INTO #temp_fatalidades_data (
									dia,
									hora,
									fatalidades)
								(SELECT 
									CONVERT(DATE, oc.ocorrencia_dia) AS dia,
									DATEPART(HOUR,(CONVERT(DATETIME, oc.ocorrencia_horario))) AS hora ,
									SUM(ae.total_fatalidades) AS fatalidades
								FROM aeronave ae
								INNER JOIN ocorrencia oc
									ON ae.codigo_ocorrencia = oc.codigo_ocorrencia
								GROUP BY CONVERT(DATE, oc.ocorrencia_dia),CONVERT(DATETIME, oc.ocorrencia_horario))


SELECT 
		temp.hora,
		SUM(temp.fatalidades) AS fatalidades,
		(SUM(temp.fatalidades)/(DATEDIFF(DAY,(MIN(temp.dia)),(MAX(temp.dia))))) AS media_hora

	FROM #temp_fatalidades_data temp
	GROUP BY temp.hora
UNION
SELECT
		NULL AS hora,
		CONVERT(DECIMAL(5,2),SUM(temp.fatalidades)/24) AS fatalidades,
		NULL AS media_hora
	FROM #temp_fatalidades_data temp
ORDER BY hora DESC

--Levantar Fabricantes e a Primeira e Última Ocorrência.
SELECT
		aux.fabricante,
		pr.primeiro,
		pr.hora,
		pr.tipo,
		pr.fatalidades,
		pr.dano,
		ul.ultimo,
		ul.hora,
		ul.tipo,
		ul.fatalidades,
		ul.dano
	FROM (
		SELECT
				ae.aeronave_fabricante AS fabricante
			FROM aeronave ae
			GROUP BY ae.aeronave_fabricante) aux
CROSS APPLY( 
	SELECT TOP(1)
			oc.ocorrencia_dia AS primeiro,
			oc.ocorrencia_horario AS hora,
			ae.aeronave_tipo_veiculo AS tipo,
			ae.total_fatalidades AS fatalidades,
			ae.aeronave_nivel_dano AS dano
		FROM ocorrencia oc
		INNER JOIN aeronave ae
			ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
		WHERE aux.fabricante = ae.aeronave_fabricante
		ORDER BY primeiro, hora
)pr
CROSS APPLY( 
	SELECT TOP(1)
			oc.ocorrencia_dia AS ultimo,
			oc.ocorrencia_horario AS hora,
			ae.aeronave_tipo_veiculo AS tipo,
			ae.total_fatalidades AS fatalidades,
			ae.aeronave_nivel_dano AS dano
		FROM ocorrencia oc
		INNER JOIN aeronave ae
			ON oc.codigo_ocorrencia = ae.codigo_ocorrencia
		WHERE aux.fabricante = ae.aeronave_fabricante
		ORDER BY ultimo DESC, hora DESC
)ul
ORDER BY fabricante

--Levantar o primeiro acidente de cada mês de 2018 - Ocorrências de SP.
SELECT 
		rn.ocorrencia_dia,
		rn.ocorrencia_horario,
		rn.ocorrencia_classificacao
	FROM(
		SELECT
				 ROW_NUMBER() 
					OVER(
						PARTITION BY
							MONTH(CONVERT(DATE,oc.ocorrencia_dia))
						ORDER BY 
							(CONVERT(DATE,oc.ocorrencia_dia)),
							DATEPART(HOUR,(CONVERT(DATETIME,oc.ocorrencia_horario)))
						) AS mes#,
						oc.ocorrencia_dia,
						oc.ocorrencia_horario,
						oc.ocorrencia_uf,
						oc.ocorrencia_classificacao
			FROM 
				ocorrencia oc
			WHERE 
				oc.ocorrencia_uf = 'SP'
				AND oc.ocorrencia_classificacao = 'ACIDENTE'
				AND YEAR(CONVERT(DATE,oc.ocorrencia_dia)) = 2018
			GROUP BY 
				MONTH(CONVERT(DATE,oc.ocorrencia_dia)),
				oc.ocorrencia_dia,
				oc.ocorrencia_horario,
				oc.ocorrencia_uf,
				oc.ocorrencia_classificacao) rn
		WHERE rn.mes# = 1
	
--Levantar o primeiro incidente de cada hora, do dia que houve mais incidente.
WITH cte_tabela AS (
	SELECT TOP(1)
			CONVERT(DATE,oc.ocorrencia_dia) AS dia,
			COUNT(oc.codigo_ocorrencia) AS quantia
		FROM 
			ocorrencia oc
		WHERE 
			oc.ocorrencia_classificacao = 'INCIDENTE'
		GROUP BY 
			CONVERT(DATE,oc.ocorrencia_dia)
		ORDER BY 
			quantia DESC
)
	SELECT
			DATEPART(HOUR,(CONVERT(DATETIME,oc.ocorrencia_horario))) AS hora,
			COUNT(oc.ocorrencia_horario) AS quantia,
			oc.ocorrencia_tipo
		FROM ocorrencia oc
		INNER JOIN cte_tabela
			ON cte_tabela.dia = CONVERT(DATE,oc.ocorrencia_dia)
		WHERE oc.ocorrencia_classificacao = 'INCIDENTE'
		GROUP BY oc.ocorrencia_tipo, DATEPART(HOUR,(CONVERT(DATETIME,oc.ocorrencia_horario)))



