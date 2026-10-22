-- P01 | Pruebas del bloque R01 (accesos): PT-01, PT-02, PT-07, PT-28
-- Cada prueba se conecta con la cuenta indicada. Las negativas DEBEN dar error.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus /nolog "@sql/03_pruebas/P01_accesos.sql"
-- Pide la clave de SYS. Las claves de las cuentas del escenario (ficticias, de laboratorio) salen de _claves.sql.
SET ECHO ON VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100
WHENEVER SQLERROR CONTINUE
@sql/02_remediacion/_claves.sql
ACCEPT clave_sys CHAR PROMPT 'Clave de SYS: ' HIDE
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
SPOOL evidencias/despues/P01_accesos_&f_ev..txt

PROMPT ======================================================================
PROMPT  PT-01 | A8.2 | Minimo privilegio: APP_MATRICULA no debe leer BECAS
PROMPT  Esperado: ORA-00942
PROMPT ======================================================================
SET ECHO OFF
CONNECT app_matricula/"&clave_app_matricula"@localhost:1521/XEPDB1
SET ECHO ON
SHOW USER
SELECT COUNT(*) FROM instituto.becas;

PROMPT ======================================================================
PROMPT  PT-02 | A5.15 | Acceso legitimo por rol: DOC_MCHAVES lee NOTAS
PROMPT  Esperado: devuelve filas y el permiso viene de ROL_DOCENTE
PROMPT ======================================================================
SET ECHO OFF
CONNECT doc_mchaves/"&clave_doc_mchaves"@localhost:1521/XEPDB1
SET ECHO ON
SHOW USER
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS notas_visibles FROM instituto.notas;

PROMPT ======================================================================
PROMPT  PT-07 | A5.15 | Permisos a PUBLIC: EX_KSALAS intenta leer ADECUACIONES
PROMPT  Esperado: ORA-28000 (cuenta bloqueada) u ORA-00942
PROMPT ======================================================================
SET ECHO OFF
CONNECT ex_ksalas/"temporal"@localhost:1521/XEPDB1
SET ECHO ON
SHOW USER
SELECT COUNT(*) FROM instituto.adecuaciones;

PROMPT ======================================================================
PROMPT  PT-28 | A5.18 | Derechos re-otorgables: TESO_PAULA intenta re-otorgar
PROMPT  Esperado: ORA-01031 (privilegios insuficientes)
PROMPT ======================================================================
SET ECHO OFF
CONNECT teso_paula/"&clave_teso_paula"@localhost:1521/XEPDB1
SET ECHO ON
SHOW USER
GRANT SELECT ON instituto.becas TO secretaria;

SPOOL OFF
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
EXIT
