-- =====================================================================
-- 00_crear_escenario.sql | Centro Medico Los Robles - estado "ANTES"
-- Crea el esquema CLINICA con datos ficticios y siembra MALAS PRACTICAS
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

PROMPT === 1) Tablespace TS_CLINICA (misma carpeta que los datafiles de XEPDB1)
DECLARE
  v_dir VARCHAR2(513);
BEGIN
  SELECT SUBSTR(file_name, 1, INSTR(file_name, '\', -1))
    INTO v_dir
    FROM dba_data_files
   WHERE tablespace_name = 'SYSTEM';
  EXECUTE IMMEDIATE 'CREATE TABLESPACE ts_clinica DATAFILE ''' || v_dir ||
                    'ts_clinica01.dbf'' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G';
  DBMS_OUTPUT.PUT_LINE('Datafile creado: ' || v_dir || 'ts_clinica01.dbf');
END;
/

PROMPT === 2) Esquema CLINICA
CREATE USER clinica IDENTIFIED BY "Clinica2026"
  DEFAULT TABLESPACE ts_clinica QUOTA UNLIMITED ON ts_clinica;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO clinica;

PROMPT === 3) Tablas
CREATE TABLE clinica.medicos (
  id_medico        NUMBER(4)     CONSTRAINT pk_medicos PRIMARY KEY,
  nombre           VARCHAR2(80)  NOT NULL,
  especialidad     VARCHAR2(40)  NOT NULL,
  codigo_colegiado VARCHAR2(10)  NOT NULL,
  usuario_bd       VARCHAR2(128)
) TABLESPACE ts_clinica;

CREATE TABLE clinica.pacientes (
  id_paciente    NUMBER(6)     CONSTRAINT pk_pacientes PRIMARY KEY,
  cedula         VARCHAR2(12)  NOT NULL CONSTRAINT uq_pacientes_cedula UNIQUE,
  nombre         VARCHAR2(80)  NOT NULL,
  fecha_nac      DATE          NOT NULL,
  sexo           CHAR(1),
  telefono       VARCHAR2(9),
  correo         VARCHAR2(80),
  direccion      VARCHAR2(120),
  fecha_registro DATE
) TABLESPACE ts_clinica;

CREATE TABLE clinica.consultas (
  id_consulta   NUMBER(8)     CONSTRAINT pk_consultas PRIMARY KEY,
  id_paciente   NUMBER(6)     NOT NULL CONSTRAINT fk_consultas_paciente REFERENCES clinica.pacientes,
  id_medico     NUMBER(4)     NOT NULL CONSTRAINT fk_consultas_medico REFERENCES clinica.medicos,
  fecha         DATE          NOT NULL,
  motivo        VARCHAR2(120),
  diagnostico   VARCHAR2(120),
  tratamiento   VARCHAR2(200),
  notas_medicas VARCHAR2(400)
) TABLESPACE ts_clinica;

CREATE TABLE clinica.citas (
  id_cita     NUMBER(8)     CONSTRAINT pk_citas PRIMARY KEY,
  id_paciente NUMBER(6)     NOT NULL CONSTRAINT fk_citas_paciente REFERENCES clinica.pacientes,
  id_medico   NUMBER(4)     NOT NULL CONSTRAINT fk_citas_medico REFERENCES clinica.medicos,
  fecha_hora  DATE          NOT NULL,
  estado      VARCHAR2(12)  NOT NULL
) TABLESPACE ts_clinica;

CREATE TABLE clinica.facturas (
  id_factura    NUMBER(8)     CONSTRAINT pk_facturas PRIMARY KEY,
  id_consulta   NUMBER(8)     CONSTRAINT fk_facturas_consulta REFERENCES clinica.consultas,
  id_paciente   NUMBER(6)     NOT NULL CONSTRAINT fk_facturas_paciente REFERENCES clinica.pacientes,
  fecha         DATE          NOT NULL,
  monto         NUMBER(10,2)  NOT NULL,
  metodo_pago   VARCHAR2(10)  NOT NULL,
  num_tarjeta   VARCHAR2(16),
  aseguradora   VARCHAR2(40),
  poliza_seguro VARCHAR2(20)
) TABLESPACE ts_clinica;

