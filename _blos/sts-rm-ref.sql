begin
    dbms_sqltune.remove_sqlset_reference (sqlset_name => '&sqlset_name', reference_id => &reference_id);
end;
/