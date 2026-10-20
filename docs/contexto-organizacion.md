# Contexto de la organización — Instituto Oracle Heredia

> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.

## 1. Organización
- **Nombre:** Instituto Oracle Heredia (ficticio)
- **Sector:** Educación, colegio técnico
- **Ubicación:** Heredia, Costa Rica
- **Motor:** Oracle Database 21c Express Edition (21.3), PDB XEPDB1, esquema INSTITUTO
- **Descripción:** El Instituto Oracle Heredia es un colegio técnico ficticio de Heredia que ofrece especialidades en Informática y Electrónica. Su base de datos Oracle guarda a 500 estudiantes de décimo a duodécimo año, la mayoría menores de edad, junto con los datos de sus encargados, las notas de seis docentes, las adecuaciones curriculares con la condición de salud que las justifica y las becas con el ingreso familiar y la cuenta bancaria donde se deposita el beneficio. La Ley 8968 obliga a proteger todos esos datos, y los de salud y condición socioeconómica son sensibles; además, al tratarse de menores, una divulgación causaría un daño difícil de reparar. En este proyecto actúo como DBA: diagnostico la base, aplico los controles de ISO/IEC 27001:2022 y demuestro con evidencia que la confidencialidad se cumple.

## 2. Datos personales

| Tabla | Columnas | Clasificación | Categoría Ley 8968 |
| --- | --- | --- | --- |
| ADECUACIONES | detalle_condicion, recomendaciones | Sensible | Dato sensible (información biomédica) |
| BECAS | ingreso_familiar | Sensible | Dato sensible (condición socioeconómica) |
| ADECUACIONES | tipo_adecuacion, fecha_resolucion | Restringido | Acceso restringido |
| ESTUDIANTES | cedula, fecha_nac, telefono, correo, direccion, encargado | Restringido | Acceso restringido |
| BECAS | num_cuenta | Restringido | Acceso restringido |
| NOTAS | materia, periodo, nota | Restringido | Acceso restringido |
| ESTUDIANTES | nombre, sexo, grupo, fecha_ingreso | Interno | Acceso restringido |
| BECAS | tipo_beca, monto_mensual, fecha_aprobacion | Interno | — |
| DOCENTES | codigo_empleado, usuario_bd | Interno | — |
| DOCENTES | nombre, especialidad | Público | Acceso irrestricto |

⭐ **Columna de alta sensibilidad:** `INSTITUTO.ADECUACIONES.DETALLE_CONDICION`

El detalle de la condición es el dato más sensible de la base porque revela la salud de un menor de edad: en los datos de prueba hay casos de trastorno del espectro autista (F84), déficit de atención (F90), epilepsia (G40) y depresión (F32). El artículo 3 de la Ley 8968 define como sensible la información biomédica (y también la condición socioeconómica, que aparece en BECAS) y el artículo 9 restringe su tratamiento. En el diagnóstico inicial comprobé que una ex-secretaria, cuya cuenta seguía activa, pudo consultar qué estudiantes tienen un diagnóstico de autismo gracias a un permiso otorgado a PUBLIC. Eso incumple a la vez el artículo 10 (seguridad de los datos) y el deber de confidencialidad, por lo que todo riesgo que exponga esta columna se califica con impacto 5.

## 3. Actores y cuentas

| Actor | Cuenta | Debe | No debe |
| --- | --- | --- | --- |
| DBA | `SYS (después: cuenta nominal de DBA)` | Administrar la base | Leer condiciones de salud sin necesidad |
| Desarrollador | `DEV_RAMIRO` | Trabajar en DEV con datos enmascarados | Ver datos reales de producción |
| Aplicación de matrícula | `APP_MATRICULA` | Gestionar los datos de contacto de los estudiantes | Ver becas ni condiciones de salud |
| Docentes | `DOC_MCHAVES, DOC_RBRENES` | Ver y registrar las notas de sus propios estudiantes | Ver notas o adecuaciones de otros docentes, ni el detalle de la condición de salud |
| Secretaría | `SECRETARIA (compartida)` | Datos de contacto y registro de notas | Ingreso familiar ni cuenta bancaria completa |
| Tesorería | `TESO_PAULA` | Montos de las becas con la cuenta enmascarada | Condiciones de salud; re-otorgar permisos |
| Soporte TI | `SOPORTE_TI` | Operación técnica | Exportar la base completa |
| Auditor externo | `AUDITOR_EXT` | Leer el rastro de auditoría | Administrar o purgar la auditoría |
| Ex-secretaria | `EX_KSALAS` | Nada (renunció) | Cualquier acceso |

## 4. Malas prácticas iniciales (estado "ANTES")

