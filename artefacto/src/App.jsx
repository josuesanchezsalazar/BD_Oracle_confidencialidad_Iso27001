import { useEffect, useState } from 'react';
import { org, pasos } from './data.js';
import PasoCabecera from './componentes/PasoCabecera.jsx';
import Icono, { ICONO_PASO } from './componentes/Icono.jsx';
import AyudaPaso from './componentes/AyudaPaso.jsx';
import AyudaGeneral from './componentes/AyudaGeneral.jsx';
import Inicio from './secciones/Inicio.jsx';
import Contexto from './secciones/Contexto.jsx';
import Riesgos from './secciones/Riesgos.jsx';
import Tareas from './secciones/Tareas.jsx';
import Mapeo from './secciones/Mapeo.jsx';
import Observables from './secciones/Observables.jsx';
import Matriz from './secciones/Matriz.jsx';
import Pruebas from './secciones/Pruebas.jsx';
import Evidencias from './secciones/Evidencias.jsx';

const SECCIONES = { inicio: Inicio, contexto: Contexto, riesgos: Riesgos, tareas: Tareas, mapeo: Mapeo, observables: Observables, matriz: Matriz, pruebas: Pruebas, evidencias: Evidencias };
const IDS = pasos.map((p) => p.id);
const desdeHash = () => {
  const h = window.location.hash.slice(1);
  return IDS.includes(h) ? h : 'inicio';
};

export default function App() {
  const [activo, setActivo] = useState(desdeHash);
  const [ejemplo, setEjemplo] = useState(true);
  const [indice, setIndice] = useState(null);
  const [visor, setVisor] = useState(null);
  const [ayudaAbierta, setAyudaAbierta] = useState(false);

  useEffect(() => {
    fetch('./evidencias/index.json')
      .then((r) => (r.ok ? r.json() : null))
      .then(setIndice)
      .catch(() => setIndice(null));
  }, []);

  useEffect(() => {
    const alCambiar = () => setActivo(desdeHash());
    window.addEventListener('hashchange', alCambiar);
    return () => window.removeEventListener('hashchange', alCambiar);
  }, []);

  const ir = (id) => {
    window.location.hash = id;
    window.scrollTo({ top: 0 });
  };

  const alAbrir = (fase, archivo) => {
    fetch(`./evidencias/${fase}/${archivo}`)
      .then((r) => r.text())
      .then((texto) => {
        setVisor({ fase, archivo, texto });
        ir('evidencias');
      });
  };

  const pos = IDS.indexOf(activo);
  const anterior = pasos[pos - 1];
  const siguiente = pasos[pos + 1];

  return (
    <div className={`app${ejemplo ? '' : ' sin-ejemplo'}`}>
      <header className="cabecera">
        <span className="logo"><Icono nombre="escudoOk" tam={34} /></span>
        <div className="cab-texto">
          <p className="sobretitulo">EIF402 Administración de Bases de Datos · UNA · II Ciclo 2026</p>
          <h1>Controles ISO/IEC 27001:2022 para la confidencialidad en Oracle</h1>
          <p className="subtitulo">Escenario de prueba: {org.nombre} · {org.motor}</p>
        </div>
        <div className="acciones">
          <label className="interruptor">
            <input type="checkbox" checked={ejemplo} onChange={(e) => setEjemplo(e.target.checked)} />
            <span>{org.etiquetas.interruptor}</span>
          </label>
          <button type="button" className="boton primario" onClick={() => setAyudaAbierta(true)}><Icono nombre="ayuda" tam={16} /> Ayuda</button>
          <button type="button" className="boton" onClick={() => window.print()}><Icono nombre="impresora" tam={16} /> Imprimir / PDF</button>
        </div>
      </header>

      <div className="cuerpo">
        <nav className="rail" aria-label="Pasos">
          <p className="rail-titulo">Paso a paso según el PDF</p>
          <p className="rail-posicion">Paso {pos + 1} de {IDS.length}</p>
          <div className="rail-progreso" role="progressbar" aria-valuemin={0} aria-valuemax={IDS.length - 1} aria-valuenow={pos}>
            <span style={{ width: `${(pos / (IDS.length - 1)) * 100}%` }} />
          </div>
          {pasos.map((p) => (
            <button key={p.id} type="button" className={`rail-item${p.id === activo ? ' activa' : ''}`} onClick={() => ir(p.id)} aria-current={p.id === activo ? 'step' : undefined}>
              <span className="rail-num"><Icono nombre={ICONO_PASO[p.id]} tam={15} /></span>
              <span className="rail-texto">{p.titulo}</span>
              <span className={`punto punto-${p.estado}`} title={p.estado} />
            </button>
          ))}
        </nav>

        <main>
          {pasos.map((p) => {
            const Seccion = SECCIONES[p.id];
            return (
              <section key={p.id} className={`paso${p.id === activo ? ' activa' : ''}`} aria-labelledby={`t-${p.id}`}>
                <PasoCabecera paso={p} />
                <AyudaPaso id={p.id} />
                <Seccion ir={ir} indice={indice} visor={visor} alAbrir={alAbrir} />
              </section>
            );
          })}
          <div className="navegacion">
            {anterior ? <button type="button" className="boton" onClick={() => ir(anterior.id)}><Icono nombre="izquierda" tam={16} /> {anterior.titulo}</button> : <span />}
            {siguiente ? <button type="button" className="boton primario" onClick={() => ir(siguiente.id)}>{siguiente.titulo} <Icono nombre="derecha" tam={16} /></button> : <span />}
          </div>
        </main>
      </div>

      <AyudaGeneral abierto={ayudaAbierta} onCerrar={() => setAyudaAbierta(false)} />

      <footer className="pie">
        Josué Sánchez Salazar · Prof. Johnny Villalobos Murillo · Datos ficticios generados para el proyecto · Uso de IA declarado en docs/uso-ia.md
      </footer>
    </div>
  );
}
