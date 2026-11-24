# Evidencia 04 — Catálogo mínimo de datos (Actividad 4)

**Script:** `sql/03-inventario-tablas.sql` · **Captura:** `capturas/04-inventario-tablas.png`
**Servidor PostgreSQL:** `127.0.0.1:5433` (PostgreSQL 16.15 sobre Ubuntu, según `E5` líneas 1–2) · **Servidor MongoDB:** `<servidor-mongo>` *(completar con el de tu LAB-02; la evidencia E6 no venía en el paquete)*

El catálogo tiene **una fila por conjunto de datos** (el diccionario, una por columna).

| ID | Conjunto de datos | Motor | Ubicación | Propietario | Custodio | Clasificación | Datos personales | Finalidad | Conservación | Diccionario |
|---|---|---|---|---|---|---|---|---|---|---|
| CAT-01 | Clientes | PostgreSQL 16 | `127.0.0.1:5433` / `comercial` / `public.clientes` | Gerencia Comercial | DBA | Confidencial | Sí | Operación comercial, facturación y soporte | Mientras exista la relación comercial + plazo legal *(a confirmar con jurídico, POL-03)* | `diccionario-clientes.csv` |
| CAT-02 | Auditoría de clientes | PostgreSQL 16 | `127.0.0.1:5433` / `comercial` / `auditoria.cambios_clientes` | Auditoría interna *(propuesto)* | DBA | Confidencial | **Sí** (valores antes/después de cambios) | Trazabilidad de cambios sobre `clientes` | Metadatos 24 meses; valores antes/después 12 meses y luego anonimizar *(ver 05-conservación)* | Columnas: `id_evento, momento, usuario_sesion, aplicacion, operacion, id_cliente, valores_antes, valores_despues` |
| CAT-03 | Registro de cambios | PostgreSQL 16 | `127.0.0.1:5433` / `comercial` / `gobierno.solicitudes_cambio` | Comité de cambios | DBA | Interna | No (nombres de áreas, no de personas) | Evidencia de POL-06: autorización de cambios | 24 meses (igual que la bitácora de DDL que concilia) | `03-diccionario.md` § complementario |
| CAT-04 | Clientes (tienda) | MongoDB 7 | `<servidor-mongo>` / `comercial` / `clientes` | Gerencia Comercial *(propuesto)* | DBA | Confidencial | Sí | Venta en línea | Igual que CAT-01 | Pendiente: esquema flexible; documentar campos observados con el LAB-02 |
| CAT-05 | Perfilado | MongoDB 7 | `<servidor-mongo>` / `comercial` / `system.profile` | Responsable de seguridad *(propuesto)* | DBA | Confidencial | **Sí** (los filtros de las consultas pueden incluir valores personales) | Diagnóstico y trazabilidad de operaciones | Colección de 1 MB que se sobrescribe; copias exportadas 90 días | No aplica (estructura del perfilador de MongoDB) |
| CAT-06 | Vista de bitácora | PostgreSQL 16 | `127.0.0.1:5433` / `comercial` / `dba.bitacora` (vista) | Responsable de seguridad *(propuesto)* | DBA | Confidencial | **Sí** (muestra el texto de las sentencias) | Consulta de la bitácora del servidor | No almacena: lee el archivo vigente. Conservación = la del archivo (ver 05) | Columnas: `num`, `linea` |
| CAT-07 | Instantáneas de privilegios | MongoDB 7 | `<servidor-mongo>` / `auditoria` / `instantaneas_privilegios` | Responsable de seguridad *(propuesto)* | DBA | Confidencial | No (usuarios y roles técnicos) | Detectar cambios de privilegios sin auditoría nativa | 24 meses (igual que cambios de privilegios en PostgreSQL) | Pendiente (LAB-02) |

## Preguntas

**1. ¿Por qué CAT-02 y CAT-05 contienen datos personales aunque su propósito sea la auditoría?**
Porque registran *qué pasó con el dato*, y para eso copian el dato: `auditoria.cambios_clientes` guarda los valores antes y después de cada cambio (RFC, correo, etc.), y `system.profile` guarda el filtro y a veces los valores de cada consulta. El propósito del registro no cambia la naturaleza de lo que contiene: un RFC en una tabla de auditoría sigue siendo un RFC. Por eso se clasifican como confidenciales, se restringe su lectura, y su conservación debe conciliarse con la de los datos que copian (conflicto de la Actividad 5).

**2. ¿Qué pasa si CAT-01 y CAT-04 tienen propietarios distintos y el RFC de un cliente difiere entre ambos motores?**
No hay una autoridad única que decida cuál valor es el correcto: cada propietario defiende el suyo y la corrección se bloquea. Además, se rompe la trazabilidad (los cambios de un motor no se explican con las solicitudes del otro) y se complica atender derechos de acceso o rectificación del titular. La solución es nombrar **un propietario del dato "cliente"** (o una regla de precedencia: qué sistema es la fuente de verdad del RFC) y registrarla en el catálogo.

**3. ¿Qué información del catálogo cambia con más frecuencia y quién debe actualizarla?**
Propietario y custodio (rotación de personas y áreas), tamaño y filas estimadas (cambian a diario), ubicación (migraciones, nuevos servidores) y conservación (cuando se revisan las políticas). Lo técnico lo actualiza el **custodio** (DBA) con el script de inventario; lo que implica decisión (propietario, clasificación, finalidad, conservación) lo valida el **propietario**. Se propone revisión trimestral, en la misma cadencia de la conciliación (POL-01).
