# 1. Tabla de riesgos de confidencialidad (R-CONF)

> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.

Nivel = Probabilidad (P) × Impacto (I), escala 1–5. Bandas: 1–4 Bajo · 5–9 Medio · 10–14 Alto · 15–25 Crítico.
Apetito de riesgo: residual ≤ 6. Propuesta: un riesgo residual de 6 o menos se considera aceptable. Pendiente de confirmar con el profesor (pregunta 3).

## Riesgos en general (aplican a cualquier base Oracle)

| ID | Riesgo | Descripción | Causas típicas | Activo | P | I | Nivel inherente | Meta residual (provisional) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R-CONF-01 | Acceso no autorizado por privilegios excesivos o mal asignados | Un usuario, aplicación o proceso accede a datos que su función no requiere porque la base le concedió más permisos de los necesarios. Es la causa más frecuente de fuga de confidencialidad en una base de datos, porque ocurre con acceso legítimo. | Rol DBA o privilegios ANY otorgados a cuentas que no administran; Permisos otorgados a PUBLIC; Permisos directos a usuarios en lugar de roles; WITH GRANT OPTION o WITH ADMIN OPTION sin control; Ausencia de restricción por fila o por columna | Tablas y columnas con datos personales o sensibles | 5 | 5 | 25 Crítico | 6 Medio (P2 × I3) |
| R-CONF-02 | Suplantación de identidad por autenticación débil o cuentas sin gestión | Un atacante, o una persona sin autorización, se hace pasar por un usuario legítimo porque la base acepta contraseñas débiles, no bloquea intentos repetidos o conserva cuentas que ya no deberían existir. | Contraseñas débiles o por defecto, sin función de verificación; Perfiles sin límite de intentos fallidos ni de inactividad; Cuentas compartidas, sin trazabilidad individual; Cuentas de personas que ya no pertenecen a la organización; Verificadores de contraseña antiguos (11G) habilitados | Cuentas de la base de datos y sus credenciales | 4 | 5 | 20 Crítico | 6 Medio (P2 × I3) |
| R-CONF-03 | Exposición de datos en reposo y eliminación insegura | Quien obtenga los archivos de datos, un respaldo o un objeto "borrado" puede leer la información sin pasar por los controles de acceso de la base. | Datafiles y backups sin cifrar (sin TDE ni cifrado de RMAN); Objetos eliminados que permanecen en la papelera de reciclaje; Backups y dumps vencidos que no se destruyen; Keystore o claves sin gestión | Datafiles, backups, papelera y dumps | 3 | 5 | 15 Crítico | 5 Medio (P1 × I5) |
| R-CONF-04 | Fuga por exportaciones y entornos no productivos | Los datos salen de producción mediante exportaciones, copias o canales de red que no tienen los mismos controles que la base original. | Roles de exportación completa asignados a cuentas operativas; Directorios y paquetes UTL_* abiertos a PUBLIC; Clones DEV/TEST con datos reales sin enmascarar; Exportaciones sin cifrar ni auditar; Database links sin control | Dumps de Data Pump y esquemas de desarrollo y pruebas | 3 | 5 | 15 Crítico | 5 Medio (P1 × I5) |
| R-CONF-05 | Interceptación de datos en tránsito | El tráfico entre clientes y servidor (consultas y resultados) puede ser capturado si viaja sin cifrar o si el listener está expuesto a redes no confiables. | Cifrado de Oracle Net sin configurar (ENCRYPTION_SERVER en ACCEPTED por defecto); Listener escuchando en interfaces innecesarias; Sin restricción de los nodos que pueden conectarse; Conexiones desde redes compartidas | Sesiones SQL*Net entre aplicación y base | 2 | 4 | 8 Medio | 3 Bajo (P1 × I3) |
| R-CONF-06 | Falta de trazabilidad y manipulación del registro de auditoría | Sin un registro confiable de quién accedió a qué, el abuso de accesos legítimos pasa inadvertido y no se puede demostrar el cumplimiento. | Sin políticas de auditoría sobre los datos sensibles; Auditoría que nadie revisa; Cuentas operativas con AUDIT_ADMIN que pueden purgar el rastro; Sin copia del rastro fuera de la base (SIEM) | Rastro de auditoría (UNIFIED_AUDIT_TRAIL) | 4 | 3 | 12 Alto | 4 Bajo (P2 × I2) |

## Ejemplo en el escenario de prueba (Instituto Oracle Heredia)

