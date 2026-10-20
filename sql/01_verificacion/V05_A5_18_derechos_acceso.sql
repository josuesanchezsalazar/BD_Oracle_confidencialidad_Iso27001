-- V05 | A5.18 Derechos de acceso
-- Reporte de todos los derechos sobre el esquema para compararlo con la matriz aprobada.
@@_encabezado V05_A5_18

PROMPT --- 1) Privilegios de objeto sobre el esquema (comparar con matriz rol-objeto)
SELECT grantee, table_name, privilege, grantable
  FROM dba_tab_privs
 WHERE owner = UPPER('&esquema')
 ORDER BY grantee, table_name, privilege;

PROMPT --- 2) Privilegios por columna sobre el esquema
SELECT grantee, table_name, column_name, privilege
  FROM dba_col_privs
 WHERE owner = UPPER('&esquema')
 ORDER BY grantee, table_name;

PROMPT --- 3) Derechos re-otorgables (WITH GRANT / WITH ADMIN) en cuentas propias
SELECT grantee, table_name AS objeto_o_rol, privilege, 'GRANT OPTION' AS tipo
  FROM dba_tab_privs
 WHERE owner = UPPER('&esquema') AND grantable = 'YES'
UNION ALL
SELECT grantee, granted_role, NULL, 'ADMIN OPTION'
  FROM dba_role_privs
 WHERE admin_option = 'YES'
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY 1, 2;

SPOOL OFF
