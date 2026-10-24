# 08. Ciclo de vida y cancelación de datos

## Objetivo

Analizar cómo localizar, bloquear, eliminar o dejar de utilizar datos personales cuando exista una solicitud de cancelación procedente.

## Componentes del ciclo de vida

1. Base de datos principal: contiene los registros operativos.
2. Réplicas: pueden mantener copias de los registros.
3. Respaldos: permiten recuperar información ante fallos.
4. Reportes y exportaciones: pueden contener datos extraídos.
5. Sistemas externos: pueden recibir información mediante integraciones.
6. Entornos de desarrollo: pueden contener copias de datos de producción.

## Procedimiento propuesto

1. Verificar la identidad del solicitante y la legitimidad de la solicitud.
2. Canalizarla al responsable de privacidad o al área competente.
3. Localizar los registros y sistemas donde se encuentran los datos.
4. Determinar si procede la cancelación y si existen obligaciones de conservación.
5. Ejecutar las acciones autorizadas y registrar las evidencias.
6. Coordinar el tratamiento de réplicas, respaldos y sistemas externos.
7. Documentar las excepciones y comunicar el resultado conforme al procedimiento aplicable.

## Riesgos identificados

Eliminar únicamente una fila no garantiza que desaparezcan todas las copias. Los respaldos pueden requerir una política específica de vencimiento o eliminación, y las copias restauradas deben volver a aplicar las solicitudes pendientes.

## Conclusión

La cancelación debe gestionarse mediante un procedimiento documentado que abarque todo el ciclo de vida, respete las obligaciones aplicables y mantenga trazabilidad.