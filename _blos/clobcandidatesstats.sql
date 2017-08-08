set serveroutput on 

declare
   cursor c1 is
      select t.owner,
             t.table_name,
             tc.column_name,
             tc.data_length
      from   dba_tab_columns tc
                inner join dba_tables t
                on tc.owner = t.owner and
                   tc.table_name = t.table_name 
      where  tc.data_type = 'VARCHAR2'
      and    tc.data_length > 1333
      and    t.owner = '&&owner'
      order by t.owner, t.table_name, tc.column_name;

   l_stmt varchar2(10000);     
   
   l_max_lengthc     pls_integer;
   l_avg_lenthc      pls_integer;
   l_stddev_lengthc  pls_integer;
   l_max_lengthb     pls_integer;
   l_avg_lenthb      pls_integer;
   l_stddev_lengthb  pls_integer;   
   
   procedure p (p_label in varchar2, p_num in number)
   is
   begin
      dbms_output.put_line (rpad (p_label, 30, '.') || to_char (p_num, '9,999'));
   end;   
begin
   for rec in c1 
   loop
      dbms_output.put_line('*******************************************************************************************');
      dbms_output.put_line(' ' || rec.table_name || '.' || rec.column_name || ' : ' || rec.data_length);
      
      l_stmt := 
            'select max(lengthc(' || rec.column_name || '))           as max_lengthc, '
         || '       round(avg(lengthc(' || rec.column_name || ')))    as avg_lengthc, '
         || '       round(stddev(lengthc(' || rec.column_name || '))) as stddev_lengthc, '
         || '       max(lengthb(' || rec.column_name || '))           as max_lengthb, '
         || '       round(avg(lengthb(' || rec.column_name || ')))    as avg_lengthb, '
         || '       round(stddev(lengthb(' || rec.column_name || '))) as stddev_lengthb '
         || 'from   ' || rec.owner || '.' || rec.table_name || ' '
         || 'where  ' || rec.column_name || ' is not null';
      
      execute immediate l_stmt 
         into l_max_lengthc,
              l_avg_lenthc,
              l_stddev_lengthc,
              l_max_lengthb,
              l_avg_lenthb,
              l_stddev_lengthb;
      
      p('   max length chars', nvl(l_max_lengthc,     0));
      p('   avg length chars', nvl(l_avg_lenthc,      0));
      p('   std length chars', nvl(l_stddev_lengthc,  0));
      p('   max length bytes', nvl(l_max_lengthb,     0));
      p('   avg length bytes', nvl(l_avg_lenthb,      0));
      p('   std length bytes', nvl(l_stddev_lengthb,  0));
   end loop;
exception
   when others then
      raise_application_error(-20000, '* !!! An error occured: ' || sqlcode || ': ' || sqlerrm);
end;
/
