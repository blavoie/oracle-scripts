------------------------------------------------------------------------------------------------
-- Export statistics from source database
------------------------------------------------------------------------------------------------
begin
    dbms_stats.create_stat_table('BRLAV35', 'DBMS_STATS_TABLE');
    dbms_stats.export_schema_stats (
         ownname  => 'ICU'                              -- Name of the schema to exports stats from
       , statown  => 'BRLAV35'                          -- Schema containing stattab (if different than ownname)
       , stattab  => 'DBMS_STATS_TABLE'                 -- User statistics table identifier describing where to store the statistics
       , statid   => 
             'PROD_' 
          || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI')         -- Identifier (optional) to associate with these statistics within stattab
    );
end;
/

-- Do and export/import with DataPump, or transfert it with dblink as shown at next step

------------------------------------------------------------------------------------------------
-- Import statistics to target database
------------------------------------------------------------------------------------------------

create table dbms_stats_table as
	select *
	from   dbms_stats_table@enprodic.ulaval.ca;

-- Show statid possibilities
select distinct
       dst.statid
from   dbms_stats_table dst;

-- Update pointing user 
update dbms_stats_table s
set    c5 = user;
commit;

exec dbms_stats.upgrade_stat_table (ownname => user, stattab => 'DBMS_STATS_TABLE'); -- necessary from 10g to 11g
exec dbms_stats.import_schema_stats(ownname => user, stattab => 'DBMS_STATS_TABLE', statid => 'PROD_201211231653');
commit;