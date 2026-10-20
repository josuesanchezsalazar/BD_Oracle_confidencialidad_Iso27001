-- V08 | A8.3 Restriccion de acceso a la informacion
-- Controles a nivel de fila (VPD) y columna (vistas) sobre el esquema.
@@_encabezado V08_A8_3

PROMPT --- 1) Politicas VPD (DBMS_RLS) sobre el esquema
SELECT object_name, policy_name, pf_owner, function, sel, ins, upd, del, enable
  FROM dba_policies
 WHERE object_owner = UPPER('&esquema')
 ORDER BY object_name, policy_name;

PROMPT --- 2) Vistas del esquema (acceso restringido por columnas)
SELECT owner, view_name FROM dba_views WHERE owner = UPPER('&esquema') ORDER BY view_name;

PROMPT --- 3) Quien puede saltarse VPD (EXEMPT ACCESS POLICY)
SELECT grantee, privilege
  FROM dba_sys_privs
 WHERE privilege = 'EXEMPT ACCESS POLICY'
 ORDER BY grantee;

SPOOL OFF
