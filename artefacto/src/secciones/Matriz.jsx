import { useState } from 'react';
import { pares, controles } from '../data.js';
import { estado, claseEstado, NOMBRES_MADUREZ } from '../calculos.js';
import BarraMadurez from '../componentes/BarraMadurez.jsx';
import BarraApilada from '../componentes/BarraApilada.jsx';
import EnlaceEvidencia from '../componentes/EnlaceEvidencia.jsx';

export default function Matriz({ indice, alAbrir }) {
  const [filtro, setFiltro] = useState('Todos');
  const filas = pares.filter((p) => filtro === 'Todos' || estado(p.control.madurez.antes) === filtro);
  const cuenta = (e) => controles.filter((c) => estado(c.madurez.antes) === e).length;

  return (
    <>
      <p>
        Escala de madurez: {NOMBRES_MADUREZ.map((n, k) => `${k} ${n}`).join(' · ')}. Estado: 0–1 No cumple · 2 Parcial · 3–4 Cumple.
        La barra muestra el nivel ANTES y la meta DESPUÉS.
      </p>
      <BarraApilada
        titulo={`Estado de los ${controles.length} controles (ANTES)`}
        segmentos={[
          { etiqueta: 'No cumple', valor: cuenta('No cumple'), clase: 'est-falla' },
          { etiqueta: 'Parcial', valor: cuenta('Parcial'), clase: 'est-parcial' },
          { etiqueta: 'Cumple', valor: cuenta('Cumple'), clase: 'est-cumple' },
        ]}
      />
      <div className="filtros" role="group" aria-label="Filtrar por estado">
        {['Todos', 'No cumple', 'Parcial', 'Cumple'].map((f) => (
          <button key={f} type="button" className={f === filtro ? 'sel' : ''} onClick={() => setFiltro(f)}>{f}</button>
        ))}
      </div>
      <table>
        <thead><tr><th>Tarea</th><th>Riesgo</th><th>Control</th><th>Criterio 0-4</th><th>Evidencia</th><th>Estado</th></tr></thead>
        <tbody>{filas.map(({ tarea, control, riesgos }) => (
          <tr key={`${tarea.id}-${control.id}`}>
            <td><strong>{tarea.id}</strong> {tarea.tarea}</td>
            <td>{riesgos.join(', ')}</td>
            <td><strong>{control.id}</strong> {control.nombre}</td>
            <td>
              <BarraMadurez antes={control.madurez.antes} meta={control.madurez.meta} />
              <small className="ejemplo-txt">{control.madurez.justAntes}</small>
            </td>
            <td><EnlaceEvidencia indice={indice} prefijo={control.script} alAbrir={alAbrir} /></td>
            <td><span className={claseEstado(estado(control.madurez.antes))}>{estado(control.madurez.antes)}</span></td>
          </tr>
        ))}</tbody>
      </table>
      <p><small>{filas.length} filas: una por cada par tarea–control. El texto bajo la barra explica el nivel con la evidencia del escenario de prueba.</small></p>
    </>
  );
}
