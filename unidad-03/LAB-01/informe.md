Informe — Laboratorio 1: Bitácoras y auditoría del dato (PostgreSQL)

Materia: Administración de Bases de Datos (DBA) · Unidad III Escenario: Comercializadora Norte S.A. de C.V. — tabla clientes, roles app_ventas y soporte_ana Instancia: PostgreSQL 16 sobre Ubuntu en WSL (servicio postgresql@16-main, puerto 5433)

Conclusiones principales

La auditoría no es retroactiva: lo que no se registró antes del incidente no se puede reconstruir (Actividad 3; el cambio original del RFC quedó sin responsable demostrable).
La bitácora dice que ocurrió algo; la auditoría dice qué datos cambiaron. Se necesitan ambas.
Ningún mecanismo dentro del servidor resiste a un administrador con control total: con el disparador deshabilitado, un cambio de RFC quedó sin fila de auditoría (Actividad 14). Solo la bitácora lo delató.
La propia bitácora y la auditoría son datos sensibles: la bitácora filtró una contraseña en texto plano y la auditoría duplica RFC y datos personales.
2. Entorno y método
Elemento	Valor
Motor	PostgreSQL 16 en Ubuntu sobre WSL (sudo -u postgres psql -p 5433 -d comercial)
Roles	postgres (administrador), app_ventas (SELECT/UPDATE), soporte_ana (SELECT)
Conexiones de prueba	psql por TCP 127.0.0.1:5433 (regla pg_hba.conf línea 125, scram-sha-256) y socket local para el administrador
Fuentes de evidencia	dba.bitacora (archivo vigente), pg_stat_activity, auditoria.cambios_clientes

Cada actividad tiene su evidencia (.md con comandos, resultados y capturas) en evidencias/ y su script en sql/. Ver el índice en el README.

3. Parte A — Bitácora del servidor
Actividad 1 — Configuración inicial

Con los valores por defecto: logging_collector = off, log_connections = off, log_disconnections = off, log_statement = none. No se registra quién se conecta ni los UPDATE. Con el colector apagado, los mensajes van a stderr y quien decide su destino es el entorno que arrancó el servidor (aquí, el servicio de PostgreSQL en Ubuntu/WSL). log_timezone = America/Mazatlan: importa para ordenar correctamente eventos de varias fuentes. → evidencias/01-configuracion-inicial.md

Actividad 2 — Colector y vista dba.bitacora

ALTER SYSTEM SET logging_collector = on + reinicio (contexto postmaster: el proceso colector y la tubería de stderr se crean solo al arrancar; log_statement solo necesita pg_reload_conf()). Se creó dba.bitacora (pg_read_file(pg_current_logfile()) + WITH ORDINALITY) en un esquema sin acceso para PUBLIC. Ventaja: filtrar con SQL; riesgo: concentrar evidencia sensible y que cualquiera con acceso lea IPs, usuarios y secretos. Solo el rol DBA/auditoría debe consultarla. → evidencias/02-colector.md · sql/01-colector-y-vista.sql

Actividad 3 — El incidente sin bitácora

app_ventas ejecutó UPDATE clientes SET rfc = … WHERE id = 3 (UPDATE 1) y la búsqueda en la bitácora devolvió (0 rows).

Pregunta	Respuesta
¿Se puede demostrar quién modificó el RFC?	No. Solo se ve el estado actual del dato.
¿Se puede demostrar que no fue soporte_ana?	No. Solo hay una inferencia por diseño (solo tiene SELECT), no una prueba.
¿Los privilegios debían impedir el cambio?	No: app_ventas está autorizada. Los privilegios controlan, no dejan rastro.
¿Qué debía estar configurado antes?	Colector, log_connections/log_disconnections, prefijo con %u %d %a %h y log_statement = 'mod'.

→ evidencias/03-incidente-sin-bitacora.md

Actividad 4 — Configurar la bitácora

Se activaron log_connections, log_disconnections, log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ' y log_statement = 'ddl', con pg_reload_conf(). Los valores quedan en postgresql.auto.conf. El mensaje parameter "…" changed to "on" lo escribe el postmaster (PID 6128), no la sesión del administrador. Quien puede ejecutar ALTER SYSTEM puede reducir la evidencia futura, de ahí la necesidad de copias externas. → evidencias/04-configuracion-bitacora.md · sql/02-configuracion-bitacora.sql

Actividad 5 — Accesos exitosos y fallidos

Una conexión exitosa deja cuatro eventos: connection received → authenticated (método y regla de pg_hba.conf) → authorized (SSL y application_name) → disconnection (duración). Un fallo muestra al cliente un mensaje genérico, mientras la bitácora guarda la causa real (Role "…" does not exist), lo que evita la enumeración de usuarios. El usuario que aparece en un intento fallido no prueba quién intentó entrar. Patrón de fuerza bruta: muchos FATAL password authentication failed desde un mismo origen (consulta de conteo en la evidencia). → evidencias/05-accesos.md

