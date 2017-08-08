CREATE OR REPLACE PACKAGE &&tool_administer_schema..sqlt$h AUTHID DEFINER AS
/* $Header: 215187.1 sqcpkgh.pks 11.4.5.0 2012/11/21 carlos.sierra $ */

  /*************************************************************************************/

  /* -------------------------
   *
   * public apis
   *
   * ------------------------- */

  PROCEDURE health_check (p_statement_id IN NUMBER);

  /*************************************************************************************/

END sqlt$h;
/

SET TERM ON;
SHOW ERRORS;
