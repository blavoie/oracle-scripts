SET ECHO ON 
SET LINESIZE 500
SET SERVEROUTPUT ON

-- Cr�er la table
DECLARE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE t';
EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END;
/

CREATE TABLE t (x INT);

-- Proc�dure utilisant bind variables

CREATE OR REPLACE PROCEDURE proc1
AS
BEGIN
   FOR i IN 1 .. 10000
   LOOP
      EXECUTE IMMEDIATE 'insert into t values ( :x )' USING i;
   END LOOP;
END;
/

-- Proc�dure n'utilisant pas de bind variables

CREATE OR REPLACE PROCEDURE proc2
AS
BEGIN
   FOR i IN 1 .. 10000
   LOOP
      EXECUTE IMMEDIATE 'insert into t values ( ' || i || ')';
   END LOOP;
END;
/

-- Rouler le test
EXEC runstats_pkg.rs_start;
EXEC proc1;
EXEC runstats_pkg.rs_middle;
EXEC proc2;
EXEC runstats_pkg.rs_stop(10000);