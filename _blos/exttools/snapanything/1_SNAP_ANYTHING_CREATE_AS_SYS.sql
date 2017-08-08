--
-- Install script for the SNAP_ANYTHING schema and its objects.
--
-- Run this script as user sys after making the modifications that you see fit 
--
-- Things you might want to rethink and change: Password, "SELECT ANY TABLE" and "SELECT ANY DICTIONARY" Privileges
-- 
-- Version:     1.0
-- Author:      Marcus Mönnig
-- Copyright:   Marcus Mönnig - All rights reserved.
--


CREATE USER SNAP_ANYTHING IDENTIFIED BY SNAP_ANYTHING;

-- Minimum privileges:

GRANT CONNECT, RESOURCE TO SNAP_ANYTHING;
GRANT EXECUTE ON SYS.JOB_CLASS_NO_LOGGING TO SNAP_ANYTHING;
GRANT CREATE TABLE TO SNAP_ANYTHING; 


-- The user SNAP_ANYTHING needs select privileges on objects that are snapped
-- The two grants below should cover most of what you might want to snap, but 
-- is not really secure. You might want to remove these two grants and only grant 
-- what is actually snapped.

GRANT SELECT ANY TABLE TO SNAP_ANYTHING; 
GRANT SELECT ANY DICTIONARY TO SNAP_ANYTHING; 


CREATE TABLE SNAP_ANYTHING.HIST_QUERIES
  (
     ENABLED         CHAR(1) CHECK (ENABLED IN ( 'Y', 'N' )),
     NAME            VARCHAR2(200) NOT NULL,
     QUERY_TEXT      VARCHAR2(2000) NOT NULL,
     TARGET_TABLE    VARCHAR2(200) NOT NULL,
	 RETENTION_MINUTES NUMBER DEFAULT 10080 NOT NULL ENABLE, 
     NEXT_SNAP_TIME  DATE DEFAULT SYSDATE NOT NULL,
     REPEAT_INTERVAL VARCHAR2(2000) NOT NULL,
     CONSTRAINT PK_HIST_QUERIES PRIMARY KEY (NAME)
  ); 
/

CREATE TABLE SNAP_ANYTHING.HIST_QUERIES_LOG
  (
     SNAP_TIME DATE DEFAULT SYSDATE NOT NULL,
     NAME      VARCHAR2(200) NOT NULL,
     LOG_TEXT  VARCHAR2(2000)
  );
/

CREATE OR REPLACE PACKAGE SNAP_ANYTHING."PKG_HIST_QUERIES"
AS
  PROCEDURE SNAP;
  PROCEDURE PURGE;
END PKG_HIST_QUERIES;
/

