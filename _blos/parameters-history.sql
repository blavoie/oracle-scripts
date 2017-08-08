-- From: EDB360
with all_parameters
     as (select snap_id
               ,dbid
               ,instance_number
               ,parameter_name
               ,value
               ,isdefault
               ,ismodified
               ,lag (value) over ( partition by dbid, instance_number, parameter_hash order by snap_id) prior_value
         from   dba_hist_parameter)
select to_char (s.begin_interval_time, 'YYYY-MM-DD HH24:MI') begin_time
      ,to_char (s.end_interval_time, 'YYYY-MM-DD HH24:MI') end_time
      ,p.snap_id
      ,p.dbid
      ,p.instance_number
      ,p.parameter_name
      ,p.value
      ,p.isdefault
      ,p.ismodified
      ,p.prior_value
from   all_parameters p
      ,dba_hist_snapshot s
where      p.value != p.prior_value
       and s.snap_id = p.snap_id
       and s.dbid = p.dbid
       and s.instance_number = p.instance_number
order by s.begin_interval_time desc
        ,p.dbid
        ,p.instance_number
        ,p.parameter_name
/