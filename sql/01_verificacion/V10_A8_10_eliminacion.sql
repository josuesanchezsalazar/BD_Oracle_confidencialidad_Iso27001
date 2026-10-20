-- V10 | A8.10 Eliminacion de la informacion
-- Datos "borrados" que siguen existiendo en la papelera de reciclaje.
-- Complemento en RMAN:  RMAN> REPORT OBSOLETE;   (guardar salida en evidencias)
@@_encabezado V10_A8_10

PROMPT --- 1) Estado de la papelera de reciclaje
SELECT name, value FROM v$parameter WHERE name = 'recyclebin';

PROMPT --- 2) Objetos en la papelera (deberia estar vacia o controlada)
SELECT owner, original_name, type, droptime, can_undrop
  FROM dba_recyclebin
 ORDER BY droptime DESC;

PROMPT --- 3) Directorios del servidor (posibles dumps o archivos olvidados)
SELECT directory_name, directory_path FROM dba_directories ORDER BY directory_name;

SPOOL OFF
