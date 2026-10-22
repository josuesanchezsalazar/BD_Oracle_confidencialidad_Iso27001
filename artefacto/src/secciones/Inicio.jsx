import { riesgos, tareas, controles, oficiales, complementarios, pruebas, pasos } from '../data.js';
import { nivel, banda, estado } from '../calculos.js';
import Cadena from '../componentes/Cadena.jsx';
import Icono, { ICONO_PASO } from '../componentes/Icono.jsx';
import Kpi from '../componentes/Kpi.jsx';
import GuiaInicio from '../componentes/GuiaInicio.jsx';
import AvisoDespues from '../componentes/AvisoDespues.jsx';

const FASES = [
  { nombre: 'Planificar', texto: 'Riesgos, tareas, mapeo, matriz y diagnóstico ANTES', actual: true },
  { nombre: 'Hacer', texto: 'Scripts de remediación por bloques' },
  { nombre: 'Verificar', texto: 'Mismos scripts y pruebas DESPUÉS' },
  { nombre: 'Actuar', texto: 'Riesgo residual y plan de mejora' },
];

export default function Inicio({ ir, indice, alAbrir }) {
  const hayDespues = (indice?.despues ?? []).length > 0;
  const criticos = riesgos.filter((r) => banda(nivel(r.p, r.i)) === 'Crítico').length;
  const noCumple = controles.filter((c) => estado(c.madurez.antes) === 'No cumple').length;
  const ejecutadas = pruebas.filter((p) => p.origen === 'ejecutada').length;

  return (
    <>
      <GuiaInicio />

      <div className="kpis">
        <Kpi icono="alerta" tono="critico" valor={riesgos.length} texto={`riesgos R-CONF, ${criticos} críticos`} />
        <Kpi icono="lista" valor={tareas.length} texto="tareas críticas del DBA" />
        <Kpi icono="escudo" valor={`${oficiales.length} + ${complementarios.length}`} texto="controles oficiales + complementarios" />
        <Kpi icono="x" tono="critico" valor={`${noCumple} de ${controles.length}`} texto='controles en "No cumple" (ANTES)' />
        <Kpi icono="matraz" tono="ok" valor={`${ejecutadas} de ${pruebas.length}`} texto="pruebas con salida real" />
      </div>

      <h3><Icono nombre="reloj" tam={18} /> ANTES y DESPUÉS</h3>
      <AvisoDespues ir={ir} hayDespues={hayDespues} />

      <h3><Icono nombre="ayuda" tam={18} /> Cómo leer este artefacto</h3>
      <ul className="como-leer">
        <li><strong>Primero lo general.</strong> Cada riesgo, tarea y control se explica para cualquier base Oracle.</li>
        <li><strong>Después el ejemplo.</strong> Lo que ocurrió en el escenario de prueba aparece en recuadros verdes. El interruptor de arriba los muestra u oculta.</li>
        <li><strong>Un paso por cada requisito del PDF.</strong> Cada pantalla empieza con lo que pide el PDF y cómo se resolvió.</li>
      </ul>

      <h3><Icono nombre="objetivo" tam={18} /> Ciclo PHVA: dónde está el proyecto</h3>
      <ol className="phva">
        {FASES.map((f) => (
          <li key={f.nombre} className={f.actual ? 'actual' : ''}>
            <strong>{f.nombre}</strong>
            <span>{f.texto}</span>
            {f.actual && <em>Estás aquí</em>}
          </li>
        ))}
      </ol>

      <h3><Icono nombre="lista" tam={18} /> Ruta paso a paso</h3>
      <ol className="ruta">
        {pasos.filter((p) => p.id !== 'inicio').map((p) => (
          <li key={p.id}>
            <button type="button" className="ruta-item" onClick={() => ir(p.id)}>
              <span className={`punto punto-${p.estado}`} />
              <span className="ruta-num"><Icono nombre={ICONO_PASO[p.id]} tam={16} /></span>
              <span className="ruta-tit">{p.titulo}</span>
              <span className="ruta-pdf">{p.pdf}</span>
            </button>
          </li>
        ))}
      </ol>

      <h3><Icono nombre="enlace" tam={18} /> Sigue un riesgo de punta a punta</h3>
      <p>Elige un riesgo y mira su cadena completa: tarea del DBA, control ISO, evidencia y pruebas.</p>
      <Cadena indice={indice} alAbrir={alAbrir} />
    </>
  );
}
