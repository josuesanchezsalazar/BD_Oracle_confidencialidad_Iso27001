# 2. Tareas críticas del DBA

> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.

| ID | Tarea | Qué hace el DBA | Frecuencia | Riesgos | Controles | Scripts | Ejemplo en el instituto |
| --- | --- | --- | --- | --- | --- | --- | --- |
| T-01 | Gestión de usuarios | Crear cuentas nominales (una por persona o proceso), bloquear o eliminar las de quienes salen de la organización y revisar periódicamente las cuentas inactivas. | Por evento + revisión mensual | R-CONF-02 | A5.16, A5.18 | V03 | Dar de baja a EX_KSALAS y reemplazar la cuenta compartida SECRETARIA por una cuenta por secretaria. |
| T-02 | Privilegios y roles | Otorgar permisos por roles de función, sin PUBLIC, sin privilegios ANY y sin GRANT OPTION, y revisarlos contra una matriz aprobada. | Por solicitud + revisión trimestral | R-CONF-01 | A5.15, A8.2, A5.18 | V02, V05, V07 | Crear ROL_DOCENTE, ROL_SECRETARIA y ROL_TESORERIA; quitar el rol DBA a DEV_RAMIRO, SELECT ANY TABLE a APP_MATRICULA y PUBLIC sobre ADECUACIONES. |
| T-03 | Autenticación | Definir perfiles con complejidad de contraseña, bloqueo por intentos, expiración e IDLE_TIME, y eliminar los verificadores antiguos. | Configuración inicial + revisión semestral | R-CONF-02 | A5.17, A8.5 | V04, V09 | Un perfil para todas las cuentas y fin de los intentos ilimitados de PERFIL_APLICACIONES. |
| T-04 | Cifrado TDE | Configurar el keystore, cifrar los tablespaces con datos sensibles y respaldar el keystore por separado. | Configuración inicial + rotación anual de la clave | R-CONF-03 | A8.24* | V16 | Mover las tablas de INSTITUTO a un tablespace cifrado con AES256. |
| T-05 | Masking y redacción | Clasificar las columnas, ocultar las sensibles con redacción según el usuario o rol y filtrar filas con VPD o vistas. | Por cambio en la estructura de datos | R-CONF-01 | A8.11, A8.3, A5.12 | V01, V08, V11 | Redactar DETALLE_CONDICION, INGRESO_FAMILIAR y NUM_CUENTA y limitar a cada docente a sus propias notas y adecuaciones. |
| T-06 | Backup | Realizar respaldos cifrados con retención definida y restauraciones de prueba. | Diaria (backup) + mensual (prueba de restauración) | R-CONF-03 | A8.13 | V13 | Backup RMAN en frío de XE (NOARCHIVELOG) con cifrado y RESTORE ... VALIDATE. |
| T-07 | Auditoría | Crear políticas de auditoría unificada sobre datos sensibles, gestión de accesos y exportaciones, y separar AUDIT_ADMIN de AUDIT_VIEWER. | Configuración inicial + revisión trimestral | R-CONF-06 | A8.15, A5.33 | V06, V14 | Auditar ADECUACIONES, BECAS y Data Pump y dejar a AUDITOR_EXT solo con AUDIT_VIEWER. |
| T-08 | Parcheo | Registrar la versión y los parches y aplicar las actualizaciones de seguridad; si la edición no las recibe, documentar el riesgo aceptado. | Trimestral (revisión de avisos de Oracle) | R-CONF-02, R-CONF-03 | A8.8* | V17 | XE 21.3 no recibe parches: riesgo aceptado y recomendación de usar una edición con soporte en producción. |
| T-09 | Listener y red | Configurar el cifrado de Oracle Net y limitar el listener a las interfaces y los nodos necesarios. | Configuración inicial + por cambio de red | R-CONF-05 | A8.20, A8.21* | V15 | sqlnet.ora con AES256 y listener solo en localhost. |
| T-10 | Eliminación segura | Purgar la papelera, destruir backups y dumps vencidos y dar de baja esquemas sin uso. | Mensual | R-CONF-03 | A8.10 | V10 | Purgar ESTUDIANTES_RESPALDO_2025 de la papelera. |
| T-11 | Logs y monitoreo | Revisar el rastro de auditoría con un reporte periódico automatizado de accesos fallidos y cambios de privilegios. | Semanal (automatizado) | R-CONF-06 | A8.15, A8.16*, A5.33 | V14 | Reporte semanal con DBMS_SCHEDULER sobre UNIFIED_AUDIT_TRAIL. |
| T-12 | Clones DEV/TEST | Entregar copias para desarrollo y pruebas con datos enmascarados y controlar las exportaciones. | Por cada clon solicitado | R-CONF-04 | A8.11, A8.12, A8.33* | V11, V12 | Enmascarar INSTITUTO_DEV y retirar la exportación completa a SOPORTE_TI. |

\* Control complementario, fuera de la lista oficial de la asignación.

