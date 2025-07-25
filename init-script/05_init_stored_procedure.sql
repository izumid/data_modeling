
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

-- MARK: Quote Hist
DROP PROCEDURE IF EXISTS Aeronautico.uspHistCotacao;
CREATE OR REPLACE PROCEDURE Aeronautico.uspHistCotacao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Verifica se os parâmetros de data são nulos e os define a partir do banco
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataPedido) INTO date_initial FROM Aeronautico.stgCotacao;
		SELECT MAX(DataPedido) INTO date_final FROM Aeronautico.stgCotacao;
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
			   	Corp.cast_date(DataRetornoCorretor) AS DataRetornoCorretor,
			   	Corp.cast_date(DataRetorno) AS DataRetorno,
				LOWER(TRIM(Prefixo)) AS Prefixo,
				LOWER(TRIM(Corretor)) AS Corretor,
				CASE 
					WHEN CascoHangar = 'C' THEN 'casco'
					WHEN CascoHangar = 'H' THEN 'hangar'
					WHEN CascoHangar = 'D' THEN 'drone'
					ELSE LOWER(TRIM(CascoHangar)) 
				END AS CascoHangar,
				LOWER(TRIM(Renovacao)) AS Renovacao,
				Corp.cast_date(Vigencia) AS Vigencia,
				LOWER(TRIM(Subscritor)) AS Subscritor,
				Corp.cast_decimal(MoedaReal) AS MoedaReal,
				Corp.cast_decimal(MoedaDolar)AS MoedaDolar,
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
		WHERE RetornoCorretor >= date_initial AND RetornoCorretor < date_initial + INTERVAL '1 day';

		-- Insere novos dados
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

		-- Avança para o próximo dia
		date_initial := date_initial + INTERVAL '1 day';
		RAISE NOTICE 'Initial Date: %',date_initial;
		-- COMMIT;
	END LOOP;

	-- Remove tabela temporaria, evitando conflitos de criacao
	DROP TABLE IF EXISTS RawData;
END;
$procedure$;


