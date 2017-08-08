declare
    l_str       varchar2 (4000);
    l_tabname   varchar2 (30) := 'WLS_ACCESS';
begin
    for x in (select a.partition_name, a.tablespace_name, a.high_value
              from   user_tab_partitions a
              where      a.table_name = l_tabname
                     and a.interval = 'YES'
                     and a.partition_name like 'SYS\_P%' escape '\')
    loop
        execute immediate 'select to_char( ' || x.high_value || '-numtodsinterval(1,''second''), ''"PART_"yyyy_mm_dd'' ) from dual' into l_str;

        execute immediate 'alter table "' || l_tabname || '" rename partition "' || x.partition_name || '" to "' || l_str || '"';
    end loop;
end;
/