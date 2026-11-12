# Evidencia 01 — Edición de MongoDB y limitación de la auditoría

**Actividad 1 · LAB-02 Trazabilidad en MongoDB Community**

## Comandos ejecutados (sesión del DBA)

```js
db.version()
db.adminCommand({ buildInfo: 1 }).modules
db.serverCmdLineOpts().parsed
```
## Resultado observado

Captura: ![Edición y configuración](01-.png)

| Dato | Valor observado | Fuente |
|---|---|---|
| Versión | `8.0.38` | `db.version()` (captura 01) |
| `modules` | `[]` (sin `enterprise`) | línea *Build Info* de `bitacora-mongod.log` |
| Archivo de configuración | `/etc/mongod.conf` | `serverCmdLineOpts().parsed.config` |
| Red | `bindIp: 127.0.0.1`, `port: 27017` | ídem |
| Datos | `/var/lib/mongodb` | ídem |
| Bitácora | `systemLog.destination: file`, `path: /var/log/mongodb/mongod.log`, `logAppend: true` | ídem |
| `security` | **No aparece** en `parsed` | ídem |

**1. ¿Qué edición estás usando? ¿Qué evidencia lo demuestra?**
MongoDB **Community Edition 8.0.38**. La evidencia es que `buildInfo.modules` está vacío (`modules: []`); en Enterprise incluiría `"enterprise"`. Además, en la configuración no existe ninguna opción de auditoría (`auditLog`, `--auditDestination`).

**2. ¿A dónde escribe tu servidor su bitácora? ¿Cómo lo sabes?**
A un archivo: `/var/log/mongodb/mongod.log`. Lo sé porque `db.serverCmdLineOpts().parsed.systemLog` muestra `path: '/var/log/mongodb/mongod.log'`.

**3. Según REF-U3-04, ¿qué cuatro categorías de eventos registraría la auditoría nativa?**
(1) cambios de esquema (DDL); (2) eventos de conjuntos de réplicas y clústeres fragmentados; (3) autenticación y autorización; (4) operaciones CRUD (requiere `auditAuthorizationSuccess: true`).

**4. ¿Qué tendría que evaluar una organización antes de licenciar Enterprise o migrar a Atlas solo para obtener auditoría?**
- Costo de licencia/suscripción frente al riesgo que se quiere cubrir.
- Esfuerzo y riesgo de la migración (compatibilidad, ventanas de mantenimiento, cambios operativos).
- Que la auditoría de Atlas está limitada a clústeres de nivel M10 o superior (REF-U3-04).
- Impacto en desempeño de auditar CRUD y volumen de eventos a almacenar.
- Destino y conservación de los eventos (consola, syslog, archivo JSON/BSON) y su integración con el SIEM.
- Si los controles compensatorios en Community (privilegios mínimos, instantáneas, exportación externa) bastan para el nivel de riesgo.

**Conclusión:** la auditoría nativa **no existe** en esta edición; todo lo que sigue en el laboratorio es trazabilidad parcial (perfilador + bitácora), no auditoría.
