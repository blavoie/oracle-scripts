create or replace procedure proc_test1 (p_inlist in ccard_ntt)
is
    l_nb pls_integer;
begin
    -- not working :(
    select /*+ QRY_PROC_TEST1 */ 
           count(*)
    into   l_nb
    from   individu_mc i
    where  i.idul in (select column_value
                      from   table(ccard(p_inlist)));
end;
/

create or replace procedure proc_test2( p_inlist in ccard_ntt ) is
    -- not working :(
    cursor cur is
        select /*+ QRY_PROC_TEST2 */
               i.nom,
               i.prenom
        from   individu_mc i
        where  i.idul in (select column_value
                          from   table(ccard(p_inlist))); 
begin
    for rec in cur 
    loop
       null;
    end loop;
end proc_test2;
/

alter session set statistics_level=all;
alter session set timed_statistics = true;
alter session set max_dump_file_size = unlimited;
alter session set tracefile_identifier = ccard01;

exec dbms_monitor.session_trace_enable(waits => true, binds => true);

declare
    l_retour  varchar2(3000);
    l_list1   ccard_ntt   := ccard_ntt('ADSY1','ADSY2','ADSY3','ADSY4');
    l_nb      pls_integer;
begin  
    select /*+ QRY_1 */
           count(*)
    into   l_nb
    from   individu_mc    i   
    where  i.idul in (select column_value
                      from   table(ccard(ccard_ntt('ADSY1','ADSY2','ADSY3','ADSY4'))));
                      
    -- not working..... :(                     
    select /*+ QRY_2 */
           count(*)
    into   l_nb
    from   individu_mc    i   
    where  i.idul in (select column_value
                      from   table(ccard(l_list1)));
                      
    select /*+ QRY_3 */
           count(*)
    into   l_nb
    from   individu_mc    i   
    where  i.idul in (select --+ dynamic_sampling(t, 2)
                             column_value
                      from   table(l_list1) t);

    proc_test1(l_list1);
    proc_test2(l_list1);
end;
/

exec dbms_monitor.session_trace_disable;