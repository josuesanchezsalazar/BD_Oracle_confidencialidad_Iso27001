-- R06b | HACER: cifrado de datos en reposo con TDE (A8.24*, riesgo R-CONF-03)
-- Verifica despues con: V16 y la prueba PT-18.
--
-- Requiere que WALLET_ROOT ya este configurado y la instancia reiniciada (ver R06b_paso1_wallet_root.sql).
-- La clave del keystore NO se guarda en el repositorio: se pasa como primer argumento.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R06b_tde.sql" <clave_del_keystore>
--
-- Hace: crea el keystore, lo abre, crea la clave maestra, crea el keystore de inicio automatico (para que la base
-- arranque sin pedir la clave) y cifra en linea el tablespace TS_INSTITUTO con AES256.
-- OJO: respalde el keystore (wallet) por separado; sin el, los datos cifrados no se pueden leer.
SET ECHO OFF VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100 SERVEROUTPUT ON
DEFINE clave_ks = &1
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
SPOOL evidencias/despues/R06b_tde_&f_ev..txt
PROMPT ======================================================================
PROMPT  Remediacion R06b_tde
PROMPT ======================================================================
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

PROMPT --- 1) Configuracion del keystore (contenedor raiz)
SHOW CON_NAME
SELECT name, value FROM v$parameter WHERE name IN ('wallet_root','tde_configuration');
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE' SCOPE = BOTH;

PROMPT --- 2) Keystore y clave maestra
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY "&clave_ks";
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "&clave_ks" CONTAINER = ALL;
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "&clave_ks" WITH BACKUP USING 'respaldo_inicial' CONTAINER = ALL;
ADMINISTER KEY MANAGEMENT CREATE AUTO_LOGIN KEYSTORE FROM KEYSTORE IDENTIFIED BY "&clave_ks";

PROMPT --- 3) Cifrado en linea del tablespace de los datos sensibles (PDB XEPDB1)
ALTER SESSION SET CONTAINER = XEPDB1;
ALTER TABLESPACE ts_instituto ENCRYPTION ONLINE USING 'AES256' ENCRYPT FILE_NAME_CONVERT = ('ts_instituto01.dbf', 'ts_instituto01_cif.dbf');

PROMPT --- 4) Resultado
COLUMN wrl_parameter FORMAT A50
COLUMN status FORMAT A16
SELECT con_id, wrl_type, wrl_parameter, status, wallet_type FROM v$encryption_wallet;
COLUMN tablespace_name FORMAT A16
SELECT t.name AS tablespace_name, e.encryptedts, e.encryptionalg
  FROM v$tablespace t LEFT JOIN v$encrypted_tablespaces e ON e.ts# = t.ts#
 ORDER BY t.name;
SELECT COUNT(*) AS estudiantes_legibles FROM instituto.estudiantes;

SPOOL OFF
EXIT
