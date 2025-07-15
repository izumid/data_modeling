-- MARK: FAct
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