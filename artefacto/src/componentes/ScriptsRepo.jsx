import { useEffect, useState } from 'react';
import { scriptsData } from '../data.js';
import { archivoEvidencia } from '../calculos.js';
import Icono from './Icono.jsx';

// "01_verificacion/V15_A8_20_redes.sql" -> "V15_A8_20" (prefijo de su evidencia); V00 y los demas no tienen.
const prefijoEvidencia = (ruta) => {
  const nombre = ruta.split('/').pop();
  return /^V(0[1-9]|1[0-7])_/.test(nombre) ? nombre.split('_').slice(0, 3).join('_') : null;
};

export function Copiar({ texto, etiqueta = 'Copiar' }) {
  const [ok, setOk] = useState(false);
  const copiar = () => {
    navigator.clipboard?.writeText(texto).then(() => { setOk(true); setTimeout(() => setOk(false), 1500); }).catch(() => {});
  };
  return (
    <button type="button" className="boton chico" onClick={copiar}>
      <Icono nombre={ok ? 'check' : 'copiar'} tam={13} /> {ok ? 'Copiado' : etiqueta}
    </button>
  );
}

export default function ScriptsRepo({ indice, abrirSalida }) {
  const [indiceScripts, setIndiceScripts] = useState(null);
  const [sel, setSel] = useState(null);
  const [texto, setTexto] = useState('');
  const [error, setError] = useState(false);

  useEffect(() => {
    fetch('./scripts/index.json').then((r) => (r.ok ? r.json() : null)).then(setIndiceScripts).catch(() => setIndiceScripts(null));
  }, []);

  const abrir = (ruta) => {
    setSel(ruta); setTexto(''); setError(false);
    fetch(`./scripts/${ruta}`).then((r) => (r.ok ? r.text() : Promise.reject())).then(setTexto).catch(() => setError(true));
  };

  const total = scriptsData.etapas.reduce((n, e) => n + e.archivos.length, 0);

  return (
    <>
      <p className="nota-ad">
        Los {total} scripts del repositorio, en el orden en que se usan: <strong>crear</strong> el escenario, <strong>verificar</strong> las fallas (ANTES),
        <strong> solucionar</strong> por bloques y <strong>verificar de nuevo</strong> (DESPUÉS). Elige uno para ver su código. {scriptsData.nota}
      </p>
      <div className="evidencias scripts-repo">
        <div className="lista-ev">
          {scriptsData.etapas.map((e) => (
            <section key={e.id} className="etapa" aria-label={e.titulo}>
              <h4><span className="etapa-num">{e.numero}</span> <Icono nombre={e.icono} tam={15} /> {e.titulo}</h4>
              <p className="etapa-texto">{e.texto}</p>
              {e.comando && (
                <div className="etapa-cmd">
                  <pre>{e.comando}</pre>
                  <Copiar texto={e.comando} />
                </div>
              )}
              {e.aviso && <p className="etapa-aviso"><Icono nombre="alerta" tam={14} /> {e.aviso}</p>}
              <ul>
                {e.archivos.map((ruta) => {
                  const pref = prefijoEvidencia(ruta);
                  const antes = pref && archivoEvidencia(indice, 'antes', pref);
                  const despues = pref && archivoEvidencia(indice, 'despues', pref);
                  return (
                    <li key={ruta}>
                      <button type="button" className={`enlace${sel === ruta ? ' sel' : ''}`} onClick={() => abrir(ruta)}>
                        <Icono nombre="archivo" tam={13} /> {ruta.split('/').pop()}
                      </button>
                      {indiceScripts?.[ruta]?.cabecera && <small className="etapa-cab">{indiceScripts[ruta].cabecera}</small>}
                      {(antes || despues) && (
                        <span className="etapa-salidas">
                          Salida: {antes && <button type="button" className="enlace" onClick={() => abrirSalida('antes', antes)}>ANTES</button>}
                          {antes && despues && ' · '}
                          {despues && <button type="button" className="enlace" onClick={() => abrirSalida('despues', despues)}>DESPUÉS</button>}
                        </span>
                      )}
                    </li>
                  );
                })}
              </ul>
            </section>
          ))}
        </div>

        <div className="visor">
          {!sel && (
            <div className="vacio">
              <Icono nombre="terminal" tam={28} />
              <p>Elige un script de la lista para ver su código tal como está en la carpeta <code>sql/</code>.</p>
            </div>
          )}
          {sel && (
            <>
              <h3 className="visor-cab"><Icono nombre="terminal" tam={16} /> sql/{sel} {texto && <Copiar texto={texto} etiqueta="Copiar script" />}</h3>
              {error && <p className="aviso-ejemplo">No se pudo cargar el script. Se copia al ejecutar <code>npm run dev</code> o <code>npm run build</code>.</p>}
              {!error && <pre>{texto || 'Cargando…'}</pre>}
            </>
          )}
        </div>
      </div>
    </>
  );
}
