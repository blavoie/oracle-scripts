drop table test01;
create table test01 
    nologging 
as 
    select *
    from   icu.individu_mc@enprodic.ulaval.ca;
    
    
alter table test01 add (
    constraint pk_test01
        primary key (numero_dossier)
);

-- Créer package avec pipelined table function
create or replace package pkg
is   
    type indiv_ntt is table of test01%rowtype;
    
    -- fonction
    function get_individu (p_no_dossier in test01.numero_dossier%type)
        return indiv_ntt
        parallel_enable
        pipelined;
end pkg;
/

create or replace package body pkg
is
    function get_individu (p_no_dossier in test01.numero_dossier%type)
        return indiv_ntt
        parallel_enable
        pipelined
    is
        l_resultat test01%rowtype;
    begin 
        select *
        into   l_resultat 
        from   test01
        where  numero_dossier = p_no_dossier;
        
        pipe row(l_resultat);
    end get_individu;
end pkg;
/

-----------------------------------
-- tester!
set serveroutput on 
declare
    -- récupérer aléatoirement 10 000 individus.
    type liste_dossier_tt is table of number;
    l_lst liste_dossier_tt;
    
    l_idx pls_integer;
    
    -- Réceptacle
    l_indiv test01%rowtype;
begin
    select numero_dossier
    bulk collect into l_lst
    from   (
                select numero_dossier
                from   test01 
                order by dbms_random.value
           )
    where  rownum <= 1000;
    
    -- Utilisant Table Function
    runstats_pkg.rs_start;
    
    l_idx := l_lst.first;
    while (l_idx is not null)
    loop
        select *
        into   l_indiv
        from   table(pkg.get_individu(l_lst(l_idx)));
        
        l_idx := l_lst.next(l_idx);
    end loop;
    
    runstats_pkg.rs_middle;
    
    -- N'utilisant pas Table Function
    l_idx := l_lst.first;
    while (l_idx is not null)
    loop
        select *
        into   l_indiv
        from   test01
        where  numero_dossier = l_lst(l_idx);
    
        l_idx := l_lst.next(l_idx);
    end loop;
    
    -- Fin
    runstats_pkg.rs_stop(500);
end;
/    