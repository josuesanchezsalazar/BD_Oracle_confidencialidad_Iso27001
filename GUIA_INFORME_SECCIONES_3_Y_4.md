# Texto para el informe: secciones 3 y 4

> Listo para copiar y pegar en el Google Doc. Los bloques en cita (`>`) son notas para ti: no se pegan.
> Todas las cifras salen de `docs/01`–`05`, `contexto-organizacion.md` y `artefacto/src/data/`. Si cambias un JSON, vuelve a correr `npm run docs` y revisa que los números de aquí coincidan.
> Para pegar las tablas: en Google Docs activa Herramientas → Preferencias → *Detectar Markdown*, o pégalas desde un editor de tablas.

---

> **Cómo organizar la sección 3.** El PDF de la asignación (sección 6) pide seis piezas y tu informe ya tiene las seis letras A–F. Falta lo que va **antes** de la A (una introducción corta) y **dentro** de cada letra: un párrafo de qué es, la tabla y una línea de cómo se lee. Las tablas completas, con textos largos, están en el artefacto y en `docs/`; en el informe van versiones condensadas para que no pasen de 8 a 10 páginas.

# 3. Desarrollo del marco de controles

## Introducción de la sección

El marco se desarrolló con la metodología PHVA (Planificar, Hacer, Verificar, Actuar) sobre un escenario de prueba: el Instituto Oracle Heredia, un colegio técnico ficticio con una base Oracle 21c Express Edition (21.3), la PDB XEPDB1 y el esquema INSTITUTO. La base guarda 500 estudiantes, en su mayoría menores de edad, con sus notas, adecuaciones curriculares (condición de salud) y becas (ingreso familiar y cuenta bancaria). La columna de mayor sensibilidad es `ADECUACIONES.DETALLE_CONDICION`, dato sensible según la Ley 8968, por lo que todo riesgo que la exponga se calificó con impacto 5.

Las seis piezas siguientes forman una cadena de trazabilidad: **riesgo → tarea del DBA → control ISO → evidencia observable → prueba**. Cada riesgo se trata con controles, cada control se demuestra con un script de verificación (V01–V17) y cada script se respalda con pruebas de la batería (PT-01 a PT-29). Del escenario se separó una capa general, aplicable a cualquier base Oracle, y un ejemplo concreto, para que el marco no dependa del instituto.

El artefacto interactivo contiene las tablas completas, la comparación ANTES/DESPUÉS y las evidencias: **[pega aquí el enlace del artefacto y del repositorio Git]**.

> Verifica que el enlace del artefacto abra sin tu sesión. La asignación pide "informe PDF con artefacto (o link)".

---

## A. Tabla de riesgos

La asignación exige al menos cinco riesgos de confidencialidad (R-CONF-01 a R-CONF-05). Se identificaron seis: se agregó R-CONF-06 (trazabilidad y manipulación del registro de auditoría) porque, sin un rastro confiable, el abuso de un acceso legítimo no se detecta. Cada riesgo se calificó con Probabilidad (P) × Impacto (I) en escala 1–5. Bandas: 1–4 Bajo, 5–9 Medio, 10–14 Alto, 15–25 Crítico. El apetito de riesgo propuesto es un residual de 6 o menos, pendiente de confirmar con el profesor.

| ID | Riesgo | P | I | Nivel inherente | Meta residual |
| --- | --- | --- | --- | --- | --- |
| R-CONF-01 | Acceso no autorizado por privilegios excesivos o mal asignados | 5 | 5 | 25 Crítico | 6 Medio |
| R-CONF-02 | Suplantación de identidad por autenticación débil o cuentas sin gestión | 4 | 5 | 20 Crítico | 6 Medio |
| R-CONF-03 | Exposición de datos en reposo y eliminación insegura | 3 | 5 | 15 Crítico | 5 Medio |
| R-CONF-04 | Fuga por exportaciones y entornos no productivos | 3 | 5 | 15 Crítico | 5 Medio |
| R-CONF-05 | Interceptación de datos en tránsito | 2 | 4 | 8 Medio | 3 Bajo |
| R-CONF-06 | Falta de trazabilidad y manipulación del registro de auditoría | 4 | 3 | 12 Alto | 4 Bajo |

