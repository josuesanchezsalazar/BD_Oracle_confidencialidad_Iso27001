import { useState } from 'react';
import { controles } from '../data.js';
import { archivoEvidencia } from '../calculos.js';
import Icono from '../componentes/Icono.jsx';
import AvisoDespues from '../componentes/AvisoDespues.jsx';

const PESTANAS = [
  { id: 'comparar', nombre: 'Comparar', icono: 'columnas' },
  { id: 'antes', nombre: 'ANTES', icono: 'alerta' },
  { id: 'despues', nombre: 'DESPUÉS', icono: 'escudoOk' },
];

function Visor({ visor }) {
  if (!visor) {
    return (
      <div className="vacio">
        <Icono nombre="archivo" tam={28} />
        <p>Elige un archivo de la lista para ver la salida real del script, con su fecha, usuario y contenedor.</p>
      </div>
    );
  }
  return (
    <>
      <h3><Icono nombre="terminal" tam={16} /> {visor.fase}/{visor.archivo}</h3>
      <pre>{visor.texto}</pre>
    </>
  );
}

// "V01_A5_12_20261020_1336.txt" -> "20/10/2026 13:36"
const fechaDe = (archivo) => {
  const m = archivo?.match(/_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})\.txt$/);
  return m ? `${m[3]}/${m[2]}/${m[1]} ${m[4]}:${m[5]}` : '';
};

function Comparacion({ indice, alAbrir }) {
  const filas = controles.filter((c) => c.script);
  const celda = (fase, c) => {
    const archivo = archivoEvidencia(indice, fase, c.script);
    const hallazgo = fase === 'antes' ? c.madurez.justAntes : c.madurez.justDespues;
    if (!archivo) {
      return <span className="pendiente-chip"><Icono nombre="reloj" tam={12} /> pendiente</span>;
    }
    return (
      <div className="celda-evid">
        <button type="button" className="enlace" onClick={() => alAbrir(fase, archivo)}>
          <Icono nombre="archivo" tam={13} /> {c.script.split('_')[0]} · {fechaDe(archivo)}
        </button>
        {hallazgo && <small>{hallazgo}</small>}
      </div>
    );
  };
  return (
    <table className="tabla-ad">
      <thead>
        <tr><th>Control</th><th>Madurez</th><th className="col-antes">ANTES (con fallas)</th><th className="col-despues">DESPUÉS (corregido)</th></tr>
      </thead>
      <tbody>{filas.map((c) => (
        <tr key={c.id}>
          <td><strong>{c.id}</strong> {c.nombre}<br /><small>Script {c.script.split('_')[0]}</small></td>
          <td className="nowrap">{c.madurez.antes} → {c.madurez.despues ?? '?'} <small>(meta {c.madurez.meta})</small></td>
          <td>{celda('antes', c)}</td>
          <td>{celda('despues', c)}</td>
        </tr>
      ))}</tbody>
    </table>
  );
}

export default function Evidencias({ indice, visor, alAbrir }) {
  const [pestana, setPestana] = useState('comparar');
  if (!indice) {
    return <p className="aviso-ejemplo">Las evidencias se cargan con <code>npm run dev</code> o <code>npm run build</code>, que copian la carpeta <code>evidencias/</code>.</p>;
  }
  const hayDespues = indice.despues.length > 0;
  const GRUPOS = [
    { id: 'V', titulo: 'Verificación: la salida SQL de cada control', ayuda: 'Un archivo por control (V01–V17). Es la evidencia principal.', abierto: true },
    { id: 'P', titulo: 'Pruebas ejecutadas', ayuda: 'Intentos de acceso con cada cuenta (PT-xx).', abierto: false },
    { id: 'R', titulo: 'Registro de lo que se aplicó (Hacer)', ayuda: 'Qué cambió cada bloque de remediación.', abierto: false },
  ];
  const boton = (fase, archivo) => (
    <li key={archivo}>
      <button type="button" className={`enlace${visor?.archivo === archivo && visor?.fase === fase ? ' sel' : ''}`} onClick={() => alAbrir(fase, archivo)}>
        <Icono nombre="archivo" tam={13} /> {archivo.replace(/_\d{8}_\d{4}\.txt$/, '')}
      </button>
    </li>
  );
  const lista = (fase) => {
    if (indice[fase].length === 0) {
      return (
        <ul className="lista-ev">
          <li className="vacio-lista">
            <Icono nombre="reloj" tam={16} />
            <span>Aún no hay archivos. Se generan al ejecutar <code>V00_ejecutar_todo.sql despues</code> tras la fase Hacer.</span>
          </li>
        </ul>
      );
    }
    return (
      <div className="lista-ev">
        {GRUPOS.map((g) => {
          const archivos = indice[fase].filter((f) => f.startsWith(g.id));
          if (archivos.length === 0) return null;
          return (
            <details key={g.id} open={g.abierto || archivos.some((f) => f === visor?.archivo)}>
              <summary>{g.titulo} <span className="contador">{archivos.length}</span></summary>
              <small>{g.ayuda}</small>
              <ul>{archivos.map((f) => boton(fase, f))}</ul>
            </details>
          );
        })}
      </div>
    );
  };

  return (
    <>
      <AvisoDespues hayDespues={hayDespues} />
      <div className="pestanas" role="tablist" aria-label="Fase de la evidencia">
        {PESTANAS.map((p) => (
          <button key={p.id} type="button" role="tab" aria-selected={pestana === p.id} className={pestana === p.id ? 'sel' : ''} onClick={() => setPestana(p.id)}>
            <Icono nombre={p.icono} tam={15} /> {p.nombre}
            {p.id !== 'comparar' && <span className="contador">{indice[p.id].length}</span>}
          </button>
        ))}
      </div>
      {pestana === 'comparar' && (
        <>
          <p className="nota-ad">Cada fila es un control. El mismo script (por ejemplo V01) se ejecutó dos veces: primero sobre la base con fallas (ANTES) y después de corregir (DESPUÉS). Son dos archivos distintos con la misma consulta; lo que cambia es el resultado, y se resume bajo cada enlace.</p>
          <Comparacion indice={indice} alAbrir={(fase, archivo) => { setPestana(fase); alAbrir(fase, archivo); }} />
        </>
      )}
      {pestana !== 'comparar' && (
        <div className="evidencias">
          {lista(pestana)}
          <div className="visor"><Visor visor={visor} /></div>
        </div>
      )}
    </>
  );
}
