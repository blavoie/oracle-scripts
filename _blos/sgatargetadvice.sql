with current_size
     as (select *
         from   v$sga_target_advice
         where  sga_size_factor = 1)
select sta.*, 
       round ( (cur.estd_physical_reads - sta.estd_physical_reads) / cur.estd_physical_reads,2) as pct_savings_phys_reads, 
       round ( (cur.estd_db_time - sta.estd_db_time) / cur.estd_db_time,2) as pct_savings_db_time
from   v$sga_target_advice sta
      ,current_size cur