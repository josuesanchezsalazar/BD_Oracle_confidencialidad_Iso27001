-- V12 | A8.12 Prevencion de fuga de datos (DLP)
-- Vias de salida masiva de datos: paquetes UTL_*, roles de exportacion, directorios, DB links.
@@_encabezado V12_A8_12

PROMPT --- 1) Paquetes de salida de datos ejecutables por PUBLIC (deberia ser 0)
SELECT grantee, table_name AS paquete, privilege
  FROM dba_tab_privs
 WHERE grantee = 'PUBLIC'
   AND table_name IN ('UTL_FILE','UTL_HTTP','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_INADDR')
 ORDER BY table_name;

PROMPT --- 2) Cuentas propias con roles de exportacion completa
SELECT grantee, granted_role
  FROM dba_role_privs
 WHERE granted_role IN ('DATAPUMP_EXP_FULL_DATABASE','EXP_FULL_DATABASE')
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY grantee;

PROMPT --- 3) Privilegios sobre objetos DIRECTORY otorgados a cuentas propias o PUBLIC
SELECT grantee, table_name AS directorio, privilege
  FROM dba_tab_privs
 WHERE type = 'DIRECTORY'
   AND (grantee = 'PUBLIC'
        OR grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N'
                       UNION SELECT role FROM dba_roles WHERE oracle_maintained = 'N'))
 ORDER BY table_name, grantee;

PROMPT --- 4) Database links existentes
SELECT owner, db_link, username, host FROM dba_db_links ORDER BY owner;

PROMPT --- 5) Politicas de auditoria sobre Data Pump
SELECT policy_name, audit_option, audit_option_type
  FROM audit_unified_policies
 WHERE audit_option_type = 'DATAPUMP ACTION'
 ORDER BY policy_name;

SPOOL OFF
