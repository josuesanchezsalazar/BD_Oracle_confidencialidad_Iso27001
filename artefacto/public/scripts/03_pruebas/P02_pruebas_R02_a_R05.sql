-- P02 | Pruebas de los bloques R02 a R05 (identidades, restriccion/masking, auditoria, fuga/eliminacion)
-- Cubre: PT-03, PT-04, PT-05, PT-08, PT-09, PT-10, PT-11, PT-12, PT-13, PT-14, PT-15, PT-16, PT-26, PT-27
-- (PT-06, PT-17, PT-23 y PT-25 las demuestran los scripts V11, V01, V12 y V10; PT-22 se corre con expdp.)
-- Cada conexion usa la cuenta indicada. Las negativas DEBEN dar error.
--
-- Uso (desde la RAIZ del repositorio; pide la clave de SYS):
--   sqlplus /nolog "@sql/03_pruebas/P02_pruebas_R02_a_R05.sql"
-- Dura unos 4 minutos porque PT-11 espera a que expire la sesion inactiva.
SET ECHO ON VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100 SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE
@sql/02_remediacion/_claves.sql
ACCEPT clave_sys CHAR PROMPT 'Clave de SYS: ' HIDE
SET ECHO OFF
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
SPOOL evidencias/despues/P02_pruebas_R02_a_R05_&f_ev..txt
SET ECHO ON
COLUMN id_docente FORMAT 9999
COLUMN num_cuenta FORMAT A24
COLUMN detalle_condicion FORMAT A30
COLUMN username FORMAT A15
COLUMN dbusername FORMAT A15
COLUMN action_name FORMAT A12
COLUMN object_name FORMAT A14
COLUMN fecha FORMAT A20
COLUMN tipo FORMAT A22
COLUMN usuario FORMAT A15
COLUMN detalle FORMAT A22

PROMPT ======================================================================
PROMPT  PT-08 | A8.5 | Bloqueo: 5 intentos fallidos como DEV_RAMIRO y luego la clave correcta
PROMPT  Esperado: ORA-28000 (cuenta bloqueada)
PROMPT ======================================================================
SET ECHO OFF
CONNECT dev_ramiro/"Mala#Clave1"@localhost:1521/XEPDB1
CONNECT dev_ramiro/"Mala#Clave2"@localhost:1521/XEPDB1
CONNECT dev_ramiro/"Mala#Clave3"@localhost:1521/XEPDB1
CONNECT dev_ramiro/"Mala#Clave4"@localhost:1521/XEPDB1
CONNECT dev_ramiro/"Mala#Clave5"@localhost:1521/XEPDB1
PROMPT --- ahora con la clave CORRECTA:
CONNECT dev_ramiro/"&clave_dev_ramiro"@localhost:1521/XEPDB1
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
SELECT username, account_status FROM dba_users WHERE username = 'DEV_RAMIRO';
ALTER USER dev_ramiro ACCOUNT UNLOCK;
SET ECHO ON

PROMPT ======================================================================
PROMPT  PT-09 | A8.5 | Fuerza bruta contra la aplicacion: 8 intentos fallidos como APP_MATRICULA
PROMPT  Esperado: ORA-01017 hasta el 5.o intento y ORA-28000 a partir de ahi
PROMPT ======================================================================
SET ECHO OFF
CONNECT app_matricula/"Mala#Clave1"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave2"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave3"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave4"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave5"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave6"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave7"@localhost:1521/XEPDB1
CONNECT app_matricula/"Mala#Clave8"@localhost:1521/XEPDB1
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
SELECT username, account_status FROM dba_users WHERE username = 'APP_MATRICULA';
ALTER USER app_matricula ACCOUNT UNLOCK;
SET ECHO ON

PROMPT ======================================================================
PROMPT  PT-10 | A5.17 | Complejidad: DOC_MCHAVES intenta cambiar su clave por "abc"
PROMPT  Esperado: ORA-28003 (fallo la verificacion de la contrasena)
PROMPT ======================================================================
SET ECHO OFF
CONNECT doc_mchaves/"&clave_doc_mchaves"@localhost:1521/XEPDB1
SHOW USER
SET ECHO ON
ALTER USER doc_mchaves IDENTIFIED BY "abc" REPLACE "&clave_doc_mchaves";

