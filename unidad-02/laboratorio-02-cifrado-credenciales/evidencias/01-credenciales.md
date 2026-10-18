Evidencia 1: Protección de credenciales

## Objetivo

Demostrar los riesgos de almacenar contraseñas en texto claro y comparar esta práctica con el almacenamiento de hashes de contraseña mediante bcrypt.

## Comando o procedimiento

Se ejecutó el archivo sql/01-credenciales.sql. Primero se creó la tabla usuarios_insegura, que almacena directamente la contraseña del usuario. Después se creó la tabla usuarios_segura, que guarda un hash generado mediante crypt() y gen_salt('bf').

## Resultado obtenido

En la tabla insegura, la contraseña puede visualizarse directamente mediante una consulta SQL. En la tabla segura, el campo password_hash contiene una representación criptográfica de la contraseña.

Al comprobar la contraseña original, el resultado esperado es true. Al comprobar una contraseña incorrecta, el resultado esperado es false.

## Análisis

Si una persona no autorizada obtiene acceso de lectura a la tabla insegura, puede conocer las contraseñas almacenadas y utilizarlas para intentar acceder a las cuentas correspondientes. Esto también puede comprometer otros servicios si los usuarios reutilizan sus contraseñas.

El almacenamiento mediante hash reduce este riesgo porque no conserva directamente la contraseña original. La sal aleatoria y el algoritmo de derivación dificultan los ataques de diccionario y las comparaciones masivas de contraseñas.

## Conclusión

Las contraseñas no deben almacenarse en texto claro. Es preferible utilizar un mecanismo especializado de hash de contraseñas, con sal y un factor de trabajo adecuado, para reducir el impacto de una posible filtración de la base de datos.

## Evidencias

![alt text](image-7.png)

![alt text](image-8.png)