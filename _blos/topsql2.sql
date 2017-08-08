with buffer_gets_tot as (select trunc (sum (buffer_gets)) buffer_gets_tot from v$sqlarea),
metrics as (
    -- This view return raw metrics values
    select sa.sql_fulltext,
           sa.sql_id,
           sa.executions,
           sa.buffer_gets,
           sa.rows_processed,
           sa.sorts,
           sa.optimizer_cost,
           sa.elapsed_time,
           sa.cpu_time,
           sa.concurrency_wait_time, 
           --sa.application_wait_time,
           sa.user_io_wait_time,
           sa.plsql_exec_time,
           sa.buffer_gets / bgt.buffer_gets_tot                                as buffer_gets_pct,
           sa.buffer_gets / sa.executions                                      as buffer_gets_per_exec,
           decode(sa.rows_processed, 0, 0, sa.buffer_gets / sa.rows_processed) as buffer_gets_per_rows,       
           sa.rows_processed / sa.executions                                   as rows_processed_per_exec,
           sa.sorts / sa.executions                                            as sorts_per_exec,
           sa.elapsed_time / sa.executions                                     as elapsed_time_per_exec,
           sa.cpu_time / sa.executions                                         as cpu_time_per_exec, 
           --sa.application_wait_time / sa.executions                            as appl_wait_time_per_exec, 
           sa.concurrency_wait_time / sa.executions                            as concur_wait_time_per_exec,
           sa.user_io_wait_time / sa.executions                                as user_io_wait_time_per_exec,
           sa.plsql_exec_time / sa.executions                                  as plsql_exec_time_per_exec 
    from   v$sqlarea       sa,
           buffer_gets_tot bgt
    where  sa.executions > 0
    and    sa.parsing_schema_name = 'ICU'),
metrics_with_rank as (    
    -- this view calculate, round, format, rank, etc, metrics
    select m.sql_fulltext,
           m.sql_id,
           m.executions,
           m.buffer_gets,
           m.rows_processed,
           m.sorts,
           m.optimizer_cost,
           round(m.elapsed_time/1000000, 2)                                 as elapsed_time_sec,
           round(m.cpu_time/1000000, 2)                                     as cpu_time_sec,
           round(m.concurrency_wait_time/1000000, 2)                        as concurrency_wait_time_sec, 
           --round(m.application_wait_time/1000000, 2)                        as application_wait_time_sec,
           round(m.user_io_wait_time/1000000, 2)                            as user_io_wait_time_sec,
           round(m.plsql_exec_time/1000000, 2)                              as plsql_exec_time_sec,
           round(100*m.buffer_gets_pct,6)                                   as buffer_gets_pct,
           round(m.buffer_gets_per_exec)                                    as buffer_gets_per_exec,   
           round(m.buffer_gets_per_rows)                                    as buffer_gets_per_rows,
           round(m.rows_processed_per_exec)                                 as rows_processed_per_exec,
           round(m.sorts_per_exec)                                          as sorts_per_exec,
           round(m.elapsed_time_per_exec/1000000, 2)                        as elapsed_time_per_exec_sec,
           round(m.cpu_time_per_exec/1000000, 2)                            as cpu_time_per_exec_sec, 
           --round(m.appl_wait_time_per_exec/1000000, 2)                      as appl_wait_time_per_exec_sec, 
           round(m.concur_wait_time_per_exec/1000000, 2)                    as concur_wait_time_per_exec_sec,
           round(m.user_io_wait_time_per_exec/1000000, 2)                   as user_io_wait_time_per_exec_sec,
           round(m.plsql_exec_time_per_exec/1000000, 2)                     as plsql_exec_time_per_exec_sec,
           rank() over (order by m.executions desc)                         as rk_executions,
           rank() over (order by m.buffer_gets desc)                        as rk_buffer_gets,
           rank() over (order by m.buffer_gets_per_exec desc)               as rk_buffer_gets_per_exec,
           rank() over (order by m.buffer_gets_per_rows desc)               as rk_buffer_gets_per_rows,
           rank() over (order by m.rows_processed_per_exec desc)            as rk_rows_processed_per_exec,
           rank() over (order by m.sorts_per_exec desc)                     as rk_sorts_per_exec,
           rank() over (order by m.elapsed_time_per_exec desc)              as rk_elapsed_time_per_exec,
           rank() over (order by m.cpu_time_per_exec desc)                  as rk_cpu_time_per_exec, 
           --rank() over (order by m.appl_wait_time_per_exec desc)            as rk_appl_wait_time_per_exec, 
           rank() over (order by m.concur_wait_time_per_exec desc)          as rk_concur_wait_time_per_exec,
           rank() over (order by m.user_io_wait_time_per_exec desc)         as rk_user_io_wait_time_per_exec,
           rank() over (order by m.plsql_exec_time_per_exec desc)           as rk_plsql_exec_time_per_exec                             
    from   metrics m
)
select *
from   metrics_with_rank
where  rk_executions                    <= 20
or     rk_buffer_gets                   <= 20
or     rk_buffer_gets_per_exec          <= 20
or     rk_buffer_gets_per_rows          <= 20
or     rk_rows_processed_per_exec       <= 20
or     rk_sorts_per_exec                <= 20
or     rk_elapsed_time_per_exec         <= 20
or     rk_cpu_time_per_exec             <= 20
--or     rk_appl_wait_time_per_exec       <= 20 
or     rk_concur_wait_time_per_exec     <= 20
or     rk_user_io_wait_time_per_exec    <= 20
or     rk_plsql_exec_time_per_exec      <= 20         
