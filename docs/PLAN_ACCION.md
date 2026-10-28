# PLAN DE ACCIÓN — Controles ISO/IEC 27001:2022 para la Confidencialidad en Oracle

**Curso:** EIF402 Administración de Bases de Datos — Prof. Johnny Villalobos Murillo — UNA, II Ciclo 2026
**Modalidad:** individual (se verifica originalidad con Turnitin)
**Motor:** Oracle Database 21c XE (PDB `XEPDB1`) + SQL Developer
**Período del plan:** lunes 19 oct 2026 → domingo 29 nov 2026

> **Convención usada en este documento**
> - **[O] Oficial** = lo pide el documento de asignación (fuente principal, lo que se evalúa).
> - **[N] Notas** = aclaración o comentario del profesor en clase (Semana 13, jueves 15/10).
> - **[S] Sugerencia** = recomendación propia para cumplir mejor o con menos esfuerzo. No es obligatoria.

> ⚠️ **Fecha a confirmar de inmediato.** Las notas de clase dicen que el artefacto "se entrega de hoy en 15" (desde el 15/10 → aprox. **29/10**) y que el **22/10** hay un adelanto obligatorio ("no presentarlo es pérdida del proyecto"). Este plan llega hasta el **29/11** como pediste, pero está construido para que el **29/10 exista una versión completa mínima** de los 6 componentes del artefacto. Si el profesor confirma que la entrega final es el 29/10, se usa esa versión y se comprime el resto (ver sección 6.3).

---

## 1. Análisis de requisitos

### 1.1 Requisitos oficiales [O] (documento de asignación)

| # | Requisito | Detalle exacto | Sección del doc |
|---|-----------|----------------|-----------------|
| O-1 | Riesgos | Identificar y clasificar **al menos 5** riesgos de confidencialidad `R-CONF-01..05`, con **impacto y probabilidad** | 3, 6.1 |
| O-2 | Tareas DBA | Mapear **al menos 12** tareas críticas: usuarios, privilegios, autenticación, cifrado TDE, masking, backup, auditoría, parcheo, listener, eliminación segura, logs, clones DEV/TEST | 3, 6.2 |
| O-3 | Controles | Seleccionar y justificar controles del Anexo A 2022: **A5.12, A5.15, A5.16, A5.17, A5.18, A5.33, A8.2, A8.3, A8.5, A8.10, A8.11, A8.12, A8.13, A8.15, A8.20** (son exactamente 15) | 3 |
| O-4 | Mapeo | Controles ISO → implementación sugerida → **evidencia observable** (consulta/configuración) | 6.3 |
| O-5 | Lista auditable | **15 controles observables por un auditor externo** | 6.4 |
| O-6 | Matriz | `Tarea | Riesgo | Control | Criterio 0-4 | Evidencia | Estado (Cumple/No cumple/Parcial)` | 3, 6.5 |
| O-7 | Pruebas | Batería: `ID | Tipo | Procedimiento | Resultado esperado | Herramienta` + **scripts de verificación obligatorios** | 3, 6.6 |
| O-8 | Marco teórico | 2–3 páginas: cambios 2013→2022 (93 controles, 4 temas), mínimo privilegio y separación de funciones, defensa en profundidad y Zero Trust, TDE / masking / redaction / VPD / TLS, DLP y backups cifrados, logging/SIEM, **Ley 8968** | 5 |
| O-9 | Metodología | **PHVA** (Planificar-Hacer-Verificar-Actuar) | 7 |
| O-10 | Herramientas | Oracle 19c/21c XE, SQL Developer | 7 |
| O-11 | Documentación | **APA 7**, **repositorio Git institucional**, **video de 5 minutos** | 7 |
| O-12 | Uso de IA | Tabla `Herramienta | Prompt exacto | Aporte | Validación/Corrección | Fuente verificada` + **Declaración Jurada** firmada. Omitirla = falta grave / plagio | 8 |
| O-13 | Entregables | 1) Informe PDF con el artefacto (o link al artefacto interactivo), 2) scripts `.sql`, 3) repo Git, 4) video 5 min, 5) tabla de IA firmada | 10 |
| O-14 | Formato del artefacto | "interactivo HTML, PDF o sitio" — cualquiera de los tres es válido | 6 |

### 1.2 Rúbrica [O] y dónde se gana cada punto

| Criterio | Peso | Cómo se gana en este plan |
|----------|------|---------------------------|
| Identificación de riesgos y tareas DBA | 20% | Tablas R-CONF y T-01..T-12 con contexto claro, P×I justificado, vínculo tarea↔riesgo |
| Mapeo y justificación de controles ISO | 20% | Cada control con: qué dice la norma (paráfrasis), por qué aplica al riesgo, cómo se implementa en Oracle, consulta de evidencia |
| Matriz de evaluación y controles observables | 20% | Escala 0-4 con criterios explícitos; evidencia "antes" y "después"; estado coherente con el nivel |
| Pruebas técnicas y scripts | 15% | Scripts que **corren** en XE 21c, con salida (spool) guardada como evidencia; pruebas negativas (ORA-xxxx esperados) |
| Documentación de IA y APA 7 | 15% | Tabla de IA honesta desde el día 1 (incluye este plan), declaración firmada, referencias APA 7 |
| Presentación, video y repositorio | 10% | Artefacto limpio, video guionizado, commits frecuentes, entrega a tiempo |

> Nota [N]: "mínima nota un 7, probada con una IA y más de 7 si excede" se dijo para la **práctica de recuperación**, no necesariamente para este proyecto. Ver preguntas al profesor.

### 1.3 Aclaraciones de las notas de clase [N]

- **Adelanto el jueves 22/10**; no presentarlo es pérdida del proyecto. Individual, se verifica individualidad y originalidad. Horario mencionado: 8 a 12 md.
- El profesor sugiere un artefacto en **React "bien elegante y bien hecho"**, pero aclara que **lo que le importa es que sea lógico** y que contenga **tablas de riesgos, impacto y mapeo ISO con implementación**.
- Insistió en la **evidencia observable** (ej.: `SELECT * FROM DBA_SYS_PRIVS`, `SELECT * FROM V$ENCRYPTION_WALLET`): sentencias SQL que **determinen** si un control está bien o lo **corrijan**.
- **Matriz de madurez**: distinguir entre un control *documentado* y uno *realmente ejecutado* ("una cosa es documentarlo y en el momento de hacerlo el control nunca ha sido ejecutado").
- Pruebas de **mínimo privilegio**, **auditoría**, y un **reporte semanal de accesos no autorizados y de privilegios no concedidos**; revisar **política de control de acceso** y **política por columnas** sensibles.
- Herramientas Oracle mencionadas: usuarios, privilegios, roles, **perfiles (IDLE_TIME)**, redo online/archive, **LogMiner**, **auditoría** (sabe quién, cuándo, conexión/desconexión), columna de alta sensibilidad.
- **Usar 2 IAs para revisión** del trabajo.
- **Ley de Control Interno (8292) → administración de riesgos (SEVRI)** y generar reporte (pizarra: SEVRI, SUGEVAL, SUGEF; certificaciones ISACA/ISO).
- Pizarra: "Integridad 8 → 4, Disponibilidad 8 → 4, Confidencialidad 4 → 2 (?)" con costos ($) por control. Interpretación probable: **llevar el nivel de riesgo inherente a un nivel residual menor aplicando controles que tienen costo**. → Confirmar con el profesor.
- Pizarra/nota menciona "C 8.1, 9.2, 9.5, 9.7, 10.1" — **no coincide** con la lista oficial (parece numeración antigua o de otro documento). **Manda la lista oficial**; preguntar.

