# Contexto de la organización — Centro Médico Los Robles

> ✍️ **Pendiente de redactar por el estudiante:** la descripción de la sección 1 y la justificación de la columna de alta sensibilidad. Las tablas de abajo reflejan el escenario implementado en `sql/00_escenario/00_crear_escenario.sql`.

## 1. Organización
- **Nombre:** Centro Médico Los Robles (ficticio)
- **Sector:** salud, clínica privada
- **Ubicación:** Heredia, Costa Rica
- **Servicios:** Medicina General, Pediatría y Cardiología (6 médicos)
- **Volumen:** 500 pacientes registrados, ~2000 consultas desde 2024
- **Descripción:** _(2–3 líneas con tus palabras: qué hace la clínica y por qué la confidencialidad de su base de datos es crítica)_
- **Marco legal:** Ley 8968 (los datos de salud son **datos sensibles**). Si fuera un centro de la CCSS aplicarían además la Ley 8292 y el SEVRI.

## 2. Datos personales (esquema `CLINICA`, PDB `XEPDB1`)

| Tabla | Columna | Clasificación | Categoría Ley 8968 |
|-------|---------|---------------|--------------------|
| PACIENTES | cedula, fecha_nac, telefono, correo, direccion | Restringido | Acceso restringido |
| PACIENTES | nombre, sexo | Interno | Acceso restringido |
| CONSULTAS | **diagnostico**, tratamiento, notas_medicas, motivo | **Sensible** | **Dato sensible (salud)** |
| FACTURAS | num_tarjeta, poliza_seguro | Restringido | Acceso restringido |
| FACTURAS | monto, metodo_pago, aseguradora | Interno | — |
| CITAS | fecha_hora, estado | Interno | — |
| MEDICOS | nombre, especialidad, codigo_colegiado | Público | Acceso irrestricto |

⭐ **Columna de alta sensibilidad:** `CLINICA.CONSULTAS.DIAGNOSTICO`. _Justificación con tus palabras: (por ejemplo, revela condiciones como VIH, depresión o ansiedad, cuya divulgación causa discriminación…)._

## 3. Actores y cuentas

| Actor | Cuenta | Debe ver / hacer | NO debe ver |
|-------|--------|------------------|-------------|
| DBA | `SYS` (después: cuenta nominal de DBA) | Administración | Diagnósticos (ideal) |
| Desarrollador | `DEV_CARLOS` | Esquema en DEV con datos enmascarados | Datos reales de producción |
| Aplicación de citas | `APP_CITAS` | PACIENTES (contacto) y CITAS | Diagnósticos, tarjetas |
| Médicos | `MED_LSOLIS`, `MED_EVARGAS` | Consultas de **sus** pacientes | Consultas de pacientes de otros médicos |
| Recepción | `RECEPCION` (compartida → nominales) | Datos de contacto y citas | Diagnóstico, tarjeta |
| Facturación | `FACT_ANA` | Facturas (tarjeta parcial) | Diagnósticos |
| Soporte TI | `SOPORTE_TI` | Operación técnica | Exportar toda la BD |
| Auditor externo | `AUDITOR_EXT` | Leer el rastro de auditoría | Administrar o purgar la auditoría |
| Ex-empleada | `EX_MROJAS` | Nada (renunció) | Todo |

## 4. Malas prácticas iniciales (estado "ANTES")

| ID | Mala práctica | Riesgo | Control |
|----|---------------|--------|---------|
| MP-01 | `DEV_CARLOS` tiene rol `DBA` y contraseña débil | R-CONF-01 | A8.2 |
| MP-02 | `APP_CITAS` tiene `SELECT ANY TABLE` | R-CONF-01 | A8.2, A5.15 |
| MP-03 | `SELECT` sobre `CONSULTAS` otorgado a `PUBLIC` | R-CONF-01 | A5.15, A5.18, A8.3 |
| MP-04 | Cuenta compartida `RECEPCION` con grants directos excesivos (ve facturas) | R-CONF-02 | A5.16, A5.15 |
| MP-05 | Cuenta de la ex-empleada `EX_MROJAS` activa | R-CONF-02 | A5.16 |
| MP-06 | `FACT_ANA` puede re-otorgar (`WITH GRANT OPTION`) | R-CONF-01 | A5.18 |
| MP-07 | Médicos ven consultas de todos los pacientes (sin VPD) | R-CONF-01 | A8.3 |
| MP-08 | `AUDITOR_EXT` tiene `AUDIT_ADMIN` (puede purgar el rastro) | R-CONF-06 | A5.33 |
| MP-09 | `SOPORTE_TI` con `DATAPUMP_EXP_FULL_DATABASE`; directorio de exportación abierto a `PUBLIC` | R-CONF-04 | A8.12 |
| MP-10 | Copia de pacientes "borrada" que sigue en la papelera | R-CONF-03 | A8.10 |
| MP-11 | Clon `CLINICA_DEV` con datos reales sin enmascarar | R-CONF-04 | A8.11, A8.33* |
| MP-12 | `PERFIL_APLICACIONES` sin límite de intentos fallidos | R-CONF-02 | A8.5, A5.17 |
| — | Sin clasificación, auditoría propia, redacción, TDE ni cifrado de red | Varios | A5.12, A8.15, A8.11, A8.24*, A8.20 |

**Hallazgos reales del diagnóstico (no sembrados):**
- `SYS` usa una contraseña débil (A5.17).
- `DEV_CARLOS` y `SOPORTE_TI` quedan **exentos de redacción** heredando `EXEMPT REDACTION POLICY` del rol `EXP_FULL_DATABASE` (A8.11). Ver `evidencias/antes/V11_*`.
- El perfil `DEFAULT` no tiene `PASSWORD_VERIFY_FUNCTION` (A5.17). Ver `evidencias/antes/V04_*`.
