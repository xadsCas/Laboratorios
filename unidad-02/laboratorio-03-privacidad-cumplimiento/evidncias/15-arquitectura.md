# 15. Arquitectura de datos protegidos

## Objetivo

Proponer una arquitectura que permita utilizar los datos de clientes de acuerdo con cada finalidad, reduciendo el acceso innecesario.

## Componentes

### 1. Base operativa

Contiene los datos necesarios para atender clientes y gestionar operaciones. El acceso se concede únicamente a los usuarios autorizados.

### 2. Capa de analítica

Utiliza vistas con columnas limitadas, datos agrupados y rangos. No debe recibir acceso directo a todos los identificadores personales si no lo necesita.

### 3. Capa de auditoría

Registra accesos, modificaciones y operaciones administrativas relevantes. Los registros deben protegerse contra modificaciones no autorizadas.

### 4. Gestión de respaldos

Establece responsables, plazos de conservación y procedimientos de restauración. Las solicitudes de cancelación deben considerarse al restaurar copias.

### 5. Entornos de desarrollo

Utilizan preferentemente datos sintéticos o adecuadamente anonimizados, evitando copias innecesarias de producción.

## Controles transversales

- Control de acceso por roles.
- Mínimo privilegio.
- Protección de credenciales.
- Cifrado cuando corresponda.
- Registro y revisión de acciones.
- Políticas de retención y eliminación.
- Procedimientos para solicitudes ARCO.
- Evaluación de nuevas finalidades.

## Conclusión

La arquitectura propuesta separa las necesidades operativas, analíticas y de auditoría. La combinación de vistas limitadas, permisos, trazabilidad y políticas de ciclo de vida reduce la exposición de datos personales.