> **Ojo:** las páginas 1–3 de tus notas (escenarios de fallo de medios, control file, 8 estrategias, manual de recuperación) son **otra asignación** (práctica individual de estrategias de recuperación). No se mezcla con este proyecto.

### 1.4 Vacíos detectados en la asignación [S]

La lista oficial de 15 controles **no incluye** controles que encajan directamente con tareas que la misma asignación pide mapear:

| Tarea pedida | Control 2022 que le corresponde mejor | ¿Está en la lista oficial? |
|---|---|---|
| Cifrado TDE | **A8.24** Uso de criptografía | No |
| Parcheo | **A8.8** Gestión de vulnerabilidades técnicas | No |
| Clones DEV/TEST | **A8.31** Separación de entornos / **A8.33** Información de prueba | No |
| Monitoreo de logs | **A8.16** Actividades de monitoreo | No |
| Listener / red | **A8.21** Seguridad de servicios de red | No (sí A8.20) |

**Recomendación:** trabajar los 15 oficiales como núcleo obligatorio y agregar estos 4–5 como **"controles complementarios"** claramente marcados. Eso demuestra criterio (suma en "Mapeo y justificación") sin desviarse de lo pedido. Confirmar con el profesor.

---

## 2. Explicación del proyecto en lenguaje claro

### 2.1 ¿Qué es esto en una frase?
Eres el DBA de una organización con datos personales; debes **demostrar con evidencia técnica** que la base de datos Oracle protege la **confidencialidad** según ISO 27001/27002:2022, y presentarlo como una **auditoría documentada** (riesgos → controles → cómo se implementan → cómo se verifican → qué tan maduros están).

### 2.2 ¿Es una aplicación, scripts o documentación?
**Las tres cosas, en esta proporción aproximada:**

| Componente | Peso real en la nota | Qué es |
|---|---|---|
| **Documentación / análisis** (riesgos, tareas, mapeo, matriz, marco teórico, IA) | ~55% | El corazón. Tablas bien razonadas. |
| **Scripts SQL + pruebas con evidencia** | ~35% | Consultas de verificación, scripts de remediación, pruebas negativas, salidas guardadas. |
| **Artefacto de presentación** (HTML/React/PDF), video, repo | ~10% | El "envase". No es un sistema de software. |

**No tienes que construir un sistema con backend.** El artefacto puede ser una página (React o HTML) que **muestra** tus tablas y evidencias. La "parte técnica" real son los scripts que corres en Oracle.

### 2.3 La idea clave que hace todo coherente: "Antes → Después" [S]
1. Creas en `XEPDB1` una **empresa ficticia** con datos sensibles y la configuras **deliberadamente mal** (usuario de desarrollo con rol DBA, `GRANT SELECT ... TO PUBLIC`, contraseñas débiles, cuenta de ex-empleado activa, sin auditoría, sin cifrado).
2. Corres los **scripts de verificación** → evidencias "ANTES" → la matriz sale en "No cumple / nivel 0-1".
3. Aplicas los **scripts de remediación** (PHVA: Hacer).
4. Vuelves a correr los **mismos scripts de verificación** → evidencias "DESPUÉS" → "Cumple / nivel 3-4".
5. Corres la **batería de pruebas** (incluye intentos de acceso que **deben fallar**).

Esto te da evidencia observable real, una matriz con sentido, un riesgo residual medible y una demo perfecta para el video.

### 2.4 Conocimientos que necesitas

| Tema | Nivel necesario | Dónde se usa |
|---|---|---|
| ISO 27001:2022 Anexo A vs ISO 27002:2022 (guía de implementación) | Conceptual | Marco teórico, mapeo |
| Gestión de riesgos (probabilidad × impacto, inherente vs residual) | Conceptual | Tabla R-CONF, matriz |
| PHVA | Conceptual | Estructura de todo el trabajo |
| Usuarios, roles, privilegios de sistema/objeto, `PUBLIC`, perfiles | Práctico | A5.15–A5.18, A8.2, A8.5 |
| Diccionario de datos de seguridad (`DBA_USERS`, `DBA_SYS_PRIVS`, `DBA_ROLE_PRIVS`, `DBA_TAB_PRIVS`, `DBA_PROFILES`, `DBA_USERS_WITH_DEFPWD`) | Práctico | Verificación |
| Unified Auditing (`CREATE AUDIT POLICY`, `UNIFIED_AUDIT_TRAIL`) | Práctico | A8.15, A5.33 |
| Data Redaction (`DBMS_REDACT`) y VPD (`DBMS_RLS`) | Práctico básico | A8.11, A8.3 |
| TDE en multitenant (`WALLET_ROOT`, keystore, tablespace cifrado) | Práctico (con cuidado) | A8.24* / R-CONF-03 |
| RMAN con cifrado, Data Pump con cifrado | Práctico básico | A8.13, A8.12 |
| `sqlnet.ora` (cifrado nativo de red) y listener | Práctico básico | A8.20 |
| Ley 8968 y su reglamento; Ley 8292 (SEVRI) | Conceptual | Marco teórico, contexto |
| APA 7 | Formato | Referencias |

Oracle XE 21c **sí incluye** TDE, Data Redaction y auditoría (verificado en la información de licenciamiento de XE), así que todo se puede demostrar en tu instalación local.

---

## 3. Arquitectura recomendada (la más sencilla que cumple)

```
┌───────────────────────────────────────────────────────────────┐
│  Oracle 21c XE (tu PC)                                         │
│   CDB$ROOT ── keystore TDE, RMAN, sqlnet.ora                   │
│   XEPDB1   ── esquema EMPRESA (datos ficticios sensibles)      │
│               usuarios/roles de prueba, políticas de auditoría │
│               redacción, VPD, perfiles                         │
└──────────────▲────────────────────────────────────────────────┘
               │ SQL Developer / SQL*Plus (SPOOL → .txt)
┌──────────────┴────────────────────────────────────────────────┐
│  Repositorio Git                                               │
│   sql/  (escenario, verificación, remediación, pruebas,        │
│          reportes)                                             │
│   evidencias/antes  evidencias/despues  (txt + capturas)       │
│   artefacto/  React + Vite estático: lee datos de JSON         │
│   docs/  marco teórico, IA, referencias, guion video           │
└───────────────────────────────────────────────────────────────┘
               │ npm run build  →  sitio estático
               │ Imprimir a PDF (hoja de estilos de impresión)
               ▼
        Informe PDF + link al artefacto + video 5 min
```

