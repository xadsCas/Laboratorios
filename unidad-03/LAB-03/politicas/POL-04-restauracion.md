# POL-04 — Restauración

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta

**Objetivo:** Evitar que una restauración (que sobrescribe datos y puede borrar rastros) se haga sin autorización, sin control o destruyendo la evidencia de lo que ocurrió.

**Alcance:** Toda restauración de las bases de `comercial` en PostgreSQL y MongoDB, de datos completos o parciales, en cualquier ambiente. Mayor rigor en producción.

**Regla:**
1. Una restauración en producción es un **cambio en producción**: requiere solicitud con folio aprobada por el propietario del dato (Gerencia Comercial) y por el Comité de cambios, y se ejecuta dentro de la ventana aprobada (POL-06).
2. Antes de restaurar se exportan, con hash, las bitácoras y las tablas de auditoría vigentes, para no perder la evidencia del incidente que motiva la restauración.
3. Primero se restaura en un ambiente de pruebas; solo si esa prueba es correcta se restaura en producción.
4. Tras la restauración, una persona distinta al ejecutor verifica la integridad (conteos, últimas fechas, privilegios vigentes) y se deja acta.

El procedimiento técnico se definirá en la Unidad V.

**Responsable:** Autoriza: propietario del dato y Comité de cambios. Ejecuta: DBA. Verifica: Auditoría interna o Responsable de seguridad.

**Excepciones:** Caída total de producción: el Responsable de seguridad y el propietario pueden autorizar la restauración de inmediato, con folio regularizado en un máximo de 24 horas y revisión en la siguiente conciliación.

**Revisión:** Semestral y después de cada restauración real.
