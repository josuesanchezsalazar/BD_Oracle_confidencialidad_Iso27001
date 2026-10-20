-- =====================================================================
-- 00_crear_escenario.sql | Instituto Oracle Heredia - estado "ANTES"
-- Crea el esquema INSTITUTO con datos ficticios y siembra MALAS PRACTICAS
-- deliberadas (MP-01..MP-12) que luego se diagnostican y remedian.
--
-- Uso (desde la raiz del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/00_escenario/00_crear_escenario.sql"
-- Para repetir desde cero, ejecutar antes 99_limpiar_escenario.sql
-- Todos los datos son ficticios (generados con DBMS_RANDOM, semilla fija).
-- =====================================================================
SET ECHO OFF FEEDBACK ON SERVEROUTPUT ON VERIFY OFF
ALTER SESSION SET CONTAINER = XEPDB1;
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

PROMPT === 1) Tablespace TS_INSTITUTO (misma carpeta que los datafiles de XEPDB1)
DECLARE
  v_dir VARCHAR2(513);
BEGIN
  SELECT SUBSTR(file_name, 1, INSTR(file_name, '\', -1))
    INTO v_dir
    FROM dba_data_files
   WHERE tablespace_name = 'SYSTEM';
  EXECUTE IMMEDIATE 'CREATE TABLESPACE ts_instituto DATAFILE ''' || v_dir ||
                    'ts_instituto01.dbf'' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G';
  DBMS_OUTPUT.PUT_LINE('Datafile creado: ' || v_dir || 'ts_instituto01.dbf');
END;
/

PROMPT === 2) Esquema INSTITUTO
CREATE USER instituto IDENTIFIED BY "Instituto2026"
  DEFAULT TABLESPACE ts_instituto QUOTA UNLIMITED ON ts_instituto;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO instituto;

PROMPT === 3) Tablas
CREATE TABLE instituto.docentes (
  id_docente      NUMBER(4)     CONSTRAINT pk_docentes PRIMARY KEY,
  nombre          VARCHAR2(80)  NOT NULL,
  especialidad    VARCHAR2(40)  NOT NULL,
  codigo_empleado VARCHAR2(10)  NOT NULL,
  usuario_bd      VARCHAR2(128)
) TABLESPACE ts_instituto;

CREATE TABLE instituto.estudiantes (
  id_estudiante NUMBER(6)     CONSTRAINT pk_estudiantes PRIMARY KEY,
  cedula        VARCHAR2(12)  NOT NULL CONSTRAINT uq_estudiantes_cedula UNIQUE,
  nombre        VARCHAR2(80)  NOT NULL,
  fecha_nac     DATE          NOT NULL,
  sexo          CHAR(1),
  grupo         VARCHAR2(6)   NOT NULL,
  telefono      VARCHAR2(9),
  correo        VARCHAR2(80),
  direccion     VARCHAR2(120),
  encargado     VARCHAR2(80),
  fecha_ingreso DATE
) TABLESPACE ts_instituto;

CREATE TABLE instituto.notas (
  id_nota       NUMBER(8)     CONSTRAINT pk_notas PRIMARY KEY,
  id_estudiante NUMBER(6)     NOT NULL CONSTRAINT fk_notas_estudiante REFERENCES instituto.estudiantes,
  id_docente    NUMBER(4)     NOT NULL CONSTRAINT fk_notas_docente REFERENCES instituto.docentes,
  materia       VARCHAR2(40)  NOT NULL,
  periodo       VARCHAR2(8)   NOT NULL,
  nota          NUMBER(5,2)   NOT NULL
) TABLESPACE ts_instituto;

CREATE TABLE instituto.adecuaciones (
  id_adecuacion     NUMBER(6)     CONSTRAINT pk_adecuaciones PRIMARY KEY,
  id_estudiante     NUMBER(6)     NOT NULL CONSTRAINT fk_adec_estudiante REFERENCES instituto.estudiantes,
  id_docente        NUMBER(4)     NOT NULL CONSTRAINT fk_adec_docente REFERENCES instituto.docentes,
  tipo_adecuacion   VARCHAR2(20)  NOT NULL,
  detalle_condicion VARCHAR2(120) NOT NULL,
  recomendaciones   VARCHAR2(200),
  fecha_resolucion  DATE          NOT NULL
) TABLESPACE ts_instituto;