**Decisiones:**
- **Artefacto = React + Vite estático, sin backend.** Las tablas viven en archivos `src/data/*.json`. Cumple la sugerencia de "React elegante" y el requisito de "interactivo HTML/sitio", y con una hoja de estilos de impresión (texto negro) genera el **Informe PDF** desde la misma fuente. Cero servidor, cero conexión en vivo.
- **Sin backend Python obligatorio.** Si antes pensabas en Python + React, déjalo como **mejora opcional de la última semana** (ej.: un script con `python-oracledb` que corre los `V-xx` y regenera `evidencias.json`). No lo necesitas para cumplir la rúbrica.
- **Plan B si el tiempo aprieta:** una sola página HTML con las tablas, o directamente un PDF. La asignación acepta ambos.

---

## 4. Herramientas necesarias

| Herramienta | Uso | Estado |
|---|---|---|
| Oracle Database 21c XE | Motor | Ya instalado (servicios en Manual: iniciar `OracleServiceXE` y el listener antes de trabajar) |
| SQL Developer | Ejecutar scripts, capturas | Instalar/verificar |
| SQL*Plus | `SPOOL` de evidencias con fecha | Incluido en XE |
| RMAN | Backup cifrado | Incluido |
| Git + plataforma institucional (GitHub/GitLab) | Repositorio | Preguntar URL/plataforma |
| Node.js LTS + Vite + React | Artefacto | `npm create vite@latest artefacto -- --template react` |
| Herramienta de captura (Win+Shift+S) | Evidencias | — |
| OBS Studio o grabador de Windows | Video 5 min | — |
| Zotero (opcional) | Referencias APA 7 | — |
| 2 IAs (p. ej. Claude + otra) | Revisión cruzada [N] | Documentar ambas en la tabla de IA |

---

## 5. Contenido técnico base (borradores para adaptar con tus palabras)

> ⚠️ **Originalidad:** el trabajo pasa por Turnitin y se verifica individualidad. Usa estos borradores como guía; **redacta con tus palabras, elige tu propio escenario y ajusta valores**. Declara el uso de IA en la tabla (incluido este plan).

### 5.1 Contexto / escenario [S]
Define una organización ficticia propia (sector, qué datos personales maneja, quién accede). Ejemplo de estructura:
- Organización: *(nombre inventado)*, sector *(salud/financiero/educación/comercio)*.
- Datos en la BD: cédula, nombre, correo, teléfono, salario o saldo, número de tarjeta (ficticio), diagnóstico/observaciones, etc.
- Clasificación (A5.12): **Público / Interno / Restringido / Sensible** (alineado con la Ley 8968: datos de acceso irrestricto, restringido y sensibles).
- Actores: DBA, desarrollador, aplicación web, analista de RRHH, soporte, auditor.

### 5.2 Tabla de riesgos R-CONF (borrador)
Escala sugerida: Probabilidad (P) 1–5 × Impacto (I) 1–5 = Nivel. Bandas: 1–4 Bajo, 5–9 Medio, 10–14 Alto, 15–25 Crítico. *(Confirmar escala con el profesor.)*

| ID | Riesgo | Causa / vector | Activo afectado | P | I | Nivel inherente | Meta residual |
|----|--------|----------------|-----------------|---|---|-----------------|---------------|
| R-CONF-01 | Acceso no autorizado por privilegios excesivos o acumulados | Rol DBA o privilegios `ANY` a cuentas no administrativas; grants a `PUBLIC` | Tablas con datos personales | 4 | 5 | 20 Crítico | ≤ 6 |
| R-CONF-02 | Suplantación por autenticación débil o cuentas inactivas | Contraseñas débiles/por defecto, sin bloqueo, cuentas de ex-empleados activas | Cuentas de BD | 4 | 4 | 16 Crítico | ≤ 6 |
| R-CONF-03 | Exposición de datos en reposo | Datafiles y respaldos sin cifrar; eliminación insegura (recyclebin, backups viejos) | Datafiles, backups | 3 | 5 | 15 Crítico | ≤ 5 |
| R-CONF-04 | Fuga por exportaciones y entornos no productivos | Data Pump sin control/cifrado; clones DEV/TEST con datos reales sin enmascarar | Dumps, clones | 3 | 4 | 12 Alto | ≤ 4 |
| R-CONF-05 | Interceptación de datos en tránsito / listener expuesto | Conexiones sin cifrado, listener sin restricciones | Sesiones de red | 2 | 4 | 8 Medio | ≤ 3 |
| R-CONF-06 *(adicional)* | Falta de trazabilidad | Auditoría deshabilitada o registros manipulables por usuarios no autorizados | Registros de auditoría | 4 | 3 | 12 Alto | ≤ 4 |

### 5.3 Tabla de tareas del DBA (12 obligatorias)

| ID | Tarea | Descripción operativa | Riesgo(s) | Controles |
|----|-------|-----------------------|-----------|-----------|
| T-01 | Gestión de usuarios | Alta, baja y revisión periódica; sin cuentas compartidas ni huérfanas | R-02, R-01 | A5.16, A5.18 |
| T-02 | Privilegios y roles | Roles por función, mínimo privilegio, nada a `PUBLIC` | R-01 | A5.15, A8.2, A8.3 |
| T-03 | Autenticación y perfiles | Perfil con complejidad, bloqueo, expiración, `IDLE_TIME` | R-02 | A5.17, A8.5 |
| T-04 | Cifrado TDE | Keystore + tablespace cifrado para datos sensibles | R-03 | A8.24*, A5.12 |
| T-05 | Enmascaramiento / redacción | `DBMS_REDACT` sobre columnas sensibles | R-01, R-04 | A8.11, A8.3 |
| T-06 | Respaldos | RMAN cifrado, retención, prueba de restauración | R-03 | A8.13 |
| T-07 | Auditoría | Políticas unificadas sobre datos sensibles y gestión de accesos | R-06 | A8.15, A5.33 |
| T-08 | Parcheo | Control de versión/parches, gestión de vulnerabilidades | R-02, R-03 | A8.8* |
| T-09 | Listener y red | Cifrado nativo de red, restricciones del listener | R-05 | A8.20, A8.21* |
| T-10 | Eliminación segura | Purga de recyclebin, `DELETE OBSOLETE`, baja de esquemas | R-03 | A8.10 |
| T-11 | Logs y monitoreo | Revisión de audit trail, reporte semanal, LogMiner | R-06 | A8.15, A8.16*, A5.33 |
| T-12 | Clones DEV/TEST | Copias con datos enmascarados, exportación controlada | R-04 | A8.11, A8.12, A8.33* |

