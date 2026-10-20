-- V03 | A5.16 Gestion de identidades
-- Inventario de cuentas propias, estado, ultimo acceso y cuentas inactivas.
@@_encabezado V03_A5_16

PROMPT --- 1) Cuentas propias (no mantenidas por Oracle)
SELECT username, account_status, profile,
       TO_CHAR(created,'YYYY-MM-DD') AS creada,
       TO_CHAR(last_login,'YYYY-MM-DD HH24:MI') AS ultimo_login,
       common
  FROM dba_users
 WHERE oracle_maintained = 'N'
 ORDER BY username;

PROMPT --- 2) Cuentas ABIERTAS sin acceso en 90 dias o que nunca han ingresado (candidatas a bloqueo)
SELECT username, account_status, TO_CHAR(last_login,'YYYY-MM-DD') AS ultimo_login
  FROM dba_users
 WHERE oracle_maintained = 'N'
   AND account_status = 'OPEN'
   AND (last_login IS NULL OR last_login < SYSTIMESTAMP - INTERVAL '90' DAY)
 ORDER BY username;

SPOOL OFF
