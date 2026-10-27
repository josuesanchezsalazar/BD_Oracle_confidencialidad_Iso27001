import { useMemo } from 'react';
import { controlesClave, nivel, banda, claseBanda } from '../calculos.js';
import EnlaceEvidencia from './EnlaceEvidencia.jsx';
import Icono from './Icono.jsx';

export default function ControlesClave({ indice, alAbrir, ir }) {
  const top = useMemo(() => controlesClave(5), []);

  return (
    <section className="clave" aria-label="Controles más importantes para evaluar el escenario">
      <p className="clave-criterio">
        <Icono nombre="info" tam={14} /> <strong>Criterio:</strong> importancia = (suma del nivel P×I de los riesgos que el control trata) × (salto de madurez ANTES → DESPUÉS).
        Prioriza lo que cubre riesgos graves y lo que más cambió.
      </p>
      <ol className="clave-lista">
        {top.map(({ control: c, tratados, sumaPI, salto, puntaje }, i) => (
          <li key={c.id} className="clave-item">
            <span className="clave-num" aria-hidden="true">{i + 1}</span>
            <div className="clave-cuerpo">
              <h4>{c.id} <span>{c.nombre}</span></h4>
              <p className="clave-razon">
                Trata{' '}
                {tratados.map((r, k) => (
                  <span key={r.id}>
                    {k > 0 && (k === tratados.length - 1 ? ' y ' : ', ')}
                    <span className={`banda-etiqueta ${claseBanda(banda(nivel(r.p, r.i)))}`}>{r.id} · {nivel(r.p, r.i)}</span>
                  </span>
                ))}{' '}
                y pasó de nivel <strong>{c.madurez.antes}</strong> a <strong>{c.madurez.despues}</strong>.
              </p>
              <p className="clave-mirar"><strong>Qué mirar:</strong> {c.auditor.observa}</p>
              <p className="clave-pie">
                <span className="clave-puntaje" title="suma P×I × salto de madurez">{sumaPI} × {salto} = <strong>{puntaje}</strong></span>
                {c.script && <span>Evidencia DESPUÉS: <EnlaceEvidencia indice={indice} prefijo={c.script} alAbrir={alAbrir} fase="despues" /></span>}
                <button type="button" className="enlace" onClick={() => ir('matriz')}>Ver en la matriz</button>
              </p>
            </div>
          </li>
        ))}
      </ol>
    </section>
  );
}