`*` = control complementario fuera de la lista oficial.

### 5.4 Mapeo de los 15 controles oficiales → implementación → evidencia

| Control | Nombre (2022) | Implementación en Oracle | Evidencia observable (script V-xx) |
|---------|---------------|--------------------------|-----------------------------------|
| A5.12 | Clasificación de la información | Etiquetar columnas con `COMMENT ON COLUMN ... IS 'CLASIF:SENSIBLE'` y tabla de inventario | `SELECT owner, table_name, column_name, comments FROM dba_col_comments WHERE comments LIKE 'CLASIF:%';` |
| A5.15 | Control de acceso | Política escrita + roles por función | `SELECT grantee, granted_role FROM dba_role_privs WHERE grantee IN (SELECT username FROM dba_users WHERE oracle_maintained='N');` |
| A5.16 | Gestión de identidades | Cuentas nominales, bloqueo de inactivas | `SELECT username, account_status, created, last_login, profile FROM dba_users WHERE oracle_maintained='N';` |
| A5.17 | Información de autenticación | Perfil con función de verificación, sin contraseñas por defecto | `SELECT * FROM dba_users_with_defpwd;` y `SELECT profile, resource_name, limit FROM dba_profiles WHERE resource_type='PASSWORD';` |
| A5.18 | Derechos de acceso | Revisión periódica y revocación | `SELECT grantee, owner, table_name, privilege FROM dba_tab_privs WHERE owner='EMPRESA';` (comparar con matriz aprobada) |
| A5.33 | Protección de registros | Solo `AUDIT_ADMIN/AUDIT_VIEWER` a cuentas autorizadas | `SELECT grantee, granted_role FROM dba_role_privs WHERE granted_role IN ('AUDIT_ADMIN','AUDIT_VIEWER');` |
| A8.2 | Derechos de acceso privilegiado | Rol DBA y `ANY` solo a administradores | `SELECT grantee, privilege FROM dba_sys_privs WHERE privilege LIKE '%ANY%' AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained='N');` + `SELECT * FROM v$pwfile_users;` |
| A8.3 | Restricción de acceso a la información | Vistas + grants por columna; VPD (`DBMS_RLS`) por fila | `SELECT object_owner, object_name, policy_name, function FROM dba_policies;` |
| A8.5 | Autenticación segura | Bloqueo por intentos, versión de hash, `IDLE_TIME` | `SELECT username, password_versions FROM dba_users WHERE oracle_maintained='N';` + intentos fallidos en `unified_audit_trail` (`return_code=1017`) |
| A8.10 | Eliminación de la información | Purga controlada y retención de backups | `SELECT owner, original_name, droptime FROM dba_recyclebin;` + `RMAN> REPORT OBSOLETE;` |
| A8.11 | Enmascaramiento de datos | `DBMS_REDACT` en tarjeta, cédula, salario | `SELECT * FROM redaction_policies;` `SELECT * FROM redaction_columns;` + quién está exento: `SELECT grantee FROM dba_sys_privs WHERE privilege='EXEMPT REDACTION POLICY';` |
| A8.12 | Prevención de fuga de datos | Restringir roles de exportación, paquetes `UTL_*` a `PUBLIC`, auditar Data Pump, exportar cifrado | `SELECT grantee, table_name FROM dba_tab_privs WHERE grantee='PUBLIC' AND table_name IN ('UTL_FILE','UTL_HTTP','UTL_TCP','UTL_SMTP');` + `SELECT grantee FROM dba_role_privs WHERE granted_role LIKE '%EXP_FULL_DATABASE';` |
| A8.13 | Respaldo de la información | RMAN cifrado + prueba de restauración | `SELECT handle, encrypted, completion_time FROM v$backup_piece ORDER BY completion_time DESC;` + `RMAN> SHOW ALL;` |
| A8.15 | Registro (logging) | Políticas de auditoría unificada | `SELECT * FROM audit_unified_enabled_policies;` + `SELECT event_timestamp, dbusername, action_name, object_name, return_code FROM unified_audit_trail ORDER BY event_timestamp DESC FETCH FIRST 50 ROWS ONLY;` |
| A8.20 | Seguridad de redes | Cifrado nativo en `sqlnet.ora`, restricciones del listener | `SELECT network_service_banner FROM v$session_connect_info WHERE sid = SYS_CONTEXT('USERENV','SID');` + `lsnrctl status` |

Complementarios: **A8.24** → `SELECT con_id, wrl_type, status, wallet_type FROM v$encryption_wallet;` y `SELECT tablespace_name, encrypted FROM dba_tablespaces;` · **A8.8** → `SELECT banner_full FROM v$version;` y `SELECT patch_id, action, status, action_time FROM dba_registry_sqlpatch;` (XE no recibe parches de Oracle: documentarlo como limitación y riesgo aceptado, estado "Parcial").

### 5.5 Escala de madurez 0–4 (criterio de la matriz)

| Nivel | Nombre | Criterio verificable | Estado |
|-------|--------|----------------------|--------|
| 0 | Inexistente | No hay control ni documento | No cumple |
| 1 | Inicial | Se hace de forma ad hoc, sin documento ni evidencia repetible | No cumple |
| 2 | Documentado | Existe política/procedimiento, pero **no hay evidencia de ejecución** (el caso que mencionó el profesor) | Parcial |
| 3 | Implementado y verificado | Control configurado y **evidencia observable** que lo prueba (script V-xx pasa) | Cumple |
| 4 | Gestionado / automatizado | Además se monitorea periódicamente (job programado, reporte semanal) y hay mejora continua | Cumple |

Formato de la matriz [O]:
`Tarea | Riesgo | Control | Criterio 0-4 (antes → después) | Evidencia (archivo/consulta) | Estado`

### 5.6 Ejemplos de scripts clave

**Encabezado de evidencia (en cada script de verificación):**
```sql
-- V08_A8_2_privilegios.sql  |  ejecutar como SYSTEM en XEPDB1
SET LINESIZE 200 PAGESIZE 100 FEEDBACK ON
COLUMN fecha NEW_VALUE f NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD_HH24MI') fecha FROM dual;
SPOOL ../../evidencias/&fase/V08_A8_2_&f..txt
PROMPT === A8.2 Derechos de acceso privilegiado ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') pdb, USER usuario, SYSTIMESTAMP FROM dual;
SELECT grantee, granted_role FROM dba_role_privs
 WHERE granted_role = 'DBA'
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N');
SELECT grantee, privilege FROM dba_sys_privs
 WHERE privilege LIKE '%ANY%'
   AND grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N');
SPOOL OFF
```
(`&fase` = `antes` o `despues`, se define con `DEFINE fase = antes`.)

