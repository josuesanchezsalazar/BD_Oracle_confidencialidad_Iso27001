# CONTEXTO DEL PROYECTO — Síntesis conceptual completa

**Proyecto:** Controles ISO/IEC 27001:2022 para la Confidencialidad en la Administración de Bases de Datos (Oracle)
**Curso:** EIF402 Administración de Bases de Datos — UNA, II Ciclo 2026
**Para qué sirve este documento:** entender *de qué se trata*, *en qué se fundamenta* y *cómo encajan las piezas* antes de investigar o programar. Es el "mapa mental" del proyecto; el `PLAN_ACCION.md` es el "qué hacer y cuándo".

> Este documento es material de estudio. Para el informe, redacta con tus palabras, cita las fuentes oficiales (ISO, documentación Oracle, leyes) y declara el uso de IA. Los números de artículo de leyes y las cláusulas exactas deben verificarse en la fuente oficial antes de citarlos.

---

## Índice

1. La idea central en una página
2. El problema: confidencialidad y el DBA como custodio
3. La familia ISO/IEC 27000: qué es cada norma
4. ISO 27001:2022 vs 2013: qué cambió y por qué importa
5. Gestión de riesgos: el lenguaje del proyecto
6. PHVA: el esqueleto metodológico
7. Principios de seguridad que justifican los controles
8. Los 15 controles oficiales explicados uno por uno
9. Controles complementarios recomendados
10. Mecanismos de seguridad de Oracle (cómo se implementa todo)
11. Auditoría, evidencia y madurez
12. Marco normativo costarricense
13. Cómo encaja todo: la cadena completa con un ejemplo
14. Errores conceptuales frecuentes (y cómo defenderte)
15. Glosario
16. Preguntas de autoevaluación para la defensa

---

## 1. La idea central en una página

Una organización guarda datos personales (cédulas, salarios, tarjetas, información sensible) en una base de datos Oracle. La persona con más poder técnico sobre esos datos es el **DBA**. Si los privilegios, contraseñas, respaldos, conexiones o registros están mal gestionados, alguien que **no debería** ver esos datos puede verlos. Eso es una **falla de confidencialidad**.

La norma **ISO/IEC 27001:2022** dice *qué* controles debe considerar una organización para proteger su información; la **ISO/IEC 27002:2022** explica *cómo* implementarlos. El proyecto pide:

1. **Identificar riesgos** de confidencialidad propios de una BD (qué puede salir mal).
2. **Identificar tareas del DBA** donde esos riesgos aparecen (dónde sale mal).
3. **Seleccionar controles ISO** que reducen cada riesgo (qué se hace para evitarlo).
4. **Traducir cada control a Oracle**: configuración, comando o política concreta (cómo se hace).
5. **Definir evidencia observable**: una consulta o archivo que un auditor externo puede revisar para comprobar que el control existe y funciona (cómo se demuestra).
6. **Evaluar la madurez** de cada control en una escala 0–4 y su estado (qué tan bien se hace).
7. **Probar** técnicamente los controles con una batería de pruebas (comprobar que realmente funciona).
8. Todo ordenado con **PHVA** y respaldado por un **marco teórico** y la **Ley 8968**.

En una frase: **pasas de "la norma dice" a "en Oracle se hace así, y aquí está la prueba"**.

---

## 2. El problema: confidencialidad y el DBA como custodio

### 2.1 La tríada CID
La seguridad de la información protege tres propiedades:

| Propiedad | Definición | Pregunta clave | Ejemplo de falla en BD |
|-----------|-----------|----------------|------------------------|
| **Confidencialidad** | La información solo es accesible para quien está autorizado | ¿Quién puede **ver**? | Un desarrollador consulta salarios |
| Integridad | La información es exacta y completa; solo cambia de forma autorizada | ¿Quién puede **cambiar**? | Alguien modifica un saldo |
| Disponibilidad | La información está accesible cuando se necesita | ¿Está **ahí** cuando hace falta? | Se cae un tablespace |

Este proyecto se enfoca **solo en confidencialidad**. Por eso, por ejemplo, el respaldo (A8.13) aparece aquí no por disponibilidad, sino porque **un respaldo sin cifrar es una copia completa de los datos que puede robarse**.

En la pizarra el profesor mostró los tres ejes (Integridad, Disponibilidad, Confidencialidad), cada uno con controles que tienen **costo**. Le tocó al curso el eje de confidencialidad.

### 2.2 ¿Por qué el DBA?
- El DBA tiene, por diseño, los privilegios más altos (SYSDBA, rol DBA). Puede leer prácticamente todo.
- Es quien **otorga** privilegios a otros: si se equivoca, el error se multiplica.
- Gestiona los **respaldos, exportaciones y clones**: copias de los datos fuera de producción.
- Configura la **red**, el **cifrado** y la **auditoría**.

Por eso la asignación lo llama "custodio técnico". Custodio no significa dueño: el **dueño** del dato (por ejemplo, RRHH dueño de salarios) decide quién debe verlo; el DBA **implementa** esa decisión y **demuestra** que se cumple.

### 2.3 Amenazas típicas a la confidencialidad en una BD

| Amenaza | Origen | Ejemplo |
|---------|--------|---------|
| Abuso de privilegios | Interno | Usuario con `SELECT ANY TABLE` consulta datos que no le corresponden |
| Credenciales comprometidas | Externo/interno | Contraseña débil o por defecto adivinada |
| Cuentas huérfanas | Interno | Cuenta de un ex-empleado sigue activa |
| Robo de medios | Externo/interno | Copia de un datafile o un backup fuera de la organización |
| Fuga por copias | Interno | Exportación Data Pump enviada por correo; clone de pruebas con datos reales |
| Intercepción | Externo | Sniffing de tráfico SQL*Net sin cifrar |
| Falta de trazabilidad | — | No se puede saber quién vio qué; el abuso pasa inadvertido |

Detalle importante: **la mayoría de incidentes de confidencialidad en BD vienen de usuarios con acceso legítimo que hacen más de lo debido**, no de "hackers". Por eso los controles de privilegios y auditoría pesan tanto.

---

## 3. La familia ISO/IEC 27000: qué es cada norma

| Norma | Qué es | Papel en el proyecto |
|-------|--------|---------------------|
| **ISO/IEC 27000** | Vocabulario y visión general | Definiciones (confidencialidad, control, riesgo) |
| **ISO/IEC 27001:2022** | **Requisitos** de un Sistema de Gestión de Seguridad de la Información (SGSI). Es la norma **certificable** | Base del proyecto; su **Anexo A** lista los 93 controles |
| **ISO/IEC 27002:2022** | **Guía de implementación** de cada control del Anexo A: propósito, guía, información adicional | Justificación y "cómo" de cada control |
| ISO/IEC 27005 | Gestión de riesgos de seguridad de la información | Metodología de riesgos (complementaria) |
| ISO 31000 | Gestión de riesgos general (no solo TI) | Conceptos de riesgo, apetito, tratamiento |

### 3.1 Estructura de ISO 27001
- **Cláusulas 4 a 10** (lo obligatorio para certificar): contexto de la organización (4), liderazgo (5), planificación — incluye evaluación y tratamiento de riesgos (6), soporte (7), operación (8), evaluación del desempeño (9), mejora (10). Estas cláusulas **siguen el ciclo PHVA**.
- **Anexo A**: lista de 93 controles de referencia. La organización decide cuáles aplica según sus riesgos y lo documenta en la **Declaración de Aplicabilidad (SoA)**: qué controles aplica, cuáles excluye y por qué.

> Conexión con el proyecto: tu selección de 15 controles con justificación es, en pequeño, una **SoA parcial enfocada en confidencialidad de BD**.

### 3.2 27001 vs 27002 en una línea
- 27001 Anexo A: "*La organización debe restringir el acceso a la información según la política*" (el **qué**, una frase por control).
- 27002: "*Para lograrlo, considere: perfiles por función, mínimo privilegio, revisiones periódicas…*" (el **cómo**, varias páginas por control).

---

## 4. ISO 27001:2022 vs 2013: qué cambió y por qué importa

El marco teórico pide explicar estos cambios.

| Aspecto | 2013 | 2022 |
|---------|------|------|
| Controles Anexo A | **114** | **93** |
| Organización | **14 dominios** (A.5 a A.18) | **4 temas** |
| Controles nuevos | — | **11** |
| Atributos de control | No | Sí (en 27002) |
| Transición | — | Las certificaciones 2013 dejaron de ser válidas el 31 de octubre de 2025 |

### 4.1 Los 4 temas del Anexo A 2022

| Tema | Rango | Cantidad | Ejemplos para BD |
|------|-------|----------|------------------|
| Organizacionales | 5.1 – 5.37 | 37 | Clasificación, control de acceso, identidades, registros |
| Personas | 6.1 – 6.8 | 8 | Concienciación, confidencialidad (NDA) |
| Físicos | 7.1 – 7.14 | 14 | Seguridad del centro de datos, medios |
| Tecnológicos | 8.1 – 8.34 | 34 | Privilegios, autenticación, masking, DLP, backup, logging, redes |

37 + 8 + 14 + 34 = 93. Los 15 controles del proyecto están en los temas **5 (organizacionales)** y **8 (tecnológicos)**.

### 4.2 Los 11 controles nuevos de 2022
5.7 Inteligencia de amenazas · 5.23 Seguridad en servicios en la nube · 5.30 Preparación de TIC para la continuidad · 7.4 Monitoreo de seguridad física · 8.9 Gestión de la configuración · **8.10 Eliminación de la información** · **8.11 Enmascaramiento de datos** · **8.12 Prevención de fuga de datos** · 8.16 Actividades de monitoreo · 8.23 Filtrado web · 8.28 Codificación segura.

Tres de los nuevos (**8.10, 8.11, 8.12**) están en tu lista oficial. Esto es un buen argumento en el marco teórico: **la versión 2022 incorporó explícitamente controles centrados en la confidencialidad de los datos**, que en 2013 no existían como controles propios.

### 4.3 Atributos (27002:2022)
Cada control tiene atributos que permiten filtrarlo:
- **Tipo de control:** preventivo, detectivo, correctivo.
- **Propiedades de seguridad:** confidencialidad, integridad, disponibilidad.
- **Conceptos de ciberseguridad:** Identificar, Proteger, Detectar, Responder, Recuperar.
- **Capacidades operativas:** gestión de identidades y accesos, protección de la información, gestión de eventos, etc.
- **Dominios de seguridad:** gobernanza, protección, defensa, resiliencia.

> Uso en el proyecto: agrega una columna "Tipo (P/D/C)" en tu mapeo. Muestra que entiendes que, por ejemplo, la redacción es **preventiva** y el logging es **detectivo**. Las notas de clase hablan de "control preventivo".

### 4.4 Correspondencia 2013 → 2022 de tus controles
Útil porque mucha bibliografía, y quizá lo que se dijo en clase ("8.1, 9.2, 10.1"), usa la numeración 2013: **A.8** era Gestión de activos, **A.9** Control de acceso y **A.10** Criptografía.

| 2022 | Proviene de (2013) |
|------|-------------------|
| 5.12 Clasificación | A.8.2.1 |
| 5.15 Control de acceso | A.9.1.1, A.9.1.2 |
| 5.16 Gestión de identidades | A.9.2.1 |
| 5.17 Información de autenticación | A.9.2.4, A.9.3.1, A.9.4.3 |
| 5.18 Derechos de acceso | A.9.2.2, A.9.2.5, A.9.2.6 |
| 5.33 Protección de registros | A.18.1.3 |
| 8.2 Acceso privilegiado | A.9.2.3 |
| 8.3 Restricción de acceso | A.9.4.1 |
| 8.5 Autenticación segura | A.9.4.2 |
| 8.10, 8.11, 8.12 | Nuevos |
| 8.13 Respaldo | A.12.3.1 |
| 8.15 Registro | A.12.4.1, A.12.4.2, A.12.4.3 |
| 8.20 Seguridad de redes | A.13.1.1 |
| 8.24 Criptografía *(complementario)* | A.10.1.1, A.10.1.2 |

---

## 5. Gestión de riesgos: el lenguaje del proyecto

### 5.1 Conceptos

| Concepto | Definición práctica | Ejemplo |
|----------|--------------------|---------|
| **Activo** | Lo que tiene valor y se protege | Tabla `CLIENTES`, backups, cuentas |
| **Amenaza** | Lo que podría causar daño | Empleado curioso, atacante externo |
| **Vulnerabilidad** | Debilidad que la amenaza explota | `GRANT SELECT ... TO PUBLIC` |
| **Riesgo** | Posibilidad de que la amenaza explote la vulnerabilidad y cause impacto | Acceso no autorizado a salarios |
| **Probabilidad (P)** | Qué tan factible es que ocurra | 4 = probable |
| **Impacto (I)** | Qué tan grave sería | 5 = sanción legal, daño reputacional |
| **Nivel de riesgo** | P × I | 4 × 5 = 20 (crítico) |
| **Riesgo inherente** | Nivel **sin** controles (o con los actuales) | 20 |
| **Control** | Medida que reduce P o I | Revocar privilegios, redacción |
| **Riesgo residual** | Nivel **después** de aplicar controles | 2 × 3 = 6 |
| **Apetito/tolerancia** | Nivel máximo aceptable para la organización | ≤ 6 |

### 5.2 Cómo reduce el riesgo un control
- **Reduce probabilidad:** mínimo privilegio, autenticación fuerte (es más difícil que ocurra).
- **Reduce impacto:** cifrado y redacción (si ocurre, lo que se obtiene no sirve o está oculto).
- **Detecta:** auditoría (no evita, pero permite reaccionar y disuade).

### 5.3 Opciones de tratamiento
**Mitigar** (aplicar controles, lo que haces casi siempre), **evitar** (dejar de hacer la actividad, p. ej., no clonar datos reales a pruebas), **transferir** (seguros, terceros) y **aceptar** (documentar que se asume, como la falta de parches en XE).

### 5.4 La pizarra: costo y reducción
El profesor dibujó controles con "$" y flechas tipo "8 → 4", "4 → 2". Interpretación coherente: **cada control cuesta, y debes justificar que reduce el riesgo a un nivel aceptable**. En tu informe esto se ve como: riesgo inherente → controles (con esfuerzo/costo) → riesgo residual meta. Confírmalo con él.

### 5.5 Escala sugerida

| P / I | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Probabilidad | Rara | Improbable | Posible | Probable | Casi segura |
| Impacto | Insignificante | Menor | Moderado | Mayor (sanción, reclamo) | Catastrófico (fuga masiva, sanción grave Ley 8968) |

Bandas: 1–4 Bajo · 5–9 Medio · 10–14 Alto · 15–25 Crítico.

---

## 6. PHVA: el esqueleto metodológico

PHVA (Planificar–Hacer–Verificar–Actuar), o ciclo de Deming (PDCA en inglés), es el modelo de mejora continua sobre el que está construida ISO 27001.

| Fase | Qué significa en general | Qué es en tu proyecto | Producto |
|------|--------------------------|----------------------|----------|
| **Planificar** | Entender contexto, riesgos y decidir controles | Escenario, clasificación, R-CONF, tareas DBA, mapeo ISO, criterios de madurez, diagnóstico "antes" | Tablas 1, 2, 3, matriz inicial |
| **Hacer** | Implementar controles | Scripts de remediación: roles, perfiles, auditoría, redacción, TDE, red, RMAN | Carpeta `02_remediacion` |
| **Verificar** | Medir si funcionan | Re-ejecutar verificaciones, batería de pruebas, matriz "después" | Evidencias, matriz final |
| **Actuar** | Corregir y mejorar | Riesgo residual, plan de mejora, automatización (reporte semanal) | Plan de mejora |

Mapeo con 27001: Planificar ≈ cláusulas 4–6, Hacer ≈ 7–8, Verificar ≈ 9, Actuar ≈ 10.

> Para la defensa: "Usé PHVA porque es el ciclo en que se basa ISO 27001; mi diagnóstico 'antes/después' es literalmente Planificar–Hacer–Verificar, y el plan de mejora es Actuar".

---

## 7. Principios de seguridad que justifican los controles

### 7.1 Mínimo privilegio (*least privilege*)
Cada usuario o proceso recibe **solo** los privilegios estrictamente necesarios para su función, **solo** sobre los objetos necesarios, y **solo** durante el tiempo necesario.
- En Oracle se viola con: rol `DBA` a no-administradores, privilegios `ANY`, `GRANT ... TO PUBLIC`, `WITH ADMIN OPTION` innecesario.
- Se relaciona con **necesidad de saber** (*need to know*): aunque tengas acceso técnico, solo ves lo que tu función requiere (columnas, filas).

### 7.2 Separación de funciones (*segregation of duties*)
Ninguna persona debe controlar sola todas las etapas de una operación sensible. Aplicado al DBA:
- Quien **administra** la BD no debería ser quien **audita** su propio trabajo.
- Quien gestiona **claves de cifrado** puede ser distinto de quien administra datos.
- Oracle lo soporta con privilegios administrativos separados: **SYSDBA** (todo), **SYSOPER** (arranque/parada), **SYSBACKUP** (respaldos), **SYSKM** (gestión de claves TDE), **SYSDG** (Data Guard), **SYSRAC**, y roles **AUDIT_ADMIN** (configura auditoría) y **AUDIT_VIEWER** (solo lee auditoría). **Database Vault** permite incluso impedir que el DBA lea datos de aplicación.

### 7.3 Defensa en profundidad
Varias capas independientes; si una falla, otra protege:

| Capa | Control en Oracle | Qué detiene |
|------|-------------------|-------------|
| Red | Cifrado nativo/TLS, restricciones del listener | Intercepción |
| Autenticación | Perfiles, contraseñas fuertes, bloqueo | Suplantación |
| Autorización | Roles, mínimo privilegio | Acceso indebido a objetos |
| Datos (fila/columna) | VPD, redacción | Ver filas o columnas que no corresponden |
| Almacenamiento | TDE, backups cifrados | Robo de archivos |
| Detección | Auditoría, reportes | Abuso no detectado |

### 7.4 Zero Trust (confianza cero)
Modelo descrito en NIST SP 800-207: **"nunca confiar, siempre verificar"**. Estar dentro de la red no da confianza automática.
Principios aplicados a BD:
- Autenticar y autorizar **cada** sesión; no confiar en la IP de origen.
- Mínimo privilegio y acceso por sesión/contexto.
- **Asumir brecha**: cifrar en reposo y en tránsito y auditar, como si el atacante ya estuviera dentro.
- Verificación continua (monitoreo).

### 7.5 Confidencialidad por diseño y por defecto
Los datos sensibles deben estar protegidos desde la creación del esquema (clasificación, columnas sensibles en tablespace cifrado, políticas de redacción) y no "parchados" después. Encaja con la Ley 8968.

---

## 8. Los 15 controles oficiales explicados uno por uno

Formato de cada control: **Propósito** (qué busca la norma), **En la BD** (qué significa para un DBA), **En Oracle** (mecanismo), **Evidencia** (qué ve el auditor), **Falla típica**, **Tipo**.

### A5.12 — Clasificación de la información
- **Propósito:** identificar el nivel de protección que requiere cada información según su sensibilidad y requisitos legales.
- **En la BD:** saber qué tablas/columnas son sensibles. Sin esto, no sabes qué cifrar, redactar o auditar.
- **En Oracle:** inventario de columnas sensibles; etiquetado con `COMMENT ON COLUMN` (o tabla de inventario); opcional Transparent Sensitive Data Protection (TSDP) para asociar políticas a tipos sensibles.
- **Evidencia:** `DBA_COL_COMMENTS` con etiquetas; documento de clasificación alineado con la Ley 8968 (sensible / restringido / irrestricto).
- **Falla típica:** "todo es confidencial" (no ayuda a priorizar) o nada está clasificado.
- **Tipo:** preventivo. **Es la base de los demás controles.**

### A5.15 — Control de acceso
- **Propósito:** establecer reglas (política) de acceso físico y lógico basadas en requisitos del negocio y de seguridad.
- **En la BD:** una **política escrita** de quién accede a qué, basada en funciones, implementada con roles.
- **En Oracle:** roles por función (`ROL_RRHH`, `ROL_SOPORTE`), grants a roles y no a usuarios, cero grants sensibles a `PUBLIC`.
- **Evidencia:** `DBA_ROLE_PRIVS`, `DBA_TAB_PRIVS`; documento de política; matriz rol–objeto aprobada.
- **Falla típica:** privilegios otorgados directamente a usuarios "por urgencia"; no existe política o no coincide con la realidad.
- **Tipo:** preventivo.

### A5.16 — Gestión de identidades
- **Propósito:** gestionar el ciclo de vida completo de las identidades (alta, cambios, baja).
- **En la BD:** cada persona tiene su propia cuenta (no cuentas compartidas tipo `ADMIN` usada por todos); bajas oportunas.
- **En Oracle:** `CREATE USER` nominal; `ACCOUNT LOCK` al salir la persona; revisión de `LAST_LOGIN`; distinción entre usuarios **comunes** (`C##`, en el CDB) y **locales** (en la PDB).
- **Evidencia:** `DBA_USERS` (estado, último login, perfil); cuentas inactivas > N días.
- **Falla típica:** cuentas huérfanas de ex-empleados; cuentas genéricas compartidas (sin trazabilidad).
- **Tipo:** preventivo.

### A5.17 — Información de autenticación
- **Propósito:** controlar la asignación y gestión de la información de autenticación (contraseñas, claves), incluyendo su calidad y protección.
- **En la BD:** contraseñas robustas, sin contraseñas por defecto, entregadas de forma segura, cambiadas periódicamente.
- **En Oracle:** perfiles con `PASSWORD_VERIFY_FUNCTION`, `PASSWORD_LIFE_TIME`, `PASSWORD_REUSE_*`; la vista `DBA_USERS_WITH_DEFPWD` detecta contraseñas por defecto.
- **Evidencia:** `DBA_PROFILES` (recursos tipo PASSWORD), `DBA_USERS_WITH_DEFPWD`.
- **Falla típica:** perfil `DEFAULT` sin función de verificación; contraseñas en scripts en texto plano.
- **Tipo:** preventivo.

### A5.18 — Derechos de acceso
- **Propósito:** otorgar, revisar periódicamente, modificar y retirar derechos de acceso según la política.
- **En la BD:** el acceso no es "para siempre": se **revisa** (ej. trimestral) y se retira lo que sobra.
- **En Oracle:** reportes de privilegios por usuario; `REVOKE`; opcional Privilege Analysis (`DBMS_PRIVILEGE_CAPTURE`) para detectar privilegios no usados, si tu edición lo permite.
- **Evidencia:** reporte de privilegios vs matriz aprobada; registros de auditoría de `GRANT`/`REVOKE`; el **reporte semanal de privilegios** que pidió el profesor.
- **Falla típica:** acumulación de privilegios al cambiar de puesto ("privilege creep").
- **Tipo:** preventivo/detectivo.

### A5.33 — Protección de registros
- **Propósito:** proteger los registros (*records*) contra pérdida, destrucción, falsificación, acceso no autorizado o publicación indebida.
- **En la BD:** el registro de auditoría es evidencia; si cualquiera puede leerlo o borrarlo, pierde valor y además puede contener datos sensibles.
- **En Oracle:** la auditoría unificada se guarda en el esquema `AUDSYS`, protegido; solo `AUDIT_ADMIN` puede gestionarla (incluida la purga con `DBMS_AUDIT_MGMT`) y `AUDIT_VIEWER` leerla; los cambios a la configuración de auditoría se auditan obligatoriamente.
- **Evidencia:** quién tiene `AUDIT_ADMIN/AUDIT_VIEWER`; política de retención; prueba de que un usuario común no puede leer `UNIFIED_AUDIT_TRAIL`.
- **Falla típica:** DBA operativo con `AUDIT_ADMIN` (puede borrar su propio rastro).
- **Tipo:** preventivo.

### A8.2 — Derechos de acceso privilegiado
- **Propósito:** restringir y gestionar la asignación y uso de derechos privilegiados.
- **En la BD:** los privilegios peligrosos (rol `DBA`, `SYSDBA`, `ANY`, `GRANT ANY`, `ALTER USER`, `EXEMPT ... POLICY`) solo para administradores identificados, justificados y auditados.
- **En Oracle:** `DBA_SYS_PRIVS`, `DBA_ROLE_PRIVS`, `V$PWFILE_USERS` (quién tiene SYSDBA/SYSBACKUP/SYSKM, etc.); privilegios administrativos separados por función.
- **Evidencia:** lista de cuentas con privilegios elevados = lista aprobada; auditoría de uso.
- **Falla típica:** la aplicación web se conecta con un usuario que tiene `DBA` o `SELECT ANY TABLE`.
- **Tipo:** preventivo. **Es el control más importante del proyecto.**

### A8.3 — Restricción de acceso a la información
- **Propósito:** restringir el acceso a la información según la política de control de acceso (nivel de datos, no solo de sistema).
- **En la BD:** que cada usuario vea solo las **filas** y **columnas** que le corresponden. Es lo que las notas llaman "política para columnas".
- **En Oracle:** vistas con columnas seleccionadas, grants por columna (para `INSERT/UPDATE/REFERENCES`), **VPD** (`DBMS_RLS`) para filtrar filas automáticamente, redacción para columnas.
- **Evidencia:** `DBA_POLICIES` (VPD), definiciones de vistas, prueba con dos usuarios que ven resultados distintos.
- **Falla típica:** acceso a la tabla completa cuando solo se necesitan algunas columnas.
- **Tipo:** preventivo.

### A8.5 — Autenticación segura
- **Propósito:** implementar tecnologías y procedimientos de autenticación seguros según la restricción de acceso.
- **En la BD:** bloqueo tras intentos fallidos, protocolos de hash modernos, cierre de sesiones inactivas (el **IDLE_TIME** que mencionó el profesor), idealmente MFA o autenticación centralizada para administradores.
- **En Oracle:** perfil con `FAILED_LOGIN_ATTEMPTS`, `PASSWORD_LOCK_TIME`, `IDLE_TIME`, `SESSIONS_PER_USER`; `PASSWORD_VERSIONS` en `DBA_USERS` (verificadores 12C); en `sqlnet.ora`, `SQLNET.ALLOWED_LOGON_VERSION_SERVER` para rechazar verificadores antiguos.
- **Evidencia:** perfiles asignados; intentos fallidos registrados en auditoría (ORA-01017); prueba de bloqueo (ORA-28000).
- **Falla típica:** sin límite de intentos (ataque de fuerza bruta posible).
- **Tipo:** preventivo.

### A8.10 — Eliminación de la información *(nuevo en 2022)*
- **Propósito:** eliminar la información cuando ya no se necesita, de forma segura.
- **En la BD:** datos borrados que siguen existiendo en la **papelera de reciclaje** (recyclebin), backups vencidos, dumps olvidados, esquemas de proyectos terminados, archivos en disco.
- **En Oracle:** `PURGE RECYCLEBIN`/`PURGE DBA_RECYCLEBIN`, política de retención de RMAN y `DELETE OBSOLETE`, `DROP USER ... CASCADE` para esquemas dados de baja, borrado de dumps y archivos.
- **Evidencia:** `DBA_RECYCLEBIN` vacío o controlado; `REPORT OBSOLETE`; procedimiento documentado.
- **Falla típica:** `DROP TABLE` que en realidad deja la tabla en la papelera, consultable.
- **Tipo:** preventivo. Además se relaciona con la Ley 8968 (derecho de supresión y no conservar datos más allá de lo necesario).

### A8.11 — Enmascaramiento de datos *(nuevo en 2022)*
- **Propósito:** ocultar datos (especialmente personales) según la política de acceso, requisitos legales y necesidades del negocio.
- **En la BD:** dos variantes que conviene distinguir bien:

| | **Redacción dinámica** (Data Redaction) | **Enmascaramiento estático** (Data Masking) |
|---|---|---|
| Cuándo | Al momento de la consulta | Se modifican los datos en una copia |
| Dato original | Intacto en la BD | Reemplazado en la copia |
| Uso típico | Producción: soporte ve `****1234` | Clones DEV/TEST con datos falsos pero realistas |
| Oracle | `DBMS_REDACT` | Data Masking and Subsetting / scripts propios de `UPDATE` |

- **Evidencia:** `REDACTION_POLICIES`, `REDACTION_COLUMNS`; consulta del mismo dato con dos usuarios distintos; quién está exento (`EXEMPT REDACTION POLICY`).
- **Falla típica:** creer que la redacción protege contra un DBA (SYS y quien tenga `EXEMPT REDACTION POLICY` ven todo; el rol `DBA` lo incluye indirectamente).
- **Tipo:** preventivo.

### A8.12 — Prevención de fuga de datos (DLP) *(nuevo en 2022)*
- **Propósito:** aplicar medidas para evitar la divulgación no autorizada de información desde sistemas, redes y dispositivos.
- **En la BD:** vías de salida masiva de datos: Data Pump (`expdp`), `UTL_FILE` (escribir archivos), `UTL_HTTP`/`UTL_TCP`/`UTL_SMTP` (enviar por red o correo), database links, clones, spool de clientes.
- **En Oracle:** restringir `DATAPUMP_EXP_FULL_DATABASE`/`EXP_FULL_DATABASE` y `CREATE ANY DIRECTORY`; revocar `EXECUTE` de paquetes `UTL_*` a `PUBLIC`; ACLs de red (`DBMS_NETWORK_ACL_ADMIN`); exportar con `ENCRYPTION=ALL`; auditar Data Pump (`COMPONENT = DATAPUMP EXPORT`).
- **Evidencia:** grants a `PUBLIC` sobre `UTL_*` = 0; quién tiene roles de exportación; registros de auditoría de exportaciones.
- **Falla típica:** cualquier usuario puede exportar o escribir archivos en el servidor.
- **Tipo:** preventivo/detectivo.

### A8.13 — Respaldo de la información
- **Propósito:** mantener y probar copias de respaldo según una política acordada.
- **En la BD (enfoque de confidencialidad):** el backup es una copia completa de los datos. Si no está cifrado y protegido, es la forma más fácil de robarlos. También debe **probarse** la restauración.
- **En Oracle:** RMAN con cifrado (modos transparente con keystore TDE, por contraseña o dual); retención; `RESTORE ... VALIDATE`; ubicación protegida.
- **Evidencia:** `V$BACKUP_PIECE.ENCRYPTED = YES`; `RMAN> SHOW ALL`; registro de restauraciones de prueba.
- **Falla típica:** backups sin cifrar en un disco compartido o en la nube sin control.
- **Tipo:** preventivo/correctivo.

### A8.15 — Registro (logging)
- **Propósito:** producir, almacenar, proteger y analizar registros de actividades, excepciones y eventos relevantes.
- **En la BD:** saber **quién** accedió a **qué** dato sensible, **cuándo**, **desde dónde** y si tuvo éxito. Es el único control que permite detectar abuso de alguien con acceso legítimo.
- **En Oracle:** **Auditoría unificada**: políticas sobre objetos sensibles, sobre acciones de gestión de accesos, sobre inicios de sesión fallidos (`ORA_LOGON_FAILURES`), sobre Data Pump; vista `UNIFIED_AUDIT_TRAIL`. Complementos: alert log y listener log.
- **Evidencia:** `AUDIT_UNIFIED_ENABLED_POLICIES`; registros reales en `UNIFIED_AUDIT_TRAIL`; reporte semanal.
- **Falla típica:** auditoría activada pero **nadie la revisa** (eso sería nivel 2–3, no 4); o auditar todo y generar ruido inútil.
- **Tipo:** detectivo.

### A8.20 — Seguridad de redes
- **Propósito:** proteger las redes y dispositivos de red para la información en sistemas y aplicaciones.
- **En la BD:** el tráfico entre cliente y servidor (consultas y resultados) puede viajar en texto plano. El listener es la puerta de entrada.
- **En Oracle:** cifrado nativo de red (`SQLNET.ENCRYPTION_SERVER=REQUIRED`, algoritmo AES256) y checksum (integridad), o TLS (TCPS); restricciones del listener (no administración remota, `TCP.VALIDNODE_CHECKING` para limitar IPs); puerto no expuesto a internet.
- **Evidencia:** `V$SESSION_CONNECT_INFO.NETWORK_SERVICE_BANNER` muestra el adaptador de cifrado; `lsnrctl status`; contenido de `sqlnet.ora`/`listener.ora`.
- **Falla típica:** conexiones sin cifrar desde la aplicación en una red compartida.
- **Tipo:** preventivo.

---

## 9. Controles complementarios recomendados

No están en la lista oficial, pero corresponden a tareas que la asignación sí pide. Inclúyelos marcados como "complementarios" si el profesor lo permite.

| Control | Por qué hace falta | Tarea relacionada |
|---------|-------------------|-------------------|
| **A8.24 Uso de criptografía** | Es el control que realmente cubre **TDE** y la gestión de claves | T-04 Cifrado |
| **A8.8 Gestión de vulnerabilidades técnicas** | Cubre el **parcheo** | T-08 Parcheo |
| **A8.16 Actividades de monitoreo** | Revisar activamente los logs (reporte semanal, alertas) | T-11 Logs |
| **A8.31 Separación de entornos** y **A8.33 Información de prueba** | Clones DEV/TEST sin datos reales | T-12 Clones |
| **A8.21 Seguridad de servicios de red** | Configuración segura del listener como servicio | T-09 Listener |
| A8.9 Gestión de la configuración | Mantener una línea base segura (parámetros, perfiles) | Todas |

Nota sobre **A8.8 en XE:** Oracle no publica parches (Release Updates) para la edición Express. En tu matriz esto es un caso honesto de **riesgo aceptado/limitación** con estado "Parcial", y una recomendación de usar una edición con soporte en producción.

---

## 10. Mecanismos de seguridad de Oracle (cómo se implementa todo)

### 10.1 Arquitectura multitenant (importante en XE 21c)
- **CDB** (`CDB$ROOT`): contenedor raíz; aquí viven el keystore TDE, la configuración de RMAN y los parámetros globales.
- **PDB** (`XEPDB1`): base "enchufable" donde van tus datos de aplicación. **Tu escenario va en XEPDB1.**
- **Usuarios comunes** (prefijo `C##`): existen en todo el CDB. **Usuarios locales**: solo en una PDB.
- Muchas vistas `V$` y `CDB_` muestran la columna `CON_ID` (1 = root, 3 = normalmente XEPDB1).
- `ORACLE_MAINTAINED = 'Y'` en `DBA_USERS`/`DBA_ROLES` identifica cuentas y roles internos de Oracle; filtra con `'N'` para ver solo los tuyos.

### 10.2 Autenticación y perfiles
- Métodos: contraseña (base de datos), sistema operativo, externa (Kerberos, LDAP/directorio), y el **archivo de contraseñas** para privilegios administrativos (`SYSDBA`, etc.).
- **Perfiles** (`CREATE PROFILE`): dos familias de límites:
  - **Contraseña:** `FAILED_LOGIN_ATTEMPTS`, `PASSWORD_LOCK_TIME`, `PASSWORD_LIFE_TIME`, `PASSWORD_GRACE_TIME`, `PASSWORD_REUSE_MAX`, `PASSWORD_REUSE_TIME`, `PASSWORD_VERIFY_FUNCTION`.
  - **Recursos:** `IDLE_TIME`, `CONNECT_TIME`, `SESSIONS_PER_USER`, etc. (requieren `RESOURCE_LIMIT = TRUE`, que es el valor por defecto en versiones modernas).
- Funciones de verificación incluidas: `ORA12C_VERIFY_FUNCTION`, `ORA12C_STRONG_VERIFY_FUNCTION` (si no existen, se crean con `utlpwdmg.sql`).

### 10.3 Privilegios y roles
- **Privilegios de sistema:** permiten acciones globales (`CREATE SESSION`, `CREATE TABLE`, `SELECT ANY TABLE`…). Los `ANY` son peligrosos porque aplican a **todos** los esquemas.
- **Privilegios de objeto:** sobre un objeto concreto (`SELECT ON empresa.clientes`, `EXECUTE ON paquete`).
- **Roles:** agrupan privilegios; se otorgan a usuarios. Facilitan cumplir A5.15 y A5.18.
- **PUBLIC:** pseudo-rol que tienen **todos** los usuarios. Lo que se le otorga a `PUBLIC` lo tiene cualquiera.
- `WITH ADMIN OPTION` (sistema/roles) y `WITH GRANT OPTION` (objetos): permiten re-otorgar; deben controlarse.
- Vistas clave: `DBA_SYS_PRIVS`, `DBA_TAB_PRIVS`, `DBA_COL_PRIVS`, `DBA_ROLE_PRIVS`, `ROLE_SYS_PRIVS`, `SESSION_PRIVS`.
- Lo que tus notas describen (crear usuario → privilegios → rol `vendedores` → otorgar rol a `juan` → perfiles con idle time) es exactamente la cadena de A5.16 → A5.15 → A5.18 → A8.5.

### 10.4 Virtual Private Database (VPD)
- Una **función de política** devuelve un predicado (por ejemplo `sucursal = 'HEREDIA'`) que Oracle **agrega automáticamente** al `WHERE` de cada consulta sobre la tabla.
- El usuario no puede saltarlo con SQL normal; solo `SYS` y quien tenga `EXEMPT ACCESS POLICY`.
- Se administra con `DBMS_RLS.ADD_POLICY`; evidencia en `DBA_POLICIES`.
- Control: A8.3 (restricción por **filas**).

### 10.5 Data Redaction
- Oculta valores de columnas **en el resultado** de la consulta, sin cambiar los datos almacenados.
- Tipos: `FULL` (valor por defecto: 0 o espacio), `PARTIAL` (`************1234`), `REGEXP`, `RANDOM`, `NONE`.
- Condición (`expression`): define a quién se le aplica (por ejemplo, a quien no tenga el rol RRHH).
- **Limitación importante:** no está diseñada para resistir a un usuario que intenta **inferir** valores con consultas ad hoc (por ejemplo, `WHERE salario > 1000000` sigue filtrando por el valor real). Es una capa de protección de presentación, no un muro absoluto. Por eso se combina con mínimo privilegio y auditoría.
- Control: A8.11 (y A8.3 por columnas).

### 10.6 Transparent Data Encryption (TDE)
- **Cifra los datos en reposo**: datafiles, y por extensión los datos de esos tablespaces en redo, undo, temp y backups.
- **Transparente**: el usuario autorizado consulta normalmente; Oracle descifra en memoria.
- **Arquitectura de dos niveles de claves:** una **clave maestra** guardada en el **keystore** (wallet) cifra las **claves de tablespace o columna**, que se guardan en la base de datos. Sin keystore abierto, los datos cifrados son inaccesibles.
- Modalidades: cifrado de **columna** o de **tablespace** (recomendado: más simple, permite índices normales).
- Configuración moderna (19c/21c): parámetros `WALLET_ROOT` y `TDE_CONFIGURATION`; comandos `ADMINISTER KEY MANAGEMENT`.
- **Qué NO hace:** no protege contra un usuario con privilegios SQL legítimos. Si tienes `SELECT` sobre la tabla, ves los datos en claro. Protege contra quien roba **archivos**, no contra quien tiene **acceso**.
- Evidencia: `V$ENCRYPTION_WALLET`, `DBA_TABLESPACES.ENCRYPTED`, `V$ENCRYPTED_TABLESPACES`.
- Control: A8.24 (complementario), y apoya A8.13 (backups) y A8.10.

### 10.7 Cifrado de red
- **Cifrado nativo de Oracle Net:** se configura en `sqlnet.ora` (`SQLNET.ENCRYPTION_SERVER`, `SQLNET.ENCRYPTION_TYPES_SERVER`, `SQLNET.CRYPTO_CHECKSUM_*`). Valores: `REJECTED`, `ACCEPTED`, `REQUESTED`, `REQUIRED`.
- **TLS (TCPS):** usa certificados y wallets; más estándar, más complejo de configurar.
- Para el proyecto, el cifrado nativo es suficiente y demostrable con `V$SESSION_CONNECT_INFO`.
- Control: A8.20.

### 10.8 Auditoría unificada
- Desde 12c, todas las fuentes de auditoría se consolidan en un solo rastro: `UNIFIED_AUDIT_TRAIL` (almacenado en `AUDSYS`).
- En 21c la base funciona por defecto en **modo mixto** (conviven la auditoría tradicional y la unificada); las **políticas unificadas funcionan igual**. La auditoría tradicional está en desuso.
- Componentes:
  - `CREATE AUDIT POLICY` (qué auditar: acciones, privilegios, roles, componentes como Data Pump, con condiciones).
  - `AUDIT POLICY ...` (habilitarla, opcionalmente para ciertos usuarios o solo éxitos/fallos).
  - Políticas predefinidas (`ORA_SECURECONFIG`, `ORA_LOGON_FAILURES`, etc.).
  - `DBMS_AUDIT_MGMT` para retención y purga (solo `AUDIT_ADMIN`).
- Cada registro incluye usuario, fecha/hora, acción, objeto, código de retorno, terminal/host, SQL (si se configura) y más. Es lo que tus notas describen: "sabe a qué hora se conectó, a qué hora se desconectó, sabe todo".
- Control: A8.15, A5.33, apoya A5.18 y A8.12.

### 10.9 LogMiner (mencionado en clase)
- Permite leer los **redo logs** (online y archivados) y reconstruir las operaciones: `SQL_REDO` (lo que se hizo) y `SQL_UNDO` (cómo revertirlo), con usuario y hora.
- Útil para **análisis forense** de cambios, detección de fraudes en modificaciones, y, como dijo el profesor, extraer patrones (incluso con IA).
- **Limitación clave para confidencialidad:** el redo solo contiene **cambios** (INSERT, UPDATE, DELETE, DDL). **Un `SELECT` no genera redo**, así que LogMiner **no puede mostrar quién leyó datos**. Para saber quién **consultó** información sensible necesitas **auditoría**. Esta distinción es excelente para la defensa.
- Requiere supplemental logging para información completa; se usa con `DBMS_LOGMNR`.

### 10.10 RMAN y Data Pump con cifrado
- **RMAN:** `CONFIGURE ENCRYPTION FOR DATABASE ON` (modo transparente con keystore), `SET ENCRYPTION ON IDENTIFIED BY ... ONLY` (modo contraseña), o ambos (dual). `V$BACKUP_PIECE.ENCRYPTED` lo evidencia.
- **Data Pump:** parámetros `ENCRYPTION`, `ENCRYPTION_MODE`, `ENCRYPTION_PASSWORD`; acceso controlado por roles `DATAPUMP_EXP_FULL_DATABASE`/`DATAPUMP_IMP_FULL_DATABASE` y objetos `DIRECTORY`.

### 10.11 Database Vault (opcional, "excede")
- Permite crear **reinos** (*realms*) que impiden incluso a usuarios con privilegios `ANY` o rol DBA leer datos de un esquema. Implementa separación de funciones de forma técnica. La página de XE lo menciona como disponible. Úsalo solo si sobra tiempo: es potente pero puede complicar la administración.

### 10.12 Disponibilidad en XE 21c
Según la información oficial de XE, la edición incluye seguridad avanzada (TDE, Data Redaction), políticas de auditoría y Database Vault. Límites de XE: 2 núcleos de CPU, 2 GB de RAM, 12 GB de datos de usuario, una instalación por máquina, sin soporte ni parches.

---

## 11. Auditoría, evidencia y madurez

### 11.1 Qué hace un auditor externo
No confía en lo que le dicen; **verifica**. Para cada control pregunta:
1. ¿Existe una política o procedimiento? (**diseño**)
2. ¿Está implementado técnicamente?
3. ¿Funciona de forma consistente en el tiempo? (**eficacia operativa**)
4. ¿Hay evidencia que lo pruebe?

La diferencia entre **diseño** y **eficacia operativa** es exactamente lo que dijo el profesor: *"una cosa es documentarlo y en el momento de hacerlo el control nunca ha sido ejecutado"*.

### 11.2 Evidencia observable
Evidencia que un tercero puede **obtener o reproducir** por sí mismo, sin depender de tu palabra:
- Resultado de una consulta al diccionario de datos (`DBA_SYS_PRIVS`…).
- Contenido de un archivo de configuración (`sqlnet.ora`).
- Registros de auditoría con fecha.
- Resultado de una prueba (error ORA esperado).
- Captura con fecha, usuario y contenedor visibles.

Cualidades de buena evidencia: **suficiente** (cubre el control), **pertinente** (prueba lo que dice), **fiable** (no manipulable, reproducible) y **fechada**.

### 11.3 Escala de madurez 0–4
Inspirada en modelos como CMMI/COBIT (que usan 0–5), adaptada a lo que pide la asignación:

| Nivel | Nombre | Pregunta que lo define |
|-------|--------|-----------------------|
| 0 | Inexistente | ¿Existe algo? No. |
| 1 | Inicial | ¿Se hace? A veces, sin método ni registro. |
| 2 | Documentado | ¿Está escrito? Sí, pero no hay prueba de que se ejecute. |
| 3 | Implementado y verificado | ¿Hay evidencia técnica de que funciona? Sí. |
| 4 | Gestionado | ¿Se monitorea y mejora periódicamente (automatizado)? Sí. |

Regla de estado: 0–1 = **No cumple**, 2 = **Parcial**, 3–4 = **Cumple**.

### 11.4 La matriz de evaluación
`Tarea | Riesgo | Control | Criterio 0-4 | Evidencia | Estado` une todo: cada fila dice "para esta tarea del DBA, que tiene este riesgo, este control está en este nivel, y lo pruebo con esta evidencia". Si la matriz se lee de forma lógica, cumple lo que el profesor dijo que más le importa.

### 11.5 Prueba vs verificación
- **Verificación** (script V-xx): inspecciona el **estado** de la configuración ("¿quién tiene DBA?").
- **Prueba** (PT-xx): ejerce el **comportamiento** ("intento leer con este usuario y debe fallar"). Las **pruebas negativas** (lo que no debe poder hacerse) son las más convincentes para un auditor.

---

## 12. Marco normativo costarricense

> Verifica artículos y vigencia en el texto oficial (SCIJ, PRODHAB, CGR) antes de citar.

### 12.1 Ley N.º 8968 — Protección de la Persona frente al Tratamiento de sus Datos Personales (2011)
- **Objeto:** garantizar el derecho a la **autodeterminación informativa**: el control de cada persona sobre sus datos.
- **Ámbito:** bases de datos automatizadas o manuales, públicas o privadas.
- **Categorías de datos** (base para tu clasificación A5.12):
  - **Datos sensibles:** fuero íntimo (origen racial, opiniones políticas, convicciones religiosas, salud, vida y orientación sexual, entre otros). Protección máxima.
  - **Datos de acceso restringido:** en registros públicos, pero solo de interés para su titular o la Administración.
  - **Datos de acceso irrestricto:** en bases públicas de acceso general.
- **Principios:** consentimiento informado, calidad de la información (exacta, actual, necesaria, conservada solo el tiempo necesario).
- **Derechos del titular:** acceso, rectificación, supresión (relaciona con A8.10).
- **Seguridad de los datos:** obligación del responsable de adoptar **medidas técnicas y organizativas** que garanticen la seguridad y eviten alteración, pérdida, tratamiento o acceso no autorizado. **Este es el enlace legal directo con tus controles.**
- **Deber de confidencialidad:** quienes intervienen en el tratamiento deben guardar secreto.
- **Autoridad:** **PRODHAB** (Agencia de Protección de Datos de los Habitantes).
- **Sanciones:** faltas leves, graves y gravísimas; las gravísimas pueden llegar a multas de hasta treinta salarios base y suspensión del funcionamiento de la base de datos.
- **Reglamento:** Decreto Ejecutivo N.º 37554-JP (verificar), que desarrolla protocolos de actuación y medidas de seguridad.
- **Reforma:** existe un proyecto de reforma integral (expediente 22.388) inspirado en estándares como el RGPD europeo: nuevos derechos (portabilidad, limitación), delegado de protección de datos y evaluaciones de impacto. **Verifica su estado actual** antes de mencionarlo como vigente.

**Cómo usarla en el proyecto:** el impacto de los riesgos R-CONF es alto porque una fuga de datos personales constituye incumplimiento del deber de seguridad y confidencialidad de la Ley 8968, con sanciones y daño reputacional. Tu clasificación de columnas usa sus categorías.

### 12.2 Ley N.º 8292 — Ley General de Control Interno (2002) y SEVRI
- Aplica a la Administración Pública. Exige un sistema de control interno con cinco componentes: ambiente de control, **valoración del riesgo**, actividades de control, sistemas de información y seguimiento.
- **SEVRI** (Sistema Específico de Valoración del Riesgo Institucional): obligación de identificar, analizar, evaluar, administrar y revisar riesgos de forma sistemática, con directrices de la Contraloría General de la República.
- **Relación con el proyecto:** tu tabla de riesgos y su tratamiento es un ejercicio de valoración del riesgo; si la organización ficticia fuera pública, tus R-CONF alimentarían su SEVRI. Esto conecta con lo que el profesor anotó en la pizarra (Ley de Control Interno → Administración del riesgo → SEVRI).

### 12.3 Regulación sectorial (mención breve)
La pizarra menciona **SUGEF** y **SUGEVAL**: superintendencias del sector financiero que emiten normativa de gestión de TI y riesgo para entidades supervisadas (por ejemplo, el reglamento de gestión de TI de SUGEF basado en COBIT). Si tu organización ficticia es financiera, menciona que también le aplicaría. Verifica la norma vigente antes de citarla.

### 12.4 Certificaciones
La pizarra también menciona **ISACA** (certificaciones como CISA, auditoría de SI, y CISM, gestión de seguridad; y el marco COBIT) e **ISO** (certificación del SGSI con 27001). Sirven para contextualizar quién audita y con qué estándares.

---

## 13. Cómo encaja todo: la cadena completa con un ejemplo

```
CONTEXTO ─► ACTIVO ─► RIESGO ─► TAREA DBA ─► CONTROL ISO ─► IMPLEMENTACIÓN ORACLE
                                                                  │
   RIESGO RESIDUAL ◄── ESTADO ◄── MADUREZ 0-4 ◄── PRUEBA ◄── EVIDENCIA OBSERVABLE
```

### Ejemplo de punta a punta: R-CONF-01

1. **Contexto:** la empresa guarda salario y tarjeta de 500 clientes (datos de acceso restringido según la Ley 8968).
2. **Activo:** tabla `EMPRESA.CLIENTES`, columnas `SALARIO` y `NUM_TARJETA` clasificadas como SENSIBLE (A5.12).
3. **Riesgo:** R-CONF-01, acceso no autorizado por privilegios excesivos. P = 4, I = 5, nivel 20 (crítico).
4. **Vulnerabilidades encontradas (diagnóstico "antes"):** `dev_juan` tiene rol `DBA`; `app_web` tiene `SELECT ANY TABLE`; `SELECT` sobre `CLIENTES` otorgado a `PUBLIC`.
5. **Tarea DBA:** T-02, gestión de privilegios y roles.
6. **Controles:** A8.2 (privilegios elevados), A5.15 (política y roles), A5.18 (revisión de derechos), A8.11 (redacción), A8.15 (auditoría).
7. **Implementación:** `REVOKE DBA`, `REVOKE SELECT ANY TABLE`, `REVOKE ... FROM PUBLIC`, roles `ROL_RRHH`/`ROL_SOPORTE`, política de redacción, política de auditoría sobre `CLIENTES`.
8. **Evidencia:** salida de `DBA_ROLE_PRIVS` y `DBA_SYS_PRIVS` antes (filas problemáticas) y después (sin filas); `REDACTION_COLUMNS`; registros en `UNIFIED_AUDIT_TRAIL`.
9. **Pruebas:** PT-01 (`app_web` recibe ORA-00942), PT-03 (soporte ve `************1234`), PT-11 (la consulta queda auditada).
10. **Madurez:** A8.2 pasa de 0 a 3; con reporte semanal programado de privilegios, a 4.
11. **Estado:** Cumple.
12. **Riesgo residual:** P baja a 2 (menos usuarios pueden acceder), I baja a 3 (datos redactados para la mayoría) → 6 (medio, dentro de la meta). Riesgo restante: un administrador con privilegios sigue pudiendo ver datos → plan de mejora: Database Vault o separación SYSKM/AUDIT_ADMIN (fase Actuar).

