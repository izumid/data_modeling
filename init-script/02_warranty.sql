-- MARK: Stage
CREATE SCHEMA IF NOT EXISTS Garantia;
DROP TABLE IF EXISTS Garantia.stgCotacao;
CREATE TABLE Garantia.stgCotacao(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,DataEmissao VARCHAR(255)
	,Vencimento VARCHAR(255)
	,Finalizacao VARCHAR(255)
	,Empreendimento VARCHAR(255)
	,Fiador VARCHAR(255)
	,DataEntrada DATE
	,Subscritor VARCHAR(255)
	,Situacao VARCHAR(255)
	,Tomador VARCHAR(255)
	,CnpjTomador VARCHAR(255)
	,Segurado VARCHAR(255)
	,Modalidade VARCHAR(255)
	,Corretor VARCHAR(255)
	,Cocorretagem VARCHAR(255)
	,ComissaoTotal VARCHAR(255)
	,ImportanciaSegurada VARCHAR(255)
	,InicioVigencia VARCHAR(255)
	,FinalVigencia VARCHAR(255)
	,Taxa VARCHAR(255)
	,Premio VARCHAR(255)
	,FormaPagamento VARCHAR(255)
	,ComissaoPaga VARCHAR(255)
	,Seguradora VARCHAR(255)
	,Endosso VARCHAR(255)
	,NumeroApolice VARCHAR(255)
);

-- MARK: History
DROP TABLE IF EXISTS Garantia.histCotacao;
CREATE TABLE Garantia.histCotacao(
	 Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,LinhaExcel VARCHAR(255)
	,Emissao DATE
	,Vencimento DATE
	,Finalizacao DATE
	,Empreendimento VARCHAR(255)
	,Fiador VARCHAR(255)
	,Entrada DATE
	,Subscritor VARCHAR(255)
	,Situacao VARCHAR(255)
	,Tomador VARCHAR(255)
	,CnpjTomador VARCHAR(255)
	,Segurado VARCHAR(255)
	,Modalidade VARCHAR(255)
	,Corretor VARCHAR(255)
	,Cocorretagem VARCHAR(255)
	,ComissaoTotal DOUBLE PRECISION NULL
	,ImportanciaSegurada DOUBLE PRECISION NULL
	,VigenciaInicial DATE
	,VigenciaFinal DATE
	,Taxa DOUBLE PRECISION NULL
	,Premio DOUBLE PRECISION NULL
	,FormaPagamento VARCHAR(255)
	,ComissaoPaga DOUBLE PRECISION NULL
	,Seguradora VARCHAR(255)
	,Endosso VARCHAR(255)
	,Apolice BIGINT
	,Desatualizado DATE
);


DROP TABLE IF EXISTS Garantia.histEmissao;
CREATE TABLE Garantia.histEmissao(
	 Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,LinhaExcel VARCHAR(255)
	,Emissao DATE
	,Vencimento DATE
	,Finalizacao DATE
	,Empreendimento VARCHAR(255)
	,Fiador VARCHAR(255)
	,Entrada DATE
	,Subscritor VARCHAR(255)
	,Situacao VARCHAR(255)
	,Tomador VARCHAR(255)
	,CnpjTomador VARCHAR(255)
	,Segurado VARCHAR(255)
	,Modalidade VARCHAR(255)
	,Corretor VARCHAR(255)
	,Cocorretagem VARCHAR(255)
	,ComissaoTotal DOUBLE PRECISION NULL
	,ImportanciaSegurada DOUBLE PRECISION NULL
	,VigenciaInicial DATE
	,VigenciaFinal DATE
	,Taxa DOUBLE PRECISION NULL
	,Premio DOUBLE PRECISION NULL
	,FormaPagamento VARCHAR(255)
	,ComissaoPaga DOUBLE PRECISION NULL
	,Seguradora VARCHAR(255)
	,Endosso VARCHAR(255)
	,Apolice VARCHAR(50)
	,Desatualizado DATE
);

