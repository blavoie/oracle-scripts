create or replace package my_package
as
	procedure p;
end;
/


create or replace package body my_package
as
	g_some_global   varchar2(30);

procedure p
is
begin
	dbms_output.put_line( g_some_global );
end;



begin
	g_some_global := 'result of some logic';
end;
/

exec my_package.p
