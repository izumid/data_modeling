--MARK: Stage
CREATE SCHEMA IF NOT EXISTS Sinistro;
DROP TABLE IF EXISTS Sinistro.stg;
CREATE TABLE Sinistro.stg(
	LinhaExcel VARCHAR(255)
	,Arquivo VARCHAR(255)
	,Aba VARCHAR(30)
	,StatusSinistro VARCHAR(100)
	,Segurado VARCHAR(255)
	,Cedente VARCHAR(255)
	,NumeroApolice VARCHAR(50)
	,Corretor VARCHAR(255)
	,Regulador VARCHAR(25)
	,NumeroRamo VARCHAR(25)
	,InicioVigencia DATE
	,FimVigencia VARCHAR(25)
	,Contrato VARCHAR(25)
	,DataAviso VARCHAR(25)
	,CoberturaAcionada VARCHAR(255)
	,LmiCobertura VARCHAR(50)
	,PrejuizoEstimado VARCHAR(25)
	,ValorReclamado VARCHAR(25)
	,ValorApurado VARCHAR(25)
	,FranquiaPos VARCHAR(25)
	,IndizacaoPendente VARCHAR(25)
	,HonorarioRegulacao VARCHAR(25)
	,DespesaRegulacao VARCHAR(25)
	,TotalPagoIndenizacaoDespesa VARCHAR(25)
    ,SinistroSemIndenizacaoJustificarMotivo VARCHAR(255)
	,NumeroSinistro VARCHAR(50)
	,DataOcorrenciaSinistro VARCHAR(25)
	,AeronaveHangar VARCHAR(100)
	,Piloto VARCHAR(255)
	,CodigoAnac VARCHAR(255)
	,Prefixo VARCHAR(255)
	,Ano VARCHAR(25)
	,Utilizacao VARCHAR(255)
	,Causa VARCHAR(255)
	,LmiSegurado VARCHAR(50)
    ,ValorReservaRelatorioPreliminar VARCHAR(25)
	,Moeda VARCHAR(25)
	,Adiantamento VARCHAR(25)
	,IndenizacaoLiquidaPagaFinal VARCHAR(25)
	,DespesaRemocao VARCHAR(25)
	,NumeroBordero VARCHAR(25)
	,DataPagamento VARCHAR(25)
    ,IndenizacaoLiquidaPagaSeguradora VARCHAR(25)
	,DespesaPagaSeguradora VARCHAR(25)
	,TotalPagoSeguradora VARCHAR(25)
	,PslSeguradora VARCHAR(25)
	,Diferenca VARCHAR(25)
	,Comentario VARCHAR(255)
	-- ,COMENTARIOSSOBREPENDENCIAS VARCHAR(255)
	,Tomador VARCHAR(255)
	,Reclamante VARCHAR(255)
	,Caracterizacao VARCHAR(255)
	,Edital VARCHAR(255)
	,NumeroOficio VARCHAR(50)
	,Processo VARCHAR(255)
	,Assunto VARCHAR(255)
	,Judicial VARCHAR(255)
	,ValorMulta VARCHAR(25)
	,Salvado VARCHAR(25)
	,ValorIndenizado VARCHAR(25)
	,DataRetroatividade VARCHAR(25)
	,Terceiro VARCHAR(255)
	,ValorIndenizavel VARCHAR(25)
	,Situacao VARCHAR(255)
	,DataFatoGerador VARCHAR(25)
	,DataVistoria VARCHAR(25)
	,BemLocalSinistrado VARCHAR(255)
	,IndenizacaoLiquidaPaga VARCHAR(25)
	,ressarcimentoseguradora VARCHAR(25)
  
);


