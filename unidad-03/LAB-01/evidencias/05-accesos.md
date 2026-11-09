# Evidencia 05 — Accesos exitosos y fallidos

## Intentos generados

Se generaron tres conexiones desde la terminal: contraseña incorrecta, usuario inexistente y
una conexión correcta con `application_name`.

```bash
psql "postgresql://app_ventas:incorrecta@127.0.0.1:5433/comercial" -c "SELECT 1"
psql "postgresql://usuario_inexistente:x@127.0.0.1:5433/comercial" -c "SELECT 1"
psql "postgresql://app_ventas:<contraseña_correcta>@127.0.0.1:5433/comercial?application_name=app-ventas-web" \
     -c "SELECT count(*) FROM clientes"
```

Lo que ve el cliente (mensaje genérico, igual para contraseña errónea y usuario inexistente):

```text
FATAL:  password authentication failed for user "usuario_inexistente"
FATAL:  password authentication failed for user "app_ventas"
```

![Mensajes que recibe el cliente](accesos.png)

Lo que queda en la bitácora de la conexión correcta:

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%app_ventas%' ORDER BY num;
```

```text
14:00:31.930 CST [18369] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=53356
14:00:31.963 CST [18369] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authenticated: identity="app_ventas" method=scram-sha-256 (/etc/postgresql/16/main/pg_hba.conf:125)
14:00:31.964 CST [18369] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web SSL enabled (protocol=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384, bits=256)
14:02:31.903 CST [18369] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  disconnection: session time: 0:01:59.973 user=app_ventas database=comercial host=127.0.0.1 port=53356
```

![Conexión recibida, autenticada, autorizada y desconexión](accesos2.png)

Una conexión exitosa deja cuatro eventos: `connection received` → `connection authenticated`
(con el método y la regla de `pg_hba.conf`) → `connection authorized` (con SSL y
`application_name`) → `disconnection` (con la duración de la sesión).

### 11.1 Leer una línea campo por campo

Se toma la línea de autenticación de la conexión exitosa de `app_ventas`:

| **Campo**          | **Valor**                                    | **Significado** |
| ------------------ | -------------------------------------------- | --------------- |
| Fecha y hora (`%m`) | `2026-11-08 14:00:31.963 CST`               | Momento exacto del evento, con milisegundos y zona horaria. |
| PID (`%p`)         | `18369`                                      | Proceso de PostgreSQL que atiende esa conexión; sirve para seguir todos los eventos de una sesión. |
| Usuario (`%u`)     | `app_ventas`                                 | Rol con el que se autenticó. |
| Base de datos (`%d`) | `comercial`                                | Base a la que se conectó. |
| Aplicación (`%a`)  | `[unknown]`                                  | Todavía no se conoce el `application_name`; se informa en la línea siguiente (`authorized`). |
| Cliente (`%h`)     | `127.0.0.1`                                  | Dirección desde donde se conectó (el propio equipo). |
| Severidad          | `LOG`                                        | Evento informativo (un fallo se muestra como `FATAL`). |
| Mensaje            | `connection authenticated: identity="app_ventas" method=scram-sha-256` | Se verificó la identidad con SCRAM-SHA-256. |
| Regla aplicada     | `/etc/postgresql/16/main/pg_hba.conf:125`    | Línea de `pg_hba.conf` que decidió el método de autenticación. |

## Preguntas

**1. La bitácora registra el usuario `app_ventas` en el intento fallido. ¿Eso prueba que la aplicación de ventas intentó entrar? ¿Qué prueba realmente?**
No. Prueba que alguien presentó el nombre `app_ventas` desde cierta IP, en cierto momento y que
la contraseña no coincidió. El nombre de usuario lo escribe quien conecta; no es una identidad
verificada (por eso falló). Tampoco prueba que fuera la aplicación: puede ser un operador con
un error de configuración, un script o un atacante que conoce el nombre del rol. Para atribuirlo
hay que correlacionar la IP, el `application_name` y el contexto.

**2. ¿Qué información adicional registra PostgreSQL cuando el rol no existe? ¿Por qué aparece en la bitácora y no en el mensaje que recibe el cliente?**
La bitácora agrega una línea `DETAIL` con la causa real, por ejemplo
`Role "usuario_inexistente" does not exist.` (y `Connection matched pg_hba.conf line N`),
mientras que el cliente recibe el mismo `password authentication failed` que con una contraseña
incorrecta. Se hace así para no permitir la enumeración de usuarios: un atacante no debe poder
distinguir un rol existente de uno inexistente, pero el administrador sí necesita saber cuál
fue el motivo.

**3. ¿Por qué `app=[unknown]` en el intento fallido, pero `app=app-ventas-web` en la desconexión?**
Por dos razones: (1) en los intentos fallidos de la práctica no se envió `application_name` en la
cadena de conexión (solo se agregó en la conexión correcta); y (2) incluso cuando se envía, el
nombre se aplica a la sesión al terminar la autenticación, por lo que las primeras líneas
(`received`, `authenticated`) aún muestran `[unknown]` y en `authorized` ya aparece
`application_name=app-ventas-web`. En la desconexión la sesión ya lo tenía configurado, de ahí
`app=app-ventas-web`.

**4. ¿Qué patrón de varias líneas te haría sospechar de un ataque de fuerza bruta? Escribe la consulta que contaría los intentos fallidos por usuario.**
Muchas líneas `FATAL: password authentication failed` en un lapso corto, repetidas desde la
misma IP o rango, ya sea contra un mismo usuario (adivinar la contraseña) o contra muchos
usuarios distintos (enumeración), y especialmente si luego aparece una conexión exitosa del
mismo origen.

```sql
SELECT substring(linea from 'user=([^ ]+)') AS usuario,
       substring(linea from 'client=([^ ]+)') AS cliente,
       count(*) AS intentos_fallidos
FROM dba.bitacora
WHERE linea LIKE '%FATAL%password authentication failed%'
GROUP BY 1, 2
ORDER BY intentos_fallidos DESC;
```