**Escenario inseguro (fragmento de `00_crear_escenario.sql`):**
```sql
ALTER SESSION SET CONTAINER = XEPDB1;
CREATE TABLESPACE ts_empresa DATAFILE 'C:\app\<usuario>\product\21c\oradata\XE\XEPDB1\ts_empresa01.dbf'
  SIZE 100M AUTOEXTEND ON;               -- ajusta la ruta a tu instalación
CREATE USER empresa IDENTIFIED BY "Empresa#2026" DEFAULT TABLESPACE ts_empresa
  QUOTA UNLIMITED ON ts_empresa;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO empresa;

CREATE TABLE empresa.clientes (
  id          NUMBER PRIMARY KEY,
  cedula      VARCHAR2(12),
  nombre      VARCHAR2(80),
  correo      VARCHAR2(80),
  salario     NUMBER(12,2),
  num_tarjeta VARCHAR2(16),
  sucursal    VARCHAR2(20)
);
INSERT INTO empresa.clientes
SELECT LEVEL, LPAD(TRUNC(DBMS_RANDOM.VALUE(100000000,799999999)),9,'0'),
       'Cliente '||LEVEL, 'cliente'||LEVEL||'@correo.test',
       ROUND(DBMS_RANDOM.VALUE(350000,2500000),2),
       '4' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0,999999999999999)),15,'0'),
       CASE MOD(LEVEL,3) WHEN 0 THEN 'HEREDIA' WHEN 1 THEN 'SAN JOSE' ELSE 'ALAJUELA' END
FROM dual CONNECT BY LEVEL <= 500;
COMMIT;

-- Malas prácticas deliberadas (estado "ANTES")
CREATE USER dev_juan IDENTIFIED BY juan123;        GRANT DBA TO dev_juan;
CREATE USER app_web  IDENTIFIED BY app;            GRANT CREATE SESSION, SELECT ANY TABLE TO app_web;
CREATE USER ex_empleado IDENTIFIED BY temporal;    GRANT CREATE SESSION TO ex_empleado;
GRANT SELECT ON empresa.clientes TO PUBLIC;
```

**Remediación (fragmentos):**
```sql
-- A8.2 / A5.15 / A5.18
REVOKE DBA FROM dev_juan;
REVOKE SELECT ANY TABLE FROM app_web;
REVOKE SELECT ON empresa.clientes FROM PUBLIC;
ALTER USER ex_empleado ACCOUNT LOCK;
CREATE ROLE rol_rrhh;      GRANT SELECT ON empresa.clientes TO rol_rrhh;
CREATE ROLE rol_soporte;   GRANT SELECT ON empresa.clientes TO rol_soporte;  -- verá datos redactados

-- A5.17 / A8.5 (si la función no existe: @?/rdbms/admin/utlpwdmg.sql)
CREATE PROFILE perfil_usuarios LIMIT
  FAILED_LOGIN_ATTEMPTS 5  PASSWORD_LOCK_TIME 1/24
  PASSWORD_LIFE_TIME 90    PASSWORD_GRACE_TIME 7
  PASSWORD_REUSE_MAX 5     PASSWORD_REUSE_TIME 365
  IDLE_TIME 15             SESSIONS_PER_USER 3
  PASSWORD_VERIFY_FUNCTION ora12c_verify_function;
ALTER USER dev_juan PROFILE perfil_usuarios;
ALTER USER app_web  PROFILE perfil_usuarios;

-- A8.11 Redacción: quien NO tenga rol_rrhh ve datos ocultos
BEGIN
  DBMS_REDACT.ADD_POLICY(
    object_schema       => 'EMPRESA',
    object_name         => 'CLIENTES',
    policy_name         => 'RED_CLIENTES',
    column_name         => 'NUM_TARJETA',
    function_type       => DBMS_REDACT.PARTIAL,
    function_parameters => 'VVVVVVVVVVVVVVVV,VVVVVVVVVVVVVVVV,*,1,12',
    expression          => 'SYS_CONTEXT(''SYS_SESSION_ROLES'',''ROL_RRHH'') = ''FALSE''');
  DBMS_REDACT.ALTER_POLICY(
    object_schema => 'EMPRESA', object_name => 'CLIENTES', policy_name => 'RED_CLIENTES',
    action        => DBMS_REDACT.ADD_COLUMN,
    column_name   => 'SALARIO',
    function_type => DBMS_REDACT.FULL);
END;
/

-- A8.15 / A5.33 Auditoría unificada
CREATE AUDIT POLICY pol_conf_datos_sensibles
  ACTIONS SELECT ON empresa.clientes, UPDATE ON empresa.clientes, DELETE ON empresa.clientes;
CREATE AUDIT POLICY pol_conf_gestion_accesos
  ACTIONS CREATE USER, ALTER USER, DROP USER, CREATE ROLE, DROP ROLE, GRANT, REVOKE;
CREATE AUDIT POLICY pol_conf_exportaciones ACTIONS COMPONENT = DATAPUMP EXPORT;
AUDIT POLICY pol_conf_datos_sensibles;
AUDIT POLICY pol_conf_gestion_accesos;
AUDIT POLICY pol_conf_exportaciones;
```

**TDE (R-CONF-03) — hacerlo en la semana 4, con respaldo previo:**
```sql
-- Como SYS en CDB$ROOT
ALTER SYSTEM SET WALLET_ROOT = 'C:\app\<usuario>\admin\XE\wallet' SCOPE = SPFILE;  -- crea la carpeta antes
SHUTDOWN IMMEDIATE
STARTUP
ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=FILE' SCOPE = BOTH;
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY "<clave_keystore>";
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "<clave_keystore>" CONTAINER = ALL;
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "<clave_keystore>" WITH BACKUP CONTAINER = ALL;
SELECT con_id, wrl_type, status, wallet_type FROM v$encryption_wallet;   -- evidencia

-- En XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;
CREATE TABLESPACE ts_sensible
  DATAFILE 'C:\app\<usuario>\product\21c\oradata\XE\XEPDB1\ts_sensible01.dbf' SIZE 50M
  ENCRYPTION USING 'AES256' ENCRYPT;
ALTER TABLE empresa.clientes MOVE TABLESPACE ts_sensible;
ALTER INDEX empresa.<nombre_pk> REBUILD;                                  -- consulta el nombre en dba_indexes
SELECT tablespace_name, encrypted FROM dba_tablespaces;                  -- evidencia
```
> ⚠️ Respalda la carpeta del keystore y anota la clave en un lugar seguro: **sin keystore no hay datos**. Después de cada reinicio debes abrir el keystore (`SET KEYSTORE OPEN ... CONTAINER=ALL`) o crear uno auto-login. Si `STATUS` en la PDB queda `OPEN_NO_MASTER_KEY`, ejecuta `SET KEY` dentro de `XEPDB1`.

**Red (A8.20) — en `sqlnet.ora` del servidor** (en 21c puede estar en `...\homes\OraDB21Home1\network\admin`):
```
SQLNET.ENCRYPTION_SERVER = REQUIRED
SQLNET.ENCRYPTION_TYPES_SERVER = (AES256)
SQLNET.CRYPTO_CHECKSUM_SERVER = REQUIRED
SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER = (SHA256)
```

