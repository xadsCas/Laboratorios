## Evidencia 10: Política de gestión de claves criptográficas

## Política de claves

1. Generación segura

Las claves deberán generarse mediante herramientas criptográficas confiables y con algoritmos y longitudes adecuados para el propósito. No se utilizarán claves improvisadas ni valores fáciles de adivinar.

2. Almacenamiento separado

Las claves reales no deberán escribirse directamente en scripts SQL, archivos de configuración públicos ni repositorios de código. Se utilizará un gestor de secretos o un sistema de gestión de claves.

3. Control de acceso

El acceso a las claves se limitará a los usuarios y servicios que las necesiten para realizar sus funciones. Se aplicará el principio de mínimo privilegio.

4. Rotación de claves

Se establecerán periodos de revisión y rotación según el riesgo, el tipo de clave y los requisitos de la organización. Las claves deberán rotarse inmediatamente cuando exista sospecha de exposición o compromiso.

5. Protección de respaldos

Las copias de seguridad que contengan datos sensibles deberán protegerse mediante cifrado y controles de acceso. Las claves necesarias para recuperar la información deberán gestionarse de manera segura y separada de los respaldo

