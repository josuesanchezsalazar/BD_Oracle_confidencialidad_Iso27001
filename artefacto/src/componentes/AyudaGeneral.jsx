import { useEffect, useRef, useState } from 'react';
import { ayuda } from '../data.js';
import Icono from './Icono.jsx';

const SECCIONES = [
  { id: 'mapa', nombre: 'Cómo encaja todo', icono: 'enlace' },
  { id: 'usar', nombre: 'Cómo usar el artefacto', icono: 'terminal' },
  { id: 'glosario', nombre: 'Glosario', icono: 'libro' },
  { id: 'preguntas', nombre: 'Preguntas frecuentes', icono: 'ayuda' },
];

const quitarAcentos = (t) => t.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();

// Panel lateral con la ayuda general: mapa del proyecto, guía de uso, glosario con buscador y preguntas.
export default function AyudaGeneral({ abierto, onCerrar }) {
  const [seccion, setSeccion] = useState('mapa');
  const [busqueda, setBusqueda] = useState('');
  const cerrar = useRef(null);

  useEffect(() => {
    if (!abierto) return undefined;
    const alTecla = (e) => { if (e.key === 'Escape') onCerrar(); };
    window.addEventListener('keydown', alTecla);
    cerrar.current?.focus();
    return () => window.removeEventListener('keydown', alTecla);
  }, [abierto, onCerrar]);

  if (!abierto) return null;
  const q = quitarAcentos(busqueda);
  const terminos = ayuda.general.glosario.filter(([t, d]) => !q || quitarAcentos(`${t} ${d}`).includes(q));

  return (
    <div className="ayuda-fondo" onClick={onCerrar}>
      <aside className="ayuda-panel" role="dialog" aria-modal="true" aria-label="Ayuda general" onClick={(e) => e.stopPropagation()}>
        <header className="ayuda-panel-cab">
          <h2><Icono nombre="ayuda" tam={22} /> Ayuda</h2>
          <button type="button" className="boton" ref={cerrar} onClick={onCerrar} aria-label="Cerrar la ayuda"><Icono nombre="x" tam={16} /> Cerrar</button>
        </header>

        <div className="pestanas" role="tablist" aria-label="Secciones de la ayuda general">
          {SECCIONES.map((s) => (
            <button key={s.id} type="button" role="tab" aria-selected={seccion === s.id} className={seccion === s.id ? 'sel' : ''} onClick={() => setSeccion(s.id)}>
              <Icono nombre={s.icono} tam={14} /> {s.nombre}
            </button>
          ))}
        </div>

        {seccion === 'mapa' && (
          <>
            <p>Todo el proyecto es una cadena. Cada riesgo se conecta con una tarea, un control, un script y una evidencia; si falta un eslabón, no se puede demostrar nada.</p>
            <ol className="cadena-ayuda">
              {ayuda.general.cadena.map((c) => (<li key={c.titulo}><strong>{c.titulo}</strong><span>{c.texto}</span></li>))}
            </ol>
            <h3>El ciclo PHVA</h3>
            <ul className="ayuda-lista-simple">
              <li><strong>Planificar:</strong> riesgos, tareas, controles, matriz y diagnóstico ANTES.</li>
              <li><strong>Hacer:</strong> scripts que corrigen las fallas, por bloques.</li>
              <li><strong>Verificar:</strong> repetir los mismos scripts y las pruebas, y comparar con el ANTES.</li>
              <li><strong>Actuar:</strong> riesgo residual, brechas que quedan y plan de mejora.</li>
            </ul>
          </>
        )}

        {seccion === 'usar' && <ul className="ayuda-lista-simple">{ayuda.general.usar.map((t) => <li key={t}>{t}</li>)}</ul>}

        {seccion === 'glosario' && (
          <>
            <label className="buscador">
              <Icono nombre="ojo" tam={16} />
              <input type="search" value={busqueda} onChange={(e) => setBusqueda(e.target.value)} placeholder="Buscar un término (por ejemplo: TDE, PUBLIC, ORA-00942)" aria-label="Buscar en el glosario" />
            </label>
            <p><small>{terminos.length} de {ayuda.general.glosario.length} términos</small></p>
            <dl className="ayuda-terminos">
              {terminos.map(([t, d]) => (<div key={t}><dt>{t}</dt><dd>{d}</dd></div>))}
            </dl>
            {terminos.length === 0 && <p>Ningún término coincide con la búsqueda.</p>}
          </>
        )}

        {seccion === 'preguntas' && (
          <div className="ayuda-defender">
            {ayuda.general.preguntas.map((q) => (<details key={q.p}><summary>{q.p}</summary><p>{q.r}</p></details>))}
          </div>
        )}
      </aside>
    </div>
  );
}
