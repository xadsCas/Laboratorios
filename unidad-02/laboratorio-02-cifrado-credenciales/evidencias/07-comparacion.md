# Evidencia 7: Comparación de mecanismos de protección

## Objetivo

Comparar distintos mecanismos de seguridad y relacionarlos con la información que necesitan proteger.

## Comando o procedimiento

Se analizaron cinco situaciones relacionadas con credenciales, datos sensibles, comunicaciones, respaldos y claves criptográficas.

## Resultado obtenido

| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash de contraseña con sal y un factor de trabajo adecuado | Evita almacenar directamente la contraseña original y dificulta los ataques de recuperación. |
| RFC almacenado en una tabla | Cifrado cuando esté justificado por el riesgo y los requisitos de protección | Protege la confidencialidad del dato almacenado frente a accesos que no dispongan de la clave. |
| Consulta enviada al servidor | TLS correctamente configurado y validación del certificado | Protege la comunicación durante el tránsito y permite verificar la identidad del servidor. |
| Respaldo de una base de datos | Cifrado del respaldo y control de acceso | Reduce el riesgo de exposición de la información contenida en la copia. |
| Clave criptográfica | Gestor de secretos o sistema de gestión de claves | Restringe el acceso, facilita la rotación y reduce la exposición de las claves. |
