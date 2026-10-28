# R06a | HACER: cifrado de red y verificadores de contrasena modernos (A8.20, A5.17, A8.5)
# DEBE EJECUTARSE COMO ADMINISTRADOR (el archivo vive en una carpeta protegida de Oracle).
#
# Que hace:
#   1. Hace una copia de seguridad de sqlnet.ora junto al original (sqlnet.ora.antes_R06).
#   2. Agrega, sin tocar lo que ya existe:
#        - cifrado de red AES256 obligatorio en el servidor (SQLNET.ENCRYPTION_*)
#        - integridad SHA256 obligatoria (SQLNET.CRYPTO_CHECKSUM_*)
#        - solo verificador de contrasena 12C (SQLNET.ALLOWED_LOGON_VERSION_SERVER = 12a)
#   No requiere reiniciar la base ni el listener: aplica a las conexiones nuevas.
#
# Uso (PowerShell como administrador, desde la raiz del repositorio):
#   powershell -ExecutionPolicy Bypass -File .\sql\02_remediacion\R06a_sqlnet_admin.ps1
#
# Para revertir: copiar sqlnet.ora.antes_R06 sobre sqlnet.ora.

$ruta = 'C:\app\tempadmin\product\21c\homes\OraDB21Home1\NETWORK\ADMIN\sqlnet.ora'
if (-not (Test-Path $ruta)) { throw "No existe $ruta" }

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { throw 'Ejecute este script en PowerShell COMO ADMINISTRADOR.' }

$copia = "$ruta.antes_R06"
if (-not (Test-Path $copia)) { Copy-Item $ruta $copia; Write-Host "Copia de seguridad: $copia" }

$actual = Get-Content $ruta -Raw
if ($actual -match 'SQLNET.ENCRYPTION_SERVER') {
    Write-Host 'sqlnet.ora ya tiene la configuracion de R06a. Nada que hacer.'
    return
}

$bloque = @'

# ---- R06a: seguridad de red (A8.20) y verificadores de contrasena (A5.17, A8.5) ----
SQLNET.ENCRYPTION_SERVER = REQUIRED
SQLNET.ENCRYPTION_TYPES_SERVER = (AES256)
SQLNET.CRYPTO_CHECKSUM_SERVER = REQUIRED
SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER = (SHA256)
SQLNET.ALLOWED_LOGON_VERSION_SERVER = 12a
'@

Add-Content -Path $ruta -Value $bloque
Write-Host 'sqlnet.ora actualizado:'
Get-Content $ruta
