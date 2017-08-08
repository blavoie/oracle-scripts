CREATE OR REPLACE PACKAGE &&tool_administer_schema..sqlt$c AUTHID DEFINER AS
/* $Header: 215187.1 sqcpkgc.pks 11.4.5.0 2012/11/21 carlos.sierra $ */

  /*************************************************************************************/

  /* -------------------------
   *
   * public apis
   *
   * ------------------------- */

  PROCEDURE compare_report (
    p_statement_id1    IN NUMBER,
    p_statement_id2    IN NUMBER,
    p_plan_hash_value1 IN NUMBER,
    p_plan_hash_value2 IN NUMBER );

  /*************************************************************************************/

END sqlt$c;
/

SET TERM ON;
SHOW ERRORS;