**Cómo se lee:** el nivel inherente es el riesgo antes de aplicar controles; la meta residual es lo que se espera después. Las causas típicas, los activos y la justificación de cada P e I están en el artefacto (pestaña de riesgos).

> Si quieres una sola frase de justificación por riesgo en el informe, usa la columna "Cómo se manifestó" de `docs/01-riesgos.md`.

## B. Tabla de tareas del DBA

La asignación pide al menos 12 tareas críticas. Se definieron 12, cada una ligada a los riesgos que reduce y a los controles que la sostienen.

| ID | Tarea | Frecuencia | Riesgos | Controles |
| --- | --- | --- | --- | --- |
| T-01 | Gestión de usuarios | Por evento + revisión mensual | R-CONF-02 | A5.16, A5.18 |
| T-02 | Privilegios y roles | Por solicitud + revisión trimestral | R-CONF-01 | A5.15, A8.2, A5.18 |
| T-03 | Autenticación | Inicial + revisión semestral | R-CONF-02 | A5.17, A8.5 |
| T-04 | Cifrado TDE | Inicial + rotación anual de clave | R-CONF-03 | A8.24* |
| T-05 | Masking y redacción | Por cambio en la estructura de datos | R-CONF-01 | A8.11, A8.3, A5.12 |
| T-06 | Backup | Diaria + prueba de restauración mensual | R-CONF-03 | A8.13 |
| T-07 | Auditoría | Inicial + revisión trimestral | R-CONF-06 | A8.15, A5.33 |
| T-08 | Parcheo | Trimestral | R-CONF-02, R-CONF-03 | A8.8* |
| T-09 | Listener y red | Inicial + por cambio de red | R-CONF-05 | A8.20, A8.21* |
| T-10 | Eliminación segura | Mensual | R-CONF-03 | A8.10 |
| T-11 | Logs y monitoreo | Semanal (automatizado) | R-CONF-06 | A8.15, A8.16*, A5.33 |
| T-12 | Clones DEV/TEST | Por cada clon solicitado | R-CONF-04 | A8.11, A8.12, A8.33* |

\* Control complementario, fuera de la lista oficial de 15 de la asignación.

**Cómo se lee:** cubre las doce tareas que pide la asignación (usuarios, privilegios, autenticación, TDE, masking, backup, auditoría, parcheo, listener, eliminación segura, logs y clones DEV/TEST).

## C. Mapeo de controles ISO con implementación y evidencia

Se seleccionaron los 15 controles oficiales del Anexo A 2022 que indica la asignación y 5 complementarios (marcados con \*) que cierran brechas que los 15 no cubren: criptografía (A8.24), vulnerabilidades (A8.8), monitoreo (A8.16), servicios de red (A8.21) e información de prueba (A8.33). Los complementarios se declaran aparte para no confundirlos con los oficiales.

