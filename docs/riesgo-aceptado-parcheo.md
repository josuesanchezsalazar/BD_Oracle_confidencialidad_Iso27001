# Riesgo aceptado: parcheo del motor Oracle 21c XE (A8.8*)

> **Borrador para revisión del estudiante.** La decisión de aceptar el riesgo, el responsable y la fecha de revisión son propuestas; se confirman antes de citar este documento en el informe.

## Hallazgo

| Dato | Valor | Evidencia |
|---|---|---|
| Motor | Oracle Database 21c Express Edition, versión 21.3.0.0.0 | `evidencias/despues/V17_A8_8_20261027_0757.txt`, sección 1 |
| Parches SQL aplicados | Ninguno (consulta sin filas) | Mismo archivo, sección 2 |

## Por qué no se aplica el control completo

Oracle Database XE no recibe Release Updates trimestrales (Critical Patch Updates): la versión se actualiza solo cuando Oracle publica una versión XE nueva. El instituto no puede, por tanto, cumplir el requisito de A8.8 de corregir las vulnerabilidades técnicas conocidas dentro de un plazo definido mediante parches del proveedor.

## Decisión propuesta

Aceptar el riesgo residual del parcheo y compensarlo con controles que sí están implementados y medidos:

| Compensación | Control | Evidencia |
|---|---|---|
| Listener escucha solo en 127.0.0.1 (reduce la exposición de red) | A8.21* | `P03_PT29_listener_*.txt` |
| Cuentas nominales, mínimo privilegio y revocación a `PUBLIC` | A5.15, A8.2, A8.3 | V02, V07, V08 |
| Auditoría unificada y reporte semanal | A8.15 | V14, R04 |
| Datos en reposo cifrados (TDE) y respaldo cifrado | A8.24* | R06b, R06c, P04 |

## Condiciones de revisión

- Revisar este riesgo cuando Oracle publique una versión nueva de XE o un aviso de seguridad que afecte a la 21c.
- En un entorno real, migrar a una edición con soporte de parches (Standard o Enterprise) si la base pasa a producción.

## Nivel de madurez asociado

El control A8.8* queda con meta 2 en la matriz: se detecta y documenta la versión y se acepta formalmente el riesgo, sin parcheo disponible.
