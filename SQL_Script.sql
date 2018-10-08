CREATE DATABASE DadosAerios
USE DadosAerios
CREATE TABLE ocorrencia (
	codigo_ocorrencia BIGINT NOT NULL PRIMARY KEY, 
	ocorrencia_classificacao VARCHAR(50) NOT NULL, 
	ocorrencia_tipo VARCHAR(50) NOT NULL, 
	ocorrencia_tipo_categoria VARCHAR(50) NOT NULL, 
	ocorrencia_tipo_icao VARCHAR(50) NOT NULL, 
	ocorrencia_latitude DECIMAL(10,6) NOT NULL, 
	ocorrencia_longitude DECIMAL(10,6) NOT NULL, 
	ocorrencia_cidade  VARCHAR(50) NOT NULL, 
	ocorrencia_uf  VARCHAR(5) NOT NULL, 
	ocorrencia_pais  VARCHAR(50) NOT NULL, 
	ocorrencia_aerodromo  VARCHAR(50) NOT NULL, 
	ocorrencia_dia VARCHAR(20) NOT NULL, 
	ocorrencia_horario VARCHAR(20) NOT NULL, 
	investigacao_aeronave_liberada  VARCHAR(50), 
	investigacao_status  VARCHAR(50) NOT NULL, 
	divulgacao_relatorio_numero VARCHAR(50), 
	divulgacao_relatorio_publicado VARCHAR(10) NOT NULL, 
	divulgacao_dia_publicacao  VARCHAR(20), 
	total_recomendacoes INTEGER,
	total_aeronaves_envolvidas INTEGER, 
	ocorrencia_saida_pista VARCHAR(10) NOT NULL, 
	ocorrencia_dia_extracao VARCHAR(20)
	)


CREATE TABLE aeronave (
	aeronave_matriculada VARCHAR(10) NOT NULL, 
	codigo_ocorrencia BIGINT FOREIGN KEY REFERENCES ocorrencia(codigo_ocorrencia),
	aeronave_operador_categoria VARCHAR(50) NOT NULL, 
	aeronave_tipo_veiculo VARCHAR(50) NOT NULL, 
	aeronave_fabricante VARCHAR(50) NOT NULL, 
	aeronave_modelo VARCHAR(50) NOT NULL, 
	aeronave_tipo_icao VARCHAR(50) NOT NULL, 
	aeronave_motor_tipo VARCHAR(50) NOT NULL, 
	aeronave_motor_quantidade VARCHAR(50) NOT NULL, 
	aeronave_pmd INTEGER NOT NULL, 
	aeronave_pmd_categoria VARCHAR(50) NOT NULL, 
	aeronave_assentos VARCHAR(10), 
	aeronave_ano_fabricacao VARCHAR(10), 
	aeronave_pais_fabricante VARCHAR(50) NOT NULL, 
	aeronave_pais_registro VARCHAR(50) NOT NULL, 
	aeronave_registro_categoria VARCHAR(50) NOT NULL, 
	aeronave_registro_segmento VARCHAR(50) NOT NULL, 
	aeronave_voo_origem VARCHAR(50), 
	aeronave_voo_destino VARCHAR(50), 
	aeronave_fase_operacao VARCHAR(50) NOT NULL, 
	aeronave_fase_operacao_icao VARCHAR(50) NOT NULL, 
	aeronave_tipo_operacao VARCHAR(50) NOT NULL, 
	aeronave_nivel_dano VARCHAR(50) NOT NULL, 
	total_fatalidades INTEGER NOT NULL, 
	aeronave_dia_extracao VARCHAR(20)
	)

CREATE TABLE fatorcontribuinte (
	codigo_ocorrencia BIGINT FOREIGN KEY REFERENCES ocorrencia(codigo_ocorrencia),
	fator_nome VARCHAR(50), 
	fator_aspecto VARCHAR(50), 
	fator_condicionante VARCHAR(50), 
	fator_area VARCHAR(50), 
	fator_detalhe_fato TEXT, 
	fator_dia_extracao VARCHAR(50)
	)

CREATE TABLE recomendacao (
	codigo_ocorrencia BIGINT FOREIGN KEY REFERENCES ocorrencia(codigo_ocorrencia), 
	recomendacao_numero VARCHAR(10) NOT NULL PRIMARY KEY, 
	recomendacao_dia_assinatura VARCHAR(50), 
	recomendacao_dia_encaminhamento VARCHAR(50), 
	recomendacao_feedback TEXT, 
	recomendacao_conteudo VARCHAR(50), 
	recomendacao_status VARCHAR(50), 
	recomendacao_destinatario_sigla VARCHAR(50), 
	recomendacao_destinatario_nome VARCHAR(50), 
	dia_extracao_recomendacao VARCHAR(50)
	)

ALTER TABLE fatorcontribuinte ALTER COLUMN fator_detalhe_fato VARCHAR(MAX)


ALTER TABLE recomendacao ALTER COLUMN recomendacao_numero VARCHAR(50)
ALTER TABLE recomendacao ALTER COLUMN recomendacao_feedback VARCHAR(50)
ALTER TABLE recomendacao ALTER COLUMN recomendacao_conteudo VARCHAR(MAX)
ALTER TABLE recomendacao ALTER COLUMN recomendacao_destinatario_nome VARCHAR(100) 
