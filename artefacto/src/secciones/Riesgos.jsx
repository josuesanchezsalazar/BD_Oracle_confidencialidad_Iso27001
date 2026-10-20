import { useState } from 'react';
import { riesgos, escala } from '../data.js';
import { nivel, banda, claseBanda } from '../calculos.js';
import MapaCalor from '../componentes/MapaCalor.jsx';
import Ejemplo from '../componentes/Ejemplo.jsx';

export default function Riesgos() {
  const [sel, setSel] = useState(null);
  const elegir = (id) => {
    setSel(id);
    document.getElementById(`riesgo-${id}`)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  return (
    <>
      <h3>Tabla de riesgos con probabilidad e impacto</h3>
      <p>Nivel = Probabilidad × Impacto. Bandas: 1–4 Bajo · 5–9 Medio · 10–14 Alto · 15–25 Crítico. Los valores de P e I se califican con la evidencia del escenario de prueba.</p>
      <table>
        <thead><tr><th>ID</th><th>Riesgo</th><th>P</th><th>I</th><th>Nivel inherente</th><th>Meta residual (provisional)</th></tr></thead>
        <tbody>{riesgos.map((r) => {
          const n = nivel(r.p, r.i);
          const m = nivel(r.meta.p, r.meta.i);
          return (
            <tr key={r.id}>
              <td><button type="button" className="enlace" onClick={() => elegir(r.id)}>{r.id}</button></td>
              <td>{r.nombre}</td>
              <td>{r.p}</td>
              <td>{r.i}</td>
              <td className={claseBanda(banda(n))}>{n} · {banda(n)}</td>
              <td className={claseBanda(banda(m))}>{m} · {banda(m)} <small>(P{r.meta.p} × I{r.meta.i})</small></td>
            </tr>
          );
        })}</tbody>
      </table>

      <div className="mapas">
        <MapaCalor titulo="Riesgo inherente (hoy)" puntos={riesgos} seleccionado={sel} onSelect={elegir} />
        <MapaCalor titulo="Meta de riesgo residual" puntos={riesgos.map((r) => ({ id: r.id, nombre: r.nombre, ...r.meta }))} seleccionado={sel} onSelect={elegir} />
      </div>
      <p className="apetito"><strong>Apetito de riesgo:</strong> residual ≤ {escala.apetito.max}. <small>{escala.apetito.nota}</small></p>

      <h3>Cada riesgo explicado</h3>
      <div className="tarjetas">
        {riesgos.map((r) => {
          const n = nivel(r.p, r.i);
          return (
            <article key={r.id} id={`riesgo-${r.id}`} className={`tarjeta${sel === r.id ? ' sel' : ''}`}>
              <header>
                <strong>{r.id}</strong>
                <span className={`banda-etiqueta ${claseBanda(banda(n))}`}>{n} · {banda(n)}</span>
              </header>
              <h4>{r.nombre}</h4>
              <p>{r.descripcion}</p>
              <h5>Causas típicas en Oracle</h5>
              <ul>{r.causas.map((c) => <li key={c}>{c}</li>)}</ul>
              <p><strong>Activo afectado:</strong> {r.activo}</p>
              <p><strong>Controles que lo tratan:</strong> {r.controles.join(', ')}</p>
              <Ejemplo>
                <p>{r.manifestacion.resumen}</p>
                <p><strong>Activo:</strong> {r.manifestacion.activo}{r.manifestacion.malasPracticas.length > 0 && <> · <strong>Malas prácticas:</strong> {r.manifestacion.malasPracticas.join(', ')}</>}</p>
                <p><strong>P = {r.p}:</strong> {r.justP}.</p>
                <p><strong>I = {r.i}:</strong> {r.justI}.</p>
                <p><strong>Meta {nivel(r.meta.p, r.meta.i)} (P{r.meta.p} × I{r.meta.i}):</strong> {r.justMeta}</p>
              </Ejemplo>
            </article>
          );
        })}
      </div>

      <h3>Escala utilizada</h3>
      <table>
        <thead><tr><th>Valor</th><th>Probabilidad</th><th>Impacto</th></tr></thead>
        <tbody>{escala.probabilidad.map((p, k) => (
          <tr key={p.valor}>
            <td>{p.valor}</td>
            <td><strong>{p.nombre}:</strong> {p.criterio}</td>
            <td><strong>{escala.impacto[k].nombre}:</strong> {escala.impacto[k].criterio}</td>
          </tr>
        ))}</tbody>
      </table>
    </>
  );
}
