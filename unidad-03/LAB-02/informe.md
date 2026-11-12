# Informe — LAB-02 Trazabilidad en MongoDB Community

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos · **Unidad III**
**Entorno:** MongoDB Community 8.0.38 en Ubuntu (WSL), `mongosh 2.14.2`
**Fecha de la práctica:** 11–12 de noviembre de 2026 (hora local UTC-6)

---

## 1. Despliegue, edición y limitación

**Despliegue.** Servidor instalado con paquetes en Ubuntu sobre WSL, con configuración en `/etc/mongod.conf`, datos en `/var/lib/mongodb` y bitácora en el archivo `/var/log/mongodb/mongod.log`. Dos sesiones de trabajo: la del DBA (`admin`, rol `root`) y la de la aplicación (`app_ventas`, `readWrite` en `comercial`, `appName=app-ventas-web`).

**Edición verificada.** La edición es **Community 8.0.38**: `db.adminCommand({ buildInfo: 1 }).modules` devolvió `[]` (en Enterprise incluiría `"enterprise"`), y la configuración no contiene ninguna opción de auditoría.

**Qué no existe en Community.** La **auditoría nativa** (`--auditDestination`, registro de DDL, autenticación y autorización, y CRUD con `auditAuthorizationSuccess: true`) solo está en MongoDB Enterprise y en Atlas (M10 o superior), según REF-U3-04. No se simuló ni se presentó como disponible.

**Observaciones del entorno (hechos verificados):**
- La guía fue escrita para 7.0; se usó 8.0.38.
- `serverCmdLineOpts().parsed` **no muestra `security.authorization`**: el servidor arrancó sin la autorización habilitada, a diferencia de lo que supone la guía (Unidad II). Las conexiones se autenticaron con credenciales, por lo que `user` quedó registrado.

## 2. Perfilador

**Configuración.** Se activó a nivel de la base `comercial` con `db.setProfilingLevel()`: nivel 2 (todas las operaciones) en la Actividad 3, y después nivel 1 con el filtro `{ op: { $in: ["insert", "update", "remove"] } }` (Actividad 4). El nivel puesto así **no es persistente** (se pierde al reiniciar; la opción permanente es `operationProfiling.mode` en `/etc/mongod.conf`, no aplicada).

**Interpretación.** Cada documento de `system.profile` identifica `op`, `ns`, `command`, `user` (con la base: `app_ventas@comercial`), `client`, `appName` y `ts`. Con el nivel 1 y filtro quedó el `update` del teléfono de `_id: 1` por `app_ventas@comercial`, aplicación `app-ventas-web`, `2026-11-12T06:02:08.774Z`. Con el nivel 2 se vio además la lectura (`find` con filtro `ciudad: "Culiacán"`).

**Costo y riesgos.**
- El perfilador está diseñado para analizar desempeño, no para auditar; el nivel 2 degrada el rendimiento y consume disco.
- `system.profile` es una colección limitada de 1 MB: la evidencia se sobrescribe sola.
- Guarda los filtros en texto claro, que pueden contener datos personales.
- Solo guarda el valor **nuevo** de un `update`, nunca el anterior, ni el contenido de un documento eliminado.
- El filtro reduce volumen y datos personales, pero **pierde las lecturas**.

## 3. Bitácora de `mongod`

**Dónde se escribe.** En el archivo `/var/log/mongodb/mongod.log`; desde `mongosh`, `getLog` devuelve los 1024 eventos más recientes en memoria (en esta práctica se exportaron 522 eventos).

**Accesos.** La bitácora distingue con claridad un acceso exitoso (`Successfully authenticated`, con usuario, base, cliente, mecanismo y `appName`) de uno fallido (`Failed to authenticate`, con `result` y `error`): contraseña incorrecta (`storedKey mismatch`, resultado 18) frente a usuario inexistente (`UserNotFound`, resultado 11). Los dos intentos fallidos produjeron tres líneas (uno de ellos, dos): hay que contar intentos, no líneas. El nombre de aplicación de esos intentos fue `mongosh 2.14.2` porque no incluyeron `appName`.

**Cambios de configuración.** Cada cambio del perfilador queda como `Profiler settings changed` (valores `from` y `to`) pero **sin usuario**. Se atribuyó por correlación de `ctx`: el cambio de las 00:01:47.190 (`conn43`) corresponde a la autenticación de `admin` en `conn43` a las 23:57:31.332. La correlación es válida porque hay un único arranque del servidor en el periodo.

**Límite de lo que no registra.** La bitácora no registró ninguna operación CRUD: en la Actividad 2 mostró que la aplicación se conectó y se autenticó, pero no qué cambió.

## 4. Privilegios

