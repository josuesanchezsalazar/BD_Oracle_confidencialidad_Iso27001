// Barra horizontal apilada con leyenda. segmentos: [{ etiqueta, valor, clase }]
export default function BarraApilada({ titulo, segmentos }) {
  const total = segmentos.reduce((s, x) => s + x.valor, 0) || 1;
  return (
    <div className="apilada">
      {titulo && <strong>{titulo}</strong>}
      <div className="apilada-barra" role="img" aria-label={segmentos.map((s) => `${s.etiqueta}: ${s.valor}`).join(', ')}>
        {segmentos.filter((s) => s.valor > 0).map((s) => (
          <span key={s.etiqueta} className={s.clase} style={{ flexGrow: s.valor }}>{s.valor}</span>
        ))}
      </div>
      <ul className="apilada-leyenda">
        {segmentos.map((s) => (
          <li key={s.etiqueta}><i className={s.clase} />{s.etiqueta}: {s.valor} de {total}</li>
        ))}
      </ul>
    </div>
  );
}