PROMPT === 4) Datos ficticios (6 medicos, 500 pacientes, 2000 consultas/facturas, 800 citas)
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
  aseguradoras t_lista := t_lista('Aseguradora Pacifica','Seguros del Valle','MediProteccion');
  notas      t_lista := t_lista('Signos vitales dentro de rango.',
                                'Se solicita hemograma y control en 15 dias.',
                                'Antecedentes familiares de diabetes.',
                                'Refiere episodios similares el ano anterior.',
                                'Se explica plan de tratamiento al paciente y acompanante.',
                                'Paciente fumador, se recomienda cesacion.');
  -- Formato: diagnostico | tratamiento | motivo de consulta
  diag_general t_lista := t_lista(
    'J06.9 Infeccion aguda de vias respiratorias superiores|Acetaminofen 500 mg c/8h por 5 dias|Fiebre y dolor de garganta',
    'K29.7 Gastritis no especificada|Omeprazol 20 mg en ayunas por 30 dias|Dolor abdominal',
    'M54.5 Lumbago|Ibuprofeno 400 mg c/8h y fisioterapia|Dolor lumbar',
    'N39.0 Infeccion de vias urinarias|Nitrofurantoina 100 mg c/12h por 7 dias|Ardor al orinar',
    'Z00.0 Examen medico general|Sin tratamiento, control anual|Chequeo anual',
    'F41.1 Trastorno de ansiedad generalizada|Referencia a psicologia y sertralina 50 mg|Ansiedad e insomnio',
    'F32.1 Episodio depresivo moderado|Fluoxetina 20 mg diaria y psicoterapia|Tristeza persistente',
    'E11.9 Diabetes mellitus tipo 2|Metformina 850 mg c/12h y dieta|Control de glicemia',
    'B20 Enfermedad por VIH|Terapia antirretroviral, control trimestral|Control de carga viral');
  diag_pediatria t_lista := t_lista(
    'J06.9 Infeccion aguda de vias respiratorias superiores|Acetaminofen pediatrico segun peso|Fiebre y tos',
    'J45.9 Asma|Salbutamol inhalado segun necesidad|Dificultad para respirar',
    'A09 Gastroenteritis infecciosa|Suero oral y dieta blanda|Diarrea y vomito',
    'H66.9 Otitis media|Amoxicilina pediatrica por 7 dias|Dolor de oido',
    'Z00.1 Control de nino sano|Vacunacion al dia, control en 6 meses|Control de crecimiento',
    'L20.9 Dermatitis atopica|Crema hidratante y antihistaminico|Lesiones en la piel');
  diag_cardio t_lista := t_lista(
    'I10 Hipertension esencial|Losartan 50 mg diario y dieta baja en sodio|Control de presion arterial',
    'I25.1 Cardiopatia aterosclerotica|Aspirina 100 mg y atorvastatina 40 mg|Dolor de pecho al esfuerzo',
    'I48 Fibrilacion auricular|Anticoagulacion y control de frecuencia|Palpitaciones',
    'I50.9 Insuficiencia cardiaca|Furosemida 40 mg y enalapril|Cansancio y edema en piernas',
    'E78.5 Hiperlipidemia|Atorvastatina 20 mg nocturna|Colesterol elevado');

  v_sexo   CHAR(1);
  v_nombre VARCHAR2(80);
  v_nac    DATE;
  v_pac    NUMBER;
  v_med    NUMBER;
  v_reg    VARCHAR2(200);
  v_fecha  DATE;
  v_metodo VARCHAR2(10);
  v_tarj   VARCHAR2(16);
  v_aseg   VARCHAR2(40);
  v_poliza VARCHAR2(20);
  v_estado VARCHAR2(12);
  v_cedula VARCHAR2(12);
  v_tel    VARCHAR2(9);
  v_correo VARCHAR2(80);
  v_dir    VARCHAR2(120);
  v_nota   VARCHAR2(400);
  v_diag   VARCHAR2(120);
  v_trat   VARCHAR2(200);
  v_motivo VARCHAR2(120);

  FUNCTION elegir(p t_lista) RETURN VARCHAR2 IS
  BEGIN
    RETURN p(TRUNC(DBMS_RANDOM.VALUE(1, p.COUNT + 1)));
  END;

  -- Pediatras (3,4) atienden menores (id_paciente <= 120); el resto: general (1,2) o cardiologia (5,6)
  FUNCTION medico_para(p_pac NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_pac <= 120 THEN
      RETURN TRUNC(DBMS_RANDOM.VALUE(3, 5));
    END IF;
    RETURN CASE TRUNC(DBMS_RANDOM.VALUE(1, 5)) WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 5 ELSE 6 END;
  END;
BEGIN
  DBMS_RANDOM.SEED(2026);

  INSERT INTO clinica.medicos VALUES (1, 'Dra. Laura Solis Campos',  'Medicina General', 'MED-10234', 'MED_LSOLIS');
  INSERT INTO clinica.medicos VALUES (2, 'Dr. Andres Mora Arias',    'Medicina General', 'MED-11872', NULL);
  INSERT INTO clinica.medicos VALUES (3, 'Dra. Paula Chaves Monge',  'Pediatria',        'MED-09541', NULL);
  INSERT INTO clinica.medicos VALUES (4, 'Dr. Diego Rojas Calderon', 'Pediatria',        'MED-12650', NULL);
  INSERT INTO clinica.medicos VALUES (5, 'Dra. Elena Vargas Brenes', 'Cardiologia',      'MED-08317', 'MED_EVARGAS');
  INSERT INTO clinica.medicos VALUES (6, 'Dr. Mario Quesada Salas',  'Cardiologia',      'MED-13009', NULL);

  FOR i IN 1 .. 500 LOOP
    v_sexo   := CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'F' ELSE 'M' END;
    v_nombre := CASE v_sexo WHEN 'F' THEN elegir(nombres_f) ELSE elegir(nombres_m) END
                || ' ' || elegir(apellidos) || ' ' || elegir(apellidos);
    v_nac    := CASE WHEN i <= 120
                     THEN DATE '2012-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 4700))
                     ELSE DATE '1940-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 23000)) END;
    v_cedula := TRUNC(DBMS_RANDOM.VALUE(1, 8)) || '-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(100, 1300)), 4, '0')
                || '-' || LPAD(i, 4, '0');
    v_tel    := CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN '8' ELSE '6' END
                || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 9999999)), 7, '0');
    v_correo := LOWER(REPLACE(v_nombre, ' ', '.')) || i || '@correo.test';
    v_dir    := elegir(lugares) || ', ' || TRUNC(DBMS_RANDOM.VALUE(25, 500)) || ' m '
                || elegir(rumbos) || ' de la iglesia';
    INSERT INTO clinica.pacientes
    VALUES (i, v_cedula, v_nombre, v_nac, v_sexo, v_tel, v_correo, v_dir,
            DATE '2023-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1000)));
  END LOOP;

  FOR i IN 1 .. 2000 LOOP
    v_pac   := TRUNC(DBMS_RANDOM.VALUE(1, 501));
    v_med   := medico_para(v_pac);
    v_reg   := CASE WHEN v_med IN (3, 4) THEN elegir(diag_pediatria)
                    WHEN v_med IN (5, 6) THEN elegir(diag_cardio)
                    ELSE elegir(diag_general) END;
    v_fecha := DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1000))
               + TRUNC(DBMS_RANDOM.VALUE(7, 17)) / 24;
    v_diag   := REGEXP_SUBSTR(v_reg, '[^|]+', 1, 1);
    v_trat   := REGEXP_SUBSTR(v_reg, '[^|]+', 1, 2);
    v_motivo := REGEXP_SUBSTR(v_reg, '[^|]+', 1, 3);
    v_nota   := 'Paciente consciente y orientado. ' || elegir(notas);
    INSERT INTO clinica.consultas
    VALUES (i, v_pac, v_med, v_fecha, v_motivo, v_diag, v_trat, v_nota);

    v_metodo := CASE TRUNC(DBMS_RANDOM.VALUE(1, 4)) WHEN 1 THEN 'TARJETA' WHEN 2 THEN 'EFECTIVO' ELSE 'SEGURO' END;
    v_tarj   := NULL; v_aseg := NULL; v_poliza := NULL;
    IF v_metodo = 'TARJETA' THEN
      v_tarj := '4' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 999999999999999)), 15, '0');
    ELSIF v_metodo = 'SEGURO' THEN
      v_aseg   := elegir(aseguradoras);
      v_poliza := 'POL-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 999999)), 6, '0');
    END IF;
    INSERT INTO clinica.facturas
    VALUES (i, i, v_pac, TRUNC(v_fecha), ROUND(DBMS_RANDOM.VALUE(25000, 150000), -2),
            v_metodo, v_tarj, v_aseg, v_poliza);
  END LOOP;

  FOR i IN 1 .. 800 LOOP
    v_pac    := TRUNC(DBMS_RANDOM.VALUE(1, 501));
    v_med    := medico_para(v_pac);
    v_estado := CASE TRUNC(DBMS_RANDOM.VALUE(1, 5)) WHEN 1 THEN 'CANCELADA' WHEN 2 THEN 'ATENDIDA' ELSE 'PROGRAMADA' END;
    INSERT INTO clinica.citas
    VALUES (i, v_pac, v_med,
            DATE '2026-09-01' + TRUNC(DBMS_RANDOM.VALUE(0, 120)) + TRUNC(DBMS_RANDOM.VALUE(7, 17)) / 24,
            v_estado);
  END LOOP;

  COMMIT;
