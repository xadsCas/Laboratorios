# POL-06 — Cambios en producción

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta

**Objetivo:** Que todo cambio de estructura, privilegios o configuración en producción esté autorizado, ocurra en una ventana definida y pueda demostrarse con evidencia independiente de quien lo ejecutó.

**Alcance:** Cambios de estructura (`CREATE`, `ALTER`, `DROP`, `COMMENT`), de privilegios (`GRANT`, `REVOKE`, `CREATE ROLE`), de configuración de registro y activación o desactivación de disparadores de auditoría, en el ambiente de **producción** según la definición de ambientes de la Unidad I (desarrollo, pruebas, producción; los mismos valores que admite `gobierno.solicitudes_cambio.ambiente`).

**Regla:**
- **Antes:** el cambio se solicita con folio en `gobierno.solicitudes_cambio`, indicando descripción, solicitante, ambiente y ventana; lo aprueba el Comité de cambios con una `fecha_aprobacion` **real y anterior** al inicio de la ventana, y el registro de la aprobación **no** lo crea la misma persona que ejecuta el cambio.
- **Durante:** el DBA ejecuta el cambio con su usuario nominal, solo dentro de la ventana aprobada y con el folio citado en el `COMMENT` o en el mensaje de la sentencia.
- **Después:** el DBA verifica que el cambio funciona y, cada mes, una persona distinta concilia la bitácora de DDL/DCL con las solicitudes aprobadas; todo cambio sin folio es un hallazgo.
- Antes de desactivar un disparador de auditoría se requiere folio y se vuelve a activar al terminar; ambas sentencias se concilian.

**Responsable:** Decide: Comité de cambios. Ejecuta: DBA. Concilia: Auditoría interna o Responsable de seguridad (persona distinta al ejecutor).

**Excepciones:** Cambio de emergencia para restablecer el servicio, aprobado verbalmente por el propietario y el Responsable de seguridad, con folio marcado "emergencia" registrado en las 24 horas siguientes y revisado en la siguiente conciliación.

**Revisión:** Mensual la conciliación; anual el texto de la política. Coherencia con POL-03: la bitácora de DDL/DCL y la tabla de solicitudes se conservan 24 meses, el mismo plazo, para poder conciliar.
