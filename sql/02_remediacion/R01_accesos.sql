-- R01 | HACER: accesos y privilegios (MP-01, MP-02, MP-03, MP-06)
-- Controles: A8.2 (acceso privilegiado), A5.15 (control de acceso), A5.18 (derechos de acceso)
-- Verifica despues con: V02, V05, V07 (fase "despues") y las pruebas PT-01, PT-02, PT-07, PT-28.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R01_accesos.sql"
--
-- Es repetible: si un privilegio ya fue retirado, el script no falla.
SET ECHO OFF VERIFY OFF FEEDBACK ON TAB OFF TRIMSPOOL ON LINESIZE 200 PAGESIZE 100 SERVEROUTPUT ON
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = XEPDB1;
BEGIN
  IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Conectese a XEPDB1 (contenedor actual: ' || SYS_CONTEXT('USERENV','CON_NAME') || ')');
  END IF;
END;
/
SET SERVEROUTPUT ON
COLUMN fecha_ev NEW_VALUE f_ev NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha_ev FROM dual;
SPOOL evidencias/despues/R01_accesos_&f_ev..txt
PROMPT ======================================================================
PROMPT  Remediacion R01: accesos y privilegios
PROMPT ======================================================================
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor, USER AS usuario,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS TZH:TZM') AS fecha
  FROM dual;

WHENEVER SQLERROR EXIT FAILURE ROLLBACK

PROMPT --- 1) Roles por funcion (A5.15)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      -- 1921 el rol ya existe | 1951/1952 el rol o privilegio no estaba otorgado
      IF SQLCODE IN (-1921, -1951, -1952) THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya aplicado) ' || p_sql);
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  ejecutar('CREATE ROLE rol_docente');
  ejecutar('CREATE ROLE rol_secretaria');
  ejecutar('CREATE ROLE rol_tesoreria');
  ejecutar('CREATE ROLE rol_app_matricula');
  ejecutar('CREATE ROLE rol_desarrollo');

  -- Docente: sus notas y adecuaciones (el filtro por fila llega con VPD en R03)
  ejecutar('GRANT SELECT, INSERT, UPDATE ON instituto.notas TO rol_docente');
  ejecutar('GRANT SELECT ON instituto.adecuaciones TO rol_docente');
  ejecutar('GRANT SELECT ON instituto.estudiantes TO rol_docente');

  -- Secretaria: matricula y consulta de becas; las notas son de solo lectura
  ejecutar('GRANT SELECT ON instituto.estudiantes TO rol_secretaria');
  ejecutar('GRANT SELECT ON instituto.becas TO rol_secretaria');
  ejecutar('GRANT SELECT ON instituto.notas TO rol_secretaria');

  -- Tesoreria: gestiona becas, sin poder re-otorgar (sin WITH GRANT OPTION)
  ejecutar('GRANT SELECT, UPDATE ON instituto.becas TO rol_tesoreria');
  ejecutar('GRANT SELECT ON instituto.estudiantes TO rol_tesoreria');

  -- Aplicacion de matricula: solo lo que necesita sobre estudiantes
  ejecutar('GRANT SELECT, INSERT, UPDATE ON instituto.estudiantes TO rol_app_matricula');

  -- Desarrollo: trabaja SOLO sobre el clon, nunca sobre produccion
  ejecutar('GRANT SELECT, INSERT, UPDATE, DELETE ON instituto_dev.estudiantes TO rol_desarrollo');
  ejecutar('GRANT SELECT, INSERT, UPDATE, DELETE ON instituto_dev.adecuaciones TO rol_desarrollo');
END;
/

PROMPT --- 2) Retirar privilegios de sistema y roles excesivos (A8.2)
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
  ejecutar('REVOKE DBA FROM dev_ramiro');                      -- MP-01
  ejecutar('REVOKE SELECT ANY TABLE FROM app_matricula');      -- MP-02
END;
/

PROMPT --- 3) Retirar los permisos directos sobre INSTITUTO, incluido PUBLIC y GRANT OPTION (A5.15, A5.18)
BEGIN
  FOR r IN (SELECT DISTINCT grantee, privilege, table_name
              FROM dba_tab_privs
             WHERE owner = 'INSTITUTO'
               AND grantee IN ('APP_MATRICULA','SECRETARIA','EX_KSALAS','TESO_PAULA',
                               'DOC_MCHAVES','DOC_RBRENES','DEV_RAMIRO','PUBLIC')) LOOP
    EXECUTE IMMEDIATE 'REVOKE ' || r.privilege || ' ON instituto.' || r.table_name || ' FROM ' || r.grantee;
    DBMS_OUTPUT.PUT_LINE('OK    REVOKE ' || r.privilege || ' ON instituto.' || r.table_name || ' FROM ' || r.grantee);
  END LOOP;
END;
/

PROMPT --- 4) Asignar cada cuenta a su rol de funcion
GRANT rol_docente        TO doc_mchaves, doc_rbrenes;
GRANT rol_secretaria     TO secretaria;
GRANT rol_tesoreria      TO teso_paula;
GRANT rol_app_matricula  TO app_matricula;
GRANT rol_desarrollo     TO dev_ramiro;

PROMPT --- 5) Resultado: roles y permisos directos que quedan
COLUMN grantee FORMAT A22
COLUMN granted_role FORMAT A22
COLUMN table_name FORMAT A22
COLUMN privilege FORMAT A18
SELECT grantee, granted_role FROM dba_role_privs
 WHERE grantee IN ('DEV_RAMIRO','APP_MATRICULA','SECRETARIA','TESO_PAULA','DOC_MCHAVES','DOC_RBRENES','EX_KSALAS')
 ORDER BY grantee, granted_role;
SELECT grantee, table_name, privilege FROM dba_tab_privs
 WHERE owner = 'INSTITUTO' AND (grantee = 'PUBLIC' OR grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N'))
 ORDER BY grantee, table_name;
PROMPT (La segunda consulta debe salir vacia: nadie tiene permisos directos ni PUBLIC.)

SPOOL OFF
EXIT