END;
/

-- =====================================================================
-- 5) MALAS PRACTICAS DELIBERADAS (estado ANTES)
-- =====================================================================
PROMPT === 5) Malas practicas deliberadas

-- MP-01 | R-CONF-01 | A8.2: desarrollador con rol DBA y contrasena debil
CREATE USER dev_carlos IDENTIFIED BY "carlos123";
GRANT CREATE SESSION, DBA TO dev_carlos;

-- MP-02 | R-CONF-01 | A8.2, A5.15: la aplicacion de citas puede leer CUALQUIER tabla
CREATE USER app_citas IDENTIFIED BY "app";
GRANT CREATE SESSION, SELECT ANY TABLE TO app_citas;
GRANT INSERT, UPDATE ON clinica.citas TO app_citas;

-- MP-03 | R-CONF-01 | A5.15, A5.18, A8.3: diagnosticos visibles para TODOS (PUBLIC)
GRANT SELECT ON clinica.consultas TO PUBLIC;

-- MP-04 | R-CONF-02 | A5.16, A5.15: cuenta COMPARTIDA de recepcion con grants directos excesivos
CREATE USER recepcion IDENTIFIED BY "recepcion";
GRANT CREATE SESSION TO recepcion;
GRANT SELECT ON clinica.pacientes TO recepcion;
GRANT SELECT ON clinica.facturas  TO recepcion;
GRANT SELECT, INSERT, UPDATE ON clinica.citas TO recepcion;