PROMPT ======================================================================
PROMPT  PT-12 | A5.16 | Cuenta huerfana: EX_KSALAS intenta conectarse
PROMPT  Esperado: ORA-28000 (la cuenta esta bloqueada)
PROMPT ======================================================================
SET ECHO OFF
CONNECT ex_ksalas/"temporal"@localhost:1521/XEPDB1
SET ECHO ON

PROMPT ======================================================================
PROMPT  PT-13 | A5.16 | Cuenta compartida: SECRETARIA intenta conectarse
PROMPT  Esperado: ORA-28000; cada secretaria usa su cuenta nominal
PROMPT ======================================================================
SET ECHO OFF
CONNECT secretaria/"secretaria"@localhost:1521/XEPDB1
CONNECT sec_laraya/"&clave_sec_laraya"@localhost:1521/XEPDB1
SHOW USER
SET ECHO ON
SELECT role FROM session_roles ORDER BY role;

PROMPT ======================================================================
PROMPT  PT-03 | A8.3 | Restriccion por filas: DOC_MCHAVES agrupa las notas por docente
PROMPT  Esperado: solo aparece id_docente = 1
PROMPT ======================================================================
SET ECHO OFF
CONNECT doc_mchaves/"&clave_doc_mchaves"@localhost:1521/XEPDB1
SHOW USER
SET ECHO ON
SELECT id_docente, COUNT(*) AS notas FROM instituto.notas GROUP BY id_docente;
SELECT id_docente, COUNT(*) AS adecuaciones FROM instituto.adecuaciones GROUP BY id_docente;

PROMPT ======================================================================
PROMPT  PT-04 | A8.11 | Redaccion parcial: SEC_LARAYA consulta la cuenta bancaria de las becas
PROMPT  Esperado: solo los ultimos 4 caracteres visibles
PROMPT ======================================================================
SET ECHO OFF
CONNECT sec_laraya/"&clave_sec_laraya"@localhost:1521/XEPDB1
SET ECHO ON
SELECT num_cuenta, ingreso_familiar FROM instituto.becas FETCH FIRST 3 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-05 | A8.11 | Redaccion total: una cuenta sin rol de docente consulta la condicion de salud
PROMPT  Esperado: TESO_PAULA sin acceso (ORA-00942); INSTITUTO (duena del esquema, sin rol docente) ve la condicion vacia
PROMPT ======================================================================
SET ECHO OFF
CONNECT teso_paula/"&clave_teso_paula"@localhost:1521/XEPDB1
SET ECHO ON
SELECT detalle_condicion FROM instituto.adecuaciones FETCH FIRST 3 ROWS ONLY;
SET ECHO OFF
CONNECT instituto/"&clave_instituto"@localhost:1521/XEPDB1
SET ECHO ON
SELECT id_adecuacion, detalle_condicion FROM instituto.adecuaciones FETCH FIRST 3 ROWS ONLY;
PROMPT --- el docente, que SI lo necesita, ve su condicion:
SET ECHO OFF
CONNECT doc_mchaves/"&clave_doc_mchaves"@localhost:1521/XEPDB1
SET ECHO ON
-- (no se usa SUBSTR: la redaccion rechaza funciones SQL sobre la columna redactada, ORA-28094)
COLUMN detalle_condicion FORMAT A60
SELECT id_adecuacion, detalle_condicion FROM instituto.adecuaciones FETCH FIRST 3 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-14 | A8.15 | Auditoria de lectura: DOC_MCHAVES lee ADECUACIONES y se revisa el rastro
PROMPT  Esperado: registro con usuario, fecha, accion SELECT y objeto
PROMPT ======================================================================
SET ECHO OFF
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL
SET ECHO ON
SELECT TO_CHAR(event_timestamp,'YYYY-MM-DD HH24:MI:SS') AS fecha, dbusername, action_name, object_name
  FROM unified_audit_trail
 WHERE object_schema = 'INSTITUTO' AND object_name = 'ADECUACIONES' AND action_name = 'SELECT'
 ORDER BY event_timestamp DESC FETCH FIRST 5 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-15 | A8.15 | Auditoria de privilegios: GRANT de prueba y su registro
