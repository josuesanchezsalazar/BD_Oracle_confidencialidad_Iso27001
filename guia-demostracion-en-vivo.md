# Demostración en vivo del estado actual (DESPUÉS)

> Archivo generado desde `artefacto/src/data/scripts.json` con `npm run docs`. Para cambiarlo, edita ese JSON.

> **Aviso:** No ejecutes 99_limpiar_escenario.sql ni 00_crear_escenario.sql durante la demostración: devuelven la base al estado ANTES y borran la remediación. Para mostrar el ANTES usa las salidas guardadas en la pestaña ANTES.

## Paso 1. Encender Oracle y abrir la base

*PowerShell como administrador*

```
Get-Service Oracle*
Start-Service OracleServiceXE
Start-Service OracleOraDB21Home1TNSListener
```

```
sqlplus sys as sysdba
ALTER DATABASE OPEN;
ALTER PLUGGABLE DATABASE ALL OPEN;
SELECT name, open_mode FROM v$pdbs;
```

**Debe verse:** XEPDB1 en READ WRITE. Si la base ya estaba abierta, Oracle lo avisa y no pasa nada.

## Paso 2. Entrar por TCP a la base del proyecto

*PowerShell, en la carpeta del proyecto*

```
cd C:\Users\josue\OneDrive\Desktop\BD_Oracle_confidencialidad_Iso27001
sqlplus "sys@localhost:1521/XEPDB1 as sysdba"
```

**Debe verse:** Pide la contraseña de SYS (no se ve al escribir). Entrar por TCP, no local, activa el cifrado de red.

## Paso 3. Ver lo corregido con consultas cortas

*SQL*Plus*

```
SET LINESIZE 160 PAGESIZE 40
SHOW CON_NAME
-- 1) Nadie conserva el rol DBA salvo SYS y SYSTEM
SELECT grantee FROM dba_role_privs WHERE granted_role = 'DBA' AND grantee NOT IN ('SYS','SYSTEM');
-- 2) Ya no hay permisos a PUBLIC sobre INSTITUTO
SELECT COUNT(*) FROM dba_tab_privs WHERE grantee = 'PUBLIC' AND owner = 'INSTITUTO';
-- 3) Datos en reposo cifrados
SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = 'TS_INSTITUTO';
SELECT status, wallet_type FROM v$encryption_wallet;
-- 4) La sesión va cifrada por la red
SELECT network_service_banner FROM v$session_connect_info WHERE sid = SYS_CONTEXT('USERENV','SID') AND network_service_banner LIKE '%AES%';
```

**Debe verse:** 1) ninguna fila. 2) 0. 3) TS_INSTITUTO con YES y wallet OPEN. 4) AES256 Encryption service adapter.

## Paso 4. Mostrar la restricción por fila con una cuenta de docente

*SQL*Plus (la contraseña de DOC_MCHAVES está en sql/02_remediacion/_claves.sql)*

```
CONNECT doc_mchaves@localhost:1521/XEPDB1
SELECT COUNT(*) FROM instituto.notas;
CONNECT sys@localhost:1521/XEPDB1 AS SYSDBA
SELECT COUNT(*) FROM instituto.notas;
```

**Debe verse:** El docente ve solo sus notas (346); SYS ve las 2000. Antes de remediar veía todas.

## Paso 5. Verificar un control con su script

*SQL*Plus, desde la raíz del repositorio*

```
DEFINE fase = despues
@sql/01_verificacion/V16_A8_24_criptografia.sql
```

**Debe verse:** Muestra la salida en pantalla y la guarda en evidencias/despues. Sirve igual con V02, V07, V09 o V15.

## Paso 6. Correr la batería completa de verificación

*PowerShell, raíz del repositorio*

```
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" despues
```

**Debe verse:** Genera 17 archivos nuevos en evidencias/despues (tarda unos segundos). Quedan duplicados de los anteriores: borra el juego viejo antes de entregar.

## Paso 7. Probar los intentos que deben fallar

*PowerShell, raíz del repositorio*

```
sqlplus /nolog "@sql/03_pruebas/P01_accesos.sql"
```

**Debe verse:** Pide la clave de SYS. Cada acción prohibida (ex-secretaria, DBA, etc.) debe terminar en error ORA-xxxxx. P02 hace lo mismo para R02–R05 y dura unos 4 minutos.

## Paso 8. Mostrar el cifrado del respaldo (PT-19)

*PowerShell, raíz del repositorio*

