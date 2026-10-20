# Guía de demostración en SQL*Plus — Estado "ANTES"

> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.

Paso a paso para mostrar en vivo el escenario Instituto Oracle Heredia y sus fallas de confidencialidad.

## Preparación

### Paso 0. Encender Oracle (solo después de reiniciar el equipo)

```
Start-Service OracleServiceXE
lsnrctl status
```

PowerShell como administrador. Debe aparecer el servicio xepdb1.

### Paso 1. Abrir una terminal en la carpeta del proyecto

```
cd C:\Users\josue\OneDrive\Desktop\BD_Oracle_confidencialidad_Iso27001
```

PowerShell normal.

### Paso 2. Entrar como administrador de la base

```
sqlplus sys as sysdba
```

La contraseña no se muestra al escribirla.

### Paso 3. Pasar a la base del proyecto y verificar dónde estoy

```
ALTER SESSION SET CONTAINER = XEPDB1;
SHOW CON_NAME
SET LINESIZE 200 PAGESIZE 100
COLUMN nombre FORMAT A30
COLUMN detalle_condicion FORMAT A60
```

Oracle XE es multitenant: los datos del instituto viven en la PDB XEPDB1, no en CDB$ROOT.

## Mostrar el escenario (los activos)

```
SELECT 'DOCENTES' tabla, COUNT(*) filas FROM instituto.docentes
UNION ALL SELECT 'ESTUDIANTES',  COUNT(*) FROM instituto.estudiantes
UNION ALL SELECT 'NOTAS',        COUNT(*) FROM instituto.notas
UNION ALL SELECT 'ADECUACIONES', COUNT(*) FROM instituto.adecuaciones
UNION ALL SELECT 'BECAS',        COUNT(*) FROM instituto.becas;

-- La columna de alta sensibilidad: condición de salud (dato sensible, Ley 8968)
SELECT e.nombre, a.tipo_adecuacion, a.detalle_condicion
  FROM instituto.adecuaciones a JOIN instituto.estudiantes e ON e.id_estudiante = a.id_estudiante
 FETCH FIRST 5 ROWS ONLY;

-- Las cuentas que acceden a la base
SELECT username, account_status, profile FROM dba_users WHERE oracle_maintained = 'N' ORDER BY username;
```

Cinco tablas con datos ficticios; la columna más sensible es DETALLE_CONDICION.

## Demostraciones: fallas entrando como otros usuarios

### Demo A — Una ex-secretaria lee diagnósticos de estudiantes (MP-03 y MP-05)

**Qué demuestra:** Una cuenta que ya no debería existir conserva acceso, y un permiso otorgado a PUBLIC llega a todas las cuentas, presentes y futuras.

```
CONNECT ex_ksalas/temporal@localhost:1521/XEPDB1

SELECT e.nombre, a.detalle_condicion
  FROM instituto.adecuaciones a JOIN instituto.estudiantes e ON e.id_estudiante = a.id_estudiante
 WHERE a.detalle_condicion LIKE 'F84%' FETCH FIRST 3 ROWS ONLY;
```

**Resultado ANTES:** Tres filas con nombres de estudiantes y el diagnóstico F84.0 Trastorno del espectro autista.

> **Qué vemos:** Una cuenta que debería estar dada de baja entra y lee las condiciones de salud de estudiantes menores de edad. Falla A5.16 porque la cuenta sigue activa, y A5.15 y A5.18 porque ADECUACIONES está otorgada a PUBLIC. Es un dato sensible según la Ley 8968.

### Demo B — Una docente ve las notas de todos los docentes (MP-07)

**Qué demuestra:** Sin restricción por filas, un usuario con permiso sobre una tabla ve todas sus filas, aunque su función solo requiera las suyas.

```
CONNECT doc_mchaves/Docente2026@localhost:1521/XEPDB1

SELECT COUNT(*) AS notas_visibles FROM instituto.notas;
SELECT id_docente, COUNT(*) FROM instituto.notas GROUP BY id_docente ORDER BY 1;
SELECT COUNT(*) AS adecuaciones_visibles FROM instituto.adecuaciones;
```

**Resultado ANTES:** 2000 notas visibles con filas de los 6 docentes, y 120 adecuaciones.

> **Qué vemos:** La profesora Chaves es la docente 1, pero ve las 2000 notas de los 6 docentes y las 120 adecuaciones, no solo lo suyo. Falta restringir por fila (A8.3) y ocultar la condición de salud (A8.11). VPD sí funciona en este XE 21c, así que es la corrección prevista.

### Demo C — Secretaría ve el ingreso familiar y la cuenta bancaria completa (MP-04)

**Qué demuestra:** Una cuenta compartida no deja rastro de quién actuó, y sin redacción un permiso de lectura muestra el dato completo.

```
CONNECT secretaria/secretaria@localhost:1521/XEPDB1

SELECT id_beca, tipo_beca, ingreso_familiar, num_cuenta
  FROM instituto.becas FETCH FIRST 3 ROWS ONLY;
```

**Resultado ANTES:** Tres filas con el ingreso familiar y la cuenta bancaria completa.

> **Qué vemos:** La cuenta la comparten todas las secretarias, así que no se sabe quién consultó (A5.16), y además muestra el ingreso familiar y la cuenta bancaria completos. Se corrige con cuentas nominales, roles y redacción (A8.11).

### Demo D — La aplicación de matrícula lee cualquier tabla (MP-02)

**Qué demuestra:** Un privilegio ANY otorgado a una cuenta de aplicación convierte cualquier vulnerabilidad de la aplicación en acceso a toda la base.

```
CONNECT app_matricula/app@localhost:1521/XEPDB1

SELECT COUNT(*) AS becas_que_ve_la_app FROM instituto.becas;
```

**Resultado ANTES:** 90 becas visibles.

> **Qué vemos:** La app solo debería tocar los datos de contacto de los estudiantes, pero lee todas las becas porque tiene SELECT ANY TABLE (A8.2). Si alguien vulnera la app, queda expuesta toda la base.

## Mostrar la evidencia observable que vería un auditor

```
CONNECT sys as sysdba
DEFINE fase = antes
@sql/01_verificacion/V07_A8_2_acceso_privilegiado.sql
```

El script guarda su salida con fecha, usuario y contenedor en evidencias/antes. Después de remediar se repite con fase = despues y se comparan.

## Cuentas del escenario (solo laboratorio, datos ficticios)

| Usuario | Contraseña | Mala práctica |
| --- | --- | --- |
| `ex_ksalas` | `temporal` | MP-05 cuenta de ex-empleada activa |
| `doc_mchaves` | `Docente2026` | MP-07 ve notas y adecuaciones de todos |
| `secretaria` | `secretaria` | MP-04 cuenta compartida |
| `app_matricula` | `app` | MP-02 SELECT ANY TABLE |
| `dev_ramiro` | `ramiro123` | MP-01 rol DBA |
| `teso_paula` | `Tesoreria1` | MP-06 WITH GRANT OPTION |
| `auditor_ext` | `Auditor2026` | MP-08 AUDIT_ADMIN |
| `soporte_ti` | `soporte` | MP-09 exportación completa |

