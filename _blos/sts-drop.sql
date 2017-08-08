begin
    dbms_sqltune.drop_sqlset (sqlset_owner => upper ('&owner'), sqlset_name => '&sqlset_name');
end;
/