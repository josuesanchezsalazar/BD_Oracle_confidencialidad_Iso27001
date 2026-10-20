-- V01 | A5.12 Clasificacion de la informacion
-- Ejecutar como SYS AS SYSDBA en XEPDB1. Verifica que las columnas sensibles esten etiquetadas.
@@_encabezado V01_A5_12

PROMPT --- 1) Columnas etiquetadas con clasificacion (COMMENT 'CLASIF:...')
SELECT owner, table_name, column_name, comments
  FROM dba_col_comments
 WHERE owner = UPPER('&esquema')
   AND comments LIKE 'CLASIF:%'
 ORDER BY table_name, column_name;

PROMPT --- 2) Columnas del esquema SIN clasificacion (deberia ser 0 filas)
SELECT c.owner, c.table_name, c.column_name
  FROM dba_tab_columns c
  LEFT JOIN dba_col_comments m
         ON m.owner = c.owner AND m.table_name = c.table_name AND m.column_name = c.column_name
 WHERE c.owner = UPPER('&esquema')
   AND (m.comments IS NULL OR m.comments NOT LIKE 'CLASIF:%')
 ORDER BY c.table_name, c.column_id;

SPOOL OFF
