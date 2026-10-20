import { NOMBRES_MADUREZ } from '../calculos.js';

// Cuatro segmentos (niveles 1 a 4): lleno hasta el nivel ANTES y marcado el nivel META.
export default function BarraMadurez({ antes, meta }) {
  return (
    <div className="madurez" role="img" aria-label={`Nivel ${antes} (${NOMBRES_MADUREZ[antes]}), meta ${meta}`}>
      <strong className="madurez-valor">{antes}</strong>
      {[1, 2, 3, 4].map((n) => (
        <span key={n} className={`seg${n <= antes ? ' lleno' : ''}${n === meta ? ' meta' : ''}`} title={`Nivel ${n}: ${NOMBRES_MADUREZ[n]}`}>
          {n === meta ? 'meta' : ''}
        </span>
      ))}
    </div>
  );
}
