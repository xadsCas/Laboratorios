
-- LAB-04: Inspeccion de configuracion segura
-- Consultas de solo lectura

-- Actividad 7: autenticacion y almacenamiento de contrasenas
SHOW password_encryption;

-- Actividad 10: extensiones instaladas
SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;

-- Actividad 11: limites y tiempos de conexion
SHOW max_connections;
SHOW superuser_reserved_connections;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;

-- Actividad 12: rutas de archivos sensibles
SHOW data_directory;
SHOW config_file;
SHOW hba_file;

-- Actividad 15: configuracion TLS
SHOW ssl;
SHOW ssl_min_protocol_version;

-- Verificar la conexion actual
SELECT
    pid,
    usename,
    client_addr,
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

-- Revisar parametros relevantes de seguridad
SELECT
    name,
    setting,
    unit,
    source,
    pending_restart
FROM pg_settings
WHERE name IN (
    'listen_addresses',
    'port',
    'ssl',
    'password_encryption',
    'max_connections',
    'superuser_reserved_connections',
    'statement_timeout',
    'idle_in_transaction_session_timeout',
    'ssl_min_protocol_version'
)
ORDER BY name;
