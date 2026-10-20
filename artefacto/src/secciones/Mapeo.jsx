import { useState } from 'react';
import { org, controles } from '../data.js';
import EnlaceEvidencia from '../componentes/EnlaceEvidencia.jsx';

const FILTROS = ['Todos', 'Oficiales', 'Complementarios'];

export default function Mapeo({ indice, alAbrir }) {
  const [filtro, setFiltro] = useState('Todos');
  const filas = controles.filter((c) => filtro === 'Todos' || (filtro === 'Oficiales') === c.oficial);

  return (
    <>
      <div className="filtros" role="group" aria-label="Filtrar controles">
        {FILTROS.map((f) => (
          <button key={f} type="button" className={f === filtro ? 'sel' : ''} onClick={() => setFiltro(f)}>{f}</button>
        ))}
      </div>
      <table>
        <thead>
          <tr>
            <th>Control</th><th>Qué exige</th><th>Riesgos</th><th>Implementación en Oracle</th><th>Evidencia observable</th><th>Tipo</th>
            <th className="col-ejemplo">{org.etiquetas.ejemplo}</th>
          </tr>
        </thead>
        <tbody>{filas.map((c) => (
          <tr key={c.id}>
            <td><strong>{c.id}</strong><br />{c.nombre}<br /><small>{c.tema}{c.oficial ? '' : ' · complementario'}</small></td>
            <td>{c.exige}</td>
            <td>{c.riesgos.join(', ')}</td>
            <td>{c.implementacion}</td>
            <td><code className="sql">{c.consulta}</code><small>Script: </small><EnlaceEvidencia indice={indice} prefijo={c.script} alAbrir={alAbrir} /></td>
            <td>{c.tipo}</td>
            <td className="col-ejemplo">{c.ejemplo}</td>
          </tr>
        ))}</tbody>
      </table>
      <p><small>* Control complementario: el PDF pide la tarea (TDE, parcheo, clones, monitoreo, listener), pero su lista de 15 controles no incluye el control 2022 que mejor la cubre.</small></p>
    </>
  );
}
