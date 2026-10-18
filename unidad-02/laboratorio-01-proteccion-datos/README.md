# Laboratorio 01 — Protección y privacidad de datos

**Alumno:** Ernesto Castillo Inzunza  
**Instructor:** Alexis Moisés Montaño Araujo  
**Asignatura:** Bases de datos  
**Actividad:** Protección y privacidad de datos

## Objetivo

Aplicar técnicas de protección de datos en PostgreSQL mediante la clasificación de información, el enmascaramiento, la seudonimización, la anonimización y la consulta de datos sujetos a políticas de retención.

## Estructura del proyecto

- `sql/01-clasificacion.sql`: crea una tabla de clientes ficticios para identificar y clasificar datos personales.
- `sql/02-enmascaramiento.sql`: crea una vista que oculta parcialmente los datos personales y configura permisos para el rol de soporte.
- `sql/03-seudonimizacion.sql`: genera identificadores sustitutos y separa los datos analíticos de la tabla que relaciona los tokens con los clientes.
- `sql/04-anonimizacion.sql`: genera estadísticas agrupadas para reducir la exposición de datos individuales.
- `sql/05-retencion.sql`: consulta los registros con una antigüedad superior a cinco años.
- `evidencias/`: contiene las capturas de pantalla que documentan la ejecución de las consultas y sus resultados.
- `informe.md`: presenta la explicación técnica, los resultados, las conclusiones y las preguntas de reflexión.

## Requisitos

- PostgreSQL.
- Un cliente SQL, como pgAdmin.
- Una base de datos de pruebas en la que se puedan crear tablas, vistas, esquemas y roles.

## Orden de ejecución

Ejecutar los archivos SQL en el siguiente orden:

1. `01-clasificacion.sql`
2. `02-enmascaramiento.sql`
3. `03-seudonimizacion.sql`
4. `04-anonimizacion.sql`
5. `05-retencion.sql`

Los scripts deben ejecutarse en la misma base de datos. Se recomienda usar una base de datos de pruebas y ejecutar los scripts de creación inicialmente una sola vez, salvo que se hayan preparado para volver a ejecutarse.

## Consideraciones de seguridad

Los datos utilizados son ficticios y tienen fines académicos. Las vistas y los permisos deben comprobarse con los roles correspondientes. El enmascaramiento y la seudonimización no sustituyen el control de acceso, y las estadísticas agrupadas deben evaluarse para evitar la identificación indirecta de personas.
