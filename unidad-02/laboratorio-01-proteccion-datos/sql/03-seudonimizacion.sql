-- Laboratorio 01: Seudonimización de datos
-- Objetivo: sustituir el identificador del cliente por un token.
-- Requiere que exista la tabla public.clientes.

-- Crear los esquemas para separar la información.
CREATE SCHEMA pii;
CREATE SCHEMA analitica;

-- Generar UUID para los tokens.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tabla de correspondencia entre tokens y clientes.
-- Debe tener acceso restringido.
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id INTEGER NOT NULL UNIQUE
        REFERENCES public.clientes(id)
);

-- Generar un token por cada cliente que aún no tenga uno.
INSERT INTO pii.mapa_cliente (cliente_id)
SELECT c.id
FROM public.clientes AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM pii.mapa_cliente AS m
    WHERE m.cliente_id = c.id
);

-- Tabla de análisis: no contiene nombre, correo, teléfono ni RFC.
CREATE TABLE analitica.clientes (
    token UUID PRIMARY KEY,
    edad INTEGER,
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_alta DATE
);

-- Asociar cada token con los atributos necesarios para el análisis.
INSERT INTO analitica.clientes
    (token, edad, ciudad, codigo_postal, fecha_alta)
SELECT
    m.token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente AS m
JOIN public.clientes AS c
    ON c.id = m.cliente_id
WHERE NOT EXISTS (
    SELECT 1
    FROM analitica.clientes AS a
    WHERE a.token = m.token
);

-- Crear el rol que consultará únicamente los datos analíticos.
CREATE ROLE analista NOLOGIN;

GRANT USAGE ON SCHEMA analitica TO analista;
GRANT SELECT ON TABLE analitica.clientes TO analista;

-- Retirar permisos de consulta sobre las tablas que no debe consultar.
REVOKE ALL PRIVILEGES ON SCHEMA pii FROM analista;
REVOKE ALL PRIVILEGES ON TABLE pii.mapa_cliente FROM analista;
REVOKE ALL PRIVILEGES ON TABLE public.clientes FROM analista;

-- Revisar los datos analíticos como administrador.
SELECT *
FROM analitica.clientes
ORDER BY token;

-- Verificación de permisos:
-- Ejecutar las instrucciones por separado.
-- La tabla analítica debe poder consultarse.
-- Las tablas del mapa y de clientes originales deben estar restringidas.

-- SET ROLE analista;
-- SELECT * FROM analitica.clientes;
-- SELECT * FROM pii.mapa_cliente;
-- SELECT * FROM public.clientes;
-- RESET ROLE;
