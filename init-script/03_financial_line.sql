-- MARK: Stage
CREATE SCHEMA IF NOT EXISTS linhaFinanceira;
DROP TABLE IF EXISTS linhaFinanceira.stgCotacao;
CREATE TABLE linhaFinanceira.stgCotacao(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
    ,DataEntrada VARCHAR(255)
    ,SeguroFac VARCHAR(255)
    ,Ramo VARCHAR(255)
    ,Segurado VARCHAR(255)
    ,Corretor VARCHAR(255)
    ,Tiposeguro VARCHAR(255)
    ,Status VARCHAR(255)
    ,Deadline VARCHAR(255)
    ,DataEnvio VARCHAR(255)
    ,FimVigencia VARCHAR(255)
    ,Hot VARCHAR(255)
    ,Premio VARCHAR(255)
    ,Subscritor VARCHAR(255)
    ,Atividade VARCHAR(255)
    ,MotivoDeclinio VARCHAR(255)
    ,EnviadoEm VARCHAR(255)
    ,Comercial VARCHAR(255)
    ,Modalidade VARCHAR(255)
    ,Faturamento VARCHAR(255)
    ,Limite VARCHAR(255)
    ,NumeroApoliceSeguradora VARCHAR(255)
    
);

-- MARK: History
DROP TABLE IF EXISTS linhaFinanceira.histCotacao;
CREATE TABLE linhaFinanceira.histCotacao(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
    ,Entrada DATE
    ,Segmento VARCHAR(255)
    ,Ramo VARCHAR(255)
    ,Segurado VARCHAR(255)
    ,Corretor VARCHAR(255)
    ,Tipodeseguro VARCHAR(255)
    ,Situacao VARCHAR(255)
    ,Deadline DATE
    ,Envio DATE
    ,VigenciaFinal DATE
    ,Hot VARCHAR(255)
    ,Premio DOUBLE PRECISION 
    ,Subscritor VARCHAR(50)
    ,Atividade VARCHAR(255)
    ,Enviado DATE
    ,Comercial VARCHAR(50)
    ,MotivoDeclinio VARCHAR(255)
    ,Modalidade VARCHAR(255)
    ,Faturamento DOUBLE PRECISION 
    ,Limite DOUBLE PRECISION 
    ,Apolice VARCHAR(255)
	,Desatualizado DATE
);

DROP TABLE IF EXISTS linhaFinanceira.stgEmissao;
CREATE TABLE linhaFinanceira.stgEmissao(
	 LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,Segurado VARCHAR(255)
	,Ramo VARCHAR(255)
    ,Renovacao VARCHAR(255)
    ,NumeroApolice VARCHAR(255)
    ,TipoDocumento VARCHAR(255)
    ,DataEmissao VARCHAR(255)
    ,VigenciaInicial VARCHAR(255)
    ,VigenciaFinal VARCHAR(255)
    ,PremioLiquido VARCHAR(255)
    ,ComissaoTotal VARCHAR(255)
    ,ComissaoTotalValor VARCHAR(255)
    ,QuantidadeParcela VARCHAR(255)
    ,PrimeiroVencimentoParcela VARCHAR(255)
    ,Corretor VARCHAR(255)
    ,Contrato VARCHAR(255)
    ,ValorProLabore VARCHAR(255)
    ,OneOff VARCHAR(255)
    ,Status VARCHAR(255)
    ,MesBound VARCHAR(255)
    ,Lmg VARCHAR(255)
    ,PremioNet VARCHAR(255)
    ,ComissaoProLabore VARCHAR(255)
    ,Atividade VARCHAR(255)
    ,CnpjCpf VARCHAR(255)
    ,Campanha VARCHAR(255)
);


DROP TABLE IF EXISTS linhaFinanceira.histEmissao;
CREATE TABLE linhaFinanceira.histEmissao(
	 LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,Segurado VARCHAR(255)
	,Ramo CHAR(3)
    ,Renovacao VARCHAR(9)
    ,NumeroApolice VARCHAR(255)
    ,TipoDocumento VARCHAR(50)
    ,DataEmissao DATE
    ,VigenciaInicial DATE
    ,VigenciaFinal DATE
    ,PremioLiquido DATE
    ,ComissaoTotal DOUBLE PRECISION
    ,ComissaoTotalValor DOUBLE PRECISION
    ,QuantidadeParcela INT
    ,PrimeiroVencimentoParcela DATE
    ,Corretor VARCHAR(255)
    ,Contrato INT
    ,OneOff CHAR(3)
    ,Situacao VARCHAR(50)
    ,MesBound CHAR(8)
    ,Lmg DOUBLE PRECISION
    ,PremioNet VARCHAR(255)
    ,ComissaoProLabore DOUBLE PRECISION
    ,ValorProLabore DOUBLE PRECISION
    ,Atividade VARCHAR(255)
    ,CnpjCpf VARCHAR(19)
    ,Campanha VARCHAR(255)
);
