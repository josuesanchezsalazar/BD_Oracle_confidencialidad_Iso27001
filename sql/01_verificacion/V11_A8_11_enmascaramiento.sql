-- V11 | A8.11 Enmascaramiento de datos (Data Redaction)
@@_encabezado V11_A8_11

PROMPT --- 1) Politicas de redaccion
SELECT object_owner, object_name, policy_name, expression, enable
  FROM redaction_policies
 ORDER BY object_owner, object_name;

PROMPT --- 2) Columnas redactadas y tipo de redaccion
SELECT object_owner, object_name, column_name, function_type, function_parameters
  FROM redaction_columns
 ORDER BY object_owner, object_name, column_name;

PROMPT --- 3) Cuentas propias EXENTAS de redaccion (directo o por roles) - deben ser minimas
SELECT DISTINCT r.usr AS username, r.origen AS via
  FROM (SELECT username AS usr, username AS origen FROM dba_users WHERE oracle_maintained = 'N'
        UNION ALL
        SELECT CONNECT_BY_ROOT grantee, granted_role
          FROM dba_role_privs
        CONNECT BY PRIOR granted_role = grantee) r
  JOIN dba_sys_privs sp ON sp.grantee = r.origen
 WHERE sp.privilege = 'EXEMPT REDACTION POLICY'
   AND r.usr IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY 1;

SPOOL OFF
