set long 10000;
set pagesize 1000
set linesize 200

select dbms_sqltune.report_tuning_task ('&&task_name') as recommendations from dual;

set pagesize 24