-- MP-05 | R-CONF-02 | A5.16: recepcionista que renuncio y su cuenta sigue activa
CREATE USER ex_mrojas IDENTIFIED BY "temporal";
GRANT CREATE SESSION TO ex_mrojas;
GRANT SELECT ON clinica.pacientes TO ex_mrojas;

-- MP-06 | R-CONF-01 | A5.18: facturacion puede re-otorgar acceso (WITH GRANT OPTION)
CREATE USER fact_ana IDENTIFIED BY "Factura1";
GRANT CREATE SESSION TO fact_ana;
GRANT SELECT, UPDATE ON clinica.facturas TO fact_ana WITH GRANT OPTION;
GRANT SELECT ON clinica.pacientes TO fact_ana;

-- MP-07 | R-CONF-01 | A8.3: cada medico ve las consultas de TODOS los pacientes (sin VPD)
CREATE USER med_lsolis  IDENTIFIED BY "Medico2026";
CREATE USER med_evargas IDENTIFIED BY "Medico2026";
GRANT CREATE SESSION TO med_lsolis, med_evargas;
GRANT SELECT, INSERT, UPDATE ON clinica.consultas TO med_lsolis;
GRANT SELECT, INSERT, UPDATE ON clinica.consultas TO med_evargas;
GRANT SELECT ON clinica.pacientes TO med_lsolis;
GRANT SELECT ON clinica.pacientes TO med_evargas;

