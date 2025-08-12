-- MARK: Stage
CREATE SCHEMA IF NOT EXISTS Aeronautico;
DROP TABLE IF EXISTS Aeronautico.stgCotacao;
CREATE TABLE Aeronautico.stgCotacao(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(255)
	,DataPedido DATE
	,DataRetornoCorretor VARCHAR(255)
	,DataRetorno VARCHAR(255)
	,Prefixo VARCHAR(255)
	,Corretor VARCHAR(255)
	,CascoHangar VARCHAR(255)
	,Renovacao VARCHAR(255)
	,Vigencia VARCHAR(255)
	,Subscritor VARCHAR(255)
	,MoedaReal VARCHAR(255)
	,MoedaDolar VARCHAR(255)
	,StatusCotacao VARCHAR(255)
	,Informacao VARCHAR(255)
);

DROP TABLE IF EXISTS Aeronautico.histCotacao;
CREATE TABLE Aeronautico.histCotacao(
	Arquivo VARCHAR(150) NULL
	,Aba VARCHAR(31) NULL
	,LinhaExcel INT NOT NULL
	,RequisicaoCorretor DATE NULL
	,RetornoCorretor DATE NULL
	,Retorno DATE NULL
	,Prefixo VARCHAR(13) NULL
	,Corretor VARCHAR(150) NULL
	,Cobertura VARCHAR(50) NULL
	,Renovacao VARCHAR(50) NULL
	,VigenciaInicio DATE NULL
	,Subscritor VARCHAR(50) NULL
	,PremioLiquidoReal DECIMAL(15,2) NULL
	,PremioLiquidoDolar DECIMAL(15,2) NULL
	,Situacao VARCHAR(100) NULL
	,Informacao VARCHAR(255) NULL
);

-- MARK: History
CREATE SCHEMA IF NOT EXISTS Aeronautico;
DROP TABLE IF EXISTS Aeronautico.stgEmissao;
CREATE TABLE Aeronautico.stgEmissao(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255) NULL
	,Aba VARCHAR(255) NULL
	,Segurado VARCHAR(255) NULL
	,CnpjCpf VARCHAR(255) NULL
	,Ramo VARCHAR(255) NULL
	,NumeroApolice VARCHAR(255) NULL
	,TipoDocumento VARCHAR(255) NULL
	,DataEmissao DATE NULL
	,VigenciaInicial VARCHAR(255) NULL
	,VigenciaFinal VARCHAR(255) NULL
	,PremioLiquido VARCHAR(255) NULL
	,ComissaoTotal VARCHAR(255) NULL
	,ComissaoTotalValor VARCHAR(255) NULL
	,QuantidadeParcela VARCHAR(255) NULL
	,PrimeiroVencimentoParcela VARCHAR(255) NULL
	,Corretor VARCHAR(255) NULL
	,Prefixo VARCHAR(255) NULL
	,Cedente VARCHAR(255) NULL
	,Fabricante VARCHAR(255) NULL
	,Modelo VARCHAR(255) NULL
	,AnoFabricacao VARCHAR(255) NULL
	,Utilizacao VARCHAR(255) NULL
	,ImportanciaSeguradaCasco VARCHAR(255) NULL
	,PremioLiquidoCasco VARCHAR(255) NULL
	,ImportanciaSeguradaLuc VARCHAR(255) NULL
	,PremioLiquidoLuc VARCHAR(255) NULL
	,PremioLiquidoConvertido VARCHAR(255) NULL
	,TaxaCambialEmissao VARCHAR(255) NULL
	,Renovacao VARCHAR(255) NULL
);

DROP TABLE IF EXISTS Aeronautico.histEmissao;
CREATE TABLE Aeronautico.histEmissao(
	Arquivo VARCHAR(150) NULL
	,Aba VARCHAR(31) NULL
	,LinhaExcel INT NOT NULL
	,Segurado VARCHAR(255) NULL
	,Documento VARCHAR(35) NULL
	,Ramo VARCHAR(50) NULL
	,Apolice VARCHAR(255) NULL
	,ApoliceTipo VARCHAR(100) NULL
	,Emissao DATE NULL
	,VigenciaInicial DATE NULL
	,VigenciaFinal DATE NULL
	,PremioLiquido DOUBLE PRECISION NULL
	,ComissaoTotal DOUBLE PRECISION NULL
	,Comission DOUBLE PRECISION NULL
	,Parcela INT NULL
	,PrimeiroVencimentoParcela DATE NULL
	,Corretor VARCHAR(150) NULL
	,Prefixo VARCHAR(13) NULL
	,Cedente VARCHAR(255) NULL
	,Fabricante VARCHAR(255) NULL
	,ModeloAeronave VARCHAR(255) NULL
	,AnoFabricacaoAeronave SMALLINT NULL
	,UsoAeronave VARCHAR(255) NULL
	,ImportanciaSeguradaCasco DOUBLE PRECISION NULL
	,PremioLiquidoCasco DOUBLE PRECISION NULL
	,ImportanciaSeguradaLuc DOUBLE PRECISION NULL
	,PremioLiquidoLuc DOUBLE PRECISION NULL
	,PremioLiquidoConvertido DOUBLE PRECISION NULL
	,TaxaCambialEmissao DOUBLE PRECISION NULL
	,Renovacao VARCHAR(20) NULL
);


