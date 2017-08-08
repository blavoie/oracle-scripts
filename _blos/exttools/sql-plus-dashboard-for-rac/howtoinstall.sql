####################
Installation
####################


    -- Create new user if required
    REM  SQL> grant create session to js identified by js;


1-  connect with DBA/SysDBA, execute 1_grants.sql and pass username
 
SQL> start 1_grants.sql
   
     Enter value for _usr: js

     Grant succeeded.
    ........



2-- Create Types

 REM connect with user "js" and execute 2_types.sql

SQL>  conn js/js
      Connected.

SQL>  start 2_types.sql

      Type created.
      ......



3-- Create package

SQL> start 3_pkg.sql

Package created.

No errors.

Package body created.

No errors.


 

########################
How to Execute
########################


REM Script requires linesize 190, pages 0 and arraysize 45+ minimum, so make sure you keep your terminal screen as full screen.
REM and use below command to set the env. and start the script

NOTE: arraysize should be same as you pass parameter to sql.. by default arraysize value is 47 and refresh time 6 seconds, should be enough for 8 node cluster


SQL> connect js/js

SQL>set lines 190 pages 0 arraysize 47
SQL>select * from table(jss.gtop) ;


 
--  Screen Size and Refresh/Sample time can be passed as parameter 

 SQL>set lines 190 pages 0 arraysize 50
 SQL>select * from table(jss.gtop(50,10)) ;

    -- Above example, would use 50 arraysize and 10 second sample.

 

Note : Screensize and passed parameter to jss.gtop(X) should be same

     : There might be some delay top of sample time based on db performance or no. of nodes it has to collect data
       I observed 3 second delay on vms running on my laptop. timestamp is being used to calculate per second metrics values
   
 




########################
How to drop
########################

REM connect with user and execute drop.sql

SQL> connect js/js
SQL> start drop.sql
