-- R03 | HACER: restriccion por fila, redaccion, clasificacion y clon enmascarado (MP-07, MP-11)
-- Controles: A5.12 (clasificacion), A8.3 (restriccion de acceso), A8.11 (enmascaramiento), A8.33* (informacion de prueba)
-- Verifica despues con: V01, V08, V11 y las pruebas PT-03, PT-04, PT-05, PT-06, PT-17, PT-26.
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R03_restriccion_masking.sql"
@@_inicio R03_restriccion_masking

PROMPT --- 1) Clasificacion de las 36 columnas segun la Ley 8968 (A5.12)
DECLARE
  v_nivel VARCHAR2(12);
  n       NUMBER := 0;
BEGIN
  FOR c IN (SELECT table_name, column_name FROM dba_tab_columns
             WHERE owner = 'INSTITUTO' AND table_name NOT LIKE 'BIN$%'
               AND table_name IN ('DOCENTES','ESTUDIANTES','NOTAS','ADECUACIONES','BECAS')) LOOP
    v_nivel := CASE
      WHEN c.table_name = 'ADECUACIONES' AND c.column_name IN ('DETALLE_CONDICION','RECOMENDACIONES') THEN 'Sensible'
      WHEN c.table_name = 'BECAS'        AND c.column_name = 'INGRESO_FAMILIAR'                       THEN 'Sensible'
      WHEN c.table_name = 'ADECUACIONES' AND c.column_name IN ('TIPO_ADECUACION','FECHA_RESOLUCION') THEN 'Restringido'
      WHEN c.table_name = 'ESTUDIANTES'  AND c.column_name IN ('CEDULA','FECHA_NAC','TELEFONO','CORREO','DIRECCION','ENCARGADO') THEN 'Restringido'
      WHEN c.table_name = 'BECAS'        AND c.column_name = 'NUM_CUENTA'                            THEN 'Restringido'
      WHEN c.table_name = 'NOTAS'        AND c.column_name IN ('MATERIA','PERIODO','NOTA')           THEN 'Restringido'
      WHEN c.table_name = 'DOCENTES'     AND c.column_name IN ('NOMBRE','ESPECIALIDAD')              THEN 'Publico'
      ELSE 'Interno'
    END;
    EXECUTE IMMEDIATE 'COMMENT ON COLUMN instituto.' || c.table_name || '.' || c.column_name ||
                      ' IS ''CLASIF:' || v_nivel || '''';
    n := n + 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('OK    ' || n || ' columnas etiquetadas');
END;
/

PROMPT --- 2) Restriccion por fila (VPD): cada docente ve solo sus notas y adecuaciones (A8.3)
CREATE OR REPLACE FUNCTION instituto.vpd_docente (p_esquema VARCHAR2, p_objeto VARCHAR2)
  RETURN VARCHAR2
IS
  v_id instituto.docentes.id_docente%TYPE;
BEGIN
  SELECT id_docente INTO v_id
    FROM instituto.docentes
   WHERE UPPER(usuario_bd) = SYS_CONTEXT('USERENV','SESSION_USER');
  RETURN 'id_docente = ' || v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;   -- las cuentas que no son docentes se rigen por sus roles
END;
/
DECLARE
  PROCEDURE politica(p_tabla VARCHAR2, p_nombre VARCHAR2, p_tipos VARCHAR2) IS
    v NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v FROM dba_policies
     WHERE object_owner = 'INSTITUTO' AND object_name = p_tabla AND policy_name = p_nombre;
    IF v > 0 THEN
      DBMS_RLS.DROP_POLICY('INSTITUTO', p_tabla, p_nombre);
    END IF;
    DBMS_RLS.ADD_POLICY(
      object_schema   => 'INSTITUTO',
      object_name     => p_tabla,
      policy_name     => p_nombre,
      function_schema => 'INSTITUTO',
      policy_function => 'VPD_DOCENTE',
      statement_types => p_tipos,
      update_check    => (INSTR(p_tipos, 'INSERT') > 0 OR INSTR(p_tipos, 'UPDATE') > 0));
    DBMS_OUTPUT.PUT_LINE('OK    politica ' || p_nombre || ' sobre ' || p_tabla || ' (' || p_tipos || ')');
  END;
BEGIN
  politica('NOTAS',        'P_DOCENTE_NOTAS',  'SELECT,INSERT,UPDATE,DELETE');
  politica('ADECUACIONES', 'P_DOCENTE_ADEC',   'SELECT');
END;
/

PROMPT --- 3) Redaccion de datos (A8.11): condicion de salud, ingreso familiar y cuenta bancaria
DECLARE
  PROCEDURE quitar(p_tabla VARCHAR2) IS
    v NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v FROM redaction_policies
     WHERE object_owner = 'INSTITUTO' AND object_name = p_tabla;
    IF v > 0 THEN
      DBMS_REDACT.DROP_POLICY('INSTITUTO', p_tabla, 'R_' || p_tabla);
    END IF;
  END;
BEGIN
  quitar('ADECUACIONES');
  quitar('BECAS');

  -- La condicion de salud solo la ve quien tiene el rol de docente (y los docentes ya ven solo las suyas)
  DBMS_REDACT.ADD_POLICY(
    object_schema => 'INSTITUTO', object_name => 'ADECUACIONES', policy_name => 'R_ADECUACIONES',
    column_name   => 'DETALLE_CONDICION', function_type => DBMS_REDACT.FULL,
    expression    => 'SYS_CONTEXT(''SYS_SESSION_ROLES'',''ROL_DOCENTE'') = ''FALSE''');

  -- Ingreso familiar y cuenta bancaria: solo tesoreria los ve completos
  DBMS_REDACT.ADD_POLICY(
    object_schema => 'INSTITUTO', object_name => 'BECAS', policy_name => 'R_BECAS',
    column_name   => 'INGRESO_FAMILIAR', function_type => DBMS_REDACT.FULL,
    expression    => 'SYS_CONTEXT(''SYS_SESSION_ROLES'',''ROL_TESORERIA'') = ''FALSE''');
  DBMS_REDACT.ALTER_POLICY(
    object_schema => 'INSTITUTO', object_name => 'BECAS', policy_name => 'R_BECAS',
    action => DBMS_REDACT.ADD_COLUMN, column_name => 'NUM_CUENTA', function_type => DBMS_REDACT.PARTIAL,
    function_parameters => 'VVVVVVVVVVVVVVVVVVVVVV,VVVVVVVVVVVVVVVVVVVVVV,*,1,18');
  DBMS_OUTPUT.PUT_LINE('OK    politicas de redaccion R_ADECUACIONES y R_BECAS');
