import { useState } from 'react';
import { demos } from '../data.js';

function Comando({ texto }) {
  const [copiado, setCopiado] = useState(false);
  const copiar = () => {
    navigator.clipboard?.writeText(texto).then(() => {
      setCopiado(true);
      setTimeout(() => setCopiado(false), 1500);
    });
  };
  return (
    <div className="comando">
      <pre>{texto}</pre>
      <button type="button" onClick={copiar}>{copiado ? 'Copiado' : 'Copiar'}</button>
    </div>
  );
}

export default function Demo() {
  return (
    <>
      <p className="aviso-ejemplo">Las demostraciones usan las cuentas ficticias del escenario de prueba. Se ejecutan en SQL*Plus o en SQL Developer (conexión localhost, puerto 1521, servicio XEPDB1).</p>

      <h3>Preparación</h3>
      <ol className="prep">
        {demos.preparacion.map((p) => (
          <li key={p.paso}>
            <strong>{p.paso}</strong>
            <Comando texto={p.comando} />
            <small>{p.nota}</small>
          </li>
        ))}
      </ol>

      <h3>{demos.escenario.paso}</h3>
      <Comando texto={demos.escenario.comando} />
      <p><small>{demos.escenario.nota}</small></p>

      <h3>Las demostraciones</h3>
      <div className="tarjetas">
        {demos.demos.map((d) => (
          <article key={d.id} className="tarjeta">
            <header>
              <strong>Demo {d.id}</strong>
              <span className="chip-pdf">{d.malasPracticas} · {d.controles.join(', ')}</span>
            </header>
            <h4>{d.titulo}</h4>
            <p><strong>Qué demuestra (en general):</strong> {d.general}</p>
            <Comando texto={d.sql} />
            <p><strong>Resultado ANTES:</strong> {d.vera}</p>
            <p className="decir"><strong>Qué vemos:</strong> {d.vemos}</p>
          </article>
        ))}
      </div>

      <h3>{demos.cierre.paso}</h3>
      <Comando texto={demos.cierre.comando} />
      <p><small>{demos.cierre.nota}</small></p>
    </>
  );
}