CREATE TABLE instituto.becas (
  id_beca          NUMBER(6)     CONSTRAINT pk_becas PRIMARY KEY,
  id_estudiante    NUMBER(6)     NOT NULL CONSTRAINT fk_becas_estudiante REFERENCES instituto.estudiantes,
  tipo_beca        VARCHAR2(20)  NOT NULL,
  ingreso_familiar NUMBER(10,2)  NOT NULL,
  monto_mensual    NUMBER(10,2)  NOT NULL,
  num_cuenta       VARCHAR2(22),
  fecha_aprobacion DATE          NOT NULL
) TABLESPACE ts_instituto;

PROMPT === 4) Datos ficticios (6 docentes, 500 estudiantes, 2000 notas, 120 adecuaciones, 90 becas)
DECLARE
  TYPE t_lista IS TABLE OF VARCHAR2(200);
  nombres_f  t_lista := t_lista('Maria','Ana','Laura','Sofia','Valeria','Daniela','Carolina',
                                'Gabriela','Fernanda','Lucia','Monica','Adriana');
  nombres_m  t_lista := t_lista('Jose','Luis','Carlos','Andres','Diego','Javier','Pablo',
                                'Mario','Esteban','Sebastian','Ricardo','Felipe');
  apellidos  t_lista := t_lista('Rodriguez','Vargas','Jimenez','Mora','Rojas','Araya','Solis',
                                'Quesada','Chaves','Alfaro','Castro','Hernandez','Ramirez',
                                'Salas','Brenes','Campos','Arias','Calderon','Monge','Picado');
  lugares    t_lista := t_lista('Heredia centro','San Pablo','Santo Domingo','Barva',
                                'San Rafael','Belen','Flores','San Isidro');
  rumbos     t_lista := t_lista('norte','sur','este','oeste');
  grupos     t_lista := t_lista('10-1','10-2','10-3','11-1','11-2','11-3','12-1','12-2','12-3');
  periodos   t_lista := t_lista('2025-II','2026-I','2026-II');
  tipos_adec t_lista := t_lista('Acceso','No significativa','Significativa');
  tipos_beca t_lista := t_lista('Transporte','Alimentacion','Socioeconomica');
  -- Condiciones (codigos CIE-10) que justifican una adecuacion curricular
  condiciones t_lista := t_lista(
    'F90.0 Trastorno por deficit de atencion con hiperactividad',
    'F81.0 Trastorno especifico de la lectura (dislexia)',
    'F84.0 Trastorno del espectro autista',
    'H90 Hipoacusia',
    'H54 Discapacidad visual',
    'G40 Epilepsia',
    'E10 Diabetes mellitus tipo 1',
    'F41.1 Trastorno de ansiedad generalizada',
    'F32.1 Episodio depresivo moderado');
  recomendaciones t_lista := t_lista(
    'Tiempo adicional en las evaluaciones',
    'Ubicacion cercana a la pizarra',
    'Material en formato ampliado',
    'Pausas durante las pruebas',
    'Apoyo de un docente de educacion especial',
    'Acompanamiento del departamento de orientacion');

  v_sexo   CHAR(1);
  v_nombre VARCHAR2(80);
  v_est    NUMBER;
  v_doc    NUMBER;
  v_cedula VARCHAR2(12);
  v_tel    VARCHAR2(9);
  v_correo VARCHAR2(80);
  v_dir    VARCHAR2(120);
  v_encarg VARCHAR2(80);
  v_grupo  VARCHAR2(6);
  v_mat    VARCHAR2(40);
  v_per    VARCHAR2(8);
  v_tipo   VARCHAR2(20);
  v_cond   VARCHAR2(120);
  v_reco   VARCHAR2(200);

  FUNCTION elegir(p t_lista) RETURN VARCHAR2 IS
  BEGIN
    RETURN p(TRUNC(DBMS_RANDOM.VALUE(1, p.COUNT + 1)));
  END;

  -- Cada docente imparte materias de su especialidad
  FUNCTION materia_de(p_doc NUMBER) RETURN VARCHAR2 IS
    v NUMBER := TRUNC(DBMS_RANDOM.VALUE(1, 3));
  BEGIN
    RETURN CASE p_doc
      WHEN 1 THEN CASE TRUNC(DBMS_RANDOM.VALUE(1, 4)) WHEN 1 THEN 'Programacion' WHEN 2 THEN 'Bases de datos' ELSE 'Redes' END
      WHEN 2 THEN CASE v WHEN 1 THEN 'Circuitos' ELSE 'Electronica digital' END
      WHEN 3 THEN CASE v WHEN 1 THEN 'Algebra' ELSE 'Estadistica' END
      WHEN 4 THEN CASE v WHEN 1 THEN 'Lengua' ELSE 'Literatura' END
      WHEN 5 THEN CASE v WHEN 1 THEN 'Fisica' ELSE 'Quimica' END
      ELSE        CASE v WHEN 1 THEN 'Ingles conversacional' ELSE 'Ingles tecnico' END
    END;
  END;
