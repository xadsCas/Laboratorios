
-- LAB-04: Hardening de PostgreSQL
-- Actividad 1: Identificar la superficie de ataque

-- Version del servidor
SELECT version();

-- Configuracion de red y autenticacion
SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;

-- Conexiones actuales
SELECT
    pid,
    usename,
    datname,
    client_addr,
    client_port,
    application_name
FROM pg_stat_activity
ORDER BY usename, datname;

-- Actividad 2: Rutas de configuracion
SHOW data_directory;
SHOW config_file;
SHOW hba_file;

-- Actividad 3: Parametros de escucha
SELECT name, setting, source, pending_restart
FROM pg_settings
WHERE name IN ('listen_addresses', 'port');

-- Actividad 4: Reglas de pg_hba.conf
SELECT
    rule_number,
    file_name,
    line_number,
    type,
    database,
    user_name,
    address,
    auth_method,
    error
FROM pg_hba_file_rules
ORDER BY rule_number;

-- Actividad 5: Identificar reglas potencialmente permisivas
SELECT
    rule_number,
    type,
    database,
    user_name,
    address,
    auth_method,
    error
FROM pg_hba_file_rules
WHERE
    'all' = ANY(database)
    OR 'all' = ANY(user_name)
    OR address = '0.0.0.0'
    OR address = '::'
ORDER BY rule_number;
