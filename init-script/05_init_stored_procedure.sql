
-- MARK: UDF Try Cast
-- postgress highly typed a function must have a typed return
DROP FUNCTION IF EXISTS Cast_Date(IN input_value TEXT);
CREATE FUNCTION public.Cast_Date(IN input_value TEXT) RETURNS DATE LANGUAGE plpgsql AS $function$
DECLARE result DATE;
BEGIN
	BEGIN
    result := input_value::DATE;
    EXCEPTION WHEN others THEN
        result := NULL;
   END;
    RETURN result;
END;
$function$

DROP FUNCTION IF EXISTS Cast_Decimal(IN input_value TEXT);
CREATE FUNCTION public.Cast_Decimal(IN input_value TEXT) RETURNS DECIMAL(15,4) LANGUAGE plpgsql AS $function$
DECLARE result DECIMAL(15,4);
BEGIN
	BEGIN
    result := input_value::DECIMAL(15,4);
    EXCEPTION WHEN others THEN
        result := NULL;
    END;
    RETURN result;
END;
$function$

DROP FUNCTION IF EXISTS Cast_Int(IN input_value TEXT);
CREATE FUNCTION public.Cast_Int(IN input_value TEXT) RETURNS INTEGER LANGUAGE plpgsql AS $function$
DECLARE result INTEGER;
BEGIN
	BEGIN
    result := input_value::INTEGER;
    EXCEPTION WHEN others THEN
        result := NULL;
    END;
    RETURN result;
END;

