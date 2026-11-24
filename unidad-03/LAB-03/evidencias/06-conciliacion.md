# Evidencia 06 — Registro de cambios y conciliación (Actividad 7)

**Script:** `sql/04-registro-cambios.sql` · **Capturas:** `capturas/05-registro-cambios-y-bitacora.png` · **Fuente de la bitácora:** `E5-bitacora-postgresql.log`
**Periodo cubierto por la bitácora:** desde 2026-11-23 23:27:09 (arranque del servidor, `E5` línea 1) hasta 23:47:25 (última línea, `E5` línea 102).

## Verificación de ventana (captura 05)

`CAM-2026-014 | Comité de cambios | dentro_de_ventana = t`

## Extracción de la bitácora (captura 05; coincide con `E5`)

| num (línea de E5) | Momento | Usuario | Sentencia |
|---|---|---|---|
| 51 | 2026-11-23 23:41:18.119 | postgres | `CREATE SCHEMA gobierno;` |
| 52 | 23:41:18.124 | postgres | `REVOKE ALL ON SCHEMA gobierno FROM PUBLIC;` |
| 53 | 23:41:18.128 | postgres | `CREATE TABLE gobierno.solicitudes_cambio (...)` |
| 68 | 23:42:01.024 | postgres | `ALTER TABLE clientes ADD COLUMN canal_alta VARCHAR(20);` |


## Tabla de conciliación

| Momento (bitácora) | Usuario | Sentencia | Línea E5 | Folio que lo autoriza | ¿Autorizado? | Hallazgo |
|---|---|---|---|---|---|---|
| 23:41:18.119 | `postgres` | `CREATE SCHEMA gobierno` | 51 | Ninguno | **No** | H-03 |
| 23:41:18.124 | `postgres` | `REVOKE ALL ON SCHEMA gobierno FROM PUBLIC` | 52 | Ninguno | **No** | H-03 |
| 23:41:18.128 | `postgres` | `CREATE TABLE gobierno.solicitudes_cambio` | 53 | Ninguno | **No** | H-03 |
| 23:42:01.024 | `postgres` | `ALTER TABLE clientes ADD COLUMN canal_alta ...` | 68 | CAM-2026-014 | Sí, **con reserva** | H-04 |
| 23:42:01.029 | `postgres` | `COMMENT ON COLUMN clientes.canal_alta ...` | 69 | CAM-2026-014 (citado en el propio comentario) | Sí, con reserva | H-04 |
| 23:38:21 (6 sentencias) | `postgres` | `COMMENT ON TABLE/COLUMN clientes ...` | 42–47 | Ninguno | **No** | H-03 *(preparación de la Actividad 3)* |
| 23:41:18.160 | `postgres` | `COMMENT ON TABLE gobierno.solicitudes_cambio` | 63 | Ninguno | **No** | H-03 |

Cambios de datos del mismo periodo (no DDL, pero conciliables con la auditoría): `INSERT` de 2 clientes con datos erróneos, 23:34:58.603 (línea 28) = `id_evento` 9 y 10 en E4, sin folio (preparación de la Actividad 1).

### Motivo de la reserva en CAM-2026-014 (H-04)
La línea 64 muestra que el `INSERT` del folio lo hizo **`postgres` a las 23:42:01.006**, y el `ALTER TABLE` lo hizo **el mismo usuario 18 ms después** (línea 68). Además, el propio `INSERT` define `fecha_aprobacion = now() - interval '1 day'` y la ventana `now() - 5 minutes … now() + 1 hour`, es decir, **la fecha de aprobación está retrodatada y la ventana se calculó en el mismo acto**. La bitácora prueba que el registro de autorización se creó en el momento del cambio y por quien lo ejecutó; no prueba que el Comité de cambios aprobara el día anterior. Es una simulación válida para la práctica, pero ante un auditor real el control no sería confiable (sin separación entre quien aprueba y quien ejecuta).

### Cobertura de la conciliación: lo que **no** se puede conciliar
`E2` muestra privilegios vigentes (`app_ventas`: SELECT, UPDATE; `soporte_ana`: SELECT) y la tabla `clientes` tiene la columna `segmento`, pero **no hay líneas de bitácora** de los `GRANT`, `REVOKE`, `CREATE ROLE` ni `ALTER TABLE ... segmento` que los originaron: el archivo exportado empieza en el arranque del 2026-11-23 23:27 (el servidor estuvo apagado desde el 2026-11-19 00:25:40, `E5` línea 4) y los eventos de la auditoría del 2026-11-08 (`E4` ids 1–8) tampoco tienen su sentencia en el archivo (H-02).

## Preguntas

**1. ¿Qué cambios de la bitácora no tienen folio? ¿Preparación o hallazgo?**
Los DDL y metadatos sin folio son: `CREATE SCHEMA gobierno`, `REVOKE ALL ... FROM PUBLIC`, `CREATE TABLE gobierno.solicitudes_cambio` y los `COMMENT ON` (líneas 42–47 y 63). Son **preparación del laboratorio**, no actividad maliciosa, y el sistema de folios no puede autorizar su propia creación (circularidad). Aun así se registran como **hallazgo H-03** (severidad Media): un cambio de estructura y de privilegios en el ambiente de producción sin folio es exactamente lo que POL-06 prohíbe, y no se corrige en silencio.

**2. La desactivación del disparador (LAB-01, Actividad 14): ¿qué tan grave es? ¿Qué distingue la línea 163 de la 169?**
En **este** archivo no hay líneas de `DISABLE TRIGGER` (cubre solo desde el 2026-11-23 23:27), así que no se puede verificar aquí; `E3` solo muestra que hoy el disparador está habilitado (`tgenabled = O`). *Respuesta conceptual con el ejemplo de la guía:* es un hallazgo **grave (Alta)**, porque apagar el disparador suspende la auditoría del dato justo cuando se quiere modificar sin dejar rastro. La línea 163 la ejecuta **`app_ventas`**, un rol de aplicación: significa que una cuenta de servicio tiene permisos de estructura sobre `clientes`, lo que no debería ocurrir y es un riesgo de **control de acceso**. La línea 169 la ejecuta **`postgres`** (el administrador): es un uso legítimo de su poder, pero debe tener folio y su par `ENABLE` (línea 171) para demostrar que se restauró. La diferencia está en *quién* lo hizo y si está *autorizado*, no en la sentencia.

**3. ¿Qué limitación tiene la conciliación si `log_statement` estuvo en `none` durante algún periodo?**
Los cambios de ese periodo **no dejan línea**, así que la conciliación parecería "limpia" aunque hubiera cambios no autorizados: la ausencia de evidencia no es evidencia de ausencia. `E1` solo muestra la configuración **hoy**; para demostrar que estuvo vigente en todo el periodo se necesitaría historial de configuración (archivos de configuración versionados, o los cambios de `postgresql.conf` con folio). La guía ya lo ejemplifica: la creación de `dba.bitacora` no aparece porque se creó con `log_statement = none`.

**4. ¿Quién debería realizar la conciliación?**
Una persona **distinta** de quien hizo los cambios: Auditoría interna o el Responsable de seguridad. El DBA entrega la extracción (con hash) y aclara dudas técnicas, pero si concilia sus propios actos se rompe la separación de funciones; es la misma razón por la que `auditoria.cambios_clientes` no debe pertenecer a quien opera `clientes`.
