# P04_PT19_tde_observable.ps1 | PT-19 (A8.24*): un texto conocido es visible en un archivo sin cifrar
# y no aparece en el archivo cifrado de TDE ni en las piezas del respaldo RMAN cifrado.
#
# Uso (desde la raiz del repo; la clave de SYS se toma de la variable ORA_SYS_PWD, no se guarda):
#   $env:ORA_SYS_PWD = '<clave>'; .\sql\03_pruebas\P04_PT19_tde_observable.ps1
#
# Pasos: (1) crea un tablespace TEMPORAL sin cifrar con una copia de un nombre real,
#        (2) lo deja OFFLINE para liberar el archivo y lo busca con una lectura binaria,
#        (3) busca el mismo texto en el datafile cifrado y en las piezas del respaldo,
#        (4) elimina el tablespace temporal con su archivo.
param(
    [string]$Texto = 'Maria Monge Campos',
    [string]$Backup = 'C:\oracle_lab\backup',
    [string]$DataDir = 'C:\app\tempadmin\product\21c\oradata\XE\XEPDB1'
)
$ErrorActionPreference = 'Stop'
if (-not $env:ORA_SYS_PWD) { throw 'Defina $env:ORA_SYS_PWD (clave de SYS) antes de ejecutar.' }

Add-Type -TypeDefinition @'
using System; using System.IO;
public static class Buscar {
  public static long Contar(string ruta, byte[] pat) {
    long n = 0; int B = 16*1024*1024; byte[] buf = new byte[B + pat.Length];
    using (var fs = new FileStream(ruta, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
      int keep = 0, r;
      while ((r = fs.Read(buf, keep, B)) > 0) {
        int tot = keep + r;
        for (int i = 0; i <= tot - pat.Length; i++) {
          if (buf[i] != pat[0]) continue;
          int j = 1; while (j < pat.Length && buf[i + j] == pat[j]) j++;
          if (j == pat.Length) n++;
        }
        keep = Math.Min(pat.Length - 1, tot);
        Array.Copy(buf, tot - keep, buf, 0, keep);
      }
    }
    return n;
  }
}
'@

function Invoke-Sql([string]$sql) {
    $f = New-TemporaryFile
    Set-Content $f.FullName -Value ("ALTER SESSION SET CONTAINER = XEPDB1;`nSET LINESIZE 200 PAGESIZE 50`n" + $sql + "`nEXIT") -Encoding ascii
    & sqlplus -s "sys/$($env:ORA_SYS_PWD) as sysdba" "@$($f.FullName)"
    Remove-Item $f.FullName
}

$f_ev = Get-Date -Format 'yyyyMMdd_HHmm'
$out  = "evidencias\despues\P04_PT19_tde_observable_$f_ev.txt"
$pat  = [Text.Encoding]::UTF8.GetBytes($Texto)
$log  = New-Object System.Collections.Generic.List[string]
function Say([string]$m) { Write-Host $m; $log.Add($m) }

Say ('=' * 70)
Say ' PT-19 | A8.24* | TDE observable: el texto aparece en un archivo sin cifrar y no en uno cifrado'
Say " Esperado: sin cifrar > 0 coincidencias; datafile cifrado y piezas del respaldo = 0"
Say " Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   Texto buscado: '$Texto'"
Say ('=' * 70)

# Limpieza previa por si quedo un intento fallido
Invoke-Sql "DROP TABLESPACE ts_pt19_plano INCLUDING CONTENTS AND DATAFILES;" 2>$null | Out-Null

Say '--- 1) Referencia SIN cifrar: tablespace temporal TS_PT19_PLANO'
$r = Invoke-Sql @"
CREATE TABLESPACE ts_pt19_plano DATAFILE '$DataDir\TS_PT19_PLANO.DBF' SIZE 5M;
CREATE TABLE sys.pt19_ref TABLESPACE ts_pt19_plano AS SELECT nombre FROM instituto.estudiantes WHERE nombre = '$Texto';
ALTER SYSTEM CHECKPOINT;
SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name IN ('TS_PT19_PLANO','TS_INSTITUTO');
ALTER TABLESPACE ts_pt19_plano OFFLINE;
"@
$r | ForEach-Object { Say $_ }

$plano = Join-Path $DataDir 'TS_PT19_PLANO.DBF'
Say "Coincidencias en $plano (sin cifrar): $([Buscar]::Contar($plano, $pat))"

Say '--- 2) Datafile cifrado (TDE AES256)'
$cif = Join-Path $DataDir 'TS_INSTITUTO01_CIF.DBF'
try   { Say "Coincidencias en $cif : $([Buscar]::Contar($cif, $pat))" }
catch { Say "No se pudo leer $cif (archivo bloqueado por Oracle): $($_.Exception.Message)" }

Say '--- 3) Piezas del respaldo RMAN cifrado'
Get-ChildItem $Backup -File | ForEach-Object {
    Say ("Coincidencias en {0} ({1:N0} bytes): {2}" -f $_.FullName, $_.Length, [Buscar]::Contar($_.FullName, $pat))
}

Say '--- 4) Limpieza del tablespace temporal'
Invoke-Sql "DROP TABLESPACE ts_pt19_plano INCLUDING CONTENTS AND DATAFILES;`nSELECT COUNT(*) AS quedan FROM dba_tablespaces WHERE tablespace_name='TS_PT19_PLANO';" | ForEach-Object { Say $_ }
Say "Archivo temporal eliminado: $(-not (Test-Path $plano))"

$log | Set-Content $out -Encoding utf8
Write-Host "Evidencia: $out"
