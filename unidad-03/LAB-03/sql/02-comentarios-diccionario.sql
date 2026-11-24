-- LAB-03 · Actividad 3 — Diccionario de datos operativo (COMMENT)
-- Ejecutar como administrador en la base comercial.
-- Las sentencias de la sección A ya se ejecutaron el 2026-11-23 23:38:21 (E5 líneas 42-47).
-- La sección B está PENDIENTE de ejecutar: hoy telefono, ciudad, codigo_postal, fecha_alta y
-- segmento salen sin descripción en el diccionario (ver evidencias/diccionario-clientes.csv).

-- A. Ya ejecutadas ------------------------------------------------------------
COMMENT ON TABLE clientes IS 'Clientes de Comercializadora Norte. Propietario: Gerencia Comercial. Custodio: DBA. Clasificación: confidencial (contiene datos personales).';
COMMENT ON COLUMN clientes.id     IS 'Identificador interno del cliente. Generado por el sistema.';
COMMENT ON COLUMN clientes.nombre IS 'Nombre completo. Dato personal identificador directo.';
COMMENT ON COLUMN clientes.correo IS 'Correo de contacto. Dato personal. Uso: notificaciones al cliente.';
COMMENT ON COLUMN clientes.rfc    IS 'RFC del cliente. Dato personal. Uso: facturación. Cambios auditados en auditoria.cambios_clientes.';
COMMENT ON COLUMN clientes.edad   IS 'Edad en años cumplidos. Dato personal. Uso: analítica agregada.';

-- B. PENDIENTES ---------------------------------------------------------------
COMMENT ON COLUMN clientes.telefono      IS 'Teléfono de contacto (10 dígitos). Dato personal. Uso: contacto operativo y soporte.';
COMMENT ON COLUMN clientes.ciudad        IS 'Ciudad de residencia o entrega. Dato personal de ubicación (nivel general). Uso: logística y analítica agregada.';
COMMENT ON COLUMN clientes.codigo_postal IS 'Código postal (5 dígitos). Dato personal de ubicación. Uso: logística y analítica agregada.';
COMMENT ON COLUMN clientes.fecha_alta    IS 'Fecha de alta del cliente. Valor por defecto: CURRENT_DATE. No es dato personal sensible; es dato de la relación comercial.';
COMMENT ON COLUMN clientes.segmento      IS 'Segmento comercial asignado (agregado en LAB-01). Dato derivado de clasificación interna. Uso: analítica y campañas.';
-- canal_alta ya tiene COMMENT (23:42:01, E5 línea 69): 'Canal por el que se registró el cliente. Cambio CAM-2026-014.'

-- C. Comentarios de los demás objetos del expediente (recomendado, para que el catálogo los muestre)
COMMENT ON TABLE auditoria.cambios_clientes IS 'Auditoría de cambios sobre clientes (disparador trg_auditoria_clientes). Contiene datos personales en valores_antes/valores_despues. Propietario: Auditoría interna. Custodio: DBA. Clasificación: confidencial.';
COMMENT ON VIEW  dba.bitacora IS 'Lectura de la bitácora actual de PostgreSQL (pg_read_file). Puede contener datos personales y secretos. Propietario: Responsable de seguridad. Custodio: DBA. Clasificación: confidencial.';

-- D. Verificación: columnas sin descripción (debe devolver 0 filas al terminar)
SELECT c.column_name
FROM information_schema.columns c
WHERE c.table_schema = 'public' AND c.table_name = 'clientes'
  AND col_description('public.clientes'::regclass, c.ordinal_position) IS NULL;

-- E. Consulta del diccionario (misma de la guía)
SELECT c.ordinal_position          AS pos,
       c.column_name               AS columna,
       c.data_type                 AS tipo,
       c.character_maximum_length  AS longitud,
       c.is_nullable               AS acepta_nulos,
       c.column_default            AS valor_por_defecto,
       col_description('public.clientes'::regclass, c.ordinal_position) AS descripcion
FROM information_schema.columns c
WHERE c.table_schema = 'public' AND c.table_name = 'clientes'
ORDER BY c.ordinal_position;

-- F. Re-exportar el CSV (terminal, desde LAB-03/) cuando la sección B ya esté ejecutada:
-- psql -U postgres -d comercial --csv -c "SELECT c.column_name AS columna, c.data_type AS tipo, c.character_maximum_length AS longitud, c.is_nullable AS acepta_nulos, col_description('public.clientes'::regclass, c.ordinal_position) AS descripcion FROM information_schema.columns c WHERE c.table_schema = 'public' AND c.table_name = 'clientes' ORDER BY c.ordinal_position" > evidencias/diccionario-clientes.csv
