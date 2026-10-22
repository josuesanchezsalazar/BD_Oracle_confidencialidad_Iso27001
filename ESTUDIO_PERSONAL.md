# ESTUDIO PERSONAL — Controles ISO 27001:2022 para la confidencialidad en Oracle

> **Para qué sirve este archivo.** Es para que **tú** entiendas el proyecto y puedas defenderlo. No es un entregable: no va al informe ni al profesor. Explica **qué decidí, por qué lo decidí y cómo se justifica**, contra lo que pide el PDF de la asignación.
>
> **Cómo leerlo.** Las secciones 1 y 2 son lo más importante para el jueves. La 3 es el marco teórico (lo que el PDF llama "análisis de temas relacionados"). La 4 responde si el artefacto cumple. La 5 cuenta qué pasó realmente al ejecutar. La 6 trae preguntas probables con respuesta.
>
> **Aviso de honestidad.** Donde un dato debe confirmarse en la fuente oficial (ISO, Oracle, SCIJ) lo marqué con **(verificar)**. Regla del curso: lo que no verificaste no lo afirmes como hecho. Esto se declara en [docs/uso-ia.md](docs/uso-ia.md).

---

## 0. Dónde está el proyecto hoy (21/10/2026)

| Fase PHVA | Estado | Qué hay |
|---|---|---|
| **Planificar** | Hecho | Riesgos, tareas, mapeo de controles, matriz, pruebas definidas, escenario, diagnóstico ANTES (V01–V17) |
| **Hacer** | Casi hecho | Bloques R01–R05 aplicados; TDE y respaldo cifrado hechos; **falta** el cifrado de red (requiere administrador) |
| **Verificar** | En curso | V y pruebas ejecutadas para R01–R05; falta repetir V13, V15, V16, V17 y las pruebas PT-18 a PT-21, PT-24 |
| **Actuar** | Pendiente | Riesgo residual y plan de mejora |

**Situación técnica a resolver antes de seguir:** al terminar el respaldo RMAN la base quedó **montada, no abierta**, y luego los servicios `OracleServiceXE` y `OracleOraDB21Home1TNSListener` aparecen **detenidos** (probablemente el equipo se reinició o suspendió). No pude iniciarlos porque requiere administrador. Para retomar: PowerShell **como administrador** → iniciar ambos servicios → `sqlplus "sys/<clave> as sysdba"` → `ALTER DATABASE OPEN;` → `ALTER PLUGGABLE DATABASE ALL OPEN;`. Los datos no se pierden: el último apagado fue ordenado (`SHUTDOWN IMMEDIATE`).

---

## 1. La idea central (cómo defenderlo en 1 minuto)

> "Soy el DBA de un colegio técnico que guarda datos sensibles de menores (condiciones de salud, ingreso familiar). La Ley 8968 me obliga a protegerlos. En vez de **afirmar** que están protegidos, **lo medí**: escribí scripts SQL que miran la configuración de Oracle y la comparan con lo que exige ISO 27001:2022. Primero medí el estado inicial (ANTES), que salió malo a propósito. Luego apliqué las correcciones (HACER) y repetí **los mismos scripts** (VERIFICAR) para demostrar con evidencia que mejoró."

Tres frases que resumen todo el diseño:

1. **Riesgo → Tarea del DBA → Control ISO → Script → Evidencia.** Cada riesgo nace en algo que el DBA hace, se trata con un control de la norma, y el control se comprueba con una consulta SQL.
2. **Lo general primero, el ejemplo después.** Los riesgos y controles valen para cualquier Oracle; el colegio es solo el banco de pruebas.
3. **El ANTES es malo a propósito.** Si todo estuviera bien desde el inicio no habría nada que demostrar.

---

## 2. Qué decidí y por qué (objetivo por objetivo del PDF)

### 2.1 Objetivo: "Identificar y clasificar al menos 5 riesgos de confidencialidad (R-CONF) asociados a motores de BD (Oracle)"

**Qué hice:** 6 riesgos, no 5. Los cinco primeros son los que pide el PDF (R-CONF-01 a 05); el sexto (R-CONF-06, trazabilidad del registro de auditoría) es adicional y está marcado así.

**Por qué 6 y no 5.** El PDF dice "al menos 5". Con cinco quedaba sin cubrir un hueco real: si nadie registra quién lee los datos, los otros cinco riesgos pueden materializarse sin que nadie lo note. Agregarlo cuesta poco y cierra el ciclo (prevenir + detectar).

**Cómo clasifiqué: Probabilidad × Impacto, escala 1–5.**

| Banda | Rango (P×I) | Por qué estos cortes |
|---|---|---|
| Bajo | 1–4 | Aceptable sin acción |
| Medio | 5–9 | Se trata en el plan |
| Alto | 10–14 | Se trata con prioridad |
| Crítico | 15–25 | Se trata primero |

Usé 1–5 porque es la escala más común en matrices de riesgo (ISO 27005 no impone una) y permite 25 combinaciones. **Está pendiente confirmar con el profesor** si quiere otra escala (pregunta 3 de [docs/preguntas-profesor.md](docs/preguntas-profesor.md)).

**Los riesgos, con la razón de cada P e I:**

| ID | Riesgo | P | I | Nivel | Por qué ese P e I |
|---|---|---|---|---|---|
| R-CONF-01 | Acceso por privilegios excesivos | 5 | 5 | 25 Crítico | **P=5** porque ya se demostró en el diagnóstico: una ex-secretaria leyó diagnósticos. **I=5** porque expone datos sensibles masivos de menores (Ley 8968) |
| R-CONF-02 | Suplantación por autenticación débil | 4 | 5 | 20 Crítico | **P=4**: contraseñas como "app" se adivinan sin conocimiento técnico. **I=5**: suplantar una cuenta con rol DBA da todo |
| R-CONF-03 | Datos en reposo y eliminación insegura | 3 | 5 | 15 Crítico | **P=3**: requiere acceso al servidor o al backup. **I=5**: quien copie el archivo lee todo |
| R-CONF-04 | Fuga por exportaciones y clones | 3 | 5 | 15 Crítico | **P=3**: requiere la cuenta de soporte, pero el clon con datos reales ya existía. **I=5**: un dump trae todo fuera de producción |
| R-CONF-05 | Datos en tránsito | 2 | 4 | 8 Medio | **P=2**: hay que estar en la red; el listener solo escucha en localhost. **I=4**: se ven consultas, no la base completa |
| R-CONF-06 | Falta de trazabilidad | 4 | 3 | 12 Alto | **P=4**: ningún acceso a datos sensibles quedaba registrado. **I=3**: no expone datos por sí mismo, impide detectar el abuso |

