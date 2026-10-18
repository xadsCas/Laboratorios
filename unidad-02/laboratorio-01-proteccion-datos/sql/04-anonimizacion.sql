-- Laboratorio 01: Anonimización y agregación
-- Objetivo: reducir la exposición de información individual mediante agrupaciones.
-- Requiere que exista la tabla public.clientes.

-- Agrupar edades en rangos y reducir la precisión de la ubicación.
SELECT
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        WHEN edad >= 46 THEN '46 o más'
        ELSE 'Sin clasificar'
    END AS rango_edad,
    LEFT(codigo_postal, 2) AS region,
    COUNT(*) AS cantidad_clientes
FROM public.clientes
GROUP BY
    CASE
        WHEN edad BETWEEN 18 AND 30 THEN '18-30'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45'
        WHEN edad >= 46 THEN '46 o más'
        ELSE 'Sin clasificar'
    END,
    LEFT(codigo_postal, 2)
HAVING COUNT(*) >= 5
ORDER BY rango_edad, region;

-- La condición HAVING evita mostrar grupos con menos de cinco registros.
-- Si no aparecen filas, significa que ningún grupo cumple el mínimo.
-- Esto no demuestra por sí solo que los datos sean anónimos:
-- deben evaluarse también los riesgos de identificación indirecta.
