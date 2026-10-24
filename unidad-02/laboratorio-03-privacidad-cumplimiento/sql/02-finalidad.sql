-- LAB-03: Privacidad, cumplimiento y gobierno de los datos
-- Actividad: uso de datos según su finalidad.

-- Estadísticas de clientes por ciudad.
SELECT
    ciudad,
    COUNT(*) AS cantidad_clientes
FROM clientes
GROUP BY ciudad
ORDER BY cantidad_clientes DESC;

-- Estadísticas de clientes por rango de edad.
SELECT
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad,
    COUNT(*) AS cantidad_clientes
FROM clientes
GROUP BY 1
ORDER BY 1;