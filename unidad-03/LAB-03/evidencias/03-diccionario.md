# Evidencia 03 — Diccionario de datos operativo (Actividad 3)

**Scripts:** `sql/02-comentarios-diccionario.sql` · **Exportación:** `diccionario-clientes.csv` · **Captura:** `capturas/03-diccionario.png`
**Tabla:** `comercial.public.clientes`

## Estado de los `COMMENT` (verificado contra la bitácora)

| Objeto | `COMMENT` ejecutado | Evidencia |
|---|---|---|
| Tabla `clientes`, columnas `id`, `nombre`, `correo`, `rfc`, `edad` | Sí, 2026-11-23 23:38:21 | `E5` líneas 42–47 |
| Columna `canal_alta` | Sí, 23:42:01 (con folio CAM-2026-014) | `E5` línea 69 |
| Columnas `telefono`, `ciudad`, `codigo_postal`, `fecha_alta`, `segmento` | **Pendiente**: salen vacías en el CSV y en la captura 03 | `diccionario-clientes.csv` |

## Diccionario completo (estructura del motor + significado + gobierno)

Columnas técnicas tomadas de la exportación del motor. Descripción de las cinco columnas pendientes: texto propuesto en el script SQL.

| Columna | Tipo | Nulos | Descripción | Clasificación (Unidad II) | Finalidad | Control aplicado | ¿Cambios auditados? | Regla de calidad |
|---|---|---|---|---|---|---|---|---|
| `id` | bigint | NO | Identificador interno generado por el sistema | Interno | Identificación técnica | Secuencia `clientes_id_seq` | Sí (`id_cliente`) | Único, no nulo (PK) |
| `nombre` | varchar(120) | NO | Nombre completo | Dato personal (identificador directo) | Identificación y facturación | Acceso por rol | Sí | No nulo |
| `correo` | varchar(150) | NO | Correo de contacto | Dato personal | Notificaciones al cliente | Acceso por rol | Sí | Formato válido; único (C1, C4) |
| `telefono` | varchar(20) | SÍ | Teléfono de contacto | Dato personal | Contacto operativo y soporte | Acceso por rol | Sí | 10 dígitos (C6) |
| `rfc` | varchar(13) | SÍ | RFC del cliente | Dato personal (fiscal) | Facturación | Vista enmascarada para soporte (Unidad II) | Sí, LAB-01 Parte B | Formato RFC (C2, C3) |
| `edad` | integer | SÍ | Edad en años cumplidos | Dato personal | Analítica agregada | Acceso por rol | Sí | Rango 18–120 (C5) |
| `ciudad` | varchar(80) | SÍ | Ciudad de residencia o entrega | Dato personal (ubicación general) | Logística y analítica agregada | Acceso por rol | Sí | Consistencia de escritura (C7) |
| `codigo_postal` | varchar(10) | SÍ | Código postal | Dato personal (ubicación) | Logística y analítica agregada | Acceso por rol | Sí | 5 dígitos (C6) |
| `fecha_alta` | date | SÍ | Fecha de alta (por defecto `CURRENT_DATE`) | Interno (relación comercial) | Trazabilidad comercial | Valor por defecto | Sí | No futura |
| `segmento` | varchar(20) | SÍ | Segmento comercial asignado | Interno (dato derivado) | Analítica y campañas | Acceso por rol | Sí | Valores de un catálogo |
| `canal_alta` | varchar(20) | SÍ | Canal por el que se registró el cliente | Interno | Analítica de adquisición | Cambio con folio CAM-2026-014 | Sí | Valores de un catálogo |

## Diccionario complementario: `gobierno.solicitudes_cambio`

| Columna | Tipo | Significado |
|---|---|---|
| `folio` | text (PK) | Identificador de la solicitud (ej. CAM-2026-014) |
| `descripcion` | text | Qué se pide cambiar |
| `solicitado_por` | text | Área solicitante |
| `aprobado_por` | text | Quién autorizó (NULL = sin aprobar) |
| `ambiente` | text | `desarrollo`, `pruebas` o `produccion` |
| `fecha_aprobacion` | timestamptz | Cuándo se aprobó |
| `ventana_inicio` / `ventana_fin` | timestamptz | Periodo en el que el cambio está autorizado |

## Preguntas

**1. ¿Qué ventaja tiene guardar el significado en `COMMENT` en lugar de solo en un documento aparte?**
El significado **viaja con el objeto**: se consulta con `col_description` desde el mismo servidor, se respalda y se restaura junto con la base y no se desincroniza silenciosamente cuando se cambia la tabla (un documento aparte envejece sin que nadie lo note). Además, el cambio del `COMMENT` queda en la bitácora (ver pregunta 2). Un documento externo solo puede decir lo que alguien se acordó de escribir.

**2. ¿Quedaron registrados los `COMMENT` en la bitácora? ¿Con qué nivel de `log_statement`?**
Sí. Con `log_statement = mod` (`E1`), que registra **toda sentencia DDL** además de `INSERT/UPDATE/DELETE/TRUNCATE`. Aparecen en `E5` líneas 42–47 (primeros seis), 63 (`gobierno.solicitudes_cambio`) y 69 (`canal_alta`). Los `SELECT` del diccionario, en cambio, **no** se registran con `mod`; solo con `all`.

**3. ¿Qué información del diccionario debe mantenerse fuera del motor? ¿Por qué?**
La que el motor no puede saber ni garantizar: clasificación formal de la Unidad II, base legal o finalidad aprobada, propietario como área de la organización, regla de calidad acordada con el negocio y periodo de conservación. Además, una copia **fuera del motor** (el CSV con control de versiones en Git) permite auditar el diccionario aunque la base esté caída o haya sido alterada: si todo vive solo en `COMMENT`, quien tenga acceso de escritura puede cambiar el significado de un campo sin dejar rastro en un repositorio independiente.
