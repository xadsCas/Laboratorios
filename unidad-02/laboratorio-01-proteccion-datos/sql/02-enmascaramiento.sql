-- Laboratorio 01: Enmascaramiento de datos
-- Objetivo: mostrar datos parcialmente ocultos al rol de soporte.
-- Requiere que exista la tabla public.clientes.

-- Crear un rol sin inicio de sesión directo.
CREATE ROLE soporte NOLOGIN;

-- Crear una vista con datos enmascarados.
CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    LEFT(nombre, 1) || '***' AS nombre_enmascarado,
    CASE
        WHEN correo IS NOT NULL AND POSITION('@' IN correo) > 1
        THEN LEFT(correo, 1) || '***' || SUBSTRING(correo FROM POSITION('@' IN correo))
        ELSE '***'
    END AS correo_enmascarado,
    CASE
        WHEN telefono IS NOT NULL
        THEN '******' || RIGHT(telefono, 4)
        ELSE NULL
    END AS telefono_enmascarado,
    CASE
        WHEN rfc IS NOT NULL
        THEN LEFT(rfc, 3) || '**********'
        ELSE NULL
    END AS rfc_enmascarado
FROM public.clientes;

-- Permitir que el rol use el esquema y consulte la vista.
GRANT USAGE ON SCHEMA public TO soporte;
GRANT SELECT ON v_clientes_soporte TO soporte;

-- Evitar que el rol consulte directamente la tabla original.
REVOKE ALL PRIVILEGES ON TABLE public.clientes FROM soporte;

-- Consultar la vista como administrador para revisar su contenido.
SELECT *
FROM v_clientes_soporte
ORDER BY id;

-- Verificación de permisos:
-- Ejecutar estas instrucciones por separado.
-- La consulta a la vista debe funcionar.
-- La consulta directa a clientes debe producir un error de permisos.

-- SET ROLE soporte;
-- SELECT * FROM public.v_clientes_soporte;
-- SELECT * FROM public.clientes;
-- RESET ROLE;
