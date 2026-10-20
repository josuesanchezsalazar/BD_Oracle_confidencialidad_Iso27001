import { archivoEvidencia } from '../calculos.js';

export default function EnlaceEvidencia({ indice, prefijo, alAbrir }) {
  if (!prefijo) return <span className="sin-evidencia">evidencia manual</span>;
  const archivo = archivoEvidencia(indice, 'antes', prefijo);
  if (!archivo) return <code>{prefijo}</code>;
  return (
    <button type="button" className="enlace" onClick={() => alAbrir('antes', archivo)} title={archivo}>
      {prefijo}
    </button>
  );
}
