CREATE SCHEMA Aeronautico;
DROP TABLE IF EXISTS Aeronautico.stgCotacao;
CREATE TABLE Aeronautico.stgCotacao(
	LinhaExcel INT NOT NULL
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

DROP TABLE IF EXISTS Aeronautico.stgEmissao;
CREATE TABLE Aeronautico.stgEmissao(
	LinhaExcel INT NOT NULL
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

CREATE SCHEMA Sinistro;
DROP TABLE IF EXISTS Sinistro.stg;
CREATE TABLE Sinistro.stg(
	LinhaExcel INT NOT NULL
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
  
);
