import { useState } from 'react';
import { ayuda } from '../data.js';
import Icono from './Icono.jsx';

const PESTANAS = [
  { id: 'que', nombre: 'Qué es y para qué', icono: 'info' },
  { id: 'leer', nombre: 'Cómo leerlo', icono: 'ojo' },
  { id: 'terminos', nombre: 'Términos', icono: 'libro' },
  { id: 'defender', nombre: 'Cómo defenderlo', icono: 'escudoOk' },
];

const CLAVE = 'ayuda-paso-cerrada';
const leer = () => { try { return window.localStorage.getItem(CLAVE) === '1'; } catch { return false; } };
const guardar = (v) => { try { window.localStorage.setItem(CLAVE, v ? '1' : '0'); } catch { /* sin almacenamiento */ } };

// Ayuda contextual de un paso: cuatro pestañas con todo lo necesario para entenderlo y defenderlo.
export default function AyudaPaso({ id }) {
  const datos = ayuda.pasos[id];
  const [pestana, setPestana] = useState('que');
  const [cerrada, setCerrada] = useState(leer);
  if (!datos) return null;
  const alternar = () => setCerrada((c) => { guardar(!c); return !c; });

  return (
    <section className="ayuda-paso" aria-label="Ayuda de este paso">
      <button type="button" className="ayuda-cab" onClick={alternar} aria-expanded={!cerrada}>
        <span><Icono nombre="ayuda" tam={18} /> Ayuda de este paso</span>
        <span className="guia-estado">{cerrada ? 'Mostrar' : 'Ocultar'}</span>
      </button>
      {!cerrada && (
        <div className="ayuda-cuerpo">
          <div className="pestanas" role="tablist" aria-label="Secciones de la ayuda">
            {PESTANAS.map((p) => (
              <button key={p.id} type="button" role="tab" aria-selected={pestana === p.id} className={pestana === p.id ? 'sel' : ''} onClick={() => setPestana(p.id)}>
                <Icono nombre={p.icono} tam={14} /> {p.nombre}
              </button>
            ))}
          </div>

          {pestana === 'que' && (
            <div className="ayuda-que">
              <div><h4>Qué es</h4><p>{datos.queEs}</p></div>
              <div><h4>Para qué sirve en el proyecto</h4><p>{datos.paraQue}</p></div>
            </div>
          )}

          {pestana === 'leer' && (
            <ol className="ayuda-lista">{datos.comoLeer.map((t) => <li key={t}>{t}</li>)}</ol>
          )}

          {pestana === 'terminos' && (
            <dl className="ayuda-terminos">
              {datos.terminos.map(([t, d]) => (<div key={t}><dt>{t}</dt><dd>{d}</dd></div>))}
            </dl>
          )}

          {pestana === 'defender' && (
            <div className="ayuda-defender">
              {datos.defender.map((q) => (
                <details key={q.p}>
                  <summary>{q.p}</summary>
                  <p>{q.r}</p>
                </details>
              ))}
            </div>
          )}
        </div>
      )}
    </section>
  );
}
