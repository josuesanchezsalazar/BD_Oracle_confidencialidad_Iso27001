import { escala, riesgos, controles, curva } from './data.js';

// Nivel de riesgo = probabilidad x impacto (escala 1-5)
export const nivel = (p, i) => p * i;

export const banda = (valor) => escala.bandas.find((b) => valor >= b.min && valor <= b.max).nombre;

// Regla de la matriz: 0-1 No cumple, 2 Parcial, 3-4 Cumple
export const estado = (madurez) => (madurez <= 1 ? 'No cumple' : madurez === 2 ? 'Parcial' : 'Cumple');

export const NOMBRES_MADUREZ = ['Inexistente', 'Inicial', 'Documentado', 'Implementado y verificado', 'Gestionado'];

// Archivo de evidencia mas reciente de una fase cuyo nombre empieza con el prefijo (p. ej. "V07_A8_2")
export const archivoEvidencia = (indice, fase, prefijo) =>
  (indice?.[fase] ?? []).filter((f) => f.startsWith(`${prefijo}_`)).sort().at(-1);

export const claseBanda = (nombre) => `banda-${nombre.toLowerCase().replace('í', 'i')}`;
export const claseEstado = (valor) => `estado estado-${valor.toLowerCase().replace(' ', '-')}`;

const media = (valores) => (valores.length ? valores.reduce((a, b) => a + b, 0) / valores.length : null);
const redondear = (v) => (v === null ? null : Math.round(v * 100) / 100);

// Nivel de un control tras cada bloque: ANTES hasta que un bloque lo remedia; luego el nivel parcial
// del bloque (si lo declara) o su nivel DESPUES. Un control sin DESPUES medido no se cuenta (null).
function nivelesPorBloque() {
  const actual = Object.fromEntries(controles.map((c) => [c.id, c.madurez.antes]));
  return curva.bloques.map((b) => {
    b.controles.forEach((id) => {
      const m = controles.find((c) => c.id === id).madurez;
      const parcial = b.parcial?.[id];
      actual[id] = parcial ?? m.despues ?? null;
    });
    return { ...actual };
  });
}

// Serie de la curva: madurez media por riesgo y promedio de los 20 controles, tras cada bloque.
export function serieCurva() {
  const niveles = nivelesPorBloque();
  const punto = (ids, n) => redondear(media(ids.map((id) => n[id]).filter((v) => v !== null)));
  return {
    bloques: curva.bloques,
    riesgos: riesgos.map((r) => ({ id: r.id, nombre: r.nombre, valores: niveles.map((n) => punto(r.controles, n)) })),
    promedio: niveles.map((n) => punto(controles.map((c) => c.id), n)),
    meta: redondear(media(controles.map((c) => c.madurez.meta))),
  };
}

// Controles a priorizar al evaluar el escenario: (suma P x I de los riesgos que trata) x (salto de madurez antes -> despues).
export function controlesClave(cuantos = 5) {
  return controles
    .filter((c) => c.madurez.despues != null)
    .map((c) => {
      const tratados = riesgos.filter((r) => c.riesgos.includes(r.id));
      const sumaPI = tratados.reduce((acc, r) => acc + nivel(r.p, r.i), 0);
      const salto = c.madurez.despues - c.madurez.antes;
      return { control: c, tratados, sumaPI, salto, puntaje: sumaPI * salto };
    })
    .sort((a, b) => b.puntaje - a.puntaje || b.sumaPI - a.sumaPI || Number(b.control.oficial) - Number(a.control.oficial) || a.control.id.localeCompare(b.control.id))
    .slice(0, cuantos);
}
