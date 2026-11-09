# Actividad 17 — Cronología y respuestas a Dirección

## 1. Cronología

| # | Fecha y hora | Usuario | Cliente | Tipo de evento | Qué ocurrió | ¿Exitoso? | Fuente |
|---|---|---|---|---|---|---|---|
| 1 | 2026-11-08 12:29:55 | app_ventas | — | Acceso | Dos intentos de login por TCP rechazados (`password authentication failed`, "has no password assigned"), regla `pg_hba.conf` línea 125 (127.0.0.1/32) | No | Bitácora 12:29:55.366 PID 17593 y 12:29:55.376 PID 17594 |
| 2 | 2026-11-08 12:30:05 | postgres | — | Acceso | Dos intentos de login por TCP rechazados por la misma causa y la misma regla | No | Bitácora 12:30:05.528 PID 17606 y 12:30:05.536 PID 17607 |
| 3 | 2026-11-08 13:56:48 | (recarga de configuración) | — | Configuración | `SIGHUP`: `log_connections=on`, `log_disconnections=on`, `log_statement=ddl`. A partir de aquí se registran conexiones y DDL | Sí | Bitácora 13:56:48.544–.555 PID 6128 |
| 4 | 2026-11-08 14:00:31 | app_ventas | — | Acceso | Login exitoso (scram-sha-256, TLS 1.3, `app-ventas-web`, 127.0.0.1); sesión de ~2 min **sin sentencias registradas** | Sí | Bitácora 14:00:31.963 y 14:02:31.903 PID 18369 |
| 5 | 2026-11-08 14:55:05 | postgres | — | Privilegio | `REVOKE UPDATE ON clientes FROM soporte_ana` | Sí (sin error posterior) | Bitácora 14:55:05.516 PID 18745 |
| 6 | 2026-11-08 14:55:13 | postgres | — | Error | `GRANT UPDATE ON clientes TO app_ventas` falló por sintaxis (faltó `;` y se pegó el `ALTER TABLE`). **El GRANT no se ejecutó** | No | Bitácora 14:55:13.501 PID 18745 |
| 7 | 2026-11-08 14:55:32 | postgres | — | Estructura | `ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20)` | Sí | Bitácora 14:55:32.103 PID 18745 |
| 8 | 2026-11-08 15:26:54 | postgres | — | Configuración | `ALTER SYSTEM SET log_statement='mod'`; recarga. Desde aquí se registran INSERT/UPDATE/DELETE | Sí | Bitácora 15:26:54.392–.417 PIDs 19089/6128 |
| 9 | 2026-11-08 15:27:00 | app_ventas | id 3 | Datos | `UPDATE clientes SET telefono='6679990000' WHERE id=3` desde `app-ventas-web` (127.0.0.1) | Sí | Bitácora 15:27:00.920 PID 19100 |
| 10 | 2026-11-08 16:29:35 | postgres | — | Error | `DROP ROLE soporte_ana` rechazado: aún tiene privilegios sobre `clientes` | No | Bitácora 16:29:35.678–.696 PID 19421 |
| 11 | 2026-11-08 16:38:15 | postgres | — | Privilegio | `ALTER USER soporte_ana PASSWORD '<hash SCRAM>'` | Sí | Bitácora 16:38:15.954 PID 19522 |
| 12 | 2026-11-08 16:42:34 | soporte_ana | id 5 | Error | Login exitoso y `DELETE FROM clientes WHERE id=5` → `permission denied for table clientes` | No (el DELETE) | Bitácora 16:42:34.947–.950 PID 19600 |
| 13 | 2026-11-08 17:20:57 | postgres | — | Estructura | `CREATE SCHEMA auditoria`, `REVOKE ALL … FROM PUBLIC` y `CREATE TABLE auditoria.cambios_clientes` | Sí | Bitácora 17:20:57.549, 17:20:57.566, 17:21:01.753 PID 19662 |
| 14 | 2026-11-08 19:08:15 | postgres | — | Estructura | `CREATE FUNCTION auditoria.registrar_cambio_cliente()` (SECURITY DEFINER), `REVOKE … FROM PUBLIC` y `CREATE TRIGGER trg_auditoria_clientes` | Sí | Bitácora 19:08:15.594, 19:08:19.365, 19:08:22.946 PID 20619 |
| 15 | 2026-11-08 19:16:42 | app_ventas | id 3 | Datos | `UPDATE clientes SET rfc='GAMA780912ZZZ' WHERE id=3`; RFC `…XYZ` → `…ZZZ` | Sí | Auditoría `id_evento=1`; bitácora 19:16:42.635 PID 20674 |
| 16 | 2026-11-08 19:17:00 y 19:17:04 | app_ventas | — | Error | Dos `SELECT * FROM auditoria.cambios_clientes` por `psql` → `permission denied for schema auditoria` | No | Bitácora 19:17:00.079 PID 20687 y 19:17:04.592 PID 20703 |
| 17 | 2026-11-08 19:28:47 y 19:28:52 | postgres | id 6 | Datos | `INSERT` de Pedro Ruiz (RFC `RUPE950101AAA`) y `DELETE` 5 s después | Sí | Auditoría `id_evento=2` y `3`; bitácora 19:28:47.328 y 19:28:52.529 PID 20789 |
| 18 | 2026-11-08 19:42:48 | app_ventas | — | Error | Intento de `DELETE FROM auditoria.cambios_clientes` (denegado, schema) e intento de `ALTER TABLE clientes DISABLE TRIGGER` (denegado, `must be owner`) | No | Bitácora 19:42:48.279–.281 PID 20898 |
| 19 | 2026-11-08 19:46:11 | postgres | id 3 | Estructura / Datos | `DISABLE TRIGGER` → `UPDATE clientes SET rfc='GAMA780912GHI' WHERE id=3` → `ENABLE TRIGGER`. **El cambio de RFC no quedó en la auditoría** | Sí (el cambio); sin registro de auditoría | Bitácora 19:46:11.626, .633, .636 PID 20789. Sin `id_evento` correspondiente |
| 20 | 2026-11-08 19:54:30 | postgres | ids 1, 2, 4, 5, 3 | Datos | `UPDATE clientes SET segmento='regular'` sin WHERE; 5 filas auditadas, el RFC no cambia | Sí | Auditoría `id_evento=4–8`; bitácora 19:54:30.012 PID 20789 |

