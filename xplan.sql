-- Explain the last executed statement
select * from table(dbms_xplan.display_cursor(null, null, 'allstats last advanced'));
