import { useState } from 'react';
import { org, pruebas } from '../data.js';
import Insignia from '../componentes/Insignia.jsx';
import BarraApilada from '../componentes/BarraApilada.jsx';
import Icono from '../componentes/Icono.jsx';

const FASES = [
  { id: 'antes', nombre: 'Antes de la evaluación', icono: 'alerta', ayuda: 'Cada prueba se intentó sobre la base con fallas. "Falla" significa que el acceso indebido fue posible: el control todavía no existía.' },
  { id: 'despues', nombre: 'Después de la evaluación', icono: 'escudoOk', ayuda: 'Las mismas pruebas, repetidas tras aplicar las correcciones. "Cumple" significa que el intento indebido fue bloqueado (o que el acceso legítimo funcionó).' },
];

const ORIGEN = {
  ejecutada: 'Ejecutada: se corrió la prueba o su script y hay salida real.',
  inferida: 'Inferida: deducida de la configuración observada; el intento no se corrió.',
  pendiente: 'Pendiente: no se pudo ejecutar todavía (ver el motivo en la fila).',
};

// Estado, resultado y motivo de una prueba según la fase elegida
const datosDe = (p, fase) => (fase === 'antes'
  ? { estado: p.estadoAntes, resultado: p.antes, razon: p.razonAntes, pendiente: p.estadoAntes === 'Pendiente' }
  : { estado: p.estadoDespues ?? 'Pendiente', resultado: p.despues, razon: p.razonDespues, pendiente: !p.estadoDespues });

export default function Pruebas() {
  const [fase, setFase] = useState('antes');
  const antes = fase === 'antes';
  const info = FASES.find((f) => f.id === fase);
  const filas = pruebas.map((p) => ({ p, d: datosDe(p, fase) }));
  const pendientes = filas.filter((f) => f.d.pendiente);
  const cuenta = (e) => filas.filter((f) => f.d.estado === e).length;

  return (
    <>
      <p>
        Una prueba <strong>negativa</strong> intenta algo prohibido y debe fallar; una <strong>positiva</strong> hace algo permitido y debe funcionar.
        A diferencia de los scripts V01–V17 (que leen la configuración), las pruebas demuestran que el control <strong>funciona</strong>.
      </p>

      <div className="pestanas" role="tablist" aria-label="Fase de la evaluación">
        {FASES.map((f) => (
          <button key={f.id} type="button" role="tab" aria-selected={fase === f.id} className={fase === f.id ? 'sel' : ''} onClick={() => setFase(f.id)}>
            <Icono nombre={f.icono} tam={15} /> {f.nombre}
          </button>
        ))}
      </div>
      <p className="nota-ad">{info.ayuda}</p>

      <BarraApilada
        titulo={`${info.nombre}: resultado de las ${pruebas.length} pruebas`}
        segmentos={antes
          ? [
            { etiqueta: 'Falla (acceso indebido posible)', valor: cuenta('Falla'), clase: 'est-falla' },
            { etiqueta: 'Pendiente', valor: cuenta('Pendiente'), clase: 'est-pendiente' },
          ]
          : [
            { etiqueta: 'Cumple', valor: cuenta('Cumple'), clase: 'est-cumple' },
            { etiqueta: 'Falla', valor: cuenta('Falla'), clase: 'est-falla' },
            { etiqueta: 'Pendiente', valor: cuenta('Pendiente'), clase: 'est-pendiente' },
          ]}
      />

      {pendientes.length > 0 && (
        <aside className="pendientes" aria-label="Por qué hay pruebas pendientes">
          <h4><Icono nombre="reloj" tam={16} /> ¿Por qué hay {pendientes.length} pruebas pendientes {antes ? 'en el ANTES' : 'en el DESPUÉS'}?</h4>
          <p>
            Una prueba queda pendiente cuando <strong>no se puede intentar todavía</strong>, no porque se haya olvidado. Se marcan así para no inventar resultados.
          </p>
          <ul>
            {pendientes.map(({ p, d }) => (
              <li key={p.id}><strong>{p.id}</strong> {p.tipo}: {d.razon ?? 'Aún sin ejecutar.'}</li>
            ))}
          </ul>
        </aside>
      )}

      <table>
        <thead>
          <tr>
            <th>ID</th><th>Tipo</th><th>Procedimiento</th><th>Resultado esperado</th><th>Herramienta</th>
            {antes && <th>Origen</th>}
            <th>Estado</th>
            <th className="col-ejemplo">{org.etiquetas.caso}</th>
          </tr>
        </thead>
        <tbody>{filas.map(({ p, d }) => (
          <tr key={p.id} className={d.pendiente ? 'fila-pendiente' : ''}>
            <td className="nowrap">{p.id}</td>
            <td>{p.tipo}<br /><small>{p.control}</small></td>
            <td>{p.procedimiento}</td>
            <td>{p.esperado}</td>
            <td>{p.herramienta}</td>
            {antes && <td title={ORIGEN[p.origen]}>{p.origen}</td>}
            <td><Insignia valor={d.estado} /></td>
            <td className="col-ejemplo">
              <code className="sql">{p.caso}</code>
              {d.pendiente ? <small className="ejemplo-txt">{d.razon ?? 'Aún sin ejecutar.'}</small> : d.resultado}
            </td>
          </tr>
        ))}</tbody>
      </table>
      {antes && <ul className="origen-leyenda">{Object.values(ORIGEN).map((t) => <li key={t}>{t}</li>)}</ul>}
    </>
  );
}
