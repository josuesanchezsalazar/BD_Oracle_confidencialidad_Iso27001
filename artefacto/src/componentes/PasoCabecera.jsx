import Icono, { ICONO_PASO } from './Icono.jsx';

const ETIQUETA = { listo: 'Listo', parcial: 'En curso', pendiente: 'Pendiente' };
const ICONO_ESTADO = { listo: 'check', parcial: 'reloj', pendiente: 'reloj' };

export default function PasoCabecera({ paso }) {
  return (
    <header className="paso-cab">
      <div className="chips-cab">
        <span className="chip-fase">{paso.fase}</span>
        <span className="chip-pdf"><Icono nombre="archivo" tam={13} /> PDF · {paso.pdf}</span>
        <span className={`chip-estado est-${paso.estado}`}><Icono nombre={ICONO_ESTADO[paso.estado]} tam={13} /> {ETIQUETA[paso.estado]}</span>
      </div>
      <h2 id={`t-${paso.id}`}><span className="titulo-icono"><Icono nombre={ICONO_PASO[paso.id]} tam={24} /></span>{paso.titulo}</h2>
      {paso.nota && <p className="estado-paso"><Icono nombre="info" tam={15} /> {paso.nota}</p>}
    </header>
  );
}