**Evidencia disponible en Community.** Ninguna directa: en los archivos exportados hay **0** referencias a `grantRoles` o `revokeRoles`, ni en la bitácora (522 eventos) ni en `system-profile.json`.

**Control compensatorio.** Instantáneas de privilegios en `auditoria.instantaneas_privilegios`. La comparación de las dos instantáneas (`06:05:34.549Z` y `06:06:14.512Z`) muestra que `app_ventas` pasó de `readWrite` a `readWrite` + `dbAdmin` en `comercial`.

**Su límite.** Responde *si* cambió y *qué* se agregó, pero **no quién** (el campo `tomada_por` es quien tomó la instantánea) **ni cuándo exactamente** (solo una ventana de ≈ 40 s). Es un control compensatorio, no auditoría.

## 5. Conservación

**Riesgos observados.** Los de la Actividad 3 se perdieron al ejecutar `system.profile.drop()` sin exportar antes (la guía lo advierte), lo que ilustra la fragilidad de la evidencia en el perfilador. Otros riesgos: sobrescritura de la colección limitada de 1 MB, pérdida del nivel y de la memoria de `getLog` al reiniciar, y rotación o borrado del archivo de bitácora.

**Exportación realizada.** `system-profile.json` (601 bytes) y `bitacora-mongod.log` (522 eventos), con hash SHA-256 en `hashes.sha256`.

## 6. Comparación

| Evento | PostgreSQL | MongoDB Community | Enterprise/Atlas |
|---|---|---|---|
| Acceso exitoso / fallido | Sí | **Sí** (bitácora) | Documentado, no practicado |
| Cambio de privilegios | Parcial/Sí (DDL) | **No** (solo instantáneas: qué, no quién) | Documentado, no practicado |
| Cambio de estructura | Parcial/Sí | **Parcial** (se observó un `drop`, sin usuario) | Documentado, no practicado |
| Modificación de datos | Sí | **Parcial/Sí** (perfilador activo) | Documentado, no practicado |
| Valor anterior | Sí (disparador) | **No** | No verificado |
| Lectura de datos sensibles | No con `'mod'` | **Parcial** (nivel 2) | Documentado, no practicado |
| Cambio de config. del registro | Parcial | **Sí**, sin usuario (correlación por `ctx`) | Documentado, no practicado |

## 7. Recomendación

**Para una organización que necesite auditar cambios de privilegios en MongoDB**, recomiendo **MongoDB Enterprise o Atlas (M10 o superior) con auditoría nativa**, porque es el único mecanismo evaluado que cubre de forma deliberada los eventos de autenticación y autorización, algo que en Community no se pudo registrar. Antes de decidir, debe evaluarse costo, migración e impacto en desempeño.

Mientras tanto, o si la organización decide permanecer en Community, un esquema compensatorio razonable (no equivalente a auditoría):
- Restringir quién puede ejecutar cambios de privilegios (privilegios mínimos, cuentas nominales, sin cuentas compartidas) y exigir un ticket para cada cambio.
- Tomar instantáneas de privilegios de forma automática (por ejemplo, diarias y antes y después de cada ventana de cambios), con comparación automática, alertas y copia a un almacenamiento externo de solo escritura.
- Habilitar `systemLog` a archivo con retención y enviarlo a un SIEM; vigilar `Profiler settings changed` y los accesos fallidos.
- Usar el perfilador solo con filtros, exportarlo con frecuencia y tratar `system.profile` como dato sensible.
- Habilitar la autorización (`security.authorization: enabled`) en todos los servidores.

### Hechos verificados frente a supuestos

| Tipo | Afirmación |
|---|---|
| **Verificado** | La edición es Community 8.0.38 (`modules: []`). |
| **Verificado** | El servidor arrancó sin `security` en la configuración. |
| **Verificado** | Con el perfilador apagado no hay rastro de la operación (0 coincidencias). |
| **Verificado** | Con nivel 2 o con filtro, `system.profile` registra `user`, `client`, `appName`, `ts` y el comando, pero no el valor anterior. |
| **Verificado** | Los accesos fallidos y exitosos quedan en la bitácora y el cambio de configuración del perfilador se atribuye por `ctx`. |
| **Verificado** | El cambio de privilegios no aparece en perfilador ni bitácora; las instantáneas lo detectan pero no lo atribuyen. |
| **Supuesto** | Que la auditoría nativa de Enterprise/Atlas registraría los cambios de privilegios con autor y hora (según la documentación de REF-U3-04; no se practicó). |
| **Supuesto** | Que el esquema compensatorio sea suficiente; depende del riesgo y debe validarse en la organización. |
| **Supuesto** | Que los comportamientos observados en 8.0.38 sean los mismos en 7.0 (la guía los describe equivalentes). |

---
