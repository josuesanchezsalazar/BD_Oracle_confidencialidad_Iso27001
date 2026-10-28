// Copia ../evidencias/{antes,despues}/*.txt a public/evidencias y genera un indice
// para que el artefacto pueda listar y mostrar las salidas reales de los scripts V-xx.
// Tambien copia los scripts de ../sql listados en src/data/scripts.json a public/scripts (sin _claves.sql).
import { cpSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = join(dirname(fileURLToPath(import.meta.url)), '..');
const origen = join(raiz, '..', 'evidencias');
const destino = join(raiz, 'public', 'evidencias');

rmSync(destino, { recursive: true, force: true });
const indice = {};
for (const fase of ['antes', 'despues']) {
  const carpeta = join(origen, fase);
  mkdirSync(join(destino, fase), { recursive: true });
  indice[fase] = existsSync(carpeta)
    ? readdirSync(carpeta).filter((f) => f.endsWith('.txt')).sort()
    : [];
  for (const archivo of indice[fase]) {
    cpSync(join(carpeta, archivo), join(destino, fase, archivo));
  }
}
writeFileSync(join(destino, 'index.json'), JSON.stringify(indice, null, 2));
console.log(`Evidencias sincronizadas: ${indice.antes.length} antes, ${indice.despues.length} despues`);

// ---- Scripts del repositorio (creacion, verificacion, solucion, pruebas) ----
const sql = join(raiz, '..', 'sql');
const destinoScripts = join(raiz, 'public', 'scripts');
const etapas = JSON.parse(readFileSync(join(raiz, 'src', 'data', 'scripts.json'), 'utf8')).etapas;
const EXCLUIDOS = new Set(['02_remediacion/_claves.sql']); // contrasenas de laboratorio: no se publican
const listados = new Set(etapas.flatMap((e) => e.archivos));
const sinListar = [];
for (const carpeta of readdirSync(sql, { withFileTypes: true }).filter((d) => d.isDirectory())) {
  for (const f of readdirSync(join(sql, carpeta.name))) {
    const ruta = `${carpeta.name}/${f}`;
    if (/\.(sql|ps1|rman)$/.test(f) && !listados.has(ruta) && !EXCLUIDOS.has(ruta)) sinListar.push(ruta);
  }
}
if (sinListar.length) console.warn(`AVISO: scripts sin listar en scripts.json: ${sinListar.join(', ')}`);

rmSync(destinoScripts, { recursive: true, force: true });
const cabecera = (texto) => texto.split(/\r?\n/).slice(0, 3).filter((l) => /^\s*(--|#)/.test(l)).map((l) => l.replace(/^\s*(--|#)+\s*/, '').trim()).filter((l) => l && !/^=+$/.test(l))[0] ?? '';
const indiceScripts = {};
for (const ruta of listados) {
  if (EXCLUIDOS.has(ruta)) throw new Error(`${ruta} no se puede publicar`);
  const fuente = join(sql, ruta);
  if (!existsSync(fuente)) throw new Error(`scripts.json lista un archivo que no existe: sql/${ruta}`);
  mkdirSync(dirname(join(destinoScripts, ruta)), { recursive: true });
  cpSync(fuente, join(destinoScripts, ruta));
  indiceScripts[ruta] = { cabecera: cabecera(readFileSync(fuente, 'utf8')) };
}
writeFileSync(join(destinoScripts, 'index.json'), JSON.stringify(indiceScripts, null, 2));
console.log(`Scripts sincronizados: ${listados.size}`);