BEGIN
  DBMS_RANDOM.SEED(2026);

  INSERT INTO instituto.docentes VALUES (1, 'Prof. Maria Chaves Solis',    'Informatica', 'EMP-10234', 'DOC_MCHAVES');
  INSERT INTO instituto.docentes VALUES (2, 'Prof. Andres Mora Arias',     'Electronica', 'EMP-11872', NULL);
  INSERT INTO instituto.docentes VALUES (3, 'Prof. Paula Chaves Monge',    'Matematica',  'EMP-09541', NULL);
  INSERT INTO instituto.docentes VALUES (4, 'Prof. Diego Rojas Calderon',  'Espanol',     'EMP-12650', NULL);
  INSERT INTO instituto.docentes VALUES (5, 'Prof. Rebeca Brenes Salas',   'Ciencias',    'EMP-08317', 'DOC_RBRENES');
  INSERT INTO instituto.docentes VALUES (6, 'Prof. Mario Quesada Salas',   'Ingles',      'EMP-13009', NULL);

  FOR i IN 1 .. 500 LOOP
    v_sexo   := CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'F' ELSE 'M' END;
    v_nombre := CASE v_sexo WHEN 'F' THEN elegir(nombres_f) ELSE elegir(nombres_m) END
                || ' ' || elegir(apellidos) || ' ' || elegir(apellidos);
    v_cedula := TRUNC(DBMS_RANDOM.VALUE(1, 8)) || '-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(100, 1300)), 4, '0')
                || '-' || LPAD(i, 4, '0');
    v_tel    := CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN '8' ELSE '6' END
                || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 9999999)), 7, '0');
    v_correo := LOWER(REPLACE(v_nombre, ' ', '.')) || i || '@correo.test';
    v_dir    := elegir(lugares) || ', ' || TRUNC(DBMS_RANDOM.VALUE(25, 500)) || ' m '
                || elegir(rumbos) || ' de la iglesia';
    v_encarg := CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN elegir(nombres_f) ELSE elegir(nombres_m) END
                || ' ' || elegir(apellidos) || ' ' || elegir(apellidos);
    v_grupo  := elegir(grupos);
    INSERT INTO instituto.estudiantes
    VALUES (i, v_cedula, v_nombre,
            DATE '2008-09-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1500)),
            v_sexo, v_grupo, v_tel, v_correo, v_dir, v_encarg,
            DATE '2023-02-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1000)));
  END LOOP;

  FOR i IN 1 .. 2000 LOOP
    v_est := TRUNC(DBMS_RANDOM.VALUE(1, 501));
    v_doc := TRUNC(DBMS_RANDOM.VALUE(1, 7));
    v_mat := materia_de(v_doc);
    v_per := elegir(periodos);
    INSERT INTO instituto.notas
    VALUES (i, v_est, v_doc, v_mat, v_per, ROUND(DBMS_RANDOM.VALUE(45, 100), 1));
  END LOOP;

  FOR i IN 1 .. 120 LOOP
    v_est := TRUNC(DBMS_RANDOM.VALUE(1, 501));
    v_doc := TRUNC(DBMS_RANDOM.VALUE(1, 7));
    v_tipo := elegir(tipos_adec);
    v_cond := elegir(condiciones);
    v_reco := elegir(recomendaciones);
    INSERT INTO instituto.adecuaciones
    VALUES (i, v_est, v_doc, v_tipo, v_cond, v_reco,
            DATE '2024-02-01' + TRUNC(DBMS_RANDOM.VALUE(0, 900)));
  END LOOP;

  FOR i IN 1 .. 90 LOOP
    v_tipo := elegir(tipos_beca);
    INSERT INTO instituto.becas
    VALUES (i, i * 5, v_tipo,
            ROUND(DBMS_RANDOM.VALUE(150000, 900000), -3),
            ROUND(DBMS_RANDOM.VALUE(15000, 60000), -3),
            'CR' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 99)), 2, '0')
                 || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 999999999)), 9, '0')
                 || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 999999999)), 9, '0'),
            DATE '2025-02-01' + TRUNC(DBMS_RANDOM.VALUE(0, 600)));
  END LOOP;

  COMMIT;
