# 11. Gobierno de datos

## Objetivo

Definir responsabilidades, accesos y medidas de protección para los datos de los clientes.

| Dato | Responsable funcional | Acceso recomendado | Protección |
|---|---|---|---|
| Nombre | Área de clientes | Soporte y facturación según necesidad | Acceso por roles |
| Correo | Área de clientes | Personal autorizado | Restricción de consultas |
| Teléfono | Área de clientes | Soporte cuando sea necesario | Acceso limitado |
| RFC | Facturación | Personal autorizado de facturación | Restricción y auditoría |
| Edad | Responsable de analítica | Analítica con rangos | Minimización |
| Ciudad | Área de analítica | Usuarios autorizados | Vistas limitadas |
| Código postal | Área de clientes | Personal que lo necesite | Acceso por finalidad |

## Responsabilidades

- **Propietario funcional:** define el uso permitido y la calidad del dato.
- **DBA:** administra la base de datos, los permisos, las copias y los controles técnicos.
- **Responsable de privacidad:** coordina las políticas y las solicitudes relacionadas con datos personales.
- **Usuarios:** consultan únicamente la información necesaria para su función.

## Reglas de gobierno

1. Mantener un inventario actualizado.
2. Asignar responsables para cada categoría de datos.
3. Revisar los permisos periódicamente.
4. Documentar los periodos de retención.
5. Registrar accesos y cambios relevantes.
6. Evaluar nuevos usos antes de autorizarlos.

## Conclusión

El gobierno de datos requiere responsabilidades claras, políticas documentadas y controles técnicos que permitan demostrar el cumplimiento.