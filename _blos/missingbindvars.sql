with force_matches
     as (
         select force_matching_signature,
                count( unique sql_id) matches,
                sum (elapsed_time) elapsed_time_total,
                max(last_active_time) last_active_time_,
                sum(executions) executions_total,
                decode(sum(executions), 0, 0, round(sum(elapsed_time) / sum(executions))) elapsed_time_per_exec,
                max(sql_id
                    || child_number) max_sql_child,
                dense_rank() over (order by count(*) desc) ranking
         from   gv$sql
         where  force_matching_signature <> 0
         group  by force_matching_signature
         having  count( unique sql_id) > 4
         )
select s. force_matching_signature,
       s.*
from   gv$sql s
       join force_matches fm
         on ( s.force_matching_signature=fm.force_matching_signature)
order by s.force_matching_signature,s.sql_id;