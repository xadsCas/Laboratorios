# Laboratorio 02 — Cifrado, credenciales y comunicaciones seguras

## 1. Introducción

La protección de la información es fundamental para evitar el acceso no autorizado a credenciales y datos sensibles. En el laboratorio 02-cifrado-credenciales veremos diferentes formas para hacerlo

## 2. Objetivo

Aplicar y analizar mecanismos de protección de credenciales y datos sensibles, verificar el estado de las comunicaciones seguras y establecer recomendaciones para gestionar adecuadamente las claves criptográficas.

## 3. Protección de credenciales

Se utilizó el script `sql/01-credenciales.sql` para comparar una tabla que almacena contraseñas en texto claro con otra que almacena hashes generados mediante `crypt()` y `gen_salt('bf')`.

La tabla insegura permite visualizar directamente la contraseña. La tabla segura almacena un hash que puede utilizarse para comprobar la contraseña introducida sin guardar su valor original.

![alt text](image-7.png)

![alt text](image-8.png)

## 4. Protección de datos sensibles

Se utilizó el script `sql/02-cifrado-datos.sql` para cifrar un RFC ficticio mediante `pgp_sym_encrypt()` y recuperar el valor mediante `pgp_sym_decrypt()`.

![alt text](image-9.png)

![alt text](image-10.png)

## 5. Verificación de TLS

Se consultaron los parámetros `ssl`, `ssl_min_protocol_version`, `port` y `listen_addresses`. También se utilizó `pg_stat_ssl` para revisar el estado de la sesión actual.

En las capturas iniciales, el parámetro `ssl` aparece desactivado y la sesión consultada muestra `ssl = false`. También se registró un error de permisos al consultar `ssl_min_protocol_version`.

Estos resultados indican que la sesión observada no utiliza TLS.

## 6. Gestión de claves criptográficas

Se analizó el riesgo de escribir claves directamente en consultas SQL. Una clave expuesta en el código o en el historial de un repositorio puede comprometer los datos cifrados.

Como medida preventiva, se propone utilizar un gestor de secretos, restringir los accesos, rotar las claves comprometidas y proteger los respaldos.

## 7. Comparación de mecanismos

Los hashes de contraseñas se utilizan para verificar credenciales sin conservar la contraseña original. El cifrado permite proteger datos recuperables mediante una clave. TLS protege la comunicación durante el tránsito, mientras que el cifrado de respaldos protege copias almacenadas.

Estos mecanismos se complementan con controles de acceso y una gestión segura de claves.

## 8. Resultados y problemas encontrados

Los resultados se documentan en los archivos de evidencias. La configuración SSL observada inicialmente estaba desactivada. También se encontró un error de permisos al consultar un parámetro de configuración.

Estos problemas deben registrarse como limitaciones de la práctica. No se considerará habilitado TLS hasta verificarlo mediante consultas y una conexión de prueba.

## 9. Conclusiones

El laboratorio permite reconocer la importancia de proteger las contraseñas mediante hash, cifrar los datos sensibles cuando corresponda y evitar que las claves criptográficas se expongan en el código fuente.

## 10. Preguntas de reflexión

### 1. ¿Por qué una contraseña no debe almacenarse como texto claro?

Porque cualquier persona que obtenga acceso de lectura podría conocerla directamente. Un hash especializado reduce ese riesgo al permitir verificar la contraseña sin almacenarla en su forma original.

### 2. ¿Por qué un hash no es equivalente a un cifrado?

El hash está diseñado para producir una representación que permita verificar una contraseña, no para recuperar el dato original. El cifrado es reversible cuando se dispone de la clave adecuada.

### 3. ¿Por qué el cifrado de una columna no sustituye al control de acceso?

Porque el cifrado protege la confidencialidad del dato, pero no define por sí mismo quién puede consultar o modificar la tabla. Se necesitan permisos adecuados y controles de acceso.

### 4. ¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?

TLS protege la comunicación, pero no determina qué tablas o registros puede consultar un usuario. La autorización de PostgreSQL sigue siendo necesaria.

### 5. ¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?

Podría perder la capacidad de recuperar los datos cifrados si no existe una copia segura de la clave o un mecanismo de recuperación apropiado.

### 6. ¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?

La clave podría ser utilizada por personas no autorizadas para descifrar datos protegidos. Se debe considerar comprometida, rotarla y evaluar el alcance del incidente.

### 7. ¿Por qué un repositorio privado no debe considerarse un almacén de secretos?

Porque los permisos pueden cambiar, las cuentas pueden verse comprometidas y los datos pueden conservarse en el historial, las copias o los registros. Los secretos deben almacenarse en mecanismos diseñados para administrarlos.

### 8. ¿Qué diferencia existe entre proteger información almacenada y proteger información durante su transmisión?

La protección en reposo protege datos almacenados en bases de datos, archivos o respaldos. La protección en tránsito protege los datos que circulan por la red, por ejemplo mediante TLS.

### 9. ¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?

Porque una clave expuesta puede permitir descifrar información incluso cuando el algoritmo es seguro. La generación, almacenamiento, acceso, rotación y revocación de claves son esenciales.

### 10. ¿Qué mecanismo adicional implementarías para proteger los respaldos?

Implementaría cifrado de respaldos, almacenamiento separado, permisos restringidos, protección de las claves y pruebas periódicas de recuperación.

## 11. Archivos de evidencias

- `evidencias/01-credenciales.md`
- `evidencias/02-cifrado-datos.md`
- `evidencias/03-gestion-claves.md`
- `evidencias/04-tls.md`
- `evidencias/07-comparacion.md`
- `evidencias/08-analisis-escenario.md`
- `evidencias/10-politicas-clave.md`

## 12. Archivos SQL

- `sql/01-credenciales.sql`
- `sql/02-cifrado-datos.sql`
- `sql/03-verificacion-tls.sql`

## 13. Conclusión general

La protección de credenciales y datos requiere mecanismos distintos que trabajen en conjunto. El hash de contraseñas, el cifrado de datos sensibles, TLS, la protección de respaldos y la gestión segura de claves reducen riesgos diferentes. Su aplicación debe verificarse mediante resultados reales y complementarse con controles de acceso y procedimientos de seguridad.