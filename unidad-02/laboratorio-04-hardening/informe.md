    
# LAB-04 — Informe de hardening de PostgreSQL

## Datos generales

- Materia: DBA — Gestión de Seguridad y Desempeño de Bases de Datos.
- Unidad: II — Seguridad, privacidad y control de acceso.
- Laboratorio: 4 — Hardening y configuración segura de PostgreSQL.
- Herramienta: pgAdmin 4.
- Estudiante: Ernesto Casillo Inzunza.  

## 1. ¿Cuál era la principal superficie de ataque?

La superficie de ataque comprende las interfaces de red, los puertos, las conexiones, los roles, los métodos de autenticación, los archivos de configuración y los componentes habilitados en PostgreSQL. En la inspección inicial se consultaron las conexiones activas y se obtuvieron siete filas en la primera ejecución. Para determinar los riesgos concretos es necesario completar la revisión de las interfaces de escucha, las reglas de autenticación y los privilegios.

## 2. ¿Qué configuración representaba el mayor riesgo?

Una configuración que permita conexiones desde redes innecesariamente amplias, combinada con privilegios excesivos, puede representar un riesgo importante. El hallazgo concreto de este servidor debe establecerse a partir de los resultados de listen_addresses, pg_hba.conf, los roles y los controles de red.

## 3. ¿Qué cambio produjo la mayor reducción de exposición?

Restringir las conexiones a los orígenes y las interfaces estrictamente necesarios puede reducir considerablemente la exposición. La mejora efectiva debe comprobarse comparando el estado anterior y el posterior. No se declara un cambio aplicado hasta contar con evidencia.

## 4. ¿Qué diferencia existe entre el firewall y pg_hba.conf?

El firewall controla el tráfico de red según criterios como origen, destino y puerto. En cambio, pg_hba.conf define qué conexiones a PostgreSQL pueden autenticarse, considerando el tipo de conexión, la base de datos, el usuario, el origen y el método de autenticación. Son controles complementarios, no equivalentes.

## 5. ¿Qué diferencia existe entre autenticación y autorización?

La autenticación verifica la identidad del usuario que intenta conectarse. La autorización determina qué operaciones puede realizar esa identidad después de autenticarse. Una contraseña válida no debe conceder automáticamente permisos administrativos.

## 6. ¿Por qué una cuenta de aplicación no debe ser SUPERUSER?

Una cuenta SUPERUSER tiene privilegios administrativos amplios. Si una aplicación utiliza esa cuenta y sufre una vulnerabilidad, un atacante podría obtener capacidades mucho mayores que las necesarias para operar la aplicación. Por ello, se recomienda una cuenta independiente con permisos mínimos.

## 7. ¿Por qué cambiar el puerto no constituye hardening suficiente?

Cambiar el puerto no sustituye la autenticación segura, el control de privilegios, la restricción de orígenes ni las reglas de firewall. El servicio podría continuar expuesto y vulnerable aunque utilice un puerto diferente.

## 8. ¿Por qué listen_addresses='*' puede ser innecesario?

Ese valor hace que PostgreSQL escuche en todas las interfaces disponibles. Si solo necesita atender conexiones locales o desde una red específica, escuchar en interfaces adicionales aumenta la exposición. La configuración debe ajustarse a las necesidades reales, considerando también pg_hba.conf y el firewall.

## 9. ¿Qué papel tiene el sistema operativo en la seguridad de PostgreSQL?

El sistema operativo controla los permisos de los archivos de configuración, las credenciales, los certificados y el directorio de datos. Si usuarios no autorizados pueden leer o modificar estos archivos, los controles SQL pueden resultar insuficientes. Se deben revisar los propietarios y los permisos desde el servidor.

## 10. ¿Qué controles deberían revisarse periódicamente?

Se deben revisar los roles y sus privilegios, las cuentas administrativas, las cuentas de aplicación, las reglas de pg_hba.conf, las interfaces de escucha, el firewall, TLS, las extensiones, los parámetros de conexión, los permisos de archivos, las actualizaciones y los registros de actividad. Las revisiones deben documentarse con fecha y evidencia.

## 11. Caso integral: identificación de riesgos

| N.º | Problema | Riesgo | Control propuesto |
|---|---|---|---|
| 1 | Escucha en todas las interfaces | Exposición innecesaria | Restringir interfaces |
| 2 | Puerto accesible desde cualquier origen | Intentos de conexión no deseados | Aplicar allowlist en firewall |
| 3 | Regla 0.0.0.0/0 | Acceso desde cualquier IPv4 sujeto a otras condiciones | Restringir las redes autorizadas |
| 4 | Regla all/all | Acceso demasiado amplio | Especificar bases y usuarios |
| 5 | Aplicación con SUPERUSER | Escalada de impacto ante compromiso | Crear cuenta de aplicación limitada |
| 6 | Privilegios excesivos | Modificación o eliminación de datos | Aplicar mínimo privilegio |
| 7 | Métodos de autenticación inadecuados | Riesgo de acceso no autorizado | Revisar y fortalecer autenticación |
| 8 | TLS no verificado | Posible exposición de comunicaciones | Verificar cifrado y clientes |
| 9 | Archivos sensibles mal protegidos | Lectura o modificación no autorizada | Restringir permisos del sistema operativo |
| 10 | Ausencia de revisión periódica | Riesgos que pasan inadvertidos | Establecer auditorías y mantenimiento |

## 12. ¿Es suficiente tener contraseñas fuertes?

No. Las contraseñas fuertes ayudan a proteger la autenticación, pero no restringen por sí mismas las redes, los privilegios, las interfaces de escucha ni los permisos de los archivos. La seguridad requiere combinar autenticación, autorización, controles de red, configuración segura, protección del sistema operativo y monitoreo.

## 13. Conclusión

El laboratorio permite comprender que el hardening de PostgreSQL consiste en reducir la exposición y limitar los accesos a lo estrictamente necesario. La inspección mediante consultas SQL ayuda a identificar la configuración existente y proporciona información para construir una línea base de seguridad. La efectividad de las medidas debe demostrarse con evidencias antes y después de los cambios autorizados.