-- MARK: Dimension


-- MARK: USP STG
-- MARK: USP Quote
DROP PROCEDURE IF EXISTS Garantia.uspHistCotacao;
CREATE OR REPLACE PROCEDURE Garantia.uspHistCotacao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataEntrada) INTO date_initial FROM Garantia.stgCotacao;
		SELECT MAX(DataEntrada) INTO date_final FROM Garantia.stgCotacao;
	END IF;
	
	WHILE date_initial <= date_final LOOP
	
		DROP TABLE IF EXISTS RawData_GR;
		CREATE TEMP TABLE RawData_GR AS
			SELECT 
				 LOWER(TRIM(Arquivo)) AS Arquivo
				,LOWER(TRIM(Aba)) AS Aba
				,LinhaExcel
				,Corp.cast_date(DataEmissao) AS Emissao
			   	,Corp.cast_date(Vencimento) AS Vencimento
			   	,Corp.cast_date(Finalizacao) AS Finalizacao
				,LOWER(TRIM(Empreendimento)) AS Empreendimento
				,LOWER(TRIM(Fiador)) AS Fiador
				,CASE WHEN DataEntrada IS NOT NULL THEN DataEntrada ELSE '99991231' END AS Entrada
				,LOWER(TRIM(Subscritor)) AS Subscritor
				,LOWER(TRIM(Situacao)) AS Situacao
				,LOWER(TRIM(Tomador)) AS Tomador
				,LOWER(TRIM(CnpjTomador)) AS CnpjTomador
				,LOWER(TRIM(Segurado)) AS Segurado
				,LOWER(TRIM(Modalidade)) AS Modalidade
				,LOWER(TRIM(Corretor)) AS Corretor
				,LOWER(TRIM(Cocorretagem)) AS Cocorretagem
				,Corp.Cast_Decimal(ComissaoTotal) AS ComissaoTotal
				,Corp.Cast_Decimal(ImportanciaSegurada) AS ImportanciaSegurada
				,Corp.Cast_Date(InicioVigencia) AS VigenciaInicial
				,Corp.Cast_Date(FinalVigencia) AS VigenciaFinal
				,Corp.Cast_Decimal(Taxa) AS Taxa
				,Corp.Cast_Decimal(Premio) AS Premio
				,LOWER(TRIM(FormaPagamento)) AS FormaPagamento
				,Corp.cast_decimal(ComissaoPaga) AS ComissaoPaga
				,LOWER(TRIM(Seguradora)) AS Seguradora
				,LOWER(TRIM(Endosso)) AS Endosso
				,(SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApolice,'[^0-9]+','','g'))), ' ', -1)) AS Apolice
			FROM Garantia.stgCotacao
			WHERE DataEntrada >= date_initial
			AND DataEntrada < date_initial + INTERVAL '1 day';

		-- deprecate old registries filling the 'desatualizado' field and insert new registries
		MERGE INTO Garantia.histCotacao AS dest
			USING(
				SELECT 
					 Arquivo
					,Aba
					,LinhaExcel
					,Emissao
					,Vencimento
					,Finalizacao
					,Empreendimento
					,Fiador
					,Entrada
					,Subscritor
					,Situacao
					,Tomador
					,CnpjTomador
					,Segurado
					,Modalidade
					,Corretor
					,Cocorretagem
					,ComissaoTotal
					,ImportanciaSegurada
					,VigenciaInicial
					,VigenciaFinal
					,Taxa
					,Premio
					,FormaPagamento
					,ComissaoPaga
					,Seguradora
					,Endosso
					,Apolice
				FROM RawData_GR where 1=1 and Apolice IS NULL) AS orig
				ON(
						dest.Fiador = orig.Fiador
					AND dest.CnpjTomador = orig.CnpjTomador
					AND dest.Segurado = orig.Segurado
					AND dest.Modalidade = orig.Modalidade
					AND dest.corretor = orig.corretor
					AND dest.VigenciaInicial = orig.VigenciaInicial
					AND dest.apolice = orig.apolice
				)
				WHEN MATCHED THEN UPDATE SET  Desatualizado = NOW()
				WHEN NOT MATCHED THEN INSERT
				VALUES( 
					orig.Arquivo
					,orig.Aba
					,orig.LinhaExcel
					,orig.Emissao
					,orig.Vencimento
					,orig.Finalizacao
					,orig.Empreendimento
					,orig.Fiador
					,orig.Entrada
					,orig.Subscritor
					,orig.Situacao
					,orig.Tomador
					,orig.CnpjTomador
					,orig.Segurado
					,orig.Modalidade
					,orig.Corretor
					,orig.Cocorretagem
					,orig.ComissaoTotal
					,orig.ImportanciaSegurada
					,orig.VigenciaInicial
					,orig.VigenciaFinal
					,orig.Taxa
					,orig.Premio
					,orig.FormaPagamento
					,orig.ComissaoPaga
					,orig.Seguradora
					,orig.Endosso
					,orig.Apolice
				);
		
		-- insert registries thar are already in database (old), but having any change on non main fields
		INSERT INTO Garantia.histCotacao
			SELECT 
				orig.Arquivo
				,orig.Aba
				,orig.LinhaExcel
				,orig.Emissao
				,orig.Vencimento
				,orig.Finalizacao
				,orig.Empreendimento
				,orig.Fiador
				,orig.Entrada
				,orig.Subscritor
				,orig.Situacao
				,orig.Tomador
				,orig.CnpjTomador
				,orig.Segurado
				,orig.Modalidade
				,orig.Corretor
				,orig.Cocorretagem
				,orig.ComissaoTotal
				,orig.ImportanciaSegurada
				,orig.VigenciaInicial
				,orig.VigenciaFinal
				,orig.Taxa
				,orig.Premio
				,orig.FormaPagamento
				,orig.ComissaoPaga
				,orig.Seguradora
				,orig.Endosso
				,orig.Apolice
			FROM RawData_GR AS orig
			WHERE 1=1
			AND EXISTS(
				SELECT 1 FROM Garantia.histCotacao as dest
				WHERE 1=1 
				AND (
						dest.Fiador = orig.Fiador
					AND dest.CnpjTomador = orig.CnpjTomador
					AND dest.Segurado = orig.Segurado
					AND dest.Modalidade = orig.Modalidade
					AND dest.corretor = orig.corretor
					AND dest.VigenciaInicial = orig.VigenciaInicial
					AND dest.apolice = orig.apolice
				)
				AND NOT (
						orig.Arquivo = dest.Arquivo
					AND orig.Aba = dest.Aba
					AND orig.LinhaExcel = dest.LinhaExcel
					AND orig.Emissao = dest.Emissao
					AND orig.Vencimento = dest.Vencimento
					AND orig.Finalizacao = dest.Finalizacao
					AND orig.Empreendimento = dest.Empreendimento
					AND orig.Fiador = dest.Fiador
					AND orig.Entrada = dest.Entrada
					AND orig.Subscritor = dest.Subscritor
					AND orig.Situacao = dest.Situacao
					AND orig.Tomador = dest.Tomador
					AND orig.Cocorretagem = dest.Cocorretagem
					AND orig.ComissaoTotal = dest.ComissaoTotal
					AND orig.ImportanciaSegurada = dest.ImportanciaSegurada
					AND orig.Taxa = dest.Taxa
					AND orig.Premio = dest.Premio
					AND orig.FormaPagamento = dest.FormaPagamento
					AND orig.ComissaoPaga = dest.ComissaoPaga
					AND orig.Seguradora = dest.Seguradora
					AND orig.Endosso = dest.Endosso
				)
			);
		
		-- go ahed to the next day
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;

	END LOOP;

	-- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
	DROP TABLE IF EXISTS RawData_GR;
