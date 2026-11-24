-- LAB-03 · Actividad 7 — Registro de cambios y conciliación
-- Ejecutado el 2026-11-23 entre 23:41:18 y 23:42:01 (E5 líneas 51-69).

CREATE SCHEMA gobierno;
REVOKE ALL ON SCHEMA gobierno FROM PUBLIC;

CREATE TABLE gobierno.solicitudes_cambio (
    folio            TEXT PRIMARY KEY,
    descripcion      TEXT NOT NULL,
    solicitado_por   TEXT NOT NULL,
    aprobado_por     TEXT,
    ambiente         TEXT NOT NULL CHECK (ambiente IN ('desarrollo', 'pruebas', 'produccion')),
    fecha_aprobacion TIMESTAMPTZ,
    ventana_inicio   TIMESTAMPTZ,
    ventana_fin      TIMESTAMPTZ
);

COMMENT ON TABLE gobierno.solicitudes_cambio IS 'Registro de solicitudes de cambio en la base comercial. Propietario: Comité de cambios. Custodio: DBA. Evidencia de POL-06.';

INSERT INTO gobierno.solicitudes_cambio VALUES
('CAM-2026-014', 'Agregar columna canal_alta a clientes', 'Gerencia Comercial',
 'Comité de cambios', 'produccion', now() - interval '1 day',
 now() - interval '5 minutes', now() + interval '1 hour');

ALTER TABLE clientes ADD COLUMN canal_alta VARCHAR(20);
COMMENT ON COLUMN clientes.canal_alta IS 'Canal por el que se registró el cliente. Cambio CAM-2026-014.';

-- Verificación de ventana
SELECT folio, aprobado_por,
       ventana_inicio <= now() AND now() <= ventana_fin AS dentro_de_ventana
FROM gobierno.solicitudes_cambio;

-- Extracción de cambios de estructura y privilegios desde la bitácora
SELECT num,
       substr(linea, 1, 23)                    AS momento,
       substring(linea from 'user=([^ ]*)')     AS usuario,
       substring(linea from 'statement: (.*)$') AS sentencia
FROM dba.bitacora
WHERE linea ~ 'statement: (CREATE|ALTER|DROP|GRANT|REVOKE)'
ORDER BY num;

-- ---------------------------------------------------------------------------
-- Consultas de apoyo para la conciliación (SOLO LECTURA)
-- ---------------------------------------------------------------------------

-- Solicitudes registradas y cuándo se escribió el registro de autorización
-- (se compara con E5 línea 64: el INSERT del folio ocurre 18 ms antes del ALTER, línea 68).
SELECT folio, solicitado_por, aprobado_por, ambiente,
       fecha_aprobacion, ventana_inicio, ventana_fin
FROM gobierno.solicitudes_cambio;

-- Confirmar el cliente del incidente del RFC (evento id_evento = 1 de auditoria.cambios_clientes)
-- Ajusta los nombres de columna si tu tabla difiere (ver E4).
SELECT id_evento, momento, usuario_sesion, aplicacion, operacion, id_cliente
FROM auditoria.cambios_clientes
WHERE id_evento = 1;
SELECT id, nombre FROM clientes WHERE id = 3;
