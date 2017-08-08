set hea off

select    'Béatrice a: ' 
       || round(sysdate - ddn, 2)                  || ' jours, '
       || round((sysdate - ddn)/7, 2)              || ' semaines, '
       || round(months_between(sysdate, ddn), 2)   || ' mois'  
from   (
         select to_date('2011-08-26 09:24','YYYY-MM-DD HH24:MI') ddn
         from   dual
       );

set hea on        