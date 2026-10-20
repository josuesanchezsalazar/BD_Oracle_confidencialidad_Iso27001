import { org } from '../data.js';
import EnlaceEvidencia from '../componentes/EnlaceEvidencia.jsx';

// Todo este paso es el escenario de prueba, por eso no se oculta con el interruptor.
export default function Contexto({ indice, alAbrir }) {
  return (
    <>
      <p className="aviso-ejemplo">Este paso describe el <strong>escenario de prueba</strong>. No forma parte de la teoría general: es el ejemplo con el que se miden los controles.</p>
      <h3>{org.nombre}</h3>
      <p>{org.descripcion}</p>
      <h3>Columna de alta sensibilidad: <code>{org.columnaCritica}</code></h3>
      <p>{org.justificacionColumna}</p>

      <h3>Clasificación de los datos (A5.12 y Ley 8968)</h3>
      <table>
        <thead><tr><th>Tabla</th><th>Columnas</th><th>Nivel</th><th>Categoría Ley 8968</th></tr></thead>
        <tbody>{org.clasificacion.map((c) => (
          <tr key={c.tabla + c.columnas}><td>{c.tabla}</td><td>{c.columnas}</td><td>{c.nivel}</td><td>{c.ley8968}</td></tr>
        ))}</tbody>
      </table>

      <h3>Actores y cuentas</h3>
      <table>
        <thead><tr><th>Actor</th><th>Cuenta</th><th>Debe</th><th>No debe</th></tr></thead>
        <tbody>{org.actores.map((a) => (
          <tr key={a.actor}><td>{a.actor}</td><td><code>{a.cuenta}</code></td><td>{a.debe}</td><td>{a.noDebe}</td></tr>
        ))}</tbody>
      </table>

      <h3>Malas prácticas sembradas (estado ANTES)</h3>
      <table>
        <thead><tr><th>ID</th><th>Mala práctica</th><th>Consecuencia</th><th>Riesgo</th><th>Controles</th></tr></thead>
        <tbody>{org.malasPracticas.map((m) => (
          <tr key={m.id}><td>{m.id}</td><td>{m.practica}</td><td>{m.consecuencia}</td><td>{m.riesgo}</td><td>{m.controles.join(', ')}</td></tr>
        ))}</tbody>
      </table>

      <h3>Hallazgos reales del diagnóstico (no sembrados)</h3>
      <p>Estas fallas no las puse yo: las encontraron los scripts de verificación. Son la mejor prueba de que los scripts auditan de verdad.</p>
      <table>
        <thead><tr><th>Hallazgo</th><th>Control</th><th>Evidencia</th></tr></thead>
        <tbody>{org.hallazgosReales.map((h) => (
          <tr key={h.hallazgo}><td>{h.hallazgo}</td><td>{h.control}</td><td><EnlaceEvidencia indice={indice} prefijo={h.evidencia} alAbrir={alAbrir} /></td></tr>
        ))}</tbody>
      </table>
    </>
  );
}
