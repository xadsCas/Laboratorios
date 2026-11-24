# Expediente de auditoría interna — Base `comercial`

**Organización:** Comercializadora Norte S.A. de C.V. · **Materia:** DBA, Unidad III · **LAB-03**
**Fecha de integración:** 2026-11-23 · **Responsable del expediente:** `<Tu nombre y matrícula>`


## 1. Alcance

| Elemento | Detalle | Fuente |
|---|---|---|
| Motor revisado | PostgreSQL 16.15 (paquete pgdg sobre Ubuntu), escuchando en `127.0.0.1:5433` y socket Unix | E5 líneas 1–3 |
| Base y esquemas | `comercial`: `public`, `auditoria`, `dba`, `gobierno` (creado en esta práctica) | `capturas/01`, E5 línea 51 |
| Autenticación local | `peer` (`pg_hba.conf` línea 118) | E5 línea 74 |
| MongoDB 7 | Referencia del LAB-02. **Evidencia E6 no integrada en este paquete** (ver §9) | `evidencias/E6-mongodb/LEEME.md` |
| Periodo revisado | Eventos de auditoría de datos desde **2026-11-08** (E4); bitácora de PostgreSQL desde **2026-11-23 23:27:09** hasta 23:47:25 | E4, E5 |
| Solicitudes de auditoría atendidas | A1–A6 (ver secciones indicadas abajo) | Guía §5 |

---

## 2. Configuración de auditoría (A3)

| Mecanismo | Estado verificado | Evidencia |
|---|---|---|
| Colector de bitácoras | `logging_collector = on` | E1 |
| Conexiones y desconexiones | `log_connections = on`, `log_disconnections = on` | E1; ejemplos en E5 líneas 25, 72 |
| Qué sentencias se registran | `log_statement = mod`: **todo el DDL y toda modificación de datos**; **no** registra `SELECT` | E1; E5 líneas 28, 42–47, 51–69 |
| Formato de línea | `%m [%p] user=%u db=%d app=%a client=%h` (momento, proceso, usuario, base, aplicación, origen) | E1 |
| Errores | `log_min_error_statement = error` (valor por defecto): guarda el texto de la sentencia que falló | E1; E5 líneas 31–47, 48–50 |
| Auditoría del dato | Disparador `trg_auditoria_clientes` **habilitado** (`tgenabled = O`) sobre `clientes`, que alimenta `auditoria.cambios_clientes` | E3; E4 |
| Privilegios vigentes | `app_ventas`: SELECT, UPDATE; `soporte_ana`: SELECT, ambos sobre `public.clientes` | E2 |
| MongoDB | Perfilador, bitácora de `mongod` e instantáneas de privilegios (LAB-02) | |

---

## 3. Bitácora interpretada (A3, A5)

Formato del LAB-01, Actividad 17. Cinco eventos distintos.

### Evento 1 — Incidente del RFC de María García (modificación de un dato sensible por una aplicación)

| Campo | Interpretación |
|---|---|
| **Quién** | Rol `app_ventas` (`usuario_sesion`) |
| **Cuándo** | 2026-11-08 19:16:42.633577 (UTC−6) |
| **Desde dónde** | Aplicación `app-ventas-web` (`aplicacion`) |
| **Qué ocurrió** | `UPDATE` sobre el cliente `id_cliente = 3` |
| **Tipo de evento** | Modificación de datos (DML) sobre un dato sensible, por una cuenta de aplicación |
| **Qué prueba** | Que el disparador registró el cambio con usuario, aplicación y momento; que `app_ventas` puede modificar `clientes` (E2) |
| **Qué NO prueba** | El motivo, la autorización ni el valor anterior y posterior (E4 omite `valores_*` a propósito); ni que el cambio fuera indebido sin una política escrita (POL-01, POL-05) |
| **Fuente** | E4 `id_evento = 1`; E2 |


### Evento 2 — Carga de registros con datos erróneos (dos fuentes que se corroboran)