| ID | Cómo se manifestó | Activo | Malas prácticas | Justificación de P | Justificación de I | Justificación de la meta |
| --- | --- | --- | --- | --- | --- | --- |
| R-CONF-01 | Un desarrollador con rol DBA, una app con SELECT ANY TABLE, condiciones de salud legibles por PUBLIC y docentes que ven las notas y adecuaciones de todos. | ADECUACIONES, NOTAS, BECAS y ESTUDIANTES | MP-01, MP-02, MP-03, MP-06, MP-07 | Ya se demostró: PUBLIC implica que cualquier cuenta, actual o futura, tiene acceso, y la ex-secretaria lo usó en la demo | Expone las condiciones de salud de 120 adecuaciones, en su mayoría de menores de edad: datos sensibles masivos según el art. 3 y el art. 9 de la Ley 8968 | Con roles mínimos y filtro por fila baja la probabilidad a 2; la redacción reduce lo que se vería si ocurre (impacto 3). |
| R-CONF-02 | Contraseñas como "app" o "temporal", una cuenta compartida de secretaría, la cuenta de una ex-secretaria activa y un perfil con intentos ilimitados. | Cuentas APP_MATRICULA, SECRETARIA, EX_KSALAS y DEV_RAMIRO | MP-04, MP-05, MP-12 | Contraseñas como "app" o "temporal" se adivinan sin conocimiento técnico y el perfil de la aplicación no bloquea nunca | Suplantar una cuenta con rol DBA (contraseña ramiro123) da acceso total a los datos sensibles | El bloqueo y las contraseñas fuertes bajan la probabilidad a 2; con privilegios mínimos (A8.2, A5.15) una cuenta suplantada ya no tiene acceso amplio (impacto 3). |
| R-CONF-03 | Datafile ts_instituto01.dbf sin cifrar, ningún backup y una copia de estudiantes que sigue en la papelera. | ts_instituto01.dbf y la papelera de INSTITUTO | MP-10 | Requiere acceso al sistema de archivos del servidor o a una copia del backup | Quien copie el datafile o el backup obtiene la base completa en texto legible | TDE y backups cifrados bajan la probabilidad a 1. El impacto se deja en 5 hasta medirlo: se revisará con la evidencia de la fase Verificar. |
| R-CONF-04 | SOPORTE_TI puede exportar toda la base, DIR_EXPORTES es de PUBLIC, PUBLIC ejecuta UTL_* y el clon INSTITUTO_DEV contiene condiciones de salud reales. | Dumps y esquema INSTITUTO_DEV | MP-09, MP-11 | Exportar requiere la cuenta de soporte o de desarrollo, pero el clon con datos reales ya existe | Un dump o el clon contienen todas las condiciones de salud y los ingresos familiares fuera de producción | Sin exportación abierta ni clon real baja la probabilidad a 1. El impacto sigue en 5 si un dump sin cifrar llegara a filtrarse; se revisará al medir. |
| R-CONF-05 | Sin cifrado de red en sqlnet.ora; el listener estaba configurado sobre una IP de la red local y se limitó a localhost el 19/10. | Sesiones de la aplicación de matrícula | — | Requiere estar en la red y capturar tráfico; hoy el listener solo escucha en localhost | Se verían las consultas y los resultados de las sesiones capturadas, no la base completa | El cifrado AES256 baja la probabilidad a 1 y lo capturado deja de ser legible (impacto 3). |
| R-CONF-06 | Solo hay políticas por defecto, ninguna sobre ADECUACIONES, y el auditor externo tiene AUDIT_ADMIN. | UNIFIED_AUDIT_TRAIL | MP-08 | Hoy ningún acceso a los datos sensibles queda registrado, salvo los de SYS | No expone datos por sí mismo, pero impide detectar el abuso y demostrar el cumplimiento del art. 10 de la Ley 8968 | Con auditoría revisada cada semana el abuso se detecta pronto: probabilidad 2 e impacto 2. |

## Escala

| Valor | Probabilidad | Impacto |
| --- | --- | --- |
| 1 | Rara: Casi imposible con la configuración actual | Insignificante: Sin datos personales expuestos |
| 2 | Improbable: Requiere varias fallas juntas o estar en la red interna | Menor: Datos internos o pocos registros |
| 3 | Posible: Requiere conocimiento técnico o acceso al servidor | Moderado: Datos restringidos de pocos titulares, o pérdida de capacidad de detección |
| 4 | Probable: Una cuenta interna puede hacerlo sin conocimientos especiales | Mayor: Datos restringidos masivos o datos sensibles de pocos titulares |
| 5 | Casi segura: Es trivial o ya se demostró en el diagnóstico | Catastrófico: Datos sensibles masivos; falta gravísima de la Ley 8968 |

## Controles que tratan cada riesgo

| Riesgo | Controles |
| --- | --- |
| R-CONF-01 | A8.2, A5.15, A5.18, A8.3, A8.11 |
| R-CONF-02 | A5.16, A5.17, A8.5, A8.2, A5.15, A8.8* |
| R-CONF-03 | A8.10, A8.13, A8.24*, A5.12, A8.8* |
| R-CONF-04 | A8.12, A8.11, A8.33* |
| R-CONF-05 | A8.20, A8.21* |
| R-CONF-06 | A8.15, A5.33, A8.16* |

