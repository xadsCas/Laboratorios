
function preparacion() {
  const admin = db.getSiblingDB("admin");
  admin.createUser({ user: "admin", pwd: "<REDACTED>", roles: ["root"] });
  admin.auth("admin", "<REDACTED>");

  const comercial = db.getSiblingDB("comercial");
  comercial.createUser({
    user: "app_ventas",
    pwd: "<REDACTED>",
    roles: [{ role: "readWrite", db: "comercial" }]
  });

  comercial.clientes.insertMany([
    { _id: 1, nombre: "Ana López", correo: "ana.lopez@example.test", telefono: "6671234567", rfc: "LOAA850315ABC", edad: 41, ciudad: "Culiacán", codigo_postal: "80000" },
    { _id: 2, nombre: "Carlos Pérez", correo: "carlos.perez@example.test", telefono: "6672345678", rfc: "PECA900720DEF", edad: 35, ciudad: "Culiacán", codigo_postal: "80100" },
    { _id: 3, nombre: "María García", correo: "maria.garcia@example.test", telefono: "6673456789", rfc: "GAMA780912GHI", edad: 47, ciudad: "Mazatlán", codigo_postal: "82000" },
    { _id: 4, nombre: "Luis Torres", correo: "luis.torres@example.test", telefono: "6674567890", rfc: "TOLU920201JKL", edad: 34, ciudad: "Los Mochis", codigo_postal: "81200" },
    { _id: 5, nombre: "Laura Sánchez", correo: "laura.sanchez@example.test", telefono: "6675678901", rfc: "SALA880525MNO", edad: 38, ciudad: "Culiacán", codigo_postal: "80200" }
  ]);
}
// preparacion();   // ejecutar una sola vez

/* ---------------------------------------------------------------
 * 6.4 Función auxiliar — definirla en CADA sesión del DBA
 * --------------------------------------------------------------- */
function bitacora() {
  return db.adminCommand({ getLog: "global" }).log.map(l => JSON.parse(l));
}

/* ---------------------------------------------------------------
 * Actividad 1 — Lo que no existe en esta edición   [DBA]
 * --------------------------------------------------------------- */
db.version();
db.adminCommand({ buildInfo: 1 }).modules;
db.serverCmdLineOpts().parsed;

/* ---------------------------------------------------------------
 * Actividad 2 — El incidente sin perfilado
 * --------------------------------------------------------------- */
db.getProfilingStatus();                                   // [DBA]
/* [TERMINAL]
 * mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web" --quiet --eval 'db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XXX" } })'
 */
db.system.profile.countDocuments();                        // [DBA]
bitacora().filter(e => JSON.stringify(e).includes("GAMA780912XXX")).length;
bitacora().filter(e => JSON.stringify(e).includes("app-ventas-web")).map(e => ({ t: e.t, c: e.c, ctx: e.ctx, msg: e.msg }));

/* ---------------------------------------------------------------
 * Actividad 3 — Activar el perfilador y registrar operaciones
 * --------------------------------------------------------------- */
db.setProfilingLevel(2);                                   // [DBA]
db.getProfilingStatus();
/* [TERMINAL]
 * mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web" --quiet --eval 'db.clientes.find({ ciudad: "Culiacán" }, { nombre: 1, ciudad: 1 }).toArray(); db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XYZ" } }); db.clientes.deleteOne({ _id: 2 });'
 */
db.system.profile.find(                                    // [DBA]
  { ns: "comercial.clientes" },
  { op: 1, ns: 1, command: 1, user: 1, client: 1, appName: 1, ts: 1, millis: 1, nreturned: 1, docsExamined: 1, nModified: 1, ndeleted: 1 }
).sort({ ts: 1 });

/* ---------------------------------------------------------------
 * Actividad 4 — Reducir el volumen con un filtro
 * ¡EXPORTAR system.profile ANTES de ejecutar el drop()!
 * --------------------------------------------------------------- */