**Cómo explicar el criterio de P e I (esto lo preguntan):** cada valor se justifica con evidencia del escenario, no con intuición. La columna "Justificación de P / de I" de [docs/01-riesgos.md](docs/01-riesgos.md) lo deja escrito. Una calificación sin justificación se puede discutir; una con evidencia, no.

**La meta residual** (columna "Meta") es el nivel que se espera tras aplicar controles. Propuse un **apetito de riesgo ≤ 6**: un riesgo residual de 6 o menos se acepta. Es una propuesta mía, no una regla del PDF. Se recalcula en la fase Verificar con lo que realmente se logró.

**Por qué agrupé así los riesgos.** Cada riesgo agrupa causas que se atacan con las mismas medidas:

- R-CONF-01 y 02 = **quién entra y con qué permisos** (identidad y acceso)
- R-CONF-03 = **datos quietos** (disco, backups, papelera)
- R-CONF-04 = **datos que salen** (exportaciones, clones)
- R-CONF-05 = **datos en movimiento** (red)
- R-CONF-06 = **ver lo que pasó** (auditoría)

Esas cinco áreas cubren el ciclo de vida del dato: en reposo, en tránsito, en uso, y la capacidad de detectar. Si el profesor pregunta "¿por qué estos riesgos y no otros?", esta es la respuesta.

---

### 2.2 Objetivo: "Mapear al menos 12 tareas críticas del DBA"

**Qué hice:** exactamente las 12 que el PDF enumera entre paréntesis (usuarios, privilegios, autenticación, TDE, masking, backup, auditoría, parcheo, listener, eliminación segura, logs, clones DEV/TEST). No inventé otras.

**Por qué las 12 del PDF y no más.** El objetivo dice "al menos 12" y la lista entre paréntesis es la definición implícita de "críticas". Seguirla evita que el profesor diga que faltó una.

**Cada tarea tiene 5 datos** (en [docs/02-tareas-dba.md](docs/02-tareas-dba.md)): qué hace el DBA, frecuencia, riesgo que reduce, controles que aplica, y script que lo verifica.

| ID | Tarea | Riesgo | Controles | Por qué es crítica |
|---|---|---|---|---|
| T-01 | Gestión de usuarios | R-CONF-02 | A5.16, A5.18 | Una cuenta de alguien que se fue es una puerta abierta |
| T-02 | Privilegios y roles | R-CONF-01 | A5.15, A8.2, A5.18 | Es la causa más frecuente de fuga en bases de datos |
| T-03 | Autenticación | R-CONF-02 | A5.17, A8.5 | Sin bloqueo ni complejidad, la contraseña se adivina |
| T-04 | Cifrado TDE | R-CONF-03 | A8.24* | Protege archivos y backups robados |
| T-05 | Masking y redacción | R-CONF-01 | A8.11, A8.3, A5.12 | Reduce lo que se ve aunque haya acceso |
| T-06 | Backup | R-CONF-03 | A8.13 | Un backup sin cifrar es la base completa en un archivo |
| T-07 | Auditoría | R-CONF-06 | A8.15, A5.33 | Sin rastro no hay detección ni evidencia legal |
| T-08 | Parcheo | R-CONF-02, 03 | A8.8* | Las vulnerabilidades conocidas son la vía de entrada más común |
| T-09 | Listener y red | R-CONF-05 | A8.20, A8.21* | Define quién puede conectarse y si el tráfico viaja cifrado |
| T-10 | Eliminación segura | R-CONF-03 | A8.10 | "Borrado" no es borrado (papelera, backups viejos) |
| T-11 | Logs y monitoreo | R-CONF-06 | A8.15, A8.16*, A5.33 | Auditar sin revisar no sirve |
| T-12 | Clones DEV/TEST | R-CONF-04 | A8.11, A8.12, A8.33* | Los entornos de prueba tienen la guardia baja |

\* Control complementario, fuera de la lista de 15 del PDF.

**Por qué conecto tareas con riesgos (el "mapeo").** Es el centro del diseño. Un riesgo sin tarea es un problema que nadie sabe a quién asignar; una tarea sin riesgo es trabajo sin motivo. El mapeo demuestra que cada tarea del DBA existe porque reduce un riesgo concreto.

---

### 2.3 Objetivo: "Seleccionar y justificar controles del Anexo A 2022 pertinentes (los 15 listados)"

**Qué hice:** usé **los 15 del PDF** y agregué **5 complementarios** (A8.24, A8.8, A8.16, A8.21, A8.33) marcados con asterisco.

**Por qué agregué 5 si el PDF da una lista.** Porque el propio PDF pide cosas que **su lista de 15 no cubre**:

| El PDF pide en las tareas | Control que lo cubre | ¿Está en los 15? |
|---|---|---|
| Cifrado TDE | A8.24 Uso de criptografía | No |
| Parcheo | A8.8 Gestión de vulnerabilidades técnicas | No |
| Logs y monitoreo | A8.16 Actividades de monitoreo | No |
| Listener | A8.21 Seguridad de los servicios de red | No |
| Clones DEV/TEST | A8.33 Información de prueba | No |

Si no los agregaba, había tareas obligatorias sin ningún control asociado. **Esta es una decisión mía y debes decirlo así**: "el PDF exige estas tareas pero su lista de controles no las cubre; agregué cinco y los marqué". Falta confirmar con el profesor (pregunta 4).

**Cómo justifiqué cada control: la plantilla de 4 preguntas.** Esto es lo que debes repetir si te piden "justifica A8.2":

1. **¿Qué exige la norma?** (la frase de ISO 27002)
2. **¿Por qué aplica a un DBA?** (qué riesgo del proyecto trata)
3. **¿Cómo se implementa en Oracle?** (comando o configuración)
4. **¿Cómo se comprueba?** (consulta SQL y criterio de aceptación)

Ejemplo completo con A8.2:

| Pregunta | Respuesta |
|---|---|
| ¿Qué exige? | Restringir y gestionar los derechos de acceso privilegiado |
| ¿Por qué aplica? | R-CONF-01: un desarrollador con rol DBA ve todo |
| ¿Cómo se implementa? | Quitar `DBA` y privilegios `ANY` a cuentas no administrativas; dar roles mínimos |
| ¿Cómo se comprueba? | `V07`: roles poderosos y privilegios `ANY` por cuenta. Aceptación: 0 cuentas no administrativas con rol DBA o `ANY` |

