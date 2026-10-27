import Icono from './Icono.jsx';

// Explica, para quien ve el artefacto por primera vez, qué significan ANTES y DESPUÉS.
export default function AvisoDespues({ ir, hayDespues }) {
  return (
    <aside className="aviso-ad" aria-label="Qué significan ANTES y DESPUÉS">
      <div className="ad-col antes">
        <span className="ad-etiqueta"><Icono nombre="alerta" tam={14} /> ANTES</span>
        <p>Diagnóstico inicial. Los scripts V01–V17 se ejecutaron sobre la base <strong>con fallas</strong> y las salidas están guardadas. Es el punto de partida.</p>
        <span className="ad-estado listo"><Icono nombre="check" tam={14} /> Hecho</span>
      </div>
      <div className="ad-flecha" aria-hidden="true"><Icono nombre="derecha" tam={22} /></div>
      <div className="ad-col despues">
        <span className="ad-etiqueta"><Icono nombre="escudoOk" tam={14} /> DESPUÉS</span>
        <p>Se aplican los scripts de remediación (fase <em>Hacer</em>) y se <strong>repiten los mismos scripts</strong>. La comparación demuestra qué mejoró.</p>
        <span className={`ad-estado ${hayDespues ? 'listo' : 'pend'}`}>
          <Icono nombre={hayDespues ? 'check' : 'reloj'} tam={14} /> {hayDespues ? 'Hecho: remediación aplicada y verificada' : 'Pendiente: fase Hacer y Verificar'}
        </span>
      </div>
      {ir && <button type="button" className="boton" onClick={() => ir('evidencias')}>Ver comparación <Icono nombre="derecha" tam={14} /></button>}
    </aside>
  );
}
