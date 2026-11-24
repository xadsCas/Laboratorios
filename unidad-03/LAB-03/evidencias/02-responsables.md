# Evidencia 02 — Propietarios, custodios y usuarios (Actividad 2)

Amplía la matriz de gobierno de la Unidad II (LAB-03, Actividad 11) con las figuras de la guía §4.2 y con los objetos creados en esta unidad.

| Conjunto de datos | Propietario | Custodio | Usuarios autorizados | Quién aprueba accesos | Quién aprueba correcciones |
|---|---|---|---|---|---|
| `comercial.public.clientes` (PostgreSQL) | Gerencia Comercial | DBA | `app_ventas` (SELECT, UPDATE) y `soporte_ana` (SELECT), según E2 | Gerencia Comercial | Gerencia Comercial |
| `auditoria.cambios_clientes` (PostgreSQL) | Auditoría interna *(propuesto)* | DBA | Auditoría interna y Responsable de seguridad (lectura). El DBA solo mantiene la tabla. | Auditoría interna | Nadie corrige filas: la tabla es de solo anexar. Una anomalía se documenta como hallazgo. |
| Bitácora de PostgreSQL (archivo del colector y `dba.bitacora`) | Responsable de seguridad de la información *(propuesto)* | DBA | Auditoría interna, Responsable de seguridad; DBA para operación | Responsable de seguridad | No aplica: la bitácora no se edita. Su contenido se redacta solo en copias para compartir (como en E5). |
| `gobierno.solicitudes_cambio` (PostgreSQL) | Comité de cambios (según el `COMMENT` de la tabla) | DBA | Comité de cambios (alta y aprobación), Auditoría interna (lectura) | Comité de cambios | Comité de cambios |
| `comercial.clientes` (MongoDB) | Gerencia Comercial *(propuesto; ver pregunta 2 de la Actividad 4)* | DBA | Aplicación de la tienda en línea y soporte, según los roles del LAB-02 | Gerencia Comercial | Gerencia Comercial |
| `comercial.system.profile` (MongoDB) | Responsable de seguridad de la información *(propuesto)* | DBA | DBA y Responsable de seguridad | Responsable de seguridad | No aplica: colección de diagnóstico, se sobrescribe sola |

## Preguntas

**1. ¿Por qué el propietario de `auditoria.cambios_clientes` no debería ser el mismo que opera `clientes`?**
Por **separación de funciones**. La auditoría existe para vigilar a quienes operan el dato. Si el área que modifica `clientes` (o el DBA que la administra) también controla la tabla de auditoría, puede borrar, alterar o dejar de alimentar el registro de sus propios actos, y el control deja de ser independiente. El propietario debe ser un área que no se beneficie de que el registro esté incompleto. Esta limitación persiste a nivel técnico mientras `postgres` sea superusuario (ver hallazgo H-05 del expediente), por eso la separación debe sostenerse con política (POL-01, POL-05) y con copias exportadas con hash fuera del servidor.

**2. ¿Quién debería poder leer las bitácoras y `dba.bitacora`? ¿Qué se observó en el LAB-01?**
Solo Auditoría interna, el Responsable de seguridad y el DBA, con acceso registrado. La bitácora **no es inocua**: con `log_statement = mod` guarda el texto de las sentencias, incluidos datos personales (en `E5` línea 28 aparecen nombre, correo, teléfono y RFC de los registros insertados) y, como se vio en el LAB-01, secretos como contraseñas escritas en `CREATE ROLE ... PASSWORD`. Quien lee la bitácora puede acceder a datos que no tendría por `clientes`. Por eso `E5` se exportó redactando la contraseña conocida y por eso el expediente no reproduce datos personales completos.

**3. ¿Qué ocurre con la responsabilidad sobre un dato cuando nadie la tiene asignada?**
Nadie decide qué es correcto, nadie aprueba accesos ni correcciones y nadie responde cuando algo sale mal. Es el problema inicial de la unidad: se puede saber **qué** pasó (la bitácora) pero no **quién respondía**. Un caso real de este laboratorio: ante el RFC incompleto del registro 7 (C2), si no hay propietario asignado, el dato queda mal indefinidamente o alguien lo corrige por iniciativa propia y sin autorización.

### Dato técnico que no hay que confundir
En `E2`/`04-inventario` el "propietario técnico" de todas las tablas es `postgres` (propietario del objeto en el motor). Eso **no** es el propietario del dato en la organización (guía §4.4 y pregunta de reflexión 2).
