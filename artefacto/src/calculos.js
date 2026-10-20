import { escala } from './data.js';

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