**Los 20 controles en una tabla de estudio** (el detalle completo está en [docs/03-mapeo-controles.md](docs/03-mapeo-controles.md)):

| Control | Nombre | Tema ISO | Riesgo que trata | Cómo se implementa en Oracle | Script |
|---|---|---|---|---|---|
| A5.12 | Clasificación de la información | Organizacional | R-CONF-03 | `COMMENT ON COLUMN` con etiqueta `CLASIF:` por columna | V01 |
| A5.15 | Control de acceso | Organizacional | R-CONF-01, 02 | Roles por función; nada a PUBLIC ni directo a usuarios | V02 |
| A5.16 | Gestión de identidades | Organizacional | R-CONF-02 | Una cuenta por persona; bloquear las de quien sale | V03 |
| A5.17 | Información de autenticación | Organizacional | R-CONF-02 | Perfil con función de verificación de contraseña | V04 |
| A5.18 | Derechos de acceso | Organizacional | R-CONF-01 | Sin `GRANT OPTION`; revisión periódica | V05 |
| A5.33 | Protección de registros | Organizacional | R-CONF-06 | El auditor solo lee (`AUDIT_VIEWER`), no purga (`AUDIT_ADMIN`) | V06 |
| A8.2 | Acceso privilegiado | Tecnológico | R-CONF-01 | Sin rol DBA ni `ANY` en cuentas no administrativas | V07 |
| A8.3 | Restricción de acceso a la información | Tecnológico | R-CONF-01 | VPD (`DBMS_RLS`): cada docente ve solo sus filas | V08 |
| A8.5 | Autenticación segura | Tecnológico | R-CONF-02 | Bloqueo por intentos, `IDLE_TIME`, solo verificador 12C | V09 |
| A8.10 | Eliminación de la información | Tecnológico | R-CONF-03 | Purgar papelera; destruir backups vencidos | V10 |
| A8.11 | Enmascaramiento de datos | Tecnológico | R-CONF-01, 04 | Data Redaction (`DBMS_REDACT`); clon enmascarado | V11 |
| A8.12 | Prevención de fuga de datos | Tecnológico | R-CONF-04 | Quitar exportación completa y `UTL_*` a PUBLIC; auditar Data Pump | V12 |
| A8.13 | Respaldo de la información | Tecnológico | R-CONF-03 | RMAN con cifrado y restauración probada | V13 |
| A8.15 | Registro (logging) | Tecnológico | R-CONF-06 | Auditoría unificada sobre datos sensibles y gestión de accesos | V14 |
| A8.20 | Seguridad de redes | Tecnológico | R-CONF-05 | Cifrado de Oracle Net (AES256) en `sqlnet.ora` | V15 |
| A8.24* | Uso de criptografía | Tecnológico | R-CONF-03 | TDE: keystore y tablespace cifrado AES256 | V16 |
| A8.8* | Gestión de vulnerabilidades técnicas | Tecnológico | R-CONF-02, 03 | Registrar versión y parches; documentar si no hay | V17 |
| A8.16* | Actividades de monitoreo | Tecnológico | R-CONF-06 | Job de `DBMS_SCHEDULER` con reporte semanal | (manual) |
| A8.21* | Seguridad de servicios de red | Tecnológico | R-CONF-05 | Listener solo en las interfaces necesarias | (manual) |
| A8.33* | Información de prueba | Tecnológico | R-CONF-04 | Clon con datos enmascarados | (manual) |

**Dato útil sobre los temas de ISO 27001:2022.** El Anexo A tiene 4 temas: Organizacional (A5), Personas (A6), Físico (A7) y Tecnológico (A8). Como el proyecto es sobre bases de datos, casi todo cae en A5 y A8. No hay controles A6 ni A7 porque tratan de personal e instalaciones físicas, que no son tarea del DBA.

**Por qué no usé otros controles A8 (por ejemplo A8.4 o A8.9).** A8.4 es acceso al código fuente y A8.9 gestión de configuración: son pertinentes en general, pero no tienen una tarea del PDF que los requiera. Agregar controles sin tarea asociada es ruido.

---

### 2.4 Objetivo: "Diseñar una Matriz de Evaluación con criterios de madurez 0-4, evidencia y estado (Cumple/No cumple/Parcial)"

**La escala 0–4 que usé y por qué:**

| Nivel | Nombre | Qué significa en la práctica |
|---|---|---|
| 0 | Inexistente | No hay nada |
| 1 | Inicial | Hay algo ad hoc, sin documento ni evidencia |
| 2 | Documentado | Existe política escrita, sin evidencia de que se ejecute |
| 3 | Implementado y verificado | **Un script V-xx lo demuestra** |
| 4 | Gestionado | Se monitorea periódicamente y se mejora |

**Por qué definí el nivel 3 con "un script lo demuestra".** Es la decisión más importante de la matriz. Convierte "cumple" en algo **objetivo**: no vale que yo diga que está implementado, tiene que existir una salida de un script que lo pruebe. Eso es lo que el PDF llama "evidencia auditable".

**La regla de estado:**

| Nivel | Estado |
|---|---|
| 0–1 | No cumple |
| 2 | Parcial |
| 3–4 | Cumple |

El PDF pide tres estados (Cumple / No cumple / Parcial) y cinco niveles; hace falta una regla para pasar de uno a otro. Esta es la mía: ejecutar y comprobar es lo que separa "Cumple".

**La estructura de la matriz.** Una fila por **par tarea–control**, no por control (24 filas). Por eso un mismo control (por ejemplo A5.18) aparece en varias tareas: el PDF pide la columna Tarea y Riesgo en la misma fila.

**Cómo se calificó el ANTES.** Leyendo las evidencias reales de [evidencias/antes/](evidencias/antes/). Ejemplo: A8.2 salió en **0** porque `V07` mostró `DEV_RAMIRO` con el rol DBA y 160 privilegios peligrosos efectivos. **Los 20 controles salieron en 0 o 1 (No cumple).** Eso es esperado y es el punto: es la línea base.

**Por qué las metas son 3 en la mayoría y 4 en algunas.** Meta 3 = implementado y verificado, alcanzable en un laboratorio. Meta 4 (A5.18, A8.15, A8.16) = requiere **revisión periódica** (reporte trimestral, revisión semanal del rastro), que en un proyecto de semanas no se puede demostrar con el paso del tiempo. Por eso las metas 4 son aspiracionales y A8.8 tiene meta **2** (en XE no hay parches, solo se puede documentar el riesgo).

