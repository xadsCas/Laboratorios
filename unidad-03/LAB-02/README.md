# LAB-02 — Trazabilidad en MongoDB Community

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos
**Unidad:** III — Auditoría, trazabilidad y gobierno práctico de datos

Laboratorio sobre los mecanismos de trazabilidad que **sí** existen en MongoDB Community (perfilador y bitácora de `mongod`), sus límites reales y un control compensatorio para cambios de privilegios. La auditoría nativa es de Enterprise/Atlas y **no existe en esta edición**.

## Entorno y despliegue (Anexo A)

| Elemento | Valor |
|---|---|
| Forma de despliegue | Instalación **nativa con paquetes** en Ubuntu sobre **WSL** (equipo `Xads`) |
| Servidor | MongoDB **Community 8.0.38** (`buildInfo.modules: []`) |
| Cliente | `mongosh 2.14.2` |
| Archivo de configuración | `/etc/mongod.conf` |
| Datos | `/var/lib/mongodb` |
| Bitácora | `/var/log/mongodb/mongod.log` (`systemLog.destination: file`, `logAppend: true`) |
| Red | `127.0.0.1:27017` |
| Zona horaria de las evidencias | Culiacán, UTC-6 (la bitácora usa hora local; `system.profile` usa UTC) |
| Reinicio del servicio | `sudo systemctl restart mongod` (o `sudo service mongod restart` si WSL no usa systemd) |

### Desviaciones respecto a la guía

1. **Versión 8.0.38** en lugar de 7.0.x. Los comandos y la forma de las salidas fueron equivalentes en lo practicado.
2. **Autorización no habilitada al arrancar el servidor:** `serverCmdLineOpts().parsed` no muestra la sección `security` (ver `evidencias/01-edicion-y-limitacion.md`), a diferencia de lo que la guía da por hecho (Unidad II). Las sesiones se autenticaron con usuario y contraseña, por lo que `user` aparece en el perfilador y en la bitácora.

## Sesiones usadas

| Sesión | Cadena de conexión |
|---|---|
| DBA | `mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"` |
| Aplicación | `mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web"` |

Las contraseñas de práctica se sustituyeron por `<REDACTED>` en todos los documentos.

## Estructura

```
LAB-02/
├── README.md
├── informe.md
├── evidencias/
│   ├── 01-edicion-y-limitacion.md
│   ├── 02-incidente-sin-perfilado.md
│   ├── 03-perfilador.md
│   ├── 04-filtro.md
│   ├── 05-accesos-mongod.md
│   ├── 06-correlacion.md
│   ├── 07-privilegios-control-compensatorio.md
│   ├── 08-conservacion.md
│   ├── 09-comparacion.md
│   ├── 10-respuesta-direccion.md
│   ├── system-profile.json
│   ├── bitacora-mongod.log
│   ├── hashes.sha256
│   └── capturas/            (captura-01 … captura-07)
└── scripts/
    └── comandos-mongosh.js
```

