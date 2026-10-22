-- R05 | HACER: fuga de datos y eliminacion segura (MP-09, MP-10)
-- Controles: A8.12 (prevencion de fuga de datos), A8.10 (eliminacion de la informacion)
-- Verifica despues con: V10, V12 y las pruebas PT-22, PT-23, PT-25.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R05_fuga_eliminacion.sql"
--
-- Para revertir un paquete UTL_* (si una aplicacion lo necesitara): GRANT EXECUTE ON utl_file TO <cuenta o rol>;
@@_inicio R05_fuga_eliminacion

PROMPT --- 1) SOPORTE_TI deja de exportar la base completa (A8.12, MP-09)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN (-1951, -1952, -1927) THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya aplicado) ' || p_sql);
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  ejecutar('REVOKE datapump_exp_full_database FROM soporte_ti');
  ejecutar('REVOKE exp_full_database FROM soporte_ti');
  ejecutar('REVOKE select_catalog_role FROM soporte_ti');
  ejecutar('REVOKE read, write ON DIRECTORY dir_exportes FROM PUBLIC');
END;
/

PROMPT --- 2) PUBLIC pierde los paquetes de salida de datos (A8.12)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN (-1927, -1952, -942) THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya aplicado) ' || p_sql);
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  FOR p IN (SELECT table_name FROM dba_tab_privs
             WHERE grantee = 'PUBLIC' AND privilege = 'EXECUTE'
               AND table_name IN ('UTL_FILE','UTL_HTTP','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_INADDR')) LOOP
    ejecutar('REVOKE EXECUTE ON sys.' || p.table_name || ' FROM PUBLIC');
  END LOOP;
END;
/

PROMPT --- 3) Papelera: purgar los objetos de INSTITUTO que siguen recuperables (A8.10, MP-10)
DECLARE
  n NUMBER := 0;
BEGIN
  FOR o IN (SELECT owner, object_name, original_name FROM dba_recyclebin
             WHERE owner IN ('INSTITUTO','INSTITUTO_DEV') AND type = 'TABLE') LOOP
    EXECUTE IMMEDIATE 'PURGE TABLE ' || o.owner || '."' || o.object_name || '"';
    DBMS_OUTPUT.PUT_LINE('OK    purgado ' || o.owner || '.' || o.original_name);
    n := n + 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('OK    ' || n || ' objetos purgados de la papelera');
END;
/

PROMPT --- 4) Resultado
COLUMN directorio FORMAT A16
SELECT grantee, table_name AS paquete FROM dba_tab_privs WHERE grantee = 'PUBLIC'
   AND table_name IN ('UTL_FILE','UTL_HTTP','UTL_TCP','UTL_SMTP','UTL_MAIL','UTL_INADDR');
SELECT grantee, table_name AS directorio, privilege FROM dba_tab_privs WHERE type = 'DIRECTORY'
   AND (grantee = 'PUBLIC' OR grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N'));
SELECT grantee, granted_role FROM dba_role_privs
 WHERE granted_role IN ('DATAPUMP_EXP_FULL_DATABASE','EXP_FULL_DATABASE')
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N');
SELECT COUNT(*) AS objetos_en_papelera FROM dba_recyclebin WHERE owner IN ('INSTITUTO','INSTITUTO_DEV');

SPOOL OFF
EXIT
