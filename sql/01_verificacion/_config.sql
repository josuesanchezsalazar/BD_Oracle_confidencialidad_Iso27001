-- _config.sql | Parametros comunes de los scripts de verificacion
-- Cambiar 'esquema' por el nombre del esquema de la organizacion ficticia.
DEFINE esquema = EMPRESA

-- Seguridad: abortar si no se esta conectado a la PDB correcta
WHENEVER SQLERROR EXIT FAILURE
BEGIN
  IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Conectese a XEPDB1 (contenedor actual: '
      || SYS_CONTEXT('USERENV','CON_NAME') || ')');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE
