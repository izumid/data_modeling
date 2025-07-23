-- MARK: Dimensions
-- Prefix are feed by (Quote,Issuance);
-- ManufactureYear,Id_AirshipUsage (I);
-- Model (I);
-- CodeAnac,Pilot (C);
CREATE SCHEMA Corp;
DROP TABLE IF EXISTS Corp.dimAeronave;
CREATE TABLE Corp.dimAeronave(
     Id 				SERIAL
	,Prefixo 			VARCHAR(50)	NULL
	,CodAnac 			INT	NULL
	,Fabricante 		VARCHAR(255) NULL
	,AnoFabricacao 		SMALLINT NULL
	,Modelo 			VARCHAR(50) NULL
	--,IdAirshipUsage		INT NULL
	,TipoUtilizacao 	VARCHAR(255) NULL
	,Piloto 			VARCHAR(255) NULL
	,RegistroEncerrado 	Date NULL
	,PRIMARY KEY (Id)
);

-- MARK: Corp Dim
DROP TABLE IF EXISTS Corp.dimArquivo;
CREATE TABLE Corp.dimArquivo(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimAba;
CREATE TABLE Corp.dimAba(
    Id Serial
    ,Nome char(31) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimFuncionario;
CREATE TABLE Corp.dimFuncionario(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCargo;
CREATE TABLE Corp.dimCargo(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);

TRUNCATE TABLE Corp.dimCargo;
INSERT INTO  Corp.dimCargo (Nome) VALUES
('Presidente')
,('Vice Presidente')
,('Superintendente')
,('Gerente')
,('Coordenador')
,('Analista Senior')
,('Analista')
,('Analista Juinor')
,('Assistente')
,('Estagiário');


-- MARK: Quote
DROP TABLE IF EXISTS Corp.dimCorretor;
CREATE TABLE Corp.dimCorretor(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCobertura;
CREATE TABLE Corp.dimCobertura(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCotacaoSituacao;
CREATE TABLE Corp.dimCotacaoSituacao(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);


-- MARK: Issuance
DROP TABLE IF EXISTS Corp.dimEmissaoSituacao;
CREATE TABLE Corp.dimEmissaoSituacao(
	Id Serial
	,Nome VARCHAR(110)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimsSegurado;
CREATE TABLE Corp.dimsSegurado(
	Id Serial
	,Nome VARCHAR(255)
	,Documento smallint 
	,CNPJ VARCHAR(30)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCedente;
CREATE TABLE Corp.dimCedente(
	Id Serial
	,Nome VARCHAR(100)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimRegulador;
CREATE TABLE Corp.dimRegulador(
	Id Serial
	,Nome VARCHAR(255)
	,PRIMARY KEY (Id)
);


-- MARK: Aeronautico
DROP TABLE IF EXISTS Aeronautico.dimAeronave;
CREATE TABLE Aeronautico.dimAeronave(
     Id					SERIAL
	,Prefixo 			VARCHAR(50) NULL
	,Fabricante			VARCHAR(255) NULL
	,Modelo				VARCHAR(50) NULL
	,AnoFabricacao 		SMALLINT NULL
	--,IdAirshipUsage 	INT NULL
	,TipoUtilizacao		VARCHAR(255) NULL
	,RegistroEncerrado 	DATE NULL
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Aeronautico.dimTipoUtilizacao;
CREATE TABLE Aeronautico.dimTipoUtilizacao(
	 Id Serial
	,Nome VARCHAR(255)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Sinistro.dimAeronave;
CREATE TABLE Sinistro.dimAeronave(
     Id 				SERIAL
	,Prefixo			VARCHAR(50) NULL
	,CodAnac			INT NULL
	,AnoFabricacao 		SMALLINT NULL
	,Piloto 			VARCHAR(255) NULL
	,TipoUtilizacao 	VARCHAR(255) NULL
	,RegistroEncerrado 	DATE NULL
	,PRIMARY KEY (Id)
);


-- MARK: Sinistro
DROP TABLE IF EXISTS Sinistro.dimCausa;
CREATE TABLE Sinistro.dimCausa(
    Id Serial
    ,Nome varchar(50) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS  Sinistro.dimSituacao;
CREATE TABLE Sinistro.dimSituacao(
	Id Serial
	,Nome VARCHAR(50)
	,PRIMARY KEY (Id)
);