# LAB-01 — Protección y privacidad de datos
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Unidad:** II. Seguridad, privacidad y control de acceso  
**Estudiante:** Ernesto castillo inzunza  
**Docente:** Alexis moises montaño araujo
**Fecha:** 18/10/26

## 1. Introducción

El objetivo de esta práctica es aplicar mecanismos de protección de datos en PostgreSQL y reconocer que cada técnica responde a una necesidad distinta. Se trabaja con una tabla de clientes de prueba para clasificar los datos personales, enmascarar información para el área de soporte, seudonimizar registros para analítica, reducir el riesgo de reidentificación mediante generalización y agregación, y definir un criterio básico de retención.

## 2. Clasificación de datos personales

En `01-clasificacion.sql` se crea la tabla `clientes`, se insertan cinco registros de prueba y se consulta la tabla para revisar los campos disponibles.

### Matriz de clasificación

| Campo | ¿Identifica directamente? | ¿Puede contribuir a identificar? | ¿Requiere protección? | Justificación |
|---|---|---|---|---|
| `id` | No por sí solo fuera del sistema | Sí | Sí | Es un identificador único que permite relacionar registros dentro de la base de datos. |
| `nombre` | Sí, dependiendo del contexto | Sí | Sí | Un nombre completo puede identificar a una persona, especialmente combinado con otros datos. |
| `correo` | Sí, normalmente | Sí | Sí | Puede identificar o contactar directamente al titular. |
| `telefono` | Sí, normalmente | Sí | Sí | Puede vincularse con una persona y utilizarse para contactarla. |
| `rfc` | Sí | Sí | Sí | Es un identificador fiscal que permite asociar información con una persona. |
| `edad` | No | Sí | Sí, según el contexto | Puede convertirse en cuasi-identificador al combinarse con ciudad, código postal u otros atributos. |
| `ciudad` | No | Sí | Sí, según el contexto | Por sí sola suele ser general, pero puede ayudar a identificar al combinarse con otros datos. |
| `codigo_postal` | No | Sí | Sí, según el contexto | Puede reducir el grupo de personas posibles, sobre todo junto con edad y ciudad. |
| `fecha_alta` | No | Sí | Sí, según el contexto | Puede contribuir a distinguir registros cuando se combina con otros atributos. |

Los campos `nombre`, `correo`, `telefono` y `rfc` requieren especial cuidado porque pueden identificar o contactar a una persona. El campo `id` también debe protegerse porque permite enlazar registros. La edad, ciudad, código postal y fecha de alta aunque no siempre identifican por separado, su combinación puede aumentar el riesgo de reidentificación.

## 3. Enmascaramiento de datos

En `02-enmascaramiento.sql` se crea el rol `soporte` y la vista `v_clientes_soporte`. La vista muestra el correo parcialmente oculto, reemplaza parte del teléfono por asteriscos y muestra únicamente los últimos cuatro caracteres del RFC. Después se concede al rol permiso de lectura sobre la vista y se retiran los privilegios directos sobre `clientes`.

El enmascaramiento reduce la exposición de datos durante la consulta, pero no cambia los valores guardados en la tabla original. Por ello, debe combinarse con permisos adecuados. Una vista no basta por sí sola si el usuario conserva permisos directos sobre la tabla original o si existen otros caminos para acceder a los datos completos.


## 4. Seudonimización y separación de funciones

En `03-seudonimizacion.sql` se crean los esquemas `pii` y `analitica`. La tabla `pii.mapa_cliente` relaciona un token UUID con el identificador del cliente. Los tokens se generan con `gen_random_uuid()` y la tabla `analitica.clientes` contiene el token junto con atributos como edad, ciudad, código postal y fecha de alta. También se crea el rol `analista` y se le concede acceso de lectura al conjunto de datos analíticos.

El conjunto analítico utiliza un token en lugar del identificador directo del cliente. El mapa de correspondencia queda en `pii.mapa_cliente` y debe estar disponible únicamente para personal expresamente autorizado. El rol analista no debería poder consultar ni el mapa ni la tabla original; esto aplica el principio de mínimo privilegio y el de separación de funciones.

## 5. Anonimización y riesgo de reidentificación

En `04-anonimizacion.sql` se aplican estas operaciones:

1. **Generalización de edad:** las edades exactas se agrupan en los rangos `18-30`, `31-45` y `46+`.
2. **Generalización de región:** se utiliza el prefijo de dos caracteres del código postal.
3. **Agregación:** se cuentan los registros por combinación de rango de edad y región.
4. **Supresión de grupos pequeños:** se utiliza `HAVING COUNT(*) >= 5` para mostrar únicamente grupos con cinco registros o más.

