# Controles ISO/IEC 27001:2022 para la confidencialidad en Oracle

Proyecto del curso EIF402 Administración de Bases de Datos (UNA, II Ciclo 2026). Diseña y verifica un marco de controles de confidencialidad para las tareas de un DBA sobre **Oracle Database 21c XE**, siguiendo el ciclo PHVA.

El escenario de prueba es un colegio técnico ficticio, el **Instituto Oracle Heredia** (esquema `INSTITUTO`). Todos los datos son ficticios.

## Qué contiene

| Carpeta | Contenido |
|---|---|
| `artefacto/` | Aplicación React (Vite) con el paso a paso del PDF: riesgos, tareas, mapeo, controles observables, matriz, pruebas, demostración y evidencias. |
| `artefacto/src/data/` | **Fuente única de datos** (JSON). Todo lo demás se genera desde aquí. |
| `sql/00_escenario/` | Crea el escenario con malas prácticas sembradas (`00_crear_escenario.sql`) y lo borra (`99_limpiar_escenario.sql`). |
| `sql/01_verificacion/` | Scripts V01–V17: verifican el estado de cada control y guardan su salida. |
| `evidencias/antes/` | Salidas reales de los scripts en el estado inicial (con fecha, usuario y contenedor). |
| `evidencias/despues/` | Se llena en la fase Verificar. |
| `docs/` | Documentos generados (`01`–`05`, contexto, guía de la demo) y el registro de uso de IA (`uso-ia.md`). |

## Cómo ejecutarlo

**Requisitos:** Oracle Database 21c XE con el servicio `OracleServiceXE` iniciado, SQL*Plus y Node.js.

```powershell
# 1. Crear el escenario (desde la raíz del repositorio)
sqlplus "sys/<clave> as sysdba" "@sql/00_escenario/00_crear_escenario.sql"

# 2. Verificar el estado ANTES y guardar las evidencias
sqlplus "sys/<clave> as sysdba" "@sql/01_verificacion/V00_ejecutar_todo.sql" antes

# 3. Ver el artefacto
cd artefacto
npm install
npm run dev
```

Para repetir desde cero, ejecutar antes `99_limpiar_escenario.sql`. Los scripts cambian solos a la PDB `XEPDB1` y abortan si no lo logran.

`npm run build` copia las evidencias, regenera los documentos de `docs/` desde los datos y compila el sitio estático. En el artefacto, el botón **Imprimir / PDF** imprime todos los pasos seguidos.

## Fases (PHVA)

- **Planificar:** riesgos, tareas, mapeo, matriz y diagnóstico ANTES. *Hecho.*
- **Hacer:** scripts de remediación por bloques (`sql/02_remediacion/`). *Pendiente.*
- **Verificar:** repetir V01–V17 y la batería de pruebas (`evidencias/despues/`). *Pendiente.*
- **Actuar:** riesgo residual y plan de mejora. *Pendiente.*

## Notas

- No se versionan contraseñas reales, keystores ni dumps (ver `.gitignore`). Las cuentas del escenario son ficticias y de laboratorio.
- Todo uso de IA está declarado en [docs/uso-ia.md](docs/uso-ia.md).
