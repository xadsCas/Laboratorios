
-- LAB-04: Actividades 8 y 9
-- Inspeccion de roles y privilegios
-- Solo lectura: no crea ni modifica usuarios.

-- Roles existentes y atributos administrativos
SELECT
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin,
    rolreplication,
    rolconnlimit,
    rolvaliduntil
FROM pg_roles
ORDER BY rolname;

-- Membresias entre roles
SELECT
    member.rolname AS miembro,
    role.rolname AS rol_concedido,
    membership.admin_option
FROM pg_auth_members AS membership
JOIN pg_roles AS role
    ON role.oid = membership.roleid
JOIN pg_roles AS member
    ON member.oid = membership.member
ORDER BY member.rolname, role.rolname;

-- Privilegios de las bases de datos
SELECT
    datname,
    datacl
FROM pg_database
ORDER BY datname;
