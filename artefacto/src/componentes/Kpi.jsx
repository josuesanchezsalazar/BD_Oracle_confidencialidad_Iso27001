import Icono from './Icono.jsx';

export default function Kpi({ icono, valor, texto, tono = 'neutro' }) {
  return (
    <div className={`kpi kpi-${tono}`}>
      <span className="kpi-icono"><Icono nombre={icono} tam={20} /></span>
      <strong>{valor}</strong>
      <span>{texto}</span>
    </div>
  );
}
