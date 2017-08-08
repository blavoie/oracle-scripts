------------------------------------------------------------------------------------
--
-- Name:          bashcreate.sql - BASH Installation script for Oracle 10.2 to 11.2
--
-- Purpose:       It's ASH for the rest of us (no EE or no diagnostic pack license).
--
-- Requirements:  * Oracle 10.2 to 11.2 (tested with 10.2 and 11.2) 
--                * SE1, SE or EE - Diagnostic Pack NOT needed
--                * Parameter job_queue_processes > 0 
--                   (since the bash data collector permanently runs as a scheduler 
--                    job, you might want to consider raising the job_queue_processes 
--                    parameter by one)
--
-- Installation:  1.) Create a new tablespace for the BASH schema (optional, but recommended).
--                2.) Run: sqlplus sys/<sys_password>@<TNS_ALIAS> as sysdba @bashcreate.sql
--                3.) When asked, enter the password for the BASH user to be created and the 
--                    names for the permanent and temporary tablespace for the BASH user.
--                4.) When asked, enter "N" if you don't want to start the data 
--                    collector job right away. 
--
-- Uninstall:     1.) Execute bash.bash.stop;
--                2.) drop user bash cascade;
--
--
-- Usage:         *** CONTROLLING THE DATA COLLECTION *** 
--
--                The package BASH.BASH has the following procedures that let you
--                control the data gathering:
--
--                procedure run;
--                    Creates and start the bash data collector scheduler job.
--
--                procedure stop;
--                    Stops the bash data collector scheduler job.
--
--                procedure purge (days_to_keep NUMBER);
--                    Purges the data in BASH$HIST_ACTIVE_SESS_HISTORY
--
--                procedure runner;  
--                    Blocking procedure that collects the bash data. Might be
--                    usefull e.g. when scheduler jobs are not available and the
--                    data collector can not be run from a job session.
--
--
--                *** SETTINGS ***
--
--                The table BASH.BASH$SETTINGS has the following columns that let
--                you control how the BASH data is gathered:
--
--                 sample_every_n_centiseconds NUMBER (Default: 100 = 1 second)
--                     Number of centiseconds V$SESSION is sampled
--
--                 max_entries_kept NUMBER (Default: 30000)
--                     How many entries are kept in BASH$ACTIVE_SESSION_HISTORY
--
--                 cleanup_every_n_samples NUMBER (Default: 100)
--                     How often the data in BASH$ACTIVE_SESSION_HISTORY is purged  
--
--                 persist_every_n_samples NUMBER (Default: 10 )
--                     How many of the samples are persisted to BASH$HIST_ACTIVE_SESS_HISTORY
--
--                 logging_enabled NUMBER (Default: 0)
--                     If logging to BASH$LOG is enabled 
--
--                 keep_log_entries_n_days NUMBER (Default: 1)
--                     How many days log entries in BASH$LOG are kept
--
--                 updated NUMBER 
--                     An internally used column that tracks changes in the settings table
--                     through a trigger
--
--                 version NUMBER 
--                     The version number of BASH. Might be used with future update scripts.
--                     Do not change.
--
--                If you change a setting in the BASH.BASH$SETTINGS table and commit,
--                the updated setting will be used by the data collector the next time
--                it persists data to DBA_HIST_ACTIVE_SESS_HISTORY (default: every 10 seconds) 
--
--                The default values for sample_every_n_centiseconds and 
--                persist_every_n_samples replicate the ASH behaviour. 
--                
--
--                *** QUERYING THE COLLECTED BASH DATA *** 
--
--                BASH$ACTIVE_SESSION_HISTORY
--                  Replaces V$ACTIVE_SESSION_HISTORY (1-second samples)
--
--                BASH$HIST_ACTIVE_SESS_HISTORY
--                  Replaces DBA_HIST_ACTIVE_SESS_HISTORY (10-second samples)
--
--                BASH$LOG
--                  Logging table (logging is off by default)
--
--
--                If want to use scripts or tools (e.g. "Mumbai" or "ASH Viewer") that 
--                select from V$ACTIVE_SESSION_HISTORY or DBA_HIST_ACTIVE_SESS_HISTORY,
--                you might want to replace the following public synonyms with synonyms 
--                pointing to BASH$ACTIVE_SESSION_HISTORY and 
--                BASH$HIST_ACTIVE_SESS_HISTORY:
--                
--                  CREATE OR REPLACE PUBLIC SYNONYM "V$ACTIVE_SESSION_HISTORY" 
--                      FOR BASH$ACTIVE_SESSION_HISTORY;
--
--                  CREATE OR REPLACE PUBLIC SYNONYM "DBA_HIST_ACTIVE_SESS_HISTORY" 
--                      FOR BASH$HIST_ACTIVE_SESS_HISTORY;
--                
--                Note that these synonyms will not work for user SYS, so selecting from 
--                V$ACTIVE_SESSION_HISTORY as user sys will still return the Oracle ASH data,
--                not BASH data.
--                
--                Also note that you are still not allowed to use Oracle Enterprise Manager,
--                Oracle Database Console or the Oracle supplied ASH scripts in RDBMS/ADMIN
--                against BASH data without a valid Diagnostic Pack license.
--
--
--                *** CLEANUP AND PURGING *** 
--
--                The data collected for BASH$ACTIVE_SESSION_HISTORY is automatically purged,
--                based on the max_entries_kept setting.
--
--                The data collected for BASH$HIST_ACTIVE_SESS_HISTORY is not purged 
--                automatically. You need to execute BASH.BASH.PURGE(<days_to_keep>) to purge
--                the data. You might want to create a scheduler job to do this on a
--                regular basis.
--
-- Background:    *** Performance impact of the BASH data collector ***
--
--                Oracle's own ASH uses a circular buffer in the SGA, which is something
--                a user process like the BASH data collector can not. After trying a few 
--                setups (global temporary tables, communications though DBMS_PIPE, etc.), I
--                decided to implement BASH as simple as possible using standard heap tables.
--                (The buffer cache is probably the closest thing to a separate memory area 
--                that can be used from a user session.)
--
--                I tested BASH on ten productive databases with quite different loads, both
--                on the OLTP and OLAP side. Since the load from BASH is not recorded by BASH 
--                (when sampling the sampler has to be ignored) I used Tanel Poder's snapper 
--                and latchprof scripts to check for load and excessive latch gets by the bash
--                data collector. The load was usually 0,01 AAS (usually on CPU), on some 
--                database with a large number of active session it sometimes was 0,02 AAS. 
--                The latchprof script showed only very low numbers of latch gets from the 
--                bash data collector.
--                
--                While the ASH setup with a circular buffer in the SGA and its latch-free 
--                access is definetly the superior architecture, I can not see any serious
--                side-effects with the down-to-earth BASH architecture.
--                
--                If you worry about the additonal 1-2% AAS load, you probably need BASH 
--                badly, to fix a few performance problems... ;-)
--                
--                
--                *** Columns in BASH$ACTIVE_SESSION_HISTORY ***
--                
--                For compatibilty reasons with 3rd party tools that select from 
--                V$ACTIVE_SESSION_HISTORY (but actually BASH$ACTIVE_SESSION_HISTORY if
--                you decide to replace the V$ACTIVE_SESSION_HISTORY public synonym), I made
--                all columns from V$ACTIVE_SESSION_HISTORY available in 
--                BASH$ACTIVE_SESSION_HISTORY, however some columns are not really filled
--                with data and always NULL: qc_session_id, qc_instance_id
--                and blocking_session_serial# from the 10.2 version of 
--                V$ACTIVE_SESSION_HISTORY and a whole series of columns from the 11.2
--                version of V$ACTIVE_SESSION_HISTORY (see comments in PL/SQL code).
--                
--                On the other hand, there are three columns in BASH$ACTIVE_SESSION_HISTORY
--                orginating from V$SESSION that are not available in V$ACTIVE_SESSION_HISTORY, 
--                because I think they are useful: OSUSER, TERMINAL, USERNAME
--                
--
-- Author:        Marcus Monnig
-- Copyright:     (c) 2012, 2013 Marcus Monnig - All rights reserved.
--
-- Disclaimer:    No guarantees. Use at your own risk. 
--
-- Changelog:     v1: 2012-12-28 First public release 
--
------------------------------------------------------------------------------------


set echo off verify off showmode off feedback off;
whenever sqlerror exit sql.sqlcode


-- Thanks Tanel for this trick... :-)
define _IF_ORA10_OR_HIGHER="--"
define _IF_ORA11_OR_HIGHER="--"
define _IF_LOWER_THAN_ORA11="--"

col bash_ora10higher    noprint new_value _IF_ORA10_OR_HIGHER
col bash_ora11higher    noprint new_value _IF_ORA11_OR_HIGHER
col bash_ora11lower     noprint new_value _IF_LOWER_THAN_ORA11

with mod_banner as (
    select
        replace(banner,'9.','09.') banner
    from
        v$version
    where rownum = 1
)
select
    decode(substr(banner, instr(banner, 'Release ')+8,1), '1',  '',  '--')  bash_ora10higher,
    decode(substr(banner, instr(banner, 'Release ')+8,2), '11', '',  '--')  bash_ora11higher,
    decode(substr(banner, instr(banner, 'Release ')+8,2), '11', '--',  '')  bash_ora11lower
from
    mod_banner
/

