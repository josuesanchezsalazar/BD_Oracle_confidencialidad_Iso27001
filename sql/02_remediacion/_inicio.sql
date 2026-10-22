-- _inicio.sql | Comun a los scripts de remediacion (R02..R06)
-- Uso: @@_inicio <ID_BLOQUE>
-- Cambia a XEPDB1 (se detiene si no lo logra) y abre el SPOOL de evidencia en evidencias/despues/.
SET ECHO OFF VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100 LONG 4000
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = XEPDB1;
BEGIN
  IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Conectese a XEPDB1 (contenedor actual: ' || SYS_CONTEXT('USERENV','CON_NAME') || ')');
  END IF;
END;
/
-- El cambio de contenedor reinicia SERVEROUTPUT: se activa despues.
SET SERVEROUTPUT ON SIZE UNLIMITED
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
COLUMN contenedor FORMAT A12
COLUMN usuario    FORMAT A12
COLUMN fecha      FORMAT A28
COLUMN grantee FORMAT A25
COLUMN granted_role FORMAT A28
COLUMN username FORMAT A22
COLUMN profile FORMAT A22
COLUMN account_status FORMAT A16
COLUMN table_name FORMAT A22
COLUMN privilege FORMAT A22
SPOOL evidencias/despues/&1._&f_ev..txt
PROMPT ======================================================================
PROMPT  Remediacion &1
PROMPT ======================================================================
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor, USER AS usuario,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS fecha
  FROM dual;
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
