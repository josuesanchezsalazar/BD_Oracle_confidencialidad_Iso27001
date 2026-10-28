-- V06 | A5.33 Proteccion de registros
-- Quien puede administrar o leer el rastro de auditoria.
@@_encabezado V06_A5_33

PROMPT --- 1) Titulares de AUDIT_ADMIN / AUDIT_VIEWER (deben ser solo cuentas autorizadas)
SELECT grantee, granted_role, admin_option
  FROM dba_role_privs
 WHERE granted_role IN ('AUDIT_ADMIN','AUDIT_VIEWER')
 ORDER BY granted_role, grantee;

PROMPT --- 2) Privilegios de sistema de auditoria en cuentas o roles propios
SELECT grantee, privilege
  FROM dba_sys_privs
 WHERE privilege IN ('AUDIT SYSTEM','AUDIT ANY')
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N'
                   UNION SELECT role FROM dba_roles WHERE oracle_maintained = 'N')
 ORDER BY grantee;

PROMPT --- 3) Configuracion de limpieza/retencion del rastro (DBMS_AUDIT_MGMT)
SELECT * FROM dba_audit_mgmt_config_params ORDER BY audit_trail, parameter_name;

SPOOL OFF
