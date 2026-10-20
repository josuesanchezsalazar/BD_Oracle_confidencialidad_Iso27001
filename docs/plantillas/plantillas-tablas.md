# Plantillas de las tablas base

> Esqueletos generados con IA (ver `docs/uso-ia.md`). **Los valores, descripciones y justificaciones se redactan a mano** en `docs/01-riesgos.md`, `docs/02-tareas-dba.md`, `docs/03-mapeo-controles.md` y `docs/04-matriz-evaluacion.md`. `*` = control complementario fuera de la lista oficial.

---

## 1. Tabla de riesgos R-CONF

**Escala:** Probabilidad (P) 1–5 × Impacto (I) 1–5 = Nivel. Bandas: 1–4 Bajo · 5–9 Medio · 10–14 Alto · 15–25 Crítico. _(confirmar con el profesor)_

| ID | Riesgo | Causa / vector | Activo afectado | P | Justificación P | I | Justificación I | Nivel inherente | Meta residual |
|----|--------|----------------|-----------------|---|-----------------|---|-----------------|-----------------|---------------|
| R-CONF-01 | | | | | | | | | |
| R-CONF-02 | | | | | | | | | |
| R-CONF-03 | | | | | | | | | |
| R-CONF-04 | | | | | | | | | |
| R-CONF-05 | | | | | | | | | |
| R-CONF-06 _(opcional)_ | | | | | | | | | |

**Mapa de calor (marcar cada R-CONF en su celda):**

| P \ I | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| **5** | | | | | |
| **4** | | | | | |
| **3** | | | | | |
| **2** | | | | | |
| **1** | | | | | |

---

## 2. Tabla de tareas del DBA (12 obligatorias)

| ID | Tarea | Descripción operativa (qué hace el DBA) | Riesgo(s) R-CONF | Control(es) ISO | Script(s) relacionados |
|----|-------|-----------------------------------------|------------------|-----------------|------------------------|
| T-01 | Gestión de usuarios | | | | V03 |
| T-02 | Privilegios y roles | | | | V02, V05, V07 |
| T-03 | Autenticación | | | | V04, V09 |
| T-04 | Cifrado TDE | | | | V16 |
| T-05 | Masking / redacción | | | | V11 |
| T-06 | Backup | | | | V13 |
| T-07 | Auditoría | | | | V06, V14 |
| T-08 | Parcheo | | | | V17 |
| T-09 | Listener | | | | V15 |
| T-10 | Eliminación segura | | | | V10 |
| T-11 | Logs | | | | V14 |
| T-12 | Clones DEV/TEST | | | | V11, V12 |

---

## 3. Mapeo de controles ISO → Oracle → evidencia

| Control | Nombre 2022 | Qué exige (parafraseado) | Riesgo que mitiga | Implementación en Oracle | Evidencia observable | Script | Tipo (P/D/C) |
|---------|-------------|--------------------------|-------------------|--------------------------|----------------------|--------|--------------|
| A5.12 | Clasificación de la información | | | | | V01 | |
| A5.15 | Control de acceso | | | | | V02 | |
| A5.16 | Gestión de identidades | | | | | V03 | |
| A5.17 | Información de autenticación | | | | | V04 | |
| A5.18 | Derechos de acceso | | | | | V05 | |
| A5.33 | Protección de registros | | | | | V06 | |
| A8.2 | Derechos de acceso privilegiado | | | | | V07 | |
| A8.3 | Restricción de acceso a la información | | | | | V08 | |
| A8.5 | Autenticación segura | | | | | V09 | |
| A8.10 | Eliminación de la información | | | | | V10 | |
| A8.11 | Enmascaramiento de datos | | | | | V11 | |
| A8.12 | Prevención de fuga de datos | | | | | V12 | |
| A8.13 | Respaldo de la información | | | | | V13 | |
| A8.15 | Registro | | | | | V14 | |
| A8.20 | Seguridad de redes | | | | | V15 | |
| A8.24* | Uso de criptografía | | | | | V16 | |
| A8.8* | Gestión de vulnerabilidades técnicas | | | | | V17 | |

---

## 4. Matriz de evaluación

**Escala de madurez:** 0 Inexistente · 1 Inicial · 2 Documentado · 3 Implementado y verificado · 4 Gestionado.
**Estado:** 0–1 = No cumple · 2 = Parcial · 3–4 = Cumple.

| Tarea | Riesgo | Control | Criterio 0-4 (antes → después) | Evidencia (archivo / consulta) | Estado |
|-------|--------|---------|--------------------------------|--------------------------------|--------|
| T-01 | | | → | `evidencias/antes/V03_A5_16_*.txt` | |
| | | | → | | |

---

## 5. Batería de pruebas

| ID | Tipo | Procedimiento | Resultado esperado | Herramienta | Resultado obtenido | Evidencia |
|----|------|---------------|--------------------|-------------|--------------------|-----------|
| PT-01 | Mínimo privilegio (negativa) | | | SQL Developer | | |
| PT-02 | | | | | | |