-- MARK: Dimension

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


-- MARK: Procedure Hist
DROP PROCEDURE IF EXISTS Aeronautico.uspHistCotacao;
CREATE OR REPLACE PROCEDURE Aeronautico.uspHistCotacao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataPedido) INTO date_initial FROM Aeronautico.stgCotacao;
		SELECT MAX(DataPedido) INTO date_final FROM Aeronautico.stgCotacao;
	END IF;
	
	WHILE date_initial <= date_final LOOP
	
		DROP TABLE IF EXISTS RawData;
		CREATE TEMP TABLE RawData AS
			SELECT 
				LOWER(TRIM(Arquivo)) AS Arquivo
				,LOWER(TRIM(Aba)) AS Aba
				,LinhaExcel
				,DataPedido
			   	,Corp.cast_date(DataRetornoCorretor) AS DataRetornoCorretor
			   	,Corp.cast_date(DataRetorno) AS DataRetorno
				,LOWER(TRIM(Prefixo)) AS Prefixo
				,LOWER(TRIM(Corretor)) AS Corretor
				,CASE 
					WHEN CascoHangar = 'C' THEN 'casco'
					WHEN CascoHangar = 'H' THEN 'hangar'
					WHEN CascoHangar = 'D' THEN 'drone'
					ELSE LOWER(TRIM(CascoHangar)) 
				END AS CascoHangar
				,LOWER(TRIM(Renovacao)) AS Renovacao
				,Corp.cast_date(Vigencia) AS Vigencia
				,LOWER(TRIM(Subscritor)) AS Subscritor
				,Corp.cast_decimal(MoedaReal) AS MoedaReal
				,Corp.cast_decimal(MoedaDolar)AS MoedaDolar
				,CASE 
					WHEN StatusCotacao IS NOT NULL THEN LOWER(TRIM(StatusCotacao))
					WHEN Informacao LIKE 'Dec%Nado%' THEN 'declinado'
					WHEN StatusCotacao IS NULL THEN LOWER(TRIM(Informacao))
					ELSE 'não Mapeado'
				END AS StatusCotacao
				,LOWER(TRIM(Informacao)) AS Informacao
			FROM Aeronautico.stgCotacao
			WHERE DataPedido >= date_initial
			AND DataPedido < date_initial + INTERVAL '1 day';
				
		-- Remove old data to new insert
		DELETE FROM Aeronautico.histCotacao
		WHERE RetornoCorretor >= date_initial AND RetornoCorretor < date_initial + INTERVAL '1 day';

		-- Insert new data
		INSERT INTO Aeronautico.histCotacao
			SELECT 
				Arquivo
				,Aba
				,LinhaExcel
				,DataPedido
				,DataRetornoCorretor
				,DataRetorno
				,Prefixo AS CodNacionalidade
				,Corretor
				,CascoHangar AS Cobertura
				,Renovacao
				,Vigencia AS VigenciaInicio
				,Subscritor
				,MoedaReal AS PremioLiquidoReal
				,MoedaDolar AS PremioLiquidoDolar
				,StatusCotacao
				,Informacao
			FROM RawData;

		-- Go ahed to the next day
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
		-- COMMIT;
	END LOOP;

	-- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
	DROP TABLE IF EXISTS RawData;
END;
$procedure$;


-- MARK: Fact
DROP TABLE IF EXISTS Aeronautico.factCotacao;
CREATE TABLE Aeronautico.factCotacao(
	Arquivo INT
	,Aba INT
	,RequisicaoCorretor DATE
	,Retorno DATE
	,RetornoCorretor DATE
	,CodNacionalidade INT
	,Corretor INT
	,Cobertura INT
	,Renovacao BOOL
	,VigenciaInicio DATE
	,Subscritor INT
	,PremioLiquidoReal DOUBLE PRECISION
	,Dolar BOOL
	,Situacao INT
);