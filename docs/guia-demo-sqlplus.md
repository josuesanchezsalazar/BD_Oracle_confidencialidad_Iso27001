# Guía de demostración en SQL*Plus — Estado "ANTES"

Paso a paso para mostrar en vivo el escenario del Centro Médico Los Robles y sus fallas de confidencialidad.

---

## Paso 0. Encender Oracle (solo después de reiniciar la PC)

PowerShell **como administrador** (clic derecho → *Ejecutar como administrador*):

```powershell
Start-Service OracleServiceXE
lsnrctl status
```

Debe aparecer el servicio `xepdb1` en el resumen. Si el listener no está arriba: `lsnrctl start`.

## Paso 1. Abrir una terminal en el repositorio

PowerShell normal (no hace falta administrador):

```powershell
cd C:\Users\josue\OneDrive\Desktop\BD_Oracle_confidencialidad_Iso27001
```

## Paso 2. Entrar como administrador de la base de datos

```powershell
sqlplus sys as sysdba
```

Escribir la contraseña cuando la pida (no se ve en pantalla).

## Paso 3. Pasar a la base del proyecto y verificar dónde estoy

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
SHOW CON_NAME
SHOW USER

SET LINESIZE 200 PAGESIZE 100
COLUMN nombre      FORMAT A30
COLUMN diagnostico FORMAT A50
COLUMN username    FORMAT A15
COLUMN profile     FORMAT A20
```

> Qué decir: "Oracle 21c XE es multitenant. `CDB$ROOT` es el contenedor raíz; los datos de la clínica viven en la PDB `XEPDB1`."

## Paso 4. Mostrar el escenario (los activos)

```sql
-- Tablas del esquema y cantidad de filas
SELECT 'MEDICOS' tabla, COUNT(*) filas FROM clinica.medicos
UNION ALL SELECT 'PACIENTES', COUNT(*) FROM clinica.pacientes
UNION ALL SELECT 'CONSULTAS', COUNT(*) FROM clinica.consultas
UNION ALL SELECT 'CITAS',     COUNT(*) FROM clinica.citas
UNION ALL SELECT 'FACTURAS',  COUNT(*) FROM clinica.facturas;

-- La columna de alta sensibilidad: diagnóstico (dato sensible de salud, Ley 8968)
SELECT p.nombre, c.fecha, c.diagnostico
  FROM clinica.consultas c JOIN clinica.pacientes p ON p.id_paciente = c.id_paciente
 FETCH FIRST 5 ROWS ONLY;

-- Las cuentas que acceden a la base
SELECT username, account_status, profile
  FROM dba_users WHERE oracle_maintained = 'N' ORDER BY username;
```

## Paso 5. Demostrar las fallas entrando como otros usuarios

### Demo A — Una ex-empleada ve diagnósticos de VIH (MP-03 + MP-05)

```sql
CONNECT ex_mrojas/temporal@localhost:1521/XEPDB1

SELECT p.nombre, c.diagnostico
  FROM clinica.consultas c JOIN clinica.pacientes p ON p.id_paciente = c.id_paciente
 WHERE c.diagnostico LIKE 'B20%' FETCH FIRST 3 ROWS ONLY;
```

> Qué decir: "Esta recepcionista renunció y su cuenta sigue activa (A5.16). Además, `CONSULTAS` está otorgada a `PUBLIC`, así que **cualquier** cuenta lee diagnósticos (A5.15, A5.18). Es un dato sensible según la Ley 8968."

### Demo B — Un médico ve los pacientes de todos los médicos (MP-07)

```sql
CONNECT med_lsolis/Medico2026@localhost:1521/XEPDB1

SELECT COUNT(*) AS consultas_visibles FROM clinica.consultas;
SELECT id_medico, COUNT(*) FROM clinica.consultas GROUP BY id_medico ORDER BY 1;
```

> Qué decir: "La Dra. Solís es el médico 1, pero ve las 2000 consultas de los 6 médicos. Falta restricción por fila (A8.3); se corrige con VPD."

### Demo C — Recepción ve números de tarjeta completos (MP-04)

```sql
CONNECT recepcion/recepcion@localhost:1521/XEPDB1

SELECT id_factura, metodo_pago, num_tarjeta
  FROM clinica.facturas WHERE num_tarjeta IS NOT NULL FETCH FIRST 3 ROWS ONLY;
```

> Qué decir: "Es una cuenta compartida por todas las recepcionistas (sin trazabilidad, A5.16) y ve tarjetas completas. Se corrige con cuentas nominales, roles y redacción (A8.11)."

### Demo D — La aplicación de citas lee cualquier tabla (MP-02)

```sql
CONNECT app_citas/app@localhost:1521/XEPDB1

SELECT COUNT(*) AS facturas_que_ve_la_app FROM clinica.facturas;
```

> Qué decir: "La app solo maneja citas, pero tiene `SELECT ANY TABLE` (A8.2): si la app es vulnerada, el atacante lee toda la base."

## Paso 6. Mostrar la evidencia observable (lo que vería un auditor)

Volver como administrador y ejecutar un script de verificación en vivo:

```sql
CONNECT sys as sysdba
DEFINE fase = antes
@sql/01_verificacion/V07_A8_2_acceso_privilegiado.sql
```

> Qué decir: "Cada control tiene un script de verificación que guarda su salida con fecha, usuario y contenedor en `evidencias/antes/`. Después de remediar, el mismo script se corre con `fase = despues` y se comparan los resultados."

Ver el archivo generado:

```sql
HOST dir evidencias\antes
```

## Paso 7. Salir

```sql
EXIT
```

---

### Tabla rápida de usuarios del escenario (solo laboratorio, datos ficticios)

| Usuario | Contraseña | Mala práctica |
|---------|------------|---------------|
| `ex_mrojas` | `temporal` | MP-05 cuenta de ex-empleada activa |
| `med_lsolis` | `Medico2026` | MP-07 ve consultas de todos |
| `recepcion` | `recepcion` | MP-04 cuenta compartida |
| `app_citas` | `app` | MP-02 `SELECT ANY TABLE` |
| `dev_carlos` | `carlos123` | MP-01 rol `DBA` |
| `fact_ana` | `Factura1` | MP-06 `WITH GRANT OPTION` |
| `auditor_ext` | `Auditor2026` | MP-08 `AUDIT_ADMIN` |
| `soporte_ti` | `soporte` | MP-09 exportación completa |
