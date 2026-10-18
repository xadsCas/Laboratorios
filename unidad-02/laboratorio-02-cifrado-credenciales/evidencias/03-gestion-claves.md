## Evidencia 3: Gestión segura de claves

## Objetivo

Identificar los riesgos de incluir claves criptográficas directamente en consultas SQL y establecer medidas para protegerlas.

## Comando o procedimiento

SELECT pgp_sym_decrypt(
    rfc_cifrado,
    'CLAVE-DE-PRUEBA'
)
FROM clientes_protegidos;

## Resultado obtenido

La consulta muestra una práctica insegura porque la clave está escrita directamente en el código SQL. Si se ejecuta con datos cifrados válidos y la clave correspondiente, permite recuperar el dato original, pero también puede exponer el secreto a quienes tengan acceso al archivo o a los registros de ejecución.

## Analisis

Una clave no se deberia publicar en alugun repositorio ya que cualquier persona podria utilizarla para descifrar los datos. Para evitar esto las claves deberian ir en una base de secretos o un sistema de gestion de claves.

Conclusion

la seguridad de los datos depende de distintos factores como el algoritmo de seguridad de las claves.