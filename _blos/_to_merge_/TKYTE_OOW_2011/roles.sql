connect /

drop table t;

create table t 
as 
select * 
  from all_users
 where rownum <= 3;

create or replace procedure show_user_info_ir
AUTHID CURRENT_USER
as
begin
    dbms_output.put_line( '--------- IR Status ---------' );
    for x in (select sys_context('userenv', 'authenticated_identity' ) ai,
                     sys_context('userenv', 'current_schema') cs,
                     sys_context('userenv', 'current_schemaid') cs_id,
                     sys_context('userenv', 'current_user') cu
                from dual )
    loop
        dbms_output.put_line( 'authenticated identity: ' || x.ai );
        dbms_output.put_line( 'current schema        : ' || x.cs );
        dbms_output.put_line( 'current schemaid      : ' || x.cs_id );
        dbms_output.put_line( 'current user          : ' || x.cu );
    end loop;
end;
/
create or replace procedure show_user_info_dr
AUTHID DEFINER
as
begin
    dbms_output.put_line( '--------- DR Status ---------' );
    for x in (select sys_context('userenv', 'authenticated_identity' ) ai,
                     sys_context('userenv', 'current_schema') cs,
                     sys_context('userenv', 'current_schemaid') cs_id,
                     sys_context('userenv', 'current_user') cu
                from dual )
    loop
        dbms_output.put_line( 'authenticated identity: ' || x.ai );
        dbms_output.put_line( 'current schema        : ' || x.cs );
        dbms_output.put_line( 'current schemaid      : ' || x.cs_id );
        dbms_output.put_line( 'current user          : ' || x.cu );
    end loop;
end;
/



create or replace procedure curr_user
AUTHID CURRENT_USER
as
begin
    show_user_info_ir;
    show_user_info_dr;
    dbms_output.put_line( '--------- data      ---------' );
    for x in (select * from t)
    loop
        dbms_output.put_line( x.username );
    end loop;
    for x in (select * from ops$tkyte.t)
    loop
        dbms_output.put_line( x.username );
    end loop;
end;
/

grant execute on curr_user to public;

exec curr_user
connect scott/tiger
drop table t;
exec ops$tkyte.curr_user
create table t ( x int );
exec ops$tkyte.curr_user

drop table t;
create table t ( x int, y int, z int );
exec ops$tkyte.curr_user

drop table t;
create table t ( x varchar2(30), y number, z date );
insert into t values ( 'hello', 0, sysdate );
exec ops$tkyte.curr_user

connect /

create or replace procedure curr_user
AUTHID CURRENT_USER
as
begin
    show_user_info_ir;
    show_user_info_dr;
    dbms_output.put_line( '--------- data      ---------' );
    for x in (select username, user_id, created from t)
    loop
        dbms_output.put_line( x.username );
    end loop;
end;
/

connect scott/tiger
exec ops$tkyte.curr_user
