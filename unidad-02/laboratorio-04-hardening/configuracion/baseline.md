
# Línea base de seguridad — PostgreSQL 16

## 1. Propósito

Documentar el estado inicial de seguridad y definir el estado esperado después del hardening. Los valores observados se deben obtener del servidor; las recomendaciones no se consideran cambios aplicados.

## 2. Red y conexiones

| Control | Estado observado | Estado esperado |
|---|---|---|
| Puerto | Pendiente de verificar | Puerto documentado y acceso restringido |
| listen_addresses | Pendiente de verificar | Solo interfaces necesarias |
| pg_hba.conf | Pendiente de verificar | Reglas específicas por usuario, base y origen |
| Firewall | Pendiente de verificar | Permitir únicamente orígenes autorizados |
| Redes permitidas | Pendiente de verificar | Lista explícita de redes necesarias |

## 3. Autenticación

| Control | Estado observado | Estado esperado |
|---|---|---|
| password_encryption | Pendiente de verificar | Método seguro compatible con el entorno |
| Métodos de pg_hba.conf | Pendiente de verificar | Métodos adecuados al riesgo y a los clientes |
| Contraseñas | Pendiente de verificar | Credenciales únicas y robustas |
| Cuentas administrativas | Pendiente de verificar | Uso limitado y controlado |

## 4. Autorización

| Control | Estado observado | Estado esperado |
|---|---|---|
| Roles SUPERUSER | Pendiente de verificar | Solo los estrictamente necesarios |
| Cuenta de aplicación | Pendiente de verificar | Separada de la cuenta administrativa |
| Cuenta de consulta | Pendiente de verificar | Solo lectura sobre objetos autorizados |
| Privilegios | Pendiente de verificar | Mínimo privilegio |

## 5. Configuración y extensiones

| Control | Estado observado | Estado esperado |
|---|---|---|
| Extensiones | Pendiente de verificar | Solo las necesarias |
| max_connections | Pendiente de verificar | Límite acorde con la carga |
| statement_timeout | Pendiente de verificar | Tiempo máximo adecuado |
| idle_in_transaction_session_timeout | Pendiente de verificar | Evitar transacciones inactivas indefinidas |

## 6. Sistema operativo

| Control | Estado observado | Estado esperado |
|---|---|---|
| Propietario de archivos | Pendiente de verificar | Cuenta de servicio autorizada |
| Permisos de configuración | Pendiente de verificar | Lectura y escritura restringidas |
| Directorio de datos | Pendiente de verificar | Acceso limitado a la cuenta de PostgreSQL |

## 7. Cifrado

| Control | Estado observado | Estado esperado |
|---|---|---|
| ssl | Pendiente de verificar | TLS habilitado cuando corresponda |
| TLS de la conexión actual | Pendiente de verificar | Cifrado confirmado en conexiones que lo requieren |
| Versión de TLS | Pendiente de verificar | Protocolo moderno compatible con los clientes |
| Credenciales | Pendiente de verificar | No almacenar en el repositorio |

## 8. Mantenimiento

- Actualizaciones: establecer un proceso periódico.
- Revisiones: comprobar roles, reglas y conexiones periódicamente.
- Documentación: registrar cambios, responsables y evidencias.
- Recuperación: verificar que exista una estrategia de respaldo y restauración.

## 9. Criterio de aceptación

La línea base se considerará validada cuando cada control tenga un resultado observado, una justificación y una evidencia verificable. Los controles no comprobados permanecerán pendientes.
