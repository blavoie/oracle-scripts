declare
    l_date  varchar2(30) := '01-jan-2011';
    l_start number;
begin
    l_start := dbms_utility.get_cpu_time;

	for i in 1 .. 10
	loop
    for x in ( select * 
                 from big_table.big_table
                where created = l_date )
    loop
        null;
    end loop;
    end loop;

    dbms_output.put_line( 'CPU: ' || 
    to_char( dbms_utility.get_cpu_time-l_start ) );
end;
/

declare
    l_date  date := to_date( '01-jan-2011', 'dd-mon-yyyy' );
    l_start number;
begin
    l_start := dbms_utility.get_cpu_time;

    for i in 1 .. 10
	loop
	for x in ( select * 
                 from big_table.big_table 
                where created = l_date )
    loop
        null;
    end loop;
    end loop;

    dbms_output.put_line( 'CPU: ' || 
    to_char( dbms_utility.get_cpu_time-l_start ) );
end;
/
