CREATE OR REPLACE PACKAGE BODY Ut_ILO_Sysutil
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
--< ut_client_id_set_get >---------------------------------------
---------------------------------------------------------------------
   PROCEDURE ut_client_id_set_get
   IS
     v_id varchar2(2000);
   BEGIN
      -- get Default 
      v_id := ilo_sysutil.get_client_id;
      print_result('Check Defaults: get_client_id - '||v_id,TRUE);
      
      ilo_sysutil.set_client_id('UT_CLIENT_ID');
      print_result('Check After SET: get_client_id = UT_CLIENT_ID',ilo_sysutil.get_client_id = 'UT_CLIENT_ID');

      -- set it back
      ilo_sysutil.set_client_id(v_id);
     
      print_result('Check After RESET: get_client_id = '||v_id,ilo_sysutil.get_client_id = v_id);

   END ut_client_id_set_get;


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
      debug('-- BEGIN ut_ilo_sysutil');

      dbms_output.put_line(rpad('=',60,'='));
      dbms_output.put_line('ilo_sysutil Unit tests for version '||ilo_sysutil.get_version);
      dbms_output.put_line(rpad('=',60,'='));

      /* Process the test Procedures */
      debug('++ BEGIN ilo_sysutil.turn_trace_on');
      dbms_output.put_line('*** Turn tracing on ***');
      ilo_sysutil.turn_trace_on;

      debug('++ BEGIN ilo_sysutil.write_to_trace');
      dbms_output.put_line('*** Writing unit test message to trace file ***');
      ilo_sysutil.write_to_trace('*** Unit test ilo_sysutil.write_to_trace. Datestamp should follow.');

      debug('++ BEGIN ilo_sysutil.write_datestamp');
      dbms_output.put_line('*** Writing datestamp to trace file ***');
      ilo_sysutil.write_datestamp;

      debug('++ BEGIN ilo_sysutil.write_to_alert');
      dbms_output.put_line('*** Writing unit test message to alert log ***');
      ilo_sysutil.write_to_alert('*** Unit test ilo_sysutil.write_to_alert');

      for rec in (select 'UNIT TEST: THIS SHOULD BE IN TRACE FILE' from dual) loop null; end loop;

      debug('++ BEGIN ilo_sysutil.turn_trace_off');
      dbms_output.put_line('*** Turn tracing off ***');
      ilo_sysutil.turn_trace_off;
      
      for rec in (select 'UNIT TEST: THIS SHOULD NOT BE IN TRACE FILE' from dual) loop null; end loop;

      debug('++ BEGIN ilo_sysutil.get_db_major_ver');
      print_result('Check Defaults: get_db_major_ver - '||ilo_sysutil.get_db_major_ver, 
                   ilo_sysutil.get_db_major_ver is not null);

      debug('++ BEGIN ilo_sysutil.get_spid');
      print_result('Check Defaults: get_spid - '||ilo_sysutil.get_spid, 
                   ilo_sysutil.get_spid is not null);

      debug('++ BEGIN ilo_sysutil.get_session_type');
      print_result('Check Defaults: get_session_type - '||ilo_sysutil.get_session_type, 
                   ilo_sysutil.get_session_type is not null);

      debug('++ BEGIN ilo_sysutil.get_instance_name');
      print_result('Check Defaults: get_instance_name - '||ilo_sysutil.get_instance_name, 
                   ilo_sysutil.get_instance_name is not null);

      debug('++ BEGIN ilo_sysutil.get_service_name');
      print_result('Check Defaults: get_service_name - '||ilo_sysutil.get_service_name, 
                   ilo_sysutil.get_service_name is not null);

      debug('++ BEGIN ilo_sysutil.get_session_user');
      print_result('Check Defaults: get_session_user - '||ilo_sysutil.get_session_user, 
                   ilo_sysutil.get_session_user is not null);

      debug('++ BEGIN ilo_sysutil.get_ip_address');
      print_result('Check Defaults: get_ip_address - '||ilo_sysutil.get_ip_address, 
                   TRUE); -- not always set, just output the result

      debug('++ BEGIN ilo_sysutil.get_terminal');
      print_result('Check Defaults: get_terminal - '||ilo_sysutil.get_terminal, 
                   ilo_sysutil.get_terminal is not null);

      debug('++ BEGIN ilo_sysutil.get_session_id');
      print_result('Check Defaults: get_session_id - '||ilo_sysutil.get_session_id, 
                   ilo_sysutil.get_session_id is not null);

      debug('++ BEGIN ilo_sysutil.get_os_user');
      print_result('Check Defaults: get_os_user - '||ilo_sysutil.get_os_user, 
                   ilo_sysutil.get_os_user is not null);

      debug('++ BEGIN ilo_sysutil.get_session_id');
      print_result('Check Defaults: get_session_id - '||ilo_sysutil.get_session_id, 
                   ilo_sysutil.get_session_id is not null);

      debug('++ BEGIN ut_ilo_sysutil.ut_client_id_set_get');
      ut_client_id_set_get;

      /* End of Test Procedure List */

      -- Print the overall result of the procedure
      print_result('Package Results ', package_results);

      dbms_output.put_line(rpad('=',60,'='));
      if package_results then
        dbms_output.put_line('ilo_sysutil Unit tests completed successfully.');
      else
        dbms_output.put_line('ilo_sysutil Unit tests completed with failures.');
      end if;
      dbms_output.put_line(rpad('=',60,'='));
      debug('-- END ut_ilo_sysutil');

      RETURN (package_results);
   END;
END Ut_ILO_Sysutil;
/