END;
/

-- =====================================================================
-- 5) MALAS PRACTICAS DELIBERADAS (estado ANTES)
-- =====================================================================
PROMPT === 5) Malas practicas deliberadas

-- MP-01 | R-CONF-01 | A8.2: desarrollador con rol DBA y contrasena debil
CREATE USER dev_ramiro IDENTIFIED BY "ramiro123";
GRANT CREATE SESSION, DBA TO dev_ramiro;

-- MP-02 | R-CONF-01 | A8.2, A5.15: la aplicacion de matricula puede leer CUALQUIER tabla
CREATE USER app_matricula IDENTIFIED BY "app";
GRANT CREATE SESSION, SELECT ANY TABLE TO app_matricula;
GRANT INSERT, UPDATE ON instituto.estudiantes TO app_matricula;

-- MP-03 | R-CONF-01 | A5.15, A5.18, A8.3: adecuaciones (condiciones de salud) visibles para TODOS (PUBLIC)
GRANT SELECT ON instituto.adecuaciones TO PUBLIC;

-- MP-04 | R-CONF-02 | A5.16, A5.15: cuenta COMPARTIDA de secretaria con grants directos excesivos
CREATE USER secretaria IDENTIFIED BY "secretaria";
GRANT CREATE SESSION TO secretaria;
GRANT SELECT ON instituto.estudiantes TO secretaria;
GRANT SELECT ON instituto.becas       TO secretaria;
GRANT SELECT, INSERT, UPDATE ON instituto.notas TO secretaria;

-- MP-05 | R-CONF-02 | A5.16: secretaria que renuncio y su cuenta sigue activa
CREATE USER ex_ksalas IDENTIFIED BY "temporal";
GRANT CREATE SESSION TO ex_ksalas;
GRANT SELECT ON instituto.estudiantes TO ex_ksalas;

-- MP-06 | R-CONF-01 | A5.18: tesoreria puede re-otorgar acceso (WITH GRANT OPTION)
CREATE USER teso_paula IDENTIFIED BY "Tesoreria1";
GRANT CREATE SESSION TO teso_paula;
GRANT SELECT, UPDATE ON instituto.becas TO teso_paula WITH GRANT OPTION;
GRANT SELECT ON instituto.estudiantes TO teso_paula;