**Backup cifrado (A8.13)** — en RMAN, conectado al CDB:
```
CONFIGURE ENCRYPTION FOR DATABASE ON;      -- usa el keystore TDE
BACKUP TABLESPACE xepdb1:ts_sensible;
```

**Reporte semanal [N] (`04_reportes/R01_reporte_semanal.sql`):**
```sql
-- Accesos fallidos / no autorizados de los últimos 7 días
SELECT dbusername, action_name, object_schema, object_name, return_code, COUNT(*) intentos
  FROM unified_audit_trail
 WHERE event_timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
   AND return_code <> 0
 GROUP BY dbusername, action_name, object_schema, object_name, return_code
 ORDER BY intentos DESC;
-- Cambios de privilegios de la semana
SELECT event_timestamp, dbusername, action_name, sql_text
  FROM unified_audit_trail
 WHERE event_timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
   AND action_name IN ('GRANT','REVOKE','CREATE USER','ALTER USER','DROP USER')
 ORDER BY event_timestamp;
```
Programarlo con `DBMS_SCHEDULER` (guardando el resultado en una tabla `SEC_REPORTE_SEMANAL`) es la evidencia para subir controles a **nivel 4**.

---

## 6. Plan de trabajo priorizado

### 6.1 Hitos

| Hito | Fecha | Qué debe existir |
|------|-------|------------------|
| **H0 – Avance 1** | **Jue 22 oct** | Contexto, riesgos R-CONF, 12 tareas, borrador de mapeo de 15 controles, escala 0-4, repo creado, 4–6 scripts de verificación corriendo con evidencia "antes", tabla de IA iniciada |
| H1 – Versión completa mínima | Jue 29 oct | Los 6 componentes del artefacto en borrador + marco teórico + V01–V15 completos (evidencia "antes") |
| H2 – Remediación de accesos | Jue 5 nov | Usuarios, roles, perfiles, auditoría, redacción aplicados |
| H3 – Cifrado y red | Jue 12 nov | TDE, RMAN cifrado, Data Pump cifrado, red cifrada |
| H4 – Verificación | Jue 19 nov | Evidencia "después", batería de pruebas ejecutada, matriz final, riesgo residual |
| H5 – Artefacto final | Jue 26 nov | React pulido, PDF, IA + declaración, APA 7, revisión con 2 IAs |
| **H6 – Entrega final** | **Dom 29 nov** | Video, repo etiquetado `v1.0`, PDF, scripts, tabla IA firmada |

### 6.2 Detalle por semana

#### Semana 0 — Preparar el avance (lun 19 → jue 22 oct) — **PRIORIDAD MÁXIMA**

| Día | Tarea | Depende de | Entregable |
|-----|-------|------------|------------|
| Lun 19 | Leer este plan; anotar preguntas para el profesor; crear repo y estructura de carpetas; iniciar `docs/uso-ia.md` con la primera fila (este plan) | — | Repo con estructura |
| Mar 20 | Definir escenario/empresa ficticia y clasificación de datos; escribir tabla R-CONF (P, I, nivel); escribir tabla T-01..T-12 | Lun | `src/data/riesgos.json`, `tareas.json` (o en Markdown) |
| Mar 20 | Encender Oracle, correr `00_crear_escenario.sql` en XEPDB1; correr V-scripts de A8.2, A5.16, A5.17, A5.18, A8.15 y la consulta de `v$encryption_wallet` con fase=antes | — | `evidencias/antes/*.txt` + capturas |
| Mié 21 | Borrador del mapeo de los 15 controles (tabla 5.4 con tus palabras); escala 0-4; primer esbozo de matriz con estado "antes" | Mar | `controles.json`, `matriz.json` |
| Mié 21 | Esqueleto React (Vite) con 3 pestañas: Contexto, Riesgos, Mapeo. *Plan B: un HTML o PDF simple con las mismas tablas* | Mar | Artefacto v0.1 |
| Mié 21 | Ensayar explicación de 3–5 min: problema → riesgos → controles → cómo lo voy a verificar (antes/después) | Todo lo anterior | Guion corto |
| **Jue 22** | **Presentar avance**; hacer las preguntas al profesor (sección 9) | — | Notas de retroalimentación |

**Qué presentar el 22 (lista de chequeo):**
- [ ] Contexto de la organización y clasificación de datos
- [ ] Tabla R-CONF-01..05 (+06) con P, I y nivel
- [ ] Tabla de 12 tareas del DBA vinculadas a riesgos
- [ ] Mapeo borrador de los 15 controles (control → implementación → consulta de evidencia)
- [ ] Escala de madurez 0–4 y estructura de la matriz
- [ ] Evidencia real de 4–6 consultas corriendo en tu Oracle (estado "antes")
- [ ] Enlace al repo y vista del artefacto (aunque sea v0.1)
- [ ] Tabla de uso de IA iniciada
- [ ] Metodología PHVA explicada en una diapositiva/sección

#### Semana 1 — Planificar completo (vie 23 → jue 29 oct)
- Marco teórico de 2–3 páginas (O-8), con referencias APA 7 desde el inicio.
- Completar V01–V15 (+ complementarios) y correrlos todos en fase "antes".
- Matriz completa con nivel "antes" de cada control.
- Batería de pruebas **diseñada** (tabla), aunque aún no ejecutada.
- Sección "Ley 8968" y relación con Ley 8292/SEVRI (1 párrafo cada una).
- Artefacto: todas las secciones existen (aunque sea con datos borrador).
- **Resultado: H1, versión entregable si la fecha final fuera el 29/10.**

#### Semana 2 — Hacer: accesos (vie 30 oct → jue 5 nov)
- Remediación: revocar, roles por función, bloqueo de cuentas, perfiles, `PUBLIC` limpio.
- Auditoría unificada (3 políticas) y prueba de que registra.
- Redacción sobre tarjeta/salario/cédula; VPD por sucursal (opcional: si `DBMS_RLS` da error en XE, usar vistas + grants y documentarlo).
- Clasificación con `COMMENT ON COLUMN`.
- Commits por cada control remediado.

#### Semana 3 — Hacer: cifrado y red (vie 6 → jue 12 nov)
- **Antes de tocar nada: backup RMAN completo** (y prueba `PRUEBA-TDE-00`: buscar un nombre de cliente dentro de una copia del backup sin cifrar con `findstr` → aparece).
- TDE (keystore + tablespace cifrado + mover tabla) → repetir búsqueda en backup nuevo → **no aparece**.
- RMAN cifrado, retención y `DELETE OBSOLETE`; purga de recyclebin.
- Data Pump con `ENCRYPTION=ALL` y auditoría de exportación.
- `sqlnet.ora` cifrado de red + evidencia del banner.
- A8.8: documentar versión y limitación de parches en XE.