| Campo | Interpretación |
|---|---|
| **Quién** | `postgres` (administrador), proceso 1163 |
| **Cuándo** | 2026-11-23 23:34:58.603 (bitácora) = 23:34:58.60344 (auditoría) |
| **Desde dónde** | `psql`, `client=[local]` (socket Unix, mismo servidor) |
| **Qué ocurrió** | `INSERT` de dos clientes (ids 7 y 8) con errores de calidad (C1–C7) |
| **Tipo de evento** | Modificación de datos (DML) |
| **Qué prueba** | Quién, cuándo y desde qué herramienta; la correspondencia entre la línea 28 de la bitácora y los eventos 9 y 10 de `auditoria.cambios_clientes` demuestra que el disparador y `log_statement = mod` funcionaban a la vez |
| **Qué NO prueba** | Que los datos fueran correctos ni que el alta estuviera autorizada: no hay folio |
| **Fuente** | E5 línea 28; E4 `id_evento` 9 y 10; `evidencias/01-calidad.md` |

### Evento 3 — Cambio de estructura con folio (`canal_alta`)

| Campo | Interpretación |
|---|---|
| **Quién** | `postgres`, proceso 1163 |
| **Cuándo** | `INSERT` del folio: 23:42:01.006 (línea 64); `ALTER TABLE`: 23:42:01.024 (línea 68); `COMMENT`: 23:42:01.029 (línea 69) |
| **Desde dónde** | `psql`, `client=[local]` |
| **Qué ocurrió** | Se registró la solicitud CAM-2026-014 y 18 ms después se agregó la columna `canal_alta` a `clientes` |
| **Tipo de evento** | Cambio de estructura (DDL) en producción |
| **Qué prueba** | Que existe un registro de autorización que cubre el cambio y que el cambio ocurrió dentro de la ventana (captura 05: `dentro_de_ventana = t`) |
| **Qué NO prueba** | Que el Comité de cambios aprobara **antes** del cambio: el registro lo creó el mismo usuario que ejecutó el cambio, con `fecha_aprobacion = now() - 1 day` (H-04) |
| **Fuente** | E5 líneas 64, 68, 69; `evidencias/06-conciliacion.md` |

### Evento 4 — Dos conexiones rechazadas por autenticación `peer` (evento de seguridad)

| Campo | Interpretación |
|---|---|
| **Quién** | Identidad del sistema operativo `ernes` (23:43:26.874, proceso 1299) y luego `root` (23:45:21.674, proceso 1334), ambos pidiendo entrar como `postgres` |
| **Cuándo** | 2026-11-23, 23:43:26 y 23:45:21 |
| **Desde dónde** | `client=[local]` (socket Unix); regla de `pg_hba.conf` línea 118 (`local all postgres peer`) |
| **Qué ocurrió** | `FATAL: Peer authentication failed for user "postgres"`: la identidad del SO no coincidía con el usuario solicitado. Poco después hay conexiones de `postgres` correctas (líneas 85–101) |
| **Tipo de evento** | Fallo de autenticación (seguridad) |
| **Qué prueba** | Que el control `peer` funcionó: rechazó dos intentos con identidad distinta a `postgres`; que quedó registrado el usuario solicitado y el real |
| **Qué NO prueba** | Quién estaba detrás ni su intención. El patrón (usuario normal y luego `root` intentando `psql -U postgres`, seguido de conexiones correctas) es **compatible con un error del operador** al invocar `psql`; el registro no permite descartar ni confirmar otra cosa. No hubo acceso a datos en los intentos rechazados |
| **Fuente** | E5 líneas 74–81 (y 85–101) |

### Evento 5 — Arranque del servidor tras apagado de cuatro días (evento de sistema)

| Campo | Interpretación |
|---|---|
| **Quién** | Proceso principal de PostgreSQL (`user=` vacío) |
| **Cuándo** | Arranque 2026-11-23 23:27:09.948; el servidor se había apagado el 2026-11-19 00:25:40 |
| **Desde dónde** | Servidor local |
| **Qué ocurrió** | PostgreSQL 16.15 inicia y queda listo en 80 ms (línea 5) |
| **Tipo de evento** | Operación de la instancia |
| **Qué prueba** | Que no hubo actividad del servidor entre el 19 y el 23 de noviembre; que el archivo de bitácora exportado comienza en este arranque |
| **Qué NO prueba** | Qué ocurrió antes (incluido el 2026-11-08, E4 ids 1–8): esos eventos no tienen su línea de bitácora en este archivo (H-02) |
| **Fuente** | E5 líneas 1–5 |