Actividad 6 — Privilegios y estructura

REVOKE, GRANT y ALTER TABLE quedan registrados con log_statement = 'ddl' porque cambian el catálogo. Hallazgo: CREATE ROLE … PASSWORD '…' guarda la contraseña en texto plano en la bitácora. Mitigación: crear el rol sin contraseña y asignarla con \password, restringir la lectura de la bitácora y rotar el secreto. → evidencias/06-privilegios-estructura.md · sql/03-privilegios-estructura.sql

Actividad 7 — ddl frente a mod

Con ddl el UPDATE de datos no aparece; con mod sí (incluye INSERT, UPDATE, DELETE, TRUNCATE, COPY FROM). Leer un RFC solo se registraría con all (costoso y ruidoso). Aun con mod, la bitácora no guarda el valor anterior, por lo que no permite revertir con certeza. → evidencias/07-modificaciones.md

Actividad 8 — Errores y operaciones rechazadas

DELETE sin permiso → permission denied for table clientes; DROP ROLE soporte_ana → cannot be dropped because some objects depend on it. Cada error genera ERROR + STATEMENT (log_min_error_statement = error) y queda aun con log_statement = none. Un error es evidencia de intento, no de cambio. → evidencias/08-errores.md

Actividad 9 — pg_stat_activity

Muestra el presente (quién está conectado, desde dónde, qué ejecuta y desde cuándo) y desaparece al cerrar la sesión; la bitácora conserva el pasado. Son complementarias. → evidencias/09-pg-stat-activity.md

4. Parte B — Auditoría a nivel de dato
Actividad 10 — Diseño y creación del registro

Tabla auditoria.cambios_clientes con momento TIMESTAMPTZ, usuario_sesion, usuario_efectivo, aplicacion, ip_cliente INET, operacion, id_cliente, valores_antes y valores_despues (JSONB). Decisiones: TIMESTAMPTZ para ordenar sin ambigüedad de zona; JSONB del registro completo para que los eventos sigan siendo válidos si clientes cambia de estructura. La tabla hereda la clasificación de clientes (datos personales) y se protege con esquema aparte sin acceso para PUBLIC. → evidencias/10-diseño-auditoria.md · sql/04-esquema-auditoria.sql

Actividad 11 — Función y disparador

auditoria.registrar_cambio_cliente() es SECURITY DEFINER con search_path fijo y sin EXECUTE para PUBLIC; el disparador trg_auditoria_clientes es AFTER INSERT OR UPDATE OR DELETE … FOR EACH ROW. Sin SECURITY DEFINER, app_ventas (sin permisos sobre auditoria) haría fallar su propio UPDATE; darle permisos le permitiría borrar el rastro. La creación del mecanismo quedó en la bitácora. → evidencias/funcion-disparador.md · sql/05-funcion-disparador.sql

Actividad 12 — El incidente auditado

app_ventas cambió el RFC (GAMA780912XYZ → GAMA780912ZZZ) y no pudo leer la auditoría (permission denied for schema auditoria). El evento quedó con usuario, hora, aplicación, IP y valores antes/después. usuario_efectivo = postgres (efecto de SECURITY DEFINER) y usuario_sesion = app_ventas identifica al responsable real. Reversión: UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3; (también se audita). La IP es más confiable que application_name, que declara el propio cliente. → evidencias/11-incidente-auditado.md · sql/06-campos-modificados.sql

Actividad 13 — Altas y bajas

INSERT guarda solo valores_despues; DELETE guarda solo valores_antes. El cliente borrado (Pedro Ruiz) solo se puede reconstruir desde la auditoría. ip_cliente queda vacía para el administrador porque se conectó por socket local (inet_client_addr() es NULL). Conflicto con la retención de la Unidad II: el dato "eliminado" persiste en la auditoría; lo resuelven gobierno de datos, Legal/Cumplimiento y Seguridad, no el DBA. → evidencias/12-altas y bajas.md

Actividad 14 — Intentar manipular la auditoría

app_ventas no pudo borrar la auditoría ni deshabilitar el disparador. El administrador sí: deshabilitó el disparador, cambió el RFC y lo volvió a habilitar; el conteo de la auditoría no aumentó. La evidencia del cambio sin auditar está en la bitácora (ALTER TABLE … DISABLE/ENABLE TRIGGER y el UPDATE), cruzándola con la tabla de auditoría. Control administrativo: bitácoras en un sistema externo de otra área y cambios con doble autorización; es la separación de funciones de la Unidad II. → evidencias/13-manipulacion.md

Actividad 15 — Límites, lecturas y volumen
Hecho	Bitácora (mod)	Auditoría (disparador)
SELECT de soporte_ana sobre RFC	No lo registra	No lo registra (no hay disparador de lectura)
UPDATE masivo de 5 filas	1 línea	5 filas (una por registro afectada)

