CREATE OR REPLACE FUNCTION normalizacionTabla() RETURNS VOID AS $$
	
BEGIN
	-- Validar si la tabla moneda existe
	IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'Moneda') THEN
		--Eliminar la tabla moneda si existe
		DROP TABLE Moneda;
	END IF;
	IF EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'Moneda' ) THEN
		--Crear la tabla Moneda
		CREATE TABLE IF NOT EXISTS moneda (
			id SERIAL PRIMARY KEY,
			Moneda VARCHAR(100),
			Sigla VARCHAR(5),
			Imagen BYTEA
		);
	END IF;
	--Validar si la columna idMoneda existe en la tabla país
	IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'Pais' AND column_name = 'idMoneda') THEN
		--Agregar columna de idMoneda a la tabla Pais
		ALTER TABLE Pais
			ADD COLUMN IF NOT EXISTS idMoneda INTEGER;
	END IF;
	--Validar si en a 
	IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'Pais' AND column_name = 'Mapa' AND column_name = 'Bandera') THEN
		--Crear columnas de mapa y bandera en la tabla Pais
		ALTER TABLE Pais
			ADD COLUMN IF NOT EXISTS Mapa BYTEA,
			ADD COLUMN IF NOT EXISTS Bandera BYTEA;
	END IF;
	--Validar si la tabla Moneda esta vacía
	IF (SELECT COUNT(*) FROM Moneda) = 0 THEN
		--Tranferir información de moneda de la tabla pais a la tabla moneda
		INSERT INTO Moneda (Moneda, Sigla, Imagen)
		SELECT DISTINCT Moneda, NULLIF('Sigla', ''), 
				CASE WHEN 'Imagen' IS NOT NULL THEN 'Imagen'::BYTEA ELSE NULL END
			FROM Pais
			WHERE Moneda IS NOT NULL;
	END IF;
	--Validar si la columna idMoneda esta vacía en la tabla País
	IF (SELECT COUNT(*) FROM Pais WHERE idMoneda IS NULL) > 0 THEN
		--Actualizar la columna idMoneda en la tabla pais
		UPDATE Pais P
			SET idMoneda = M.id
			FROM Moneda M
			WHERE P.Moneda = M.Moneda;
	END IF;
	--Eliminar la columna moneda de la tabla Pais
	ALTER TABLE pais
		DROP COLUMN IF EXISTS Moneda;	
END
$$ LANGUAGE plpgsql;