prompt
prompt Choose the BASH user's password
prompt ------------------------------------  

prompt Not specifying a password will result in the installation FAILING
prompt
prompt &&bash_password

spool bashcreate.log

begin
  if '&&bash_password' is null then
    raise_application_error(-20101, 'Install failed - No password specified for bash user');
  end if;
end;
/


prompt
prompt
prompt Choose the Default tablespace for the bash user
prompt ----------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store user data.  Specifying the SYSTEM tablespace for the user's 
prompt default tablespace will result in the installation FAILING, as 
prompt using SYSTEM for performance data is not supported.
prompt
prompt Choose the bash users's default tablespace.  This is the tablespace
prompt in which the BASH objects will be created.

column db_default format a28 heading 'BASH DEFAULT TABLESPACE'
select tablespace_name, contents
     , decode(tablespace_name,'SYSAUX','*') db_default
  from sys.dba_tablespaces 
 where tablespace_name <> 'SYSTEM'
   and contents = 'PERMANENT'
   and status = 'ONLINE'
 order by tablespace_name;

prompt
prompt Pressing <return> will result in BASH's recommended default
prompt tablespace (identified by *) being used.
prompt

set heading off
col default_tablespace new_value default_tablespace noprint
select 'Using tablespace '||
       upper(nvl('&&default_tablespace','SYSAUX'))||
       ' as bash default tablespace.'
     , nvl('&default_tablespace','SYSAUX') default_tablespace
  from sys.dual;
set heading on

begin
  if upper('&&default_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for DEFAULT tablespace');
  end if;
end;
/


prompt
prompt
prompt Choose the Temporary tablespace for the bash user
prompt ------------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store temporary data (e.g. for sort workareas).  Specifying the SYSTEM 
prompt tablespace for the user's temporary tablespace will result in the 
prompt installation FAILING, as using SYSTEM for workareas is not supported.

prompt
prompt Choose the bash user's Temporary tablespace.

column db_default format a26 heading 'DB DEFAULT TEMP TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_TEMP_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'TEMPORARY'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_TEMP_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default Temporary 
prompt tablespace (identified by *) being used.
prompt

set heading off
col temporary_tablespace new_value temporary_tablespace noprint
select 'Using tablespace '||
       nvl('&&temporary_tablespace',property_value)||
       ' as bash temporary tablespace.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';
set heading on

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
/


prompt
prompt
prompt ... Creating bash user

CREATE USER "BASH" IDENTIFIED BY &&bash_password
      DEFAULT TABLESPACE &&default_tablespace
      TEMPORARY TABLESPACE &&temporary_tablespace;

prompt
prompt
prompt ... Granting priviliges to bash user
	  
ALTER USER BASH QUOTA UNLIMITED ON &&default_tablespace;
GRANT CREATE JOB TO "BASH";
GRANT CREATE PUBLIC SYNONYM TO "BASH";
GRANT CREATE SESSION TO "BASH";
GRANT ALTER SESSION TO "BASH";
GRANT CREATE PROCEDURE TO "BASH";
GRANT CREATE SEQUENCE TO "BASH";
GRANT CREATE SYNONYM TO "BASH";
GRANT CREATE TABLE TO "BASH";
GRANT CREATE TRIGGER TO "BASH";
GRANT CREATE VIEW TO "BASH";

ALTER USER "BASH" DEFAULT ROLE ALL;

GRANT SELECT on GV_$SESSION TO BASH;
GRANT SELECT on V_$ACTIVE_SERVICES TO BASH;
GRANT SELECT on V_$EVENT_NAME TO BASH;
GRANT SELECT on V_$PROCESS TO BASH;
GRANT SELECT on V_$SESSION TO BASH;
GRANT SELECT on V_$SQL TO BASH;
GRANT SELECT on V_$TRANSACTION TO BASH;

GRANT EXECUTE ON DBMS_LOCK TO BASH;


prompt
prompt
prompt ... Installing sequences


CREATE SEQUENCE  "BASH"."BASH_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 200 NOORDER  NOCYCLE ;
CREATE SEQUENCE  "BASH"."BASH_LOG_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 200 ORDER  NOCYCLE ;

 
prompt
prompt
prompt ... Installing tables

CREATE TABLE "BASH"."BASH$SESSION_INTERNAL" 
   (	"SAMPLE_ID" NUMBER, 
	"SAMPLE_TIME" TIMESTAMP (3), 
	"SID" NUMBER, 
	"SERIAL#" NUMBER, 
	"USER#" NUMBER, 
	"USERNAME" VARCHAR2(30 BYTE), 
	"COMMAND" NUMBER, 
	"OSUSER" VARCHAR2(30 BYTE), 
	"MACHINE" VARCHAR2(64 BYTE), 
	"PORT" NUMBER, 
	"TERMINAL" VARCHAR2(16 BYTE), 
	"PROGRAM" VARCHAR2(64 BYTE), 
	"TYPE" VARCHAR2(10 BYTE), 
	"SQL_ID" VARCHAR2(13 BYTE), 
	"SQL_CHILD_NUMBER" NUMBER, 
	"SQL_EXEC_START" DATE, 
	"SQL_EXEC_ID" NUMBER, 
	"PLSQL_ENTRY_OBJECT_ID" NUMBER, 
	"PLSQL_ENTRY_SUBPROGRAM_ID" NUMBER, 
	"PLSQL_OBJECT_ID" NUMBER, 
	"PLSQL_SUBPROGRAM_ID" NUMBER, 
	"MODULE" VARCHAR2(64 BYTE), 
	"ACTION" VARCHAR2(64 BYTE), 
	"ROW_WAIT_OBJ#" NUMBER, 
	"ROW_WAIT_FILE#" NUMBER, 
	"ROW_WAIT_BLOCK#" NUMBER, 
	"TOP_LEVEL_CALL#" NUMBER, 
	"CLIENT_IDENTIFIER" VARCHAR2(64 BYTE), 
	"BLOCKING_SESSION_STATUS" VARCHAR2(11 BYTE), 
	"BLOCKING_SESSION" NUMBER, 
	"SEQ#" NUMBER, 
	"EVENT#" NUMBER, 
	"EVENT" VARCHAR2(64 BYTE), 
	"P1TEXT" VARCHAR2(64 BYTE), 
	"P1" NUMBER, 
	"P2TEXT" VARCHAR2(64 BYTE), 
	"P2" NUMBER, 
	"P3TEXT" VARCHAR2(64 BYTE), 
	"P3" NUMBER, 
	"WAIT_CLASS_ID" NUMBER, 
	"WAIT_CLASS" VARCHAR2(64 BYTE), 
	"WAIT_TIME" NUMBER, 
	"SECONDS_IN_WAIT" NUMBER, 
	"STATE" VARCHAR2(19 BYTE), 
	"ECID" VARCHAR2(64 BYTE), 
	"XID" RAW(8), 
	"SQL_PLAN_HASH_VALUE" NUMBER, 
	"FORCE_MATCHING_SIGNATURE" NUMBER, 
	"SERVICE_HASH" NUMBER, 
	"EVENT_ID" NUMBER, 
	"SQL_OPNAME" VARCHAR2(64 BYTE), 
	"INST_ID" NUMBER
   ) 
  TABLESPACE &&default_tablespace ;

CREATE TABLE "BASH"."BASH$SESSION_HIST_INTERNAL" 
   (	"SAMPLE_ID" NUMBER, 
	"SAMPLE_TIME" TIMESTAMP (3), 
	"SID" NUMBER, 
	"SERIAL#" NUMBER, 
	"USER#" NUMBER, 
	"USERNAME" VARCHAR2(30 BYTE), 
	"COMMAND" NUMBER, 
	"OSUSER" VARCHAR2(30 BYTE), 
	"MACHINE" VARCHAR2(64 BYTE), 
	"PORT" NUMBER, 
	"TERMINAL" VARCHAR2(16 BYTE), 
	"PROGRAM" VARCHAR2(64 BYTE), 
	"TYPE" VARCHAR2(10 BYTE), 
	"SQL_ID" VARCHAR2(13 BYTE), 
	"SQL_CHILD_NUMBER" NUMBER, 
	"SQL_EXEC_START" DATE, 
	"SQL_EXEC_ID" NUMBER, 
	"PLSQL_ENTRY_OBJECT_ID" NUMBER, 
	"PLSQL_ENTRY_SUBPROGRAM_ID" NUMBER, 
	"PLSQL_OBJECT_ID" NUMBER, 
	"PLSQL_SUBPROGRAM_ID" NUMBER, 
	"MODULE" VARCHAR2(64 BYTE), 
	"ACTION" VARCHAR2(64 BYTE), 
	"ROW_WAIT_OBJ#" NUMBER, 
	"ROW_WAIT_FILE#" NUMBER, 
	"ROW_WAIT_BLOCK#" NUMBER, 
	"TOP_LEVEL_CALL#" NUMBER, 
	"CLIENT_IDENTIFIER" VARCHAR2(64 BYTE), 
	"BLOCKING_SESSION_STATUS" VARCHAR2(11 BYTE), 
	"BLOCKING_SESSION" NUMBER, 
	"SEQ#" NUMBER, 
	"EVENT#" NUMBER, 
	"EVENT" VARCHAR2(64 BYTE), 
	"P1TEXT" VARCHAR2(64 BYTE), 
	"P1" NUMBER, 
	"P2TEXT" VARCHAR2(64 BYTE), 
	"P2" NUMBER, 
	"P3TEXT" VARCHAR2(64 BYTE), 
	"P3" NUMBER, 
	"WAIT_CLASS_ID" NUMBER, 
	"WAIT_CLASS" VARCHAR2(64 BYTE), 
	"WAIT_TIME" NUMBER, 
	"SECONDS_IN_WAIT" NUMBER, 
	"STATE" VARCHAR2(19 BYTE), 
	"ECID" VARCHAR2(64 BYTE), 
	"XID" RAW(8), 
	"SQL_PLAN_HASH_VALUE" NUMBER, 
	"FORCE_MATCHING_SIGNATURE" NUMBER, 
	"SERVICE_HASH" NUMBER, 
	"EVENT_ID" NUMBER, 
	"SQL_OPNAME" VARCHAR2(64 BYTE), 
	"INST_ID" NUMBER
   ) TABLESPACE &&default_tablespace ;

