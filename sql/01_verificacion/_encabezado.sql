-- _encabezado.sql | Abre el SPOOL de evidencia con fecha, usuario y contenedor
-- Uso: @@_encabezado <ID_EVIDENCIA>     (requiere &fase = antes | despues)
SET ECHO OFF VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON
SET LINESIZE 220 PAGESIZE 200 LONG 4000
@@_config
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;

-- Formatos comunes de columnas
COLUMN contenedor      FORMAT A12
COLUMN usuario         FORMAT A12
COLUMN host            FORMAT A25
COLUMN fecha           FORMAT A28
COLUMN username        FORMAT A25
COLUMN grantee         FORMAT A25
COLUMN granted_role    FORMAT A30
COLUMN privilege       FORMAT A35
COLUMN owner           FORMAT A15
COLUMN table_name      FORMAT A25
COLUMN column_name     FORMAT A25
COLUMN profile         FORMAT A20
COLUMN resource_name   FORMAT A28
COLUMN limit           FORMAT A28
COLUMN account_status  FORMAT A20
COLUMN via             FORMAT A30
COLUMN comments        FORMAT A45

SPOOL evidencias/&fase/&1._&f_ev..txt
PROMPT ======================================================================
PROMPT  Evidencia: &1   |   Fase: &fase
PROMPT ======================================================================
SELECT SYS_CONTEXT('USERENV','CON_NAME')     AS contenedor,
       USER                                  AS usuario,
       SYS_CONTEXT('USERENV','HOST')         AS host,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS fecha
  FROM dual;
