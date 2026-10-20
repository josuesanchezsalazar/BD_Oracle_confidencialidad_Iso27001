import { org, oficiales } from '../data.js';
import EnlaceEvidencia from '../componentes/EnlaceEvidencia.jsx';

export default function Observables({ indice, alAbrir }) {
  return (
    <>
      <p>Los {oficiales.length} controles oficiales de la asignación, vistos como los vería un auditor externo: qué revisa, con qué consulta y cuándo lo da por aceptado.</p>
      <table>
        <thead>
          <tr>
            <th>#</th><th>Control</th><th>Qué observa el auditor</th><th>Consulta</th><th>Criterio de aceptación</th><th>Evidencia</th>
            <th className="col-ejemplo">{org.etiquetas.ejemplo}</th>
          </tr>
        </thead>
        <tbody>{oficiales.map((c, k) => (
          <tr key={c.id}>
            <td>{k + 1}</td>
            <td><strong>{c.id}</strong><br />{c.nombre}</td>
            <td>{c.auditor.observa}</td>
            <td><code className="sql">{c.consulta}</code></td>
            <td>{c.auditor.criterio}</td>
            <td><EnlaceEvidencia indice={indice} prefijo={c.script} alAbrir={alAbrir} /></td>
            <td className="col-ejemplo">{c.auditor.ejemplo}</td>
          </tr>
        ))}</tbody>
      </table>
    </>
  );
}
