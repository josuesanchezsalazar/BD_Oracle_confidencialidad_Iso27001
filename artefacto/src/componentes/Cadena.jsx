import { useState } from 'react';
import { riesgos, riesgoPorId, tareas, controlPorId, pruebas, org } from '../data.js';
import { nivel, banda, claseBanda } from '../calculos.js';
import EnlaceEvidencia from './EnlaceEvidencia.jsx';
import Ejemplo from './Ejemplo.jsx';

// Trazabilidad de punta a punta: elige un riesgo y ve sus causas, tareas, controles, evidencia y pruebas.
export default function Cadena({ indice, alAbrir }) {
  const [id, setId] = useState('R-CONF-01');
  const r = riesgoPorId[id];
  const n = nivel(r.p, r.i);
  const mps = org.malasPracticas.filter((m) => m.riesgo === id);
  const ts = tareas.filter((t) => t.riesgos.includes(id));
  const cs = r.controles.map((c) => controlPorId[c]);
  const scripts = [...new Set(cs.map((c) => c.script))];
  const ps = pruebas.filter((p) => r.controles.includes(p.control));

  return (
    <div className="cadena-viva">
      <div className="selector" role="tablist" aria-label="Elegir un riesgo">
        {riesgos.map((x) => (
          <button key={x.id} type="button" role="tab" aria-selected={x.id === id} className={x.id === id ? 'sel' : ''} onClick={() => setId(x.id)}>
            {x.id.replace('R-CONF-', 'R')}
          </button>
        ))}
      </div>
      <div className="cadena-cols">
        <div className="col">
          <h4>1 · Riesgo</h4>
          <p><strong>{r.nombre}</strong></p>
          <span className={`banda-etiqueta ${claseBanda(banda(n))}`}>{n} · {banda(n)}</span>
          <ul className="mini">{r.causas.slice(0, 3).map((c) => <li key={c}>{c}</li>)}</ul>
        </div>
        <div className="col">
          <h4>2 · Tarea del DBA</h4>
          <ul className="mini">{ts.map((t) => <li key={t.id}><strong>{t.id}</strong> {t.tarea}</li>)}</ul>
        </div>
        <div className="col">
          <h4>3 · Control ISO</h4>
          <ul className="mini">{cs.map((c) => <li key={c.id}><strong>{c.id}</strong> {c.nombre}</li>)}</ul>
        </div>
        <div className="col">
          <h4>4 · Evidencia</h4>
          <ul className="mini">{scripts.map((s) => <li key={s ?? 'manual'}><EnlaceEvidencia indice={indice} prefijo={s} alAbrir={alAbrir} /></li>)}</ul>
        </div>
        <div className="col">
          <h4>5 · Pruebas</h4>
          <p className="mini">{ps.length} pruebas: {ps.map((p) => p.id).join(', ')}</p>
        </div>
      </div>
      {mps.length > 0 && (
        <Ejemplo titulo="Malas prácticas del escenario que originan este riesgo">
          <ul className="mini">{mps.map((m) => <li key={m.id}><strong>{m.id}</strong> {m.practica}</li>)}</ul>
        </Ejemplo>
      )}
    </div>
  );
}
