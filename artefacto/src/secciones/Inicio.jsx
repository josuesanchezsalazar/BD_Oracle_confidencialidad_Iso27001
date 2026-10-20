import { riesgos, tareas, controles, oficiales, complementarios, pruebas, pasos } from '../data.js';
import { nivel, banda, estado } from '../calculos.js';
import Cadena from '../componentes/Cadena.jsx';

const FASES = [
  { nombre: 'Planificar', texto: 'Riesgos, tareas, mapeo, matriz y diagnóstico ANTES', actual: true },
  { nombre: 'Hacer', texto: 'Scripts de remediación por bloques' },
  { nombre: 'Verificar', texto: 'Mismos scripts y pruebas DESPUÉS' },
  { nombre: 'Actuar', texto: 'Riesgo residual y plan de mejora' },
];

export default function Inicio({ ir, indice, alAbrir }) {
  const criticos = riesgos.filter((r) => banda(nivel(r.p, r.i)) === 'Crítico').length;
  const noCumple = controles.filter((c) => estado(c.madurez.antes) === 'No cumple').length;
  const ejecutadas = pruebas.filter((p) => p.origen === 'ejecutada').length;

  return (
    <>
      <div className="kpis">
        <div className="kpi"><strong>{riesgos.length}</strong><span>riesgos R-CONF, {criticos} críticos</span></div>
        <div className="kpi"><strong>{tareas.length}</strong><span>tareas críticas del DBA</span></div>
        <div className="kpi"><strong>{oficiales.length} + {complementarios.length}</strong><span>controles oficiales + complementarios</span></div>
        <div className="kpi"><strong>{noCumple} de {controles.length}</strong><span>controles en "No cumple" (estado ANTES)</span></div>
        <div className="kpi"><strong>{ejecutadas} de {pruebas.length}</strong><span>pruebas con salida real</span></div>
      </div>

      <h3>Cómo leer este artefacto</h3>
      <ul className="como-leer">
        <li><strong>Primero lo general.</strong> Cada riesgo, tarea y control se explica para cualquier base Oracle.</li>
        <li><strong>Después el ejemplo.</strong> Lo que ocurrió en el escenario de prueba aparece en recuadros verdes. El interruptor de arriba los muestra u oculta.</li>
        <li><strong>Un paso por cada requisito del PDF.</strong> Cada pantalla empieza con lo que pide el PDF y cómo se resolvió.</li>
      </ul>

      <h3>Ciclo PHVA: dónde está el proyecto</h3>
      <ol className="phva">
        {FASES.map((f) => (
          <li key={f.nombre} className={f.actual ? 'actual' : ''}>
            <strong>{f.nombre}</strong>
            <span>{f.texto}</span>
            {f.actual && <em>Estás aquí</em>}
          </li>
        ))}
      </ol>

      <h3>Ruta paso a paso</h3>
      <ol className="ruta">
        {pasos.filter((p) => p.id !== 'inicio').map((p) => (
          <li key={p.id}>
            <button type="button" className="ruta-item" onClick={() => ir(p.id)}>
              <span className={`punto punto-${p.estado}`} />
              <span className="ruta-num">{p.numero}</span>
              <span className="ruta-tit">{p.titulo}</span>
              <span className="ruta-pdf">{p.pdf}</span>
            </button>
          </li>
        ))}
      </ol>

      <h3>Sigue un riesgo de punta a punta</h3>
      <p>Elige un riesgo y mira su cadena completa: tarea del DBA, control ISO, evidencia y pruebas.</p>
      <Cadena indice={indice} alAbrir={alAbrir} />
    </>
  );
}
