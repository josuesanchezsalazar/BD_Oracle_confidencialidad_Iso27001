import { useState } from 'react';
import { org, pruebas } from '../data.js';
import { claseEstado } from '../calculos.js';
import BarraApilada from '../componentes/BarraApilada.jsx';

const ORIGEN = {
  ejecutada: 'Ejecutada: se corrió la prueba o su script y hay salida real.',
  inferida: 'Inferida: deducida de la configuración observada; el intento no se ha corrido.',
  pendiente: 'Pendiente: se ejecutará en la fase Hacer o Verificar.',
};

export default function Pruebas() {
  const [origen, setOrigen] = useState('todas');
  const filas = pruebas.filter((p) => origen === 'todas' || p.origen === origen);
  const cuenta = (o) => pruebas.filter((p) => p.origen === o).length;

  return (
    <>
      <p>
        Cada prueba se define en general y se aplica al escenario de prueba. Una prueba negativa debe <strong>fallar</strong> al intentar el acceso indebido.
        "Falla" en el estado ANTES significa que el acceso indebido fue posible: el control todavía no existe.
      </p>
      <BarraApilada
        titulo="Origen del resultado ANTES"
        segmentos={[
          { etiqueta: 'Ejecutadas', valor: cuenta('ejecutada'), clase: 'est-cumple' },
          { etiqueta: 'Inferidas', valor: cuenta('inferida'), clase: 'est-parcial' },
          { etiqueta: 'Pendientes', valor: cuenta('pendiente'), clase: 'est-pendiente' },
        ]}
      />
      <div className="filtros" role="group" aria-label="Filtrar por origen">
        {['todas', 'ejecutada', 'inferida', 'pendiente'].map((o) => (
          <button key={o} type="button" className={o === origen ? 'sel' : ''} onClick={() => setOrigen(o)}>{o}</button>
        ))}
      </div>
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Tipo</th><th>Procedimiento</th><th>Resultado esperado</th><th>Herramienta</th><th>Origen</th><th>Estado ANTES</th>
            <th className="col-ejemplo">{org.etiquetas.caso}</th>
          </tr>
        </thead>
        <tbody>{filas.map((p) => (
          <tr key={p.id}>
            <td className="nowrap">{p.id}</td>
            <td>{p.tipo}<br /><small>{p.control}</small></td>
            <td>{p.procedimiento}</td>
            <td>{p.esperado}</td>
            <td>{p.herramienta}</td>
            <td title={ORIGEN[p.origen]}>{p.origen}</td>
            <td><span className={claseEstado(p.estadoAntes)}>{p.estadoAntes}</span></td>
            <td className="col-ejemplo"><code className="sql">{p.caso}</code>{p.antes}</td>
          </tr>
        ))}</tbody>
      </table>
      <ul className="origen-leyenda">{Object.values(ORIGEN).map((t) => <li key={t}>{t}</li>)}</ul>
    </>
  );
}
