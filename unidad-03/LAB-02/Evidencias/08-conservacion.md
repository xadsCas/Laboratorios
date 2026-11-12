# Evidencia 08 — Conservación: exportar antes de perder

**Actividad 8 · LAB-02**

## Comandos ejecutados

Exportar `system.profile` (desde `LAB-02/`):

```bash
mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'EJSON.stringify(db.system.profile.find({}, { op: 1, ns: 1, user: 1, client: 1, appName: 1, ts: 1, "command.q": 1, "command.u": 1 }).toArray(), null, 2)' > evidencias/system-profile.json
```

Exportar la bitácora (memoria de `getLog`):

```bash
mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'db.adminCommand({ getLog: "global" }).log.join("\n")' > evidencias/bitacora-mongod.log
```

Hashes:

```bash
sha256sum evidencias/system-profile.json evidencias/bitacora-mongod.log > evidencias/hashes.sha256
```

## Resultado observado

| Archivo | Tamaño | Contenido | SHA-256 |
|---|---|---|---|
| `system-profile.json` | 601 bytes | 2 documentos (`update` de `app_ventas@comercial`; `command` de `admin@admin`) | `6f8ce3b5ca893bb8d6ed548f958b3a2e5ec5bc65aaa9029c6f8d37e600870277` |
| `bitacora-mongod.log` | 207 805 bytes | 522 eventos, del arranque (2026-11-11 22:24 local) hasta 2026-11-12 00:11:19 | `232ddf7116db860b5b252a866e159615d360b22aaa934aa27e76d59d240f9ab5` |

Los hashes están en `hashes.sha256` y se verifican con `sha256sum -c evidencias/hashes.sha256`.

Observación: la exportación de `getLog` contiene 522 eventos, menos que el máximo de 1024 que conserva la memoria; por eso en esta práctica el búfer **no** había descartado eventos y empieza en el arranque del servidor.

### Lo que NO está evidenciado (pendiente)

## Respuestas

**1. Menciona tres formas en que la evidencia del perfilador o de la bitácora puede perderse sin que nadie la borre deliberadamente.**
1. `system.profile` es una colección **limitada** de 1 MB: al llenarse, sobrescribe los documentos más antiguos sin avisar.
2. El **reinicio** del servidor: el nivel del perfilador vuelve a 0 (deja de registrar) y la memoria de `getLog` se vacía.
3. La **rotación o el borrado** del archivo de bitácora (por ejemplo, `logrotate` sin retención suficiente) o un disco lleno que impide seguir escribiendo.

**2. ¿Por qué el tamaño de 1 MB de `system.profile` es un problema de conservación y no solo de espacio?**
Porque lo que se pierde no es espacio libre sino **evidencia**: con nivel 2, el megabyte se llena en poco tiempo y los eventos más antiguos —que pueden ser justo los de un incidente aún no detectado— se sobrescriben sin que nadie lo note. La conservación exige exportar de forma periódica y externa; ampliar el espacio no resuelve que la retención sea implícita e incontrolada.

**3. ¿Por qué `getLog` sirve para interpretar pero no para conservar?**
Porque devuelve solo los 1024 eventos más recientes que el servidor guarda **en memoria**; esa memoria se vacía al reiniciar y no ofrece historia completa ni garantías de integridad. Sirve para consultar rápido; para conservar se necesita el archivo de bitácora (`systemLog.path`) y copias exportadas con su hash.
