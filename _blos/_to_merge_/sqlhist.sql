select s.begin_interval_time,
       s.end_interval_time,
       ss.sql_id,
       ss.plan_hash_value,
       ss.executions_total,
       ss.executions_delta,
       ceil(ss.elapsed_time_delta   / decode(ss.executions_delta,0,1,ss.executions_delta)/1000) as milliseconds_per_exec,
       ceil(ss.rows_processed_delta / decode(ss.executions_delta,0,1,ss.executions_delta)) as rows_per_exec,
       ceil(ss.buffer_gets_delta    / decode(ss.executions_delta,0,1,ss.executions_delta)) as gets_per_exec
from   dba_hist_sqlstat ss,
       dba_hist_snapshot s
where  ss.sql_id = nvl('&&sql_id', ss.sql_id)
and    s.snap_id = ss.snap_id
and    ss.plan_hash_value <> 0
order by ss.sql_id, s.snap_id;