**La parte difícil de explicar: el nivel DESPUÉS.** Los niveles DESPUÉS ya están escritos en los datos del artefacto (22/10/2026) y se basan en la evidencia que vimos:

| Control | ANTES | DESPUÉS propuesto | Razón |
|---|---|---|---|
| A5.15 | 0 | 3 | V02: 0 permisos directos, 0 de PUBLIC |
| A5.18 | 0 | 3 | V05: 0 derechos re-otorgables; falta reporte periódico para el 4 |
| A8.2 | 0 | 3 | V07 tras R01 y R05: ninguna cuenta no administrativa con DBA ni `ANY` |
| A5.16 | 1 | 3 | V03: cuentas nominales; `SECRETARIA` y `EX_KSALAS` bloqueadas |
| A5.17 | 1 | 3 | V04: 0 cuentas con contraseña por defecto; verificador ORA12C_STRONG |
| A8.5 | 1 | 2 → 3 | Bloqueo e `IDLE_TIME` probados (PT-08, 09, 11); falta quitar el verificador 11G (requiere `sqlnet.ora`) |
| A5.12 | 0 | 3 | V01: 0 columnas sin clasificar de 36 |
| A8.3 | 0 | 3 | PT-03: `DOC_MCHAVES` ve solo `id_docente = 1` |
| A8.11 | 0 | 3 | PT-04, PT-05: redacción parcial y total funcionan |
| A8.15 | 1 | 3 | PT-14, PT-15: lecturas y GRANT quedan en el rastro |
| A5.33 | 1 | 3 | PT-16: `AUDITOR_EXT` lee pero no purga |
| A8.12 | 0 | 3 | V12: 0 `UTL_*` ni exportación completa; PT-22 bloqueado |
| A8.10 | 0 | 3 | V10: papelera vacía |
| A8.24* | 0 | 3 | TDE: `TS_INSTITUTO` cifrado AES256 |
| A8.13 | 0 | por confirmar | Respaldo RMAN hecho y validado; falta comprobar que las piezas salgan `ENCRYPTED = YES` (V13) |
| A8.20 | 0 | pendiente | Requiere `sqlnet.ora` como administrador |

---

### 2.5 Objetivo: "Proponer y ejecutar pruebas técnicas que demuestren la efectividad de los controles"

**Qué hice:** 29 pruebas, y **los scripts de verificación V01–V17** (uno por cada control con evidencia SQL).

**Dos tipos de herramienta de prueba, y por qué los separo:**

| Lo que son | Qué responde | Ejemplo |
|---|---|---|
| **Scripts V (verificación)** | "¿**Cómo está** configurado?" Lee el catálogo de Oracle | `V07`: lista quién tiene el rol DBA |
| **Pruebas PT (batería)** | "¿**Funciona** el control?" Intenta algo y mira el resultado | `PT-01`: la app intenta leer una tabla ajena y debe recibir `ORA-00942` |

**Por qué hacen falta los dos.** Un script V puede decir "el permiso fue revocado", pero solo la prueba demuestra que **el acceso indebido ya no es posible**. El PDF dice "demuestren la efectividad": efectividad = la prueba. La configuración sola no basta.

**Prueba negativa vs. positiva.** La negativa **intenta algo prohibido y debe fallar** (`ORA-00942`). La positiva **hace algo permitido y debe funcionar** (PT-02: el docente lee con su rol). Se necesitan ambas: si solo hay negativas, un sistema que bloquea todo pasaría las pruebas.

**Por qué "Falla" en el ANTES es lo esperado.** "Falla" significa que **el acceso indebido fue posible**. Hoy la prueba "falla" porque el control no existe. Tras remediar debe dar el resultado esperado.

**Por qué clasifiqué el origen: ejecutada / inferida / pendiente.**

| Origen | Significado | Cuántas (ANTES) |
|---|---|---|
| Ejecutada | Corrí la prueba o su script y hay salida real | 14 |
| Inferida | La deduje de la configuración, sin correr el intento | 10 |
| Pendiente | No la he podido correr aún | 5 |

Es una decisión de **honestidad**: no todas las pruebas del ANTES se corrieron, y en lugar de esconderlo lo marqué. Si el profesor pregunta "¿ejecutaste todas?", la respuesta es: "14 de 29 con salida real en el ANTES; el resto está marcado como inferido o pendiente y se corre en la fase Verificar".

**Estado de las pruebas en el DESPUÉS (lo que ya corrimos).**

| Prueba | Resultado real | ¿Cumple? |
|---|---|---|
| PT-01 `APP_MATRICULA` lee `BECAS` | `ORA-00942` | Sí |
| PT-02 `DOC_MCHAVES` lee con rol | Ve sus notas con `ROL_DOCENTE` | Sí |
| PT-03 VPD | Solo `id_docente = 1` (346 notas, 17 adecuaciones) | Sí |
| PT-04 redacción parcial | `******************4229` | Sí |
| PT-05 redacción total | Dueño del esquema ve vacío; `TESO_PAULA` sin acceso | Sí |
| PT-07 cuenta huérfana a datos | `ORA-00942` (la cuenta además queda bloqueada) | Sí |
| PT-08 bloqueo | 5 fallos → `ORA-28000` | Sí |
| PT-09 fuerza bruta | 5 fallos → `ORA-28000` a partir del 6.º | Sí |
| PT-10 complejidad | `ORA-28003` (longitud menor a 9) | Sí |
| PT-11 sesión inactiva | `ORA-02396` tras 190 s con `IDLE_TIME 1` | Sí |
| PT-12, PT-13 cuentas | `ORA-28000` | Sí |
| PT-14 auditoría de lectura | El `SELECT` de `DOC_MCHAVES` aparece en el rastro | Sí |
| PT-15 auditoría de privilegios | Quedan el `GRANT` y el `REVOKE` | Sí |
| PT-16 purga del rastro | `AUDITOR_EXT` lee 320 eventos, pero `PLS-00201` al purgar | Sí |
| PT-22 exportación | `ORA-01031` (no puede crear la tabla maestra) | Sí |
| PT-26 clon enmascarado | 0 condiciones y 0 cédulas reales | Sí |
| PT-27 reporte | El job corre y lista logons fallidos, bloqueos y accesos | Sí |
| PT-28 re-otorgar | `ORA-01031` | Sí |

Las evidencias están en [evidencias/despues/](evidencias/despues/).

---

## 3. Marco teórico (análisis de temas relacionados, PDF sección 5)

El PDF pide investigar y sintetizar **2–3 páginas**. Aquí está la síntesis de estudio, con una columna "cómo se ve en tu proyecto" para que no sea teoría suelta. **Lo que está marcado (verificar) debes confirmarlo en la fuente antes de citarlo.**

