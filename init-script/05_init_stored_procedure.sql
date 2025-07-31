
-- MARK: UDF Try Cast
-- postgress highly typed a function must have a typed return
DROP FUNCTION IF EXISTS Corp.Cast_Date(IN input_value TEXT);
CREATE FUNCTION Corp.Cast_Date(IN input_value TEXT) RETURNS DATE 
LANGUAGE plpgsql AS $function$
	DECLARE result DATE;
	BEGIN
		BEGIN
		result := input_value::DATE;
		EXCEPTION WHEN others THEN
			result := NULL;
	END;
		RETURN result;
	END;
$function$;

DROP FUNCTION IF EXISTS Corp.Cast_Decimal(IN input_value TEXT);
CREATE FUNCTION Corp.Cast_Decimal(IN input_value TEXT) RETURNS DECIMAL(15,4)
LANGUAGE plpgsql AS $function$
	DECLARE result DECIMAL(15,4);
	BEGIN
		BEGIN
		result := input_value::DECIMAL(15,4);
		EXCEPTION WHEN others THEN
			result := NULL;
		END;
		RETURN result;
	END;
$function$;

DROP FUNCTION IF EXISTS Corp.Cast_Int(IN input_value TEXT);
CREATE FUNCTION Corp.Cast_Int(IN input_value TEXT) RETURNS INTEGER 
LANGUAGE plpgsql AS $function$
	DECLARE result INTEGER;
	BEGIN
		BEGIN
		result := input_value::INTEGER;
		EXCEPTION WHEN others THEN
			result := NULL;
		END;
		RETURN result;
	END;
$function$;

DROP FUNCTION IF EXISTS Corp.Cast_BigInt(IN input_value TEXT);
CREATE FUNCTION Corp.Cast_BigInt(IN input_value TEXT) RETURNS INTEGER 
LANGUAGE plpgsql AS $function$
	DECLARE result INTEGER;
	BEGIN
		BEGIN
		result := input_value::BIGINT;
		EXCEPTION WHEN others THEN
			result := NULL;
		END;
		RETURN result;
	END;
$function$;

-- MARK: Quote Hist
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


DROP PROCEDURE IF EXISTS Garantia.uspHistCotacao;
CREATE OR REPLACE PROCEDURE Garantia.uspHistCotacao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(Entrada) INTO date_initial FROM Garantia.stgCotacao;
		SELECT MAX(Entrada) INTO date_final FROM Garantia.stgCotacao;
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
				,Corp.Cast_BigInt(SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApolice,'[^0-9]+','','g'))), ' ', -1)) AS Apolice
			FROM Garantia.stgCotacao
			WHERE DataEntrada >= date_initial
			AND DataEntrada < date_initial + INTERVAL '1 day';
				
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
				)
				WHEN MATCHED THEN UPDATE SET 
					Desatualizado = NOW()
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

		-- go ahed to the next day
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
		-- COMMIT;
	END LOOP;

	-- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
	DROP TABLE IF EXISTS RawData_GR;
END;
$procedure$;

DROP PROCEDURE IF EXISTS Garantia.uspHistEmissao;
CREATE OR REPLACE PROCEDURE Garantia.uspHistEmissao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(Entrada) INTO date_initial FROM Garantia.stgCotacao;
		SELECT MAX(Entrada) INTO date_final FROM Garantia.stgCotacao;
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
				,Corp.Cast_BigInt(SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApolice,'[^0-9]+','','g'))), ' ', -1)) AS Apolice
			FROM Garantia.stgCotacao
			WHERE DataEntrada >= date_initial
			AND DataEntrada < date_initial + INTERVAL '1 day';
				
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
				FROM RawData_GR where 1=1 and Apolice IS NOT NULL) AS orig
				ON(
						dest.Fiador = orig.Fiador
					AND dest.CnpjTomador = orig.CnpjTomador
					AND dest.Segurado = orig.Segurado
					AND dest.Modalidade = orig.Modalidade
					AND dest.corretor = orig.corretor
					AND dest.VigenciaInicial = orig.VigenciaInicial 
				)
				WHEN MATCHED THEN UPDATE SET 
					Desatualizado = NOW()
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

		-- go ahed to the next day
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
		-- COMMIT;
	END LOOP;

	-- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
	DROP TABLE IF EXISTS RawData_GR;
END;
$procedure$;