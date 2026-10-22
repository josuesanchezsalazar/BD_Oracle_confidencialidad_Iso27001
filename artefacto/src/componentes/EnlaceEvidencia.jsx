import { archivoEvidencia } from '../calculos.js';

export default function EnlaceEvidencia({ indice, prefijo, alAbrir, fase = 'antes' }) {
  if (!prefijo) return <span className="sin-evidencia">evidencia manual</span>;
  const archivo = archivoEvidencia(indice, fase, prefijo);
  if (!archivo) return fase === 'antes' ? <code>{prefijo}</code> : <span className="pendiente-chip">pendiente</span>;
  return (
    <button type="button" className="enlace" onClick={() => alAbrir(fase, archivo)} title={archivo}>
      {prefijo}
    </button>
  );
}