La generalización reduce la precisión de los atributos y la agregación evita mostrar cada registro individual. La condición `COUNT(*) >= 5` busca suprimir grupos demasiado pequeños, ya que una categoría con muy pocas personas puede facilitar la reidentificación.

## 6. Retención de datos


En `05-retencion.sql` se consultan los registros con `fecha_alta` anterior a la fecha actual menos cinco años:

```sql
SELECT *
FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';
```

### Resultado y análisis

La consulta identifica registros cuya fecha de alta supera cinco años. Como los datos de prueba reciben por defecto la fecha actual al insertarse, es normal que la consulta no devuelva filas durante esta práctica.

El plazo de cinco años se utiliza aquí como criterio de ejercicio, no como regla legal universal. En un entorno real, el periodo debe definirse de acuerdo con la finalidad del tratamiento, las obligaciones legales y contractuales y las políticas de la organización. Antes de eliminar información, deben verificarse las obligaciones de conservación, la existencia de investigaciones o procesos pendientes, los respaldos y la autorización correspondiente. Cuando proceda, los datos deben eliminarse de forma segura o anonimizarse de manera apropiada.

## 7. Conclusiones

La práctica muestra que la protección de datos requiere combinar distintas medidas. La clasificación permite identificar qué campos necesitan mayor cuidado; el enmascaramiento limita lo que ve el personal de soporte; la seudonimización sustituye identificadores directos por tokens para ciertos usos analíticos; la generalización y la agregación reducen el riesgo de reidentificación; y la retención ayuda a evitar que los datos se conserven indefinidamente sin una finalidad justificada.

## 8. Preguntas de reflexión

### 1. ¿Cuál es la diferencia entre enmascaramiento y seudonimización?

El enmascaramiento oculta total o parcialmente el valor que se muestra, mientras que la seudonimización sustituye un identificador directo por otro, como un token. En el enmascaramiento, el dato original permanece en la tabla; en la seudonimización, la identidad puede volver a relacionarse con el token mediante información adicional protegida.

### 2. ¿Por qué la seudonimización no significa anonimización?

Porque los datos seudonimizados pueden vincularse nuevamente con una persona mediante el mapa de correspondencia u otra información disponible. La anonimización busca que la identificación no sea razonablemente posible considerando el contexto y los medios disponibles.

### 3. ¿Por qué eliminar `nombre` y `RFC` no garantiza que un conjunto de datos sea anónimo?

Porque otros campos, como edad, ciudad, código postal y fecha de alta, pueden combinarse para distinguir a una persona. Estos atributos pueden actuar como cuasi-identificadores, especialmente cuando se comparan con fuentes externas.

### 4. ¿Qué función tienen los cuasi-identificadores?

Son atributos que por separado quizá no identifiquen directamente a una persona, pero que al combinarse pueden reducir el grupo de personas posibles y facilitar la reidentificación. En este laboratorio, la edad, ciudad y código postal son ejemplos.

### 5. ¿Por qué es importante separar el mapa de seudonimización?

Porque el mapa permite relacionar los tokens con los clientes reales. Mantenerlo separado y restringido reduce el riesgo de que alguien que solo necesita analizar datos pueda descubrir las identidades.

### 6. ¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?

Se aplican el principio de mínimo privilegio y la separación de funciones. El analista debe tener solo los permisos necesarios para trabajar con los datos analíticos, sin acceso a la información que revela las identidades.

### 7. ¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?

Porque una vista puede mostrar únicamente las columnas necesarias y presentar los datos enmascarados. Esto limita la exposición de la información original, siempre que los permisos de la tabla estén configurados correctamente.

### 8. ¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?

Protegerlo para visualización significa ocultar o transformar lo que se presenta al usuario. Protegerlo contra acceso no autorizado significa aplicar controles de permisos y autenticación que impidan consultar el dato original sin autorización. Se necesitan ambas medidas cuando corresponde.

### 9. ¿Por qué la retención forma parte de la protección de datos?

Porque conservar datos más tiempo del necesario aumenta el periodo durante el cual podrían ser expuestos, robados o utilizados indebidamente. Definir plazos y revisar la necesidad de conservación ayuda a limitar esos riesgos.

### 10. ¿Qué riesgo existe si una organización conserva información indefinidamente?

Aumenta la cantidad de información que podría verse comprometida en un incidente y el riesgo de usos no previstos. También puede generar incumplimientos de políticas u obligaciones aplicables si ya no existe una finalidad válida para conservarla.
