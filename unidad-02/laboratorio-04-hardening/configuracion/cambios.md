
# Registro de cambios — LAB-04

## Criterios

Cada cambio debe tener una justificación, autorización, evidencia del estado anterior y verificación posterior.

## Registro

| ID | Control | Estado inicial | Cambio propuesto o realizado | Justificación | Verificación |
|---|---|---|---|---|---|
| C01 | listen_addresses | Pendiente de verificar | Restringir a interfaces necesarias si procede | Reducir exposición de red | Pendiente |
| C02 | pg_hba.conf | Pendiente de verificar | Sustituir reglas amplias por reglas específicas autorizadas | Limitar orígenes y usuarios | Pendiente |
| C03 | Autenticación | Pendiente de verificar | Revisar métodos y utilizar métodos seguros compatibles | Proteger credenciales | Pendiente |
| C04 | Roles administrativos | Pendiente de verificar | Limitar privilegios innecesarios | Aplicar mínimo privilegio | Pendiente |
| C05 | Cuentas de aplicación | Pendiente de verificar | Separar cuenta de aplicación y cuenta DBA | Reducir impacto de una intrusión | Pendiente |
| C06 | Extensiones | Pendiente de verificar | Evaluar necesidad de cada extensión | Reducir funcionalidad innecesaria | Pendiente |
| C07 | TLS | Pendiente de verificar | Confirmar cifrado y configuración de clientes | Proteger comunicaciones | Pendiente |
| C08 | Archivos sensibles | Pendiente de verificar | Revisar permisos del sistema operativo | Evitar accesos no autorizados | Pendiente |
| C09 | Firewall | Pendiente de verificar | Proponer allowlist de orígenes autorizados | Reducir exposición de red | Pendiente |

## Cambios efectivamente aplicados

A la fecha de creación de este documento no se registra ningún cambio de configuración como aplicado. Las consultas iniciales son de inspección.

## Resultado

Actualizar cada fila después de comprobar el resultado real. Si un cambio no se puede aplicar por falta de permisos, registrar la limitación y dejarlo como propuesta.
