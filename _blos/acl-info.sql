set linesize 300

column host       format a30
column acl        format a30
column acl        format a30
column principal  format a15

select host, 
       lower_port, 
       upper_port, 
       acl,
       aclid
from   dba_network_acls;

select acl,
       aclid,
       principal,
       privilege,
       is_grant,
       invert,
       to_char(start_date, 'YYYY-MM-DD HH24:MI')  start_date,
       to_char(end_date,   'YYYY-MM-DD HH24:MI')  end_date
from   dba_network_acl_privileges;