### 3.1 Cambios de ISO 27001:2022 respecto a 2013

| Aspecto | 2013 | 2022 |
|---|---|---|
| Controles del Anexo A | 114 | **93** |
| Organización | 14 dominios (A.5 a A.18) | **4 temas**: Organizacional (37), Personas (8), Físico (14), Tecnológico (34) |
| Controles nuevos | — | **11** (inteligencia de amenazas, servicios en la nube, continuidad de las TIC, monitoreo de seguridad física, gestión de la configuración, **eliminación de la información**, **enmascaramiento de datos**, **prevención de fuga de datos**, **actividades de monitoreo**, filtrado web, codificación segura) |
| Atributos | No existían | Cada control trae atributos (tipo, propiedades de seguridad, etc.) |

**Qué importa para tu proyecto:** tres de los controles nuevos son justo los que usas: **A8.10** (eliminación), **A8.11** (enmascaramiento) y **A8.12** (fuga de datos). Eso es un argumento: el estándar de 2022 reconoce explícitamente lo que antes se improvisaba.

**Por qué es 27001 y 27002.** ISO 27001 es la norma **certificable**: dice qué debe tener un sistema de gestión. ISO 27002 es la **guía de implementación**: dice cómo aplicar cada control. Tú citas controles de 27001 (Anexo A) y los explicas con 27002. **(verificar)** los números 37/8/14/34 y los 11 nuevos en la propia norma; el texto completo es de pago.

### 3.2 Mínimo privilegio y separación de funciones en el rol DBA

- **Mínimo privilegio:** cada cuenta tiene solo lo que necesita para su función, nada más. Se implementa con **roles por función** y se revisa.
- **Separación de funciones:** una misma persona no concentra tareas que, juntas, permiten abusar o encubrir. En bases de datos: quien administra no es quien audita; quien opera no es quien exporta.
- **El problema del DBA:** el rol DBA es, por naturaleza, omnipotente. El control no es "quitar al DBA" sino **limitarlo**: separar `SYSDBA`, `AUDIT_ADMIN` y `AUDIT_VIEWER`, y que ningún desarrollador tenga DBA.

**En tu proyecto:** `DEV_RAMIRO` pasa de rol DBA a `ROL_DESARROLLO` sobre el clon. `AUDITOR_EXT` pasa de `AUDIT_ADMIN` (podía purgar su propio rastro) a `AUDIT_VIEWER` (solo lee). `SOPORTE_TI` deja de exportar la base completa. Controles: **A5.15, A8.2, A5.18, A5.33**.

### 3.3 Defensa en profundidad y Zero Trust aplicado a bases de datos

- **Defensa en profundidad:** varias capas independientes; si una falla, otra contiene. Una sola barrera no basta.
- **Zero Trust:** "nunca confiar, siempre verificar". No se confía en una conexión por venir de la red interna; cada acceso se autentica, se autoriza con mínimo privilegio y se registra. La referencia habitual es NIST SP 800-207 **(verificar)**.

**Las capas en tu proyecto (de afuera hacia adentro):**

| Capa | Control | Qué contiene si falla la anterior |
|---|---|---|
| Red | Cifrado de Oracle Net, listener en localhost | Si alguien captura tráfico, no lo lee |
| Identidad | Perfiles, bloqueo, cuentas nominales | Si adivinan una clave, el bloqueo corta |
| Autorización | Roles, sin PUBLIC, VPD | Si entran, solo ven lo suyo |
| Dato | Redacción de columnas | Si ven la fila, no ven la columna sensible |
| Almacenamiento | TDE, backup cifrado | Si roban el archivo, no lo leen |
| Detección | Auditoría y reporte | Si pasó, queda registro |

**Por qué lo menciono así en la defensa:** "ningún control por sí solo protege; el diseño es que cada capa asume que la anterior falló".

### 3.4 Controles técnicos

| Control | Qué es | Qué protege | Qué NO protege | En tu proyecto |
|---|---|---|---|---|
| **TDE** (Transparent Data Encryption) | Cifra datos **en disco** de forma transparente para la aplicación. Usa una clave maestra guardada en un keystore (wallet) | Datafiles y backups robados | **A quien ya tiene `SELECT`** (la base descifra al leer) | `TS_INSTITUTO` cifrado AES256 |
| **Data Redaction** (`DBMS_REDACT`) | Oculta el valor de una columna **al consultarla**, según una condición (rol, usuario) | Que el dato salga completo en una consulta | Que alguien con acceso a los archivos lo lea | `detalle_condicion`, `ingreso_familiar`, `num_cuenta` |
| **VPD / Row Level Security** (`DBMS_RLS`) | Agrega un filtro `WHERE` automático por usuario | Que un usuario vea filas ajenas | Columnas sensibles de sus propias filas | Cada docente ve solo sus notas |
| **TLS / cifrado de red** | Cifra la conexión cliente–servidor. En Oracle: cifrado nativo (`sqlnet.ora`) o TLS con wallet (TCPS) | Captura de tráfico | Cuentas legítimas comprometidas | AES256 en `sqlnet.ora` (pendiente de administrador) |

**Aclaración de nombres (muy preguntada).** El PDF dice "Dynamic Data Masking". En Oracle ese nombre **no es un producto**: ese término lo usa SQL Server. El equivalente en Oracle es **Data Redaction**, que enmascara dinámicamente al consultar. Para enmascarar **datos estáticos** (por ejemplo un clon) se usa un UPDATE o Data Masking and Subsetting (que es un paquete de EM, de pago) **(verificar)**. Por eso en el clon `INSTITUTO_DEV` hice un `UPDATE` directo.

**Idea para recordar:** TDE protege **en reposo**, Redaction y VPD protegen **en uso**, TLS protege **en tránsito**. Tres estados del dato, tres tecnologías.

### 3.5 DLP (prevención de fuga de datos) y backups cifrados

- **DLP** en una base de datos significa controlar las **vías de salida**: exportaciones (Data Pump), paquetes que escriben a archivos o a la red (`UTL_FILE`, `UTL_HTTP`, `UTL_TCP`, `UTL_SMTP`), directorios compartidos y *database links*.
- **Backups cifrados:** un respaldo sin cifrar equivale a entregar la base completa. RMAN puede cifrarlo de forma transparente con TDE (`CONFIGURE ENCRYPTION FOR DATABASE ON`), con contraseña, o ambas.
- **Regla práctica:** el backup y la clave de cifrado **nunca van juntos**. Si el wallet está en el mismo disco, el cifrado es decorativo.

