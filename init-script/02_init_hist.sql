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
	,CodBordero VARCHAR(25) NULL
	,Pagamento DATE NULL
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
	,Apolice VARCHAR(255)
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
	,Apolice VARCHAR(255)
	,Desatualizado DATE
);
