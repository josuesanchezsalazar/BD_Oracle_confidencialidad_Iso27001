# Prueba en vivo — Estado DESPUÉS

Las remediaciones R01-R05 ya están aplicadas. Esta prueba muestra los mismos ataques de [docs/guia-demo-sqlplus.md](docs/guia-demo-sqlplus.md), ahora bloqueados. Las contraseñas (ficticias, de laboratorio) están en [sql/02_remediacion/_claves.sql](sql/02_remediacion/_claves.sql).

## 0. Encender Oracle (PowerShell como administrador)

Según la nota del 21/10, la base quedó montada tras RMAN y los servicios estaban detenidos. No se ha comprobado si siguen así.

```powershell
Start-Service OracleServiceXE
Start-Service OracleOraDB21Home1TNSListener   # el nombre puede variar: Get-Service *Oracle*
lsnrctl status
```

```sql
sqlplus sys as sysdba
ALTER DATABASE OPEN;
ALTER PLUGGABLE DATABASE ALL OPEN;
```

## 1. Preparar la sesión

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
SHOW CON_NAME
SET LINESIZE 200 PAGESIZE 100
COLUMN nombre FORMAT A30
COLUMN detalle_condicion FORMAT A60
```

## 2. Pruebas en vivo

### A. Ex-secretaria — la cuenta ya no entra

```sql
CONNECT ex_ksalas/temporal@localhost:1521/XEPDB1
-- Esperado: ORA-01017 o la cuenta no existe / está bloqueada
```

### B. Docente — VPD le deja ver solo lo suyo y la condición de salud sale redactada

```sql
CONNECT doc_mchaves/"Dc#Mc2026!zk"@localhost:1521/XEPDB1
SELECT COUNT(*) AS notas_visibles FROM instituto.notas;                 -- antes 2000, ahora solo las suyas
SELECT id_docente, COUNT(*) FROM instituto.notas GROUP BY id_docente;   -- un solo docente
SELECT e.nombre, a.detalle_condicion
  FROM instituto.adecuaciones a JOIN instituto.estudiantes e ON e.id_estudiante = a.id_estudiante
 FETCH FIRST 3 ROWS ONLY;                                               -- detalle redactado
```

### C. Secretaría con cuenta nominal — ve la cuenta bancaria enmascarada

```sql
CONNECT sec_laraya/"Sc#La2026!zk"@localhost:1521/XEPDB1
SELECT id_beca, tipo_beca, ingreso_familiar, num_cuenta
  FROM instituto.becas FETCH FIRST 3 ROWS ONLY;
CONNECT secretaria/secretaria@localhost:1521/XEPDB1   -- cuenta compartida: debe fallar
```

### D. App de matrícula — ya no tiene SELECT ANY TABLE

```sql
CONNECT app_matricula/"Ap#Mt2026!zk"@localhost:1521/XEPDB1
SELECT COUNT(*) FROM instituto.becas;   -- Esperado: ORA-00942
```

## 3. Evidencia para el auditor

```sql
CONNECT sys/<clave> as sysdba
ALTER SESSION SET CONTAINER = XEPDB1;
DEFINE fase = despues
@sql/01_verificacion/V07_A8_2_acceso_privilegiado.sql
-- o todo junto:
@sql/01_verificacion/V00_ejecutar_todo.sql
```

## Limitaciones

- Nada de esto se ha ejecutado. Los resultados esperados salen de la guía y de los scripts R01-R05, no de una corrida.
- Para el cifrado de red (R06a) y la prueba PT-19 aún se necesita administrador.
- Para mostrar el contraste ANTES/DESPUÉS, [docs/guia-demo-sqlplus.md](docs/guia-demo-sqlplus.md) trae los comandos del estado ANTES. Esas cuentas ya no responden igual, salvo que se corra [99_limpiar_escenario.sql](sql/00_escenario/99_limpiar_escenario.sql) y luego [00_crear_escenario.sql](sql/00_escenario/00_crear_escenario.sql) para reiniciar.
