
# 01. Inventario de datos personales

## Objetivo

Identificar los datos almacenados en la tabla `clientes`, justificar su uso y determinar qué áreas necesitan acceder a ellos.

## Inventario

| Campo | Finalidad | ¿Es dato personal? | Acceso recomendado |
|---|---|---|---|
| id | Identificar el registro | Puede vincularse con una persona | Personal autorizado |
| nombre | Identificar y atender al cliente | Sí | Soporte y facturación |
| correo | Comunicarse con el cliente | Sí | Soporte y áreas autorizadas |
| telefono | Contactar al cliente | Sí | Soporte cuando sea necesario |
| rfc | Cumplir procesos fiscales | Sí | Facturación autorizada |
| edad | Generar estadísticas por grupos | Puede serlo | Analítica con datos minimizados |
| ciudad | Atender y generar estadísticas regionales | Puede serlo al combinarse con otros datos | Según finalidad |
| codigo_postal | Gestionar ubicación y entregas, si aplica | Puede serlo al combinarse con otros datos | Personal que lo necesite |
| fecha_alta | Registrar la relación con el cliente | Puede serlo | Personal autorizado |

## Análisis

No todos los departamentos necesitan consultar todos los campos. Soporte puede trabajar con los datos necesarios para atender solicitudes, mientras que analítica puede utilizar resultados agrupados.

El RFC y los datos de contacto deben limitarse a los usuarios que tengan una necesidad justificada. La información debe conservarse durante el tiempo necesario para la finalidad correspondiente y las obligaciones aplicables.

## Conclusión

El inventario permite identificar datos innecesarios, establecer permisos y definir políticas de retención. La organización debe documentar las finalidades y revisar periódicamente los accesos.