| ID | Mala práctica | Consecuencia | Riesgo | Controles | Evidencia |
| --- | --- | --- | --- | --- | --- |
| MP-01 | El desarrollador DEV_RAMIRO tiene el rol DBA y la contraseña ramiro123 | Puede leer, cambiar y exportar todo: 160 privilegios peligrosos efectivos | R-CONF-01 | A8.2 | V07_A8_2 |
| MP-02 | La aplicación APP_MATRICULA tiene SELECT ANY TABLE | Si la app es vulnerada, el atacante lee toda la base (incluidas las 90 becas con ingreso familiar y cuenta bancaria) | R-CONF-01 | A8.2, A5.15 | V07_A8_2 |
| MP-03 | SELECT sobre ADECUACIONES otorgado a PUBLIC | Cualquier cuenta, incluso las futuras, lee las condiciones de salud de los estudiantes | R-CONF-01 | A5.15, A5.18, A8.3 | V02_A5_15 |
| MP-04 | Cuenta SECRETARIA compartida por todas las secretarias, con permisos directos sobre BECAS y NOTAS | No se sabe quién hizo qué y secretaría ve el ingreso familiar y las cuentas bancarias completas | R-CONF-02 | A5.16, A5.15 | V02_A5_15 |
| MP-05 | La cuenta de la ex-secretaria EX_KSALAS sigue activa | Una persona sin relación con el instituto puede entrar y leer datos de estudiantes y condiciones de salud | R-CONF-02 | A5.16 | V03_A5_16 |
| MP-06 | TESO_PAULA tiene SELECT y UPDATE sobre BECAS con GRANT OPTION | Puede dar acceso a terceros sin que el DBA lo sepa | R-CONF-01 | A5.18 | V05_A5_18 |
| MP-07 | Los docentes tienen SELECT sobre todas las notas y adecuaciones, sin filtro por docente | DOC_MCHAVES ve las 2000 notas de los 6 docentes y las 120 adecuaciones | R-CONF-01 | A8.3 | V08_A8_3 |
| MP-08 | El auditor externo AUDITOR_EXT tiene AUDIT_ADMIN | Puede configurar y purgar el mismo rastro que audita | R-CONF-06 | A5.33 | V06_A5_33 |
| MP-09 | SOPORTE_TI tiene DATAPUMP_EXP_FULL_DATABASE y el directorio DIR_EXPORTES es de lectura y escritura para PUBLIC | Soporte puede exportar la base completa y cualquiera puede escribir archivos en el servidor | R-CONF-04 | A8.12 | V12_A8_12 |
| MP-10 | Una copia ESTUDIANTES_RESPALDO_2025 fue "borrada" pero sigue en la papelera | Los 500 estudiantes siguen recuperables con FLASHBACK | R-CONF-03 | A8.10 | V10_A8_10 |
| MP-11 | El clon INSTITUTO_DEV tiene estudiantes y adecuaciones reales sin enmascarar | Las condiciones de salud reales están en un entorno de pruebas con menos controles | R-CONF-04 | A8.11, A8.33* | V11_A8_11 |
| MP-12 | PERFIL_APLICACIONES permite intentos fallidos ilimitados y está asignado a APP_MATRICULA | La contraseña "app" se puede adivinar por fuerza bruta sin bloqueo | R-CONF-02 | A8.5, A5.17 | V09_A8_5 |

## 5. Hallazgos reales del diagnóstico (no sembrados)

| Hallazgo | Control | Evidencia |
| --- | --- | --- |
| DEV_RAMIRO y SOPORTE_TI quedan exentos de la redacción porque el rol EXP_FULL_DATABASE incluye EXEMPT REDACTION POLICY | A8.11 | V11_A8_11 |
| PUBLIC tiene EXECUTE sobre UTL_FILE, UTL_HTTP, UTL_INADDR, UTL_SMTP y UTL_TCP por defecto | A8.12 | V12_A8_12 |
| Todas las cuentas tienen verificadores de contraseña 11G además de 12C | A8.5 | V09_A8_5 |
| El perfil DEFAULT no tiene PASSWORD_VERIFY_FUNCTION e IDLE_TIME es ilimitado | A5.17, A8.5 | V04_A5_17 |
| La auditoría está en modo mixto y solo tiene las políticas por defecto ORA_LOGON_FAILURES y ORA_SECURECONFIG | A8.15 | V14_A8_15 |
| La versión es 21.3.0.0.0 sin parches: Oracle no publica parches para XE | A8.8* | V17_A8_8 |
| El listener escuchaba en una IP de red antigua (192.168.0.250) y no arrancaba; se limitó a localhost | A8.20 | listener.ora |
| La contraseña de SYS es débil | A5.17 | Observación del DBA |