CREATE TABLE "BASH"."BASH$LOG_INTERNAL" 
   (	"LOG_MESSAGE" VARCHAR2(2000 BYTE), 
	"LOG_DATE" TIMESTAMP (3), 
	"LOG_ID" NUMBER(38,0)
   )   TABLESPACE &&default_tablespace ;


CREATE TABLE "BASH"."BASH$SETTINGS" 
   (	
    updated                               NUMBER(1),
    version                               NUMBER,
    sample_every_n_centiseconds           NUMBER,
    persist_every_n_samples               NUMBER,
    cleanup_every_n_samples               NUMBER,
    max_entries_kept                      NUMBER,
    logging_enabled                       NUMBER,
    keep_log_entries_n_days               NUMBER
    ) 
  TABLESPACE &&default_tablespace;
  
INSERT INTO "BASH"."BASH$SETTINGS"   
   (	
    updated,
	version,
	sample_every_n_centiseconds,
    persist_every_n_samples,
    cleanup_every_n_samples,
    max_entries_kept,
    logging_enabled,
    keep_log_entries_n_days               
    ) 
    VALUES
    (
    0,
	1,
	100,
    10,
    100,
    30000,
    0,
    1 
    );
    
COMMIT;   
   
CREATE OR REPLACE TRIGGER "BASH"."TRG_SETTINGS_AFTER_UPD" 
   AFTER UPDATE
   of 
   sample_every_n_centiseconds,
    persist_every_n_samples,
    cleanup_every_n_samples,
    max_entries_kept,
    logging_enabled,
    keep_log_entries_n_days  
   ON BASH.BASH$SETTINGS
BEGIN
update BASH.BASH$SETTINGS set UPDATED=1; 
END TRG_SETTINGS_AFTER_UPD; 
/   
   
prompt
prompt
prompt ... Installing indexes
   
CREATE INDEX "BASH"."IDX_BSI_SAMPLE_ID" ON "BASH"."BASH$SESSION_INTERNAL" ("SAMPLE_ID")  TABLESPACE &&default_tablespace;

CREATE INDEX "BASH"."IDX_SHI_SAMPLE_ID" ON "BASH"."BASH$SESSION_HIST_INTERNAL" ("SAMPLE_ID") TABLESPACE &&default_tablespace;

CREATE INDEX "BASH"."IDX_BSI_SAMPLE_TIME" ON "BASH"."BASH$SESSION_INTERNAL" ("SAMPLE_TIME") TABLESPACE &&default_tablespace;

CREATE INDEX "BASH"."IDX_LOG_LOG_DATE" ON "BASH"."BASH$LOG_INTERNAL" ("LOG_DATE") TABLESPACE &&default_tablespace;

CREATE INDEX "BASH"."IDX_LOG_LOG_ID" ON "BASH"."BASH$LOG_INTERNAL" ("LOG_ID") TABLESPACE &&default_tablespace;

CREATE INDEX "BASH"."IDX_SHI_SAMPLE_TIME" ON "BASH"."BASH$SESSION_HIST_INTERNAL" ("SAMPLE_TIME") TABLESPACE &&default_tablespace;

prompt
prompt
prompt ... Installing views

CREATE  FORCE VIEW "BASH"."VTABSESSIONS" ("SAMPLE_ID", "SAMPLE_TIME", "INST_ID", "SESSION_ID", "SESSION_SERIAL#", "USER_ID", "USERNAME", "SQL_OPCODE", "SQL_OPNAME", "OSUSER", "MACHINE", "PORT", "TERMINAL", "PROGRAM", "SESSION_TYPE", "SQL_ID", "SQL_CHILD_NUMBER", "SQL_EXEC_START", "SQL_EXEC_ID", "PLSQL_ENTRY_OBJECT_ID", "PLSQL_ENTRY_SUBPROGRAM_ID", "PLSQL_OBJECT_ID", "PLSQL_SUBPROGRAM_ID", "MODULE", "ACTION", "CURRENT_OBJ#", "CURRENT_FILE#", "CURRENT_BLOCK#", "TOP_LEVEL_CALL#", "CLIENT_ID", "BLOCKING_SESSION_STATUS", "BLOCKING_SESSION", "SEQ#", "EVENT#", "EVENT", "P1TEXT", "P1", "P2TEXT", "P2", "P3TEXT", "P3", "WAIT_CLASS_ID", "WAIT_CLASS", "WAIT_TIME", "TIME_WAITED", "SESSION_STATE", "ECID", "SQL_PLAN_HASH_VALUE", "FORCE_MATCHING_SIGNATURE", "SERVICE_HASH", "QC_SESSION_ID", "QC_INSTANCE_ID", "BLOCKING_SESSION_SERIAL#", "EVENT_ID", "XID", "FLAGS", "BLOCKING_HANGCHAIN_INFO", "BLOCKING_INST_ID", "CAPTURE_OVERHEAD", "CONSUMER_GROUP_ID", "CURRENT_ROW#", "DBREPLAY_CALL_COUNTER", "DBREPLAY_FILE_ID", "DELTA_INTERCONNECT_IO_BYTES", "DELTA_READ_IO_BYTES", "DELTA_READ_IO_REQUESTS", "DELTA_TIME", "DELTA_WRITE_IO_BYTES", "DELTA_WRITE_IO_REQUESTS", "IN_BIND", "IN_CONNECTION_MGMT", "IN_CURSOR_CLOSE", "IN_HARD_PARSE", "IN_JAVA_EXECUTION", "IN_PARSE", "IN_PLSQL_COMPILATION", "IN_PLSQL_EXECUTION", "IN_PLSQL_RPC", "IN_SEQUENCE_LOAD", "IN_SQL_EXECUTION", "IS_AWR_SAMPLE", "IS_CAPTURED", "IS_REPLAYED", "IS_SQLID_CURRENT", "PGA_ALLOCATED", "PX_FLAGS", "QC_SESSION_SERIAL#", "REMOTE_INSTANCE#", "REPLAY_OVERHEAD", "SQL_PLAN_LINE_ID", "SQL_PLAN_OPERATION", "SQL_PLAN_OPTIONS", "TEMP_SPACE_ALLOCATED", "TIME_MODEL", "TM_DELTA_CPU_TIME", "TM_DELTA_DB_TIME", "TM_DELTA_TIME", "TOP_LEVEL_CALL_NAME", "TOP_LEVEL_SQL_ID", "TOP_LEVEL_SQL_OPCODE") AS 
  SELECT "SAMPLE_ID",
    "SAMPLE_TIME",
    "INST_ID",
    "SID" SESSION_ID,
    "SERIAL#" SESSION_SERIAL#,
    TO_NUMBER("USER#") user_id,
    "USERNAME",
    "COMMAND" sql_opcode,
    "SQL_OPNAME" sql_opname,
    "OSUSER",
    "MACHINE",
    "PORT",
    "TERMINAL",
    "PROGRAM" PROGRAM,
    "TYPE" session_type,
    "SQL_ID" sql_id,
    "SQL_CHILD_NUMBER" sql_child_number,
    "SQL_EXEC_START",
    "SQL_EXEC_ID",
    "PLSQL_ENTRY_OBJECT_ID" PLSQL_ENTRY_OBJECT_ID,
    "PLSQL_ENTRY_SUBPROGRAM_ID" plsql_entry_subprogram_id,
    "PLSQL_OBJECT_ID" plsql_object_id,
    "PLSQL_SUBPROGRAM_ID" plsql_subprogram_id,
    "MODULE" MODULE,
    "ACTION" ACTION,
    "ROW_WAIT_OBJ#" current_obj#,
    "ROW_WAIT_FILE#" current_file#,
    "ROW_WAIT_BLOCK#" current_block#,
    "TOP_LEVEL_CALL#",
    "CLIENT_IDENTIFIER" CLIENT_ID,
    "BLOCKING_SESSION_STATUS" BLOCKING_SESSION_STATUS,
    "BLOCKING_SESSION" BLOCKING_SESSION,
    "SEQ#" SEQ#,
    "EVENT#" EVENT#,
    "EVENT" EVENT,
    "P1TEXT" P1TEXT,
    "P1" P1,
    "P2TEXT" P2TEXT,
    "P2" P2,
    "P3TEXT" P3TEXT,
    "P3" P3,
    "WAIT_CLASS_ID" WAIT_CLASS_ID,
    "WAIT_CLASS" WAIT_CLASS,
    "WAIT_TIME" WAIT_TIME,
    "SECONDS_IN_WAIT" time_waited,
    "STATE" session_state,
    "ECID",
    sql_plan_hash_value sql_plan_hash_value,
    force_matching_signature force_matching_signature,
    "SERVICE_HASH" service_hash,
    to_number(NULL) qc_session_id,            --10.2 ASH Column not supported in BASH
    to_number(0) qc_instance_id,              --10.2 ASH Column not supported in BASH
    TO_NUMBER(NULL) blocking_session_serial#, --10.2 ASH Column not supported in BASH
    EVENT_ID EVENT_ID,
    XID XID,
    0 flags,
    --COLUMNS in 11.2, but not supported in BASH:
    TO_CHAR(NULL) BLOCKING_HANGCHAIN_INFO,
    to_number(NULL) BLOCKING_INST_ID,
    TO_CHAR(NULL) CAPTURE_OVERHEAD,
    to_number(NULL) CONSUMER_GROUP_ID,
    to_number(NULL) CURRENT_ROW#,
    to_number(NULL) DBREPLAY_CALL_COUNTER,
    to_number(NULL) DBREPLAY_FILE_ID,
    to_number(NULL) DELTA_INTERCONNECT_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_REQUESTS,
    to_number(NULL) DELTA_TIME,
    to_number(NULL) DELTA_WRITE_IO_BYTES,
    to_number(NULL) DELTA_WRITE_IO_REQUESTS,
    TO_CHAR(NULL) IN_BIND,
    TO_CHAR(NULL) IN_CONNECTION_MGMT,
    TO_CHAR(NULL) IN_CURSOR_CLOSE,
    TO_CHAR(NULL) IN_HARD_PARSE,
    TO_CHAR(NULL) IN_JAVA_EXECUTION,
    TO_CHAR(NULL) IN_PARSE,
    TO_CHAR(NULL) IN_PLSQL_COMPILATION,
    TO_CHAR(NULL) IN_PLSQL_EXECUTION,
    TO_CHAR(NULL) IN_PLSQL_RPC,
    TO_CHAR(NULL) IN_SEQUENCE_LOAD,
    TO_CHAR(NULL) IN_SQL_EXECUTION,
    TO_CHAR(NULL) IS_AWR_SAMPLE,
    TO_CHAR(NULL) IS_CAPTURED,
    TO_CHAR(NULL) IS_REPLAYED,
    TO_CHAR(NULL) IS_SQLID_CURRENT,
    to_number(NULL) PGA_ALLOCATED,
    to_number(NULL) PX_FLAGS,
    to_number(NULL) QC_SESSION_SERIAL#,
    to_number(NULL) REMOTE_INSTANCE#,
    TO_CHAR(NULL) REPLAY_OVERHEAD,
    to_number(NULL) SQL_PLAN_LINE_ID,
    TO_CHAR(NULL) SQL_PLAN_OPERATION,
    TO_CHAR(NULL) SQL_PLAN_OPTIONS,
    to_number(NULL) TEMP_SPACE_ALLOCATED,
    to_number(NULL) TIME_MODEL,
    to_number(NULL) TM_DELTA_CPU_TIME,
    to_number(NULL) TM_DELTA_DB_TIME,
    to_number(NULL) TM_DELTA_TIME,
    TO_CHAR(NULL) TOP_LEVEL_CALL_NAME,
    TO_CHAR(NULL) TOP_LEVEL_SQL_ID,
    to_number(NULL) TOP_LEVEL_SQL_OPCODE
  FROM BASH$SESSION_INTERNAL
  WHERE inst_id = USERENV('Instance');
  
  
