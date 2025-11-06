USE vehiculos_db;

-- Desactivar chequeo de claves foráneas para truncar
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Vehiculo; -- Truncar hija primero
TRUNCATE TABLE SeguroVehicular; -- Truncar padre después
SET FOREIGN_KEY_CHECKS = 1;

-- --- Tablas Temporales Auxiliares ---

-- Para generar N registros base
DROP TABLE IF EXISTS temp_multiplicador;
CREATE TEMPORARY TABLE temp_multiplicador (id INT);
INSERT INTO temp_multiplicador
WITH RECURSIVE nums AS (
     SELECT 1 AS id
     UNION ALL
     SELECT id + 1 FROM nums WHERE id < 1000 -- Generará 1000 seguros base
)
SELECT id FROM nums;

-- Datos ficticios para Seguros
DROP TEMPORARY TABLE IF EXISTS temp_aseguradoras;
CREATE TEMPORARY TABLE temp_aseguradoras (nombre VARCHAR(80));
INSERT INTO temp_aseguradoras VALUES
('La Caja'), ('Sancor Seguros'), ('Rivadavia'), ('Allianz'), ('Zurich'), ('Mercantil Andina');

DROP TEMPORARY TABLE IF EXISTS temp_coberturas;
CREATE TEMPORARY TABLE temp_coberturas (cobertura ENUM('RC', 'TERCEROS', 'TODO_RIESGO'));
INSERT INTO temp_coberturas VALUES
('RC'), ('TERCEROS'), ('TODO_RIESGO');

-- Datos ficticios para Vehículos
DROP TEMPORARY TABLE IF EXISTS temp_marcas;
CREATE TEMPORARY TABLE temp_marcas (marca VARCHAR(50));
INSERT INTO temp_marcas VALUES
('Ford'), ('Volkswagen'), ('Chevrolet'), ('Renault'), ('Peugeot'), ('Toyota'), ('Fiat');

DROP TEMPORARY TABLE IF EXISTS temp_modelos;
CREATE TEMPORARY TABLE temp_modelos (modelo VARCHAR(50));
INSERT INTO temp_modelos VALUES
('Focus'), ('Gol'), ('Onix'), ('Clio'), ('208'), ('Corolla'), ('Cronos'), ('Ranger'), ('Amarok');


-- --- 1. Inserción en SeguroVehicular (Padre) ---
-- (Esta parte estaba bien, se mantiene igual)
INSERT INTO SeguroVehicular (aseguradora, nroPoliza, cobertura, vencimiento)
SELECT
    (SELECT nombre FROM temp_aseguradoras ORDER BY RAND() LIMIT 1) AS aseguradora,
    CONCAT('POL-', LPAD(t.id, 8, '0')) AS nroPoliza,
    (SELECT cobertura FROM temp_coberturas ORDER BY RAND() LIMIT 1) AS cobertura,
    DATE_ADD('2024-01-01',
        INTERVAL FLOOR(RAND() * (DATEDIFF('2030-12-31', '2024-01-01'))) DAY
    ) AS vencimiento
FROM
    temp_multiplicador t;


-- --- 2. Inserción en Vehiculo (Hijo) ---

-- *** INICIO DE LA CORRECCIÓN ***

-- Tablas para generar dominio (patente)
DROP TABLE IF EXISTS temp_letras;
CREATE TEMPORARY TABLE temp_letras (letra CHAR(1));
INSERT INTO temp_letras VALUES
('A'),('B'),('C'),('D'),('E'),('F'),('G'),('H'),('I'),('J'),
('K'),('L'),('M'),('N'),('O'),('P'),('Q'),('R'),('S'),('T'),
('U'),('V'),('W'),('X'),('Y'),('Z');

DROP TABLE IF EXISTS temp_digitos;
CREATE TEMPORARY TABLE temp_digitos (digito CHAR(1));
INSERT INTO temp_digitos VALUES
('0'),('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9');

-- Crear copias físicas para evitar el error 1105
DROP TABLE IF EXISTS temp_letras2, temp_letras3, temp_letras4;
CREATE TEMPORARY TABLE temp_letras2 AS SELECT * FROM temp_letras;
CREATE TEMPORARY TABLE temp_letras3 AS SELECT * FROM temp_letras;
CREATE TEMPORARY TABLE temp_letras4 AS SELECT * FROM temp_letras;

DROP TABLE IF EXISTS temp_digitos2, temp_digitos3;
CREATE TEMPORARY TABLE temp_digitos2 AS SELECT * FROM temp_digitos;
CREATE TEMPORARY TABLE temp_digitos3 AS SELECT * FROM temp_digitos;

-- *** FIN DE LA CORRECCIÓN ***

-- Insertar 10,000 vehículos
INSERT INTO Vehiculo (dominio, marca, modelo, anio, nroChasis, seguro_id)
SELECT
    -- Dominio (Patente) con formato aleatorio (ej: AB123CD)
    CONCAT(
        l1.letra, l2.letra,
        d1.digito, d2.digito, d3.digito,
        l3.letra, l4.letra
    ) AS dominio,
    
    (SELECT marca FROM temp_marcas ORDER BY RAND() LIMIT 1) AS marca,
    (SELECT modelo FROM temp_modelos ORDER BY RAND() LIMIT 1) AS modelo,
    (FLOOR(RAND() * (2025 - 2005 + 1)) + 2005) AS anio,
    CONCAT('CHAS-', LPAD(@rownum := @rownum + 1, 8, '0')) AS nroChasis,
    
    IF(RAND() < 0.8,
        (SELECT id FROM SeguroVehicular ORDER BY RAND() LIMIT 1),
        NULL
    ) AS seguro_id
FROM
    -- Usamos las tablas copiadas
    temp_letras l1
    CROSS JOIN temp_letras2 l2
    CROSS JOIN temp_digitos d1
    CROSS JOIN temp_digitos2 d2
    CROSS JOIN temp_digitos3 d3
    CROSS JOIN temp_letras3 l3
    CROSS JOIN temp_letras4 l4
    CROSS JOIN (SELECT @rownum := 0) r -- Inicializa el contador para nroChasis
LIMIT 10000; -- Limita la cantidad de vehículos


-- --- Limpieza de Tablas Temporales ---
DROP TEMPORARY TABLE IF EXISTS temp_multiplicador;
DROP TEMPORARY TABLE IF EXISTS temp_aseguradoras;
DROP TEMPORARY TABLE IF EXISTS temp_coberturas;
DROP TEMPORARY TABLE IF EXISTS temp_marcas;
DROP TEMPORARY TABLE IF EXISTS temp_modelos;
-- Limpiar la tabla base Y todas las copias
DROP TEMPORARY TABLE IF EXISTS temp_letras;
DROP TEMPORARY TABLE IF EXISTS temp_letras2;
DROP TEMPORARY TABLE IF EXISTS temp_letras3;
DROP TEMPORARY TABLE IF EXISTS temp_letras4;
DROP TEMPORARY TABLE IF EXISTS temp_digitos;
DROP TEMPORARY TABLE IF EXISTS temp_digitos2;
DROP TEMPORARY TABLE IF EXISTS temp_digitos3;