END;
/

PROMPT --- 4) Clon INSTITUTO_DEV con datos enmascarados (A8.11, A8.33*)
BEGIN
  EXECUTE IMMEDIATE 'UPDATE instituto_dev.adecuaciones SET detalle_condicion = ''CONDICION ENMASCARADA'', recomendaciones = NULL';
  DBMS_OUTPUT.PUT_LINE('OK    adecuaciones del clon: ' || SQL%ROWCOUNT || ' filas enmascaradas');
  EXECUTE IMMEDIATE 'UPDATE instituto_dev.estudiantes SET cedula = ''D'' || LPAD(id_estudiante, 8, ''0''), '
                 || 'nombre = ''Estudiante '' || id_estudiante, fecha_nac = DATE ''2008-01-01'', telefono = NULL, '
                 || 'correo = NULL, direccion = NULL, encargado = NULL';
  DBMS_OUTPUT.PUT_LINE('OK    estudiantes del clon: ' || SQL%ROWCOUNT || ' filas enmascaradas');
  COMMIT;
END;
/

PROMPT --- 5) Resultado
COLUMN object_name FORMAT A16
COLUMN policy_name FORMAT A18
COLUMN column_name FORMAT A20
COLUMN function_type FORMAT A16
COLUMN function_parameters FORMAT A50
SELECT object_name, policy_name, sel, ins, upd, del, enable FROM dba_policies WHERE object_owner = 'INSTITUTO';
SELECT object_name, column_name, function_type, function_parameters FROM redaction_columns WHERE object_owner = 'INSTITUTO' ORDER BY 1, 2;
SELECT COUNT(*) AS columnas_sin_clasificar
  FROM dba_tab_columns c
  LEFT JOIN dba_col_comments m ON m.owner = c.owner AND m.table_name = c.table_name AND m.column_name = c.column_name
 WHERE c.owner = 'INSTITUTO' AND c.table_name NOT LIKE 'BIN$%'
   AND (m.comments IS NULL OR m.comments NOT LIKE 'CLASIF:%');

SPOOL OFF
EXIT
