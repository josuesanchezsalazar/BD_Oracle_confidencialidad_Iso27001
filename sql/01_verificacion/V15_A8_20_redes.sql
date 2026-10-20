-- V15 | A8.20 Seguridad de redes
-- Complemento fuera de SQL: guardar 'lsnrctl status' y copia de sqlnet.ora del servidor.
@@_encabezado V15_A8_20

PROMPT --- 1) Adaptadores de red de la sesion actual (debe aparecer cifrado AES256 y checksum)
SELECT network_service_banner
  FROM v$session_connect_info
 WHERE sid = SYS_CONTEXT('USERENV','SID');

PROMPT --- 2) Protocolo de la sesion actual (tcp / tcps)
SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS protocolo,
       SYS_CONTEXT('USERENV','IP_ADDRESS')       AS ip_cliente
  FROM dual;

SPOOL OFF
