-- V14 | A8.15 Registro (logging) - Auditoria unificada
@@_encabezado V14_A8_15

PROMPT --- 1) Modo de auditoria (TRUE = unificada pura; FALSE = modo mixto)
SELECT parameter, value FROM v$option WHERE parameter = 'Unified Auditing';

PROMPT --- 2) Politicas de auditoria habilitadas
SELECT policy_name, enabled_option, entity_name, success, failure
  FROM audit_unified_enabled_policies
 ORDER BY policy_name;

PROMPT --- 3) Definicion de politicas propias (no ORA_*)
SELECT policy_name, audit_option, object_schema, object_name
  FROM audit_unified_policies
 WHERE policy_name NOT LIKE 'ORA\_%' ESCAPE '\'
 ORDER BY policy_name;

PROMPT --- 4) Ultimos 30 eventos sobre el esquema o de gestion de accesos
SELECT TO_CHAR(event_timestamp,'YYYY-MM-DD HH24:MI:SS') AS fecha,
       dbusername, action_name, object_schema, object_name, return_code
  FROM unified_audit_trail
 WHERE object_schema = UPPER('&esquema')
    OR action_name IN ('GRANT','REVOKE','CREATE USER','ALTER USER','DROP USER')
 ORDER BY event_timestamp DESC
 FETCH FIRST 30 ROWS ONLY;

SPOOL OFF
