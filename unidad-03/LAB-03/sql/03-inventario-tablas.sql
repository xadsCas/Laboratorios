-- LAB-03 · Actividad 4 — Inventario técnico de tablas y vistas (insumo del catálogo)

-- IMPORTANTE: en la sesión original, ANALYZE se pegó junto con el comando de terminal y falló
-- (E5 línea 48, "syntax error at or near psql"), por eso filas_estimadas salió en -1
-- (captura 04-inventario-tablas.png). Ejecutar ANALYZE solo, antes de la consulta:
ANALYZE;

-- Tablas (relkind = 'r')
SELECT n.nspname                                     AS esquema,
       c.relname                                     AS tabla,
       pg_get_userbyid(c.relowner)                   AS propietario_tecnico,
       c.reltuples::bigint                           AS filas_estimadas,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano,
       obj_description(c.oid, 'pg_class')            AS descripcion
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;

-- Vistas (la consulta anterior no las muestra; dba.bitacora también es un activo a inventariar)
SELECT n.nspname                        AS esquema,
       c.relname                        AS vista,
       pg_get_userbyid(c.relowner)      AS propietario_tecnico,
       obj_description(c.oid, 'pg_class') AS descripcion
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'v'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;
