-- =====================================================================
-- 99_limpiar_escenario.sql | Borra TODO lo creado por el proyecto en XEPDB1
-- (escenario, remediaciones, politicas de auditoria POL_CONF*, roles ROL_*,
--  perfiles PERFIL_*, tablespaces TS_CLINICA*) para repetir desde cero.
--
-- Uso:  sqlplus "sys/<clave> as sysdba" "@sql/00_escenario/99_limpiar_escenario.sql"
-- Si un usuario tiene sesiones abiertas, cerrarlas y volver a ejecutar.
-- =====================================================================
SET ECHO OFF FEEDBACK OFF SERVEROUTPUT ON
ALTER SESSION SET CONTAINER = XEPDB1;

DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK     ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('OMITE  ' || p_sql || '  -> ' || SQLERRM);
  END;
BEGIN
  -- 1) Politicas de auditoria del proyecto
  FOR e IN (SELECT policy_name, entity_name, entity_type
              FROM audit_unified_enabled_policies
             WHERE policy_name LIKE 'POL\_CONF%' ESCAPE '\') LOOP
    IF e.entity_name = 'ALL USERS' THEN
      ejecutar('NOAUDIT POLICY ' || e.policy_name);
    ELSIF e.entity_type = 'ROLE' THEN
      ejecutar('NOAUDIT POLICY ' || e.policy_name || ' BY USERS WITH GRANTED ROLES ' || e.entity_name);
    ELSE
      ejecutar('NOAUDIT POLICY ' || e.policy_name || ' BY ' || e.entity_name);
    END IF;
  END LOOP;
  FOR p IN (SELECT DISTINCT policy_name FROM audit_unified_policies
             WHERE policy_name LIKE 'POL\_CONF%' ESCAPE '\') LOOP
    ejecutar('DROP AUDIT POLICY ' || p.policy_name);
  END LOOP;

  -- 2) Usuarios del escenario (CASCADE borra sus objetos y su papelera)
  FOR u IN (SELECT column_value AS nombre
              FROM TABLE(sys.odcivarchar2list(
                'DEV_CARLOS','APP_CITAS','RECEPCION','EX_MROJAS','FACT_ANA',
                'MED_LSOLIS','MED_EVARGAS','AUDITOR_EXT','SOPORTE_TI',
                'CLINICA_DEV','CLINICA'))) LOOP
    ejecutar('DROP USER ' || u.nombre || ' CASCADE');
  END LOOP;

  -- 3) Roles y perfiles creados por el proyecto
  FOR r IN (SELECT role FROM dba_roles
             WHERE role LIKE 'ROL\_%' ESCAPE '\' AND oracle_maintained = 'N') LOOP
    ejecutar('DROP ROLE ' || r.role);
  END LOOP;
  FOR p IN (SELECT DISTINCT profile FROM dba_profiles
             WHERE profile LIKE 'PERFIL\_%' ESCAPE '\') LOOP
    ejecutar('DROP PROFILE ' || p.profile || ' CASCADE');
  END LOOP;

  -- 4) Directorio y tablespaces
  ejecutar('DROP DIRECTORY dir_exportes');
  FOR t IN (SELECT tablespace_name FROM dba_tablespaces
             WHERE tablespace_name LIKE 'TS\_CLINICA%' ESCAPE '\') LOOP
    ejecutar('DROP TABLESPACE ' || t.tablespace_name || ' INCLUDING CONTENTS AND DATAFILES');
  END LOOP;
END;
/

PROMPT Limpieza terminada.
EXIT