-- MARK: Issuance Hist
DROP PROCEDURE IF EXISTS Aeronautico.uspHistEmissao(IN date_initial DATE, IN date_final DATE);
CREATE OR REPLACE PROCEDURE Aeronautico.uspHistEmissao(IN date_initial DATE DEFAULT NULL, IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql
AS $procedure$
DECLARE
	current_date DATE;
BEGIN
	-- Verifica se os parâmetros de data são nulos e os define a partir do banco
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataEmissao) INTO date_initial FROM Aeronautico.stgEmissao;
		SELECT MAX(DataEmissao) INTO date_final FROM Aeronautico.stgEmissao;
	END IF;

	-- Define nível de isolamento de transação
	-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	WHILE date_initial <= date_final LOOP
		-- Cria tabela temporária
		DROP TABLE IF EXISTS RawDataHistIssuance;
		CREATE TEMP TABLE RawDataHistIssuance AS
			SELECT 
				LOWER(TRIM(Arquivo)) AS Arquivo
				,LOWER(TRIM(Aba)) AS Aba
				,LinhaExcel
				,LOWER(TRIM(Segurado)) AS Segurado
				,LOWER(TRIM(CnpjCpf)) AS CnpjCpf
				,LOWER(TRIM(Ramo)) AS Ramo
				,LOWER(TRIM(NumeroApolice)) AS NumeroApolice
				,LOWER(TRIM(TipoDocumento)) AS TipoDocumento
				,DataEmissao
				,Corp.cast_date(VigenciaInicial) AS VigenciaInicial
				,Corp.cast_date(VigenciaFinal) AS VigenciaFinal
				,Corp.cast_decimal(PremioLiquido) AS PremioLiquido
				,Corp.cast_decimal(ComissaoTotal) AS ComissaoTotal
				,Corp.cast_decimal(ComissaoTotalValor) AS ComissaoTotalValor
				,Corp.cast_decimal(QuantidadeParcela) AS QuantidadeParcela
				,Corp.cast_date(PrimeiroVencimentoParcela) AS PrimeiroVencimentoParcela
				,LOWER(TRIM(Corretor)) AS Corretor
				,LOWER(TRIM(Prefixo)) AS Prefixo
				,LOWER(TRIM(Cedente)) AS Cedente
				,LOWER(TRIM(Fabricante)) AS Fabricante
				,LOWER(TRIM(Modelo)) AS Modelo
				,CASE WHEN LENGTH(AnoFabricacao) < 5 THEN AnoFabricacao::INT ELSE NULL END AS AnoFabricacao
				,LOWER(TRIM(Utilizacao)) AS UTILIZACAO
				,Corp.cast_decimal(ImportanciaSeguradaCasco) AS ImportanciaSeguradaCasco
				,Corp.cast_decimal(PremioLiquidoCasco) AS PremioLiquidoCasco
				,Corp.cast_decimal(ImportanciaSeguradaLuc) AS ImportanciaSeguradaLuc
				,Corp.cast_decimal(PremioLiquidoLuc) AS PremioLiquidoLuc
				,Corp.cast_decimal(PremioLiquidoConvertido) AS PremioLiquidoConvertido
				,Corp.cast_decimal(TaxaCambialEmissao) AS TaxaCambialEmissao
				,CASE WHEN Renovacao = 'Sim' THEN 1 ELSE 0 END AS Renovacao
			FROM Aeronautico.stgEmissao
			WHERE DataEmissao >= date_initial
			AND DataEmissao < date_initial + INTERVAL '1 day';

		-- Remove entradas existentes
		DELETE FROM Aeronautico.histEmissao
		WHERE Emissao >= date_initial AND Emissao < date_initial + INTERVAL '1 day';

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
DROP PROCEDURE IF EXISTS Sinistro.uspHist;
CREATE OR REPLACE PROCEDURE Sinistro.uspHist(IN date_initial DATE DEFAULT NULL, IN date_final DATE DEFAULT NULL)
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
				,Corp.Cast_Int(NumeroRamo) AS Ramo
				,InicioVigencia AS VigenciaInicial
				,Corp.Cast_Date(FimVigencia) AS VigenciaFinal
				,Corp.Cast_Int(Contrato) AS Contrato
				,Corp.Cast_Date(DataAviso) AS Aviso
				,LOWER(TRIM(CoberturaAcionada)) AS CoberturaAcionada
				,Corp.Cast_Decimal(LmiCobertura)AS LmiCobertura
				,Corp.Cast_Decimal(PrejuizoEstimado) AS PrejuizoEstimado
				,Corp.Cast_Decimal(ValorReclamado) AS ValorReclamado
				,Corp.Cast_Decimal(ValorApurado) AS ValorApurado
				,Corp.Cast_Decimal(FranquiaPos) AS FranquiaParticipacaoObrigatoriaSegurado
				,Corp.Cast_Decimal(IndizacaoPendente) AS IndizacaoPendente
				,Corp.Cast_Decimal(HonorarioRegulacao) AS HonorarioRegulacao
				,Corp.Cast_Decimal(DespesaRegulacao) AS DespesaRegulacao
				,Corp.Cast_Decimal(TotalPagoIndenizacaoDespesa) AS TotalPagoIndenizacaoDespesa
				,LOWER(TRIM(SinistroSemIndenizacaoJustificarMotivo)) AS SinistroSemIndenizacaoJustificarMotivo
				,NumeroSinistro AS Sinistro
				,Corp.Cast_Date(DataOcorrenciaSinistro) AS DataOcorrenciaSinistro
				,LOWER(TRIM(AeronaveHangar)) AS AeronaveHangar
				,LOWER(TRIM(Piloto)) AS Piloto
				,LOWER(TRIM(CodigoAnac)) AS CodigoAnac
				,LOWER(TRIM(Prefixo)) AS Prefixo
				,CASE WHEN LENGTH(Ano) < 5 THEN Corp.Cast_Int(Ano) ELSE NULL END AS ANO
				,LOWER(TRIM(Utilizacao)) AS Utilizacao
				,LOWER(TRIM(Causa)) AS Causa
				,Corp.Cast_Decimal(LmiSegurado) AS LmiSegurado
				,Corp.Cast_Decimal(ValorReservaRelatorioPreliminar) AS ValorReservaRelatorioPreliminar
				,CASE WHEN LEFT(Moeda,3) = 'USD' THEN 1 ELSE NULL END AS Moeda
				,Corp.Cast_Decimal(Adiantamento) AS Adiantamento
				,Corp.Cast_Decimal(IndenizacaoLiquidaPagaFinal) AS IndenizacaoLiquidaPagaFinal
				,Corp.Cast_Decimal(DespesaRemocao) AS DespesaRemocao
				,NumeroBordero AS NumeroBordero
				,Corp.Cast_Date(DataPagamento) AS DataPagamento
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


-- MARK: Quote Fact
DROP PROCEDURE IF EXISTS Aeronautico.uspFactQuote;
CREATE OR REPLACE PROCEDURE Aeronautico.uspFactQuote(IN date_initial DATE, IN date_final DATE)
LANGUAGE plpgsql
AS $procedure$
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
				da.id AS Prefixo,
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
			LEFT JOIN Dim_Airship AS da ON da.Prefixo = hist.Prefixo
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
END $procedure$;


DROP PROCEDURE IF EXISTS Corp.uspDimUpdate(date, date);
CREATE OR REPLACE PROCEDURE Corp.uspDimUpdate(
	IN date_initial date DEFAULT NULL::date,
	IN date_final date DEFAULT NULL::date)
