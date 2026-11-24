# Evidencia 01 — Calidad de datos desde la operación (Actividad 1)

**Base:** `comercial` · **PostgreSQL:** 16.15 · **Fecha de ejecución:** 2026-11-23
**Scripts:** `sql/01-verificaciones-calidad.sql` · **Capturas:** `capturas/02-verificaciones-calidad.png`

## Origen de los registros con error

Los registros 7 y 8 se cargaron a propósito con errores (bitácora, `E5-bitacora-postgresql.log` línea 28, 2026-11-23 23:34:58.603; auditoría `auditoria.cambios_clientes` `id_evento` 9 y 10, `E4-muestra-auditoria.txt`). Los dos registros **no se eliminan ni se corrigen**: forman parte de los hallazgos del expediente.

## Hallazgos

| # | Hallazgo | Registros | Regla de calidad | ¿Quién decide la corrección? | Acción propuesta | Evidencia |
|---|----------|-----------|------------------|------------------------------|------------------|-----------|
| C1 | Posible cliente duplicado: `ana.lopez@example.test` aparece 2 veces (con distinta capitalización) | 1, 7 | Unicidad del correo | Gerencia Comercial (propietario) | Confirmar con el cliente si es la misma persona; el propietario decide cuál registro se conserva o si se fusionan. Después, índice único sobre `lower(correo)`. | Captura 02 (2 registros, ids 1, 7) |
| C2 | RFC incompleto: `LOAA850315AB` tiene 12 caracteres y el formato exige 13 (3-4 letras + 6 dígitos + 3 alfanuméricos) | 7 | Formato del RFC | Gerencia Comercial, con el área de facturación | Solicitar el RFC completo al cliente. El DBA no puede "adivinar" la homoclave. | Dato en E5 línea 29; ver nota de evidencia pendiente |
| C3 | RFC ausente (`NULL`) | 8 | Completitud del RFC | Gerencia Comercial | Definir si el RFC es obligatorio para este tipo de cliente; solicitarlo si lo es. | Captura 02 (`sin_rfc = 1`) |
| C4 | Correo con formato no válido: `sin-correo` | 8 | Formato del correo | Gerencia Comercial / responsable de la aplicación de captura | Solicitar correo válido; validar en la aplicación antes de insertar. | Captura 02 (id 8) |
| C5 | Edad fuera de rango: `-3` | 8 | Rango de edad (18–120) | Gerencia Comercial | Corregir con el dato real; agregar `CHECK` de rango. | Captura 02 (id 8) |
| C6 | Teléfono truncado `667` y código postal `8000` (4 dígitos). *Detectado al revisar los datos insertados; la guía no trae consulta para esto.* | 8 | Formato de teléfono (10 dígitos) y CP (5 dígitos) | Gerencia Comercial | Solicitar datos completos. Consultas 6 y 7 del script. | E5 línea 29-30 |
| C7 | Ciudad con dos escrituras: `Culiacan` (id 7) y `Culiacán` (id 8). *Detectado al revisar los datos.* | 7, 8 | Consistencia / catálogo de valores | Gerencia Comercial | Definir un catálogo de ciudades o normalizar al capturar. Consulta 8 del script. | E5 línea 29-30 |

Completitud observada (captura 02): `total = 7`, `sin_telefono = 0`, `sin_rfc = 1`. Nótese que `sin_telefono = 0` no significa que los teléfonos estén bien: el id 8 tiene `667`, que no es nulo pero tampoco válido (C6). Medir solo nulos no detecta datos presentes pero inválidos.

## Preguntas

**1. ¿Por qué el DBA no debe corregir por su cuenta el RFC del registro 7?**
Porque el DBA es **custodio**, no propietario (guía §4.2). El valor correcto del RFC es un hecho del cliente y una decisión de la Gerencia Comercial: faltan dos caracteres y el DBA no tiene forma de saber cuáles son. Completarlos por suposición introduciría un dato falso en un campo de facturación, con consecuencias fiscales, y además sería un cambio en producción sin solicitud aprobada (POL-06). Su responsabilidad es **detectarlo, documentarlo y escalarlo** al propietario.

**2. ¿Qué restricción habría evitado cada hallazgo y quién debe aprobarla?**

| Hallazgo | Restricción | 
|----------|-------------|
| C1 | `CREATE UNIQUE INDEX ... ON clientes (lower(correo))` (un `UNIQUE` simple no detecta la diferencia de mayúsculas) |
| C2 / C3 | `CHECK (rfc IS NULL OR rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$')`; `NOT NULL` solo si el negocio decide que es obligatorio |
| C4 | `CHECK (correo ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$')` |
| C5 | `CHECK (edad IS NULL OR edad BETWEEN 18 AND 120)` |
| C6 | `CHECK` de longitud/dígitos en `telefono` y `codigo_postal` |
| C7 | Tabla catálogo de ciudades con llave foránea |

Las aprueba el **propietario** (Gerencia Comercial), porque cambian qué datos acepta el negocio (por ejemplo, si un cliente sin RFC es válido), y se aplican como **cambio en producción con folio** (POL-06). Las restricciones propuestas están en el script, comentadas, para no "corregir" silenciosamente los hallazgos.

**3. Si el DBA corrige un dato, ¿qué mecanismo del LAB-01 deja evidencia?**
El disparador `trg_auditoria_clientes` (activo según `E3`, `tgenabled = O`) registra el `UPDATE` en `auditoria.cambios_clientes` con usuario, aplicación, operación y valores antes/después. Además, con `log_statement = mod` (`E1`) la sentencia queda en la bitácora de PostgreSQL. Dos fuentes independientes que se pueden cruzar, como ocurre con los eventos 9 y 10 (ver `EXPEDIENTE.md` §3).
