-- V02 | A5.15 Control de acceso
-- Verifica que el acceso se otorga por roles de funcion y no directo a usuarios ni a PUBLIC.
@@_encabezado V02_A5_15

PROMPT --- 1) Roles propios (no mantenidos por Oracle)
SELECT role, authentication_type FROM dba_roles WHERE oracle_maintained = 'N' ORDER BY role;

PROMPT --- 2) Roles otorgados a usuarios propios
SELECT grantee, granted_role, admin_option, default_role
  FROM dba_role_privs
 WHERE grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY grantee, granted_role;

PROMPT --- 3) Privilegios de objeto sobre el esquema otorgados DIRECTO a usuarios (deberia ser 0)
SELECT grantee, table_name, privilege
  FROM dba_tab_privs
 WHERE owner = UPPER('&esquema')
   AND grantee IN (SELECT username FROM dba_users)
 ORDER BY grantee, table_name;

PROMPT --- 4) Privilegios sobre el esquema otorgados a PUBLIC (deberia ser 0)
SELECT grantee, table_name, privilege
  FROM dba_tab_privs
 WHERE owner = UPPER('&esquema') AND grantee = 'PUBLIC';

SPOOL OFF
