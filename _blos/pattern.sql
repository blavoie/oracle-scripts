select 'NVL2(' || tc.column_name || ', 1, 0) AS ' || tc.column_name || ',' as sel, 'NVL2(' || tc.column_name || ', 1, 0),' as grp
from   dba_tab_cols tc
where  tc.table_name = '&&tabname'
order by tc.column_id;
