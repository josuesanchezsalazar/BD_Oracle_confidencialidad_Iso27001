import { useState } from 'react';
import Icono from './Icono.jsx';

const CLAVE = 'guia-inicio-cerrada';
const leer = () => { try { return window.localStorage.getItem(CLAVE) === '1'; } catch { return false; } };
const guardar = (v) => { try { window.localStorage.setItem(CLAVE, v ? '1' : '0'); } catch { /* sin almacenamiento */ } };

const PASOS = [
  { icono: 'ayuda', titulo: 'Qué es esto', texto: 'Un proyecto que mide si una base de datos Oracle protege la confidencialidad de sus datos, siguiendo los controles de la norma ISO 27001:2022.' },
  { icono: 'lista', titulo: 'Cómo avanzar', texto: 'Usa el menú de la izquierda o los botones Anterior y Siguiente. Cada paso responde a un punto que pide el PDF del profesor.' },
  { icono: 'edificio', titulo: 'Teoría y ejemplo', texto: 'Primero se explica en general; lo que pasó en el escenario ficticio sale en recuadros verdes. El interruptor de arriba los oculta.' },
  { icono: 'escudoOk', titulo: 'ANTES y DESPUÉS', texto: 'ANTES es el diagnóstico con fallas. DESPUÉS es la misma medición tras corregirlas. La comparación está en el paso Evidencias.' },
];

const GLOSARIO = [
  ['R-CONF', 'Riesgo de confidencialidad (R-CONF-01 a 06).'],
  ['Control A5.15 / A8.2', 'Medida de seguridad del Anexo A de ISO 27001:2022.'],
  ['V01–V17', 'Scripts SQL que verifican un control y guardan su salida.'],
  ['Madurez 0–4', '0 no existe · 2 documentado · 3 implementado y verificado · 4 gestionado.'],
  ['DBA', 'Administrador de la base de datos.'],
  ['PHVA', 'Planificar, Hacer, Verificar, Actuar: el ciclo del proyecto.'],
];

export default function GuiaInicio() {
  const [cerrada, setCerrada] = useState(leer);
  const alternar = () => { setCerrada((c) => { guardar(!c); return !c; }); };

  return (
    <section className="guia" aria-label="Guía para quien ve el artefacto por primera vez">
      <button type="button" className="guia-cab" onClick={alternar} aria-expanded={!cerrada}>
        <span><Icono nombre="idea" tam={18} /> ¿Primera vez aquí? Guía de 1 minuto</span>
        <span className="guia-estado">{cerrada ? 'Mostrar' : 'Ocultar'}</span>
      </button>
      {!cerrada && (
        <div className="guia-cuerpo">
          <ol className="guia-pasos">
            {PASOS.map((p, k) => (
              <li key={p.titulo}>
                <span className="guia-num">{k + 1}</span>
                <Icono nombre={p.icono} tam={20} className="guia-icono" />
                <strong>{p.titulo}</strong>
                <p>{p.texto}</p>
              </li>
            ))}
          </ol>
          <details className="glosario">
            <summary>Glosario rápido</summary>
            <dl>{GLOSARIO.map(([t, d]) => (<div key={t}><dt>{t}</dt><dd>{d}</dd></div>))}</dl>
          </details>
        </div>
      )}
    </section>
  );
}
