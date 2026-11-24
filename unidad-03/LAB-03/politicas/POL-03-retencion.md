# POL-03 — Retención

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta; plazos legales pendientes de confirmar

**Objetivo:** Evitar tanto la pérdida prematura de evidencia como la conservación indefinida de datos personales (incluidas las copias que viven en las bitácoras y en la auditoría).

**Alcance:** Datos de `clientes` (PostgreSQL y MongoDB), tablas de auditoría y de registro de cambios, y todas las bitácoras y sus copias exportadas.

**Regla:** Se aplican los periodos siguientes; al vencer, se eliminan de forma segura y se deja acta. Donde un plazo depende de una obligación normativa: **Plazo a confirmar con el área jurídica** (revisar normativa fiscal de conservación de documentación comprobatoria y la LFPDPPP vigente).

| Dato o registro | Periodo | Al vencer |
|---|---|---|
| `clientes` (datos de clientes) | Mientras dure la relación comercial + plazo legal *(a confirmar con jurídico)* | Eliminar o anonimizar |
| Cambios de privilegios y estructura (DDL/DCL) en bitácora | 24 meses *(a confirmar)* | Eliminar con acta |
| `gobierno.solicitudes_cambio` | 24 meses (lo que dura la bitácora de DDL que concilia) | Eliminar con acta |
| Modificaciones de datos en bitácora (`log_statement = mod`) | 12 meses | Eliminar (contiene datos personales) |
| `auditoria.cambios_clientes`: metadatos | 24 meses | Eliminar filas vencidas con acta |
| `auditoria.cambios_clientes`: `valores_antes`/`valores_despues` | 12 meses | Anonimizar o purgar |
| Accesos de PostgreSQL y bitácora de `mongod` | 6 meses | Eliminar con acta |
| Instantáneas de privilegios (MongoDB) | 24 meses | Eliminar con acta |
| Copias exportadas de `system.profile` | 90 días | Eliminar |

La eliminación de un dato personal de `clientes` **no** exige borrar al mismo tiempo su rastro de auditoría: los metadatos se conservan para demostrar que el cambio ocurrió, y los valores personales se anonimizan al vencer su plazo de 12 meses. Esto resuelve el conflicto entre auditar y eliminar (LAB-01, Actividad 13).

**Responsable:** Decide: propietario del dato, con el área jurídica para los plazos normativos. Ejecuta: DBA. Verifica: Auditoría interna.

**Excepciones:** Retención ampliada por investigación de un incidente, requerimiento de autoridad o litigio (bloqueo legal), autorizada por el área jurídica y registrada con folio; termina cuando concluye el asunto.

**Revisión:** Anual, y cuando cambie la normativa aplicable. Coherencia con POL-05: el plazo de 12 meses de las modificaciones y de los valores de auditoría cubre las investigaciones de incidentes de datos sensibles.