**En tu proyecto:** `PUBLIC` pierde `EXECUTE` sobre los `UTL_*` y los directorios; `SOPORTE_TI` pierde `DATAPUMP_EXP_FULL_DATABASE`; hay una política de auditoría sobre exportaciones. El respaldo RMAN se hizo con cifrado AES256 y se validó con `RESTORE DATABASE VALIDATE`. Controles: **A8.12, A8.13**.

### 3.6 Logging, monitoreo y correlación (SIEM)

- **Logging** = registrar qué pasó. **Monitoreo** = alguien (o algo) lo revisa. **Correlación (SIEM)** = juntar eventos de muchas fuentes para ver patrones que un solo log no muestra.
- Idea clave: **auditar sin revisar no sirve** (por eso el control A8.16).
- En Oracle, la **auditoría unificada** reúne todo en una vista (`UNIFIED_AUDIT_TRAIL`) y se define con políticas (`CREATE AUDIT POLICY`).
- Un SIEM (Splunk, Wazuh, ELK, Sentinel) recibe esos eventos de varios sistemas. Tu proyecto **no instala un SIEM**; lo describe como la evolución natural: hoy el reporte semanal, mañana el rastro enviado a un SIEM para correlacionar (por ejemplo, 5 logins fallidos seguidos de un `GRANT`).

**En tu proyecto:** tres políticas (`POL_DATOS_SENSIBLES`, `POL_GESTION_ACCESOS`, `POL_EXPORTACIONES`) y un job semanal con `DBMS_SCHEDULER` que produce un reporte de logons fallidos, cambios de privilegios y accesos a datos sensibles. Controles: **A8.15, A5.33, A8.16**.

### 3.7 Normativa costarricense: Ley 8968

- **Nombre:** *Protección de la persona frente al tratamiento de sus datos personales*, Ley N.º 8968 (2011). Su reglamento es el Decreto Ejecutivo 37554-JP **(verificar número)**. La autoridad es la **PRODHAB** (Agencia de Protección de Datos de los Habitantes).
- **Datos sensibles:** datos que revelan origen racial, ideología, creencias, salud, vida sexual, etc. **(verificar texto exacto en el SCIJ, arts. 3 y 9)**. Reciben protección reforzada.
- **Seguridad de los datos:** el responsable de la base debe adoptar medidas técnicas y organizativas para evitar alteración, pérdida, tratamiento o acceso no autorizado (art. 10, confirmado). **Deber de confidencialidad:** quien intervenga en el tratamiento debe guardar secreto (art. 11) **(verificar)**.

**Por qué importa para tu proyecto.** Es lo que convierte tu escenario en algo serio:

| Dato del colegio | Categoría | Por qué |
|---|---|---|
| `detalle_condicion` (diagnóstico) | Sensible | Salud (y de menores) |
| `ingreso_familiar` | Sensible | Condición socioeconómica |
| cédula, teléfono, dirección | Restringido | Personales de acceso restringido |
| notas | Restringido | Personales |
| nombre del docente | Público | Es información de acceso irrestricto |

Esto se materializa en el control **A5.12**: las 36 columnas están etiquetadas `CLASIF:<nivel>`. La clasificación no es burocracia: **decide qué controles se aplican** a cada columna (las sensibles llevan redacción; las públicas no).

**Para decirlo en la defensa:** "ISO 27001 me dice cómo proteger; la Ley 8968 me dice qué es obligatorio proteger y por qué. El control A5.12 es el puente: clasifico según la ley y protejo según la clasificación."

---

## 4. ¿El artefacto cumple lo que pide el PDF (sección 6)?

**Respuesta corta: sí cumple los 6 puntos y los scripts. Lo que falta no es del artefacto sino de los entregables que lo rodean.**

| # | Lo que pide el PDF | ¿Cumple? | Dónde está | Observación |
|---|---|---|---|---|
| 1 | Tabla de riesgos R-CONF-01 a 05 con impacto y probabilidad | Sí | Paso 1 · [docs/01-riesgos.md](docs/01-riesgos.md) | Tiene 6 (el sexto es adicional y está marcado) |
| 2 | Tabla de tareas del DBA | Sí | Paso 2 · [docs/02-tareas-dba.md](docs/02-tareas-dba.md) | Las 12 del PDF |
| 3 | Mapeo de controles con implementación y evidencia observable | Sí | Paso 3 · [docs/03-mapeo-controles.md](docs/03-mapeo-controles.md) | 20 controles; cada uno con su consulta SQL |
| 4 | Lista de 15 controles observables por un auditor externo | Sí | Paso 4 | Exactamente los 15 del PDF, con criterio de aceptación |
| 5 | Matriz (Tarea \| Riesgo \| Control \| Criterio 0-4 \| Evidencia \| Estado) | Sí | Paso 5 · [docs/04-matriz-evaluacion.md](docs/04-matriz-evaluacion.md) | Las 6 columnas exactas, 24 filas |
| 6 | Batería de pruebas (ID, Tipo, Procedimiento, Resultado esperado, Herramienta) | Sí | Paso 6 · [docs/05-pruebas.md](docs/05-pruebas.md) | Esas 5 columnas más origen y resultados |
| — | **Scripts de verificación (obligatorio)** | Sí | [sql/01_verificacion/](sql/01_verificacion/) | V00–V17; ejecutados con evidencia real |

**Por qué tiene más columnas de las pedidas.** Las del PDF son el mínimo; agregué *Origen* y *Resultado ANTES/DESPUÉS* porque sin ellas la tabla no demuestra nada. Agregar columnas no incumple; **quitar** sí.

**La parte "interactiva".** El PDF permite "interactivo HTML, PDF o sitio". El artefacto es un sitio React (Vite) que se compila a HTML estático ([artefacto/](artefacto/)) y tiene botón **Imprimir / PDF**. Cumple las dos formas. Es más de lo mínimo, pero tiene una ventaja en la defensa: puedes navegar la cadena Riesgo → Tarea → Control → Evidencia → Pruebas en vivo.

**Lo que NO es del artefacto pero el PDF exige como entregable (sección 10):**

| Entregable | Estado |
|---|---|
| Informe PDF con artefacto | En proceso (Google Docs) |
| Scripts `.sql` de verificación | Hecho |
| Repositorio Git | Hecho (confirmar que quede en el repo institucional) |
| Video de 5 minutos | Pendiente |
| Tabla de uso de IA **firmada** | La tabla existe; faltan validaciones, fuentes y la firma |
| Marco teórico (2–3 páginas) | Está en esta sección 3; hay que redactarlo con tus palabras e incluirlo en el informe con referencias APA 7 |

