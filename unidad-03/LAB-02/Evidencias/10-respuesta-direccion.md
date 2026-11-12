# Evidencia 10 — Respuesta a Dirección

**Actividad 10 · LAB-02**

## 1. ¿Quién cambió el RFC de María García?

**Actividad 2 (`rfc` → `GAMA780912XXX`):** **No hay evidencia con esta edición.**
*Motivo técnico:* el perfilador estaba en nivel 0 y la bitácora de `mongod` no registra operaciones CRUD. Lo único demostrable es que a las 23:39:16 (hora local) el usuario `app_ventas` se autenticó desde `127.0.0.1` con la aplicación `app-ventas-web` (`conn23`–`conn26`); es compatible con el cambio, pero una conexión no prueba una operación.

**Actividad 3 (`rfc` → `GAMA780912XYZ`):** el cambio se ejecutó con la sesión de la aplicación a las 23:59:44 (`conn47`–`conn49`, `app_ventas`, `app-ventas-web`, según la bitácora) con el perfilador en nivel 2, que registra `user`, `client`, `appName` y `ts`.

## 2. ¿Cuándo y desde qué aplicación?

- **Actividad 2:** no se puede demostrar cuándo ocurrió la operación (*No hay evidencia con esta edición*); la sesión de la aplicación se autenticó a las 23:39:16.
- **Actividad 3:** la sesión de la aplicación ocurrió a las 23:59:44 (hora local, UTC-6); aplicación `app-ventas-web`. Hora exacta de cada operación: ⚠️ pendiente, depende del `ts` de `system.profile`.

## 3. ¿Qué valor tenía antes?

**No hay evidencia con esta edición.** `system.profile` guarda solo el comando con el valor **nuevo** (`$set`) y la bitácora no registra datos; ninguno conserva el valor anterior. Para saberlo haría falta un respaldo previo, un disparador o un historial de cambios fuera de estos mecanismos.

## 4. ¿Cambió alguien los privilegios de `app_ventas`?

- **Sí cambiaron:** la instantánea de las `06:05:34.549Z` muestra `readWrite@comercial`; la de las `06:06:14.512Z` muestra además `dbAdmin@comercial`.
- **¿Quién? No hay evidencia con esta edición.** Ni `system.profile` ni la bitácora contienen el `grantRolesToUser` (0 coincidencias en los archivos exportados). El campo `tomada_por` identifica a quien tomó la instantánea (`admin`), no a quien otorgó el rol.
- **¿Cuándo? Solo en una ventana** de ≈ 40 s entre las dos instantáneas (00:05:34 a 00:06:14 hora local).
