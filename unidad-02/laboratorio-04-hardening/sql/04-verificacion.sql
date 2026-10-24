
-- LAB-04: Verificacion final
-- Ejecutar despues de los cambios autorizados.
-- Si no se aplicaron cambios, registrar el estado final observado.

-- Version y configuracion de red
SELECT version();
SHOW port;
SHOW listen_addresses;

-- Autenticacion y cifrado
SHOW password_encryption;
SHOW ssl;
SHOW ssl_min_protocol_version;

-- Estado TLS de la sesion actual
SELECT
    pid,
    usename,
    client_addr,
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();

-- Revisar errores en las reglas de autenticacion
SELECT *
FROM pg_hba_file_rules
WHERE error IS NOT NULL
ORDER BY rule_number;

-- Revisar roles administrativos
SELECT
    rolname,
    rolsuper,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolsuper = TRUE
ORDER BY rolname;

-- Revisar extensiones instaladas
SELECT extname, extversion
FROM pg_extension
ORDER BY extname;

-- Revisar conexiones actuales
SELECT
    pid,
    usename,
    datname,
    client_addr,
    application_name
FROM pg_stat_activity
ORDER BY usename, datname;
