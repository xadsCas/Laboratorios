# POL-01 — Acceso

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta para aprobación del propietario del dato

**Objetivo:** Reducir el riesgo de que un usuario o una aplicación tenga más privilegios de los necesarios, o los conserve cuando ya no los necesita (por ejemplo, `app_ventas` con `UPDATE` sobre toda la tabla `clientes`, incluida la columna `rfc`, E2).

**Alcance:** Roles, usuarios y cuentas de aplicación sobre la base `comercial` en PostgreSQL y sobre `comercial` y `auditoria` en MongoDB; ambientes de desarrollo, pruebas y producción, con prioridad en producción. Incluye el acceso a las bitácoras y a `dba.bitacora`.

**Regla:**
1. Todo acceso nuevo o ampliado en producción se solicita por escrito, lo aprueba el **propietario del dato** (para `clientes`, la Gerencia Comercial) y se registra con folio en `gobierno.solicitudes_cambio` antes de ejecutar el `GRANT`.
2. Se otorga el privilegio mínimo necesario (por tabla y, cuando sea posible, por columna) a usuarios nominales o roles de aplicación; no se comparten cuentas.
3. Cada trimestre el DBA entrega a Auditoría interna la lista de privilegios vigentes (misma consulta de E2) y Auditoría la compara con las solicitudes aprobadas; todo privilegio sin solicitud se reporta como hallazgo y se revoca solo con aprobación del propietario.

**Responsable:** Decide: propietario del dato. Ejecuta: DBA (custodio). Revisa: Auditoría interna (persona distinta al DBA).

**Excepciones:** Acceso de emergencia por incidente, otorgado por el DBA con aprobación verbal del Responsable de seguridad y regularizado con folio en un máximo de 24 horas; se revoca al cerrar el incidente.