CREATE  FORCE VIEW "BASH"."VTABSESSIONSHIST" ("SAMPLE_ID", "SAMPLE_TIME", "SESSION_ID", "SESSION_SERIAL#", "USER_ID", "USERNAME", "SQL_OPCODE", "SQL_OPNAME", "OSUSER", "MACHINE", "PORT", "TERMINAL", "PROGRAM", "SESSION_TYPE", "SQL_ID", "SQL_CHILD_NUMBER", "SQL_EXEC_START", "SQL_EXEC_ID", "PLSQL_ENTRY_OBJECT_ID", "PLSQL_ENTRY_SUBPROGRAM_ID", "PLSQL_OBJECT_ID", "PLSQL_SUBPROGRAM_ID", "MODULE", "ACTION", "CURRENT_OBJ#", "CURRENT_FILE#", "CURRENT_BLOCK#", "TOP_LEVEL_CALL#", "CLIENT_ID", "BLOCKING_SESSION_STATUS", "BLOCKING_SESSION", "SEQ#", "EVENT#", "EVENT", "P1TEXT", "P1", "P2TEXT", "P2", "P3TEXT", "P3", "WAIT_CLASS_ID", "WAIT_CLASS", "WAIT_TIME", "TIME_WAITED", "SESSION_STATE", "ECID", "SQL_PLAN_HASH_VALUE", "FORCE_MATCHING_SIGNATURE", "SERVICE_HASH", "QC_SESSION_ID", "QC_INSTANCE_ID", "BLOCKING_SESSION_SERIAL#", "EVENT_ID", "XID", "FLAGS", "BLOCKING_HANGCHAIN_INFO", "BLOCKING_INST_ID", "CAPTURE_OVERHEAD", "CONSUMER_GROUP_ID", "CURRENT_ROW#", "DBREPLAY_CALL_COUNTER", "DBREPLAY_FILE_ID", "DELTA_INTERCONNECT_IO_BYTES", "DELTA_READ_IO_BYTES", "DELTA_READ_IO_REQUESTS", "DELTA_TIME", "DELTA_WRITE_IO_BYTES", "DELTA_WRITE_IO_REQUESTS", "IN_BIND", "IN_CONNECTION_MGMT", "IN_CURSOR_CLOSE", "IN_HARD_PARSE", "IN_JAVA_EXECUTION", "IN_PARSE", "IN_PLSQL_COMPILATION", "IN_PLSQL_EXECUTION", "IN_PLSQL_RPC", "IN_SEQUENCE_LOAD", "IN_SQL_EXECUTION", "IS_AWR_SAMPLE", "IS_CAPTURED", "IS_REPLAYED", "IS_SQLID_CURRENT", "PGA_ALLOCATED", "PX_FLAGS", "QC_SESSION_SERIAL#", "REMOTE_INSTANCE#", "REPLAY_OVERHEAD", "SQL_PLAN_LINE_ID", "SQL_PLAN_OPERATION", "SQL_PLAN_OPTIONS", "TEMP_SPACE_ALLOCATED", "TIME_MODEL", "TM_DELTA_CPU_TIME", "TM_DELTA_DB_TIME", "TM_DELTA_TIME", "TOP_LEVEL_CALL_NAME", "TOP_LEVEL_SQL_ID", "TOP_LEVEL_SQL_OPCODE") AS 
  SELECT "SAMPLE_ID",
    "SAMPLE_TIME",
    "SID" SESSION_ID,
    "SERIAL#" SESSION_SERIAL#,
    TO_NUMBER("USER#") user_id,
    "USERNAME",
    "COMMAND" sql_opcode,
    "SQL_OPNAME" sql_opname,
    "OSUSER",
    "MACHINE",
    "PORT",
    "TERMINAL",
    "PROGRAM" PROGRAM,
    "TYPE" session_type,
    "SQL_ID" sql_id,
    "SQL_CHILD_NUMBER" sql_child_number,
    "SQL_EXEC_START",
    "SQL_EXEC_ID",
    "PLSQL_ENTRY_OBJECT_ID" PLSQL_ENTRY_OBJECT_ID,
    "PLSQL_ENTRY_SUBPROGRAM_ID" plsql_entry_subprogram_id,
    "PLSQL_OBJECT_ID" plsql_object_id,
    "PLSQL_SUBPROGRAM_ID" plsql_subprogram_id,
    "MODULE" MODULE,
    "ACTION" ACTION,
    "ROW_WAIT_OBJ#" current_obj#,
    "ROW_WAIT_FILE#" current_file#,
    "ROW_WAIT_BLOCK#" current_block#,
    "TOP_LEVEL_CALL#",
    "CLIENT_IDENTIFIER" CLIENT_ID,
    "BLOCKING_SESSION_STATUS" BLOCKING_SESSION_STATUS,
    "BLOCKING_SESSION" BLOCKING_SESSION,
    "SEQ#" SEQ#,
    "EVENT#" EVENT#,
    "EVENT" EVENT,
    "P1TEXT" P1TEXT,
    "P1" P1,
    "P2TEXT" P2TEXT,
    "P2" P2,
    "P3TEXT" P3TEXT,
    "P3" P3,
    "WAIT_CLASS_ID" WAIT_CLASS_ID,
    "WAIT_CLASS" WAIT_CLASS,
    "WAIT_TIME" WAIT_TIME,
    "SECONDS_IN_WAIT" time_waited,
    "STATE" session_state,
    "ECID",
    sql_plan_hash_value sql_plan_hash_value,
    force_matching_signature force_matching_signature,
    "SERVICE_HASH" service_hash,
    --COLUMNS in 10.2, but not supported in BASH:
    0 qc_session_id,
    0 qc_instance_id,
    TO_NUMBER(NULL) blocking_session_serial#,
    EVENT_ID EVENT_ID,
    XID XID,
    0 flags,
    --COLUMNS in 11.2, but not supported in BASH:
    TO_CHAR(NULL) BLOCKING_HANGCHAIN_INFO,
    to_number(NULL) BLOCKING_INST_ID,
    TO_CHAR(NULL) CAPTURE_OVERHEAD,
    to_number(NULL) CONSUMER_GROUP_ID,
    to_number(NULL) CURRENT_ROW#,
    to_number(NULL) DBREPLAY_CALL_COUNTER,
    to_number(NULL) DBREPLAY_FILE_ID,
    to_number(NULL) DELTA_INTERCONNECT_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_REQUESTS,
    to_number(NULL) DELTA_TIME,
    to_number(NULL) DELTA_WRITE_IO_BYTES,
    to_number(NULL) DELTA_WRITE_IO_REQUESTS,
    TO_CHAR(NULL) IN_BIND,
    TO_CHAR(NULL) IN_CONNECTION_MGMT,
    TO_CHAR(NULL) IN_CURSOR_CLOSE,
    TO_CHAR(NULL) IN_HARD_PARSE,
    TO_CHAR(NULL) IN_JAVA_EXECUTION,
    TO_CHAR(NULL) IN_PARSE,
    TO_CHAR(NULL) IN_PLSQL_COMPILATION,
    TO_CHAR(NULL) IN_PLSQL_EXECUTION,
    TO_CHAR(NULL) IN_PLSQL_RPC,
    TO_CHAR(NULL) IN_SEQUENCE_LOAD,
    TO_CHAR(NULL) IN_SQL_EXECUTION,
    TO_CHAR(NULL) IS_AWR_SAMPLE,
    TO_CHAR(NULL) IS_CAPTURED,
    TO_CHAR(NULL) IS_REPLAYED,
    TO_CHAR(NULL) IS_SQLID_CURRENT,
    to_number(NULL) PGA_ALLOCATED,
    to_number(NULL) PX_FLAGS,
    to_number(NULL) QC_SESSION_SERIAL#,
    to_number(NULL) REMOTE_INSTANCE#,
    TO_CHAR(NULL) REPLAY_OVERHEAD,
    to_number(NULL) SQL_PLAN_LINE_ID,
    TO_CHAR(NULL) SQL_PLAN_OPERATION,
    TO_CHAR(NULL) SQL_PLAN_OPTIONS,
    to_number(NULL) TEMP_SPACE_ALLOCATED,
    to_number(NULL) TIME_MODEL,
    to_number(NULL) TM_DELTA_CPU_TIME,
    to_number(NULL) TM_DELTA_DB_TIME,
    to_number(NULL) TM_DELTA_TIME,
    TO_CHAR(NULL) TOP_LEVEL_CALL_NAME,
    TO_CHAR(NULL) TOP_LEVEL_SQL_ID,
    to_number(NULL) TOP_LEVEL_SQL_OPCODE
  FROM "BASH"."BASH$SESSION_HIST_INTERNAL"