| Control | Riesgo | Implementación sugerida en Oracle | Evidencia observable |
| --- | --- | --- | --- |
| A5.12 Clasificación de la información | R-CONF-03 | Etiqueta CLASIF por columna con `COMMENT ON COLUMN` | `DBA_COL_COMMENTS` (V01) |
| A5.15 Control de acceso | R-CONF-01, 02 | Permisos por roles de función; nada a PUBLIC | `DBA_TAB_PRIVS` (V02) |
| A5.16 Gestión de identidades | R-CONF-02 | Cuenta nominal por persona; bloqueo al terminar la relación | `DBA_USERS` (V03) |
| A5.17 Información de autenticación | R-CONF-02 | Perfil con `PASSWORD_VERIFY_FUNCTION`, vida y reuso | `DBA_PROFILES`, `DBA_USERS_WITH_DEFPWD` (V04) |
| A5.18 Derechos de acceso | R-CONF-01 | Revisión periódica; sin `WITH GRANT OPTION` | `DBA_TAB_PRIVS.GRANTABLE` (V05) |
| A5.33 Protección de registros | R-CONF-06 | `AUDIT_ADMIN` separado de `AUDIT_VIEWER` | `DBA_ROLE_PRIVS` (V06) |
| A8.2 Derechos de acceso privilegiado | R-CONF-01, 02 | Sin rol DBA ni privilegios ANY en cuentas operativas | `DBA_ROLE_PRIVS`, `DBA_SYS_PRIVS` (V07) |
| A8.3 Restricción de acceso a la información | R-CONF-01 | VPD (`DBMS_RLS`) por fila | `DBA_POLICIES` (V08) |
| A8.5 Autenticación segura | R-CONF-02 | Bloqueo por intentos, `IDLE_TIME`, solo verificadores 12C | `DBA_PROFILES`, `DBA_USERS` (V09) |
| A8.10 Eliminación de la información | R-CONF-03 | Purgar papelera; retención de backups y dumps | `DBA_RECYCLEBIN` (V10) |
| A8.11 Enmascaramiento de datos | R-CONF-01, 04 | Data Redaction (`DBMS_REDACT`); clon enmascarado | `REDACTION_COLUMNS` (V11) |
| A8.12 Prevención de fuga de datos | R-CONF-04 | Sin UTL_* ni directorios a PUBLIC; Data Pump auditado | `DBA_TAB_PRIVS` (V12) |
| A8.13 Respaldo de la información | R-CONF-03 | RMAN cifrado AES256 y `RESTORE ... VALIDATE` | `V$BACKUP_PIECE` (V13) |
| A8.15 Registro (logging) | R-CONF-06 | Auditoría unificada sobre datos sensibles | `AUDIT_UNIFIED_ENABLED_POLICIES` (V14) |
| A8.20 Seguridad de redes | R-CONF-05 | Cifrado Oracle Net AES256 + checksum | `V$SESSION_CONNECT_INFO` (V15) |
| A8.24* Uso de criptografía | R-CONF-03 | TDE: keystore, clave maestra, tablespace cifrado | `V$ENCRYPTION_WALLET` (V16) |
| A8.8* Gestión de vulnerabilidades | R-CONF-02, 03 | Registrar versión y parches; riesgo aceptado en XE | `V$VERSION` (V17) |
| A8.16* Actividades de monitoreo | R-CONF-06 | Reporte semanal con `DBMS_SCHEDULER` | `DBA_SCHEDULER_JOB_RUN_DETAILS` |
| A8.21* Seguridad de los servicios de red | R-CONF-05 | Listener solo en 127.0.0.1 | `lsnrctl status`, `netstat` |
| A8.33* Información de prueba | R-CONF-04 | Clon con datos enmascarados | Comparación producción vs. clon (PT-26) |

**Cómo se lee:** cada fila une un control con lo que se configura en Oracle y con la consulta que permite a un tercero comprobarlo. Los textos completos y las consultas SQL están en `docs/03-mapeo-controles.md`.

## D. Lista de controles observables por un auditor externo

Los 15 controles oficiales, con lo que un auditor externo puede observar y el criterio para aceptarlo.

| # | Control | Qué observa el auditor | Criterio de aceptación | Script |
| --- | --- | --- | --- | --- |
| 1 | A5.12 | Que cada columna con datos personales tenga clasificación | 0 columnas sin etiqueta | V01 |
| 2 | A5.15 | Que los permisos estén en roles y no en PUBLIC | 0 permisos directos y 0 a PUBLIC | V02 |
| 3 | A5.16 | Que no haya cuentas compartidas ni de ex-empleados abiertas | Toda cuenta abierta es vigente e individual | V03 |
| 4 | A5.17 | Que todas las cuentas usen perfil con función de verificación | Función ≠ NULL y 0 contraseñas por defecto | V04 |
| 5 | A5.18 | Que exista revisión periódica y no haya derechos re-otorgables | 0 filas con GRANTABLE = YES + reporte | V05 |
| 6 | A5.33 | Quién puede leer, configurar o purgar la auditoría | Ninguna cuenta operativa o de auditor con AUDIT_ADMIN | V06 |
| 7 | A8.2 | Que solo cuentas de administración tengan privilegios elevados | 0 cuentas no administrativas con DBA o ANY | V07 |
| 8 | A8.3 | Que un usuario no vea filas ajenas | Política activa; dos usuarios obtienen resultados distintos | V08 |
| 9 | A8.5 | Bloqueo por intentos y cierre por inactividad | Sin intentos ilimitados; `IDLE_TIME` definido; verificadores 12C | V09 |
| 10 | A8.10 | Que lo borrado no siga recuperable | 0 objetos en la papelera | V10 |
| 11 | A8.11 | Que las columnas sensibles se vean ocultas | Políticas activas y ninguna cuenta operativa exenta | V11 |
| 12 | A8.12 | Quién puede sacar datos en forma masiva | 0 permisos de PUBLIC sobre UTL_* y directorios; Data Pump auditado | V12 |
| 13 | A8.13 | Que haya backups recientes, cifrados y probados | `ENCRYPTED = YES` + restauración de prueba | V13 |
| 14 | A8.15 | Que el acceso a datos sensibles quede registrado | Políticas activas + evidencia de revisión | V14 |
| 15 | A8.20 | Que el tráfico viaje cifrado | Banner de sesión TCP con AES256 | V15 |

