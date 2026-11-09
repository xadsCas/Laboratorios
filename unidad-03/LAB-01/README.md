Laboratorio 1 — Bitácoras y auditoría del dato (PostgreSQL)

Materia: Administración de Bases de Datos (DBA) · Unidad III Autor: (nombre y matrícula) Escenario: Comercializadora Norte S.A. de C.V. — un cambio de RFC en la tabla clientes no pudo atribuirse a nadie. El laboratorio configura la bitácora de PostgreSQL y una auditoría a nivel de dato para poder responder quién, cuándo, desde dónde, qué cambió y cuál era el valor anterior.

Qué se hizo
Parte	Actividades	Resultado
A. Bitácora del servidor	1–9	Colector activo, vista dba.bitacora, registro de conexiones, prefijo con usuario/base/aplicación/cliente y log_statement en ddl → mod
B. Auditoría del dato	10–17	Tabla auditoria.cambios_clientes, función y disparador SECURITY DEFINER, pruebas de manipulación, exportación con hash y cronología del incidente
C. Opcional	18–19	Sin evidencia en esta entrega (pgaudit)
Estructura del repositorio
text
LAB-01/
├── README.md                  ← este archivo
├── informe.md                 ← informe completo: análisis, respuestas y conclusiones
├── sql/                       ← scripts ejecutados, en orden
│   ├── 01-colector-y-vista.sql
│   ├── 02-configuracion-bitacora.sql
│   ├── 03-privilegios-estructura.sql
│   ├── 04-esquema-auditoria.sql
│   ├── 05-funcion-disparador.sql
│   └── 06-campos-modificados.sql
└── evidencias/                ← comandos, resultados, capturas y respuestas por actividad
    ├── 01 … 15-*.md           (una por actividad)
    ├── funcion-disparador.md  (Actividad 11)
    ├── bitacora-lab01.log     ← bitácora exportada (contraseña sustituida por <REDACTED>)
    ├── bitacora-lab01.sha256  ← hash SHA-256 de la bitácora exportada
    └── *.png                  (capturas)
Entorno
PostgreSQL 16 en Ubuntu sobre WSL (clúster 16/main, servicio postgresql@16-main, puerto 5433), base comercial.
Roles: postgres (administrador), app_ventas (SELECT/UPDATE sobre clientes), soporte_ana (SELECT).
Zona horaria del servidor: America/Mazatlan.
Cómo reproducirlo
Iniciar PostgreSQL en WSL y cargar la base comercial, la tabla clientes y los roles (sección de preparación de la guía).
Ejecutar como administrador, en orden, los scripts de sql/:
bash
   sudo -u postgres psql -p 5433 -d comercial -P pager=off
01: activar logging_collector y reiniciar el servicio (sudo systemctl restart postgresql@16-main); crear dba.bitacora.
02: log_connections, log_disconnections, log_line_prefix, log_statement y pg_reload_conf().
03: cambios de privilegios y estructura (ver la advertencia de seguridad abajo).
04–06: esquema auditoria, función/disparador y consulta de campos modificados.
Los intentos de las aplicaciones (app_ventas, soporte_ana) se hicieron con psql por TCP (127.0.0.1:5433); los comandos exactos están en cada archivo de evidencias/.
Verificar la bitácora exportada: sha256sum -c evidencias/bitacora-lab01.sha256.
Índice de evidencias
#	Actividad	Archivo
1	Configuración inicial	evidencias/01-configuracion-inicial.md
2	Colector y vista	evidencias/02-colector.md
3	Incidente sin bitácora	evidencias/03-incidente-sin-bitacora.md
4	Configurar la bitácora	evidencias/04-configuracion-bitacora.md
5	Accesos exitosos y fallidos	evidencias/05-accesos.md
6	Privilegios y estructura	evidencias/06-privilegios-estructura.md
7	ddl frente a mod	evidencias/07-modificaciones.md
8	Errores y operaciones rechazadas	evidencias/08-errores.md
9	pg_stat_activity	evidencias/09-pg-stat-activity.md
10	Diseño de la tabla de auditoría	evidencias/10-diseño-auditoria.md
11	Función y disparador	evidencias/funcion-disparador.md, evidencias/11-incidente-auditado.md
12	Incidente auditado	evidencias/11-incidente-auditado.md
13	Altas y bajas	evidencias/12-altas y bajas.md
14	Manipulación de la auditoría	evidencias/13-manipulacion.md
15	Límites, lecturas y volumen	evidencias/14-limites.md
16	Exportar y conservar la bitácora	evidencias/bitacora-lab01.log, .sha256, y informe.md
17	Cronología y respuestas a Dirección	evidencias/15-cronologia.md