;
CREATE  FORCE VIEW "BASH"."GVTABSESSIONS" ("SAMPLE_ID", "SAMPLE_TIME", "INST_ID", "SESSION_ID", "SESSION_SERIAL#", "USER_ID", "USERNAME", "SQL_OPCODE", "SQL_OPNAME", "OSUSER", "MACHINE", "PORT", "TERMINAL", "PROGRAM", "SESSION_TYPE", "SQL_ID", "SQL_CHILD_NUMBER", "SQL_EXEC_START", "SQL_EXEC_ID", "PLSQL_ENTRY_OBJECT_ID", "PLSQL_ENTRY_SUBPROGRAM_ID", "PLSQL_OBJECT_ID", "PLSQL_SUBPROGRAM_ID", "MODULE", "ACTION", "CURRENT_OBJ#", "CURRENT_FILE#", "CURRENT_BLOCK#", "TOP_LEVEL_CALL#", "CLIENT_ID", "BLOCKING_SESSION_STATUS", "BLOCKING_SESSION", "SEQ#", "EVENT#", "EVENT", "P1TEXT", "P1", "P2TEXT", "P2", "P3TEXT", "P3", "WAIT_CLASS_ID", "WAIT_CLASS", "WAIT_TIME", "TIME_WAITED", "SESSION_STATE", "ECID", "SQL_PLAN_HASH_VALUE", "FORCE_MATCHING_SIGNATURE", "SERVICE_HASH", "QC_SESSION_ID", "QC_INSTANCE_ID", "BLOCKING_SESSION_SERIAL#", "EVENT_ID", "XID", "FLAGS", "BLOCKING_HANGCHAIN_INFO", "BLOCKING_INST_ID", "CAPTURE_OVERHEAD", "CONSUMER_GROUP_ID", "CURRENT_ROW#", "DBREPLAY_CALL_COUNTER", "DBREPLAY_FILE_ID", "DELTA_INTERCONNECT_IO_BYTES", "DELTA_READ_IO_BYTES", "DELTA_READ_IO_REQUESTS", "DELTA_TIME", "DELTA_WRITE_IO_BYTES", "DELTA_WRITE_IO_REQUESTS", "IN_BIND", "IN_CONNECTION_MGMT", "IN_CURSOR_CLOSE", "IN_HARD_PARSE", "IN_JAVA_EXECUTION", "IN_PARSE", "IN_PLSQL_COMPILATION", "IN_PLSQL_EXECUTION", "IN_PLSQL_RPC", "IN_SEQUENCE_LOAD", "IN_SQL_EXECUTION", "IS_AWR_SAMPLE", "IS_CAPTURED", "IS_REPLAYED", "IS_SQLID_CURRENT", "PGA_ALLOCATED", "PX_FLAGS", "QC_SESSION_SERIAL#", "REMOTE_INSTANCE#", "REPLAY_OVERHEAD", "SQL_PLAN_LINE_ID", "SQL_PLAN_OPERATION", "SQL_PLAN_OPTIONS", "TEMP_SPACE_ALLOCATED", "TIME_MODEL", "TM_DELTA_CPU_TIME", "TM_DELTA_DB_TIME", "TM_DELTA_TIME", "TOP_LEVEL_CALL_NAME", "TOP_LEVEL_SQL_ID", "TOP_LEVEL_SQL_OPCODE") AS 
  SELECT "SAMPLE_ID",
    "SAMPLE_TIME",
    "INST_ID",
    "SID" SESSION_ID,
    "SERIAL#" SESSION_SERIAL#,
    TO_NUMBER("USER#") user_id,
    "USERNAME",
    "COMMAND" sql_opcode,
    "SQL_OPNAME" sql_opname,
    "OSUSER",
    "MACHINE",
    "PORT",
    "TERMINAL",
    "PROGRAM" PROGRAM,
    "TYPE" session_type,
    "SQL_ID" sql_id,
    "SQL_CHILD_NUMBER" sql_child_number,
    "SQL_EXEC_START",
    "SQL_EXEC_ID",
    "PLSQL_ENTRY_OBJECT_ID" PLSQL_ENTRY_OBJECT_ID,
    "PLSQL_ENTRY_SUBPROGRAM_ID" plsql_entry_subprogram_id,
    "PLSQL_OBJECT_ID" plsql_object_id,
    "PLSQL_SUBPROGRAM_ID" plsql_subprogram_id,
    "MODULE" MODULE,
    "ACTION" ACTION,
    "ROW_WAIT_OBJ#" current_obj#,
    "ROW_WAIT_FILE#" current_file#,
    "ROW_WAIT_BLOCK#" current_block#,
    "TOP_LEVEL_CALL#",
    "CLIENT_IDENTIFIER" CLIENT_ID,
    "BLOCKING_SESSION_STATUS" BLOCKING_SESSION_STATUS,
    "BLOCKING_SESSION" BLOCKING_SESSION,
    "SEQ#" SEQ#,
    "EVENT#" EVENT#,
    "EVENT" EVENT,
    "P1TEXT" P1TEXT,
    "P1" P1,
    "P2TEXT" P2TEXT,
    "P2" P2,
    "P3TEXT" P3TEXT,
    "P3" P3,
    "WAIT_CLASS_ID" WAIT_CLASS_ID,
    "WAIT_CLASS" WAIT_CLASS,
    "WAIT_TIME" WAIT_TIME,
    "SECONDS_IN_WAIT" time_waited,
    "STATE" session_state,
    "ECID",
    sql_plan_hash_value sql_plan_hash_value,
    force_matching_signature force_matching_signature,
    "SERVICE_HASH" service_hash,
    to_number(NULL) qc_session_id,            --10.2 ASH Column not supported in BASH
    to_number(0) qc_instance_id,              --10.2 ASH Column not supported in BASH
    TO_NUMBER(NULL) blocking_session_serial#, --10.2 ASH Column not supported in BASH
    EVENT_ID EVENT_ID,
    XID XID,
    0 flags,
    --COLUMNS in 11.2, but not supported in BASH:
    TO_CHAR(NULL) BLOCKING_HANGCHAIN_INFO,
    to_number(NULL) BLOCKING_INST_ID,
    TO_CHAR(NULL) CAPTURE_OVERHEAD,
    to_number(NULL) CONSUMER_GROUP_ID,
    to_number(NULL) CURRENT_ROW#,
    to_number(NULL) DBREPLAY_CALL_COUNTER,
    to_number(NULL) DBREPLAY_FILE_ID,
    to_number(NULL) DELTA_INTERCONNECT_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_BYTES,
    to_number(NULL) DELTA_READ_IO_REQUESTS,
    to_number(NULL) DELTA_TIME,
    to_number(NULL) DELTA_WRITE_IO_BYTES,
    to_number(NULL) DELTA_WRITE_IO_REQUESTS,
    TO_CHAR(NULL) IN_BIND,
    TO_CHAR(NULL) IN_CONNECTION_MGMT,
    TO_CHAR(NULL) IN_CURSOR_CLOSE,
    TO_CHAR(NULL) IN_HARD_PARSE,
    TO_CHAR(NULL) IN_JAVA_EXECUTION,
    TO_CHAR(NULL) IN_PARSE,
    TO_CHAR(NULL) IN_PLSQL_COMPILATION,
    TO_CHAR(NULL) IN_PLSQL_EXECUTION,
    TO_CHAR(NULL) IN_PLSQL_RPC,
    TO_CHAR(NULL) IN_SEQUENCE_LOAD,
    TO_CHAR(NULL) IN_SQL_EXECUTION,
    TO_CHAR(NULL) IS_AWR_SAMPLE,
    TO_CHAR(NULL) IS_CAPTURED,
    TO_CHAR(NULL) IS_REPLAYED,
    TO_CHAR(NULL) IS_SQLID_CURRENT,
    to_number(NULL) PGA_ALLOCATED,
    to_number(NULL) PX_FLAGS,
    to_number(NULL) QC_SESSION_SERIAL#,
    to_number(NULL) REMOTE_INSTANCE#,
    TO_CHAR(NULL) REPLAY_OVERHEAD,
    to_number(NULL) SQL_PLAN_LINE_ID,
    TO_CHAR(NULL) SQL_PLAN_OPERATION,
    TO_CHAR(NULL) SQL_PLAN_OPTIONS,
    to_number(NULL) TEMP_SPACE_ALLOCATED,
    to_number(NULL) TIME_MODEL,
    to_number(NULL) TM_DELTA_CPU_TIME,
    to_number(NULL) TM_DELTA_DB_TIME,
    to_number(NULL) TM_DELTA_TIME,
    TO_CHAR(NULL) TOP_LEVEL_CALL_NAME,
    TO_CHAR(NULL) TOP_LEVEL_SQL_ID,
    to_number(NULL) TOP_LEVEL_SQL_OPCODE
  FROM BASH$SESSION_INTERNAL;

