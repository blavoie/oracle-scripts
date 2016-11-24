----------------------------------------------------------------------------------------------------
-- Parameters treatment
----------------------------------------------------------------------------------------------------
-- We use a hack to enable default values with script parameters:
--   http://stackoverflow.com/questions/13474899/default-value-for-paramteters-not-passed-sqlplus-script

set term off

col 1 new_value 1
select '' "1" from dual where rownum = 0;

-- Define default and variables based on passed parameters

col gss_owner new_value gss_owner

select nvl(upper('&1'), sys_context('userenv','current_schema')) as gss_owner
from   dual;

set term on 

----------------------------------------------------------------------------------------------------
-- Proceed
----------------------------------------------------------------------------------------------------

prompt Gather Schema Statistics for &gss_owner user....
exec dbms_stats.gather_schema_stats(ownname => '&gss_owner', estimate_percent => dbms_stats.auto_sample_size, cascade => dbms_stats.auto_cascade);

----------------------------------------------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------------------------------------------

undef gss_owner
undef 1