END;
$procedure$;



-- MARK: USP HIST
DROP PROCEDURE IF EXISTS Garantia.uspHistEmissao;
CREATE OR REPLACE PROCEDURE Garantia.uspHistEmissao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataEntrada) INTO date_initial FROM Garantia.stgCotacao;
		SELECT MAX(DataEntrada) INTO date_final FROM Garantia.stgCotacao;
	END IF;
	
	WHILE date_initial <= date_final LOOP
	
		DROP TABLE IF EXISTS RawData_GR;
		CREATE TEMP TABLE RawData_GR AS
			SELECT 
				 LOWER(TRIM(Arquivo)) AS Arquivo
				,LOWER(TRIM(Aba)) AS Aba
				,LinhaExcel
				,Corp.cast_date(DataEmissao) AS Emissao
			   	,Corp.cast_date(Vencimento) AS Vencimento
			   	,Corp.cast_date(Finalizacao) AS Finalizacao
				,LOWER(TRIM(Empreendimento)) AS Empreendimento
				,LOWER(TRIM(Fiador)) AS Fiador
				,CASE WHEN DataEntrada IS NOT NULL THEN DataEntrada ELSE '99991231' END AS Entrada
				,LOWER(TRIM(Subscritor)) AS Subscritor
				,LOWER(TRIM(Situacao)) AS Situacao
				,LOWER(TRIM(Tomador)) AS Tomador
				,LOWER(TRIM(CnpjTomador)) AS CnpjTomador
				,LOWER(TRIM(Segurado)) AS Segurado
				,LOWER(TRIM(Modalidade)) AS Modalidade
				,LOWER(TRIM(Corretor)) AS Corretor
				,LOWER(TRIM(Cocorretagem)) AS Cocorretagem
				,Corp.Cast_Decimal(ComissaoTotal) AS ComissaoTotal
				,Corp.Cast_Decimal(ImportanciaSegurada) AS ImportanciaSegurada
				,Corp.Cast_Date(InicioVigencia) AS VigenciaInicial
				,Corp.Cast_Date(FinalVigencia) AS VigenciaFinal
				,Corp.Cast_Decimal(Taxa) AS Taxa
				,Corp.Cast_Decimal(Premio) AS Premio
				,LOWER(TRIM(FormaPagamento)) AS FormaPagamento
				,Corp.cast_decimal(ComissaoPaga) AS ComissaoPaga
				,LOWER(TRIM(Seguradora)) AS Seguradora
				,LOWER(TRIM(Endosso)) AS Endosso
				,(SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApolice,'[^0-9]+','','g'))), ' ', -1)) AS Apolice
			FROM Garantia.stgCotacao
			WHERE DataEntrada >= date_initial
			AND DataEntrada < date_initial + INTERVAL '1 day';

		-- deprecate old registries filling the 'desatualizado' field and insert new registries
		MERGE INTO Garantia.histEmissao AS dest
			USING(
				SELECT 
					 Arquivo
					,Aba
					,LinhaExcel
					,Emissao
					,Vencimento
					,Finalizacao
					,Empreendimento
					,Fiador
					,Entrada
					,Subscritor
					,Situacao
					,Tomador
					,CnpjTomador
					,Segurado
					,Modalidade
					,Corretor
					,Cocorretagem
					,ComissaoTotal
					,ImportanciaSegurada
					,VigenciaInicial
					,VigenciaFinal
					,Taxa
					,Premio
					,FormaPagamento
					,ComissaoPaga
					,Seguradora
					,Endosso
					,Apolice
				FROM RawData_GR where 1=1 and Apolice IS NOT NULL
			) AS orig
			ON(
					dest.Fiador = orig.Fiador
				AND dest.CnpjTomador = orig.CnpjTomador
				AND dest.Segurado = orig.Segurado
				AND dest.Modalidade = orig.Modalidade
				AND dest.corretor = orig.corretor
				AND dest.VigenciaInicial = orig.VigenciaInicial
				AND dest.Apolice = orig.Apolice
			)
			WHEN MATCHED THEN UPDATE SET Desatualizado = NOW()
			WHEN NOT MATCHED THEN INSERT
			VALUES( 
				orig.Arquivo
				,orig.Aba
				,orig.LinhaExcel
				,orig.Emissao
				,orig.Vencimento
				,orig.Finalizacao
				,orig.Empreendimento
				,orig.Fiador
				,orig.Entrada
				,orig.Subscritor
				,orig.Situacao
				,orig.Tomador
				,orig.CnpjTomador
				,orig.Segurado
				,orig.Modalidade
				,orig.Corretor
				,orig.Cocorretagem
				,orig.ComissaoTotal
				,orig.ImportanciaSegurada
				,orig.VigenciaInicial
				,orig.VigenciaFinal
				,orig.Taxa
				,orig.Premio
				,orig.FormaPagamento
				,orig.ComissaoPaga
				,orig.Seguradora
				,orig.Endosso
				,orig.Apolice
			);
		
		-- insert registries thar are already in database (old), but having any change on non main fields
		INSERT INTO Garantia.histEmissao
			SELECT 
				orig.Arquivo
				,orig.Aba
				,orig.LinhaExcel
				,orig.Emissao
				,orig.Vencimento
				,orig.Finalizacao
				,orig.Empreendimento
				,orig.Fiador
				,orig.Entrada
				,orig.Subscritor
				,orig.Situacao
				,orig.Tomador
				,orig.CnpjTomador
				,orig.Segurado
				,orig.Modalidade
				,orig.Corretor
				,orig.Cocorretagem
				,orig.ComissaoTotal
				,orig.ImportanciaSegurada
				,orig.VigenciaInicial
				,orig.VigenciaFinal
				,orig.Taxa
				,orig.Premio
				,orig.FormaPagamento
				,orig.ComissaoPaga
				,orig.Seguradora
				,orig.Endosso
				,orig.Apolice
			FROM RawData_GR AS orig
			WHERE 1=1
			AND EXISTS(
				SELECT 1 FROM Garantia.histEmissao AS dest
				WHERE 1=1 
				AND (
						dest.Fiador = orig.Fiador
					AND dest.CnpjTomador = orig.CnpjTomador
					AND dest.Segurado = orig.Segurado
					AND dest.Modalidade = orig.Modalidade
					AND dest.corretor = orig.corretor
					AND dest.VigenciaInicial = orig.VigenciaInicial
					AND dest.apolice = orig.apolice
				)
				AND NOT (
						orig.Arquivo = dest.Arquivo
					AND orig.Aba = dest.Aba
					AND orig.LinhaExcel = dest.LinhaExcel
					AND orig.Emissao = dest.Emissao
					AND orig.Vencimento = dest.Vencimento
					AND orig.Finalizacao = dest.Finalizacao
					AND orig.Empreendimento = dest.Empreendimento
					AND orig.Fiador = dest.Fiador
					AND orig.Entrada = dest.Entrada
					AND orig.Subscritor = dest.Subscritor
					AND orig.Situacao = dest.Situacao
					AND orig.Tomador = dest.Tomador
					AND orig.Cocorretagem = dest.Cocorretagem
					AND orig.ComissaoTotal = dest.ComissaoTotal
					AND orig.ImportanciaSegurada = dest.ImportanciaSegurada
					AND orig.Taxa = dest.Taxa
					AND orig.Premio = dest.Premio
					AND orig.FormaPagamento = dest.FormaPagamento
					AND orig.ComissaoPaga = dest.ComissaoPaga
					AND orig.Seguradora = dest.Seguradora
					AND orig.Endosso = dest.Endosso
				)
			);
		
		-- go ahed to the next day
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
		-- COMMIT;
	END LOOP;

	-- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
	DROP TABLE IF EXISTS RawData_GR;
END;
$procedure$;