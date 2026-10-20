import { org, tareas } from '../data.js';
import GridTareaControl from '../componentes/GridTareaControl.jsx';

export default function Tareas() {
  return (
    <>
      <h3>Las 12 tareas críticas</h3>
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Tarea</th><th>Qué hace el DBA</th><th>Frecuencia</th><th>Riesgos</th><th>Controles</th>
            <th className="col-ejemplo">{org.etiquetas.ejemplo}</th>
          </tr>
        </thead>
        <tbody>{tareas.map((t) => (
          <tr key={t.id}>
            <td className="nowrap">{t.id}</td>
            <td><strong>{t.tarea}</strong></td>
            <td>{t.descripcion}</td>
            <td>{t.frecuencia}</td>
            <td>{t.riesgos.join(', ')}</td>
            <td>{t.controles.join(', ')}</td>
            <td className="col-ejemplo">{t.ejemplo}{t.malasPracticas.length > 0 && <><br /><small>Malas prácticas: {t.malasPracticas.join(', ')}</small></>}</td>
          </tr>
        ))}</tbody>
      </table>
      <p><small>* Control complementario, fuera de la lista oficial de la asignación.</small></p>

      <h3>Qué control aplica cada tarea</h3>
      <GridTareaControl />
    </>
  );
}
