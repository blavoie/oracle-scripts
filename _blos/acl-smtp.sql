-- http://www.oracle-base.com/articles/11g/FineGrainedAccessToNetworkServices_11gR1.php#open_acl

create  procedure mailserver_acl(
  aacl       varchar2,
  acomment   varchar2,
  aprincipal varchar2,
  aisgrant   boolean,
  aprivilege varchar2,
  aserver    varchar2,
  aport      number)
is
begin  
  begin
    dbms_network_acl_admin.drop_acl(aacl);
     dbms_output.put_line('ACL dropped.....'); 
  exception
    when others then
      dbms_output.put_line('Error dropping ACL: '||aacl);
      dbms_output.put_line(sqlerrm);
  end;
  begin
    dbms_network_acl_admin.create_acl(aacl,acomment,aprincipal,aisgrant,aprivilege);
    dbms_output.put_line('ACL created.....'); 
  exception
    when others then
      dbms_output.put_line('Error creating ACL: '||aacl);
      dbms_output.put_line(sqlerrm);
  end;  
  begin
    dbms_network_acl_admin.assign_acl(aacl,aserver,aport);
    dbms_output.put_line('ACL assigned.....');         
  exception
    when others then
      dbms_output.put_line('Error assigning ACL: '||aacl);
      dbms_output.put_line(sqlerrm);
  end;    
  commit;
  dbms_output.put_line('ACL commited.....'); 
end;
/
show errors

begin
  mailserver_acl(
    'smtp.xml',
    'ACL for used Email Server to connect',
    'PUBLIC',
    true,
    'connect',
    'smtp.gmail.com',
    587);    
end;
/

drop procedure mailserver_acl;