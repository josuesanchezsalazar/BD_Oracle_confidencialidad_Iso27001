import org from './data/organizacion.json';
import riesgosData from './data/riesgos.json';
import tareas from './data/tareas.json';
import controles from './data/controles.json';
import pruebas from './data/pruebas.json';
import pasos from './data/pasos.json';
import demos from './data/demos.json';

export { org, tareas, controles, pruebas, pasos, demos };
export const { escala, riesgos } = riesgosData;

export const tareaPorId = Object.fromEntries(tareas.map((t) => [t.id, t]));
export const controlPorId = Object.fromEntries(controles.map((c) => [c.id, c]));
export const riesgoPorId = Object.fromEntries(riesgos.map((r) => [r.id, r]));
export const oficiales = controles.filter((c) => c.oficial);
export const complementarios = controles.filter((c) => !c.oficial);

// Un par tarea-control es una fila de la matriz de evaluacion. El riesgo del par son los riesgos
// que la tarea y el control comparten; si no comparten ninguno, los del control.
export const pares = tareas.flatMap((t) =>
  t.controles.map((id) => {
    const control = controlPorId[id];
    const comunes = control.riesgos.filter((r) => t.riesgos.includes(r));
    return { tarea: t, control, riesgos: comunes.length ? comunes : control.riesgos };
  }),
);
