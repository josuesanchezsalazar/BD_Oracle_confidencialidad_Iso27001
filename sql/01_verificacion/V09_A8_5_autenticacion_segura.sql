-- V09 | A8.5 Autenticacion segura
-- Bloqueo por intentos, inactividad, version de hash y registro de intentos fallidos.
@@_encabezado V09_A8_5

PROMPT --- 1) Limites de bloqueo y sesion en perfiles asignados a cuentas propias
SELECT profile, resource_name, limit
  FROM dba_profiles
 WHERE resource_name IN ('FAILED_LOGIN_ATTEMPTS','PASSWORD_LOCK_TIME','IDLE_TIME',
                         'SESSIONS_PER_USER','CONNECT_TIME')
   AND profile IN (SELECT profile FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY profile, resource_name;

PROMPT --- 2) Parametro RESOURCE_LIMIT (debe ser TRUE para que IDLE_TIME aplique)
SELECT name, value FROM v$parameter WHERE name = 'resource_limit';

PROMPT --- 3) Versiones de verificador de contrasena (se espera solo 12C)
SELECT username, password_versions, authentication_type
  FROM dba_users
 WHERE oracle_maintained = 'N'
 ORDER BY username;

PROMPT --- 4) Intentos de inicio de sesion fallidos registrados (ORA-01017) - ultimos 30 dias
SELECT dbusername, userhost, COUNT(*) AS intentos,
       TO_CHAR(MAX(event_timestamp),'YYYY-MM-DD HH24:MI') AS ultimo
  FROM unified_audit_trail
 WHERE action_name = 'LOGON' AND return_code = 1017
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '30' DAY
 GROUP BY dbusername, userhost
 ORDER BY intentos DESC;

SPOOL OFF