PROMPT  Esperado: registro de la accion GRANT con usuario y fecha
PROMPT ======================================================================
GRANT SELECT ON instituto.docentes TO rol_app_matricula;
REVOKE SELECT ON instituto.docentes FROM rol_app_matricula;
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL
SELECT TO_CHAR(event_timestamp,'YYYY-MM-DD HH24:MI:SS') AS fecha, dbusername, action_name, object_name
  FROM unified_audit_trail
 WHERE action_name IN ('GRANT','REVOKE') AND object_name = 'DOCENTES'
 ORDER BY event_timestamp DESC FETCH FIRST 5 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-16 | A5.33 | Proteccion de registros: AUDITOR_EXT intenta purgar el rastro
PROMPT  Esperado: ORA-06550 / PLS-00201 o ORA-01031 (sin privilegios); si puede LEER el rastro
PROMPT ======================================================================
SET ECHO OFF
CONNECT auditor_ext/"&clave_auditor_ext"@localhost:1521/XEPDB1
SET ECHO ON
SELECT COUNT(*) AS eventos_legibles FROM unified_audit_trail;
BEGIN
  DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, use_last_arch_timestamp => FALSE);
END;
/

PROMPT ======================================================================
PROMPT  PT-26 | A8.33* | Clon enmascarado: comparar INSTITUTO_DEV con produccion
PROMPT  Esperado: 0 condiciones de salud reales en el entorno de pruebas
PROMPT ======================================================================
SET ECHO OFF
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
SET ECHO ON
SELECT COUNT(*) AS condiciones_reales_en_el_clon
  FROM instituto_dev.adecuaciones d JOIN instituto.adecuaciones p
    ON p.id_adecuacion = d.id_adecuacion AND p.detalle_condicion = d.detalle_condicion;
SELECT COUNT(*) AS cedulas_reales_en_el_clon
  FROM instituto_dev.estudiantes d JOIN instituto.estudiantes p ON p.id_estudiante = d.id_estudiante AND p.cedula = d.cedula;
SELECT id_estudiante, cedula, nombre, correo FROM instituto_dev.estudiantes FETCH FIRST 3 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-27 | A8.16* | Reporte periodico tras provocar intentos fallidos y bloqueos
PROMPT  Esperado: aparecen los intentos fallidos y los bloqueos del periodo
PROMPT ======================================================================
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL
EXEC DBMS_SCHEDULER.RUN_JOB('MONITOR_AUD.JOB_REPORTE_SEMANAL', TRUE)
SELECT tipo, usuario, detalle, eventos FROM monitor_aud.rep_auditoria ORDER BY tipo, usuario;
SELECT job_name, status, TO_CHAR(actual_start_date,'YYYY-MM-DD HH24:MI') AS inicio
  FROM dba_scheduler_job_run_details WHERE owner = 'MONITOR_AUD' ORDER BY log_date DESC FETCH FIRST 2 ROWS ONLY;

PROMPT ======================================================================
PROMPT  PT-11 | A8.5 | Sesion inactiva: perfil de prueba con IDLE_TIME 1 minuto (espera ~3 minutos)
PROMPT  Esperado: ORA-02396 (se excedio el tiempo maximo de inactividad)
PROMPT ======================================================================
CREATE PROFILE perfil_prueba_idle LIMIT IDLE_TIME 1;
CREATE USER usr_prueba_idle IDENTIFIED BY "Idl#Prb2026!zk" PROFILE perfil_prueba_idle;
GRANT CREATE SESSION TO usr_prueba_idle;
SET ECHO OFF
CONNECT usr_prueba_idle/"Idl#Prb2026!zk"@localhost:1521/XEPDB1
SET ECHO ON
SELECT 'sesion activa' AS estado FROM dual;
PROMPT --- esperando 190 segundos sin actividad...
HOST ping -n 191 127.0.0.1
SELECT 'sesion activa' AS estado FROM dual;
SET ECHO OFF
CONNECT sys/&clave_sys@localhost:1521/XEPDB1 AS SYSDBA
SET ECHO ON
DROP USER usr_prueba_idle CASCADE;
DROP PROFILE perfil_prueba_idle;

SPOOL OFF
EXIT
