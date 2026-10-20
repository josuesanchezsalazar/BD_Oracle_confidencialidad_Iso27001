-- V13 | A8.13 Respaldo de la informacion
-- Complemento en RMAN:  RMAN> SHOW ALL;   y   RESTORE ... VALIDATE;  (guardar salidas)
@@_encabezado V13_A8_13

PROMPT --- 1) Piezas de respaldo recientes y si estan cifradas
SELECT handle, encrypted, TO_CHAR(completion_time,'YYYY-MM-DD HH24:MI') AS completado
  FROM v$backup_piece
 ORDER BY completion_time DESC
 FETCH FIRST 20 ROWS ONLY;

PROMPT --- 2) Configuracion RMAN distinta del valor por defecto (cifrado, retencion)
SELECT name, value FROM v$rman_configuration ORDER BY name;

SPOOL OFF
