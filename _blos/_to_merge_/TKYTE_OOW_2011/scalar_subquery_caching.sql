set echo on
set linesize 1000

column ci format a10

drop table t;

create table t
as
select * 
  from all_objects;
begin
    dbms_stats.gather_table_stats( user,'T' );
end;
/


create or replace function f( x in varchar2 ) 
return number
as
begin
    dbms_application_info.set_client_info
    ( to_number(userenv('client_info'))+1 );

    return length(x);
end;
/


variable startcpu number;
begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/

set autotrace traceonly statistics
select owner, f(owner) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;


begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/
set autotrace traceonly statistics
select owner, (select f(owner) from dual) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;

create or replace function f( x in varchar2 ) 
return number
DETERMINISTIC
as
begin
    dbms_application_info.set_client_info
    ( to_number(userenv('client_info'))+1 );

    return length(x);
end;
/

begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/
set autotrace traceonly statistics
select owner, f(owner) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;

create or replace function f( x in varchar2 ) 
return number
RESULT_CACHE
as
begin
    dbms_application_info.set_client_info
    ( to_number(userenv('client_info'))+1 );

    return length(x);
end;
/

begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/
set autotrace traceonly statistics
select owner, f(owner) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;

begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/
set autotrace traceonly statistics
select owner, f(owner) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;

begin
    dbms_application_info.set_client_info(0);
    :startcpu := dbms_utility.get_cpu_time;
end;
/
set autotrace traceonly statistics
select owner, (select f(owner) from dual) from t;
set autotrace off
select userenv('client_info') ci, 
       dbms_utility.get_cpu_time-:startcpu cpu
  from dual;

