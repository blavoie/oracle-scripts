select * from bg_all_event_types
where event_name in
  (select event_name from bg_event_types
   UNION
   select metric_constant_name from bg_server_alert_metric_values
   where  metric_id in (select a.metrics_id from table(dbms_server_alert.view_thresholds) a)
  )
/