---

## 4. Elementos de gobierno (A1, A2)

- **Responsables (A1):** matriz de propietarios, custodios y usuarios en `evidencias/02-responsables.md`.
- **Catálogo (A1):** siete conjuntos de datos de los dos motores, en `evidencias/04-catalogo.md` (`CAT-01` a `CAT-07`).
- **Diccionario (A2):** `evidencias/03-diccionario.md` y `evidencias/diccionario-clientes.csv`; columnas sensibles: `nombre`, `correo`, `telefono`, `rfc`, `edad`, `ciudad`, `codigo_postal`. Estado: 6 de 11 columnas con descripción en el motor al momento de la exportación (pendientes: `telefono`, `ciudad`, `codigo_postal`, `fecha_alta`, `segmento`; script listo en `sql/02-comentarios-diccionario.sql`).

---

## 5. Conservación (A3)

Criterio completo en `evidencias/05-conservacion.md`. Resumen:

| Registro | Periodo propuesto |
|---|---|
| Accesos PostgreSQL y bitácora de `mongod` | 6 meses |
| Cambios de privilegios y estructura | 24 meses *(plazo a confirmar con jurídico)* |
| Modificaciones de datos (`mod`) | 12 meses |
| `auditoria.cambios_clientes` | Metadatos 24 meses; valores antes/después 12 meses y luego anonimizar |
| `system.profile` | Copias exportadas 90 días |
| Instantáneas de privilegios | 24 meses |

---

## 6. Políticas (A4)

| Política | Archivo | Evidencia hoy |
|---|---|---|
| POL-01 Acceso | `politicas/POL-01-acceso.md` | Parcial: E2 muestra privilegios; no hay solicitudes aprobadas ni acta trimestral |
| POL-02 Respaldo | `politicas/POL-02-respaldo.md` | **No existe** (se implementa en la Unidad V) |
| POL-03 Retención | `politicas/POL-03-retencion.md` | Criterio definido (evidencia 05); sin actas de baja porque no ha vencido ningún plazo |
| POL-04 Restauración | `politicas/POL-04-restauracion.md` | **No existe** (Unidad V) |
| POL-05 Datos sensibles | `politicas/POL-05-datos-sensibles.md` | Parcial: modificaciones auditadas (E4, E5); **lecturas no auditadas** |
| POL-06 Cambios en producción | `politicas/POL-06-cambios-produccion.md` | Parcial: `gobierno.solicitudes_cambio` y extracción de DDL; ver H-03, H-04 |

---

## 7. Conciliación de cambios (A5)

Detalle en `evidencias/06-conciliacion.md`. Resultado sobre la bitácora disponible (23:27–23:47 del 2026-11-23):

- **1 cambio de estructura con folio** (CAM-2026-014, `canal_alta`), **con reserva** por el modo en que se creó el registro de autorización (H-04).
- **Cambios de estructura y metadatos sin folio:** `CREATE SCHEMA gobierno`, `REVOKE ALL ON SCHEMA gobierno FROM PUBLIC`, `CREATE TABLE gobierno.solicitudes_cambio` y siete `COMMENT ON` (H-03).
- **No conciliable:** los privilegios y la columna `segmento` que existen hoy no tienen línea de bitácora que los origine (H-02).

---

## 8. Hallazgos