-- MP-07 | R-CONF-01 | A8.3: cada docente ve las notas y adecuaciones de TODOS los estudiantes (sin VPD)
CREATE USER doc_mchaves IDENTIFIED BY "Docente2026";
CREATE USER doc_rbrenes IDENTIFIED BY "Docente2026";
GRANT CREATE SESSION TO doc_mchaves, doc_rbrenes;
GRANT SELECT, INSERT, UPDATE ON instituto.notas TO doc_mchaves;
GRANT SELECT, INSERT, UPDATE ON instituto.notas TO doc_rbrenes;
GRANT SELECT ON instituto.adecuaciones TO doc_mchaves;
GRANT SELECT ON instituto.adecuaciones TO doc_rbrenes;
GRANT SELECT ON instituto.estudiantes  TO doc_mchaves;
GRANT SELECT ON instituto.estudiantes  TO doc_rbrenes;

-- MP-08 | R-CONF-06 | A5.33: auditor externo con AUDIT_ADMIN (puede purgar el rastro)
CREATE USER auditor_ext IDENTIFIED BY "Auditor2026";
GRANT CREATE SESSION, AUDIT_ADMIN TO auditor_ext;

-- MP-09 | R-CONF-04 | A8.12: soporte exporta toda la BD y el directorio esta abierto a PUBLIC
CREATE USER soporte_ti IDENTIFIED BY "soporte";
GRANT CREATE SESSION, DATAPUMP_EXP_FULL_DATABASE TO soporte_ti;
CREATE OR REPLACE DIRECTORY dir_exportes AS 'C:\oracle_lab\exportes';
GRANT READ, WRITE ON DIRECTORY dir_exportes TO PUBLIC;

-- MP-10 | R-CONF-03 | A8.10: copia de estudiantes "borrada" que sigue en la papelera
CREATE TABLE instituto.estudiantes_respaldo_2025 TABLESPACE ts_instituto
  AS SELECT * FROM instituto.estudiantes;
DROP TABLE instituto.estudiantes_respaldo_2025;

-- MP-11 | R-CONF-04 | A8.11, A8.33*: clon DEV con datos REALES sin enmascarar
CREATE USER instituto_dev IDENTIFIED BY "dev"
  DEFAULT TABLESPACE ts_instituto QUOTA UNLIMITED ON ts_instituto;
GRANT CREATE SESSION TO instituto_dev;
CREATE TABLE instituto_dev.estudiantes  TABLESPACE ts_instituto AS SELECT * FROM instituto.estudiantes;
CREATE TABLE instituto_dev.adecuaciones TABLESPACE ts_instituto AS SELECT * FROM instituto.adecuaciones;

-- MP-12 | R-CONF-02 | A8.5, A5.17: perfil sin limite de intentos fallidos (fuerza bruta)
CREATE PROFILE perfil_aplicaciones LIMIT
  FAILED_LOGIN_ATTEMPTS UNLIMITED
  PASSWORD_LIFE_TIME    UNLIMITED;
ALTER USER app_matricula PROFILE perfil_aplicaciones;

-- Nota: no hay clasificacion (A5.12), ni auditoria propia (A8.15), ni redaccion (A8.11),
-- ni TDE (A8.24*), ni cifrado de red (A8.20): esa ausencia ES parte del estado ANTES.

WHENEVER SQLERROR CONTINUE
PROMPT === 6) Resumen
SELECT 'DOCENTES' tabla, COUNT(*) filas FROM instituto.docentes
UNION ALL SELECT 'ESTUDIANTES',  COUNT(*) FROM instituto.estudiantes
UNION ALL SELECT 'NOTAS',        COUNT(*) FROM instituto.notas
UNION ALL SELECT 'ADECUACIONES', COUNT(*) FROM instituto.adecuaciones
UNION ALL SELECT 'BECAS',        COUNT(*) FROM instituto.becas;

SELECT owner, original_name, droptime FROM dba_recyclebin WHERE owner = 'INSTITUTO';

PROMPT Escenario creado. Siguiente paso: V00_ejecutar_todo.sql antes
EXIT
