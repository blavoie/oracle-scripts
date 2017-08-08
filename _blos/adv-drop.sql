begin
    dbms_sqltune.drop_tuning_task (task_name => '&task_name');
end;
/