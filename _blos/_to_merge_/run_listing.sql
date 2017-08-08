-- -----------------------------------------------------------------
--
-- Title:      Expert PL/SQL Practices (Apress)
-- ISBN:       978-1-4302-3485-2
-- Chapter:    9. PL/SQL from SQL
-- Author:     Adrian Billington
--             http://www.oracle-developer.net
--
-- Utility:    run_listing.sql
--
-- Notes:      1. Run in the supplied SH sample schema.
--
--             2. Use to execute and spool the results of all
--                listing SQL files.
--                Usage:
--                   SQL> @run_listing.sql <listing_script_no>
--                E.g.
--                   SQL> @run_listing.sql 9_1_4
--             
-- -----------------------------------------------------------------

set echo off
store set sqlplus_settings.sql replace
set echo on timing on
set serveroutput on
define __ora_dir = "LOG_DIR"
define __script  = &1
spool &__script..txt
@&__script
spool off
set echo off timing off
@sqlplus_settings.sql
undefine __script
undefine __ora_dir