#### Semana 4 — Verificar y Actuar (vie 13 → jue 19 nov)
- Correr todos los V-xx en fase "después".
- Ejecutar batería de pruebas completa y guardar resultados.
- Matriz final con niveles antes→después y estado.
- Riesgo residual por R-CONF y **plan de mejora** (ACTUAR): lo que queda en nivel 2–3 y por qué.
- Reporte semanal + job `DBMS_SCHEDULER` (nivel 4).
- Opcional "excede": demo de LogMiner para trazabilidad forense.

#### Semana 5 — Artefacto final (vie 20 → jue 26 nov)
- Pulir React: navegación, tablas filtrables, mapa de calor de riesgos, visor de evidencias (capturas).
- Hoja de estilos de impresión → **Informe PDF** (texto en negro).
- Tabla de IA completa + **Declaración Jurada firmada**.
- Referencias APA 7.
- Revisión cruzada con **2 IAs** [N] (registrar ambas en la tabla) y corregir.
- Revisión propia de originalidad: todo redactado con tus palabras.

#### Cierre (vie 27 → dom 29 nov)
- Grabar video de 5 min (guion en sección 8).
- README del repo, tag `v1.0`, verificar que cada script corre desde cero.
- Entregar los 5 entregables (O-13).

### 6.3 Si el profesor confirma entrega final el 29/10
Compresión: Semana 1 se convierte en "Planificar + Hacer accesos + Verificar". Se omiten TDE en vivo y red (se documentan como implementación propuesta con script listo y nivel 2 "documentado"), se ejecutan solo pruebas de accesos, redacción y auditoría, y el artefacto queda en HTML simple o PDF.

---

## 7. Guía de implementación paso a paso

1. **Iniciar Oracle**: iniciar servicios `OracleServiceXE` y `OracleOraDB21Home1TNSListener`.
2. **Conectarse** en SQL Developer como `SYS AS SYSDBA` al servicio `XEPDB1` (o `ALTER SESSION SET CONTAINER = XEPDB1`).
3. **Crear escenario**: `sql/00_escenario/00_crear_escenario.sql`.
4. **Diagnóstico ANTES**: `DEFINE fase = antes` y ejecutar `sql/01_verificacion/V00_ejecutar_todo.sql` (llama a V01..V15).
5. **Llenar matriz "antes"** con la salida.
6. **Remediar** por bloques (`sql/02_remediacion/R01..R15`), un commit por bloque.
7. **Backup** antes de TDE; aplicar TDE, RMAN cifrado, red.
8. **Diagnóstico DESPUÉS**: `DEFINE fase = despues`, ejecutar `V00_ejecutar_todo.sql`.
9. **Pruebas**: `sql/03_pruebas/P01..` (conectarse con los usuarios de prueba según indique cada prueba).
10. **Reporte semanal**: `sql/04_reportes/R01_reporte_semanal.sql` + job.
11. **Cargar resultados** en los JSON del artefacto y capturas en `artefacto/public/evidencias/`.
12. **Generar PDF** desde el artefacto y grabar video.

**Estructura del artefacto (secciones):**
1. Portada y contexto (organización, datos, clasificación)
2. Metodología PHVA
3. Marco teórico (resumen; documento completo en PDF)
4. Riesgos R-CONF (tabla + mapa de calor P×I, inherente vs residual)
5. Tareas del DBA
6. Mapeo de controles ISO → implementación → evidencia
7. 15 controles observables por auditor externo
8. Matriz de evaluación (filtros por riesgo/control/estado)
9. Batería de pruebas y resultados
10. Evidencias (antes/después)
11. Plan de mejora y riesgo residual
12. Uso de IA + Declaración Jurada
13. Referencias APA 7

---

## 8. Plan de pruebas

### 8.1 Batería (formato oficial: ID | Tipo | Procedimiento | Resultado esperado | Herramienta)

| ID | Tipo | Procedimiento | Resultado esperado | Herramienta |
|----|------|---------------|--------------------|-------------|
| PT-01 | Mínimo privilegio (negativa) | Conectar como `app_web` y `SELECT * FROM empresa.clientes` tras remediación | `ORA-00942` / `ORA-01031` | SQL Developer |
| PT-02 | Privilegio (positiva) | Usuario con `rol_rrhh` consulta clientes | Filas visibles sin redacción | SQL Developer |
| PT-03 | Redacción | Usuario con `rol_soporte` consulta `num_tarjeta, salario` | `************1234` y salario `0` | SQL Developer |
| PT-04 | Exención | Listar quién tiene `EXEMPT REDACTION POLICY` | Solo cuentas autorizadas | V-A8.11 |
| PT-05 | Bloqueo de cuenta | 5 contraseñas erróneas con `dev_juan` | `ORA-28000` cuenta bloqueada | SQL*Plus |
| PT-06 | Complejidad | `ALTER USER dev_juan IDENTIFIED BY abc` | `ORA-28003` (falla verificación) | SQL*Plus |
| PT-07 | Inactividad | Sesión inactiva > `IDLE_TIME` y ejecutar consulta | `ORA-02396` | SQL*Plus |
| PT-08 | Cuentas por defecto | `SELECT * FROM dba_users_with_defpwd` filtrando cuentas abiertas | 0 cuentas abiertas con contraseña por defecto | V-A5.17 |
| PT-09 | Cuenta huérfana | Conectar como `ex_empleado` | `ORA-28000` | SQL*Plus |
| PT-10 | PUBLIC | Grants a `PUBLIC` sobre esquema EMPRESA y paquetes `UTL_*` | 0 filas | V-A8.12 |
| PT-11 | Auditoría de acceso | `SELECT` sobre clientes y luego consultar `unified_audit_trail` | Registro con usuario, hora, objeto | V-A8.15 |
| PT-12 | Auditoría de privilegios | `GRANT` de prueba y consultar trail | Registro de `GRANT` | V-A8.15 |
| PT-13 | Protección de registros | Usuario sin `AUDIT_VIEWER` consulta `unified_audit_trail` | `ORA-00942` | SQL Developer |
| PT-14 | TDE | `v$encryption_wallet` y `dba_tablespaces` | `OPEN` y `ENCRYPTED = YES` | V-A8.24 |
| PT-15 | TDE observable | Buscar un nombre de cliente en copia de backup antes y después (`findstr /c:"Cliente 17"`) | Antes: aparece; después: no aparece | PowerShell / cmd |
| PT-16 | Backup cifrado | `v$backup_piece` | `ENCRYPTED = YES` en piezas nuevas | V-A8.13 |
| PT-17 | Restauración | `RESTORE TABLESPACE ... VALIDATE` en RMAN | Validación exitosa | RMAN |
| PT-18 | Exportación | `expdp` sin `DATAPUMP_EXP_FULL_DATABASE` | Falla por privilegios; intento auditado | expdp |
| PT-19 | Red | Banner de la sesión | Aparece adaptador de cifrado AES256 | V-A8.20 |
| PT-20 | Eliminación | Purgar recyclebin y consultar | 0 objetos de EMPRESA en recyclebin | V-A8.10 |
| PT-21 | Clasificación | Consultar comentarios `CLASIF:` | Todas las columnas sensibles etiquetadas | V-A5.12 |
| PT-22 | Reporte semanal | Ejecutar reporte tras intentos fallidos | Aparecen los intentos de PT-05/PT-09 | R01 |

