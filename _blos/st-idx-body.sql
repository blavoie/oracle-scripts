rem
rem Displays index information
rem


declare
  v_owner varchar2(30) := upper('&p_owner');
  v_table varchar2(30) := upper('&p_table');
  v_ct            number ;

begin

  v_ct := 0;

  select count(1)
    into v_ct
    from all_indexes a
   where a.table_owner = v_owner
     and a.table_name = v_table;

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  INDEX INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if;
end;
/

set verify off feed off numwidth 10 lines 500 heading on
set null .

column index_name heading 'Index Name'
column index_type format a8 heading 'Type'
column status format a8 heading 'Status'
column visibility format a4 heading 'Vis?'
column last_analyzed heading 'Last Analyzed'
column sample_size heading 'Sample'
column degree format a3 heading 'Deg'
column partitioned format a5 heading 'Part?'
column uniqueness format a5 heading 'Uniq?'
column blevel format 999999 heading 'BLevel'
column leaf_blocks heading 'LfBlks'
column num_rows heading '# Rows'
column distinct_keys heading 'DistKeys'
column avg_leaf_blocks_per_key heading 'Avg LfBlks/Key'
column avg_data_blocks_per_key heading 'Avg DtBlks/Key'
column clustering_factor heading 'CluF'
	

select index_name,  
	blevel, leaf_blocks, num_rows, distinct_keys,
	avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor,
	sample_size, case when uniqueness = 'UNIQUE' then 'YES' else 'NO ' end uniqueness,
	substr(index_type,1,4) index_type, status, degree,
	partitioned, 
	null visibility,
	-- case when visibility = 'VISIBLE' then 'YES' else 'NO ' end VISIBILITY, 
	last_analyzed
from all_indexes
where table_owner = upper('&p_owner')
and table_name = upper('&p_table')
order by index_name ;


column column_name format a30 heading 'Column Name'
column index_name heading 'Index Name'
column column_position format 999999999 heading 'Pos#'
column descend format a5 heading 'Order'
column column_expression format a100 heading 'Expression'

set long 200
break on index_name skip 0


select --lower(b.index_name) index_name, 
		b.index_name,
		b.column_position, 
		b.descend, 
		b.column_name
		--lower(b.column_name) column_name
from all_ind_columns b
where b.table_owner = upper('&p_owner')
and b.table_name = upper('&p_table')
order by b.index_name, b.column_position, b.column_name
/


select --lower(e.index_name) index_name, 
		e.index_name,
		(select column_name from all_ind_columns
		  where index_name = e.index_name
		  and	table_name = e.table_name
		  and	table_owner = e.table_owner
		  and 	column_position = e.column_position) column_name,
		e.column_position, e.column_expression 
from all_ind_expressions e
where e.table_owner = upper('&p_owner')
and e.table_name = upper('&p_table')
order by e.index_name, e.column_position
/

set head on
clear breaks
