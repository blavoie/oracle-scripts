-- From http://jonathanlewis.wordpress.com/2011/06/27/ddl/
-- Important note:  redundant in 11g because you can set the ddl_lock_timeout parameter to address the problem.
declare
   mod_complete   boolean;
   table_lock     exception;
   pragma exception_init (table_lock, -00054);
   mod_start      date;
begin
   mod_complete := false;

   select sysdate into mod_start from dual;

   while (not mod_complete) and (sysdate < mod_start + 5 / 24 / 60)
   loop
      begin
         execute immediate ('&&ddl');

         mod_complete := true;
         dbms_output.put_line ('DDL has been executed: &&ddl');
      exception
         when table_lock
         then
            null;
            dbms_lock.sleep (0.1);
      end;
   end loop;

   if mod_complete = false
   then
      dbms_output.put_line ('ERROR - Could not achieve table lock for DDL: &&ddl');
   end if;
end;
/