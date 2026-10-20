import { nivel, banda, claseBanda } from '../calculos.js';

export default function MapaCalor({ titulo, puntos, seleccionado, onSelect }) {
  return (
    <figure className="mapa">
      <figcaption>{titulo}</figcaption>
      <table className="mapa-tabla" aria-label={titulo}>
        <tbody>
          {[5, 4, 3, 2, 1].map((p) => (
            <tr key={p}>
              <th scope="row">P{p}</th>
              {[1, 2, 3, 4, 5].map((i) => (
                <td key={i} className={claseBanda(banda(nivel(p, i)))}>
                  {puntos.filter((r) => r.p === p && r.i === i).map((r) => (
                    <button
                      type="button"
                      key={r.id}
                      className={`chip${seleccionado === r.id ? ' sel' : ''}`}
                      onClick={() => onSelect?.(r.id)}
                      title={r.nombre}
                    >
                      {r.id.replace('R-CONF-', 'R')}
                    </button>
                  ))}
                </td>
              ))}
            </tr>
          ))}
          <tr>
            <th />
            {[1, 2, 3, 4, 5].map((i) => <th key={i} scope="col">I{i}</th>)}
          </tr>
        </tbody>
      </table>
    </figure>
  );
}
