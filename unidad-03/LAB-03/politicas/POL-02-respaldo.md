# POL-02 — Respaldo

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta

**Objetivo:** Reducir el riesgo de pérdida de datos por falla, error humano o incidente, y asegurar que existen copias que **sirven** (no solo copias que existen).

**Alcance:** Bases `comercial` (PostgreSQL, incluidos los esquemas `public`, `auditoria`, `gobierno` y `dba`) y `comercial`/`auditoria` (MongoDB), en producción. Las bitácoras en archivo no forman parte del respaldo de la base: se conservan con el criterio de POL-03.

**Regla:**
1. Se respalda diariamente toda la información de producción, de modo que la pérdida máxima aceptada de datos sea de 24 horas *(objetivo a confirmar por el propietario)*.
2. Los respaldos se guardan en una ubicación distinta al servidor de la base y con acceso restringido; un respaldo cifrado cuando contenga datos personales.
3. Cada trimestre una persona distinta al DBA que ejecuta el respaldo comprueba, restaurando en un ambiente de pruebas, que el respaldo es utilizable y deja acta.

El procedimiento técnico se definirá en la Unidad V.

**Responsable:** Decide la frecuencia y el objetivo de pérdida máxima: propietario del dato. Ejecuta: DBA. Verifica: Auditoría interna o Responsable de seguridad.

**Excepciones:** Mantenimiento o cambio planeado que modifique la frecuencia, con folio en `gobierno.solicitudes_cambio` aprobado por el propietario y por un máximo definido.

**Revisión:** Semestral, y siempre que cambie la criticidad del dato o la infraestructura.
