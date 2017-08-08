/*
    Référence: http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_advis.htm

    Advisor Names: 
        dbms_advisor.adv_name_sqlaccess | dbms_advisor.sqlaccess_advisor
        dbms_advisor.adv_name_sqltune
*/
declare
    l_stmt   clob;
begin

    select sql_fulltext
    into   l_stmt
    from   v$sqlarea
    where  sql_id = '&sqlid';

    dbms_advisor.quick_tune (dbms_advisor.sqlaccess_advisor, '&task_name', l_stmt);
end;
/