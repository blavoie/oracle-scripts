-- From: http://structureddata.org/2011/08/09/crowdsourcing-active-sql-monitor-reports/
--
-- script to create an Active SQL Monitor Report given a SQL ID
-- 11.2 and newer (EM/ACTIVE types are not in 11.1)
--
set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000 feedback off
spool sqlmon_4vbqtp97hwqk8.html

select dbms_sqltune.report_sql_monitor(report_level=>'ALL', type=>'EM', sql_id=>'&&sqlid') monitor_report from dual;

spool off