**Cómo se lee:** esta lista es la que se entrega al auditor: cada criterio se evalúa con "cumple / no cumple" sobre la salida de un script.

## E. Matriz de evaluación

Relaciona cada tarea con su riesgo y su control, mide el nivel de madurez en la escala 0–4 y deja el estado y la evidencia. Hay una fila por cada par tarea–control (24 filas). Se presentan los dos momentos: **ANTES** (diagnóstico del 20/10/2026) y **DESPUÉS** (verificación del 27/10/2026).

**Escala de madurez:** 0 Inexistente · 1 Inicial (ad hoc, sin documento ni evidencia) · 2 Documentado (política sin evidencia de ejecución) · 3 Implementado y verificado (un script V-xx lo demuestra) · 4 Gestionado (se monitorea y se mejora periódicamente).
**Estado:** 0–1 No cumple · 2 Parcial · 3–4 Cumple.

| Tarea | Riesgo | Control | Criterio 0-4 (ANTES → DESPUÉS) | Evidencia | Estado (ANTES → DESPUÉS) |
| --- | --- | --- | --- | --- | --- |
| T-01 Gestión de usuarios | R-CONF-02 | A5.16 | 1 → 3 | V03 | No cumple → Cumple |
| T-01 Gestión de usuarios | R-CONF-01 | A5.18 | 0 → 3 | V05 | No cumple → Cumple |
| T-02 Privilegios y roles | R-CONF-01 | A5.15 | 0 → 3 | V02 | No cumple → Cumple |
| T-02 Privilegios y roles | R-CONF-01 | A8.2 | 0 → 3 | V07 | No cumple → Cumple |
| T-02 Privilegios y roles | R-CONF-01 | A5.18 | 0 → 3 | V05 | No cumple → Cumple |
| T-03 Autenticación | R-CONF-02 | A5.17 | 1 → 3 | V04 | No cumple → Cumple |
| T-03 Autenticación | R-CONF-02 | A8.5 | 1 → 3 | V09 | No cumple → Cumple |
| T-04 Cifrado TDE | R-CONF-03 | A8.24* | 0 → 3 | V16 | No cumple → Cumple |
| T-05 Masking y redacción | R-CONF-01 | A8.11 | 0 → 3 | V11 | No cumple → Cumple |
| T-05 Masking y redacción | R-CONF-01 | A8.3 | 0 → 3 | V08 | No cumple → Cumple |
| T-05 Masking y redacción | R-CONF-03 | A5.12 | 0 → 3 | V01 | No cumple → Cumple |
| T-06 Backup | R-CONF-03 | A8.13 | 0 → 3 | V13 | No cumple → Cumple |
| T-07 Auditoría | R-CONF-06 | A8.15 | 1 → 3 | V14 | No cumple → Cumple |
| T-07 Auditoría | R-CONF-06 | A5.33 | 1 → 3 | V06 | No cumple → Cumple |
| T-08 Parcheo | R-CONF-02, 03 | A8.8* | 1 → 2 | V17 + riesgo aceptado | No cumple → Parcial |
| T-09 Listener y red | R-CONF-05 | A8.20 | 0 → 3 | V15 (por TCP) | No cumple → Cumple |
| T-09 Listener y red | R-CONF-05 | A8.21* | 0 → 3 | `lsnrctl`, `netstat` (PT-29) | No cumple → Cumple |
| T-10 Eliminación segura | R-CONF-03 | A8.10 | 0 → 3 | V10 | No cumple → Cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A8.15 | 1 → 3 | V14 | No cumple → Cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A8.16* | 0 → 3 | Job semanal (PT-27) | No cumple → Cumple |
| T-11 Logs y monitoreo | R-CONF-06 | A5.33 | 1 → 3 | V06 | No cumple → Cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.11 | 0 → 3 | V11 | No cumple → Cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.12 | 0 → 3 | V12 | No cumple → Cumple |
| T-12 Clones DEV/TEST | R-CONF-04 | A8.33* | 0 → 3 | Comparación (PT-26) | No cumple → Cumple |

