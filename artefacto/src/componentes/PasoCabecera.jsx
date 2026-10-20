const ETIQUETA = { listo: 'Listo', parcial: 'En curso', pendiente: 'Pendiente' };

export default function PasoCabecera({ paso }) {
  return (
    <header className="paso-cab">
      <div className="chips-cab">
        <span className="chip-fase">{paso.fase}</span>
        <span className="chip-pdf">PDF · {paso.pdf}</span>
        <span className={`chip-estado est-${paso.estado}`}>{ETIQUETA[paso.estado]}</span>
      </div>
      <h2>{paso.titulo}</h2>
      <div className="paso-grid">
        <div className="pide">
          <h3>Lo que pide el PDF</h3>
          <blockquote>{paso.pide}</blockquote>
        </div>
        <div className="resuelve">
          <h3>Cómo lo resolví</h3>
          <p>{paso.solucion}</p>
          {paso.nota && <p className="nota">{paso.nota}</p>}
        </div>
      </div>
    </header>
  );
}
