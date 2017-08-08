SET ECHO ON TERM OFF SERVEROUT ON SIZE 1000000 NUMF "" SQLP SQL>;
WHENEVER SQLERROR CONTINUE;
SPO trcadictexp.log;
REM $Header: 224270.1 trcadictexp.sql 11.4.4.5 2012/11/21 carlos.sierra $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   trcadictexp.sql
REM
REM DESCRIPTION
REM   This script must be executed connected as SYS. It exports into
REM   plain text files some pieces of the data dictionary to be used
REM   later by the Trace Analyzer on a given EVENT 10046 Trace file.
REM
REM PRE-REQUISITES
REM   1. None.
REM
REM PARAMETERS
REM   1. None.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as SYS.
REM   2. Execute script trcadictexp.sql.
REM   3. Provide zip file to the requestor.
REM
REM EXAMPLES
REM   # sqlplus /nolog
REM   SQL> connect / as sysdba
REM   SQL> start trcadictexp.sql
REM
REM NOTES
REM   1. Must be executed connected as SYS.
REM   2. Do not make changes to this script.
REM   3. For possible errors see trcadictexp.log generated under
REM      the SQL*Plus default directory.
REM
SET TERM OFF ECHO OFF DEF ON FEED OFF FLU OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 SHOW OFF SQLC MIX TAB OFF TRIMS ON VER OFF TIM OFF ARRAY 100 SQLP SQL> BLO . RECSEP OFF SERVEROUT ON SIZE 1000000 FOR TRU;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
BEGIN
  IF USER <> 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20100, 'Execute this script trcadictexp.sql connected as SYS, not as '||USER);
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO
PRO exporting data dictionary...
PRO
PRO 01 of 11: control file
SET TERM OFF;
SPO TRCA_CONTROL.txt;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD')||','||
       d.dbid||','||
       d.name||','||
       i.instance_number||','||
       i.instance_name||','||
       i.host_name||','||
       TRIM(REPLACE(REPLACE(v.product, 'TNS for '), ':' ))||','||
       i.version||','||
       p.value external_table_row
  FROM v$database d, v$instance i, product_component_version v, v$parameter2 p
 WHERE v.product LIKE 'TNS for%'
   AND p.name = 'db_files'
   AND ROWNUM = 1;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 02 of 11: sys.file$
SET TERM OFF;
SPO TRCA_FILE.txt;
SELECT file#||','||
       ts#||','||
       relfile# external_table_row
   FROM sys.file$
  WHERE file# IS NOT NULL;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 03 of 11: sys.uet$ dictionary managed extents (subset)
SET TERM OFF;
SPO TRCA_EXTENTS_DM.txt;
SELECT segfile#||','||
       segblock#||','||
       ts#||','||
       file#||','||
       block#||','||
       length external_table_row
  FROM sys.uet$
 WHERE block# IS NOT NULL
   AND length IS NOT NULL;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 04 of 11: sys.x$ktfbue locally managed extents (subset)
SET TERM OFF;
SPO TRCA_EXTENTS_LM.txt;
SELECT ktfbuesegfno||','||
       ktfbuesegbno||','||
       ktfbuesegtsn||','||
       ktfbuefno||','||
       ktfbuebno||','||
       ktfbueblks external_table_row
  FROM sys.x$ktfbue
 WHERE ktfbuebno IS NOT NULL
   AND ktfbueblks IS NOT NULL;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 05 of 11: dba_segments (subset)
SET TERM OFF;
SPO TRCA_SEGMENTS.txt;
SELECT o.owner#||','||
       NVL(u.name, 'SYS')||','||
       o.name||','||
       o.subname||','||
       so.object_type||','||
       s.ts#||','||
       s.block#||','||
       s.file#||','||
       bitand(NVL(s.spare1,0), 1) external_table_row
  FROM sys.seg$        s,
       sys.sys_objects so,
       sys.obj$        o,
       sys.user$       u
 WHERE bitand(NVL(s.spare1,0), 65536) = 0
   AND s.file#           = so.header_file
   AND s.block#          = so.header_block
   AND s.ts#             = so.ts_number
   AND s.type#           = so.segment_type_id
   AND s.ts#             = so.ts_number
   AND so.object_id      = o.obj#
   AND so.object_type_id = o.type#
   AND o.owner#          = u.user#(+);
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 06 of 11: dba_tables
SET TERM OFF;
SPO TRCA_TABLES.txt;
SELECT owner||','||
       table_name||','||
       num_rows||','||
       blocks||','||
       empty_blocks||','||
       avg_space||','||
       chain_cnt||','||
       avg_row_len||','||
       sample_size||','||
       TO_CHAR(last_analyzed, 'YYYYMMDDHH24MISS')||','||
       partitioned||','||
       temporary||','||
       global_stats external_table_row
  FROM dba_tables;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 07 of 11: dba_indexes
SET TERM OFF;
SPO TRCA_INDEXES.txt;
SELECT owner||','||
       index_name||','||
       index_type||','||
       table_owner||','||
       table_name||','||
       uniqueness||','||
       blevel||','||
       leaf_blocks||','||
       distinct_keys||','||
       avg_leaf_blocks_per_key||','||
       avg_data_blocks_per_key||','||
       clustering_factor||','||
       num_rows||','||
       sample_size||','||
       TO_CHAR(last_analyzed, 'YYYYMMDDHH24MISS')||','||
       partitioned||','||
       temporary||','||
       global_stats external_table_row
  FROM dba_indexes;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 08 of 11: dba_tab_cols (only indexed columns)
SET TERM OFF;
SPO TRCA_TAB_COLS.txt;
SELECT tcl.owner||','||
       tcl.table_name||','||
       tcl.column_name||','||
       tcl.column_id||','||
       tcl.num_distinct||','||
       tcl.density||','||
       tcl.num_nulls||','||
       tcl.num_buckets||','||
       TO_CHAR(tcl.last_analyzed, 'YYYYMMDDHH24MISS')||','||
       tcl.sample_size external_table_row
  FROM dba_tab_cols tcl,
       (SELECT DISTINCT table_owner, table_name, column_name
          FROM dba_ind_columns) icl
 WHERE icl.table_owner = tcl.owner
   AND icl.table_name  = tcl.table_name
   AND icl.column_name = tcl.column_name;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 09 of 11: dba_ind_columns
SET TERM OFF;
SPO TRCA_IND_COLUMNS.txt;
SELECT index_owner||','||
       index_name||','||
       table_owner||','||
       table_name||','||
       column_name||','||
       column_position||','||
       descend external_table_row
  FROM dba_ind_columns
 WHERE LENGTH(column_name) <= 30;
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 10 of 11: dba_objects (subset)
SET TERM OFF;
SPO TRCA_OBJECTS.txt;
SELECT object_id||','||
       object_type||','||
       owner||','||
       object_name||','||
       subobject_name external_table_row
  FROM dba_objects
 WHERE object_type LIKE 'TABLE%'
    OR object_type LIKE 'INDEX%'
    OR object_type = 'MATERIALIZED VIEW'
    OR object_type = 'CLUSTER';
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO 11 of 11: v$parameter2 (subset)
SET TERM OFF;
SPO TRCA_PARAMETER2.txt;
SELECT name||','||
       REPLACE(value, ',', '^') external_table_row
  FROM v$parameter2
 WHERE isdefault = 'FALSE';
SPO OFF;

/* ------------------------------------------------------------------------- */

SET TERM ON;
PRO generating zip file...
HO zip -mT TRCA_DICT TRCA_*.txt trcadictexp.log
PRO TRCA_DICT.zip has been generated
PRO
PRO trcadictexp.sql completed.
