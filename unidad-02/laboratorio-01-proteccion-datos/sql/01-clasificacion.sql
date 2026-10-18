-- Laboratorio 01: Clasificación de datos
-- Objetivo: identificar los datos personales almacenados en PostgreSQL.
-- Ejecutar en una base de datos de pruebas.

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150),
    telefono VARCHAR(20),
    rfc VARCHAR(13),
    edad INTEGER,
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_alta DATE DEFAULT CURRENT_DATE
);

-- Datos ficticios para realizar las pruebas.
INSERT INTO clientes
    (nombre, correo, telefono, rfc, edad, ciudad, codigo_postal, fecha_alta)
VALUES
    ('Ana López', 'ana@example.com', '6671234567', 'LOPA900101ABC', 35, 'Culiacán', '80000', CURRENT_DATE),
    ('Carlos Pérez', 'carlos@example.com', '6672345678', 'PECA850202DEF', 41, 'Culiacán', '80010', CURRENT_DATE),
    ('María García', 'maria@example.com', '6673456789', 'GAMA950303GHI', 27, 'Mazatlán', '82000', CURRENT_DATE),
    ('José Ramírez', 'jose@example.com', '6674567890', 'RAJO800404JKL', 46, 'Culiacán', '80020', CURRENT_DATE),
    ('Laura Torres', 'laura@example.com', '6675678901', 'TOLA990505MNO', 30, 'Mazatlán', '82010', CURRENT_DATE);

-- Consultar los registros para revisar los campos almacenados.
SELECT *
FROM clientes
ORDER BY id;

-- Clasificación de los campos:
-- nombre: dato personal identificativo.
-- correo: dato personal de contacto.
-- telefono: dato personal de contacto.
-- rfc: identificador fiscal personal.
-- edad: dato personal que puede funcionar como cuasi-identificador.
-- ciudad: dato de ubicación que puede funcionar como cuasi-identificador.
-- codigo_postal: dato de ubicación que puede funcionar como cuasi-identificador.
-- fecha_alta: dato administrativo que puede revelar información sobre la relación con el sistema.
-- id: identificador interno del registro.
