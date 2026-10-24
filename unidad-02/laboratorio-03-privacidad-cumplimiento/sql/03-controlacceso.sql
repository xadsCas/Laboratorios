-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad: control de acceso por finalidad.

-- Crear el rol solamente si no existe.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'analista'
    ) THEN
        CREATE ROLE analista NOLOGIN;
    END IF;
END
$$;

-- Crear una vista con información limitada.
CREATE OR REPLACE VIEW v_analitica_clientes AS
SELECT
    ciudad,
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad
FROM clientes;

-- Permitir el acceso al esquema y a la vista.
GRANT USAGE ON SCHEMA public TO analista;

GRANT SELECT
ON v_analitica_clientes
TO analista;

-- Comprobar los permisos otorgados.
SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista';

-- Comprobar que el rol no tiene acceso directo
-- a la tabla original mediante permisos concedidos.
SELECT has_table_privilege(
    'analista',
    'public.clientes',
    'SELECT'
) AS acceso_directo_clientes;

-- Comprobar el acceso a la vista.
SELECT has_table_privilege(
    'analista',
    'public.v_analitica_clientes',
    'SELECT'
) AS acceso_vista_analitica;