prompt
prompt
prompt ... Installing packages   
   
CREATE PACKAGE BASH.BASH AS
  procedure run;
  procedure stop;
  procedure purge (days_to_keep NUMBER);
  procedure runner;  
END BASH;
/


CREATE OR REPLACE PACKAGE BODY      BASH.BASH
AS
  -- Constants
  C_BASH_JOB_ID             CONSTANT NUMBER:=2874615647;
  C_LOCK_ID_COLLECTOR       CONSTANT NUMBER := 1237820;

  -- Settings
  s_sample_every            NUMBER := 100; --centiseconds
  s_persist_every           NUMBER := 10;  --# of samples
  s_cleanup_every           NUMBER := 100; --# of memory samples
  s_cleanup_log_every       NUMBER := 100; --# of persisted samples (100*10 seconds=1000 seconds)
  s_max_entries_kept        NUMBER :=30000;
  s_logging                 NUMBER :=0;
  s_keep_log_entries        NUMBER :=1; --# of days

  -- Variables
  g_last_snapshot_persisted NUMBER;
  g_last_snapshot_flushed   NUMBER;
  g_own_sid                 NUMBER;


PROCEDURE log(
    p_line VARCHAR2)
IS
BEGIN
  IF s_logging                                         =1 THEN
    IF mod(g_last_snapshot_persisted,s_cleanup_log_every)=0 THEN
      DELETE FROM bash$log_INTERNAL WHERE log_date< sysdate-s_keep_log_entries;
    END IF;
    INSERT
    INTO bash$log_INTERNAL
      (
        LOG_ID,
        LOG_DATE,
        LOG_MESSAGE
      )
      VALUES
      (
        bash_log_seq.nextval,
        systimestamp,
        p_line
      );
    COMMIT;
  END IF;
END;

procedure read_setting
is
l_updated NUMBER;
begin
SELECT UPDATED into l_updated FROM bash.bash$settings;
if l_updated<>0 then
log('Reloading settings...');
SELECT 
   sample_every_n_centiseconds,
    persist_every_n_samples,
    cleanup_every_n_samples,
    max_entries_kept,
    logging_enabled,
    keep_log_entries_n_days
    into 
    s_sample_every,s_persist_every,s_cleanup_every,s_max_entries_kept,s_logging,s_keep_log_entries 
FROM bash.bash$settings;
UPDATE bash.bash$settings set UPDATED=0;
COMMIT;
log('Reloading settings done.');
end if;
end;


PROCEDURE collector
IS
  l_sample_id   NUMBER;
  l_sample_time TIMESTAMP(3);
