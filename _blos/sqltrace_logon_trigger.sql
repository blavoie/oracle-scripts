/*
After creation, be sure to check if SQL_TRACE role is granted to any users (SYS?) and that is not in their default roles list.
Maybe it safer to disable completely the trigger after creation or when not used.

Usage:

grant sql_trace to brlav35;
alter user brlav35 default role all;
alter trigger enable_sql_trace enable;

...

revoke sql_trace from brlav35 ;
alter trigger enable_sql_trace disable;

*/

create role sql_trace;

create or replace trigger enable_sql_trace
   after logon
   on database
begin
   if (dbms_session.is_role_enabled ('SQL_TRACE'))
   then
      execute immediate 'alter session set timed_statistics=true';
      execute immediate 'alter session set max_dump_file_size=unlimited';
	  execute immediate 'alter session set tracefile_identifier="' || user || '-' || to_char(systimestamp,'YYYYMMDDHH24MISSFF') || "'";
	  
	  -- Prefer dbms_session over dbms_monitor, because it's granted to public...
	  dbms_session.session_trace_enable(waits => true, binds => true);
      --dbms_monitor.session_trace_enable(waits => true, binds => true);
   end if;
end;
/

