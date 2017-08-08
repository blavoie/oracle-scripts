rem
rem Displays partitioned index information
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
     and a.table_name = v_table
     and a.partitioned = 'YES';

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  PARTITIONED INDEX INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if;
end;
/

set verify off feed off numwidth 10 lines 500 heading on long 200

column index_name heading 'Index Name'
column index_type format a8 heading 'Type'
column status format a8 heading 'Status'
column visibility format a4 heading 'Vis?'
column last_analyzed heading 'Last Analyzed'
column degree format a3 heading 'Deg'
column partitioned format a5 heading 'Part?'

column blevel heading 'BLevel'
column leaf_blocks heading 'Leaf Blks'
column num_rows heading '# Rows'
column distinct_keys heading 'DistKeys'
column avg_leaf_blocks_per_key heading 'Avg Lf/Blks/Key'
column avg_data_blocks_per_key heading 'Avg Dt/Blks/Key'
column clustering_factor heading 'CluF'

column partition_position format 99999 heading 'Part#'
column partition_name heading 'Partition Name'
column high_value format a120 tru heading 'Partition Bound'

break on index_name skip 1

select index_name, partition_position, partition_name, blevel, leaf_blocks, num_rows, distinct_keys,
	avg_leaf_blocks_per_key, avg_data_blocks_per_key, clustering_factor,
	status, last_analyzed, high_value
from all_ind_partitions
where index_owner = upper('&p_owner')
and index_name in 
(
select index_name
from all_indexes
where table_owner = upper('&p_owner')
and table_name = upper('&p_table')
and partitioned = 'YES'
)
order by index_name, partition_position
/

clear breaks
