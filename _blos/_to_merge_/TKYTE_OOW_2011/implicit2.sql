drop table t;

create table t 
( x varchar2(20) constraint t_pk primary key,
  y varchar2(30) 
);

insert into t 
select user_id, username 
  from all_users;
commit;


declare
	l_rec t%rowtype;
	l_key number := 5;
begin
	select * into l_rec from t where x = l_key;

	for x in (select plan_table_output 
	            from TABLE( dbms_xplan.display_cursor() ) )
	loop
		dbms_output.put_line( '.'||x.plan_table_output );
	end loop;
end;
/
		



  



  
declare
	l_rec t%rowtype;
	l_key varchar2(20) := '5';
begin
	select * into l_rec from t where x = l_key;

	for x in (select plan_table_output 
	            from TABLE( dbms_xplan.display_cursor() ) )
	loop
		dbms_output.put_line( '.'||x.plan_table_output );
	end loop;
end;
/
		
