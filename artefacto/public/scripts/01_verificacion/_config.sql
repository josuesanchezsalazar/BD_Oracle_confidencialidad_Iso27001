-- _config.sql | Parametros comunes de los scripts de verificacion
DEFINE esquema = INSTITUTO

-- Cambia a la PDB del proyecto (permite conectarse con: sqlplus sys/<pwd> as sysdba)
SET FEEDBACK OFF
ALTER SESSION SET CONTAINER = XEPDB1;
SET FEEDBACK ON

-- Seguridad: abortar si no se esta en la PDB correcta
WHENEVER SQLERROR EXIT FAILURE
BEGIN
  IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Conectese a XEPDB1 (contenedor actual: '
      || SYS_CONTEXT('USERENV','CON_NAME') || ')');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE
