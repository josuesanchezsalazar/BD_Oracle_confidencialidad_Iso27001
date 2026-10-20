# PASO A PASO DE INICIO — Del repositorio al primer avance (22 oct)

**Cómo usar este documento:** sigue los pasos en orden. Cada paso dice qué hacer, cuánto tarda aproximadamente y qué debe existir al terminar. Los pasos marcados con 🤖 son los momentos exactos en que le pides algo a Claude, con el prompt sugerido.

> **Regla de oro de la tabla de IA:** cada vez que uses una IA (🤖), registra de inmediato en `docs/uso-ia.md` el prompt exacto, qué te devolvió, qué corregiste y qué fuente verificaste. Se llena en el momento, no al final.

**Calendario resumido**

| Momento | Pasos | Resultado |
|---------|-------|-----------|
| Lun 19 (noche) | 1–5 | Repo, estructura y registro de IA listos; preguntas al profesor escritas |
| Mar 20 | 6–11 | Contexto, riesgos y tareas redactados; escenario Oracle corriendo; primeras evidencias |
| Mié 21 | 12–16 | Mapeo, matriz borrador y vista mínima del artefacto |
| Jue 22 | 17 | Presentación del avance |

---

## FASE A — Repositorio y base de trabajo (lunes noche, ~1 hora)

### Paso 1. Instalar y verificar herramientas (10 min)
Abre una terminal (PowerShell) y verifica:

```powershell
git --version
node --version
npm --version
```

- Si falta Git: https://git-scm.com/download/win
- Si falta Node.js: instala la versión LTS desde https://nodejs.org (solo se necesita para el artefacto en React, no es urgente esta noche).
- Configura tu identidad en Git (una sola vez):

```powershell
git config --global user.name "Tu Nombre"
git config --global user.email "tu_correo@ejemplo.com"
```

**Listo cuando:** `git --version` responde.

### Paso 2. Crear el repositorio en GitHub (5 min)
1. Entra a https://github.com/new
2. Nombre: `iso27001-confidencialidad-oracle`
3. Visibilidad: **Privado** por ahora (puedes darle acceso al profesor después).
4. Marca **Add a README file** y **Add .gitignore → None** (lo haremos a mano).
5. Licencia: ninguna.
6. Crea el repositorio.

> El PDF exige un **"repositorio Git institucional"**. No sabes aún cuál es (pregunta 8 de la lista al profesor). Empieza en GitHub personal; si te indican otra plataforma, se migra con `git remote set-url origin <nueva_url>` y `git push`, sin perder el historial.

**Listo cuando:** tienes la URL del repo.

### Paso 3. Clonar y crear la estructura de carpetas (10 min)

```powershell
cd C:\Users\<tu_usuario>\Documents          # o donde guardes tus proyectos
git clone https://github.com/<tu_usuario>/iso27001-confidencialidad-oracle.git
cd iso27001-confidencialidad-oracle

mkdir docs
mkdir sql\00_escenario, sql\01_verificacion, sql\02_remediacion, sql\03_pruebas, sql\04_reportes
mkdir evidencias\antes, evidencias\despues
mkdir entregables
```

Git no versiona carpetas vacías. Crea un archivo marcador en cada una:

```powershell
Get-ChildItem -Directory -Recurse | Where-Object { -not (Get-ChildItem $_.FullName -Force) } | ForEach-Object { New-Item -Path (Join-Path $_.FullName ".gitkeep") -ItemType File | Out-Null }
```

Copia a la raíz del repo los tres archivos que ya tienes: `PLAN_ACCION.md`, `CONTEXTO_PROYECTO.md` y este `PASO_A_PASO_INICIO.md`.

**Importante para las evidencias (`.gitignore`):** crea un archivo `.gitignore` en la raíz con:

```
node_modules/
dist/
*.log
*.dbf
*.bak
*.dmp
*.p12
*.sso
ewallet*
cwallet*
```

Esto evita subir por error archivos del wallet/keystore, dumps o datafiles. **Nunca subas contraseñas ni el keystore al repositorio.**

**Listo cuando:** `git status` muestra los archivos nuevos.

### Paso 4. Primer commit (5 min)

```powershell
git add .
git commit -m "inicio: estructura del repositorio y documentos base"
git push
```

**Listo cuando:** ves los archivos en GitHub.

### Paso 5. Preparar el registro de IA y las preguntas al profesor (20 min)

Crea `docs/uso-ia.md` con este formato (sale del PDF, sección 8):

```markdown
# Registro de uso de IA

| # | Fecha | Herramienta IA | Prompt exacto utilizado | Aporte de la IA | Validación / corrección del estudiante | Fuente verificada |
|---|-------|----------------|-------------------------|-----------------|----------------------------------------|-------------------|
| 1 | 19/10/2026 | Claude | (pega aquí el prompt inicial completo que usaste para pedir el plan) | Plan de acción, documento de contexto y paso a paso | Pendiente: validar controles y consultas contra ISO 27002:2022 y documentación Oracle | Pendiente |

## Declaración Jurada
Yo, [Nombre del estudiante], declaro que todo contenido generado con IA ha sido declarado
en la tabla anterior, validado contra fuentes oficiales (ISO, documentación del motor de BD)
y que asumo responsabilidad por su veracidad. Entiendo que omitir esta declaración
constituye falta grave.

Firma: ______________________   Fecha: ______________
```

Crea `docs/preguntas-profesor.md` copiando las 14 preguntas de la sección 10 de `PLAN_ACCION.md`. Marca como **prioritarias** las preguntas 1, 2, 3, 4 y 8 (fecha final, formato del avance, escala de riesgo, controles complementarios y repositorio).

```powershell
git add .
git commit -m "docs: registro de uso de IA y preguntas al profesor"
git push
```

**Listo cuando:** existen `uso-ia.md` con la fila 1 y `preguntas-profesor.md`.

---

## FASE B — Primera redacción y escenario Oracle (martes 20)

### Paso 6. Leer el contexto con un objetivo (45 min)
Lee `CONTEXTO_PROYECTO.md` secciones **1, 2, 5, 8 y 13**. Al terminar, responde de memoria (en una hoja, sin mirar) las preguntas 1, 4, 5 y 9 de la sección 16. Donde te trabes, relee esa parte.

**Listo cuando:** puedes explicar en voz alta la cadena riesgo → tarea → control → implementación → evidencia → madurez.

### Paso 7. Decidir tu empresa ficticia (20 min)
Escribe `docs/contexto-organizacion.md` con tus propias decisiones (esto es lo que evita problemas de similitud en Turnitin):

- Nombre y sector de la organización (inventados por ti).
- Qué datos personales maneja y cuáles de ellos son sensibles.
- Clasificación de datos: Público / Interno / Restringido / Sensible.
- Quién accede a la BD (roles: DBA, desarrollador, aplicación web, RRHH, soporte, auditor).
- Qué columnas de qué tabla serán tu "columna de alta sensibilidad" (el profesor habló de la tabla T1 columna C).

### Paso 8. 🤖 PRIMERA SOLICITUD A CLAUDE: plantilla de las tablas base (15 min + validación)
**Este es el momento de pedirle a Claude el "documento de plantilla".** Pídelo ahora, no antes, porque ya tienes decidido tu escenario y puedes darle contexto.

Prompt sugerido (cámbialo con tus datos reales y pégalo tal cual en la tabla de IA):

```
Contexto: proyecto de Administración de BD (Oracle 21c XE, ISO 27001:2022), enfocado solo en
confidencialidad. Mi organización ficticia es [describe en 3-4 líneas: sector, datos, roles].
Quiero la PLANTILLA en Markdown de estos documentos, con encabezados y filas de ejemplo
que yo luego reescribiré con mis propias palabras:
1) Tabla de riesgos R-CONF-01 a R-CONF-05 (causa, activo, probabilidad, impacto, nivel
   inherente, riesgo residual meta).
2) Tabla de 12 tareas del DBA vinculadas a riesgos y controles.
3) Matriz de evaluación: Tarea | Riesgo | Control | Criterio 0-4 | Evidencia | Estado.
4) Tabla de pruebas: ID | Tipo | Procedimiento | Resultado esperado | Herramienta.
Usa los controles oficiales A5.12, A5.15, A5.16, A5.17, A5.18, A5.33, A8.2, A8.3, A8.5,
A8.10, A8.11, A8.12, A8.13, A8.15, A8.20. Marca con asterisco cualquier control extra.
```

Guarda el resultado en `docs/plantillas/` y registra el prompt en `uso-ia.md` (fila 2).

**Importante:** la plantilla es un esqueleto. **Los valores (probabilidad, impacto, descripciones, justificaciones) los decides y redactas tú.** Si dejas el texto de la IA sin cambiar, lo detecta Turnitin y se considera falta de originalidad.

### Paso 9. Redactar las tablas con tus palabras (90 min)
Convierte las plantillas en tus documentos definitivos:

- `docs/01-riesgos.md` → tabla R-CONF con tus valores y una frase de justificación por cada P e I.
- `docs/02-tareas-dba.md` → las 12 tareas, cada una ligada a un riesgo y a uno o más controles.

**Validación obligatoria:** por cada control que incluyas, abre una fuente oficial (ISO 27002:2022 o la documentación de Oracle 21c) y verifica nombre y alcance. Anota en la columna "Validación" de `uso-ia.md` qué corregiste o descartaste.

```powershell
git add .
git commit -m "docs: contexto de la organización, riesgos R-CONF y tareas del DBA"
git push
```

**Listo cuando:** existen `01-riesgos.md` y `02-tareas-dba.md` escritos por ti.

### Paso 10. Levantar Oracle y crear el escenario inseguro (60 min)
Este paso no depende de los anteriores, así que puedes hacerlo en un bloque aparte.

1. Inicia los servicios `OracleServiceXE` y `OracleOraDB21Home1TNSListener` (los tienes en Manual).
2. Abre SQL Developer y conéctate como `SYS` con rol `SYSDBA` al servicio `XEPDB1`.
3. Verifica dónde estás:

```sql
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor FROM dual;   -- debe decir XEPDB1
```

4. Si todavía no tienes el script del escenario, **este es el segundo momento de pedirle algo a Claude**:

🤖 Prompt sugerido:

```
Genera el script 00_crear_escenario.sql para Oracle 21c XE (PDB XEPDB1) con:
- un tablespace propio y el esquema [NOMBRE_ESQUEMA]
- la tabla [NOMBRE_TABLA] con estas columnas sensibles: [tus columnas]
- 500 filas de datos ficticios generados con DBMS_RANDOM
- usuarios de prueba con MALAS prácticas deliberadas (un usuario con rol DBA,
  uno con SELECT ANY TABLE, un grant a PUBLIC, una cuenta de ex-empleado activa)
- un script 99_limpiar_escenario.sql para borrar todo y repetir desde cero
Las rutas de datafiles deben ser ajustables a mi instalación (usuario Windows: [tu_usuario]).
```

5. Ejecuta el script en SQL Developer, revisa que no haya errores ORA- y guarda el resultado.

```powershell
git add .
git commit -m "sql: script de escenario inseguro (estado ANTES)"
git push
```

**Listo cuando:** `SELECT COUNT(*) FROM <tu_esquema>.<tu_tabla>;` devuelve 500.

### Paso 11. Primeras evidencias "antes" (60 min)
Ejecuta 4 a 6 consultas de verificación y guarda su salida. Las más fáciles y vistosas para el avance:

| Control | Consulta base |
|---------|---------------|
| A8.2 | `DBA_ROLE_PRIVS` (quién tiene `DBA`) y `DBA_SYS_PRIVS` con `%ANY%` |
| A5.16 | `DBA_USERS` filtrando `ORACLE_MAINTAINED='N'` |
| A5.17 | `DBA_USERS_WITH_DEFPWD` y `DBA_PROFILES` (tipo PASSWORD) |
| A5.18 | `DBA_TAB_PRIVS` sobre tu esquema (aparecerá el grant a `PUBLIC`) |
| A8.15 | `AUDIT_UNIFIED_ENABLED_POLICIES` (debería salir sin políticas tuyas) |
| A8.24 | `V$ENCRYPTION_WALLET` (sin keystore configurado) |

Para cada una:
1. Guarda el script en `sql/01_verificacion/V0X_<control>.sql`.
2. Usa `SPOOL` para guardar la salida con fecha en `evidencias/antes/`:

```sql
SPOOL evidencias/antes/V08_A8_2_&f..txt
-- ... consultas ...
SPOOL OFF
```

3. Toma una captura de pantalla donde se vean: el resultado, el usuario conectado y el contenedor (`XEPDB1`).

Si necesitas ayuda con el encabezado de `SPOOL` o con una consulta que falla, el ejemplo está en la sección 5.6 de `PLAN_ACCION.md`.

```powershell
git add .
git commit -m "verif: evidencias ANTES de A8.2, A5.16, A5.17, A5.18, A8.15, A8.24"
git push
```

**Listo cuando:** hay al menos 4 archivos `.txt` en `evidencias/antes/` con resultados reales.

---

## FASE C — Mapeo, matriz y vista mínima (miércoles 21)

### Paso 12. Mapeo de los 15 controles (90 min)
Crea `docs/03-mapeo-controles.md` con una fila por control. Columnas mínimas (las del PDF, punto 3 del producto esperado):

`Control | Qué exige (parafraseado) | Riesgo que mitiga | Implementación en Oracle | Evidencia observable (consulta) | Tipo (P/D/C)`

Parte de la tabla de la sección 5.4 de `PLAN_ACCION.md` y de la sección 8 de `CONTEXTO_PROYECTO.md`, **pero reescríbela con tus palabras y verifica cada control en ISO 27002:2022**. Si agregas controles complementarios (A8.24, A8.8, A8.33), márcalos con asterisco.

### Paso 13. 🤖 TERCERA SOLICITUD A CLAUDE: revisión crítica (30 min)
Con tus tablas ya escritas, pídele a Claude (y a una segunda IA, como pidió el profesor) que las **revise**, no que las escriba:

```
Actúa como auditor ISO 27001. Revisa estas tablas que redacté (pego a continuación
riesgos, tareas y mapeo). Dime: 1) incoherencias entre riesgo, tarea y control,
2) controles mal justificados, 3) evidencias que no demuestran realmente el control,
4) qué haría dudar a un auditor externo. No reescribas el contenido: solo señala problemas.
```

Haz lo mismo con una segunda IA. Registra **ambas** revisiones en `uso-ia.md` (filas 3 y 4), con qué corrigiste.

### Paso 14. Escala de madurez y matriz borrador (45 min)
Crea `docs/04-matriz-evaluacion.md`:

1. Pega la escala 0–4 (sección 5.5 del plan) y adáptala con tus palabras.
2. Llena la matriz con el nivel **"antes"** de cada control usando las evidencias del paso 11. Los controles aún sin evidencia quedan como "pendiente de verificación".
3. Regla de estado: 0–1 = No cumple · 2 = Parcial · 3–4 = Cumple.

### Paso 15. Vista mínima del artefacto (60 min, solo si los pasos 12–14 están terminados)
No gastes tiempo aquí hasta que el contenido esté listo.

**Opción A (más rápida, recomendada para el 22):** un solo `index.html` con las tablas.

**Opción B (React + Vite):**

```powershell
npm create vite@latest artefacto -- --template react
cd artefacto
npm install
npm run dev
```

Pestañas mínimas: Contexto, Riesgos, Tareas, Mapeo. Los datos van en `src/data/*.json`.

🤖 Si quieres ayuda para el esqueleto, **este es el cuarto momento de pedirle algo a Claude**:

```
Crea un esqueleto de React + Vite (sin backend) con pestañas Contexto, Riesgos, Tareas y
Mapeo que lean datos de src/data/*.json. Tablas simples y legibles, estilo sobrio con
texto en negro, y una hoja de estilos de impresión para exportar a PDF.
```

Registra el prompt en `uso-ia.md`.

### Paso 16. Ensayo de la presentación (30 min)
Prepara una explicación de 3 a 5 minutos con este guion:

1. Problema y organización (30 s)
2. Riesgos R-CONF y cómo los calificaste (60 s)
3. Tareas del DBA y su vínculo con los controles (45 s)
4. Mapeo ISO → Oracle → evidencia, con **una demostración real** de una consulta (90 s)
5. Escala de madurez y qué sigue (45 s)

```powershell
git add .
git commit -m "avance1: mapeo de controles, matriz borrador y vista mínima"
git push
```

---

## FASE D — Jueves 22: el avance

### Paso 17. Lista de chequeo antes de salir
- [ ] Repo en GitHub actualizado y con acceso listo para mostrar
- [ ] `docs/contexto-organizacion.md`
- [ ] `docs/01-riesgos.md`, `02-tareas-dba.md`, `03-mapeo-controles.md`, `04-matriz-evaluacion.md`
- [ ] 4–6 evidencias reales en `evidencias/antes/`
- [ ] `docs/uso-ia.md` con todas las IAs usadas y sus prompts
- [ ] `docs/preguntas-profesor.md` impreso o abierto
- [ ] Oracle iniciado y conectado para hacer una demostración en vivo
- [ ] Artefacto (HTML o React) abierto, aunque sea básico

**Durante el avance:** haz las preguntas prioritarias (1, 2, 3, 4 y 8) y anota las respuestas en `docs/preguntas-profesor.md`. Con la fecha final confirmada, ajusta el cronograma de `PLAN_ACCION.md`.

---

## Resumen: cuándo pedirle cosas a Claude

| # | Momento | Qué pedir | Qué NO pedir |
|---|---------|-----------|--------------|
| 1 | Paso 8 (martes) | Plantillas Markdown de las tablas base | Que llene los valores por ti |
| 2 | Paso 10 (martes) | Script del escenario inseguro | — |
| 3 | Paso 13 (miércoles) | Revisión crítica de lo que tú redactaste | Que reescriba tus tablas |
| 4 | Paso 15 (miércoles) | Esqueleto de React | Contenido del informe |
| 5 | Después del 22 | Scripts de verificación V01–V15 y remediación, según el avance | — |

**Regla simple:** Claude da esqueletos, scripts y revisión; tú das las decisiones, los valores y la redacción final.
