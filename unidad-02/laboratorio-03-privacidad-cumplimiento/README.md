# LAB-03: Privacidad, cumplimiento y gobierno de los datos

## 1. Introducción

El objetivo de este laboratorio es analizar cómo proteger los datos personales mediante la minimización, la limitación de finalidades, el control de acceso, la gestión de derechos ARCO y el gobierno de datos.

El caso de estudio utiliza una base de datos de clientes en PostgreSQL. Se proponen controles para reducir el acceso innecesario y documentar las responsabilidades sobre la información.

## 2. Inventario de datos

Se identificaron campos como nombre, correo, teléfono, RFC, edad, ciudad y código postal. Cada campo debe tener una finalidad definida, un responsable y una política de acceso y conservación.

El inventario permite distinguir los datos indispensables para la operación de aquellos que pueden omitirse o utilizarse de forma agrupada.

## 3. Finalidades

Los datos deben utilizarse para fines definidos y compatibles con las condiciones aplicables al tratamiento. Las solicitudes de marketing y otros usos secundarios deben evaluarse antes de autorizarse.

Analítica puede utilizar resultados agrupados por ciudad y rangos de edad para reducir la exposición de información identificativa.

## 4. Minimización

Se propuso la tabla `clientes_soporte`, que contiene únicamente los campos necesarios para tareas básicas de atención. De esta manera, se evita que soporte consulte automáticamente todos los datos de los clientes.

El script `01-minimizacion.sql` permite crear y consultar esta estructura.

## 5. Control de acceso

El script `03-controlacceso.sql` crea el rol `analista` si no existe, define la vista `v_analitica_clientes` y concede permisos de lectura sobre ella.

La finalidad es aplicar el principio de mínimo privilegio y limitar el acceso directo a la tabla original. Los permisos deben verificarse en PostgreSQL.

## 6. Derechos ARCO

Se analizaron los derechos de acceso, rectificación, cancelación y oposición. Su atención requiere verificar la solicitud, localizar los datos, evaluar las obligaciones aplicables y registrar las acciones realizadas.

La cancelación debe considerar también respaldos, réplicas, exportaciones y otros sistemas donde pueda existir información.

## 7. Retención

Los datos no deben conservarse indefinidamente sin una justificación. La organización debe documentar la finalidad, el responsable, el periodo aplicable y la acción que corresponde al vencimiento.

Los plazos deben validarse según las obligaciones legales y operativas correspondientes.

## 8. Gobierno de datos

Se propusieron responsabilidades para el propietario funcional, el DBA, el responsable de privacidad y los usuarios. El gobierno requiere inventarios, revisiones de permisos, políticas documentadas y trazabilidad.

## 9. Evaluación integral

Se identificaron riesgos relacionados con accesos excesivos, copias de datos reales, retención injustificada, usos secundarios no documentados y falta de auditoría.

Entre los controles recomendados se encuentran las vistas limitadas, los datos sintéticos para desarrollo, las políticas de retención, la revisión de permisos y el registro de acciones.

## 10. Conclusiones

El laboratorio demuestra que la protección de datos personales no depende únicamente de la seguridad técnica de la base de datos. También requiere justificar las finalidades, minimizar la información recopilada, limitar los accesos y establecer responsabilidades.

Las vistas y los roles de PostgreSQL permiten aplicar controles técnicos, mientras que las políticas de retención, los procedimientos ARCO y la documentación de responsabilidades completan el enfoque de gobierno de datos.

La implementación final debe validarse con las consultas ejecutadas y las evidencias obtenidas en el entorno de prácticas.