**Cómo se lee:** el criterio explica *por qué* se asignó ese nivel y la evidencia dice *dónde* se comprueba; los criterios textuales de cada fila (ANTES y DESPUÉS) están en `docs/04-matriz-evaluacion.md` y en la pestaña de la matriz del artefacto. Ningún control llegó a 4 porque el nivel 4 exige revisión periódica sostenida, que un laboratorio de una semana no puede demostrar.

## F. Batería de pruebas

Las pruebas demuestran la efectividad de los controles intentando el acceso indebido (pruebas negativas) y comprobando que el acceso legítimo sigue funcionando (positivas). "Falla" en ANTES significa que el acceso indebido fue posible.

**Origen de cada prueba:** *ejecutada* (se corrió y hay salida real), *inferida* (deducida de la configuración observada) o *pendiente*. Se declara para que la tabla sea honesta sobre lo que se ejecutó realmente.

| ID | Tipo | Procedimiento | Resultado esperado | Herramienta |
| --- | --- | --- | --- | --- |
| PT-01 | Mínimo privilegio (negativa) | Con la cuenta de la aplicación, leer una tabla ajena | ORA-00942 | SQL*Plus |
| PT-02 | Acceso legítimo (positiva) | Docente consulta lo autorizado vía rol | Ve las filas autorizadas | SQL*Plus |
| PT-03 | Restricción por filas (VPD) | Docente agrupa notas por responsable | Solo su id_docente | SQL*Plus |
| PT-04 | Redacción de dato restringido | Consultar la cuenta bancaria sin autorización | Solo últimos 4 caracteres | SQL*Plus |
| PT-05 | Redacción de dato sensible | Consultar la condición de salud sin necesitarla | Condición vacía | SQL*Plus |
| PT-06 | Exención de redacción | Listar `EXEMPT REDACTION POLICY` | Ninguna cuenta operativa | V11 |
| PT-07 | Permisos a PUBLIC (negativa) | Cuenta ajena intenta leer lo más sensible | ORA-28000 u ORA-00942 | SQL*Plus |
| PT-08 | Bloqueo de cuenta | Fallar la clave hasta el límite y probar la correcta | ORA-28000 | SQL*Plus |
| PT-09 | Fuerza bruta contra una aplicación | 20 intentos fallidos | ORA-28000 desde el límite | SQL*Plus |
| PT-10 | Complejidad de contraseña | Asignar una contraseña débil | ORA-28003 | SQL*Plus |
| PT-11 | Sesión inactiva | Esperar más que `IDLE_TIME` y consultar | ORA-02396 | SQL*Plus |
| PT-12 | Cuenta huérfana | Conectar con la cuenta de una ex-empleada | ORA-28000 | SQL*Plus |
| PT-13 | Cuenta compartida | Conectar con la cuenta compartida | ORA-28000; cuentas nominales | SQL*Plus |
| PT-14 | Auditoría de lectura | Leer dato sensible y revisar el rastro | Registro con usuario, fecha y objeto | V14 |
| PT-15 | Auditoría de privilegios | Ejecutar un GRANT y revisar el rastro | Registro del GRANT | V14 |
| PT-16 | Protección de registros (negativa) | El auditor intenta purgar el rastro | Privilegios insuficientes | SQL*Plus |
| PT-17 | Clasificación | Listar columnas sin etiqueta | 0 columnas | V01 |
| PT-18 | TDE (estado) | Consultar keystore y tablespaces | Keystore OPEN; tablespace cifrado | V16 |
| PT-19 | TDE observable | Buscar un texto conocido en datafile y backup | Aparece sin cifrar; no aparece cifrado | PowerShell / RMAN |
| PT-20 | Backup cifrado | Backup y revisión de piezas | `ENCRYPTED = YES` | RMAN / V13 |
| PT-21 | Restauración | Validar la restauración | Sin errores | RMAN |
| PT-22 | Exportación (negativa) | Cuenta operativa intenta `expdp FULL=Y` | Privilegios insuficientes | expdp |
| PT-23 | Vías de salida abiertas a PUBLIC | Listar permisos sobre UTL_* y directorios | 0 permisos | V12 |
| PT-24 | Cifrado de red | Conectar por TCP y revisar adaptadores | AES256 activo | V15 |
| PT-25 | Eliminación | Listar objetos en la papelera | 0 objetos | V10 |
| PT-26 | Clon enmascarado | Comparar sensibles de pruebas vs. producción | Ninguna condición real | SQL*Plus |
| PT-27 | Reporte periódico | Correr el reporte tras provocar fallos | Aparecen fallos y bloqueos | `R01_reporte_semanal` |
| PT-28 | Derechos re-otorgables (negativa) | Intentar re-otorgar un permiso | ORA-01031 | SQL*Plus |
| PT-29 | Listener limitado | Revisar interfaces del listener | Solo 127.0.0.1 | `lsnrctl`, `netstat` |