Si cada riesgo se puede contar así, el proyecto está bien construido.

---

## 14. Errores conceptuales frecuentes (y cómo defenderte)

| Error | Corrección |
|-------|-----------|
| "Con TDE los datos están protegidos de todos" | TDE protege **archivos en reposo**; quien tiene `SELECT` legítimo ve datos en claro |
| "La redacción oculta los datos al DBA" | SYS y quien tenga `EXEMPT REDACTION POLICY` (incluido indirectamente el rol DBA) ven todo; además se puede inferir con `WHERE` |
| "LogMiner me dice quién vio los datos" | LogMiner lee redo y el redo no registra `SELECT`; para lecturas se usa auditoría |
| "Activé la auditoría, entonces cumple A8.15 al máximo" | Sin revisión periódica ni protección del rastro es nivel 3, no 4 |
| "El backup es un tema de disponibilidad" | Para confidencialidad, un backup sin cifrar es una copia robable de todos los datos |
| "Si borré la tabla, ya no existe" | Puede estar en la recyclebin, en backups y en dumps (A8.10) |
| "Documenté la política, entonces cumple" | Documentado sin ejecución = nivel 2, Parcial |
| "Dar privilegios a `PUBLIC` es práctico" | Equivale a dárselos a todos, incluidos usuarios futuros |
| "ISO 27001 obliga a aplicar los 93 controles" | La organización selecciona según sus riesgos y lo justifica en la Declaración de Aplicabilidad |
| "Zero Trust es un producto" | Es un modelo/principio: verificar siempre, mínimo privilegio, asumir brecha |
| "27001 y 27002 son lo mismo" | 27001 = requisitos certificables + lista de controles; 27002 = guía de implementación |

---

## 15. Glosario

| Término | Significado |
|---------|-------------|
| Anexo A | Lista de 93 controles de referencia de ISO 27001:2022 |
| SGSI | Sistema de Gestión de Seguridad de la Información |
| SoA | Declaración de Aplicabilidad: qué controles se aplican y por qué |
| PHVA | Planificar–Hacer–Verificar–Actuar |
| CID | Confidencialidad, Integridad, Disponibilidad |
| R-CONF | Código de los riesgos de confidencialidad del proyecto |
| Riesgo inherente / residual | Antes / después de controles |
| Mínimo privilegio | Solo los permisos necesarios |
| Separación de funciones | Nadie controla solo una operación crítica |
| Defensa en profundidad | Varias capas de control independientes |
| Zero Trust | Nunca confiar, siempre verificar |
| CDB / PDB | Contenedor raíz / base de datos enchufable |
| Perfil | Conjunto de límites de contraseña y recursos de un usuario |
| Rol | Grupo de privilegios asignable |
| PUBLIC | Pseudo-rol que tienen todos los usuarios |
| VPD | Virtual Private Database: filtrado automático de filas |
| Data Redaction | Ocultar valores al consultar, sin cambiar los datos |
| Data Masking | Reemplazar datos reales en copias (no producción) |
| TDE | Cifrado transparente de datos en reposo |
| Keystore / wallet | Contenedor seguro de la clave maestra TDE |
| Unified Auditing | Auditoría consolidada de Oracle (`UNIFIED_AUDIT_TRAIL`) |
| LogMiner | Herramienta para leer y analizar redo logs |
| RMAN | Recovery Manager: respaldos y recuperación |
| Data Pump | Exportación/importación lógica (`expdp`/`impdp`) |
| DLP | Prevención de fuga de datos |
| SIEM | Sistema que centraliza y correlaciona logs de seguridad |
| Evidencia observable | Prueba verificable por un tercero |
| Madurez | Grado de desarrollo de un control (0–4) |
| PRODHAB | Agencia de Protección de Datos de los Habitantes |
| SEVRI | Sistema Específico de Valoración del Riesgo Institucional |

---

## 16. Preguntas de autoevaluación para la defensa

Si puedes responder estas preguntas con tus palabras, entiendes el proyecto:

1. ¿Por qué el DBA es un riesgo y a la vez el custodio de la confidencialidad?
2. ¿Qué diferencia hay entre ISO 27001 e ISO 27002? ¿Cuál es certificable?
3. ¿Qué cambió en el Anexo A de 2013 a 2022 y qué controles nuevos son relevantes para tu proyecto?
4. ¿Cuál es la diferencia entre riesgo inherente y residual? Da un ejemplo con tus R-CONF.
5. ¿Por qué A8.2 es probablemente el control más importante para la confidencialidad en BD?
6. ¿Qué protege TDE y qué **no** protege?
7. ¿En qué se diferencian redacción y enmascaramiento? ¿Cuándo usarías cada uno?
8. ¿Por qué LogMiner no sirve para saber quién **consultó** datos?
9. ¿Qué diferencia hay entre un control documentado (nivel 2) y uno implementado (nivel 3)? ¿Qué hace falta para el nivel 4?
10. ¿Qué es evidencia observable? Da tres ejemplos de tu proyecto.
11. ¿Cómo se aplica PHVA en tu trabajo, fase por fase?
12. ¿Qué exige la Ley 8968 en materia de seguridad y cómo la cumplen tus controles?
13. ¿Por qué un backup es un tema de confidencialidad?
14. ¿Qué es la separación de funciones y cómo la soporta Oracle?
15. ¿Por qué agregaste controles complementarios (A8.24, A8.8, A8.33) y cómo lo justificas?
16. ¿Qué riesgos quedan después de tus controles y qué harías en la fase Actuar?

---

## Fuentes oficiales para citar (APA 7)

- ISO/IEC. (2022). *ISO/IEC 27001:2022 Information security, cybersecurity and privacy protection — Information security management systems — Requirements*.
- ISO/IEC. (2022). *ISO/IEC 27002:2022 Information security, cybersecurity and privacy protection — Information security controls*.
- Oracle. (s. f.). *Oracle Database Security Guide, 21c*. Oracle Help Center.
- Oracle. (s. f.). *Oracle Database Advanced Security Guide, 21c* (TDE y Data Redaction). Oracle Help Center.
- Oracle. (s. f.). *Oracle Database Express Edition Licensing Information, 21c*. Oracle Help Center.
- Rose, S., Borchert, O., Mitchell, S., & Connelly, S. (2020). *Zero Trust Architecture* (NIST SP 800-207). National Institute of Standards and Technology.
- Asamblea Legislativa de la República de Costa Rica. (2011). *Ley N.º 8968: Protección de la Persona frente al Tratamiento de sus Datos Personales*.
- Asamblea Legislativa de la República de Costa Rica. (2002). *Ley N.º 8292: Ley General de Control Interno*.

(Ajusta el formato exacto, URL y fecha de consulta según APA 7.)
