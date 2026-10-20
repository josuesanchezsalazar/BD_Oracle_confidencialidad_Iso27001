import { tareas, controles } from '../data.js';

// Cuadricula tarea x control: un punto donde la tarea aplica el control, coloreado por el nivel ANTES del control.
export default function GridTareaControl() {
  return (
    <div className="grid-wrap" role="region" aria-label="Cobertura de controles por tarea" tabIndex={0}>
      <table className="grid-tc">
        <thead>
          <tr>
            <th />
            {controles.map((c) => (
              <th key={c.id} className="vert" title={c.nombre}><span>{c.id}</span></th>
            ))}
          </tr>
        </thead>
        <tbody>
          {tareas.map((t) => (
            <tr key={t.id}>
              <th scope="row">{t.id} {t.tarea}</th>
              {controles.map((c) => {
                const aplica = t.controles.includes(c.id);
                return (
                  <td key={c.id} className={aplica ? `on m${c.madurez.antes}` : ''} title={aplica ? `${t.id} aplica ${c.id}: nivel ANTES ${c.madurez.antes}` : ''}>
                    {aplica ? '●' : ''}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
      <p className="leyenda-grid">
        Color = nivel de madurez ANTES del control: <i className="m0" /> 0 · <i className="m1" /> 1 · <i className="m2" /> 2 · <i className="m3" /> 3 · <i className="m4" /> 4
      </p>
    </div>
  );
}
