-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad: minimización de datos
-- Objetivo: limitar los datos disponibles para soporte.

CREATE TABLE IF NOT EXISTS clientes_soporte (
    id BIGINT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

INSERT INTO clientes_soporte (id, nombre, correo, telefono)
SELECT id, nombre, correo, telefono
FROM clientes
ON CONFLICT (id) DO NOTHING;

-- Verificar la estructura de la tabla de soporte.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'clientes_soporte'
ORDER BY ordinal_position;

-- Verificar los registros disponibles para soporte.
SELECT *
FROM clientes_soporte
ORDER BY id;