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
    ,Tiposeguro VARCHAR(255)
    ,Situacao VARCHAR(255)
    ,Deadline DATE
    ,Envio DATE
    ,VigenciaFinal DATE
    ,Hot VARCHAR(255)
    ,Premio DOUBLE PRECISION 
    ,Subscritor VARCHAR(50)
    ,Atividade VARCHAR(255)
    ,MotivoDeclinio VARCHAR(255)
    ,Enviado DATE
    ,Comercial VARCHAR(50)
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
    ,VigenciaInicial DATE
    ,VigenciaFinal VARCHAR(255)
    ,PremioLiquido VARCHAR(255)
    ,ComissaoTotal VARCHAR(255)
    ,ComissaoTotalValor VARCHAR(255)
    ,QuantidadeParcela VARCHAR(255)
    ,PrimeiroVencimentoParcela VARCHAR(255)
    ,Corretor VARCHAR(255)
    ,Contrato VARCHAR(255)
    ,OneOff VARCHAR(255)
    ,Status VARCHAR(255)
    ,MesBound VARCHAR(255)
    ,Lmg VARCHAR(255)
    ,PremioNet VARCHAR(255)
    ,ComissaoProLabore VARCHAR(255)
    ,ValorProLabore VARCHAR(255)
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



-- MARK: USP STG
DROP PROCEDURE IF EXISTS linhaFinanceira.uspHistCotacao;
CREATE OR REPLACE PROCEDURE linhaFinanceira.uspHistCotacao(IN date_initial DATE DEFAULT NULL,IN date_final DATE DEFAULT NULL)
LANGUAGE plpgsql AS $procedure$
BEGIN 
	-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	-- Check nullable data parameters, if null get the min and max date of stage to fill historic table
	IF date_initial IS NULL AND date_final IS NULL THEN
		SELECT MIN(DataEntrada) INTO date_initial FROM linhaFinanceira.stgCotacao;
		SELECT MAX(DataEntrada) INTO date_final FROM linhaFinanceira.stgCotacao;
	END IF;
	
	WHILE date_initial <= date_final LOOP
	
		DROP TABLE IF EXISTS RawData_FL;
		CREATE TEMP TABLE RawData_FL AS
			SELECT
                LOWER(TRIM(LinhaExcel)) AS LinhaExcel
                ,LOWER(TRIM(Arquivo)) AS Arquivo
                ,LOWER(TRIM(Aba)) AS Aba
                ,Corp.Cast_Date(Entrada) Entrada
                ,LOWER(TRIM(SeguroFac)) AS Segmento
                ,LOWER(TRIM(Ramo)) AS Ramo
                ,LOWER(TRIM(Segurado)) AS Segurado
                ,LOWER(TRIM(Corretor)) AS Corretor
                ,LOWER(TRIM(TiposSeguro)) AS TiposSeguro
                ,LOWER(TRIM(Status)) AS Situacao
                ,Corp.Cast_Date(Deadline) AS Deadline
                ,Corp.Cast_Date(DataEnvio) AS Envio
                ,Corp.Cast_Date(FimVigencia) AS VigenciaFinal
                ,LOWER(TRIM(Hot)) AS Hot
                ,Corp.Cast_Decimal(Premio) AS Premio
                ,LOWER(TRIM(Subscritor)) AS Subscritor
                ,LOWER(TRIM(Atividade)) AS Atividade
                ,LOWER(TRIM(MotivoDeclinio)) AS MotivoDeclinio
                ,Corp.Cast_Date(EnviadoEm) AS Enviado
                ,LOWER(TRIM(Comercial)) AS Comercial
                ,LOWER(TRIM(Modalidade)) AS Modalidade
                ,Corp.Cast_Decimal(Faturamento)) AS Faturamento
                ,Corp.Cast_Decimal(Limite)) AS Limite
                ,(SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApoliceSeguradora,'[^0-9]+','','g'))), ' ', -1)) AS Apolice
			FROM linhaFinanceira.stgCotacao
			WHERE DataEntrada >= date_initial
			AND DataEntrada < date_initial + INTERVAL '1 day';

		-- deprecate old registries filling the 'desatualizado' field and insert new registries
		MERGE INTO linhaFinanceira.histCotacao AS dest
			USING(
				SELECT 
                    LinhaExcel
                    ,Arquivo
                    ,Aba
                    ,Entrada
                    ,Segmento
                    ,Ramo
                    ,Segurado
                    ,Corretor
                    ,TiposSeguro
                    ,Situacao
                    ,Deadline
                    ,Envio
                    ,VigenciaFinal
                    ,Hot
                    ,Premio
                    ,Subscritor
                    ,Atividade
                    ,MotivoDeclinio
                    ,Enviado
                    ,Comercial
                    ,Modalidade
                    ,Faturamento   
                    ,Limite
                    ,Apolice
				FROM RawData_FL where 1=1 and Apolice IS NULL) AS orig
				ON(
				    AND dest.LinhaExcel = orig.LinhaExcel
                    ,AND dest.Arquivo = orig.Arquivo
                    ,AND dest.Aba = orig.Aba
                    ,AND dest.Entrada = orig.Entrada
                    ,AND dest.Segmento = orig.Segmento
                    ,AND dest.Ramo = orig.Ramo
                    ,AND dest.Segurado = orig.Segurado
                    ,AND dest.Corretor = orig.Corretor
                    ,AND dest.TiposSeguro = orig.TiposSeguro
                    ,AND dest.Situacao = orig.Situacao
                    ,AND dest.Deadline = orig.Deadline
                    ,AND dest.Envio = orig.Envio
                    ,AND dest.VigenciaFinal = orig.VigenciaFinal
                    ,AND dest.Hot = orig.Hot
                    ,AND dest.Premio = orig.Premio
                    ,AND dest.Subscritor = orig.Subscritor
                    ,AND dest.Atividade = orig.Atividade
                    ,AND dest.MotivoDeclinio = orig.MotivoDeclinio
                    ,AND dest.Enviado = orig.Enviado
                    ,AND dest.Comercial = orig.Comercial
                    ,AND dest.Modalidade = orig.Modalidade
                    ,AND dest.Faturamento = orig.Faturamento
                    ,AND dest.Limite = orig.Limite
                    ,AND dest.Apolice = orig.Apolice
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
		INSERT INTO linhaFinanceira.histCotacao
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
			FROM RawData_FL AS orig
			WHERE 1=1
			AND EXISTS(
				SELECT 1 FROM linhaFinanceira.histCotacao as dest
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
	DROP TABLE IF EXISTS RawData_FL;
END;
$procedure$;