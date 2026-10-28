-- R06b paso 1 | Ubicacion del keystore (WALLET_ROOT). Es un parametro ESTATICO: requiere reiniciar la instancia.
-- Antes de ejecutar, la carpeta debe existir:  C:\oracle_lab\wallet\tde
--
-- Uso (desde la RAIZ del repositorio):
--   sqlplus "sys/<clave> as sysdba" "@sql/02_remediacion/R06b_paso1_wallet_root.sql"
-- Despues:  SHUTDOWN IMMEDIATE  y  STARTUP  (desde sqlplus como SYSDBA), y recien entonces R06b_tde.sql
SET ECHO OFF
ALTER SYSTEM SET WALLET_ROOT = 'C:\oracle_lab\wallet' SCOPE = SPFILE;
SELECT name, value FROM v$parameter WHERE name = 'wallet_root';
EXIT