db.setProfilingLevel(0);                                   // [DBA]
db.system.profile.drop();
db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } });
db.getProfilingStatus();
/* [TERMINAL]
 * mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web" --quiet --eval 'db.clientes.find({ _id: 1 }).toArray(); db.clientes.updateOne({ _id: 1 }, { $set: { telefono: "6670000000" } })'
 */
db.system.profile.find({}, { op: 1, ns: 1, user: 1, appName: 1, "command.q": 1, "command.u": 1, ts: 1 });

/* ---------------------------------------------------------------
 * Actividad 5 — Accesos en la bitácora de mongod
 * --------------------------------------------------------------- */
/* [TERMINAL] dos intentos fallidos
 * mongosh "mongodb://app_ventas:incorrecta@127.0.0.1:27017/comercial" --quiet --eval "db.clientes.countDocuments()"
 * mongosh "mongodb://usuario_inexistente:x@127.0.0.1:27017/comercial" --quiet --eval "db.clientes.countDocuments()"
 */
bitacora()                                                 // [DBA]
  .filter(e => e.c === "ACCESS" && e.msg === "Failed to authenticate")
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, user: e.attr.user, client: e.attr.client, error: e.attr.error, result: e.attr.result, app: e.attr.doc.application.name }));

bitacora()
  .filter(e => e.msg === "Successfully authenticated" && e.attr.user === "app_ventas")
  .slice(-1)
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, client: e.attr.client, result: e.attr.result, app: e.attr.doc.application.name }));

/* ---------------------------------------------------------------
 * Actividad 6 — Correlacionar un cambio de configuración con su autor
 * Sustituir "conn43" por el ctx real que muestre el primer comando.
 * --------------------------------------------------------------- */
bitacora()                                                 // [DBA]
  .filter(e => e.msg === "Profiler settings changed")
  .map(e => ({ t: e.t, ctx: e.ctx, msg: e.msg, attr: e.attr }));

bitacora()
  .filter(e => e.ctx === "conn43" && e.msg === "Successfully authenticated")
  .map(e => ({ t: e.t, ctx: e.ctx, user: e.attr.user, db: e.attr.db, client: e.attr.client }));

/* ---------------------------------------------------------------
 * Actividad 7 — Cambios de privilegios y control compensatorio
 * --------------------------------------------------------------- */
function instantanea() {                                   // [DBA]
  return db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({
    momento: new Date(),
    tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers,
    usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles }))
  });
}
instantanea();                                             // instantánea 1 (antes)

db.setProfilingLevel(2);
db.grantRolesToUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }]);
db.system.profile.countDocuments({ "command.grantRolesToUser": { $exists: true } });
bitacora().filter(e => JSON.stringify(e).includes("grantRoles")).length;

instantanea();                                             // instantánea 2 (después)
db.getSiblingDB("auditoria").instantaneas_privilegios.find({}, { _id: 0 }).sort({ momento: 1 });

// Restablecer
db.revokeRolesFromUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }]);
db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } });
db.getUsers();                                             // verificar que app_ventas quedó solo con readWrite

/* ---------------------------------------------------------------
 * Actividad 8 — Conservación
 * Verificación tras reiniciar el servicio (ver README: comando de reinicio)
 * --------------------------------------------------------------- */
db.getProfilingStatus();                                   // [DBA] debe volver a was: 0 tras reiniciar
db.system.profile.countDocuments();                        // los documentos siguen
bitacora().length;                                         // menor que antes (memoria vaciada)


 * mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'EJSON.stringify(db.system.profile.find({}, { op: 1, ns: 1, user: 1, client: 1, appName: 1, ts: 1, "command.q": 1, "command.u": 1 }).toArray(), null, 2)' > evidencias/system-profile.json
 * mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'db.adminCommand({ getLog: "global" }).log.join("\n")' > evidencias/bitacora-mongod.log
 * sudo cp /var/log/mongodb/mongod.log evidencias/mongod-archivo-completo.log && sudo chown $USER evidencias/mongod-archivo-completo.log
 * sha256sum evidencias/system-profile.json evidencias/bitacora-mongod.log evidencias/mongod-archivo-completo.log > evidencias/hashes.sha256

