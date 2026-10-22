-- R02 | HACER: identidades y autenticacion (MP-04, MP-05, MP-12)
-- Controles: A5.16 (identidades), A5.17 (informacion de autenticacion), A8.5 (autenticacion segura)
-- Verifica despues con: V03, V04, V09 y las pruebas PT-08..PT-13.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R02_identidades.sql"
@@_inicio R02_identidades
@@_claves

PROMPT --- 1) Perfiles con complejidad, bloqueo por intentos, expiracion e IDLE_TIME (A5.17, A8.5)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2, p_ignorar NUMBER DEFAULT 0) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || p_sql);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = p_ignorar THEN
        DBMS_OUTPUT.PUT_LINE('OMITIDO (ya existe) ' || p_sql);
      ELSE
        RAISE;
      END IF;
  END;
BEGIN
  ejecutar('CREATE PROFILE perfil_usuarios LIMIT SESSIONS_PER_USER UNLIMITED', -2379);
  ejecutar('ALTER PROFILE perfil_usuarios LIMIT FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1 '
        || 'PASSWORD_LIFE_TIME 90 PASSWORD_GRACE_TIME 7 PASSWORD_REUSE_MAX 5 PASSWORD_REUSE_TIME UNLIMITED '
        || 'IDLE_TIME 15 PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function');
  -- MP-12: el perfil de la aplicacion deja de permitir intentos ilimitados
  ejecutar('ALTER PROFILE perfil_aplicaciones LIMIT FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME 1 '
        || 'PASSWORD_LIFE_TIME 180 IDLE_TIME 15 PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function');
END;
/

PROMPT --- 2) Cuentas nominales y baja de la cuenta compartida y de la ex-secretaria (A5.16)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || REGEXP_REPLACE(p_sql, 'IDENTIFIED BY "[^"]*"', 'IDENTIFIED BY "***"'));
  END;
  PROCEDURE crear_o_actualizar(p_usuario VARCHAR2, p_clave VARCHAR2, p_perfil VARCHAR2) IS
    v NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v FROM dba_users WHERE username = UPPER(p_usuario);
    IF v = 0 THEN
      ejecutar('CREATE USER ' || p_usuario || ' IDENTIFIED BY "' || p_clave || '" PROFILE ' || p_perfil);
    ELSE
      ejecutar('ALTER USER ' || p_usuario || ' PROFILE ' || p_perfil || ' IDENTIFIED BY "' || p_clave || '"');
    END IF;
  END;
BEGIN
  -- MP-04: una cuenta por secretaria, en lugar de SECRETARIA compartida
  crear_o_actualizar('sec_laraya',  '&clave_sec_laraya',  'perfil_usuarios');
  crear_o_actualizar('sec_mvargas', '&clave_sec_mvargas', 'perfil_usuarios');
  ejecutar('GRANT CREATE SESSION TO sec_laraya, sec_mvargas');
  ejecutar('GRANT rol_secretaria TO sec_laraya, sec_mvargas');
  BEGIN
    ejecutar('REVOKE rol_secretaria FROM secretaria');
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-1951, -1952) THEN RAISE; END IF;
  END;
  ejecutar('ALTER USER secretaria ACCOUNT LOCK');
  -- MP-05: la ex-secretaria ya no pertenece a la organizacion
  ejecutar('ALTER USER ex_ksalas ACCOUNT LOCK');
END;
/

PROMPT --- 3) Perfil y contrasena fuerte para cada cuenta activa (A5.17)
DECLARE
  PROCEDURE ejecutar(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    DBMS_OUTPUT.PUT_LINE('OK    ' || REGEXP_REPLACE(p_sql, 'IDENTIFIED BY "[^"]*"', 'IDENTIFIED BY "***"'));
  END;
BEGIN
  ejecutar('ALTER USER dev_ramiro    PROFILE perfil_usuarios     IDENTIFIED BY "&clave_dev_ramiro"');
  ejecutar('ALTER USER doc_mchaves   PROFILE perfil_usuarios     IDENTIFIED BY "&clave_doc_mchaves"');
  ejecutar('ALTER USER doc_rbrenes   PROFILE perfil_usuarios     IDENTIFIED BY "&clave_doc_rbrenes"');
  ejecutar('ALTER USER teso_paula    PROFILE perfil_usuarios     IDENTIFIED BY "&clave_teso_paula"');
  ejecutar('ALTER USER auditor_ext   PROFILE perfil_usuarios     IDENTIFIED BY "&clave_auditor_ext"');
  ejecutar('ALTER USER soporte_ti    PROFILE perfil_usuarios     IDENTIFIED BY "&clave_soporte_ti"');
  ejecutar('ALTER USER instituto_dev PROFILE perfil_usuarios     IDENTIFIED BY "&clave_instituto_dev"');
  ejecutar('ALTER USER app_matricula PROFILE perfil_aplicaciones IDENTIFIED BY "&clave_app_matricula"');
  ejecutar('ALTER USER instituto     PROFILE perfil_aplicaciones IDENTIFIED BY "&clave_instituto"');
END;
/

PROMPT --- 4) Resultado: estado de las cuentas propias
SELECT username, account_status, profile FROM dba_users WHERE oracle_maintained = 'N' ORDER BY username;
PROMPT --- Limites de los perfiles
COLUMN limit FORMAT A40
COLUMN resource_name FORMAT A26
SELECT profile, resource_name, limit FROM dba_profiles
 WHERE profile IN ('PERFIL_USUARIOS','PERFIL_APLICACIONES')
   AND resource_name IN ('FAILED_LOGIN_ATTEMPTS','PASSWORD_LOCK_TIME','PASSWORD_LIFE_TIME','IDLE_TIME','PASSWORD_VERIFY_FUNCTION')
 ORDER BY profile, resource_name;

SPOOL OFF
EXIT
