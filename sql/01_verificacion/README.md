# Scripts de verificación (V00–V17)

Inspeccionan el **estado** de cada control y guardan la salida como evidencia con fecha, usuario y contenedor.

## Cómo ejecutar

1. Iniciar los servicios `OracleServiceXE` y `OracleOraDB21Home1TNSListener`.
2. Ajustar `DEFINE esquema` en [_config.sql](_config.sql) al esquema de la organización.
3. Desde la **raíz del repositorio** (para que el `SPOOL` caiga en `evidencias/`):

```powershell
sqlplus "sys@localhost:1521/XEPDB1 as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" antes
```

Para un solo control, conectado en SQL*Plus desde la raíz:

```sql
DEFINE fase = antes
@sql/01_verificacion/V07_A8_2_acceso_privilegiado.sql
```

Se ejecutan como `SYS AS SYSDBA` porque `UNIFIED_AUDIT_TRAIL` y `V$PWFILE_USERS` requieren privilegios que `SYSTEM` no tiene por defecto. `_config.sql` aborta si el contenedor no es `XEPDB1`.

| Script | Control | Script | Control |
|--------|---------|--------|---------|
| V01 | A5.12 Clasificación | V10 | A8.10 Eliminación |
| V02 | A5.15 Control de acceso | V11 | A8.11 Enmascaramiento |
| V03 | A5.16 Identidades | V12 | A8.12 Fuga de datos |
| V04 | A5.17 Información de autenticación | V13 | A8.13 Respaldo |
| V05 | A5.18 Derechos de acceso | V14 | A8.15 Registro |
| V06 | A5.33 Protección de registros | V15 | A8.20 Redes |
| V07 | A8.2 Acceso privilegiado | V16 | A8.24* Criptografía |
| V08 | A8.3 Restricción de acceso | V17 | A8.8* Vulnerabilidades |
| V09 | A8.5 Autenticación segura | | |

Complementos fuera de SQL (guardar su salida en `evidencias/<fase>/` manualmente): `lsnrctl status`, copia de `sqlnet.ora`, `RMAN> SHOW ALL`, `RMAN> REPORT OBSOLETE`.
