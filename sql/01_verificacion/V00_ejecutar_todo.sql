-- V00_ejecutar_todo.sql | Ejecuta todas las verificaciones y guarda evidencias
--
-- Uso (desde la RAIZ del repositorio, para que el SPOOL caiga en evidencias/):
--   sqlplus "sys/<clave> as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" antes
--   sqlplus "sys/<clave> as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" despues
-- (_config.sql cambia automaticamente a XEPDB1.)
-- (En PowerShell el @ debe ir entre comillas.)
DEFINE fase = &1

@@V01_A5_12_clasificacion.sql
@@V02_A5_15_control_acceso.sql
@@V03_A5_16_identidades.sql
@@V04_A5_17_autenticacion_info.sql
@@V05_A5_18_derechos_acceso.sql
@@V06_A5_33_proteccion_registros.sql
@@V07_A8_2_acceso_privilegiado.sql
@@V08_A8_3_restriccion_acceso.sql
@@V09_A8_5_autenticacion_segura.sql
@@V10_A8_10_eliminacion.sql
@@V11_A8_11_enmascaramiento.sql
@@V12_A8_12_fuga_datos.sql
@@V13_A8_13_respaldo.sql
@@V14_A8_15_registro.sql
@@V15_A8_20_redes.sql
@@V16_A8_24_criptografia.sql
@@V17_A8_8_vulnerabilidades.sql

PROMPT
PROMPT Verificaciones completadas. Evidencias en evidencias/&fase/
EXIT