**Dos puntos débiles reales** que debes saber (y decir antes de que pregunten):

1. **Los controles complementarios (*)** son decisión mía; falta que el profesor los confirme.
2. **Las 10 pruebas "inferidas" del ANTES** no se corrieron en su estado inicial. Ya no se pueden correr "como ANTES" porque la base fue remediada; lo honesto es decir "se dedujeron de la configuración observada".

---

## 5. Qué pasó realmente al ejecutar Hacer y Verificar (para que no te sorprenda)

**Bloques aplicados** (scripts en [sql/02_remediacion/](sql/02_remediacion/), pruebas en [sql/03_pruebas/](sql/03_pruebas/)):

| Bloque | Qué hace | Estado |
|---|---|---|
| R01 | Roles por función; quita DBA, `SELECT ANY TABLE`, PUBLIC y `GRANT OPTION` | Aplicado y verificado |
| R02 | Perfiles con complejidad, 5 intentos, `IDLE_TIME`; cuentas nominales; bloquea `SECRETARIA` y `EX_KSALAS` | Aplicado y verificado |
| R03 | Clasificación de 36 columnas; VPD; redacción; clon enmascarado | Aplicado y verificado |
| R04 | `AUDIT_VIEWER` para el auditor; 3 políticas de auditoría; reporte semanal | Aplicado y verificado |
| R05 | Quita exportación completa y `UTL_*`; purga la papelera | Aplicado y verificado |
| R06b | TDE: keystore y `TS_INSTITUTO` cifrado AES256 | Aplicado (V16 por repetir) |
| R06c | Respaldo RMAN cifrado y `RESTORE DATABASE VALIDATE` | Hecho (falta confirmar `ENCRYPTED = YES` con V13) |
| R06a | `sqlnet.ora` con cifrado de red y verificador 12C | **Pendiente: requiere PowerShell como administrador** |

**Cosas que salieron mal o inesperadas, y qué enseñan** (cuéntalas, demuestran que ejecutaste de verdad):

1. **`ORA-65096` al crear roles.** El primer intento corrió en `CDB$ROOT` en vez de `XEPDB1`. Enseñanza: en Oracle multitenant los roles locales se crean **dentro del PDB**. Lo corregí haciendo que cada script cambie a `XEPDB1` y **se detenga** si no lo logra.
2. **Evidencia DESPUÉS contaminada.** Una vez ejecuté V02 y las pruebas **antes** de aplicar la remediación; el resultado era idéntico al ANTES y estaba etiquetado "despues". Lo detecté, lo borré y repetí. Enseñanza: **una evidencia mal etiquetada es peor que ninguna**.
3. **`ORA-28094` con `SUBSTR` sobre columna redactada.** Redaction **no permite funciones SQL** sobre la columna protegida. Es una limitación real del producto y vale la pena mencionarla.
4. **El docente no ve su propia condición con `SUBSTR`, pero sí sin él.** Se ajustó la prueba.
5. **`HOST ping ... > NUL` fallaba** en SQL*Plus (la redirección no pasa por `cmd`). Sin ella, `PT-11` demostró `ORA-02396` correctamente.
6. **TDE deja el archivo original sin cifrar.** Al cifrar en línea con `FILE_NAME_CONVERT`, Oracle crea un archivo **nuevo** cifrado (`ts_instituto01_cif.dbf`) y **deja el viejo** (`ts_instituto01.dbf`) en texto plano en el disco. Si no se elimina, el cifrado no sirve de nada. **Esto también es A8.10** (eliminación segura). Pendiente: borrarlo como administrador y mostrar la prueba **PT-19** antes de hacerlo (buscar un nombre de estudiante en el archivo viejo).
7. **No puedo escribir en la carpeta de Oracle ni iniciar servicios** sin administrador. Por eso `sqlnet.ora` y el arranque quedan para ti.

**Hallazgos de las verificaciones que quedan abiertos (importante para la sección "Actuar"):**

| Hallazgo | Por qué queda | Qué hacer |
|---|---|---|
| `PDBADMIN` sigue abierta con perfil `DEFAULT` | Es una cuenta de Oracle del PDB | Bloquearla o documentarla como cuenta administrativa |
| Verificadores `11G` siguen en las cuentas | Requiere `ALLOWED_LOGON_VERSION_SERVER = 12a` y volver a asignar claves | R06a y repetir R02 |
| `GSMUSER_ROLE` tiene `EXEMPT ACCESS POLICY` | Rol interno de Oracle | Documentar: es del motor, no del proyecto |
| XE 21.3 no recibe parches | Limitación de la edición | Riesgo aceptado y documentado (A8.8*, meta 2) |
| Auditoría sin retención definida | No se configuró `DBMS_AUDIT_MGMT` | Mejora para "Actuar" |

---

## 6. Preguntas probables y cómo responderlas

**P1. ¿Por qué un escenario ficticio?**
El PDF exige "ejecutar pruebas técnicas". Para ejecutarlas necesitas una base con datos y configuraciones sobre las que correr los scripts. No usé datos reales por la Ley 8968. Los datos son generados con `DBMS_RANDOM`.

**P2. ¿Las fallas del ANTES son reales o las pusiste tú?**
Sembré 12 malas prácticas (MP-01 a MP-12) **a propósito**. Pero además los scripts encontraron fallas que **yo no sembré**: por ejemplo `UTL_*` abierto a PUBLIC y el cifrado de red ausente. Eso demuestra que los scripts auditan de verdad. Están en la sección "Hallazgos reales" del artefacto.

**P3. ¿Por qué todo salió en "No cumple" al inicio?**
Es la línea base. Si saliera en "Cumple" no habría nada que demostrar. El valor está en la diferencia entre el ANTES y el DESPUÉS.

**P4. ¿Qué diferencia hay entre ISO 27001 y 27002?**
27001 es certificable y dice **qué** controlar (el Anexo A). 27002 es la guía de **cómo** implementar cada control.

**P5. ¿TDE protege al que ya tiene acceso?**
No. TDE protege los **archivos** (datafiles y backups) si alguien los roba. Quien tiene `SELECT` ve el dato descifrado. Para eso están Redaction y VPD.

**P6. ¿LogMiner muestra quién leyó un dato?**
No: un `SELECT` no genera redo. Para saber quién lee, se usa **auditoría**, que es lo que configuré.

