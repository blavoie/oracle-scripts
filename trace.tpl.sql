alter session set timed_statistics=true;
alter session set max_dump_file_size=unlimited;
alter session set tracefile_identifier='IDENTIFIER';

exec dbms_session.session_trace_enable(waits => true, binds => true);

set termout off

select * 
from   stats_indiv_site_section_cours;

set termout on

exec dbms_session.session_trace_disable;