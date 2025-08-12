-- MARK: Dimension
CREATE SCHEMA Corp;
DROP TABLE IF EXISTS Corp.dimAeronave;
CREATE TABLE Corp.dimAeronave(
     Id 				SERIAL
	,Prefixo 			VARCHAR(50)	NULL
	,CodAnac 			INT	NULL
	,Fabricante 		VARCHAR(255) NULL
	,AnoFabricacao 		SMALLINT NULL
	,Modelo 			VARCHAR(50) NULL
	--,IdAirshipUsage		INT NULL
	,TipoUtilizacao 	VARCHAR(255) NULL
	,Piloto 			VARCHAR(255) NULL
	,RegistroEncerrado 	Date NULL
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimArquivo;
CREATE TABLE Corp.dimArquivo(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimAba;
CREATE TABLE Corp.dimAba(
    Id Serial
    ,Nome char(31) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimFuncionario;
CREATE TABLE Corp.dimFuncionario(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCargo;
CREATE TABLE Corp.dimCargo(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);

TRUNCATE TABLE Corp.dimCargo;
INSERT INTO  Corp.dimCargo (Nome) VALUES
('Presidente')
,('Vice Presidente')
,('Superintendente')
,('Gerente')
,('Coordenador')
,('Analista Senior')
,('Analista')
,('Analista Juinor')
,('Assistente')
,('Estagiário');


DROP TABLE IF EXISTS Corp.dimCorretor;
CREATE TABLE Corp.dimCorretor(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCobertura;
CREATE TABLE Corp.dimCobertura(
    Id Serial
    ,Nome varchar(255) NOT NULL
    ,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCotacaoSituacao;
CREATE TABLE Corp.dimCotacaoSituacao(
    Id Serial
    ,Nome varchar(100) NOT NULL
    ,PRIMARY KEY (Id)
);


DROP TABLE IF EXISTS Corp.dimEmissaoSituacao;
CREATE TABLE Corp.dimEmissaoSituacao(
	Id Serial
	,Nome VARCHAR(110)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimsSegurado;
CREATE TABLE Corp.dimsSegurado(
	Id Serial
	,Nome VARCHAR(255)
	,Documento smallint 
	,CNPJ VARCHAR(30)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimCedente;
CREATE TABLE Corp.dimCedente(
	Id Serial
	,Nome VARCHAR(100)
	,PRIMARY KEY (Id)
);

DROP TABLE IF EXISTS Corp.dimRegulador;
CREATE TABLE Corp.dimRegulador(
	Id Serial
	,Nome VARCHAR(255)
	,PRIMARY KEY (Id)
);


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