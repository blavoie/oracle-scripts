/*
From note: Extent and Block Space Calculation and Usage in Oracle Databases [ID 10640.1]   
Link: https://supporthtml.oracle.com/epmos/faces/ui/km/DocContentDisplay.jspx?_afrLoop=3150831811727000&id=10640.1&_afrWindowMode=0&_adf.ctrl-state=188pw2h6zo_75
    
Note: This formula assumes that columns containing nulls are not trailing  
      columns. A column length of 1 is assumed (column length of a null in a
      trailing column is 0).

  select avg(nvl(vsize(col1), 1)) + 
         avg(nvl(vsize(col2), 1)) + 
         ... + 
         avg(nvl(vsize(coln), 1))  "SPACE OF AVERAGE ROW" 
  from   table_name;
*/ 

-- TODO: dynamize...
declare
   stmt varchar2(10000);
begin
   stmt := 'select ';
end;
/

-- TODO: from table stats
--       do table stats include length of clobs not stored in row?  
select t.avg_row_len
from   all_tables t 
where  t.owner = ''
and    t.table_name = '';  