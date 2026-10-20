# 5. Matriz de evaluación

> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.

**Escala de madurez:** 0 Inexistente · 1 Inicial (ad hoc, sin documento ni evidencia) · 2 Documentado (existe política, sin evidencia de ejecución) · 3 Implementado y verificado (un script V-xx lo demuestra) · 4 Gestionado (se monitorea periódicamente y se mejora).

**Estado:** 0–1 No cumple · 2 Parcial · 3–4 Cumple. La columna "Criterio 0-4" muestra el nivel ANTES y la meta DESPUÉS. Hay una fila por cada par tarea–control (24 filas).

| Tarea | Riesgo | Control | Criterio 0-4 | Evidencia | Estado |
| --- | --- | --- | --- | --- | --- |
| T-01 Gestión de usuarios | R-CONF-02 | A5.16 Gestión de identidades | 1 → meta 3: Hay cuentas nominales para docentes, pero SECRETARIA es compartida y EX_KSALAS sigue OPEN; no hay procedimiento de bajas | evidencias/antes/V03_A5_16_*.txt | No cumple |
| T-01 Gestión de usuarios | R-CONF-01 | A5.18 Derechos de acceso | 0 → meta 4: Nunca se han revisado los derechos; TESO_PAULA tiene GRANT OPTION sobre BECAS | evidencias/antes/V05_A5_18_*.txt | No cumple |
| T-02 Privilegios y roles | R-CONF-01 | A5.15 Control de acceso | 0 → meta 3: No hay roles propios; 21 permisos directos a usuarios y ADECUACIONES otorgada a PUBLIC | evidencias/antes/V02_A5_15_*.txt | No cumple |
| T-02 Privilegios y roles | R-CONF-01 | A8.2 Derechos de acceso privilegiado | 0 → meta 3: DEV_RAMIRO tiene rol DBA (160 privilegios peligrosos efectivos) y APP_MATRICULA tiene SELECT ANY TABLE | evidencias/antes/V07_A8_2_*.txt | No cumple |
| T-02 Privilegios y roles | R-CONF-01 | A5.18 Derechos de acceso | 0 → meta 4: Nunca se han revisado los derechos; TESO_PAULA tiene GRANT OPTION sobre BECAS | evidencias/antes/V05_A5_18_*.txt | No cumple |
| T-03 Autenticación | R-CONF-02 | A5.17 Información de autenticación | 1 → meta 3: Solo los valores por defecto de Oracle (vida 180 días, 10 intentos); sin función de verificación; se aceptan contraseñas débiles | evidencias/antes/V04_A5_17_*.txt | No cumple |
| T-03 Autenticación | R-CONF-02 | A8.5 Autenticación segura | 1 → meta 3: Bloqueo por defecto a los 10 intentos, pero PERFIL_APLICACIONES es ilimitado, IDLE_TIME es ilimitado y hay verificadores 11G | evidencias/antes/V09_A8_5_*.txt | No cumple |
| T-04 Cifrado TDE | R-CONF-03 | A8.24* Uso de criptografía | 0 → meta 3: Keystore NOT_AVAILABLE; WALLET_ROOT vacío; ningún tablespace cifrado | evidencias/antes/V16_A8_24_*.txt | No cumple |
| T-05 Masking y redacción | R-CONF-01 | A8.11 Enmascaramiento de datos | 0 → meta 3: Sin políticas de redacción; DEV_RAMIRO y SOPORTE_TI exentos por EXP_FULL_DATABASE; clon DEV sin enmascarar | evidencias/antes/V11_A8_11_*.txt | No cumple |
| T-05 Masking y redacción | R-CONF-01 | A8.3 Restricción de acceso a la información | 0 → meta 3: Sin VPD ni vistas; DOC_MCHAVES ve las 2000 notas de los 6 docentes y las 120 adecuaciones | evidencias/antes/V08_A8_3_*.txt | No cumple |
| T-05 Masking y redacción | R-CONF-03 | A5.12 Clasificación de la información | 0 → meta 3: Ninguna columna clasificada: 36 de 36 sin etiqueta | evidencias/antes/V01_A5_12_*.txt | No cumple |
| T-06 Backup | R-CONF-03 | A8.13 Respaldo de la información | 0 → meta 3: No hay ningún backup RMAN; la configuración está por defecto con el cifrado desactivado | evidencias/antes/V13_A8_13_*.txt | No cumple |
| T-07 Auditoría | R-CONF-06 | A8.15 Registro (logging) | 1 → meta 4: Solo ORA_LOGON_FAILURES y ORA_SECURECONFIG por defecto; ninguna política sobre ADECUACIONES; nadie revisa el rastro | evidencias/antes/V14_A8_15_*.txt | No cumple |
| T-07 Auditoría | R-CONF-06 | A5.33 Protección de registros | 1 → meta 3: Oracle protege AUDSYS por defecto, pero AUDITOR_EXT tiene AUDIT_ADMIN y no hay política de retención propia | evidencias/antes/V06_A5_33_*.txt | No cumple |
| T-08 Parcheo | R-CONF-02, R-CONF-03 | A8.8* Gestión de vulnerabilidades técnicas | 1 → meta 2: Versión 21.3.0.0.0 sin parches; la limitación no estaba documentada | evidencias/antes/V17_A8_8_*.txt | No cumple |
| T-09 Listener y red | R-CONF-05 | A8.20 Seguridad de redes | 0 → meta 3: Sin cifrado configurado: el banner por TCP lista los adaptadores pero ningún algoritmo activo | evidencias/antes/V15_A8_20_*.txt | No cumple |
| T-09 Listener y red | R-CONF-05 | A8.21* Seguridad de los servicios de red | 0 → meta 3: Listener sobre una IP de red que no existía y sin restricciones; se corrigió a localhost el 19/10 | Salida de lsnrctl status y copia de listener.ora | No cumple |
| T-10 Eliminación segura | R-CONF-03 | A8.10 Eliminación de la información | 0 → meta 3: ESTUDIANTES_RESPALDO_2025 sigue en la papelera con los 500 estudiantes; no hay procedimiento | evidencias/antes/V10_A8_10_*.txt | No cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A8.15 Registro (logging) | 1 → meta 4: Solo ORA_LOGON_FAILURES y ORA_SECURECONFIG por defecto; ninguna política sobre ADECUACIONES; nadie revisa el rastro | evidencias/antes/V14_A8_15_*.txt | No cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A8.16* Actividades de monitoreo | 0 → meta 4: No existe reporte ni revisión periódica del rastro | Salida del reporte semanal y DBA_SCHEDULER_JOB_RUN_DETAILS | No cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A5.33 Protección de registros | 1 → meta 3: Oracle protege AUDSYS por defecto, pero AUDITOR_EXT tiene AUDIT_ADMIN y no hay política de retención propia | evidencias/antes/V06_A5_33_*.txt | No cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.11 Enmascaramiento de datos | 0 → meta 3: Sin políticas de redacción; DEV_RAMIRO y SOPORTE_TI exentos por EXP_FULL_DATABASE; clon DEV sin enmascarar | evidencias/antes/V11_A8_11_*.txt | No cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.12 Prevención de fuga de datos | 0 → meta 3: PUBLIC ejecuta 5 paquetes UTL_* y escribe en DIR_EXPORTES; SOPORTE_TI exporta la base completa sin auditoría | evidencias/antes/V12_A8_12_*.txt | No cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.33* Información de prueba | 0 → meta 3: INSTITUTO_DEV contiene los estudiantes y adecuaciones reales sin enmascarar | Resultado de la comparación entre producción y el clon (prueba PT-26) | No cumple |

