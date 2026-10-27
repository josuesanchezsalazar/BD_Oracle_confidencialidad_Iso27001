-- P05 | PT-24 (A8.20): cifrado de red AES256 + SHA256 activo en una conexion por TCP
-- Uso (raiz del repo, por TCP): sqlplus "sys/<clave>@localhost:1521/XEPDB1 as sysdba" "@sql/03_pruebas/P05_PT24_cifrado_red.sql"
SET ECHO OFF VERIFY OFF FEEDBACK OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100
COLUMN network_service_banner FORMAT A110
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
SPOOL evidencias/despues/P03_PT24_red_&f_ev..txt
PROMPT ======================================================================
PROMPT  PT-24 | A8.20 | Cifrado de red: conexion por TCP a localhost:1521/XEPDB1
PROMPT  Esperado: el banner muestra AES256 y SHA256 activos
PROMPT ======================================================================
SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS protocolo, SYS_CONTEXT('USERENV','IP_ADDRESS') AS ip_cliente,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha FROM dual;
SELECT network_service_banner FROM v$session_connect_info
 WHERE sid = SYS_CONTEXT('USERENV','SID') AND (network_service_banner LIKE '%AES256%' OR network_service_banner LIKE '%SHA256%');
SPOOL OFF
EXIT
