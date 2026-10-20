// Genera docs/01..05 en Markdown a partir de los mismos datos del artefacto (src/data/*.json),
// para que el repositorio y la pagina nunca se contradigan. Uso: npm run docs
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = join(dirname(fileURLToPath(import.meta.url)), '..');
const leer = (archivo) => JSON.parse(readFileSync(join(raiz, 'src', 'data', archivo), 'utf8'));
const docs = join(raiz, '..', 'docs');

const org = leer('organizacion.json');
const { riesgos, escala } = leer('riesgos.json');
const tareas = leer('tareas.json');
const controles = leer('controles.json');
const pruebas = leer('pruebas.json');

const controlPorId = Object.fromEntries(controles.map((c) => [c.id, c]));
const oficiales = controles.filter((c) => c.oficial);
const banda = (v) => escala.bandas.find((b) => v >= b.min && v <= b.max).nombre;
const estado = (m) => (m <= 1 ? 'No cumple' : m === 2 ? 'Parcial' : 'Cumple');
const celda = (t) => String(t ?? '').replaceAll('|', '\\|').replaceAll('\n', ' ');
const fila = (cols) => `| ${cols.map(celda).join(' | ')} |`;
const tabla = (encabezados, filas) =>
  [fila(encabezados), fila(encabezados.map(() => '---')), ...filas.map(fila)].join('\n');
const lista = (xs) => xs.join(', ') || '—';
const aviso = '> Archivo generado desde `artefacto/src/data/` con `npm run docs`. Para cambiarlo, edita los JSON.\n';
const escribir = (nombre, contenido) => {
  writeFileSync(join(docs, nombre), contenido.trimStart() + '\n');
  console.log(`docs/${nombre}`);
};

const pares = tareas.flatMap((t) =>
  t.controles.map((id) => {
    const control = controlPorId[id];
    const comunes = control.riesgos.filter((r) => t.riesgos.includes(r));
    return { tarea: t, control, riesgos: comunes.length ? comunes : control.riesgos };
  }),
);

escribir('01-riesgos.md', `
# 1. Tabla de riesgos de confidencialidad (R-CONF)

${aviso}
Nivel = Probabilidad (P) × Impacto (I), escala 1–5. Bandas: 1–4 Bajo · 5–9 Medio · 10–14 Alto · 15–25 Crítico.
Apetito de riesgo: residual ≤ ${escala.apetito.max}. ${escala.apetito.nota}

## Riesgos en general (aplican a cualquier base Oracle)

${tabla(['ID', 'Riesgo', 'Descripción', 'Causas típicas', 'Activo', 'P', 'I', 'Nivel inherente', 'Meta residual (provisional)'],
  riesgos.map((r) => {
    const n = r.p * r.i, m = r.meta.p * r.meta.i;
    return [r.id, r.nombre, r.descripcion, r.causas.join('; '), r.activo, r.p, r.i, `${n} ${banda(n)}`, `${m} ${banda(m)} (P${r.meta.p} × I${r.meta.i})`];
  }))}

## Ejemplo en el escenario de prueba (${org.nombre})

${tabla(['ID', 'Cómo se manifestó', 'Activo', 'Malas prácticas', 'Justificación de P', 'Justificación de I', 'Justificación de la meta'],
  riesgos.map((r) => [r.id, r.manifestacion.resumen, r.manifestacion.activo, lista(r.manifestacion.malasPracticas), r.justP, r.justI, r.justMeta]))}

## Escala

${tabla(['Valor', 'Probabilidad', 'Impacto'], escala.probabilidad.map((p, k) =>
  [p.valor, `${p.nombre}: ${p.criterio}`, `${escala.impacto[k].nombre}: ${escala.impacto[k].criterio}`]))}

## Controles que tratan cada riesgo

${tabla(['Riesgo', 'Controles'], riesgos.map((r) => [r.id, lista(r.controles)]))}
`);

escribir('02-tareas-dba.md', `
# 2. Tareas críticas del DBA

${aviso}
${tabla(['ID', 'Tarea', 'Qué hace el DBA', 'Frecuencia', 'Riesgos', 'Controles', 'Scripts', org.etiquetas.ejemplo],
  tareas.map((t) => [t.id, t.tarea, t.descripcion, t.frecuencia, lista(t.riesgos), lista(t.controles), lista(t.scripts), t.ejemplo]))}

\\* Control complementario, fuera de la lista oficial de la asignación.
`);

escribir('03-mapeo-controles.md', `
# 3. Mapeo de controles y 4. Controles observables

${aviso}
## 3. Mapeo ISO/IEC 27001:2022 → Oracle → evidencia observable

${tabla(['Control', 'Nombre', 'Qué exige', 'Riesgos', 'Implementación en Oracle', 'Evidencia observable', 'Script', 'Tipo', org.etiquetas.ejemplo],
  controles.map((c) => [c.id, c.nombre, c.exige, lista(c.riesgos), c.implementacion, `\`${c.consulta}\``, c.script ?? c.evidenciaManual, c.tipo, c.ejemplo]))}

## 4. Controles observables por un auditor externo (los 15 oficiales)

${tabla(['#', 'Control', 'Qué observa el auditor', 'Criterio de aceptación', 'Script', org.etiquetas.ejemplo],
  oficiales.map((c, k) => [k + 1, `${c.id} ${c.nombre}`, c.auditor.observa, c.auditor.criterio, c.script, c.auditor.ejemplo]))}