-- MARK: History
DROP TABLE IF EXISTS Sinistro.hist;
CREATE TABLE Sinistro.hist(
	Arquivo VARCHAR(255) NULL
	,Aba VARCHAR(30) NULL
	,LinhaExcel INT NOT NULL
	,Situacao VARCHAR(100) NULL
	,Segurado VARCHAR(255) NULL
	,Cedente VARCHAR(255) NULL
	,Apolice VARCHAR(50) NULL
	,Corretor VARCHAR(255) NULL
	,Regulador VARCHAR(25) NULL
	,Ramo Int NULL
	,VigenciaInicial DATE NULL
	,VigenciaFinal DATE NULL
	,Contrato INT NULL
	,Aviso DATE NULL
	,Cobertura VARCHAR(255) NULL
	,CoberturaLimiteMaximoIndenizacao DOUBLE PRECISION NULL
	,PrejuizoEstimado DOUBLE PRECISION NULL
	,Reclamado DOUBLE PRECISION NULL
	,Apurado DOUBLE PRECISION NULL
	,FranquiaParticipacaoObrigatoriaSegurado DOUBLE PRECISION NULL
	,IndizacaoPendente DOUBLE PRECISION NULL
	,RegulacaoHonorario DOUBLE PRECISION NULL
	,RegulacaoDespesa DOUBLE PRECISION NULL
	,TotalPagoIndenizacaoDespesa DOUBLE PRECISION NULL
	,JustificativaAusenciaIndenizacao VARCHAR(255) NULL
	,Sinistro VARCHAR(50) NULL
	,Ocorrencia DATE NULL
	,AeronaveHangar VARCHAR(100) NULL
	,Piloto VARCHAR(255) NULL
	,CodigoAnac VARCHAR(255) NULL
	,Prefixo VARCHAR(13) NULL
	,AeronaveAno INT NULL
	,AeronaveTipoUtilizacao VARCHAR(255) NULL
	,Causa VARCHAR(255) NULL
	,LimiteMaximoIndenizatorioSegurado DOUBLE PRECISION NULL
	,ValorReservaRelatorioPreliminar DOUBLE PRECISION NULL
	,Dolar smallint NULL
	,Adiantamento DOUBLE PRECISION NULL
	,IndenizacaoLiquidaPagaFinal DOUBLE PRECISION NULL
	,DespesaRemocao DOUBLE PRECISION NULL
	,Bordero VARCHAR(25) NULL
	,Pagamento DATE NULL
	,Desatualizado DATE NULL
	/*
	,LiquidIndemnificationPaid DOUBLE PRECISION NULL
	,ExpensePaid DOUBLE PRECISION NULL
	,TotalPaid DOUBLE PRECISION NULL
	,Psl DOUBLE PRECISION NULL
	,Delta DOUBLE PRECISION NULL
	,Comentary VARCHAR(255) NULL
	,PolicyHolder VARCHAR(255) NULL
	,Claimant VARCHAR(255) NULL
	,Characterization VARCHAR(255) NULL
	,PublicNotice VARCHAR(255) NULL
	,OfficialCommunication VARCHAR(50) NULL
	,AdministrativeProcedure VARCHAR(255) NULL
	,Subject VARCHAR(255) NULL
	,Judicial SMALLINT NULL
	,Penalty DOUBLE PRECISION NULL
	,Saved DOUBLE PRECISION NULL
	,Indemnified DOUBLE PRECISION NULL
	,Retroactivity DATE NULL
	,ThirdParties VARCHAR(255) NULL
	,Indemnifiable DOUBLE PRECISION NULL
	,Situation VARCHAR(255) NULL
	,GenerateFact DATE NULL
	,Assesment DATE NULL
	,AssetLocation VARCHAR(255) NULL
	,LiquidPaiddIndemnification DOUBLE PRECISION NULL
	*/
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


-- MARK: Dimension
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


-- MARK: Procedure
DROP PROCEDURE IF EXISTS Sinistro.uspHist(date, date);
CREATE OR REPLACE PROCEDURE Sinistro.uspHist(
	IN date_initial date DEFAULT NULL::date,
	IN date_final date DEFAULT NULL::date)
LANGUAGE 'plpgsql'
AS $procedure$
    BEGIN
        -- Check nullable data parameters, if null get the min and max date of stage to fill historic table
        IF date_initial IS NULL AND date_final IS NULL THEN
            SELECT MIN(InicioVigencia) INTO date_initial FROM Sinistro.stg;
            SELECT MAX(InicioVigencia) INTO date_final FROM Sinistro.stg;
        END IF;

        -- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        WHILE date_initial <= date_final LOOP

            DROP TABLE IF EXISTS RawData_Claim;
            CREATE TEMP TABLE RawData_Claim AS
                SELECT DISTINCT
                    LOWER(TRIM(Arquivo)) AS Arquivo
                    ,LOWER(TRIM(Aba)) AS Aba
                    ,LinhaExcel
                    ,LOWER(TRIM(StatusSinistro)) AS Situacao
                    ,LOWER(TRIM(Segurado)) AS Segurado
                    ,LOWER(TRIM(Cedente)) AS Cedente
					,SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroApolice,'[^0-9]+','','g'))), ' ', -1) AS Apolice
                    ,LOWER(TRIM(Corretor)) AS Corretor
                    ,LOWER(TRIM(Regulador)) AS Regulador
                    ,Corp.Cast_Int(NumeroRamo) AS Ramo
                    ,InicioVigencia AS VigenciaInicial
                    ,Corp.Cast_Date(FimVigencia) AS VigenciaFinal
                    ,Corp.Cast_Int(Contrato) AS Contrato
                    ,Corp.Cast_Date(DataAviso) AS Aviso
                    ,LOWER(TRIM(CoberturaAcionada)) AS Cobertura
                    ,Corp.Cast_Decimal(LmiCobertura)AS CoberturaLimiteMaximoIndenizacao
                    ,Corp.Cast_Decimal(PrejuizoEstimado) AS PrejuizoEstimado
                    ,Corp.Cast_Decimal(ValorReclamado) AS Reclamado
                    ,Corp.Cast_Decimal(ValorApurado) AS Apurado
                    ,Corp.Cast_Decimal(FranquiaPos) AS FranquiaParticipacaoObrigatoriaSegurado
                    ,Corp.Cast_Decimal(IndizacaoPendente) AS IndizacaoPendente
                    ,Corp.Cast_Decimal(HonorarioRegulacao) AS RegulacaoHonorario
                    ,Corp.Cast_Decimal(DespesaRegulacao) AS RegulacaoDespesa
                    ,Corp.Cast_Decimal(TotalPagoIndenizacaoDespesa) AS TotalPagoIndenizacaoDespesa
                    ,LOWER(TRIM(SinistroSemIndenizacaoJustificarMotivo)) AS JustificativaAusenciaIndenizacao
					,SPLIT_PART(LOWER(TRIM(REGEXP_REPLACE(NumeroSinistro,'[^0-9]+','','g'))), ' ', -1) AS Sinistro
                    ,Corp.Cast_Date(DataOcorrenciaSinistro) AS Ocorrencia
                    ,LOWER(TRIM(AeronaveHangar)) AS AeronaveHangar
                    ,LOWER(TRIM(Piloto)) AS Piloto
                    ,LOWER(TRIM(CodigoAnac)) AS CodigoAnac
                    ,LOWER(TRIM(Prefixo)) AS Prefixo
                    ,CASE WHEN LENGTH(Ano) < 5 THEN Corp.Cast_Int(Ano) ELSE NULL END AS AeronaveAno
                    ,LOWER(TRIM(Utilizacao)) AS AeronaveTipoUtilizacao
                    ,LOWER(TRIM(Causa)) AS Causa
                    ,Corp.Cast_Decimal(LmiSegurado) AS LimiteMaximoIndenizatorioSegurado
                    ,Corp.Cast_Decimal(ValorReservaRelatorioPreliminar) AS ValorReservaRelatorioPreliminar
                    ,CASE WHEN LEFT(Moeda,3) = 'USD' THEN 1 ELSE NULL END AS Dolar
                    ,Corp.Cast_Decimal(Adiantamento) AS Adiantamento
                    ,Corp.Cast_Decimal(IndenizacaoLiquidaPagaFinal) AS IndenizacaoLiquidaPagaFinal
                    ,Corp.Cast_Decimal(DespesaRemocao) AS DespesaRemocao
                    ,NumeroBordero AS Bordero
                    ,Corp.Cast_Date(DataPagamento) AS Pagamento
                FROM Sinistro.stg
                WHERE NumeroApolice IS NOT NULL 
				AND InicioVigencia >= date_initial
                AND InicioVigencia < date_initial + INTERVAL '1 day';
	
	-- deprecate old registries filling the 'desatualizado' field and insert new registries
		MERGE INTO Sinistro.hist AS dest
			USING(
				SELECT 
					Arquivo
					,Aba
					,LinhaExcel
					,Situacao
					,Segurado
					,Cedente
					,Apolice
					,Corretor
					,Regulador
					,Ramo
					,VigenciaInicial
					,VigenciaFinal
					,Contrato
					,Aviso
					,Cobertura
					,CoberturaLimiteMaximoIndenizacao
					,PrejuizoEstimado
					,Reclamado
					,Apurado
					,FranquiaParticipacaoObrigatoriaSegurado
					,IndizacaoPendente
					,RegulacaoHonorario
					,RegulacaoDespesa
					,TotalPagoIndenizacaoDespesa
					,JustificativaAusenciaIndenizacao
					,Sinistro
					,Ocorrencia
					,AeronaveHangar
					,Piloto
					,CodigoAnac
					,Prefixo
					,AeronaveAno
					,AeronaveTipoUtilizacao
					,Causa
					,LimiteMaximoIndenizatorioSegurado
					,ValorReservaRelatorioPreliminar
					,Dolar
					,Adiantamento
					,IndenizacaoLiquidaPagaFinal
					,DespesaRemocao
					,Bordero
					,Pagamento
				FROM RawData_Claim
			) AS orig
			ON (
				orig.Apolice = dest.Apolice
				AND orig.Sinistro = dest.Sinistro
				AND orig.Ocorrencia = dest.Ocorrencia
			)
			WHEN MATCHED THEN UPDATE SET Desatualizado = NOW()
			WHEN NOT MATCHED THEN INSERT
			VALUES(
				 orig.Arquivo
				,orig.Aba
				,orig.LinhaExcel
				,orig.Situacao
				,orig.Segurado
				,orig.Cedente
				,orig.Apolice
				,orig.Corretor
				,orig.Regulador
				,orig.Ramo
				,orig.VigenciaInicial
				,orig.VigenciaFinal
				,orig.Contrato
				,orig.Aviso
				,orig.Cobertura
				,orig.CoberturaLimiteMaximoIndenizacao
				,orig.PrejuizoEstimado
				,orig.Reclamado
				,orig.Apurado
				,orig.FranquiaParticipacaoObrigatoriaSegurado
				,orig.IndizacaoPendente
				,orig.RegulacaoHonorario
				,orig.RegulacaoDespesa
				,orig.TotalPagoIndenizacaoDespesa
				,orig.JustificativaAusenciaIndenizacao
				,orig.Sinistro
				,orig.Ocorrencia
				,orig.AeronaveHangar
				,orig.Piloto
				,orig.CodigoAnac
				,orig.Prefixo
				,orig.AeronaveAno
				,orig.AeronaveTipoUtilizacao
				,orig.Causa
				,orig.LimiteMaximoIndenizatorioSegurado
				,orig.ValorReservaRelatorioPreliminar
				,orig.Dolar
				,orig.Adiantamento
				,orig.IndenizacaoLiquidaPagaFinal
				,orig.DespesaRemocao
				,orig.Bordero
				,orig.Pagamento
			);
		
		-- insert registries thar are already in database (old), but having any change on non main fields
		INSERT INTO Sinistro.hist
			SELECT 
				orig.Arquivo
				,orig.Aba
				,orig.LinhaExcel
				,orig.Situacao
				,orig.Segurado
				,orig.Cedente
				,orig.Apolice
				,orig.Corretor
				,orig.Regulador
				,orig.Ramo
				,orig.VigenciaInicial
				,orig.VigenciaFinal
				,orig.Contrato
				,orig.Aviso
				,orig.Cobertura
				,orig.CoberturaLimiteMaximoIndenizacao
				,orig.PrejuizoEstimado
				,orig.Reclamado
				,orig.Apurado
				,orig.FranquiaParticipacaoObrigatoriaSegurado
				,orig.IndizacaoPendente
				,orig.RegulacaoHonorario
				,orig.RegulacaoDespesa
				,orig.TotalPagoIndenizacaoDespesa
				,orig.JustificativaAusenciaIndenizacao
				,orig.Sinistro
				,orig.Ocorrencia
				,orig.AeronaveHangar
				,orig.Piloto
				,orig.CodigoAnac
				,orig.Prefixo
				,orig.AeronaveAno
				,orig.AeronaveTipoUtilizacao
				,orig.Causa
				,orig.LimiteMaximoIndenizatorioSegurado
				,orig.ValorReservaRelatorioPreliminar
				,orig.Dolar
				,orig.Adiantamento
				,orig.IndenizacaoLiquidaPagaFinal
				,orig.DespesaRemocao
				,orig.Bordero
				,orig.Pagamento
			FROM RawData_Claim AS orig
			WHERE 1=1
			AND EXISTS(
				SELECT 1 FROM Sinistro.hist AS dest
				WHERE 1=1
				AND( 
						orig.Apolice = dest.Apolice
					AND orig.Sinistro = dest.Sinistro
					AND orig.Ocorrencia = dest.Ocorrencia
				)
				AND NOT(
						orig.Arquivo = dest.Arquivo
					AND orig.Aba = dest.Aba
					AND orig.LinhaExcel = dest.LinhaExcel
					AND orig.Situacao = dest.Situacao
					AND orig.Segurado = dest.Segurado
					AND orig.Cedente = dest.Cedente
					AND orig.Corretor = dest.Corretor
					AND orig.Regulador = dest.Regulador
					AND orig.Ramo = dest.Ramo
					AND orig.VigenciaInicial = dest.VigenciaInicial
					AND orig.VigenciaFinal = dest.VigenciaFinal
					AND orig.Contrato = dest.Contrato
					AND orig.Aviso = dest.Aviso
					AND orig.Cobertura = dest.Cobertura
					AND orig.CoberturaLimiteMaximoIndenizacao = dest.CoberturaLimiteMaximoIndenizacao
					AND orig.PrejuizoEstimado = dest.PrejuizoEstimado
					AND orig.Reclamado = dest.Reclamado
					AND orig.Apurado = dest.Apurado
					AND orig.FranquiaParticipacaoObrigatoriaSegurado = dest.FranquiaParticipacaoObrigatoriaSegurado
					AND orig.IndizacaoPendente = dest.IndizacaoPendente
					AND orig.RegulacaoHonorario = dest.RegulacaoHonorario
					AND orig.RegulacaoDespesa = dest.RegulacaoDespesa
					AND orig.TotalPagoIndenizacaoDespesa = dest.TotalPagoIndenizacaoDespesa
					AND orig.JustificativaAusenciaIndenizacao = dest.JustificativaAusenciaIndenizacao
					AND orig.AeronaveHangar = dest.AeronaveHangar
					AND orig.Piloto = dest.Piloto
					AND orig.CodigoAnac = dest.CodigoAnac
					AND orig.Prefixo = dest.Prefixo
					AND orig.AeronaveAno = dest.AeronaveAno
					AND orig.AeronaveTipoUtilizacao = dest.AeronaveTipoUtilizacao
					AND orig.Causa = dest.Causa
					AND orig.LimiteMaximoIndenizatorioSegurado = dest.LimiteMaximoIndenizatorioSegurado
					AND orig.ValorReservaRelatorioPreliminar = dest.ValorReservaRelatorioPreliminar
					AND orig.Dolar = dest.Dolar
					AND orig.Adiantamento = dest.Adiantamento
					AND orig.IndenizacaoLiquidaPagaFinal = dest.IndenizacaoLiquidaPagaFinal
					AND orig.DespesaRemocao = dest.DespesaRemocao
					AND orig.Bordero = dest.Bordero
					AND orig.Pagamento = dest.Pagamento
				)

		);

		-- go ahed to the next day
            date_initial := date_initial + INTERVAL '1 day';
            RAISE NOTICE 'Initial Date: %',date_initial;
        END LOOP;

        -- Remove temporary table, avoiding issues with future creations or reserve unduly space in database;
        DROP TABLE IF EXISTS RawDataClaim;
    END 
$procedure$;