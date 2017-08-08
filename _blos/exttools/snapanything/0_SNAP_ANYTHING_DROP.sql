--
-- Drop script for the SNAP_ANYTHING schema and its objects.
--
-- Run this script as user sys to remove all objects in the SNAP_ANYTHING and drop the SNAP_ANYTHING schema.
--
-- Version:     1.0
-- Author:      Marcus Mönnig
-- Copyright:   Marcus Mönnig - All rights reserved.
--



BEGIN
  DBMS_SCHEDULER.DROP_JOB(job_name => 'SNAP_ANYTHING.Snap_Anything_snapper_job');
END;
/
 

DROP TABLE SNAP_ANYTHING.HIST_QUERIES;
DROP TABLE SNAP_ANYTHING.HIST_QUERIES_LOG;
DROP PACKAGE BODY SNAP_ANYTHING.PKG_HIST_QUERIES;
DROP PACKAGE SNAP_ANYTHING.PKG_HIST_QUERIES;

DROP USER SNAP_ANYTHING;