CREATE OR REPLACE FUNCTION normalizacionTabla() RETURNS VOID AS $$
	
BEGIN
	-- Validar si la tabla moneda existe
	IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'Moneda') THEN
		--Eliminar la tabla moneda si existe
		DROP TABLE Moneda;
	END IF;
	--Crear la tabla Moneda
	CREATE TABLE IF NOT EXISTS moneda (
		id SERIAL PRIMARY KEY,
		Moneda VARCHAR(100),
		Sigla VARCHAR(5),
		Imagen BYTEA
	);
	--Validar si la columna idMoneda existe en la tabla país
	IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'Pais' AND column_name = 'idMoneda') THEN
		--Eliminar columna idMoneda de la tabla País si existe
		ALTER TABLE Pais DROP COLUMN idMoneda;
	END IF;
	--Agregar columna de idMoneda a la tabla Pais
	ALTER TABLE Pais
		ADD COLUMN IF NOT EXISTS idMoneda INTEGER;
	--Crear columnas de mapa y bandera en la tabla Pais
	ALTER TABLE Pais
		ADD COLUMN IF NOT EXISTS Mapa BYTEA,
		ADD COLUMN IF NOT EXISTS Bandera BYTEA;
	--Tranferir información de moneda de la tabla pais a la tabla moneda
	INSERT INTO Moneda (Moneda, Sigla, Imagen)
	SELECT DISTINCT Moneda, NULLIF('Sigla', ''), 
			CASE WHEN 'Imagen' IS NOT NULL THEN 'Imagen'::BYTEA ELSE NULL END
		FROM Pais
		WHERE Moneda IS NOT NULL;
	--Actualizar la columna idMoneda en la tabla pais
	UPDATE Pais P
		SET idMoneda = M.id
		FROM Moneda M
		WHERE P.Moneda = M.Moneda;
	--Eliminar la columna moneda de la tabla Pais
	ALTER TABLE pais
		DROP COLUMN IF EXISTS Moneda;	
END
$$ LANGUAGE plpgsql;