Con un millón de registros un UPDATE sin WHERE generaría un millón de eventos con dos JSON cada uno: crecimiento, lentitud y WAL. log_statement = 'all' convierte la bitácora en un nuevo depósito de datos sensibles. Alternativas para lecturas: all, función que registre el uso o pgaudit. → evidencias/14-limites.md

Actividad 16 — Exportar y conservar la bitácora

Exportación. La bitácora vigente se exportó a evidencias/bitacora-lab01.log con pg_read_file(pg_current_logfile()). El archivo se exportó con la contraseña sustituida: Temporal_Practica_2026 (que quedó en el CREATE ROLE de la Actividad 6) se reemplazó por <REDACTED> antes de salir del servidor. Su hash SHA-256 está en evidencias/bitacora-lab01.sha256.

1. Un resumen SHA-256, ¿impide que alguien modifique la bitácora? ¿Qué permite demostrar? No impide modificarla: no protege el archivo, solo describe su contenido. Permite demostrar la integridad: si el archivo cambia aunque sea un carácter, su hash será otro, así que quien tenga el hash original puede comprobar que el archivo no fue alterado desde que se calculó. No prueba quién la generó, que estuviera completa al principio, ni que el hash mismo sea confiable. Además, este hash corresponde a la copia con la contraseña sustituida, no al archivo original del servidor.

2. ¿Dónde debería guardarse el hash para que sea útil como control de integridad? Fuera del alcance de quien pueda modificar la bitácora, y no junto al archivo en la misma carpeta sin protección. Debe quedar en un lugar controlado por otra área o por un tercero: el repositorio con un commit registrado, un sistema de tickets, un correo enviado a Auditoría/Seguridad o un almacenamiento de solo escritura. Si el mismo administrador puede cambiar el archivo y el hash, el control no sirve.

3. ¿Qué riesgos tiene conservar la bitácora solo en el servidor que la produce?

Se pierde si el servidor se reinstala, se recrea, falla el disco o la bitácora rota y se elimina.
Quien controle el servidor (o un atacante que lo comprometa) puede modificarla o borrarla para ocultar sus acciones, como se vio en la Actividad 14.
Si el servidor deja de estar disponible, no hay evidencia para investigar.
Un disco lleno por los logs puede afectar al propio servicio. NIST SP 800-92 recomienda centralizar las bitácoras en un sistema separado, protegerlas contra accesos y cambios no autorizados, y definir su retención y respaldo.

4. Retención propuesta. Propongo conservarla 12 meses (los primeros 90 días disponibles para consulta rápida y el resto archivada y cifrada). Criterio: muchos incidentes se detectan semanas o meses después, y una auditoría anual necesita cubrir todo el periodo. Además, la bitácora contiene datos personales (nombres, RFC, IPs), por lo que no conviene guardarla indefinidamente por el principio de minimización. El plazo final lo deben confirmar Legal/Cumplimiento según la normativa aplicable.

5. Actividad 17 — Cronología y respuestas a Dirección

La cronología completa (20 eventos con fecha, usuario, tipo, resultado y fuente) está en evidencias/15-cronologia.md. Resumen de las respuestas:

Pregunta de Dirección	Respuesta	Evidencia
¿Quién cambió el RFC?	Primer cambio (Act. 3): no hay evidencia. Act. 12: app_ventas vía app-ventas-web, 127.0.0.1, 19:16:42. Act. 14: postgres por socket local, 19:46:11, sin fila de auditoría.	Auditoría id_evento=1; bitácora PID 20674 y PID 20789
¿Quién cambió el teléfono?	app_ventas, app-ventas-web, 15:27:00, cliente 3, nuevo valor 6679990000. Valor anterior: sin evidencia.	Bitácora PID 19100
¿Hubo intentos de acceso fallidos?	Sí, cuatro (12:29:55 y 12:30:05) por User … has no password assigned: falla de configuración, no adivinanza de contraseñas.	Bitácora PIDs 17593, 17594, 17606, 17607
¿Qué valor tenía el RFC antes de cada cambio?	…XYZ antes del cambio de las 19:16 (auditoría 1). Antes del de las 19:46: no registrado (podría inferirse ZZZ, pero es una inferencia).	Auditoría y bitácora
Huecos de evidencia
Antes de las 13:56:48 no se registraban los accesos exitosos (log_connections estaba apagado).
Antes de las 15:26:54 log_statement = ddl no registraba DML.
Los SELECT nunca se registran con mod (lo que leyó soporte_ana no consta).
14:59:09–14:59:14: 30 conexiones recibidas sin autenticación ni desconexión, sin evidencia de su resultado.
19:46:11: cambio de RFC sin fila de auditoría (disparador deshabilitado).
No hay evidencia de que el reinicio por logging_collector = on haya quedado registrado.
Solo se identifican roles, no personas reales.