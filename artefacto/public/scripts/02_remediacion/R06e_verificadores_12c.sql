-- R06e | HACER: regenerar los verificadores de contrasena para que queden solo en 12C (A8.5, A5.17)
-- Requiere R06a aplicado (SQLNET.ALLOWED_LOGON_VERSION_SERVER = 12a): Oracle conserva el verificador 11G
-- hasta que la contrasena se vuelve a establecer. Se reasignan las MISMAS contrasenas de laboratorio de _claves.sql.
-- Uso (raiz del repo): sqlplus "sys/<clave>@localhost:1521/XEPDB1 as sysdba" "@sql/02_remediacion/R06e_verificadores_12c.sql"
@@_claves
@@_inicio R06e_verificadores_12c

PROMPT --- ANTES: verificadores de las cuentas del escenario
SELECT username, password_versions FROM dba_users
 WHERE username IN ('INSTITUTO','INSTITUTO_DEV','DEV_RAMIRO','APP_MATRICULA','DOC_MCHAVES','DOC_RBRENES','TESO_PAULA','AUDITOR_EXT','SOPORTE_TI','SEC_LARAYA','SEC_MVARGAS')
 ORDER BY 1;

-- PERFIL_USUARIOS tiene PASSWORD_REUSE_MAX = 5 y rechazaria la misma contrasena (ORA-28007):
-- se relaja solo durante el cambio y se restaura al final, aunque algun ALTER USER falle.
WHENEVER SQLERROR CONTINUE
ALTER PROFILE perfil_usuarios LIMIT PASSWORD_REUSE_MAX UNLIMITED;

ALTER USER instituto     IDENTIFIED BY "&clave_instituto";
ALTER USER instituto_dev IDENTIFIED BY "&clave_instituto_dev";
ALTER USER dev_ramiro    IDENTIFIED BY "&clave_dev_ramiro";
ALTER USER app_matricula IDENTIFIED BY "&clave_app_matricula";
ALTER USER doc_mchaves   IDENTIFIED BY "&clave_doc_mchaves";
ALTER USER doc_rbrenes   IDENTIFIED BY "&clave_doc_rbrenes";
ALTER USER teso_paula    IDENTIFIED BY "&clave_teso_paula";
ALTER USER auditor_ext   IDENTIFIED BY "&clave_auditor_ext";
ALTER USER soporte_ti    IDENTIFIED BY "&clave_soporte_ti";
ALTER USER sec_laraya    IDENTIFIED BY "&clave_sec_laraya";
ALTER USER sec_mvargas   IDENTIFIED BY "&clave_sec_mvargas";

ALTER PROFILE perfil_usuarios LIMIT PASSWORD_REUSE_MAX 5;
PROMPT --- Limite de reutilizacion restaurado (se espera 5)
SELECT limit FROM dba_profiles WHERE profile='PERFIL_USUARIOS' AND resource_name='PASSWORD_REUSE_MAX';

PROMPT --- DESPUES: verificadores (se espera solo 12C)
SELECT username, password_versions FROM dba_users
 WHERE username IN ('INSTITUTO','INSTITUTO_DEV','DEV_RAMIRO','APP_MATRICULA','DOC_MCHAVES','DOC_RBRENES','TESO_PAULA','AUDITOR_EXT','SOPORTE_TI','SEC_LARAYA','SEC_MVARGAS')
 ORDER BY 1;

PROMPT --- Cuentas con verificador 11G que siguen sin contrasena de laboratorio definida
SELECT username, password_versions, account_status FROM dba_users
 WHERE password_versions LIKE '%11G%' AND oracle_maintained = 'N' ORDER BY 1;
SPOOL OFF
EXIT
