-- V07 | A8.2 Derechos de acceso privilegiado
-- Cuentas propias con roles o privilegios elevados (directos o heredados por roles).
@@_encabezado V07_A8_2

PROMPT --- 1) Roles poderosos en cuentas propias (directos o heredados)
SELECT DISTINCT r.usr AS username, r.granted_role
  FROM (SELECT CONNECT_BY_ROOT grantee AS usr, granted_role
          FROM dba_role_privs
        CONNECT BY PRIOR granted_role = grantee) r
 WHERE r.usr IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
   AND r.granted_role IN ('DBA','IMP_FULL_DATABASE','EXP_FULL_DATABASE',
                          'DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE',
                          'SELECT_CATALOG_ROLE','AUDIT_ADMIN','PDB_DBA')
 ORDER BY 1, 2;

PROMPT --- 2) Privilegios de sistema peligrosos otorgados DIRECTO a cuentas o roles propios
SELECT grantee, privilege, admin_option
  FROM dba_sys_privs
 WHERE grantee IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N'
                   UNION SELECT role FROM dba_roles WHERE oracle_maintained = 'N')
   AND (privilege LIKE '%ANY%'
        OR privilege IN ('ALTER USER','BECOME USER','ALTER SYSTEM','ALTER DATABASE',
                         'EXEMPT ACCESS POLICY','EXEMPT REDACTION POLICY','AUDIT SYSTEM'))
 ORDER BY grantee, privilege;

PROMPT --- 3) Cantidad de privilegios peligrosos efectivos por cuenta propia (incluye roles)
SELECT r.usr AS username, COUNT(DISTINCT sp.privilege) AS privilegios_peligrosos
  FROM (SELECT username AS usr, username AS origen FROM dba_users WHERE oracle_maintained = 'N'
        UNION ALL
        SELECT CONNECT_BY_ROOT grantee, granted_role
          FROM dba_role_privs
        CONNECT BY PRIOR granted_role = grantee) r
  JOIN dba_sys_privs sp ON sp.grantee = r.origen
 WHERE r.usr IN (SELECT username FROM dba_users WHERE oracle_maintained = 'N')
   AND (sp.privilege LIKE '%ANY%'
        OR sp.privilege IN ('ALTER USER','BECOME USER','ALTER SYSTEM','ALTER DATABASE',
                            'EXEMPT ACCESS POLICY','EXEMPT REDACTION POLICY','AUDIT SYSTEM'))
 GROUP BY r.usr
 ORDER BY 2 DESC;

PROMPT --- 4) Privilegios administrativos del archivo de contrasenas (SYSDBA, SYSBACKUP, SYSKM...)
SELECT username, sysdba, sysoper, sysbackup, sysdg, syskm, account_status
  FROM v$pwfile_users
 ORDER BY username;

SPOOL OFF