**Cómo se lee:** cada prueba nombra el control que demuestra. El caso concreto del instituto y el resultado ANTES/DESPUÉS de cada una están en `docs/05-pruebas.md` y en la pestaña de pruebas del artefacto.

---
---

> **Cómo organizar la sección 4.** En tu informe es la única sección de *resultados*, y las Conclusiones (6) quedan para interpretar, no para repetir tablas. Por eso propongo dos bloques: **4.1–4.6 el diagnóstico (ANTES)**, que es lo que el título pide, y **4.7–4.8 el cierre (DESPUÉS)**, para que el lector vea el cambio. Si el profesor prefiere que "Resultados del diagnóstico" sea solo el estado inicial, mueve 4.7–4.8 a un apartado "Resultados de la remediación" o a las Conclusiones.

# 4. Resultados del diagnóstico

## 4.1 Alcance y método

El diagnóstico se ejecutó el 20/10/2026 sobre Oracle Database 21c Express Edition (21.3.0.0.0), PDB XEPDB1, esquema INSTITUTO, antes de aplicar cualquier remediación. Se corrieron los 17 scripts de verificación V01–V17 (carpeta `sql/01_verificacion/`) y cada salida se guardó con fecha y hora en `evidencias/antes/`. Las consultas se validaron contra la documentación de Oracle Database 21c. El escenario se creó con el script `00_crear_escenario.sql`, que siembra 12 malas prácticas (MP-01 a MP-12) de las que se esperaba hallar evidencia; los hallazgos que no se sembraron se reportan aparte porque aparecieron en la base por defecto.

## 4.2 Hallazgos sembrados

| ID | Hallazgo | Riesgo | Control | Evidencia |
| --- | --- | --- | --- | --- |
| MP-01 | DEV_RAMIRO tiene el rol DBA y una contraseña trivial: 160 privilegios peligrosos efectivos | R-CONF-01 | A8.2 | V07 |
| MP-02 | APP_MATRICULA tiene `SELECT ANY TABLE` | R-CONF-01 | A8.2, A5.15 | V07 |
| MP-03 | `SELECT` sobre ADECUACIONES otorgado a PUBLIC | R-CONF-01 | A5.15, A5.18, A8.3 | V02 |
| MP-04 | Cuenta SECRETARIA compartida, con permisos directos | R-CONF-02 | A5.16, A5.15 | V02 |
| MP-05 | La cuenta de una ex-secretaria sigue activa | R-CONF-02 | A5.16 | V03 |
| MP-06 | TESO_PAULA con `GRANT OPTION` sobre BECAS | R-CONF-01 | A5.18 | V05 |
| MP-07 | Docentes ven todas las notas (2000) y adecuaciones (120) sin filtro | R-CONF-01 | A8.3 | V08 |
| MP-08 | AUDITOR_EXT con `AUDIT_ADMIN`: puede purgar lo que audita | R-CONF-06 | A5.33 | V06 |
| MP-09 | SOPORTE_TI con `DATAPUMP_EXP_FULL_DATABASE`; DIR_EXPORTES abierto a PUBLIC | R-CONF-04 | A8.12 | V12 |
| MP-10 | Copia "borrada" que sigue en la papelera (500 estudiantes) | R-CONF-03 | A8.10 | V10 |
| MP-11 | Clon INSTITUTO_DEV con datos reales sin enmascarar | R-CONF-04 | A8.11, A8.33* | V11 |
| MP-12 | Perfil de la aplicación con intentos fallidos ilimitados | R-CONF-02 | A8.5, A5.17 | V09 |

