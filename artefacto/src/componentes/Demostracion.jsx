import { scriptsData } from '../data.js';
import Icono from './Icono.jsx';
import { Copiar } from './ScriptsRepo.jsx';

const { demo } = scriptsData;

// Guía para demostrar en vivo el estado actual (DESPUES). Los pasos salen de scripts.json.
export default function Demostracion() {
  return (
    <>
      <h3 className="demo-tit"><Icono nombre="play" tam={18} /> {demo.titulo}</h3>
      <p className="etapa-aviso"><Icono nombre="alerta" tam={14} /> {demo.aviso}</p>
      <ol className="demo-pasos">
        {demo.pasos.map((p, i) => (
          <li key={p.titulo} className="demo-paso">
            <span className="clave-num" aria-hidden="true">{i + 1}</span>
            <div className="demo-cuerpo">
              <h4>{p.titulo}</h4>
              <small>{p.donde}</small>
              <div className="etapa-cmd">
                <pre>{p.comando}</pre>
                <Copiar texto={p.comando} />
              </div>
              {p.luego && (
                <div className="etapa-cmd">
                  <pre>{p.luego}</pre>
                  <Copiar texto={p.luego} />
                </div>
              )}
              <p className="demo-esperado"><Icono nombre="check" tam={14} /> <span><strong>Debe verse:</strong> {p.esperado}</span></p>
            </div>
          </li>
        ))}
      </ol>
    </>
  );
}