BEGIN
  select bash_seq.nextval into l_sample_id from dual;
  l_sample_time:=systimestamp;
  INSERT
  INTO bash.bash$session_INTERNAL
    (
      SAMPLE_ID,
      SAMPLE_TIME,
      INST_ID,
      SID,
      SERIAL#,
      USER#,
      USERNAME,
      COMMAND,
      OSUSER,
      MACHINE,
      PORT,
      TERMINAL,
      PROGRAM,
      TYPE,
      SQL_ID,
      SQL_CHILD_NUMBER,
      SQL_EXEC_START,
      SQL_EXEC_ID,
      PLSQL_ENTRY_OBJECT_ID,
      PLSQL_ENTRY_SUBPROGRAM_ID,
      PLSQL_OBJECT_ID,
      PLSQL_SUBPROGRAM_ID,
      MODULE,
      ACTION,
      ROW_WAIT_OBJ#,
      ROW_WAIT_FILE#,
      ROW_WAIT_BLOCK#,
      TOP_LEVEL_CALL#,
      CLIENT_IDENTIFIER,
      BLOCKING_SESSION_STATUS,
      BLOCKING_SESSION,
      SEQ#,
      EVENT#,
      EVENT,
      P1TEXT,
      P1,
      P2TEXT,
      P2,
      P3TEXT,
      P3,
      WAIT_CLASS_ID,
      WAIT_CLASS,
      WAIT_TIME,
      SECONDS_IN_WAIT,
      STATE,
      ECID,
      xid,
      sql_plan_hash_value,
      FORCE_MATCHING_SIGNATURE,
      SERVICE_HASH,
      sql_opname,
      EVENT_ID
    )
    (SELECT l_sample_id,
        l_sample_time,
        s.INST_ID,
        s.SID,
        s.SERIAL#,
        s.USER#,
        s.USERNAME,
        s.COMMAND,
        s.OSUSER,
        s.MACHINE,
&_IF_ORA11_OR_HIGHER  s.PORT,  -- Oracle 11 only
&_IF_LOWER_THAN_ORA11 NULL,
        s.TERMINAL,
        s.PROGRAM,
        s.TYPE,
        s.SQL_ID,
        s.SQL_CHILD_NUMBER,
&_IF_ORA11_OR_HIGHER  s.SQL_EXEC_START,  -- Oracle 11 only
&_IF_LOWER_THAN_ORA11 NULL,
&_IF_ORA11_OR_HIGHER  s.SQL_EXEC_ID,  -- Oracle 11 only
&_IF_LOWER_THAN_ORA11 NULL,
        s.PLSQL_ENTRY_OBJECT_ID,
        s.PLSQL_ENTRY_SUBPROGRAM_ID,
        s.PLSQL_OBJECT_ID,
        s.PLSQL_SUBPROGRAM_ID,
        s.MODULE,
        s.ACTION,
        s.ROW_WAIT_OBJ#,
        s.ROW_WAIT_FILE#,
        s.ROW_WAIT_BLOCK#,
&_IF_ORA11_OR_HIGHER  s.TOP_LEVEL_CALL#,  -- Oracle 11 only
&_IF_LOWER_THAN_ORA11 NULL,
        s.CLIENT_IDENTIFIER,
        s.BLOCKING_SESSION_STATUS,
        s.BLOCKING_SESSION,
        s.SEQ#,
        s.EVENT#,
        s.EVENT,
        s.P1TEXT,
        s.P1,
        s.P2TEXT,
        s.P2,
        s.P3TEXT,
        s.P3,
        s.WAIT_CLASS_ID,
        s.WAIT_CLASS,
        s.WAIT_TIME,
        s.SECONDS_IN_WAIT,
        s.STATE,
&_IF_ORA11_OR_HIGHER          s.ECID, -- Oracle 11 only
&_IF_LOWER_THAN_ORA11 NULL,
        t.xid,
        sq.plan_hash_value,
        sq.FORCE_MATCHING_SIGNATURE,
        serv.name_hash,
        CASE S.COMMAND
          WHEN 0
          THEN 'UNKNOWN'
          WHEN 1
          THEN 'CREATE TABLE'
          WHEN 2
          THEN 'INSERT'
          WHEN 3
          THEN 'SELECT'
          WHEN 4
          THEN 'CREATE CLUSTER'
          WHEN 5
          THEN 'ALTER CLUSTER'
          WHEN 6
          THEN 'UPDATE'
          WHEN 7
          THEN 'DELETE'
          WHEN 8
          THEN 'DROP CLUSTER'
          WHEN 9
          THEN 'CREATE INDEX'
          WHEN 10
          THEN 'DROP INDEX'
          WHEN 11
          THEN 'ALTER INDEX'
          WHEN 12
          THEN 'DROP TABLE'
          WHEN 13
          THEN 'CREATE SEQUENCE'
          WHEN 14
          THEN 'ALTER SEQUENCE'
          WHEN 15
          THEN 'ALTER TABLE'
          WHEN 16
          THEN 'DROP SEQUENCE'
          WHEN 17
          THEN 'GRANT OBJECT'
          WHEN 18
          THEN 'REVOKE OBJECT'
          WHEN 19
          THEN 'CREATE SYNONYM'
          WHEN 20
          THEN 'DROP SYNONYM'
          WHEN 21
          THEN 'CREATE VIEW'
          WHEN 22
          THEN 'DROP VIEW'
          WHEN 23
          THEN 'VALIDATE INDEX'
          WHEN 24
          THEN 'CREATE PROCEDURE'
          WHEN 25
          THEN 'ALTER PROCEDURE'
          WHEN 26
          THEN 'LOCK'
          WHEN 27
          THEN 'NO-OP'
          WHEN 28
          THEN 'RENAME'
          WHEN 29
          THEN 'COMMENT'
          WHEN 30
          THEN 'AUDIT OBJECT'
          WHEN 31
          THEN 'NOAUDIT OBJECT'
          WHEN 32
          THEN 'CREATE DATABASE LINK'
          WHEN 33
          THEN 'DROP DATABASE LINK'
          WHEN 34
          THEN 'CREATE DATABASE'
          WHEN 35
          THEN 'ALTER DATABASE'
          WHEN 36
          THEN 'CREATE ROLLBACK SEG'
          WHEN 37
          THEN 'ALTER ROLLBACK SEG'
          WHEN 38
          THEN 'DROP ROLLBACK SEG'
          WHEN 39
          THEN 'CREATE TABLESPACE'
          WHEN 40
          THEN 'ALTER TABLESPACE'
          WHEN 41
          THEN 'DROP TABLESPACE'
          WHEN 42
          THEN 'ALTER SESSION'
          WHEN 43
          THEN 'ALTER USER'
          WHEN 44
          THEN 'COMMIT'
          WHEN 45
          THEN 'ROLLBACK'
          WHEN 46
          THEN 'SAVEPOINT'
          WHEN 47
          THEN 'PL/SQL EXECUTE'
          WHEN 48
          THEN 'SET TRANSACTION'
          WHEN 49
          THEN 'ALTER SYSTEM'
          WHEN 50
          THEN 'EXPLAIN'
          WHEN 51
          THEN 'CREATE USER'
          WHEN 52
          THEN 'CREATE ROLE'
          WHEN 53
          THEN 'DROP USER'
          WHEN 54
          THEN 'DROP ROLE'
          WHEN 55
          THEN 'SET ROLE'
          WHEN 56
          THEN 'CREATE SCHEMA'
          WHEN 57
          THEN 'CREATE CONTROL FILE'
          WHEN 59
          THEN 'CREATE TRIGGER'
          WHEN 60
          THEN 'ALTER TRIGGER'
          WHEN 61
          THEN 'DROP TRIGGER'
          WHEN 62
          THEN 'ANALYZE TABLE'
          WHEN 63
          THEN 'ANALYZE INDEX'
          WHEN 64
          THEN 'ANALYZE CLUSTER'
          WHEN 65
          THEN 'CREATE PROFILE'
          WHEN 66
          THEN 'DROP PROFILE'
          WHEN 67
          THEN 'ALTER PROFILE'
          WHEN 68
          THEN 'DROP PROCEDURE'
          WHEN 70
          THEN 'ALTER RESOURCE COST'
          WHEN 71
          THEN 'CREATE MATERIALIZED VIEW LOG'
          WHEN 72
          THEN 'ALTER MATERIALIZED VIEW LOG'
          WHEN 73
          THEN 'DROP MATERIALIZED VIEW LOG'
          WHEN 74
          THEN 'CREATE MATERIALIZED VIEW'
          WHEN 75
          THEN 'ALTER MATERIALIZED VIEW'
          WHEN 76
          THEN 'DROP MATERIALIZED VIEW'
          WHEN 77
          THEN 'CREATE TYPE'
          WHEN 78
          THEN 'DROP TYPE'
          WHEN 79
          THEN 'ALTER ROLE'
          WHEN 80
          THEN 'ALTER TYPE'
          WHEN 81
          THEN 'CREATE TYPE BODY'
          WHEN 82
          THEN 'ALTER TYPE BODY'
          WHEN 83
          THEN 'DROP TYPE BODY'
          WHEN 84
          THEN 'DROP LIBRARY'
          WHEN 85
          THEN 'TRUNCATE TABLE'
          WHEN 86
          THEN 'TRUNCATE CLUSTER'
          WHEN 88
          THEN 'ALTER VIEW'
          WHEN 91
          THEN 'CREATE FUNCTION'
          WHEN 92
          THEN 'ALTER FUNCTION'
          WHEN 93
          THEN 'DROP FUNCTION'
          WHEN 94
          THEN 'CREATE PACKAGE'
          WHEN 95
          THEN 'ALTER PACKAGE'
          WHEN 96
          THEN 'DROP PACKAGE'
          WHEN 97
          THEN 'CREATE PACKAGE BODY'
          WHEN 98
          THEN 'ALTER PACKAGE BODY'
          WHEN 99
          THEN 'DROP PACKAGE BODY'
          WHEN 100
          THEN 'LOGON'
          WHEN 101
          THEN 'LOGOFF'
          WHEN 102
          THEN 'LOGOFF BY CLEANUP'
          WHEN 103
          THEN 'SESSION REC'
          WHEN 104
          THEN 'SYSTEM AUDIT'
          WHEN 105
          THEN 'SYSTEM NOAUDIT'
          WHEN 106
          THEN 'AUDIT DEFAULT'
          WHEN 107
          THEN 'NOAUDIT DEFAULT'
          WHEN 108
          THEN 'SYSTEM GRANT'
          WHEN 109
          THEN 'SYSTEM REVOKE'
          WHEN 110
          THEN 'CREATE PUBLIC SYNONYM'
          WHEN 111
          THEN 'DROP PUBLIC SYNONYM'
          WHEN 112
          THEN 'CREATE PUBLIC DATABASE LINK'
          WHEN 113
          THEN 'DROP PUBLIC DATABASE LINK'
          WHEN 114
          THEN 'GRANT ROLE'
          WHEN 115
          THEN 'REVOKE ROLE'
          WHEN 116
          THEN 'EXECUTE PROCEDURE'
          WHEN 117
          THEN 'USER COMMENT'
          WHEN 118
          THEN 'ENABLE TRIGGER'
          WHEN 119
          THEN 'DISABLE TRIGGER'
          WHEN 120
          THEN 'ENABLE ALL TRIGGERS'
          WHEN 121
          THEN 'DISABLE ALL TRIGGERS'
          WHEN 122
          THEN 'NETWORK ERROR'
          WHEN 123
          THEN 'EXECUTE TYPE'
          WHEN 128
          THEN 'FLASHBACK'
          WHEN 129
          THEN 'CREATE SESSION'
          WHEN 130
          THEN 'ALTER MINING MODEL'
          WHEN 131
          THEN 'SELECT MINING MODEL'
          WHEN 133
          THEN 'CREATE MINING MODEL'
          WHEN 134
          THEN 'ALTER PUBLIC SYNONYM'
          WHEN 135
          THEN 'DIRECTORY EXECUTE'
          WHEN 136
          THEN 'SQL*LOADER DIRECT PATH LOAD'
          WHEN 137
          THEN 'DATAPUMP DIRECT PATH UNLOAD'
          WHEN 157
          THEN 'CREATE DIRECTORY'
          WHEN 158
          THEN 'DROP DIRECTORY'
          WHEN 159
          THEN 'CREATE LIBRARY'
          WHEN 160
          THEN 'CREATE JAVA'
          WHEN 161
          THEN 'ALTER JAVA'
          WHEN 162
          THEN 'DROP JAVA'
          WHEN 163
          THEN 'CREATE OPERATOR'
          WHEN 164
          THEN 'CREATE INDEXTYPE'
          WHEN 165
          THEN 'DROP INDEXTYPE'
          WHEN 166
          THEN 'ALTER INDEXTYPE'
          WHEN 167
          THEN 'DROP OPERATOR'
          WHEN 168
          THEN 'ASSOCIATE STATISTICS'
          WHEN 169
          THEN 'DISASSOCIATE STATISTICS'
          WHEN 170
          THEN 'CALL METHOD'
          WHEN 171
          THEN 'CREATE SUMMARY'
          WHEN 172
          THEN 'ALTER SUMMARY'
          WHEN 173
          THEN 'DROP SUMMARY'
          WHEN 174
          THEN 'CREATE DIMENSION'
          WHEN 175
          THEN 'ALTER DIMENSION'
          WHEN 176
          THEN 'DROP DIMENSION'
          WHEN 177
          THEN 'CREATE CONTEXT'
          WHEN 178
          THEN 'DROP CONTEXT'
          WHEN 179
          THEN 'ALTER OUTLINE'
          WHEN 180
          THEN 'CREATE OUTLINE'
          WHEN 181
          THEN 'DROP OUTLINE'
          WHEN 182
          THEN 'UPDATE INDEXES'
          WHEN 183
          THEN 'ALTER OPERATOR'
          WHEN 192
          THEN 'ALTER SYNONYM'
          WHEN 197
          THEN 'PURGE USER_RECYCLEBIN'
          WHEN 198
          THEN 'PURGE DBA_RECYCLEBIN'
          WHEN 199
          THEN 'PURGE TABLESPACE'
          WHEN 200
          THEN 'PURGE TABLE'
          WHEN 201
          THEN 'PURGE INDEX'
          WHEN 202
          THEN 'UNDROP OBJECT'
          WHEN 204
          THEN 'FLASHBACK DATABASE'
          WHEN 205
          THEN 'FLASHBACK TABLE'
          WHEN 206
          THEN 'CREATE RESTORE POINT'
          WHEN 207
          THEN 'DROP RESTORE POINT'
          WHEN 208
          THEN 'PROXY AUTHENTICATION ONLY'
          WHEN 209
          THEN 'DECLARE REWRITE EQUIVALENCE'
          WHEN 210
          THEN 'ALTER REWRITE EQUIVALENCE'
          WHEN 211
          THEN 'DROP REWRITE EQUIVALENCE'
          WHEN 212
          THEN 'CREATE EDITION'
          WHEN 213
          THEN 'ALTER EDITION'
          WHEN 214
          THEN 'DROP EDITION'
          WHEN 215
          THEN 'DROP ASSEMBLY'
          WHEN 216
          THEN 'CREATE ASSEMBLY'
          WHEN 217
          THEN 'ALTER ASSEMBLY'
          WHEN 218
          THEN 'CREATE FLASHBACK ARCHIVE'
          WHEN 219
          THEN 'ALTER FLASHBACK ARCHIVE'
          WHEN 220
          THEN 'DROP FLASHBACK ARCHIVE'
          WHEN 225
          THEN 'ALTER DATABASE LINK'
          WHEN 305
          THEN 'ALTER PUBLIC DATABASE LINK'
          ELSE 'UNKNOWN'
        END sql_opname,
        en.event_id
      FROM gv$session s,
        V$TRANSACTION t,
        V$SQL sq,
        V$ACTIVE_SERVICES serv,
        v$event_name en
      WHERE ((s.status  ='ACTIVE'
      AND s.state      != 'WAITING')
      OR (s.status      = 'ACTIVE'
      AND s.state       = 'WAITING'
      AND s.wait_class != 'Idle'))
        --and s.module<>'BASH collector'
      AND s.sid            <>g_own_sid
      AND t.ses_addr(+)     = s.saddr
      AND sq.sql_id(+)      =s.sql_id
      AND sq.child_number(+)=s.sql_child_number
      AND serv.name(+)      =s.service_name
      AND en.EVENT#(+)      =s.EVENT#
    ) ;
    IF s_logging=1 then log('Done sampling '|| SQL%RowCount ||' rows at '||TO_CHAR(l_sample_time)||' Sample_id: '|| TO_CHAR(l_sample_id)); end if;
  COMMIT;