## 4.3 Hallazgos reales (no sembrados)

| Hallazgo | Control | Evidencia |
| --- | --- | --- |
| DEV_RAMIRO y SOPORTE_TI quedan exentos de la redacción porque `EXP_FULL_DATABASE` incluye `EXEMPT REDACTION POLICY` | A8.11 | V11 |
| PUBLIC tiene `EXECUTE` sobre UTL_FILE, UTL_HTTP, UTL_INADDR, UTL_SMTP y UTL_TCP por defecto | A8.12 | V12 |
| Todas las cuentas tienen verificadores de contraseña 11G además de 12C | A8.5 | V09 |
| El perfil DEFAULT no tiene función de verificación e `IDLE_TIME` es ilimitado | A5.17, A8.5 | V04 |
| Auditoría con solo las políticas por defecto (`ORA_LOGON_FAILURES`, `ORA_SECURECONFIG`) | A8.15 | V14 |
| Versión 21.3.0.0.0 sin parches: Oracle no publica parches para XE | A8.8* | V17 |
| El listener apuntaba a una IP de red inexistente (192.168.0.250) y no arrancaba | A8.20, A8.21* | `listener.ora` |
| La contraseña de SYS es débil | A5.17 | Observación del DBA |

> Estos ocho hallazgos son tu mejor argumento de que el diagnóstico no fue solo "ver lo que sembré": hay riesgo real en una instalación por defecto.

## 4.4 Hallazgo crítico: la demostración

El hallazgo de mayor gravedad se comprobó con una cuenta real: la ex-secretaria (EX_KSALAS), cuya cuenta seguía activa, consultó qué estudiantes tienen un diagnóstico de autismo (F84) gracias a un permiso concedido a PUBLIC (PT-07). Una sola omisión (cuenta sin dar de baja) más una sola mala práctica (permiso a PUBLIC) bastaron para exponer la salud de menores de edad. Esto incumple a la vez el artículo 10 (seguridad de los datos) y el artículo 11 (deber de confidencialidad) de la Ley 8968, y es la razón de que el impacto de estos riesgos sea 5.

## 4.5 Madurez por control (ANTES)

Los 20 controles evaluados quedaron en **No cumple**: 14 en nivel 0 (inexistente) y 6 en nivel 1 (inicial). La madurez media fue **0,30** sobre 4.

| Nivel ANTES | Controles |
| --- | --- |
| 0 — Inexistente (14) | A5.12, A5.15, A5.18, A8.2, A8.3, A8.10, A8.11, A8.12, A8.13, A8.16*, A8.20, A8.21*, A8.24*, A8.33* |
| 1 — Inicial (6) | A5.16, A5.17, A5.33, A8.5, A8.8*, A8.15 |

Los controles en nivel 1 tienen algo por defecto de Oracle (bloqueo a los 10 intentos, auditoría mínima, `AUDSYS` protegido, versión registrada), pero sin evidencia de gestión propia. Los de nivel 0 no existían en absoluto (sin TDE, sin backup, sin roles, sin redacción, sin cifrado de red).

> Pega aquí la captura del mapa de calor y de la barra de madurez de la pestaña **Visión general** del artefacto (modo ANTES).

