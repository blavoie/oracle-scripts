set echo on
set linesize 10000

drop table t;
clear screen

create table t ( x int, y int );

insert into t values ( 1, 0 );
insert into t values ( 2, 0 );
insert into t values ( 3, 0 );
pause

clear screen
create or replace trigger t_bu
before update on t
begin
	dbms_output.put_line
	( 'I am the before trigger firing' );
end;
/
pause

clear screen
create or replace trigger t_bufer
before update on t for each row
begin
	dbms_output.put_line
	( 'BUFER: changing ' || 
	   :old.x || ', ' || :old.y ||
	  ' to ' || :new.x || ', ' || :new.y );
end;
/
pause

clear screen
create or replace trigger t_aufer
after update on t for each row
begin
	dbms_output.put_line
	( 'AUFER: changed ' || 
	   :old.x || ', ' || :old.y ||
	  ' to ' || :new.x || ', ' || :new.y );
end;
/
pause

clear screen
create or replace trigger t_au
after update on t
begin
	dbms_output.put_line
	( 'I am the after trigger firing' );
end;
/
pause

clear screen
set echo off
prompt in another session:
prompt update t set y = 100 where x = 3;;
prompt and come back here and hit enter
pause
clear screen
prompt in the other session:
prompt commit;;
prompt and come back here...
set echo on

update t set y = 42;

