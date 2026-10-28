-- V04 | A5.17 Informacion de autenticacion
-- Contrasenas por defecto y politica de contrasenas de los perfiles en uso.
@@_encabezado V04_A5_17

PROMPT --- 1) Cuentas ABIERTAS con contrasena por defecto (deberia ser 0)
SELECT d.username, u.account_status
  FROM dba_users_with_defpwd d
  JOIN dba_users u ON u.username = d.username
 WHERE u.account_status = 'OPEN'
 ORDER BY d.username;

PROMPT --- 2) Parametros de contrasena de los perfiles asignados a cuentas propias
SELECT profile, resource_name, limit
  FROM dba_profiles
 WHERE resource_type = 'PASSWORD'
   AND profile IN (SELECT profile FROM dba_users WHERE oracle_maintained = 'N')
 ORDER BY profile, resource_name;

SPOOL OFF