| ID | Hallazgo | Fuente | Severidad | Impacto | Recomendación | Decisión requerida de |
|---|---|---|---|---|---|---|
| H-01 | **Calidad de datos:** duplicado por correo (1, 7), RFC incompleto (7) y ausente (8), correo inválido, edad `-3`, teléfono y CP truncados (8), ciudad con dos escrituras. Los registros siguen en producción sin corregir (no se corrigen por política hasta que el propietario decida) | `01-calidad.md`; capturas 02; E4 ids 9–10 | **Media** | Facturación fallida, comunicaciones perdidas, analítica sesgada | El propietario decide la corrección por registro; después agregar `UNIQUE` sobre `lower(correo)` y `CHECK`s (propuestos, no ejecutados) | Gerencia Comercial |
| H-02 | **Bitácora incompleta para el periodo:** el archivo exportado empieza el 2026-11-23 23:27 (arranque del servidor). No hay líneas del 2026-11-08 (eventos E4 ids 1–8, incluido el incidente del RFC), ni de los `GRANT`/`REVOKE`/`segmento` que originaron los privilegios actuales. Tampoco hay historial de que E1 estuviera vigente antes de hoy | E5 línea 1–5; E4; E2; E1 | **Alta** | No se puede demostrar con la bitácora quién hizo los cambios anteriores; la conciliación solo cubre 20 minutos | Exportar con hash **todos** los archivos de `pg_ls_logdir()` antes de que rote o se reinstale; versionar la configuración de registro; aplicar POL-03 | Responsable de seguridad |
| H-03 | **Cambios de estructura y metadatos sin folio:** `CREATE SCHEMA gobierno`, `REVOKE ALL`, `CREATE TABLE gobierno.solicitudes_cambio` y 7 `COMMENT ON`. Son preparación de la práctica, y el registro de cambios no puede autorizar su propia creación | E5 líneas 42–47, 51–53, 63 | **Media** | Cambios de estructura y de privilegios en producción sin autorización documentada | Regularizar con un folio de implantación de gobierno aprobado por el Comité, y registrar el motivo como excepción | Comité de cambios |
| H-04 | **Autorización retrodatada y creada por el ejecutor:** el folio CAM-2026-014 lo insertó `postgres` 18 ms antes del `ALTER` que autoriza; `fecha_aprobacion = now() - 1 day` y la ventana se calcularon en el mismo acto | E5 líneas 64, 68; `04-registro-cambios.sql` | **Alta** | Un cambio "autorizado" no es demostrable; no hay separación entre quien aprueba y quien ejecuta | POL-06: aprobación registrada por el Comité con fecha real y anterior; el ejecutor solo cita el folio; restringir `INSERT` a `gobierno.solicitudes_cambio` a un rol distinto del DBA | Comité de cambios |
| H-05 | **El administrador puede apagar o borrar la auditoría:** `postgres` es superusuario y puede deshabilitar `trg_auditoria_clientes`, vaciar `auditoria.cambios_clientes` o editar el archivo de bitácora. Hoy la separación de funciones es solo documental | E3; E1; guía §14 | **Alta** | Un administrador malintencionado o descuidado puede borrar su propio rastro | Exportar bitácoras y auditoría fuera del servidor con hash (POL-03); conciliación por persona distinta (POL-06); evaluar una extensión de auditoría y un colector externo | Responsable de seguridad |
| H-06 | **Datos personales en claro en la bitácora:** con `log_statement = mod` el texto de los `INSERT/UPDATE` guarda nombre, correo, teléfono y RFC. También se guardan sentencias fallidas con su texto | E5 líneas 28–30, 31–47 | **Media** | Quien lea la bitácora accede a datos que no vería por `clientes` | Restringir su lectura (POL-05), cifrar en reposo, redactar antes de compartir y fijar 12 meses de conservación | Responsable de seguridad |
| H-07 | **Privilegio excesivo:** `app_ventas` tiene `UPDATE` sobre toda la tabla `clientes`, incluida `rfc`, y es la cuenta del incidente del RFC | E2; E4 `id_evento = 1` | **Media** | Una aplicación puede alterar el RFC sin otra barrera | Pasar a `UPDATE` por columna (solo las que la aplicación necesita) y revisar con el propietario | Gerencia Comercial |
| H-08 | **Dos intentos de entrada como `postgres` con identidad distinta** (`ernes`, `root`), rechazados por `peer` | E5 líneas 74–81 | **Baja** | Sin impacto observado; el control funcionó. Conviene confirmar que fueron del operador | Confirmar con el operador y dejar nota; monitorear fallos repetidos | Responsable de seguridad |
| H-09 | **Conflicto auditoría vs. eliminación:** `auditoria.cambios_clientes` conserva copias de datos de clientes eliminados (p. ej. cliente 6, insertado y eliminado el 2026-11-08) | E4 ids 2–3; diseño del disparador (LAB-01) | **Media** | Se conservan datos personales más allá de la eliminación ordenada por la política de retención | Anonimizar `valores_*` a los 12 meses y conservar los metadatos (POL-03); plazo a confirmar con jurídico | Gerencia Comercial / jurídico |

