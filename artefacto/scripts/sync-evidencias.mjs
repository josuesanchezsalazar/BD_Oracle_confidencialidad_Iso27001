// Copia ../evidencias/{antes,despues}/*.txt a public/evidencias y genera un indice
// para que el artefacto pueda listar y mostrar las salidas reales de los scripts V-xx.
import { cpSync, existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
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