END;

PROCEDURE do_FLUSH_PERSISTANT
IS
  l_currval NUMBER;
BEGIN
  log('Flushing persistant entries');
  select bash_seq.currval into l_currval from dual;
  INSERT
  INTO bash.bash$session_hist_INTERNAL
    (SELECT *
      FROM bash.bash$session_internal
      WHERE mod(SAMPLE_id,s_persist_every)=0
      AND sample_id                     >g_last_snapshot_persisted
    );
  g_last_snapshot_persisted:=l_currval;
   IF s_logging=1 then log('Done flushing '|| SQL%RowCount ||' persistant entries'); end if;
  COMMIT;
  read_setting;  
END;


PROCEDURE do_cleanup
IS
  l_count        NUMBER;
  l_entries_kept NUMBER;
BEGIN
  log('Doing cleanup');
  l_entries_kept:=s_max_entries_kept;
  SELECT COUNT(*) INTO l_count FROM bash.bash$session_INTERNAL;
  log(l_count||' entries in bash$session_internal before delete - Keep count is '||l_entries_kept);
  l_count  :=l_count-l_entries_kept;
  IF l_count>0 THEN
    DELETE
    FROM bash.bash$session_internal
    WHERE sample_id IN
      (SELECT        *
      FROM
        (SELECT sample_id FROM bash.bash$session_internal ORDER BY sample_id
        )
      WHERE rownum<=l_count
      );
    COMMIT;
  END IF;
  SELECT COUNT(*) INTO l_count FROM bash.bash$session_internal;
  log(l_count||' entries in bash$session_internal after delete - Keep count is '||l_entries_kept);
  log('Done Cleanup');
END;


PROCEDURE purge (days_to_keep NUMBER)
IS
  l_del_sample_time TIMESTAMP(3);
BEGIN
  l_del_sample_time:=systimestamp-days_to_keep;
  log('Purging entries from Session History table older than '||l_del_sample_time);
  DELETE FROM BASH.BASH$SESSION_HIST_INTERNAL WHERE SAMPLE_TIME<l_del_sample_time;
  COMMIT;
END;


PROCEDURE STOP
IS
BEGIN
  BEGIN
    DBMS_SCHEDULER.disable (name => 'BASH_COLLECTOR_SCHEDULER_JOB');
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -27476 THEN -- Job doesn't exist
      dbms_scheduler.create_job( job_name=>'BASH_COLLECTOR_SCHEDULER_JOB', job_type=>'PLSQL_BLOCK', job_action => 'BASH.runner();', repeat_interval => 'FREQ=MINUTELY', enabled=>FALSE, comments=>'Starts the endless collector package procedure BASH.BASH.RUNNER that samples V$SESSION');
      COMMIT;
    END IF;
  END;
  BEGIN
    DBMS_SCHEDULER.stop_job(job_name => 'BASH_COLLECTOR_SCHEDULER_JOB');
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  BEGIN
    DBMS_SCHEDULER.disable (name => 'BASH_COLLECTOR_SCHEDULER_JOB');
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
END;


PROCEDURE run
IS
BEGIN
  STOP;
  DBMS_SCHEDULER.enable (name => 'BASH_COLLECTOR_SCHEDULER_JOB');
END;


PROCEDURE runner
IS
  l_start_time NUMBER;
  l_this_time  NUMBER;
  l_counter    NUMBER;
  l_result     INTEGER;
  l_sleep_time NUMBER;
BEGIN
  BEGIN
    read_setting;
    dbms_application_info.set_module('BASH collector','');
    l_result   :=DBMS_LOCK.REQUEST(C_LOCK_ID_COLLECTOR,DBMS_LOCK.X_MODE,0);
    IF l_result<>0 THEN
      raise_application_error( -20900, 'Could not start BASH collection, since it is already running in another session.' );
    END IF;
    l_counter:=0;
	select bash_seq.nextval-1 into g_last_snapshot_persisted from dual;
    g_last_snapshot_flushed  :=g_last_snapshot_persisted;
    SELECT sys_context('USERENV','SID') INTO g_own_sid FROM dual;
    l_start_time:=dbms_utility.get_time();
    LOOP
      collector;
      IF mod(l_counter,s_persist_every)=s_persist_every-1 THEN
        do_FLUSH_PERSISTANT;
      END IF;
      IF mod(l_counter,s_cleanup_every)=s_cleanup_every-1 THEN
        do_CLEANUP;
      END IF;
      l_counter     :=l_counter+1;
      l_this_time   :=dbms_utility.get_time();
      l_sleep_time  :=(s_sample_every-(l_this_time-l_start_time -((l_counter)*s_sample_every)))/100;
      IF l_sleep_time>0 THEN
        dbms_lock.sleep(l_sleep_time);
      END IF;
    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    log('Exception in runner...');
    log( SQLERRM );
    log( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    l_result :=DBMS_LOCK.RELEASE(C_LOCK_ID_COLLECTOR);
    RAISE;
  END;
  l_result :=DBMS_LOCK.RELEASE(C_LOCK_ID_COLLECTOR);
END;
END BASH;
/

prompt
prompt
prompt ... Installing public synonyms

CREATE OR REPLACE PUBLIC SYNONYM "BASH$LOG" FOR "BASH"."BASH$LOG_INTERNAL";
CREATE OR REPLACE PUBLIC SYNONYM "BASH$ACTIVE_SESSION_HISTORY" FOR "BASH"."VTABSESSIONS";
CREATE OR REPLACE PUBLIC SYNONYM "BASH$HIST_ACTIVE_SESS_HISTORY" FOR "BASH"."VTABSESSIONSHIST";


prompt
prompt Would you like to start the BASH data collector? Enter N if you don't want to start it now.
prompt


set heading off

col start_bash_collector new_value start_bash_collector noprint
select 'Starting BASH collector: '||
       decode(upper(nvl('&&start_bash_collector','Y')),'N','No','Yes')
     , upper(nvl('&&start_bash_collector','Y')) start_bash_collector
	 from dual;
set heading on


BEGIN
  IF '&start_bash_collector' <> 'N' THEN
    BASH.BASH.RUN;
  END IF;
END;
/


prompt
prompt
prompt *** Successfully installed BASH. ****
prompt
prompt

exit
