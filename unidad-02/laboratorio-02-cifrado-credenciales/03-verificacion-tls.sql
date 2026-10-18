
-- Laboratorio 02: verificacion de TLS en PostgreSQL

-- 1. Comprobar si SSL/TLS esta habilitado en el servidor.
SHOW ssl;

-- 2. Consultar la version minima de SSL/TLS configurada.
SHOW ssl_min_protocol_version;

-- 3. Consultar el puerto de PostgreSQL.
SHOW port;

-- 4. Consultar las direcciones donde escucha PostgreSQL.
SHOW listen_addresses;

-- 5. Consultar la direccion y el puerto del cliente actual.
SELECT
    inet_client_addr() AS direccion_cliente,
    inet_client_port() AS puerto_cliente;

-- 6. Comprobar si la sesion actual utiliza SSL/TLS.
SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();
