
SELECT lower(correo) AS correo_normalizado,
       count(*)      AS registros,
       string_agg(id::text, ', ') AS ids
FROM clientes
GROUP BY lower(correo)
HAVING count(*) > 1;

-- 2. RFC con formato no válido o ausente (regla: formato RFC; solo formato, no valida contra el SAT)
SELECT id, nombre, rfc, length(rfc) AS longitud
FROM clientes
WHERE rfc IS NULL
   OR rfc !~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$';

-- 3. Correo con formato no válido
SELECT id, nombre, correo
FROM clientes
WHERE correo !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';

-- 4. Edad fuera de rango (18–120)
SELECT id, nombre, edad
FROM clientes
WHERE edad IS NOT NULL AND (edad < 18 OR edad > 120);

-- 5. Completitud
SELECT count(*) AS total,
       count(*) FILTER (WHERE telefono IS NULL) AS sin_telefono,
       count(*) FILTER (WHERE rfc IS NULL)      AS sin_rfc
FROM clientes;

-- ---------------------------------------------------------------------------
-- Verificaciones adicionales (no pedidas por la guía; detectadas al revisar los datos insertados)
-- ---------------------------------------------------------------------------

-- 6. Teléfono con longitud distinta de 10 dígitos
SELECT id, nombre, telefono
FROM clientes
WHERE telefono IS NOT NULL AND telefono !~ '^[0-9]{10}$';

-- 7. Código postal con longitud distinta de 5 dígitos
SELECT id, nombre, codigo_postal
FROM clientes
WHERE codigo_postal IS NOT NULL AND codigo_postal !~ '^[0-9]{5}$';

-- 8. Variantes de escritura en ciudad (consistencia)
SELECT ciudad, count(*) AS registros
FROM clientes
GROUP BY ciudad
ORDER BY ciudad;

-- ---------------------------------------------------------------------------
-- Restricciones que PREVENDRÍAN los hallazgos (PROPUESTAS; NO ejecutar sin aprobación
-- del propietario del dato, Gerencia Comercial, y sin folio de cambio — ver POL-06).
-- Dejarlas comentadas: ejecutarlas "corregiría" los hallazgos y los haría desaparecer del expediente.
-- ---------------------------------------------------------------------------
-- CREATE UNIQUE INDEX ux_clientes_correo_lower ON clientes (lower(correo));
-- ALTER TABLE clientes ADD CONSTRAINT ck_clientes_rfc    CHECK (rfc    IS NULL OR rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$') NOT VALID;
-- ALTER TABLE clientes ADD CONSTRAINT ck_clientes_correo CHECK (correo ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$') NOT VALID;
-- ALTER TABLE clientes ADD CONSTRAINT ck_clientes_edad   CHECK (edad   IS NULL OR edad BETWEEN 18 AND 120) NOT VALID;
-- (NOT VALID: se aplica a datos nuevos sin rechazar de golpe los registros existentes ya observados.)