**P7. ¿Por qué agregaste controles que no están en la lista?**
El PDF pide TDE, parcheo, listener, monitoreo y clones como tareas, pero su lista de 15 controles no los cubre. Agregué cinco, marcados con asterisco. Quiero confirmarlo con usted.

**P8. ¿Cómo sabes que el control funciona y no solo que está configurado?**
Con las **pruebas**, no con los scripts V. El script dice "el permiso fue revocado"; la prueba demuestra que **el intento falla** (`ORA-00942`, `ORA-28000`, `ORA-01031`).

**P9. ¿Qué es el "nivel 3" de madurez?**
Implementado **y verificado**: un script V-xx lo demuestra. No vale solo que yo lo diga.

**P10. ¿Por qué el nivel 4 no se alcanzó en ningún control?**
El 4 exige operación periódica (revisión trimestral, reporte semanal ejecutándose en el tiempo). En semanas de laboratorio no se puede demostrar el paso del tiempo; por eso hay controles con meta 4 que se quedan en 3 y se documenta como mejora.

**P11. ¿Qué haces con lo que no pudiste corregir?**
Lo documento como **riesgo residual** en la fase Actuar. Ejemplo: XE no recibe parches. No lo oculto: lo declaro y recomiendo una edición con soporte en producción.

**P12. ¿Usaste IA? ¿Cómo la validaste?**
Sí, está declarada en [docs/uso-ia.md](docs/uso-ia.md) con el prompt exacto. Validé ejecutando los scripts en mi propio Oracle y contrastando los controles con ISO 27002 y la documentación de Oracle. **(Esto solo es cierto cuando termines de llenar las columnas "Validación" y "Fuente verificada".)**

**P13. ¿Qué cambiarías?**
Cuatro cosas: ejecutar las 10 pruebas inferidas antes de remediar; configurar la retención del rastro de auditoría; enviar el rastro a un SIEM; y repetir la medición con un Oracle con soporte de parches.

---

## 7. Lista de pendientes (qué falta realmente)

**Técnicos (requieren administrador o tu confirmación):**

- [ ] Iniciar los servicios de Oracle y abrir la base (`ALTER DATABASE OPEN; ALTER PLUGGABLE DATABASE ALL OPEN;`).
- [ ] Ejecutar [R06a_sqlnet_admin.ps1](sql/02_remediacion/R06a_sqlnet_admin.ps1) como administrador (cifrado de red y verificador 12C) y repetir R02.
- [ ] Repetir V13, V15, V16 y V17 y guardar la evidencia DESPUÉS.
- [ ] PT-19: buscar un nombre de estudiante en `ts_instituto01.dbf` (texto plano) y en una pieza del backup (no debe aparecer); luego **borrar el archivo viejo**.
- [ ] Confirmar `ENCRYPTED = YES` en las piezas del respaldo (V13).
- [ ] Respaldar el wallet (`C:\oracle_lab\wallet`) **fuera** de la carpeta del respaldo.

**De datos del artefacto:**

- [x] Niveles DESPUÉS de madurez escritos en `controles.json` y resultados DESPUÉS en `pruebas.json` (17 de 20 controles y 27 de 29 pruebas; faltan los que dependen de `sqlnet.ora`).
- [ ] Recalcular el riesgo residual de los 6 riesgos (fase Actuar).

**De documentación:**

- [ ] Completar las columnas "Validación" y "Fuente verificada" de [docs/uso-ia.md](docs/uso-ia.md) y firmar la declaración jurada.
- [ ] Redactar el marco teórico con tus palabras y citar en APA 7.
- [ ] Video de 5 minutos.
- [ ] Hacer las preguntas prioritarias al profesor (1, 2, 3, 4 y 8 de [docs/preguntas-profesor.md](docs/preguntas-profesor.md)).

---

## 8. Glosario rápido

| Término | Significado |
|---|---|
| **R-CONF** | Riesgo de confidencialidad |
| **DBA** | Administrador de la base de datos |
| **PHVA** | Planificar, Hacer, Verificar, Actuar (el ciclo del proyecto) |
| **PDB / CDB** | Base conectable / contenedora (Oracle multitenant). Tu escenario vive en la PDB `XEPDB1` |
| **Rol** | Conjunto de permisos que se asigna a varios usuarios |
| **PUBLIC** | "Todos": un permiso a PUBLIC lo tiene cualquier cuenta, presente o futura |
| **GRANT OPTION** | Permite al receptor volver a dar el permiso a otros |
| **VPD** | Virtual Private Database: filtro automático por fila |
| **Redaction** | Ocultar el valor de una columna al consultarla |
| **TDE** | Cifrado transparente de datos en disco |
| **Keystore / wallet** | Archivo que guarda la clave maestra de TDE |
| **RMAN** | Herramienta de respaldo de Oracle |
| **Auditoría unificada** | Mecanismo de auditoría de Oracle: todo en `UNIFIED_AUDIT_TRAIL` |
| **SIEM** | Sistema que reúne y correlaciona los registros de muchos sistemas |
| **Madurez 0–4** | Escala propia del proyecto para calificar cada control |
| **ANTES / DESPUÉS** | Estado medido antes y después de aplicar las correcciones |
| **Riesgo residual** | Lo que queda de riesgo después de aplicar controles |
| **Apetito de riesgo** | Nivel de riesgo que la organización acepta (propuesta: ≤ 6) |
| **Ley 8968** | Ley de Costa Rica de protección de datos personales |

---

## 9. Fuentes que debes consultar para citar (APA 7)

Esto no es la lista final: son las **fuentes que hay que abrir y verificar** antes de afirmar algo en el informe.

| Para qué | Fuente |
|---|---|
| Controles A5/A8 y su guía | ISO/IEC 27001:2022 (Anexo A) e ISO/IEC 27002:2022 (el texto es de pago; si no accedes, indicarlo y usar fuentes secundarias oficiales) |
| Riesgos | ISO/IEC 27005 (gestión de riesgos) |
| TDE, Redaction, VPD, auditoría | Oracle Database Security Guide 21c; Oracle Database Reference 21c |
| Cifrado de red | Oracle Database Net Services Reference 21c (`SQLNET.ENCRYPTION_*`) |
| RMAN | Oracle Database Backup and Recovery User's Guide 21c |
| Zero Trust | NIST SP 800-207 |
| Ley 8968 y reglamento | SCIJ (Sistema Costarricense de Información Jurídica), texto vigente |

**Regla de oro para el jueves:** no afirmes nada que no puedas apuntar a un archivo del repositorio (script, salida, tabla) o a una fuente. Si no hay evidencia, di "pendiente".
