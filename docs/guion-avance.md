# Guion del avance (5 minutos)

Apuntes para ensayar, no para leer. Cada bloque dice qué mostrar y la idea que debe quedar; las palabras son tuyas.

| Tiempo | Qué mostrar | Idea que debe quedar |
|---|---|---|
| 0:00–0:30 | Artefacto, paso **0 Visión general** | Soy el DBA de un colegio técnico. Los datos de salud y de condición socioeconómica de los estudiantes son sensibles según la Ley 8968, y debo **demostrar** que están protegidos, no solo afirmarlo. |
| 0:30–1:30 | Paso **1 Riesgos**: mapa de calor | Seis riesgos típicos de una base Oracle, calificados por probabilidad e impacto. Cuatro salen críticos; el mayor es el acceso por privilegios excesivos. |
| 1:30–2:15 | Pasos **2 y 3**: cuadrícula tarea × control y mapeo | Cada riesgo nace en tareas del DBA y se mitiga con controles de ISO 27001:2022. Cada control tiene su implementación en Oracle y la consulta que lo comprueba. |
| 2:15–3:45 | **Demo en vivo** (paso D): demos A y B | Demo A: una ex-secretaria lee diagnósticos de estudiantes. Demo B: una docente ve las notas de todos los docentes. Hablar de lo que se ve en pantalla y qué control falla. |
| 3:45–4:30 | Paso **5 Matriz** | Evalué cada control de 0 a 4 con evidencia real. Hoy todos están en "No cumple": es el punto de partida que quería medir. |
| 4:30–5:00 | Paso **6 Pruebas** y cierre | Las pruebas negativas hoy fallan. Sigue Hacer: remediar, repetir los mismos scripts y comparar. El uso de IA está declarado. |

## Antes de entrar

- Oracle encendido y la demo probada una vez (ver la pestaña **Demostración en vivo**).
- Artefacto abierto con `npm run dev`.
- Preguntas prioritarias a la mano: [preguntas-profesor.md](preguntas-profesor.md) (1, 2, 3, 4 y 8).

## Preguntas que pueden hacerte

- **¿Por qué un escenario ficticio?** Para tener datos y configuraciones sobre los cuales ejecutar las pruebas.
- **¿Las fallas son reales?** Las 12 las sembré; los scripts además encontraron otras que no sembré (por ejemplo, `UTL_*` abierto a `PUBLIC`).
- **¿Qué diferencia hay entre 27001 y 27002?** La 27001 es la certificable y dice qué controlar; la 27002 es la guía de cómo.
- **¿Por qué agregaste controles que no están en la lista?** El PDF pide TDE, parcheo y clones, y esos controles no están en su lista de 15. Están marcados con asterisco.
- **¿TDE protege del que tiene acceso?** No: protege archivos robados, no a quien tiene `SELECT`.
- **¿LogMiner muestra quién leyó un dato?** No: un `SELECT` no genera redo; para eso está la auditoría.

## Qué no decir

- Que algo está implementado: hoy solo está diagnosticado.
- Que las pruebas se ejecutaron todas: algunas tienen salida real y otras se infirieron de los scripts; el artefacto lo distingue.