## 4.6 Resultado de las pruebas en el estado ANTES

De las 29 pruebas de la batería, **24 fallaron** (el acceso indebido fue posible) y **5 quedaron pendientes** porque no se podían ejecutar sin el control implementado (PT-08, PT-15, PT-19, PT-21, PT-27). Por origen: 14 ejecutadas, 10 inferidas de la configuración observada y 5 pendientes.

Ejemplos del estado inicial:
- **PT-01:** APP_MATRICULA leyó las 90 becas con ingreso familiar y cuenta bancaria.
- **PT-03:** DOC_MCHAVES vio las 2000 notas de los 6 docentes.
- **PT-04:** SECRETARIA vio la cuenta bancaria completa.
- **PT-12 / PT-13:** EX_KSALAS y SECRETARIA conectaron con éxito.
- **PT-24:** el tráfico por TCP no mostraba ningún algoritmo de cifrado activo.

**Límite declarado:** las pruebas inferidas se deducen de la configuración y no se corrieron en el estado ANTES; se identifican como tales en la tabla para no presentarlas como ejecutadas.

## 4.7 Resultado tras la remediación (estado DESPUÉS)

Tras aplicar los scripts de remediación R01–R06 y verificar de nuevo con V01–V17 (27/10/2026): **19 de 20 controles en Cumple y 1 en Parcial** (A8.8*, parcheo), con madurez media de **2,95**, y las 29 pruebas con resultado DESPUÉS. A8.8* queda en nivel 2 porque XE no recibe parches: la limitación se documentó como riesgo aceptado (`docs/riesgo-aceptado-parcheo.md`).

Por bloque de remediación, el orden aplicado fue: accesos y privilegios (R01) → identidades y autenticación (R02) → restricción por fila, redacción y clon enmascarado (R03) → auditoría y monitoreo (R04) → fuga de datos y eliminación (R05) → TDE (R06b) → respaldo RMAN cifrado (R06c) → cifrado de red, verificadores 12C y listener (R06a, R06e).

> Pega aquí la captura del gráfico multilínea **«Cómo mejoró el instituto con cada bloque»** de la Visión general. Aclara en el pie de figura que solo ANTES y DESPUÉS son mediciones reales; los puntos intermedios son calculados y están rotulados así.

## 4.8 Limitaciones y priorización

**Limitaciones declaradas**
- Tres cuentas (EX_KSALAS, SECRETARIA y PDBADMIN) conservan un verificador 11G almacenado; las dos primeras están bloqueadas y `ALLOWED_LOGON_VERSION_SERVER = 12a` ya no lo admite para iniciar sesión.
- La contraseña de SYS no se cambió: se decidió dejarla como está por tratarse de un laboratorio y porque cambiarla por un valor aleatorio no era recuperable.
- Las pruebas se hicieron en un solo equipo y en una sola ejecución; no demuestran estabilidad en el tiempo.
- Ningún control llegó a nivel 4 (gestionado), que requiere revisión periódica sostenida.
- Los controles complementarios (\*) y el apetito de riesgo (residual ≤ 6) están pendientes de confirmar con el profesor.

**Controles prioritarios:** el artefacto calcula un panel «5 controles para empezar» con el criterio *suma P×I × salto de madurez*. **[Pega aquí los 5 controles que muestra el panel y su porcentaje]**; ese orden justifica por dónde conviene comenzar en una organización real con recursos limitados.

---

> **Revisión antes de pegar**
> 1. Confirma las fechas (ANTES 20/10/2026, DESPUÉS 27/10/2026). Algunos resultados de `pruebas.json` citan el 22/10, de un juego de evidencias que ya retiraste del repositorio; actualízalos o cita el 20/10 y el 27/10.
> 2. Revisa que 19 Cumple + 1 Parcial y la media de 2,95 coincidan con la Visión general del artefacto (yo los calculé de la matriz).
> 3. "Resultados" son tuyos: parafrasea con tu voz los párrafos de 4.4, 4.5 y 4.7; hacen parte de lo que defiendes ante el profesor.
> 4. Cuando pegues, agrega a la tabla de uso de IA una fila para esta sesión (prompt exacto, aporte y tu validación en pasado, no futuro).