## 2. Respuestas a Dirección

### 2.1 ¿Quién cambió el RFC?

La bitácora no rotula las actividades. Las asocio por orden y por lo que la evidencia permite. La auditoría se creó en la Actividad 10 (evento 14), así que las Actividades 3 y 7 son anteriores a las 19:08 y las 12 y 14 son posteriores.

| Actividad | Respuesta | Evidencia |
|---|---|---|
| 3 (primer cambio) | **No hay evidencia.** | Antes de las 15:26:54 `log_statement` era `ddl`, así que ningún UPDATE se registraba, y todavía no existía la tabla de auditoría. Solo constan sesiones de `app_ventas` sin sentencias (14:00:31–14:02:31 y 15:26:38) que podrían contener el cambio, pero no se puede afirmarlo. El valor `…XYZ` aparece por primera vez como "antes" en la auditoría 1, sin registro de quién lo estableció. |
| 7 | **No hay evidencia** de un UPDATE de `rfc` previo a las 19:08. | Con `log_statement=mod` (desde 15:26:54) el único UPDATE registrado antes de la auditoría es el del teléfono (sección 2.2). |
| 12 | **`app_ventas`**, vía `app-ventas-web`, desde 127.0.0.1, 2026-11-08 19:16:42, cliente id 3. | Auditoría `id_evento=1` y bitácora PID 20674. Las dos fuentes coinciden. |
| 14 | **`postgres`** (superusuario), por `psql` en socket local (autenticación `peer`), 2026-11-08 19:46:11, cliente id 3. | Solo en la bitácora (PID 20789): el trigger estaba deshabilitado, por eso **no existe fila de auditoría**. |

### 2.2 ¿Quién cambió el teléfono?

**`app_ventas`** desde `app-ventas-web` (127.0.0.1), el 2026-11-08 a las 15:27:00.920, cliente id 3, nuevo valor `6679990000`.

- Fuente: bitácora PID 19100 (`log_statement=mod`).
- **No hay evidencia** del teléfono anterior: no existía tabla de auditoría y el log solo guarda la sentencia, no el valor previo.
- **No hay evidencia** de qué persona real operaba la aplicación; el log solo identifica al rol.

