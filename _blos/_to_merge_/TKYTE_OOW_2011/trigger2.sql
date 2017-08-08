set echo on

drop table t;

create table t ( x int, y int );

create or replace trigger t
before insert on t for each row
begin
	:new.y := -:new.x;
end;
/

insert into t ( x, y ) values ( 100, 200 );
select * from t;
commit;

!cat t.ctl
!sqlldr / t direct=y
select * from t;

truncate table t;
insert /*+ append */ into t select 100, 200 from dual;
select * from t;

drop trigger t;
truncate table t;
insert /*+ append */ into t select 100, 200 from dual;
select * from t;
