// Recuadro del escenario de prueba. El interruptor "Mostrar ejemplo" (etiqueta en organizacion.json) lo oculta
// (la clase sin-ejemplo en la raiz esconde todo lo que lleve .ejemplo).
import { org } from '../data.js';

export default function Ejemplo({ titulo = org.etiquetas.ejemplo, children }) {
  return (
    <div className="ejemplo">
      <span className="ejemplo-etiqueta">{titulo}</span>
      {children}
    </div>
  );
}