-- MARK: Quote Hist
DROP PROCEDURE IF EXISTS usp_AeronauticoHistQuote;
CREATE OR REPLACE PROCEDURE usp_AeronauticoHistQuote(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
    -- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- Verifica se os parâmetros de data são nulos e os define a partir do banco
    IF date_initial IS NULL AND date_final IS NULL THEN
        SELECT MIN(DATADOPEDIDO) INTO date_initial FROM Aeronautico.stgCotacao;
        SELECT MAX(DATADOPEDIDO) INTO date_final FROM Aeronautico.stgCotacao;
    END IF;
	
    WHILE date_initial <= date_final LOOP
    
    	DROP TABLE IF EXISTS RawData;
        -- Cria tabela temporaria
        CREATE TEMP TABLE RawData AS
            SELECT 
                LOWER(TRIM(Arquivo)) AS Arquivo,
                LOWER(TRIM(Aba)) AS Aba,
				LinhaExcel,
                DataPedido,
               	public.cast_date(DataRetornoCorretor) AS DataRetornoCorretor,
               	public.cast_date(DataRetorno) AS DataRetorno,
                LOWER(TRIM(Prefixo)) AS Prefixo,
                LOWER(TRIM(Corretor)) AS Corretor,
                CASE 
                    WHEN CascoHangar = 'C' THEN 'casco'
                    WHEN CascoHangar = 'H' THEN 'hangar'
                    WHEN CascoHangar = 'D' THEN 'drone'
                    ELSE LOWER(TRIM(CascoHangar)) 
                END AS CascoHangar,
                LOWER(TRIM(Renovacao)) AS Renovacao,
				public.cast_date(Vigencia) AS Vigencia,
                LOWER(TRIM(Subscritor)) AS Subscritor,
	            public.cast_decimal(MoedaReal) AS MoedaReal,
                public.cast_decimal(MoedaDolar)AS MoedaDolar,
                CASE 
                    WHEN StatusCotacao IS NOT NULL THEN LOWER(TRIM(StatusCotacao))
                    WHEN Informacao LIKE 'Dec%Nado%' THEN 'declinado'
                    WHEN StatusCotacao IS NULL THEN LOWER(TRIM(Informacao))
                    ELSE 'não Mapeado'
                END AS StatusCotacao,
                LOWER(TRIM(Informacao)) AS Informacao
            FROM Aeronautico.stgCotacao
            WHERE DataPedido >= date_initial
            AND DataPedido < date_initial + INTERVAL '1 day';
				
        -- Remove dados previamente existentes
        DELETE FROM Aeronautico.histCotacao
        WHERE BrokerRequest >= date_initial AND BrokerRequest < date_initial + INTERVAL '1 day';

        -- Insere novos dados
        INSERT INTO Aeronautical_Hist_Quote
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
                ,MoedaFolar AS PremioLiquidoDolar
                ,StatusCotacao
                ,Informacao
            FROM RawData;

        -- Avança para o próximo dia
        date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
        -- COMMIT;
    END LOOP;

    -- Remove tabela temporaria, evitando conflitos de criacao
    DROP TABLE IF EXISTS RawData;
END;
$procedure$


-- MARK: Issuance Hist
DROP PROCEDURE IF EXISTS uspAeronauticoHistEmissao(IN date_initial DATE, IN date_final DATE);
CREATE OR REPLACE PROCEDURE uspAeronauticoHistEmissao(IN date_initial DATE DEFAULT NULL, IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    current_date DATE;
BEGIN
    -- Verifica se os parâmetros de data são nulos e os define a partir do banco
    IF date_initial IS NULL AND date_final IS NULL THEN
        SELECT MIN(DATAEMISSAO) INTO date_initial FROM Aeronautico.stgEmissao;
        SELECT MAX(DATAEMISSAO) INTO date_final FROM Aeronautico.stgEmissao;
    END IF;

    -- Define nível de isolamento de transação
    -- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    WHILE date_initial <= date_final LOOP
        -- Cria tabela temporária
        DROP TABLE IF EXISTS RawDataHistIssuance;
        CREATE TEMP TABLE RawDataHistIssuance AS
            SELECT 
                LOWER(TRIM(Arquivo)) AS Arquivo,
                LOWER(TRIM(Aba)) AS Aba,
				LinhaExcel
                LOWER(TRIM(Segurado)) AS Segurado,
                LOWER(TRIM(CnpjCpf)) AS CnpjCpf,
                LOWER(TRIM(Ramo)) AS Ramo,
                LOWER(TRIM(NumeroApolice)) AS NumeroApolice,
                LOWER(TRIM(TipoDocumento)) AS TipoDocumento,
                DataEmissao,
                public.cast_date(VigenciaInicial) AS VigenciaInicial,
                public.cast_date(VigenciaFinal) AS VigenciaFinal,
                public.cast_decimal(PremioLiquido) AS PremioLiquido,
                public.cast_decimal(ComissaoTotal) AS ComissaoTotal,
                public.cast_decimal(ComissaoTotalValor) AS ComissaoTotalValor,
                public.cast_decimal(QuantidadeParcela) AS QuantidadeParcela,
                public.cast_date(PrimeiroVencimentoParcela) AS PrimeiroVencimentoParcela,
                LOWER(TRIM(Corretor)) AS Corretor,
                LOWER(TRIM(Prefixo)) AS Prefixo,
                LOWER(TRIM(Cedente)) AS Cedente,
                LOWER(TRIM(Fabricante)) AS Fabricante,
                LOWER(TRIM(Modelo)) AS Modelo,
                CASE WHEN LENGTH(AnoFabricacao) < 5 THEN AnoFabricacao::INT ELSE NULL END AS AnoFabricacao,
                LOWER(TRIM(Utilizacao)) AS UTILIZACAO,
				
                public.cast_decimal(ImportanciaSeguradaCasco) AS ImportanciaSeguradaCasco,
                public.cast_decimal(PremioLiquidoCasco) AS PremioLiquidoCasco,
                public.cast_decimal(ImportanciaSeguradaLuc) AS ImportanciaSeguradaLuc,
                public.cast_decimal(PremioLiquidoLuc) AS PremioLiquidoLuc,
                public.cast_decimal(PremioLiquidoConvertido) AS PremioLiquidoConvertido,
                public.cast_decimal(TaxaCambialEmissao) AS TaxaCambialEmissao,
                CASE WHEN Renovacao = 'Sim' THEN 1 ELSE 0 END AS Renovacao
            FROM Aeronautico.stgEmissao
            WHERE DATAEMISSAO >= date_initial
            AND DATAEMISSAO < date_initial + INTERVAL '1 day';

        -- Remove entradas existentes
        DELETE FROM Aeronautico.histEmissao
        WHERE IssueDate >= date_initial AND IssueDate < date_initial + INTERVAL '1 day';

        -- Insere novos dados
        INSERT INTO Aeronautico.histEmissao
            SELECT * FROM RawDataHistIssuance;

        -- Avança para o próximo dia
        date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
    END LOOP;

    -- Remove tabela temporária
    DROP TABLE IF EXISTS RawDataHistIssuance;
END $procedure$;



-- MARK: Hist Claim
DROP PROCEDURE IF EXISTS uspSinistroHist;
CREATE OR REPLACE PROCEDURE uspSinistroHist(IN date_initial DATE DEFAULT NULL, IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Verifica se os parâmetros de data são nulos e os define a partir do banco
    IF date_initial IS NULL AND date_final IS NULL THEN
        SELECT MIN(InicioVigencia) INTO date_initial FROM Sinistro.stg;
        SELECT MAX(InicioVigencia) INTO date_final FROM Sinistro.stg;
    END IF;

    -- Define nível de isolamento de transação
    -- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    WHILE date_initial <= date_final LOOP
        -- Cria tabela temporária
        DROP TABLE IF EXISTS RawDataClaim;
        CREATE TEMP TABLE RawDataClaim AS
            SELECT 
                LOWER(TRIM(Arquivo)) AS Arquivo
                ,LOWER(TRIM(Aba)) AS Aba
				,LinhaExcel
                ,LOWER(TRIM(StatusSinistro)) AS Situacao
                ,LOWER(TRIM(Segurado)) AS Segurado
                ,LOWER(TRIM(Cedente)) AS Cedente
                ,NumeroApolice
                ,LOWER(TRIM(Corretor)) AS Corretor
                ,LOWER(TRIM(Regulador)) AS Regulador
                ,Cast_Int(NumeroRamo) AS Ramo
                ,InicioVigencia AS VigenciaInicial
                ,Cast_Date(FimVigencia) AS VigenciaFinal
                ,Cast_Int(Contrato) AS Contrato
                ,Cast_Date(Aviso) AS Aviso
                ,LOWER(TRIM(CoberturaAcionada)) AS CoberturaAcionada
                ,Cast_Decimal(LmiCobertura)AS LmiCobertura
                ,Cast_Decimal(PrejuizoEstimado) AS PrejuizoEstimado
                ,Cast_Decimal(ValorReclamado) AS ValorReclamado
                ,Cast_Decimal(ValorApurado) AS ValorApurado
                ,Cast_Decimal(FranquiaPos) AS FranquiaParticipacaoObrigatoriaSegurado
                ,Cast_Decimal(IndizacaoPendente) AS IndizacaoPendente
                ,Cast_Decimal(HonorarioRegulacao) AS HonorarioRegulacao
                ,Cast_Decimal(DespesaRegulacao) AS DespesaRegulacao
                ,Cast_Decimal(TotalPagoIndenizacaoDespesa) AS TotalPagoIndenizacaoDespesa
                ,LOWER(TRIM(SinistroSemIndenizacaoJustificarMotivo)) AS SinistroSemIndenizacaoJustificarMotivo
                ,NumeroSinistro AS Sinistro
                ,Cast_Date(DataOcorrenciaSinistro) AS DataOcorrenciaSinistro
                ,LOWER(TRIM(AeronaveHangar)) AS AeronaveHangar
                ,LOWER(TRIM(Piloto)) AS Piloto
                ,LOWER(TRIM(CodigoAnac)) AS CodigoAnac
                ,LOWER(TRIM(Prefixo)) AS Prefixo
                ,CASE WHEN LENGTH(Ano) < 5 THEN Cast_Int(Ano) ELSE NULL END AS ANO
                ,LOWER(TRIM(Utilizacao)) AS Utilizacao
                ,LOWER(TRIM(Causa)) AS Causa
                ,Cast_Decimal(LmiSegurado) AS LmiSegurado
                ,Cast_Decimal(ValorReservaRelatorioPreliminar) AS ValorReservaRelatorioPreliminar
                ,CASE WHEN LEFT(Moeda,3) = 'USD' THEN 1 ELSE NULL END AS Moeda
                ,Cast_Decimal(Adiantamento) AS Adiantamento
                ,Cast_Decimal(IndenizacaoLiquidaPagaFinal) AS IndenizacaoLiquidaPagaFinal
                ,Cast_Decimal(DespesaRemocao) AS DespesaRemocao
                ,NumeroBordero AS NumeroBordero
                ,Cast_Date(DataPagamento) AS DataPagamento
            FROM Sinistro.stg
            WHERE InicioVigencia >= date_initial
            AND InicioVigencia < date_initial + INTERVAL '1 day';

        -- Remove entradas existentes
        DELETE FROM Sinistro.hist
        WHERE VigenciaInicial >= date_initial AND VigenciaInicial < date_initial + INTERVAL '1 day';

        -- Insere novos dados
        INSERT INTO Sinistro.hist
            SELECT * FROM RawDataClaim;

        -- Avança para o próximo dia
        date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
    END LOOP;

    -- Remove tabela temporária
    DROP TABLE IF EXISTS RawDataClaim;
END $procedure$;

/*
-- MARK: Dimension Update DOING
DROP PROCEDURE IF EXISTS USP_Dim_Update;
CREATE PROCEDURE USP_Dim_Update(IN date_initial DATE,IN date_final DATE)
LANGUAGE plpgsql
AS $$
	BEGIN
		IF (date_initial IS NULL AND date_final IS NULL) THEN
			SELECT MIN(BrokerRequest) INTO date_initial FROM Aeronautical_Hist_Quote;
	     	SELECT MAX(BrokerRequest) INTO date_final FROM Aeronautical_Hist_Quote;
		END IF;
		
		-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		
		WHILE date_initial <= date_final DO	
			
			DROP TEMPORARY TABLE IF EXISTS tempDimData;
			CREATE TEMPORARY TABLE tempDimData AS
				SELECT
				  Filename
				  ,Sheet
				  ,NULL AS Insured
				  ,CodNacionality
				  ,NULL AS CodAnac
				  ,Broker
				  ,BrokerRequest AS CtrlDate
				  ,Coverage
				  ,Underwriter
				  ,Status
				  ,Description
				  ,NULL AS Assignor
				  ,NULL AS Manufacturer
				  ,NULL AS AirshipModel
				  ,NULL AS AirshipManufactureYear
				  ,NULL AS AirshipUsage
				  ,NULL AS Pilot
				  ,1 AS Source
				FROM Aeronautical_Hist_Quote
				WHERE BrokerRequest >= date_initial
				AND BrokerRequest < DATE_ADD(date_initial, INTERVAL 1 DAY)

				UNION ALL

				SELECT 
				  Filename
				  ,Sheet
				  ,Insured
				  ,CodNacionality
				  ,NULL AS CodAnac
				  ,Broker
				  ,IssueDate AS CtrlDate
				  ,Coverage
				  ,NULL AS Underwriter
				  ,PolicyTpe AS 'Status'
				  ,NULL AS Description
				  ,Assignor
				  ,Manufacturer
				  ,AirshipModel
				  ,AirshipManufactureYear
				  ,AirshipUsage
				  ,NULL AS Pilot
				  ,2 AS Source
				FROM Aeronautical_Hist_Issuance
				WHERE IssueDate  >= date_initial
				AND IssueDate < DATE_ADD(date_initial, INTERVAL 1 DAY)

				UNION ALL

				SELECT 
				  Filename
				  ,Sheet
				  ,Insured
				  ,CodNacionality
				  ,CodAnac
				  ,Broker
  				  ,OcorrenceClaim AS CtrlDate
				  ,RequestedCoverage AS 'Coverage'
				  ,NULL AS Underwriter
				  ,Status
				  ,NULL AS Description
				  ,Assignor
				  ,NULL AS Manufacturer
				  ,NULL AS AirshipModel
				  ,NULL AS AirshipManufactureYear
				  ,NULL AS AirshipUsage
				  ,Pilot
				  ,3 AS Source
				FROM Claim_Hist
				WHERE IssuanceStart  >= date_initial
				AND IssuanceStart < DATE_ADD(date_initial, INTERVAL 1 DAY);
		
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
			
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
			# insere aero
			INSERT INTO Dim_Airship
				SELECT DISTINCT
					 NULL AS ID
					,CodNacionality 
					,CodAnac
					,Manufacturer
					,AirshipModel
					,AirshipManufactureYear
					,AirshipUsage
					,Pilot
					,NULL AS FinalDateControl
				FROM tempDimData AS orig
				WHERE CodNacionality IS NOT NULL
				AND orig.Source = 2
				AND NOT EXISTS(
					SELECT 1 
					FROM Dim_Airship AS dest
					WHERE 1=1
					AND dest.CodNacionality = orig.CodNacionality
					-- AND da.FinalDateControl IS NULL
				);
			
		
			# insere sinistro se 'CodNacionality is not null and otherFields is null', se não nao existir
			IF 1=1 THEN
				INSERT INTO Dim_Airship
					SELECT DISTINCT
						 NULL AS ID
						,CodNacionality 
						,NULL AS CodAnac
						,NULL AS Manufacturer
						,NULL AS AirshipModel
						,NULL AS AirshipManufactureYear
						,NULL AS AirshipUsage
						,NULL AS Pilot
						,NULL AS FinalDateControl
					FROM tempDimData AS orig
					WHERE 1=1
					AND orig.Source = 3
					AND CodNacionality IS NOT NULL
					AND NOT EXISTS(
						SELECT 1 
						FROM Dim_Airship AS dest
						WHERE 1=1
						AND dest.CodNacionality = orig.CodNacionality
					)
					AND (
							orig.CodAnac 				IS NULL
					 	AND orig.Manufacturer 			IS NULL
					    AND orig.AirshipModel 			IS NULL
					 	AND orig.AirshipManufactureYear IS NULL
						AND orig.AirshipUsage 			IS NULL
					    AND orig.Pilot 					IS NULL
					);

			END IF;
			
			IF 0=1 THEN
			# descontinua registros
			UPDATE Dim_Airship AS dest
				SET dest.FinalDateControl = NOW()
				WHERE 1=1
				AND EXISTS(
					SELECT 1 
						FROM tempDimData AS orig
						WHERE 1=1 
						AND orig.Source = 3
						AND orig.CodNacionality = dest.CodNacionality
						AND NOT (
								orig.CodAnac 				IS NULL
						 	AND orig.Manufacturer 			IS NULL
						    AND orig.AirshipManufactureYear IS NULL
						    AND orig.AirshipModel 			IS NULL
							AND orig.AirshipModel 			IS NULL
						    AND orig.Pilot 					IS NULL
							AND dest.CodAnac 				= orig.CodAnac
						 	AND dest.Manufacturer			= orig.Manufacturer
						    AND dest.ManufactureYear		= orig.AirshipManufactureYear
						    AND dest.Model 					= orig.AirshipModel
							AND dest.AirshipUsage 			= orig.AirshipUsage
						    AND	dest.Pilot 					= orig.Pilot
						)
				);
			END IF;
			
			# insere o novo registro se houver um com alguns dos outros capos não nulos ou diferente dos atuais
			IF 0=1 THEN
				/*INSERT INTO Dim_Airship
					SELECT DISTINCT
						 NULL AS ID
						,COALESCE(dest.CodNacionality, orig.CodNacionality)				AS CodNacionality
						,orig.CodAnac
						,COALESCE(dest.Manufacturer, 	orig.Manufacturer) 				AS Manufacturer		
						,COALESCE(dest.Manufacturer, 	orig.AirshipManufactureYear)	AS ManufactureYear
						,COALESCE(dest.Model, 			orig.AirshipModel) 				AS Model
						,COALESCE(dest.AirshipUsage, 	orig.AirshipUsage) 				AS AirshipUsage
						,orig.Pilot
						,NULL AS FinalDateControl
					FROM tempDimData AS orig
					LEFT JOIN Dim_Airship AS dest ON dest.CodNacionality = orig.CodNacionality	
					WHERE orig.CodNacionality IS NOT NULL
					AND orig.Source = 3
					AND NOT (					
							orig.CodAnac 				IS NULL
					 	AND orig.Manufacturer 			IS NULL
					    AND orig.AirshipManufactureYear IS NULL
					    AND orig.AirshipModel 			IS NULL
						AND orig.AirshipModel 			IS NULL
					    AND orig.Pilot 					IS NULL
					)
					AND NOT(
							dest.CodAnac 				= orig.CodAnac
					 	AND dest.Manufacturer			= orig.Manufacturer
					    AND dest.ManufactureYear		= orig.AirshipManufactureYear
					    AND dest.Model 					= orig.AirshipModel
						AND dest.AirshipUsage 			= orig.AirshipUsage
					    AND	dest.Pilot 					= orig.Pilot
					);*/
			
			
					DROP TEMPORARY TABLE IF EXISTS tempNewData;
					CREATE TEMPORARY TABLE tempNewData AS (
						SELECT DISTINCT
							 NULL AS ID
							,orig.CodNacionality
							,orig.CodAnac
							,orig.Manufacturer		
							,orig.AirshipManufactureYear
							,orig.AirshipModel
							,orig.AirshipUsage
							,orig.Pilot
							,NULL AS FinalDateControl
						FROM tempDimData AS orig
						WHERE orig.CodNacionality IS NOT NULL
						AND orig.Source = 3
						AND NOT EXISTS(
							SELECT 1 
							FROM Dim_Airship AS dest
							WHERE 1=1
							AND dest.CodNacionality = orig.CodNacionality
							AND dest.FinalDateControl IS NULL
						)
					);
					
					-- inserir dados de sinistro que possuam alguma diferenca com os atuais da dimensao
					INSERT INTO Dim_Airship
					SELECT * FROM tempNewData AS orig 
					WHERE NOT(
							orig.CodAnac 				IS NULL
					 	AND orig.Manufacturer 			IS NULL
					    AND orig.AirshipManufactureYear IS NULL
					    AND orig.AirshipModel 			IS NULL
						AND orig.AirshipModel 			IS NULL
					    AND orig.Pilot 					IS NULL
					)
					AND EXISTS(
						SELECT 
							1
						FROM Dim_Airship AS dest
						WHERE 1=1
						AND dest.CodNacionality = orig.CodNacionality
						AND dest.FinalDateControl IS  NULL
						
						AND NOT(
						/*
								  dest.CodAnac 			= orig.CodAnac OR (dest.CodAnac IS NOT NULL AND orig.CodAnac IS NULL)
						      AND dest.Manufacturer		= orig.Manufacturer OR (dest.Manufacturer IS NOT NULL AND orig.Manufacturer IS NULL)
						      AND dest.ManufactureYear 	= orig.AirshipManufactureYear OR (dest.ManufactureYear IS NOT NULL AND orig.AirshipManufactureYear IS NULL)
						      AND dest.Model 			= orig.AirshipModel OR (dest.Model IS NOT NULL AND orig.AirshipModel IS NULL)
						      AND dest.AirshipUsage		= orig.AirshipUsage OR (dest.AirshipUsage IS NOT NULL AND orig.AirshipUsage IS NULL)
						      AND dest.Pilot 			= orig.Pilot OR (dest.Pilot IS NOT NULL AND orig.Pilot IS NULL)
						      */
														  (dest.CodAnac IS NOT NULL AND orig.CodAnac IS NULL)
						      AND (dest.Manufacturer IS NOT NULL AND orig.Manufacturer IS NULL)
						      AND (dest.ManufactureYear IS NOT NULL AND orig.AirshipManufactureYear IS NULL)
						      AND (dest.Model IS NOT NULL AND orig.AirshipModel IS NULL)
						      AND (dest.AirshipUsage IS NOT NULL AND orig.AirshipUsage IS NULL)
						      AND (dest.Pilot IS NOT NULL AND orig.Pilot IS NULL)
							/*
								dest.CodAnac 				= orig.CodAnac
						 	AND dest.Manufacturer			= orig.Manufacturer
						    AND dest.ManufactureYear		= orig.AirshipManufactureYear
						    AND dest.Model 					= orig.AirshipModel
							AND dest.AirshipUsage 			= orig.AirshipUsage
						    AND	dest.Pilot 					= orig.Pilot
						   -- AND dest.FinalDateControl 		IS NULL 
						   */
					    )  
					);
						
					/*
					-- inserir dado caso o CodNacionality seja inexistente na dimensao
					INSERT INTO Dim_Airship
					SELECT * FROM tempNewData AS orig 
					WHERE NOT(
							orig.CodAnac 				IS NULL
					 	AND orig.Manufacturer 			IS NULL
					    AND orig.AirshipManufactureYear IS NULL
					    AND orig.AirshipModel 			IS NULL
						AND orig.AirshipModel 			IS NULL
					    AND orig.Pilot 					IS NULL
					)
					AND NOT EXISTS(
						SELECT 
							1
						FROM Dim_Airship AS dest
						WHERE 1=1
						AND dest.CodNacionality = orig.CodNacionality
						AND dest.FinalDateControl IS NULL
					);
					*/
						
			END IF;
			
			SET date_initial =  DATE_ADD(date_initial, INTERVAL 1 DAY);
			
		END LOOP;
		DROP TEMPORARY TABLE IF EXISTS tempNewData;
		DROP TEMPORARY TABLE IF EXISTS tempDimData;
	END$$;
*/

-- MARK: Quote Fact
DROP PROCEDURE IF EXISTS USP_Aeronautical_Fact_Quote;

CREATE OR REPLACE PROCEDURE USP_Aeronautical_Fact_Quote(IN date_initial DATE, IN date_final DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    IF date_initial IS NULL AND date_final IS NULL THEN
        SELECT MIN(BrokerRequest) INTO date_initial FROM Aeronautical_Hist_Quote;
        SELECT MAX(BrokerRequest) INTO date_final FROM Aeronautical_Hist_Quote;
    END IF;

    -- Define nível de isolamento de transação
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    WHILE date_initial <= date_final LOOP
        -- Remove entradas existentes
        DELETE FROM Aeronautical_Fact_Quote
        WHERE BrokerRequest >= date_initial AND BrokerRequest < date_initial + INTERVAL '1 day';

        -- Insere novos dados
        INSERT INTO Aeronautical_Fact_Quote
            SELECT 
                df.id AS Filename,
                ds.id AS Sheet,
                hist.BrokerRequest,
                hist.AsasRequestReturn,
                hist.BrokerRequestReturn,
                da.id AS CodNacionality,
                db.id AS Broker,
                dc.id AS Coverage,
                CASE WHEN hist.Renewal = 'N' THEN NULL ELSE 1 END AS Renewal,
                hist.IssuanceStart,
                de.id AS Employee,
                CASE WHEN hist.NetPriceReal IS NOT NULL THEN hist.NetPriceReal ELSE hist.NetPriceDollar END AS Netprice,
                CASE WHEN hist.NetPriceDollar IS NULL THEN NULL ELSE 1 END AS Dollar,
                dqs.id AS Status
            FROM Aeronautical_Hist_Quote AS hist
            LEFT JOIN Dim_File AS df ON df.Name = hist.Filename
            LEFT JOIN Dim_Sheet AS ds ON ds.Name = hist.Sheet
            LEFT JOIN Dim_Airship AS da ON da.CodNacionality = hist.CodNacionality
            LEFT JOIN Dim_Broker AS db ON db.Name = hist.Broker
            LEFT JOIN Dim_Coverage AS dc ON dc.Name = hist.Coverage
            LEFT JOIN Dim_Employee AS de ON de.Name = hist.Underwriter
            LEFT JOIN Dim_QuoteStatus AS dqs ON dqs.Name = hist.Status
            WHERE BrokerRequest >= date_initial AND BrokerRequest <= date_initial + INTERVAL '1 day';

        -- Avança para o próximo dia
        date_initial := date_initial + INTERVAL '1 day';
    END LOOP;

    -- Remove tabela temporária
    DROP TABLE IF EXISTS Dim_Data;
END $$;


-- PROCEDURE: public.USP_Dim_Update(date, date)

-- DROP PROCEDURE IF EXISTS public.USP_Dim_Update(date, date);

CREATE OR REPLACE PROCEDURE public.USP_Dim_Update(
	IN date_initial date DEFAULT NULL::date,
	IN date_final date DEFAULT NULL::date)
LANGUAGE 'plpgsql'
AS $BODY$
	BEGIN
		IF date_initial IS NULL AND date_final IS NULL THEN
				SELECT MIN(BrokerRequest) INTO date_initial FROM Aeronautical_Hist_Quote;
	     	SELECT MAX(BrokerRequest) INTO date_final FROM Aeronautical_Hist_Quote;
		END IF;
		
		-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		
		WHILE date_initial <= date_final LOOP	
			
			DROP TABLE IF EXISTS tempDimData;
			CREATE TEMP TABLE tempDimData AS
				SELECT
				  Filename
				  ,Sheet
				  ,NULL AS Insured
				  ,CodNacionality
				  ,NULL AS CodAnac
				  ,Broker
				  ,BrokerRequest AS CtrlDate
				  ,Coverage
				  ,Underwriter
				  ,Status
				  ,Description
				  ,NULL AS Assignor
				  ,NULL AS Manufacturer
				  ,NULL AS AirshipModel
				  ,NULL AS AirshipManufactureYear
				  ,NULL AS AirshipUsage
				  ,NULL AS Pilot
				  ,1 AS Source
				FROM Aeronautical_Hist_Quote
				WHERE BrokerRequest >= date_initial
				AND BrokerRequest < date_initial + INTERVAL '1 day'

				UNION ALL

				SELECT 
				  Filename
				  ,Sheet
				  ,Insured
				  ,CodNacionality
				  ,NULL AS CodAnac
				  ,Broker
				  ,IssueDate AS CtrlDate
				  ,Coverage
				  ,NULL AS Underwriter
				  ,PolicyTpe AS "Status"
				  ,NULL AS Description
				  ,Assignor
				  ,Manufacturer
				  ,AirshipModel
				  ,AirshipManufactureYear
				  ,AirshipUsage
				  ,NULL AS Pilot
				  ,2 AS Source
				FROM Aeronautical_Hist_Issuance
				WHERE IssueDate  >= date_initial
				AND IssueDate < date_initial + INTERVAL '1 day'

				UNION ALL

				SELECT 
				  Filename
				  ,Sheet
				  ,Insured
				  ,CodNacionality
				  ,CodAnac
				  ,Broker
  				,OcorrenceClaim AS CtrlDate
				  ,RequestedCoverage AS "Coverage"
				  ,NULL AS Underwriter
				  ,Status
				  ,NULL AS Description
				  ,Assignor
				  ,NULL AS Manufacturer
				  ,NULL AS AirshipModel
				  ,NULL AS AirshipManufactureYear
				  ,NULL AS AirshipUsage
				  ,Pilot
				  ,3 AS Source
				FROM Claim_Hist
				WHERE IssuanceStart >= date_initial
				AND IssuanceStart < date_initial + INTERVAL '1 day';
		
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
			
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
			-- insere dados de cotação
			INSERT INTO Dim_Airship (CodNacionality)
				SELECT DISTINCT
					LEFT(CodNacionality, 50)
				FROM tempDimData AS orig
				WHERE CodNacionality IS NOT NULL
				AND orig.Source = 1
				AND NOT EXISTS(
					SELECT 1 
					FROM Dim_Airship AS dest
					WHERE 1=1
					AND dest.CodNacionality = orig.CodNacionality
					-- AND da.FinalDateControl IS NULL
				);
        
        
        -- atualiza dados das aeronaves cotadas com os dados de emissao
        MERGE INTO Dim_Airship as dest
          USING(
            SELECT DISTINCT          
              CodNacionality
              ,Manufacturer
            	,AirshipManufactureYear
              ,AirshipModel
              ,AirshipUsage
            FROM tempDimData
            WHERE CodNacionality IS NOT NULL
			AND Source = 2
			-- AND IssueDate >= date_initial
			-- AND IssueDate < date_initial + INTERVAL '1 day'
          ) AS orig ON dest.CodNacionality = orig.CodNacionality
         	WHEN MATCHED THEN 
          UPDATE SET
          		CodNacionality 		= orig.CodNacionality
              	,Manufacturer 		= orig.Manufacturer
            	,ManufactureYear	= orig.AirshipManufactureYear
              	,Model 				= orig.AirshipModel
              ,	AirshipUsage	 	= orig.AirshipUsage
           WHEN NOT MATCHED THEN
           	INSERT(CodNacionality,Manufacturer,ManufactureYear,Model,AirshipUsage)
            VALUES(orig.CodNacionality,orig.Manufacturer,orig.AirshipManufactureYear,orig.AirshipModel,orig.AirshipUsage);
        
	   date_initial := date_initial + INTERVAL '1 day';
 			RAISE NOTICE 'Initial Date: %',date_initial;
      
		END LOOP;
		DROP TABLE IF EXISTS tempDimData;
	END 
$BODY$;
ALTER PROCEDURE public.usp_dim_update(date, date)
    OWNER TO sysadmin;
