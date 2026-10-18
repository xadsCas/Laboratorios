-- Laboratorio 01: Política de retención
-- Objetivo: identificar registros que superan cinco años de antigüedad.
-- Esta consulta no elimina ni modifica registros.

SELECT
    id,
    fecha_alta,
    CURRENT_DATE - fecha_alta AS dias_desde_alta
FROM public.clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years'
ORDER BY fecha_alta;

-- Un resultado vacío significa que no se encontraron registros
-- que superen el periodo de retención definido.
-- La decisión de conservar o eliminar información debe seguir
-- una política documentada y los requisitos legales aplicables.
