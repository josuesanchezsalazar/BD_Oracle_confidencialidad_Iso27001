import { useState } from 'react';
import { pares, controles } from '../data.js';
import { estado, NOMBRES_MADUREZ } from '../calculos.js';
import BarraMadurez from '../componentes/BarraMadurez.jsx';
import BarraApilada from '../componentes/BarraApilada.jsx';
import Insignia from '../componentes/Insignia.jsx';
import Icono from '../componentes/Icono.jsx';
import EnlaceEvidencia from '../componentes/EnlaceEvidencia.jsx';

// Explica la matriz con una fila real de ejemplo, para quien la ve por primera vez.
function ComoLeer() {
  const ejemplo = controles.find((c) => c.id === 'A8.2');
  const m = ejemplo.madurez;
  return (
    <details className="como-matriz" open>
      <summary><Icono nombre="ayuda" tam={16} /> ¿Cómo se lee esta matriz? (1 minuto)</summary>
      <p>
        Cada fila responde una sola pregunta: <strong>"¿esta tarea del DBA tiene aplicado su control de seguridad, y puedo demostrarlo?"</strong>
      </p>
      <ol className="pasos-matriz">
        <li><strong>Tarea y Riesgo:</strong> qué hace el DBA y qué podría salir mal si lo hace mal.</li>
        <li><strong>Control:</strong> la medida de ISO 27001:2022 que previene ese riesgo.</li>
        <li><strong>Criterio 0-4:</strong> qué tan bien está aplicado. Es una escala de madurez:
          <ul>{NOMBRES_MADUREZ.map((n, k) => <li key={n}><b>{k}</b> {n}</li>)}</ul>
        </li>
        <li><strong>Evidencia:</strong> el archivo con la salida real del script SQL que lo demuestra, ANTES y DESPUÉS de corregir.</li>
        <li><strong>Estado:</strong> el resultado en una palabra. 0–1 <em>No cumple</em> · 2 <em>Parcial</em> · 3–4 <em>Cumple</em>.</li>
      </ol>
      <div className="ejemplo-matriz">
        <strong>Ejemplo con una fila real: {ejemplo.id} {ejemplo.nombre}</strong>
        <p>ANTES: nivel <b>{m.antes}</b> (No cumple). {m.justAntes}.</p>
        {m.despues !== undefined && <p>DESPUÉS: nivel <b>{m.despues}</b> ({estado(m.despues)}). {m.justDespues}.</p>}
        <p><small>Las barras de abajo se llenan hasta el nivel logrado. El recuadro punteado <span className="meta-muestra">meta</span> marca el nivel que se quiere alcanzar. El control mejoró cuando el relleno llega a la meta.</small></p>
      </div>
    </details>
  );
}

const FASES = [
  { id: 'antes', nombre: 'Antes de la evaluación', icono: 'alerta', ayuda: 'Estado inicial medido con los scripts V01–V17 sobre la base con fallas.' },
  { id: 'despues', nombre: 'Después de la evaluación', icono: 'escudoOk', ayuda: 'Estado tras aplicar las correcciones, medido con los mismos scripts.' },
];

export default function Matriz({ indice, alAbrir }) {
  const [fase, setFase] = useState('antes');
  const antes = fase === 'antes';
  // Nivel de madurez y justificación de la fase elegida (en DESPUÉS puede no existir todavía)
  const nivelDe = (c) => (antes ? c.madurez.antes : c.madurez.despues);
  const justDe = (c) => (antes ? c.madurez.justAntes : c.madurez.justDespues);
  const medidos = controles.filter((c) => nivelDe(c) !== undefined);
  const cuenta = (e) => medidos.filter((c) => estado(nivelDe(c)) === e).length;
  const info = FASES.find((f) => f.id === fase);

  return (
    <>
      <ComoLeer />

      <div className="pestanas" role="tablist" aria-label="Fase de la evaluación">
        {FASES.map((f) => (
          <button key={f.id} type="button" role="tab" aria-selected={fase === f.id} className={fase === f.id ? 'sel' : ''} onClick={() => setFase(f.id)}>
            <Icono nombre={f.icono} tam={15} /> {f.nombre}
          </button>
        ))}
      </div>
      <p className="nota-ad">{info.ayuda}</p>

      <BarraApilada
        titulo={`${info.nombre}: estado de los ${controles.length} controles`}
        segmentos={[
          { etiqueta: 'No cumple', valor: cuenta('No cumple'), clase: 'est-falla' },
          { etiqueta: 'Parcial', valor: cuenta('Parcial'), clase: 'est-parcial' },
          { etiqueta: 'Cumple', valor: cuenta('Cumple'), clase: 'est-cumple' },
          ...(antes ? [] : [{ etiqueta: 'Sin medir aún', valor: controles.length - medidos.length, clase: 'est-pendiente' }]),
        ]}
      />

      <table>
        <thead><tr><th>Tarea</th><th>Riesgo</th><th>Control</th><th>Criterio 0-4</th><th>Evidencia</th><th>Estado</th></tr></thead>
        <tbody>{pares.map(({ tarea, control, riesgos }) => {
          const nivel = nivelDe(control);
          return (
            <tr key={`${tarea.id}-${control.id}`}>
              <td><strong>{tarea.id}</strong> {tarea.tarea}</td>
              <td>{riesgos.join(', ')}</td>
              <td><strong>{control.id}</strong> {control.nombre}</td>
              <td>
                {nivel !== undefined ? (
                  <>
                    <BarraMadurez antes={nivel} meta={control.madurez.meta} />
                    <small className="ejemplo-txt">{justDe(control)}</small>
                  </>
                ) : (
                  <span className="pendiente-chip"><Icono nombre="reloj" tam={12} /> Sin medir aún</span>
                )}
              </td>
              <td><EnlaceEvidencia indice={indice} prefijo={control.script} alAbrir={alAbrir} fase={fase} /></td>
              <td><Insignia valor={nivel !== undefined ? estado(nivel) : 'Pendiente'} /></td>
            </tr>
          );
        })}</tbody>
      </table>
      <p><small>{pares.length} filas: una por cada par tarea–control. Un mismo control aparece en varias filas cuando lo aplican varias tareas. Cambia de pestaña para ver el mismo cuadro antes y después de corregir.</small></p>
    </>
  );
}
