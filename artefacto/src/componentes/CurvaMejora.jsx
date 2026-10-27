import { useMemo, useState } from 'react';
import { serieCurva } from '../calculos.js';
import Icono from './Icono.jsx';

// Geometria del grafico (unidades del viewBox)
const W = 760, H = 360, M = { izq: 44, der: 24, arr: 18, aba: 54 };
const MARCAS = ['circle', 'square', 'diamond', 'triangle', 'circle', 'square'];

const marca = (tipo, x, y, r, props) => {
  if (tipo === 'square') return <rect x={x - r} y={y - r} width={2 * r} height={2 * r} {...props} />;
  if (tipo === 'diamond') return <path d={`M${x} ${y - r - 1}L${x + r + 1} ${y}L${x} ${y + r + 1}L${x - r - 1} ${y}Z`} {...props} />;
  if (tipo === 'triangle') return <path d={`M${x} ${y - r - 1}L${x + r + 1} ${y + r}L${x - r - 1} ${y + r}Z`} {...props} />;
  return <circle cx={x} cy={y} r={r} {...props} />;
};

export default function CurvaMejora() {
  const serie = useMemo(serieCurva, []);
  const [oculta, setOculta] = useState(() => new Set());
  const [foco, setFoco] = useState(null);
  const n = serie.bloques.length;
  const ultimo = n - 1;
  const x = (i) => M.izq + (i * (W - M.izq - M.der)) / (n - 1);
  const y = (v) => M.arr + ((4 - v) * (H - M.arr - M.aba)) / 4;
  const ruta = (valores) => valores.map((v, i) => `${i ? 'L' : 'M'}${x(i).toFixed(1)} ${y(v).toFixed(1)}`).join(' ');
  const alternar = (id) => setOculta((s) => {
    const c = new Set(s);
    if (c.has(id)) c.delete(id); else c.add(id);
    return c;
  });

  const lineas = [
    ...serie.riesgos.map((r, k) => ({ id: r.id, etiqueta: r.id, nombre: r.nombre, valores: r.valores, color: `var(--serie-${k + 1})`, marca: MARCAS[k], ancho: 2 })),
    { id: 'promedio', etiqueta: 'Promedio de los 20 controles', nombre: 'Promedio', valores: serie.promedio, color: 'var(--texto)', marca: 'circle', ancho: 4.5 },
  ];

  return (
    <figure className="curva" aria-labelledby="curva-titulo">
      <figcaption id="curva-titulo">
        <strong>Madurez media (0–4) de los controles que tratan cada riesgo, tras cada bloque de remediación</strong>
        <span>Un punto relleno es una medición real con los scripts V01–V17. Un punto hueco es un valor <em>calculado</em>, no medido.</span>
      </figcaption>

      <div className="curva-leyenda" role="group" aria-label="Series visibles">
        {lineas.map((l) => (
          <button key={l.id} type="button" className={`curva-serie${oculta.has(l.id) ? ' apagada' : ''}`}
            aria-pressed={!oculta.has(l.id)} onClick={() => alternar(l.id)}
            onMouseEnter={() => setFoco(l.id)} onMouseLeave={() => setFoco(null)} title={l.nombre}>
            <i style={{ background: l.color }} /> {l.etiqueta}
          </button>
        ))}
        <span className="curva-serie meta"><i className="punteada" /> Meta promedio ({serie.meta.toFixed(2)})</span>
      </div>

      <div className="curva-lienzo">
        <svg viewBox={`0 0 ${W} ${H}`} role="img" aria-label={`Curva de madurez: el promedio pasa de ${serie.promedio[0]} a ${serie.promedio[ultimo]} sobre una meta de ${serie.meta}`}>
          {[0, 1, 2, 3, 4].map((v) => (
            <g key={v}>
              <line className="curva-rejilla" x1={M.izq} x2={W - M.der} y1={y(v)} y2={y(v)} />
              <text className="curva-eje" x={M.izq - 8} y={y(v) + 4} textAnchor="end">{v}</text>
            </g>
          ))}

          {serie.bloques.map((b, i) => (
            <g key={b.id}>
              <line className="curva-guia" x1={x(i)} x2={x(i)} y1={M.arr} y2={H - M.aba} />
              <text className={`curva-eje${b.medido ? ' medido' : ''}`} x={x(i)} y={H - M.aba + 20} textAnchor="middle">{b.etiqueta}</text>
              <text className="curva-eje peq" x={x(i)} y={H - M.aba + 35} textAnchor="middle">{b.medido ? 'medido' : 'calculado'}</text>
            </g>
          ))}

          <line className="curva-meta" x1={M.izq} x2={W - M.der} y1={y(serie.meta)} y2={y(serie.meta)} />
          <text className="curva-eje meta" x={W - M.der} y={y(serie.meta) - 6} textAnchor="end">meta {serie.meta.toFixed(2)}</text>

          {lineas.filter((l) => !oculta.has(l.id)).map((l) => (
            <g key={l.id} className={`curva-linea${foco && foco !== l.id ? ' atenuada' : ''}`}>
              <path d={ruta(l.valores)} fill="none" stroke={l.color} strokeWidth={l.ancho} strokeLinejoin="round" strokeLinecap="round" />
              {l.valores.map((v, i) => {
                const medido = serie.bloques[i].medido;
                return (
                  <g key={serie.bloques[i].id}>
                    {marca(l.marca, x(i), y(v), l.id === 'promedio' ? 5.5 : 4, { fill: medido ? l.color : 'var(--tarjeta)', stroke: l.color, strokeWidth: 2 })}
                    <title>{`${l.etiqueta} · ${serie.bloques[i].etiqueta} (${medido ? 'medido' : 'calculado'}): ${v.toFixed(2)}`}</title>
                  </g>
                );
              })}
            </g>
          ))}
        </svg>
      </div>

      <p className="curva-nota">
        <Icono nombre="info" tam={14} /> Los puntos intermedios se calculan así: cada control conserva su nivel ANTES hasta el bloque que lo remedia
        y desde ahí vale su nivel DESPUÉS. El último punto coincide con la matriz de evaluación.
      </p>

      <details className="curva-tabla">
        <summary>Ver los números de la curva</summary>
        <div className="tabla-scroll">
          <table>
            <thead>
              <tr>
                <th>Bloque</th>
                <th>Qué se hizo</th>
                {serie.riesgos.map((r) => <th key={r.id} title={r.nombre}>{r.id.replace('R-CONF-', 'R')}</th>)}
                <th>Promedio</th>
              </tr>
            </thead>
            <tbody>
              {serie.bloques.map((b, i) => (
                <tr key={b.id}>
                  <td><strong>{b.etiqueta}</strong> <small>{b.medido ? `medido ${b.fecha}` : 'calculado'}</small></td>
                  <td>{b.nombre}</td>
                  {serie.riesgos.map((r) => <td key={r.id}>{r.valores[i].toFixed(2)}</td>)}
                  <td><strong>{serie.promedio[i].toFixed(2)}</strong></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </details>
    </figure>
  );
}