### 8.2 Reglas de evidencia
- Cada prueba guarda: script, salida `SPOOL` con fecha/usuario/PDB, captura de pantalla.
- Nombres: `evidencias/despues/PT-05_20261115_2130.txt`.
- La matriz referencia el archivo exacto de evidencia.

### 8.3 Guion del video (5 min)
| Tiempo | Contenido |
|---|---|
| 0:00–0:30 | Problema y contexto de la organización |
| 0:30–1:15 | Riesgos R-CONF y mapa de calor |
| 1:15–2:00 | Mapeo ISO y metodología PHVA |
| 2:00–3:45 | Demo antes/después: privilegios (PT-01), redacción (PT-03), TDE (PT-15), auditoría (PT-11) |
| 3:45–4:30 | Matriz de madurez y riesgo residual |
| 4:30–5:00 | Uso de IA, conclusiones |

---

## 9. Estructura del repositorio

```
iso27001-confidencialidad-oracle/
├── README.md                     # cómo correr todo desde cero
├── PLAN_ACCION.md
├── docs/
│   ├── marco-teorico.md
│   ├── contexto-organizacion.md
│   ├── metodologia-phva.md
│   ├── uso-ia.md                 # tabla de IA + declaración jurada
│   ├── referencias-apa7.md
│   ├── preguntas-profesor.md
│   └── guion-video.md
├── sql/
│   ├── 00_escenario/
│   │   ├── 00_crear_escenario.sql
│   │   └── 99_limpiar_escenario.sql
│   ├── 01_verificacion/
│   │   ├── V00_ejecutar_todo.sql
│   │   ├── V01_A5_12_clasificacion.sql
│   │   ├── V02_A5_15_control_acceso.sql
│   │   ├── ...                   # uno por control
│   │   └── V15_A8_20_red.sql
│   ├── 02_remediacion/
│   │   ├── R01_privilegios_roles.sql
│   │   ├── R02_perfiles.sql
│   │   ├── R03_auditoria.sql
│   │   ├── R04_redaccion_vpd.sql
│   │   ├── R05_tde.sql
│   │   ├── R06_rman_cifrado.rman
│   │   └── R07_sqlnet_ora.txt
│   ├── 03_pruebas/
│   │   └── PT01..PT22.sql
│   └── 04_reportes/
│       ├── R01_reporte_semanal.sql
│       └── R02_job_scheduler.sql
├── evidencias/
│   ├── antes/
│   └── despues/
├── artefacto/                    # React + Vite
│   ├── public/evidencias/        # capturas
│   └── src/
│       ├── data/                 # riesgos.json, tareas.json, controles.json,
│       │                         # matriz.json, pruebas.json, ia.json
│       ├── components/
│       └── App.jsx
└── entregables/
    ├── Informe_ISO27001_Confidencialidad.pdf
    └── enlace_video.txt
```

**Convención de commits:** `avance1: tabla de riesgos`, `verif: V08 A8.2`, `remed: perfiles`, etc. Commits frecuentes también demuestran autoría individual.

---

## 10. Preguntas para aclarar con el profesor (llevar el 22/10)

1. ¿La entrega final es el **29 de octubre** o el **29 de noviembre**? ¿Hay más avances intermedios y qué se espera en cada uno?
2. ¿Qué formato tiene el avance del 22/10 (exposición, revisión en máquina, documento)? ¿Cuánto tiempo?
3. ¿Qué **escala** de probabilidad e impacto quiere (1–5, 1–4)? ¿El "4 → 2" de la pizarra significa reducir el riesgo inherente a un residual meta?
4. ¿Debo limitarme a los **15 controles listados** o puedo agregar complementarios (A8.24 cifrado, A8.8 parcheo, A8.16 monitoreo, A8.31/A8.33 entornos de prueba)?
5. En clase se mencionaron controles "8.1, 9.2, 9.5, 9.7, 10.1": ¿corresponden a otra numeración o manda la lista del documento?
6. ¿El artefacto debe ser obligatoriamente React o vale HTML/PDF? ¿Debe conectarse en vivo a la BD o basta con evidencia capturada?
7. ¿Se aceptan como evidencia salidas `SPOOL` y capturas, o quiere demostración en vivo?
8. ¿Cuál es el **repositorio Git institucional** (plataforma/URL)? ¿Público o privado con acceso para él?
9. Video: ¿dónde se sube, debe mostrar la demo técnica, debe aparecer el estudiante?
10. ¿Es obligatorio incluir la sección de **Ley 8292 / SEVRI** y un reporte de administración de riesgos?
11. "Usar 2 IAs para revisión": ¿ambas deben aparecer en la tabla de IA?
12. ¿Vale Oracle 21c XE local (sin parches disponibles) o se espera 19c?
13. Como no tenemos acceso al texto pagado de ISO 27002, ¿qué fuente oficial se acepta para citar los controles?
14. ¿El 7 mínimo "probado con IA" aplica también a este proyecto?

---

## 11. Riesgos del propio proyecto y cómo evitarlos

| Riesgo | Mitigación |
|---|---|
| Perder la BD por TDE mal configurado | Backup RMAN completo antes; respaldar keystore y clave; hacerlo en semana 3, no al final |
| Poco tiempo por otros cursos | Prioridad absoluta a H0 y H1; React solo después de tener las tablas |
| Similitud en Turnitin | Escenario propio, redacción propia, declarar toda IA |
| Scripts que no corren en limpio | `99_limpiar_escenario.sql` + probar `V00_ejecutar_todo.sql` desde cero antes de entregar |
| Sobre-ingeniería del artefacto | Sin backend; JSON + componentes simples; plan B HTML/PDF |

---

## 12. Primeras 10 acciones (en orden)

1. Leer este plan completo y marcar dudas.
2. Escribir las preguntas de la sección 10 en `docs/preguntas-profesor.md`.
3. Crear el repositorio y la estructura de carpetas; primer commit.
4. Registrar en `docs/uso-ia.md` la primera fila: Claude, el prompt exacto que usaste, aporte (plan y borradores), y cómo lo validarás.
5. Decidir tu organización ficticia y su clasificación de datos.
6. Redactar la tabla R-CONF con tus palabras y valores.
7. Redactar la tabla T-01..T-12.
8. Iniciar Oracle, crear el escenario inseguro y correr 4–6 verificaciones "antes" con SPOOL + captura.
9. Pasar el mapeo de 15 controles a tus palabras y armar la estructura de la matriz.
10. Montar la vista mínima (React o HTML) con Contexto, Riesgos y Mapeo, y ensayar la explicación para el jueves.
