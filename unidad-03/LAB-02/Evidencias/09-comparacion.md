# Evidencia 09 — Comparación de los tres escenarios

**Actividad 9 · LAB-02**

Leyenda: **Sí** (observado) · **Parcial** (se explica) · **No** · **Documentado, no practicado** (solo según REF-U3-04, sin práctica).

La columna de **PostgreSQL** se basa en el LAB-01; ⚠️ **verifícala contra tus propias evidencias del LAB-01** antes de entregar (aquí se llenó con los mecanismos que la guía menciona: bitácora del servidor con `log_statement = 'mod'` y disparador de auditoría).

| Evento auditable | PostgreSQL (bitácora + disparador) | MongoDB Community (perfilador + bitácora) | MongoDB Enterprise/Atlas (auditoría nativa) |
|---|---|---|---|
| Acceso exitoso | Sí (bitácora de conexiones, según LAB-01) | **Sí**: `Successfully authenticated` con `user`, `db`, `client`, mecanismo y `appName` | Documentado, no practicado (categoría autenticación/autorización) |
| Acceso fallido | Sí (bitácora, según LAB-01) | **Sí**: `Failed to authenticate` (2 intentos, 3 líneas) con motivo (`UserNotFound`, `storedKey mismatch`) | Documentado, no practicado |
| Cambio de privilegios | Parcial/Sí si se registran sentencias DDL (`GRANT`); confirmar en LAB-01 | **No**: 0 evidencias en perfilador y bitácora; solo se detecta *qué* cambió con instantáneas (control compensatorio), no *quién* ni *cuándo* exacto | Documentado, no practicado (autorización) |
| Cambio de estructura | Parcial/Sí según configuración de `log_statement` (DDL); confirmar en LAB-01 | **Parcial**: solo se observó un `CMD: drop` en la bitácora (el `drop` de `system.profile`, 00:01:47.148, `conn43`) sin usuario; no se probó `createCollection`/índices | Documentado, no practicado (cambios de esquema/DDL) |
| Modificación de datos | Sí (`log_statement = 'mod'` y disparador) | **Parcial/Sí**: con perfilador nivel 2 o con filtro (`insert`, `update`, `remove`) queda `user`, `client`, `appName`, `ts` y el comando. Depende de tenerlo activado y se pierde por sobrescritura | Documentado, no practicado (CRUD con `auditAuthorizationSuccess: true`) |
| Valor anterior del dato | Sí (disparador con `OLD`) | **No**: solo se guarda el valor nuevo (`$set`); el anterior no queda | No verificado ni practicado |
| Lectura de datos sensibles | No con `log_statement = 'mod'` (no registra `SELECT`) | **Parcial**: el nivel 2 registra el `find` con filtro y proyección, pero no el contenido devuelto; con el filtro de la Actividad 4 las lecturas se pierden | Documentado, no practicado (CRUD) |
| Cambio de configuración del registro | Parcial (depende de cómo se cambie; confirmar en LAB-01) | **Sí**: `Profiler settings changed` con `from`/`to`, pero **sin usuario**; se atribuye por correlación de `ctx` | Documentado, no practicado |

## Conclusión de la comparación

MongoDB Community permite reconstruir bastante **qué** pasó (conexiones, comandos con el perfilador activo, cambios del propio perfilador), pero tiene tres huecos graves: no registra cambios de privilegios, no guarda el valor anterior y el perfilador es volátil (1 MB y nivel que se pierde al reiniciar). La auditoría nativa de Enterprise/Atlas es la que cubre eventos de seguridad como autenticación, autorización y DDL de forma deliberada; en este laboratorio solo se documentó, no se practicó.
