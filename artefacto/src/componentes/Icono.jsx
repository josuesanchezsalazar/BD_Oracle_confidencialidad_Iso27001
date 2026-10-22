// Iconos SVG propios (trazo de 24x24), sin dependencias. Uso: <Icono nombre="escudo" />
const RUTAS = {
  escudo: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
  escudoOk: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z M9 12l2 2 4-4',
  casa: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z M9 22V12h6v10',
  edificio: 'M3 21h18 M5 21V7l8-4v18 M19 21V11l-6-4 M9 9h.01 M9 12h.01 M9 15h.01',
  alerta: 'M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z M12 9v4 M12 17h.01',
  lista: 'M11 6h10 M11 12h10 M11 18h10 M3 6l1 1 2-2 M3 12l1 1 2-2 M3 18l1 1 2-2',
  enlace: 'M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71 M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71',
  ojo: 'M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6',
  cuadricula: 'M3 3h7v7H3z M14 3h7v7h-7z M14 14h7v7h-7z M3 14h7v7H3z',
  matraz: 'M9 3h6 M10 3v6L4.5 19a2 2 0 0 0 1.7 3h11.6a2 2 0 0 0 1.7-3L14 9V3 M7 15h10',
  play: 'M6 4l14 8-14 8z',
  carpeta: 'M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  impresora: 'M6 9V2h12v7 M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2 M6 14h12v8H6z',
  check: 'M20 6L9 17l-5-5',
  x: 'M18 6L6 18 M6 6l12 12',
  reloj: 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20 M12 6v6l4 2',
  copiar: 'M9 9h11v11H9z M5 15H4V4h11v1',
  izquierda: 'M19 12H5 M12 19l-7-7 7-7',
  derecha: 'M5 12h14 M12 5l7 7-7 7',
  info: 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20 M12 16v-4 M12 8h.01',
  idea: 'M9 18h6 M10 22h4 M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.3 1 2.3h6c0-1 .4-1.8 1-2.3A7 7 0 0 0 12 2z',
  base: 'M12 3c4.97 0 9 1.34 9 3s-4.03 3-9 3-9-1.34-9-3 4.03-3 9-3z M3 6v6c0 1.66 4.03 3 9 3s9-1.34 9-3V6 M3 12v6c0 1.66 4.03 3 9 3s9-1.34 9-3v-6',
  candado: 'M5 11h14v10H5z M8 11V7a4 4 0 0 1 8 0v4',
  objetivo: 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20 M12 6a6 6 0 1 0 0 12 6 6 0 0 0 0-12 M12 10a2 2 0 1 0 0 4 2 2 0 0 0 0-4',
  columnas: 'M3 3h18v18H3z M12 3v18',
  terminal: 'M4 17l6-6-6-6 M12 19h8',
  libro: 'M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5z',
  archivo: 'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z M14 2v6h6 M8 13h8 M8 17h8',
  flechaAbajo: 'M12 5v14 M5 12l7 7 7-7',
  ayuda: 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20 M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3 M12 17h.01',
};

export default function Icono({ nombre, tam = 18, className = '', titulo }) {
  const d = RUTAS[nombre];
  if (!d) return null;
  return (
    <svg
      className={`icono ${className}`.trim()}
      width={tam}
      height={tam}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      role={titulo ? 'img' : undefined}
      aria-label={titulo}
      aria-hidden={titulo ? undefined : true}
    >
      {d.split(' M').map((seg, k) => <path key={k} d={k === 0 ? seg : `M${seg}`} />)}
    </svg>
  );
}

// Icono de cada paso del artefacto (por id de pasos.json)
export const ICONO_PASO = {
  inicio: 'casa', contexto: 'edificio', riesgos: 'alerta', tareas: 'lista', mapeo: 'enlace',
  observables: 'ojo', matriz: 'cuadricula', pruebas: 'matraz', evidencias: 'carpeta',
};
