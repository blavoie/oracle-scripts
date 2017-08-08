CREATE OR REPLACE PACKAGE BODY Ut_Ilo_Timer
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
--< PUBLIC METHODS  >------------------------------------------------
---------------------------------------------------------------------

   ---------------------------------------------------------------------
--< run_tests >------------------------------------------------
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
      debug('-- BEGIN ut_Ilo_timer');

      dbms_output.put_line(rpad('=',60,'='));
      dbms_output.put_line('Ilo_TIMER Unit tests for version '||Ilo_timer.get_version);
      dbms_output.put_line(rpad('=',60,'='));

      /* Process the test Procedures */

      /* End of Test Procedure List */

      -- Print the overall result of the procedure
      print_result('Package Results ', package_results);

      dbms_output.put_line(rpad('=',60,'='));
      if package_results then
        dbms_output.put_line('Ilo_TIMER Unit tests completed successfully.');
      else
        dbms_output.put_line('Ilo_TIMER Unit tests completed with failures.');
      end if;
      dbms_output.put_line(rpad('=',60,'='));

      debug('-- END ut_Ilo_timer');

      RETURN (package_results);
   END;
END Ut_Ilo_Timer;
/