---

## 9. Limitaciones conocidas y riesgos aceptados (A6)

### Verificado en los laboratorios (con evidencia en este expediente)
- Configuración de registro vigente (E1); privilegios vigentes (E2); disparador habilitado (E3); muestra de auditoría de datos (E4); bitácora de PostgreSQL con hash (E5).
- Correspondencia entre bitácora y auditoría del dato (eventos 9 y 10).
- Diccionario con `COMMENT`, catálogo, registro de cambios y su conciliación parcial.

### Documentado pero no practicado en este expediente
| Limitación | Por qué | Quién debería aceptarla |
|---|---|---|
| **MongoDB Community no tiene auditoría nativa**; la auditoría nativa existe en MongoDB Enterprise (documentada, no practicada). El perfilador y las instantáneas de privilegios son sustitutos parciales. **E6 no está integrada** | Alcance del LAB-02 | Responsable de seguridad y Gerencia Comercial |
| **Las lecturas no se auditan** en PostgreSQL (`log_statement = mod`; sin `pgaudit`) | Decisión de volumen y alcance | Responsable de seguridad |
| **La auditoría puede ser desactivada por el administrador** (H-05) | Superusuario con control total | Responsable de seguridad y dirección |
| **E1 solo es una fotografía de hoy**; no hay historial de configuración | Sin versionado de `postgresql.conf` | Responsable de seguridad |
| **Respaldo y restauración (POL-02 y POL-04) no tienen evidencia**: se implementan en la Unidad V | Fuera del alcance de la unidad | Gerencia Comercial (propietario) |
| **Plazos legales de conservación sin confirmar** | Requieren revisión del área jurídica | Área jurídica |
| **El hash de E5 se calculó después de exportarla** (ver `E5-bitacora-postgresql.sha256`); no demuestra que el archivo estuviera íntegro antes | Limitación general de un hash calculado en el mismo servidor | Responsable de seguridad |
| **El archivo exportado incluye su propia exportación**: E5 termina en la conexión que lo generó (línea 102) | Naturaleza del método (`pg_read_file` sobre el archivo vivo) | Responsable de seguridad |

---

## 10. Índice de evidencias

SHA-256 de los archivos de evidencia (los documentos `.md` y `.sql` se versionan en Git).

| Archivo | SHA-256 |
|---|---|
| `evidencias/E1-configuracion-registro.txt` | `a819be3902ef09da1ec76382b0d15564d02fc86c79ec5d8b12c3590cf628b7f8` |
| `evidencias/E2-privilegios.txt` | `62cf01a945a8ee22d8d504f2ca7ceeaf22d739c62f6a00a2dc70da495372dbbc` |
| `evidencias/E3-disparadores.txt` | `3f1b4fdf71681c2f0b57eef2393bee3097ee15b8f078b769134fb5c88cf3e5bf` |
| `evidencias/E4-muestra-auditoria.txt` | `c27152bedaf8d0320d6b1bb27c6a1c515708ae62f3069cf6e45afd9327951711` |
| `evidencias/E5-bitacora-postgresql.log` | `92b478d68d820c1a22fa97a8f5c97cae5bb77285a0309c042305c0b4dc4b7e9e` |
| `evidencias/capturas/01-preparacion.png` | `dc4ec54ef7573b9d0df2679fb98096f7cebaafab04bdc21c0bcb4cb393cbe87d` |
| `evidencias/capturas/02-verificaciones-calidad.png` | `b02493001d6253de87f2e088f7596e89beb8d774a445fd02ad61a44068b629c0` |
| `evidencias/capturas/03-diccionario.png` | `d74c9b30ff62e2972cbc3c2dc79364c36ffe7fe612dccd965c92ee8c1db14a03` |
| `evidencias/capturas/04-inventario-tablas.png` | `08edf092a8c5e235a9dca6e6172f1e42d033d00341279743ad78ec21fd97d603` |
| `evidencias/capturas/05-registro-cambios-y-bitacora.png` | `0136ec5d433ddfcc2de76518463df416288b65906c61ef9b79b8143c5d74b629` |
| `evidencias/diccionario-clientes.csv` | `0f970c7409e64bf17c5df7811e3fcab607421c47344e4adf2de3abf21885175d` |
    