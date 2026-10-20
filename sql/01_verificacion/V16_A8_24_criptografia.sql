-- V16 | A8.24* Uso de criptografia (complementario) - TDE
@@_encabezado V16_A8_24

PROMPT --- 1) Estado del keystore (wallet) TDE
SELECT con_id, wrl_type, wrl_parameter, status, wallet_type, keystore_mode
  FROM v$encryption_wallet;

PROMPT --- 2) Tablespaces y si estan cifrados
SELECT tablespace_name, encrypted, status FROM dba_tablespaces ORDER BY tablespace_name;

PROMPT --- 3) Detalle de tablespaces cifrados (algoritmo)
SELECT t.name AS tablespace_name, e.encryptionalg, e.encryptedts
  FROM v$encrypted_tablespaces e
  JOIN v$tablespace t ON t.ts# = e.ts# AND t.con_id = e.con_id;

PROMPT --- 4) Columnas cifradas con TDE de columna
SELECT owner, table_name, column_name, encryption_alg FROM dba_encrypted_columns;

SPOOL OFF