### 2.3 ¿Hubo intentos de acceso fallidos?

**Sí, cuatro**, todos el 2026-11-08 por TCP, cuyo origen es la regla `pg_hba.conf` línea 125 (`host … 127.0.0.1/32 scram-sha-256`):

| Hora | Usuario | PID | Causa |
|---|---|---|---|
| 12:29:55.366 | app_ventas | 17593 | `User "app_ventas" has no password assigned` |
| 12:29:55.376 | app_ventas | 17594 | ídem |
| 12:30:05.528 | postgres | 17606 | `User "postgres" has no password assigned` |
| 12:30:05.536 | postgres | 17607 | ídem |

- Se trata de un fallo de configuración (roles sin contraseña), no de adivinanza de contraseñas: son pares de intentos y hay una sola causa.
- **No hay evidencia** de la aplicación cliente ni del puerto de origen: en esa fecha `log_line_prefix` no incluía `%a` ni `%h`, y el origen 127.0.0.1 se deduce solo de la regla de `pg_hba.conf` que coincidió.
- Desde las 13:56:48 no hay más `FATAL` de autenticación. Los `permission denied` de los eventos 12, 16 y 18 son **fallos de autorización** (el login sí fue exitoso), no de acceso.

### 2.4 ¿Qué valor tenía el RFC antes de cada cambio?

| Cambio | Valor antes | Valor después | Fuente |
|---|---|---|---|
| id 3, 19:16:42 (app_ventas) | `GAMA780912XYZ` | `GAMA780912ZZZ` | Auditoría 1 |
| id 3, 19:46:11 (postgres, trigger deshabilitado) | **No hay evidencia** registrada: ni el log ni la auditoría guardan el valor previo | `GAMA780912GHI` (log, PID 20789) | Bitácora; sin fila de auditoría |
| id 6, 19:28:47 (INSERT) | no aplica (alta) | `RUPE950101AAA` | Auditoría 2 |
| id 6, 19:28:52 (DELETE) | `RUPE950101AAA` | no aplica (baja) | Auditoría 3 |
| ids 1, 2, 4, 5, 3 a las 19:54:30 | sin cambio de RFC (antes = después) | sin cambio | Auditoría 4–8 |

El antes del cambio de las 19:46 no puede declararse. Podría suponerse `ZZZ` por la secuencia (auditoría 1 y luego auditoría 8 con `GHI`), pero es una inferencia, no un dato registrado.

## 3. Huecos de evidencia (eventos sin registro)

1. **Antes de las 13:56:48:** `log_connections` estaba apagado, así que los accesos exitosos no tienen hora. Solo se registraron los fallidos.
2. **Antes de las 15:26:54:** `log_statement=ddl` no registra DML. Las sesiones de `app_ventas` de 14:00:31 (2 min) y de 15:26:38 (0.043 s) no muestran qué hicieron.
3. **SELECT nunca se registra** con `log_statement=mod`: lo que leyó `soporte_ana` (sesiones `reporte-mensual` y la de 19:53:31) no consta.
4. **14:59:09–14:59:14:** 30 "connection received" locales sin autenticación ni desconexión. No hay evidencia de su resultado ni de su origen.
5. **19:46:11.633:** UPDATE de RFC sin fila de auditoría (trigger deshabilitado por el superusuario). Solo el log lo captura.
6. **14:31:53 `logging_collector = on`:** requiere reinicio y el log no muestra ninguno (mismo PID 6128 hasta el final), por lo que no hay evidencia de que haya surtido efecto.
7. **Persona real** detrás de `app_ventas`, `postgres` o `soporte_ana`: el log solo identifica roles.

## 4. Hallazgos adicionales

- Un rol con `app_ventas` pudo hacer UPDATE (eventos 9 y 15) aunque el único GRANT visible falló (evento 6). Su permiso viene de algo anterior que esta bitácora no muestra.
- La auditoría resistió a `app_ventas` (eventos 16 y 18), pero un superusuario puede deshabilitar el trigger y dejar un cambio sin registro (evento 19). Solo la bitácora del servidor lo delata.
- `ALTER USER … PASSWORD '<hash SCRAM>'` quedó escrito en el log con `log_statement=ddl` (evento 11). El hash expuesto es un riesgo y debe protegerse el archivo de log.
