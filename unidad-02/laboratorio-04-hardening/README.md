# LAB-04 — Hardening y configuración segura de PostgreSQL

## Objetivo

Inspeccionar y fortalecer la configuración de seguridad de PostgreSQL, identificando la superficie de ataque, revisando las conexiones, la autenticación, los roles, los permisos, las extensiones y el cifrado de las comunicaciones.

## Entorno

- Motor: PostgreSQL 16
- Herramienta de administración: pgAdmin 4.
- Base de datos: u_20455801_ernesto_castillo
- Modalidad: individual.

## Superficie de ataque inicial

Se inició la revisión mediante consultas SQL para identificar la versión del servidor, el puerto, las interfaces de escucha, el estado de SSL, el método de almacenamiento de contraseñas y las conexiones activas.

La consulta de pg_stat_activity devolvió 7 filas en la primera ejecución. Entre ellas se observaron conexiones asociadas a pgAdmin y otras filas sin usuario o base de datos asociados. Estos resultados deben interpretarse considerando el estado de las sesiones en el momento de la consulta.

Los valores restantes se documentarán con los resultados obtenidos en pgAdmin.

## Hallazgos

- Se identificaron conexiones activas y procesos asociados al servidor.
- Es necesario comprobar qué interfaces de red utiliza PostgreSQL.
- Se debe revisar el archivo pg_hba.conf y los métodos de autenticación.
- Es necesario identificar los roles administrativos y sus privilegios.
- Se debe verificar si las conexiones utilizan TLS.
- Se deben revisar las extensiones y los parámetros de conexión.
- Los permisos del sistema operativo requieren comprobación desde el servidor.

## Cambios realizados

Los cambios se registrarán únicamente después de ejecutarlos y comprobarlos. Las recomendaciones que no se hayan aplicado se documentarán como propuestas.

## Justificación de los cambios

Se busca aplicar el principio de mínimo privilegio, reducir la exposición de red, restringir las conexiones a los orígenes autorizados y proteger los archivos y las credenciales.

## Conclusiones

El hardening de PostgreSQL requiere revisar conjuntamente la configuración del servidor, la autenticación, los privilegios, las conexiones, el sistema operativo y la red. La ejecución de consultas permite conocer el estado actual, pero la seguridad debe confirmarse mediante controles documentados y verificaciones posteriores.
