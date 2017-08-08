alter session set timed_statistics = true;
alter session set max_dump_file_size = unlimited;
alter session set tracefile_identifier = benchIndex;

exec dbms_monitor.session_trace_enable(waits => true, binds => true);

declare
    cursor cur is 
        select dbms_random.string('p',25) as col1,
               dbms_random.string('p',25) as col2,
               dbms_random.string('p',25) as col3,
               dbms_random.string('p',25) as col4,
               dbms_random.string('p',25) as col5,
               dbms_random.string('p',25) as col6,
               dbms_random.string('p',25) as col7,
               dbms_random.string('p',25) as col8
        from dual
        connect by level <= 10000;
begin
    for rec in cur 
    loop
       insert into idx0 (col1, col2, col3, col4, col5, col6, col7, col8)     
       values (rec.col1, rec.col2, rec.col3, rec.col4, rec.col5, rec.col6, rec.col7, rec.col8);
       
       insert into idx2 (col1, col2, col3, col4, col5, col6, col7, col8)     
       values (rec.col1, rec.col2, rec.col3, rec.col4, rec.col5, rec.col6, rec.col7, rec.col8);
       
       insert into idx4 (col1, col2, col3, col4, col5, col6, col7, col8)     
       values (rec.col1, rec.col2, rec.col3, rec.col4, rec.col5, rec.col6, rec.col7, rec.col8);
       
       insert into idx6 (col1, col2, col3, col4, col5, col6, col7, col8)     
       values (rec.col1, rec.col2, rec.col3, rec.col4, rec.col5, rec.col6, rec.col7, rec.col8);
       
       insert into idx8 (col1, col2, col3, col4, col5, col6, col7, col8)     
       values (rec.col1, rec.col2, rec.col3, rec.col4, rec.col5, rec.col6, rec.col7, rec.col8);
    end loop;
end;
/

commit;

exec dbms_monitor.session_trace_disable;