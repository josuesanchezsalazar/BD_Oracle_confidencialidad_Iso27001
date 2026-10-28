-- V17 | A8.8* Gestion de vulnerabilidades tecnicas (complementario) - Parcheo
-- Nota: Oracle no publica Release Updates para XE; documentar como riesgo aceptado.
@@_encabezado V17_A8_8

PROMPT --- 1) Version exacta del motor
SELECT banner_full FROM v$version;

PROMPT --- 2) Parches SQL aplicados
SELECT patch_id, action, status, TO_CHAR(action_time,'YYYY-MM-DD') AS fecha, description
  FROM dba_registry_sqlpatch
 ORDER BY action_time;

SPOOL OFF