\\* Control complementario, fuera de la lista oficial de la asignación.
`);

escribir('04-matriz-evaluacion.md', `
# 5. Matriz de evaluación

${aviso}
**Escala de madurez:** 0 Inexistente · 1 Inicial (ad hoc, sin documento ni evidencia) · 2 Documentado (existe política, sin evidencia de ejecución) · 3 Implementado y verificado (un script V-xx lo demuestra) · 4 Gestionado (se monitorea periódicamente y se mejora).

**Estado:** 0–1 No cumple · 2 Parcial · 3–4 Cumple. La columna "Criterio 0-4" muestra el nivel ANTES y la meta DESPUÉS. Hay una fila por cada par tarea–control (${pares.length} filas).

${tabla(['Tarea', 'Riesgo', 'Control', 'Criterio 0-4', 'Evidencia', 'Estado'],
  pares.map(({ tarea, control, riesgos: rs }) => [
    `${tarea.id} ${tarea.tarea}`, lista(rs), `${control.id} ${control.nombre}`,
    `${control.madurez.antes} → meta ${control.madurez.meta}: ${control.madurez.justAntes}`,
    control.script ? `evidencias/antes/${control.script}_*.txt` : control.evidenciaManual, estado(control.madurez.antes)]))}
`);

escribir('05-pruebas.md', `
# 6. Batería de pruebas

${aviso}
"Falla" en el estado ANTES significa que el acceso indebido fue posible; después de la remediación la prueba debe dar el resultado esperado.
**Origen:** ejecutada (se corrió la prueba o su script y hay salida real) · inferida (deducida de la configuración observada, el intento no se ha corrido) · pendiente.

${tabla(['ID', 'Tipo', 'Control', 'Procedimiento', 'Resultado esperado', 'Herramienta', 'Origen', 'Estado ANTES', 'Caso en el escenario', 'Resultado ANTES'],
  pruebas.map((p) => [p.id, p.tipo, p.control, p.procedimiento, p.esperado, p.herramienta, p.origen, p.estadoAntes, `\`${p.caso}\``, p.antes]))}
`);

// ---------------------------------------------------------------------------
// Documentos del escenario: se generan desde organizacion.json y demos.json
// ---------------------------------------------------------------------------
const demosData = leer('demos.json');
const bloque = (t) => '```\n' + t + '\n```';

escribir('contexto-organizacion.md', `
# Contexto de la organización — ${org.nombre}

${aviso}
## 1. Organización
- **Nombre:** ${org.nombre} (ficticio)
- **Sector:** ${org.sector}
- **Ubicación:** ${org.ubicacion}
- **Motor:** ${org.motor}
- **Descripción:** ${org.descripcion}

## 2. Datos personales

${tabla(['Tabla', 'Columnas', 'Clasificación', 'Categoría Ley 8968'], org.clasificacion.map((c) => [c.tabla, c.columnas, c.nivel, c.ley8968]))}

⭐ **Columna de alta sensibilidad:** \`${org.columnaCritica}\`

${org.justificacionColumna}

## 3. Actores y cuentas

${tabla(['Actor', 'Cuenta', 'Debe', 'No debe'], org.actores.map((a) => [a.actor, `\`${a.cuenta}\``, a.debe, a.noDebe]))}

## 4. Malas prácticas iniciales (estado "ANTES")

${tabla(['ID', 'Mala práctica', 'Consecuencia', 'Riesgo', 'Controles', 'Evidencia'], org.malasPracticas.map((m) => [m.id, m.practica, m.consecuencia, m.riesgo, m.controles.join(', '), m.evidencia]))}

## 5. Hallazgos reales del diagnóstico (no sembrados)

${tabla(['Hallazgo', 'Control', 'Evidencia'], org.hallazgosReales.map((h) => [h.hallazgo, h.control, h.evidencia]))}
`);

escribir('guia-demo-sqlplus.md', `
# Guía de demostración en SQL*Plus — Estado "ANTES"

${aviso}
Paso a paso para mostrar en vivo el escenario ${org.nombre} y sus fallas de confidencialidad.

## Preparación

${demosData.preparacion.map((p, k) => `### Paso ${k}. ${p.paso}\n\n${bloque(p.comando)}\n\n${p.nota}`).join('\n\n')}

## ${demosData.escenario.paso}

${bloque(demosData.escenario.comando)}

${demosData.escenario.nota}

## Demostraciones: fallas entrando como otros usuarios

${demosData.demos.map((d) => `### Demo ${d.id} — ${d.titulo} (${d.malasPracticas})\n\n**Qué demuestra:** ${d.general}\n\n${bloque(d.sql)}\n\n**Resultado ANTES:** ${d.vera}\n\n> **Qué vemos:** ${d.vemos}`).join('\n\n')}

## ${demosData.cierre.paso}

${bloque(demosData.cierre.comando)}

${demosData.cierre.nota}

## Cuentas del escenario (solo laboratorio, datos ficticios)

${tabla(['Usuario', 'Contraseña', 'Mala práctica'], demosData.cuentas.map((c) => [`\`${c.usuario}\``, `\`${c.clave}\``, c.mala]))}
`);
