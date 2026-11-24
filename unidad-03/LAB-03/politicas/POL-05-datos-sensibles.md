# POL-05 — Uso de datos sensibles

**Versión:** 1.0 · **Fecha:** 2026-11-23 · **Estado:** propuesta

**Objetivo:** Reducir la exposición de datos personales (nombre, correo, teléfono, RFC, edad, ubicación) y garantizar que el acceso a ellos es justificado y queda registrado.

**Alcance:** Columnas clasificadas como dato personal en `clientes` (ver `03-diccionario.md`), sus copias en `auditoria.cambios_clientes`, en las bitácoras y en `system.profile`, y cualquier extracción o exportación.

**Regla:**
1. El acceso a datos sensibles se concede por rol, con finalidad declarada (la del diccionario) y aprobación del propietario; el personal de soporte consulta el RFC solo mediante la **vista enmascarada** de la Unidad II.
2. Toda exportación o extracción de datos personales, o de bitácoras que los contengan, requiere justificación escrita y se redacta o enmascara antes de compartirse (como `E5`, donde se redactó el secreto conocido); los expedientes y evidencias **no** reproducen tablas de clientes completas.
3. El DBA no consulta datos sensibles por curiosidad; solo por incidente o solicitud documentada.

**Responsable:** Decide: propietario del dato. Ejecuta y registra: DBA. Revisa: Responsable de seguridad.

**Excepciones:** Investigación de un incidente, con acceso del DBA o de Auditoría autorizado por el Responsable de seguridad y limitado en tiempo; se documenta en el expediente del incidente.

**Revisión:** Trimestral junto con POL-01. Coherencia con POL-03: el plazo de 12 meses de las modificaciones y de los valores de auditoría es el que permite investigar un incidente de datos sensibles.
