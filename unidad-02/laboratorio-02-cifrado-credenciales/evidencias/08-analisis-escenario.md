## Evidencia 8: Análisis de un escenario de seguridad
1. ¿Cuáles son los principales riesgos?

Los principales riesgos son la exposición de contraseñas almacenadas en texto claro, el acceso no autorizado a datos personales y financieros, la transmisión de información sin protección adecuada, la publicación de claves criptográficas y la pérdida o robo de respaldos sin cifrar.

Estos problemas pueden provocar robo de cuentas, filtración de información confidencial, fraude y daños a la reputación de la organización.

2. ¿Qué mecanismo utilizarías para proteger cada elemento?

Contraseñas: hash especializado con sal y un factor de trabajo adecuado.

Nombres y correos electrónicos: controles de acceso y cifrado cuando el análisis de riesgos lo justifique.

RFC: cifrado de la columna cuando sea necesario, junto con permisos restringidos.

Información financiera: cifrado en reposo, control de acceso y protección de las comunicaciones.

Claves criptográficas: gestor de secretos o sistema de gestión de claves.

Comunicaciones: TLS con certificados válidos y verificación de la identidad del servidor.

Respaldos: cifrado, control de acceso, almacenamiento separado y pruebas de recuperación.

3. ¿Cuál problema consideras más crítico y por qué?

 almacenar contraseñas en texto plano y exponer claves criptográficas. Las contraseñas pueden permitir accesos no autorizados a cuentas, mientras que una clave expuesta puede permitir descifrar múltiples datos protegidos.

4. ¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos?

No. No existe el riesgo cero, siempre se pueden cometer algun errores por lo tanto solo ayuda a limitar estos problemas.