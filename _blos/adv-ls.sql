col description   for a25 wrapped
col error_message for a25 wrapped

select --owner
      task_id
      ,task_name
      ,description
      ,advisor_name
      ,created
      ,last_modified
      --,parent_task_id
      --,parent_rxec_id
      --,last_execution
      --,execution_type
      --,execution_type#
      --,execution_description
      --,execution_start
      --,execution_end
      ,status
      --,status_message
      --,pct_completion_time
      --,progress_metric
      --,metric_units
      --,activity_counter
      ,recommendation_count
      ,error_message
--,source
--,how_created
--,read_only
--,system_task
--,advisor_id
--,status#
from   dba_advisor_tasks
where  owner = upper ('&owner');