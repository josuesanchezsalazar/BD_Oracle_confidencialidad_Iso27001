-- R04 | HACER: auditoria y monitoreo (MP-08)
-- Controles: A8.15 (registro), A5.33 (proteccion de registros), A8.16* (monitoreo)
-- Verifica despues con: V06, V14 y las pruebas PT-14, PT-15, PT-16, PT-27.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R04_auditoria.sql"
@@_inicio R04_auditoria

PROMPT --- 1) El auditor externo solo LEE el rastro: AUDIT_VIEWER en lugar de AUDIT_ADMIN (A5.33)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN (-1951, -1952) THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya aplicado) ' || p_sql);
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  ejecutar('REVOKE audit_admin FROM auditor_ext');
  ejecutar('GRANT audit_viewer TO auditor_ext');
END;
/

PROMPT --- 2) Politicas de auditoria unificada (A8.15)
DECLARE
  PROCEDURE politica(p_nombre VARCHAR2, p_acciones VARCHAR2) IS
    v NUMBER;
  BEGIN
    SELECT COUNT(DISTINCT policy_name) INTO v FROM audit_unified_policies WHERE policy_name = UPPER(p_nombre);
    IF v > 0 THEN
      BEGIN EXECUTE IMMEDIATE 'NOAUDIT POLICY ' || p_nombre; EXCEPTION WHEN OTHERS THEN NULL; END;
      EXECUTE IMMEDIATE 'DROP AUDIT POLICY ' || p_nombre;
    END IF;
    EXECUTE IMMEDIATE 'CREATE AUDIT POLICY ' || p_nombre || ' ACTIONS ' || p_acciones;
    EXECUTE IMMEDIATE 'AUDIT POLICY ' || p_nombre;
    DBMS_OUTPUT.PUT_LINE('OK    politica ' || p_nombre || ' creada y habilitada');
  END;
BEGIN
  politica('pol_datos_sensibles',
    'SELECT ON instituto.adecuaciones, UPDATE ON instituto.adecuaciones, DELETE ON instituto.adecuaciones, '
    || 'SELECT ON instituto.becas, UPDATE ON instituto.becas, DELETE ON instituto.becas');
  politica('pol_gestion_accesos',
    'CREATE USER, ALTER USER, DROP USER, CREATE ROLE, ALTER ROLE, DROP ROLE, GRANT, REVOKE, '
    || 'CREATE PROFILE, ALTER PROFILE, DROP PROFILE');
  politica('pol_exportaciones', 'COMPONENT = DATAPUMP EXPORT');
END;
/

PROMPT --- 3) Reporte semanal automatizado en una cuenta sin autenticacion (A8.16*)
DECLARE
  v NUMBER;
  PROCEDURE ejecutar(p_sql VARCHAR2, p_ignorar NUMBER DEFAULT 0) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || SUBSTR(p_sql, 1, 120));
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = p_ignorar THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya existe) ' || SUBSTR(p_sql, 1, 120));
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v FROM dba_users WHERE username = 'MONITOR_AUD';
  IF v = 0 THEN
    ejecutar('CREATE USER monitor_aud NO AUTHENTICATION DEFAULT TABLESPACE ts_instituto QUOTA 10M ON ts_instituto');
  END IF;
  ejecutar('GRANT CREATE TABLE, CREATE PROCEDURE, CREATE JOB TO monitor_aud');
  ejecutar('GRANT SELECT ON audsys.unified_audit_trail TO monitor_aud');
  ejecutar('CREATE TABLE monitor_aud.rep_auditoria (fecha_reporte TIMESTAMP, tipo VARCHAR2(30), '
        || 'usuario VARCHAR2(128), detalle VARCHAR2(200), eventos NUMBER)', -955);
END;
/
CREATE OR REPLACE PROCEDURE monitor_aud.reporte_semanal AS
BEGIN
  INSERT INTO monitor_aud.rep_auditoria
    SELECT SYSTIMESTAMP, 'LOGON_FALLIDO', dbusername, userhost, COUNT(*)
      FROM audsys.unified_audit_trail
     WHERE action_name = 'LOGON' AND return_code <> 0
       AND event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
     GROUP BY dbusername, userhost;
  INSERT INTO monitor_aud.rep_auditoria
    SELECT SYSTIMESTAMP, 'CAMBIO_PRIVILEGIOS', dbusername, action_name, COUNT(*)
      FROM audsys.unified_audit_trail
     WHERE action_name IN ('GRANT','REVOKE','CREATE USER','ALTER USER','DROP USER','CREATE ROLE','ALTER ROLE','DROP ROLE')
       AND event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
     GROUP BY dbusername, action_name;
  INSERT INTO monitor_aud.rep_auditoria
    SELECT SYSTIMESTAMP, 'ACCESO_DATO_SENSIBLE', dbusername, object_name, COUNT(*)
      FROM audsys.unified_audit_trail
     WHERE object_schema = 'INSTITUTO' AND object_name IN ('ADECUACIONES','BECAS')
       AND event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
     GROUP BY dbusername, object_name;
  COMMIT;
END;
/
DECLARE
  v NUMBER;
BEGIN
  SELECT COUNT(*) INTO v FROM dba_scheduler_jobs WHERE owner = 'MONITOR_AUD' AND job_name = 'JOB_REPORTE_SEMANAL';
  IF v > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('MONITOR_AUD.JOB_REPORTE_SEMANAL');
  END IF;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'MONITOR_AUD.JOB_REPORTE_SEMANAL',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'MONITOR_AUD.REPORTE_SEMANAL',
    repeat_interval => 'FREQ=WEEKLY;BYDAY=MON;BYHOUR=7;BYMINUTE=0',
    enabled         => TRUE,
    comments        => 'Reporte semanal de accesos fallidos, cambios de privilegios y acceso a datos sensibles');
  DBMS_OUTPUT.PUT_LINE('OK    job MONITOR_AUD.JOB_REPORTE_SEMANAL (cada lunes 07:00)');
END;
/

PROMPT --- 4) Resultado
COLUMN policy_name FORMAT A22
COLUMN enabled_option FORMAT A16
COLUMN entity_name FORMAT A12
COLUMN job_name FORMAT A22
COLUMN repeat_interval FORMAT A45
SELECT policy_name, enabled_option, entity_name, success, failure FROM audit_unified_enabled_policies
 WHERE policy_name NOT LIKE 'ORA\_%' ESCAPE '\' ORDER BY policy_name;
SELECT grantee, granted_role FROM dba_role_privs WHERE granted_role IN ('AUDIT_ADMIN','AUDIT_VIEWER') ORDER BY granted_role, grantee;
SELECT job_name, enabled, repeat_interval FROM dba_scheduler_jobs WHERE owner = 'MONITOR_AUD';

SPOOL OFF
EXIT