CREATE OR REPLACE PACKAGE BODY SNAP_ANYTHING."PKG_HIST_QUERIES"
AS
  PROCEDURE SNAP
  AS
    QUERY       VARCHAR2(4000);
    L_DATE      DATE;
    V_NEXT_DATE DATE;
    CURSOR QUERIES IS
      SELECT *
      FROM   HIST_QUERIES
      WHERE  ENABLED = 'Y'
             AND NEXT_SNAP_TIME <= l_date;
    L_MESSAGE   VARCHAR2(2000);
  BEGIN
      l_date := SYSDATE;

      l_message := 'OK';

      FOR QUERIESREC IN QUERIES LOOP
          EXECUTE IMMEDIATE 'select '|| QUERIESREC.REPEAT_INTERVAL||' from dual' INTO v_next_date;

          query := 'SELECT 1 from '
                   || QueriesRec.TARGET_TABLE;

          BEGIN
              EXECUTE IMMEDIATE QUERY;
          EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE = -942 THEN
                  query := 'CREATE TABLE '
                           || QueriesRec.TARGET_TABLE
                           || ' as SELECT SYSDATE SNAP_TIME,10 ORDER_ID, sub.* from ('
                           || QueriesRec.QUERY_TEXT
                           || ') sub where 1=2';

                  EXECUTE IMMEDIATE QUERY;
                ELSE
                  RAISE;
                END IF;
          END;

          BEGIN
              query := 'INSERT INTO '
                       || QueriesRec.TARGET_TABLE
                       || ' SELECT SYSDATE, rownum, sub.* from ('
                       || QueriesRec.QUERY_TEXT
                       || ') sub';

              EXECUTE IMMEDIATE QUERY;
          EXCEPTION
              WHEN OTHERS THEN
                l_message := 'SNAP Failed: '
                             || SQLERRM;
          END;

          INSERT INTO HIST_QUERIES_LOG
                      (SNAP_TIME,
                       NAME,
                       LOG_TEXT)
          VALUES      (l_date,
                       QueriesRec.NAME,
                       l_message);

          UPDATE HIST_QUERIES
          SET    NEXT_SNAP_TIME = v_next_date
          WHERE  name = QueriesRec.NAME;

          COMMIT;
      END LOOP;

      PURGE;
  END;
  PROCEDURE PURGE
  AS
    L_DATE    DATE;
    QUERY     VARCHAR2(4000);
    CURSOR QUERIES IS
      SELECT *
      FROM   HIST_QUERIES
      WHERE  ENABLED = 'Y';
    L_MESSAGE VARCHAR2(2000);
  BEGIN
      l_date := SYSDATE;

      FOR QUERIESREC IN QUERIES LOOP
          BEGIN
              query := 'DELETE FROM '
                       || QueriesRec.TARGET_TABLE
                       || ' WHERE SNAP_TIME < sysdate - ('
                       || QueriesRec.RETENTION_MINUTES
                       || '/60/24) ';

              EXECUTE IMMEDIATE QUERY;
          EXCEPTION
              WHEN OTHERS THEN
                l_message := 'PURGE Failed for '
                             || QueriesRec.TARGET_TABLE
                             ||': '
                             || SQLERRM;

                INSERT INTO HIST_QUERIES_LOG
                            (SNAP_TIME,
                             NAME,
                             LOG_TEXT)
                VALUES      (l_date,
                             QueriesRec.NAME,
                             l_message);

                COMMIT;
          END;
      END LOOP;

      --clear the log table with a fixed retention of 10 days
      DELETE FROM HIST_QUERIES_LOG
      WHERE  snap_time < SYSDATE - 10;

      COMMIT;
  END;
END PKG_HIST_QUERIES;
/



BEGIN
    DBMS_SCHEDULER.CREATE_JOB (job_name => 'SNAP_ANYTHING.Snap_Anything_snapper_job', job_type => 'PLSQL_BLOCK', job_action => 'BEGIN SNAP_ANYTHING.PKG_HIST_QUERIES.SNAP; END;', number_of_arguments => 0, start_date => systimestamp, repeat_interval => 'FREQ=MINUTELY;INTERVAL=1', end_date => NULL, job_class => '"DEFAULT_JOB_CLASS"', enabled => FALSE, auto_drop => FALSE, comments => 'Jobs that runs every minute and triggers the snapping as set up in SNAP_ANYTHING.HIST_QUERIES.');
    DBMS_SCHEDULER.SET_ATTRIBUTE ('SNAP_ANYTHING.Snap_Anything_snapper_job', 'logging_level', DBMS_SCHEDULER.LOGGING_OFF);
    -- We don't want DBA_SCHEDULER_JOB_LOG and DBA_SCHEDULER_JOB_RUN_DETAILS to fill up, so we disable logging for our job
    DBMS_SCHEDULER.SET_ATTRIBUTE (name => 'SNAP_ANYTHING.Snap_Anything_snapper_job', attribute => 'JOB_CLASS', value => 'JOB_CLASS_NO_LOGGING');
    DBMS_SCHEDULER.ENABLE (name => 'SNAP_ANYTHING.Snap_Anything_snapper_job');
    COMMIT;
END;
/ 
