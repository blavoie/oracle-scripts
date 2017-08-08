declare
    cursor cur
    is
        select ut.*
        from   user_tables ut
        where  ut.iot_name is null;
begin
    for rec in cur
    loop
        dbms_stats.lock_table_stats (user, rec.table_name);
    end loop;
end;
/