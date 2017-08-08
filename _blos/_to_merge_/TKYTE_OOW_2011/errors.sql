drop table t;

create table t ( x int check (x>0) );


create or replace procedure noexceptions
as
begin
	insert into t values ( 1 );
	insert into t values ( 0 );
end;
/

create or replace procedure exceptions
as
begin
	insert into t values ( 1 );
	insert into t values ( 0 );
exception
when others
then
	dbms_output.put_line( 'Error!!! ' || sqlerrm );
end;
/

exec noexceptions;
select * from t;
rollback;

exec exceptions
select * from t;
rollback;
