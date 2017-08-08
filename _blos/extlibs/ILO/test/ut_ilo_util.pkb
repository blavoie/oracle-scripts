CREATE OR REPLACE PACKAGE BODY Ut_ILO_util
IS
---------------------------------------------------------------------
--
--  Instrumentation Library for Oracle
--  Copyright (C) 2006 - 2008  Method R Corporation. All rights reserved.
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2.1 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public
--  License along with this library; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--
---------------------------------------------------------------------
---------------------------------------------------------------------
--< PRIVATE TYPES AND GLOBALS >--------------------------------------
---------------------------------------------------------------------
 -- Package Results Variable.
   package_results   BOOLEAN                     := TRUE;

---------------------------------------------------------------------
--< PRIVATE METHODS >------------------------------------------------
---------------------------------------------------------------------

---------------------------------------------------------------------
--< print_result >---------------------------------------------------
---------------------------------------------------------------------
   PROCEDURE print_result (test_name IN VARCHAR2, RESULT BOOLEAN)
   IS
     c_maxlen number := 70;
   BEGIN
      package_results := package_results AND result;
      IF (RESULT)
      THEN
         DBMS_OUTPUT.PUT_LINE (   '   * '
                               || test_name
                               || LPAD ('> SUCCESS',
                                        greatest(10,c_maxlen - LENGTH (test_name)),
                                        '-'
                                       )
                              );
      ELSE
         DBMS_OUTPUT.PUT_LINE (   '   * '
                               || test_name
                               || LPAD ('> FAILURE',
                                        greatest(10,c_maxlen - LENGTH (test_name)),
                                        '-'
                                       )
                              );
      END IF;
   END print_result;

---------------------------------------------------------------------
--< bool2char >-===--------------------------------------------------
---------------------------------------------------------------------
   FUNCTION bool2char (b IN BOOLEAN) RETURN VARCHAR2
   IS
   BEGIN
      IF (b is null) THEN
         return 'NULL';
      ELSIF (b) THEN
         return 'TRUE';
      ELSE
         return 'FALSE';
      END IF;
   END bool2char;


---------------------------------------------------------------------
--< PUBLIC METHODS  >------------------------------------------------
---------------------------------------------------------------------

---------------------------------------------------------------------
--< run_tests >------------------------------------------------------
---------------------------------------------------------------------
   FUNCTION run_tests
      RETURN BOOLEAN
   IS
     procedure debug (p_txt in varchar2) is
       debug_on BOOLEAN := FALSE;
     begin
       if debug_on then
         DBMS_OUTPUT.PUT_LINE(p_txt);
       end if;
     end debug;
   BEGIN

      PACKAGE_RESULTS := TRUE;
      debug('-- BEGIN ut_ilo_util');

      dbms_output.put_line(rpad('=',60,'='));
      dbms_output.put_line('ilo_util Unit tests for version '||ilo_util.get_version);
      dbms_output.put_line(rpad('=',60,'='));

      /* Process the test Procedures */

      debug('++ BEGIN ilo_util.get_raise_exceptions');
      print_result('Check Defaults: get_raise_exceptions - '||bool2char(ilo_util.get_raise_exceptions), 
                   ilo_util.get_raise_exceptions = false);

      debug('++ BEGIN ilo_util.set_raise_exceptions(true)');
      ilo_util.set_raise_exceptions(true);
      print_result('Check True: get_raise_exceptions - '||bool2char(ilo_util.get_raise_exceptions), 
                   ilo_util.get_raise_exceptions = true);

      begin
        debug('++ BEGIN Check Exceptions Being Raised');
        execute immediate 'begin ilo_util.set_raise_exceptions(''not a boolean''); end;';
        print_result('Exception not raised correctly', false);
      exception
        when others then
          debug(sqlerrm);
          print_result('Exception raised as expected: '||sqlcode,true);
      end;

      -- Leave the raise_exceptions set to TRUE for aid in testing other packages !!!

      /* End of Test Procedure List */

      -- Print the overall result of the procedure
      print_result('Package Results ', package_results);

      dbms_output.put_line(rpad('=',60,'='));
      if package_results then
        dbms_output.put_line('ilo_util Unit tests completed successfully.');
      else
        dbms_output.put_line('ilo_util Unit tests completed with failures.');
      end if;
      dbms_output.put_line(rpad('=',60,'='));
      debug('-- END ut_ilo_util');

      RETURN (package_results);
   END;
END Ut_ILO_util;
/