```
$env:ORA_SYS_PWD = Read-Host 'Clave de SYS'
.\sql\03_pruebas\P04_PT19_tde_observable.ps1
```

**Debe verse:** El nombre buscado aparece 1 vez en el archivo sin cifrar temporal y 0 veces en el datafile cifrado y en el respaldo.

## Paso 9. Cerrar con el artefacto

*Navegador*

```
cd artefacto
npm run dev
```

**Debe verse:** Visión general (curva de mejora y 5 controles clave), Evidencias → Comparar ANTES/DESPUÉS y la matriz de evaluación.

# Orden de los scripts del repositorio

## 1. Creación del escenario

Crea el esquema INSTITUTO con datos ficticios y siembra las 12 malas prácticas (MP-01 a MP-12). Es el punto de partida: la base «con fallas».

```
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/00_escenario/00_crear_escenario.sql"
```

> 99_limpiar_escenario.sql borra el escenario para repetirlo desde cero. No lo ejecutes en una demostración: vuelve la base al estado ANTES y deshace la remediación.

- `sql/00_escenario/00_crear_escenario.sql`
- `sql/00_escenario/99_limpiar_escenario.sql`

## 2. Verificación ANTES: ver las fallas

Un script por control ISO. Solo leen (consultan el catálogo de Oracle) y guardan su salida en evidencias/antes. V00 los ejecuta todos.

```
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" antes
```

- `sql/01_verificacion/V00_ejecutar_todo.sql`
- `sql/01_verificacion/V01_A5_12_clasificacion.sql`
- `sql/01_verificacion/V02_A5_15_control_acceso.sql`
- `sql/01_verificacion/V03_A5_16_identidades.sql`
- `sql/01_verificacion/V04_A5_17_autenticacion_info.sql`
- `sql/01_verificacion/V05_A5_18_derechos_acceso.sql`
- `sql/01_verificacion/V06_A5_33_proteccion_registros.sql`
- `sql/01_verificacion/V07_A8_2_acceso_privilegiado.sql`
- `sql/01_verificacion/V08_A8_3_restriccion_acceso.sql`
- `sql/01_verificacion/V09_A8_5_autenticacion_segura.sql`
- `sql/01_verificacion/V10_A8_10_eliminacion.sql`
- `sql/01_verificacion/V11_A8_11_enmascaramiento.sql`
- `sql/01_verificacion/V12_A8_12_fuga_datos.sql`
- `sql/01_verificacion/V13_A8_13_respaldo.sql`
- `sql/01_verificacion/V14_A8_15_registro.sql`
- `sql/01_verificacion/V15_A8_20_redes.sql`
- `sql/01_verificacion/V16_A8_24_criptografia.sql`
- `sql/01_verificacion/V17_A8_8_vulnerabilidades.sql`

## 3. Solución: remediación por bloques (Hacer)

Cada bloque corrige un grupo de malas prácticas. Se aplican en este orden. R06a necesita PowerShell como administrador; R06b y R06c llevan pasos manuales que cada archivo explica.

```
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/02_remediacion/R01_accesos.sql"
```

- `sql/02_remediacion/R01_accesos.sql`
- `sql/02_remediacion/R02_identidades.sql`
- `sql/02_remediacion/R03_restriccion_masking.sql`
- `sql/02_remediacion/R04_auditoria.sql`
- `sql/02_remediacion/R05_fuga_eliminacion.sql`
- `sql/02_remediacion/R06b_paso1_wallet_root.sql`
- `sql/02_remediacion/R06b_tde.sql`
- `sql/02_remediacion/R06c_backup_rman.rman`
- `sql/02_remediacion/R06a_sqlnet_admin.ps1`
- `sql/02_remediacion/R06e_verificadores_12c.sql`
- `sql/02_remediacion/_inicio.sql`

## 4. Verificación DESPUÉS y pruebas

Se repiten los mismos scripts V (ver etapa 2) y se corren las pruebas, que intentan cada acción con la cuenta indicada: las negativas deben dar error.

```
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" despues
```

- `sql/03_pruebas/P01_accesos.sql`
- `sql/03_pruebas/P02_pruebas_R02_a_R05.sql`
- `sql/03_pruebas/P04_PT19_tde_observable.ps1`
- `sql/03_pruebas/P05_PT24_cifrado_red.sql`

## 5. Apoyo

Archivos que usan los demás: configuración común y encabezado de evidencia.

- `sql/01_verificacion/_config.sql`
- `sql/01_verificacion/_encabezado.sql`

