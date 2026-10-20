export default function Evidencias({ indice, visor, alAbrir }) {
  if (!indice) {
    return <p>Las evidencias se cargan con <code>npm run dev</code> o <code>npm run build</code>, que copian la carpeta <code>evidencias/</code>.</p>;
  }
  return (
    <div className="evidencias">
      <ul>
        {['antes', 'despues'].flatMap((fase) => indice[fase].map((archivo) => (
          <li key={fase + archivo}>
            <button type="button" className={`enlace${visor?.archivo === archivo && visor?.fase === fase ? ' sel' : ''}`} onClick={() => alAbrir(fase, archivo)}>
              {fase}/{archivo}
            </button>
          </li>
        )))}
        {indice.despues.length === 0 && <li><small>La carpeta "despues" se llena en la fase Verificar.</small></li>}
      </ul>
      <div className="visor">
        {visor ? (
          <>
            <h3>{visor.fase}/{visor.archivo}</h3>
            <pre>{visor.texto}</pre>
          </>
        ) : (
          <p>Elige un archivo de la lista para ver la salida real del script, con su fecha, usuario y contenedor.</p>
        )}
      </div>
    </div>
  );
}