-- MP-08 | R-CONF-06 | A5.33: auditor externo con AUDIT_ADMIN (puede purgar el rastro)
CREATE USER auditor_ext IDENTIFIED BY "Auditor2026";
GRANT CREATE SESSION, AUDIT_ADMIN TO auditor_ext;

-- MP-09 | R-CONF-04 | A8.12: soporte exporta toda la BD y el directorio esta abierto a PUBLIC
CREATE USER soporte_ti IDENTIFIED BY "soporte";
GRANT CREATE SESSION, DATAPUMP_EXP_FULL_DATABASE TO soporte_ti;
CREATE OR REPLACE DIRECTORY dir_exportes AS 'C:\oracle_lab\exportes';
GRANT READ, WRITE ON DIRECTORY dir_exportes TO PUBLIC;

-- MP-10 | R-CONF-03 | A8.10: copia de pacientes "borrada" que sigue en la papelera
CREATE TABLE clinica.pacientes_respaldo_2025 TABLESPACE ts_clinica
  AS SELECT * FROM clinica.pacientes;
DROP TABLE clinica.pacientes_respaldo_2025;

-- MP-11 | R-CONF-04 | A8.11, A8.33*: clon DEV con datos REALES sin enmascarar
CREATE USER clinica_dev IDENTIFIED BY "dev"
  DEFAULT TABLESPACE ts_clinica QUOTA UNLIMITED ON ts_clinica;
GRANT CREATE SESSION TO clinica_dev;
CREATE TABLE clinica_dev.pacientes TABLESPACE ts_clinica AS SELECT * FROM clinica.pacientes;
CREATE TABLE clinica_dev.consultas TABLESPACE ts_clinica AS SELECT * FROM clinica.consultas;

-- MP-12 | R-CONF-02 | A8.5, A5.17: perfil sin limite de intentos fallidos (fuerza bruta)
CREATE PROFILE perfil_aplicaciones LIMIT
  FAILED_LOGIN_ATTEMPTS UNLIMITED
  PASSWORD_LIFE_TIME    UNLIMITED;
ALTER USER app_citas PROFILE perfil_aplicaciones;

-- Nota: no hay clasificacion (A5.12), ni auditoria propia (A8.15), ni redaccion (A8.11),
-- ni TDE (A8.24*), ni cifrado de red (A8.20): esa ausencia ES parte del estado ANTES.

WHENEVER SQLERROR CONTINUE
PROMPT === 6) Resumen
SELECT 'MEDICOS' tabla, COUNT(*) filas FROM clinica.medicos
UNION ALL SELECT 'PACIENTES', COUNT(*) FROM clinica.pacientes
UNION ALL SELECT 'CONSULTAS', COUNT(*) FROM clinica.consultas
UNION ALL SELECT 'CITAS',     COUNT(*) FROM clinica.citas
UNION ALL SELECT 'FACTURAS',  COUNT(*) FROM clinica.facturas;

SELECT owner, original_name, droptime FROM dba_recyclebin WHERE owner = 'CLINICA';

PROMPT Escenario creado. Siguiente paso: V00_ejecutar_todo.sql antes
EXIT