LANGUAGE 'plpgsql'
AS $procedure$
	BEGIN
		IF date_initial IS NULL AND date_final IS NULL THEN
			SELECT MIN(RetornoCorretor) INTO date_initial FROM Aeronautico.histCotacao;
		 	SELECT MAX(RetornoCorretor) INTO date_final FROM Aeronautico.histCotacao;
		END IF;
		
		-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
		
		WHILE date_initial <= date_final LOOP	
			
			DROP TABLE IF EXISTS tempDimData;
			CREATE TEMP TABLE tempDimData AS
				SELECT
				  Arquivo
				  ,Aba
				  --,NULL AS Insured
				  ,Prefixo
				  ,NULL AS CodAnac
				  ,Corretor
				  ,RetornoCorretor AS Controle
				  ,Cobertura
				  ,Subscritor
				  ,Situacao
				  ,Informacao
				  ,NULL AS Cedente
				  ,NULL AS Fabricante
				  ,NULL AS Modelo
				  ,NULL AS AnoFabricacao
				  ,NULL AS TipoUtilizacao
				  ,NULL AS Piloto
				  ,1 AS Source
				FROM Aeronautico.histCotacao
				WHERE RetornoCorretor >= date_initial
				AND RetornoCorretor < date_initial + INTERVAL '1 day'

				UNION ALL

				SELECT 
				  Arquivo
				  ,Aba
				  --,Insured
				  ,Prefixo
				  ,NULL AS CodAnac
				  ,Corretor
				  ,Emissao AS Controle
				  ,Ramo
				  ,NULL AS Subscritor
				  ,ApoliceTipo AS Situacao
				  ,NULL AS Informacao
				  ,Cedente
				  ,Fabricante
				  ,ModeloAeronave
				  ,AnoFabricacaoAeronave
				  ,UsoAeronave
				  ,NULL AS Piloto
				  ,2 AS Source
				FROM Aeronautico.histEmissao
				WHERE Emissao  >= date_initial
				AND Emissao < date_initial + INTERVAL '1 day'

				UNION ALL

				SELECT 
				  Arquivo
				  ,Aba
				  --,Insured
				  ,Prefixo
				  ,CodigoAnac
				  ,Corretor
  				  ,Ocorrencia AS Controle
				  ,Cobertura AS Coverage
				  ,NULL AS Subscritor
				  ,Situacao
				  ,NULL AS Informacao
				  ,Cedente
				  ,NULL AS Fabricante
				  ,NULL AS ModeloAeronave
				  ,NULL AS AnoFabricacaoAeronave
				  ,NULL AS UsoAeronave
				  ,Piloto
				  ,3 AS Source
				FROM Sinistro.hist
				WHERE VigenciaInicial >= date_initial
				AND VigenciaInicial < date_initial + INTERVAL '1 day';
		
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
			
			-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	 
			-- insere dados de cotação
			INSERT INTO Aeronautico.dimAeronave (Prefixo)
				SELECT DISTINCT
					LEFT(Prefixo, 50)
				FROM tempDimData AS orig
				WHERE Prefixo IS NOT NULL
				AND orig.Source = 1
				AND NOT EXISTS(
					SELECT 1 
					FROM Aeronautico.dimAeronave AS dest
					WHERE 1=1
					AND dest.Prefixo = orig.Prefixo
					-- AND da.FinalDateControl IS NULL
				);
		
		
			-- update airships with quoted data to issuance
			MERGE INTO Aeronautico.dimAeronave as dest
			  USING(
				SELECT DISTINCT          
				  Prefixo
				  ,Fabricante
				  ,Modelo
				  ,AnoFabricacao
				  ,TipoUtilizacao
				FROM tempDimData
				WHERE Prefixo IS NOT NULL
				AND Source = 2
			  ) AS orig ON orig.Prefixo = dest.Prefixo
			WHEN MATCHED THEN 
				UPDATE SET
				 Prefixo		= orig.Prefixo
				,Fabricante		= orig.Fabricante
				,AnoFabricacao	= orig.AnoFabricacao
				,Modelo			= orig.Modelo
				,TipoUtilizacao	= orig.TipoUtilizacao
			WHEN NOT MATCHED THEN
			   INSERT(Prefixo,Fabricante,AnoFabricacao,Modelo,TipoUtilizacao)
				VALUES(orig.Prefixo,orig.AnoFabricacao,orig.AnoFabricacao,orig.Modelo,orig.TipoUtilizacao);
	
		   	date_initial := date_initial + INTERVAL '1 day';
	 		RAISE NOTICE 'Initial Date: %',date_initial;
	  
		END LOOP;
		DROP TABLE IF EXISTS tempDimData;
	END 
$procedure$;

-- ALTER PROCEDURE Corp.usp_dim_update(date, date) OWNER TO sysadmin;
