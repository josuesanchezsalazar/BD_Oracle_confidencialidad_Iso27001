import Icono from './Icono.jsx';
import { claseEstado } from '../calculos.js';

const ICONO = { 'No cumple': 'x', Falla: 'x', Parcial: 'reloj', Pendiente: 'reloj', Cumple: 'check' };

// Insignia de estado (No cumple / Parcial / Cumple / Falla / Pendiente) con icono: no depende solo del color.
export default function Insignia({ valor }) {
  return (
    <span className={claseEstado(valor)}>
      <Icono nombre={ICONO[valor] ?? 'info'} tam={13} />
      {valor}
    </span>
  );
}
