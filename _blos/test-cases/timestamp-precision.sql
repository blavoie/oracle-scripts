-- Not the same under Linux/Windows...
create table test_timestamp (
   horodate timestamp(9) not null
);

declare
begin
   for i in 1 .. 10 
   loop
      insert into test_timestamp values (systimestamp);
   end loop;
end;
/

select *
from   test_timestamp;

drop table test_timestamp;