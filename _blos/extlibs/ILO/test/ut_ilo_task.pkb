CREATE OR REPLACE PACKAGE BODY Ut_Ilo_Task
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
   -- Package Level Variables for use in comparison
   v_rec_base        Ilo_Task.stack_rec_t;
   v_rec_return      Ilo_Task.stack_rec_t;
   v_rec_empty       Ilo_Task.stack_rec_t;
   v_tab_base        Ilo_Task.stack_t    := Ilo_Task.stack_t
                                                                          ();
   v_tab_return      Ilo_Task.stack_t    := Ilo_Task.stack_t
                                                                          ();
   v_tab_empty       Ilo_Task.stack_t    := Ilo_Task.stack_t
                                                                          ();

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
--< test_stack_eq >--------------------------------------------------
---------------------------------------------------------------------
   FUNCTION test_stack_eq (
      stack1   Ilo_Task.stack_t,
      stack2   Ilo_Task.stack_t
   )
      RETURN BOOLEAN
   IS
      RESULT   BOOLEAN;
   BEGIN
      RESULT := TRUE;

      IF stack1.COUNT = stack2.COUNT
      THEN
         FOR i IN 1 .. stack1.COUNT
         LOOP
            IF NOT ((stack1 (i).SEQUENCE = stack2 (i).SEQUENCE)
                     OR (stack1 (i).SEQUENCE IS NULL AND stack2 (i).SEQUENCE IS NULL))
            THEN
               print_result('*   Sequences do not match: 1-'||stack1 (i).SEQUENCE||'  2-'||stack2 (i).SEQUENCE,FALSE);
               RESULT := RESULT AND FALSE;
            END IF;
            IF NOT ((stack1 (i).module = stack2 (i).module)
                     OR (stack1 (i).module IS NULL AND stack2 (i).module IS NULL))
            THEN
               print_result('*   Modules do not match: 1-'||stack1 (i).module||'  2-'||stack2 (i).module,FALSE);
               RESULT := RESULT AND FALSE;
            END IF;
            IF NOT ((stack1 (i).action = stack2 (i).action)
                     OR (stack1 (i).action IS NULL AND stack2 (i).action IS NULL))
            THEN
               print_result('*   Actions do not match: 1-'||stack1 (i).action||'  2-'||stack2 (i).action,FALSE);
               RESULT := RESULT AND FALSE;
            END IF;
            IF NOT ((stack1 (i).client_id = stack2 (i).client_id)
                     OR (stack1 (i).client_id IS NULL AND stack2 (i).client_id IS NULL))
            THEN
               print_result('*   Client_ids do not match: 1-'||stack1 (i).client_id||'  2-'||stack2 (i).client_id,FALSE);
               RESULT := RESULT AND FALSE;
            END IF;
            IF NOT ((stack1 (i).comment = stack2 (i).comment)
                     OR (stack1 (i).comment IS NULL AND stack2 (i).comment IS NULL))
            THEN
               print_result('*   Comments do not match: 1-'||stack1 (i).comment||'  2-'||stack2 (i).comment,FALSE);
               RESULT := RESULT AND FALSE;
            END IF;
         END LOOP;
      ELSE
         RESULT := RESULT AND FALSE;
      END IF;

      RETURN RESULT;
   END test_stack_eq;

---------------------------------------------------------------------
--< test_stack_rec_t_equal >-----------------------------------------
---------------------------------------------------------------------
   FUNCTION test_stack_rec_t_equal (
      rec1   Ilo_Task.stack_rec_t,
      rec2   Ilo_Task.stack_rec_t
   )
      RETURN BOOLEAN
   IS
      v_tab_1    Ilo_Task.stack_t := Ilo_Task.stack_t ();
      v_tab_2    Ilo_Task.stack_t := Ilo_Task.stack_t ();
   BEGIN
      v_tab_1.EXTEND;
      v_tab_1 (v_tab_1.LAST) := rec1;
      v_tab_2.EXTEND;
      v_tab_2 (v_tab_2.LAST) := rec2;
      RETURN test_stack_eq (v_tab_1, v_tab_2);
   END test_stack_rec_t_equal;

---------------------------------------------------------------------
--< ut_nesting_level_set_get >---------------------------------------
---------------------------------------------------------------------
-- since this is deprecated, test results should always return 0
--
   PROCEDURE ut_nesting_level_set_get
   IS
      v_nesting_level   NUMBER;
      v_random          NUMBER;
      
   BEGIN
      -- by Default the nesting level should be ZERO
      print_result('Check Defaults: get_nesting_level for 0', Ilo_Task.get_nesting_level = '0');
      
      -- Now set the nesting level to an arbitrary number between 1 and 10 and test
      -- First, get the random number as a whole number
      v_random := ROUND(dbms_random.VALUE * 10,0);
      
      -- Next set the Nesting level to that number
      Ilo_Task.set_nesting_level(v_random);
      
      print_result('Check After SET: get_nesting_level for '||to_char(v_random), Ilo_Task.get_nesting_level = '0');
     
     -- Set the nesting level back to Default.
     
     Ilo_Task.set_nesting_level(0);
     
   END ut_nesting_level_set_get;

---------------------------------------------------------------------
--< ut_is_apps_set_get >---------------------------------------
---------------------------------------------------------------------
   PROCEDURE ut_is_apps_set_get
   IS
   BEGIN
      -- by Default the is_apps should be FALSE
      print_result('Check Defaults: get_is_apps for FALSE', Ilo_Task.get_is_apps = FALSE);
      
      Ilo_Task.set_is_apps(TRUE);
      
      print_result('Check After SET: get_is_apps for TRUE', Ilo_Task.get_is_apps = TRUE);
     
     -- Set the is_apps back to Default.
     
    Ilo_Task.set_is_apps(FALSE);
     
   END ut_is_apps_set_get;

---------------------------------------------------------------------
--< ut_config_set_get >----------------------------------------------
---------------------------------------------------------------------
   PROCEDURE ut_config_set_get
   IS
      v_trace   BOOLEAN;
      v_wall    BOOLEAN;
   BEGIN
--
-- SINCE THIS IS DEPRECATED, TEST RESULTS SHOULD ALWAYS RETURN FALSE
--
      -- Execute test for DEFAULTS (FALSE, FALSE)
      -- Check get_TRACE for FALSE'

      print_result ('Check Defaults: get_trace for FALSE', Ilo_Task.get_trace = FALSE);
      -- Check get_write_wall_time for FALSE'
      print_result ('Check Defaults: get_write_wall_time for FALSE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check if GET_CONFIG returns TRACE = FALSE',v_trace = FALSE);
         print_result ('CHECK if GET_CONFIG returns WALL = FALSE',v_wall = FALSE);
      END IF;

      -- End of test

      -- Execute test for DEFAULTS (NULL, NULL) After having executed a (TRUE, TRUE)
      -- Assert success After the second SET_CONFIG, they should still be TRUE TRUE

      -- Set the initial values
      Ilo_Task.set_config (TRACE => TRUE, write_wall_time => TRUE);
      -- Set the initial values
      Ilo_Task.set_config (TRACE => NULL, write_wall_time => NULL);
      -- Assert Success
      print_result ('Check After SET: get_trace for TRUE',
                    Ilo_Task.get_trace = FALSE
                   );
      print_result ('Check After SET: get_write_wall_time for TRUE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      -- Assert Success
      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check After SET if GET_CONFIG returns TRACE = TRUE',
                       v_trace = FALSE
                      );
         print_result ('CHECK After SET if GET_CONFIG returns WALL = TRUE',
                       v_wall = FALSE
                      );
      END IF;

      -- End of test

      -- Execute test code (TRUE, FALSE)
      Ilo_Task.set_config (TRACE => TRUE, write_wall_time => FALSE);
      -- Assert success
      print_result ('Check After SET: get_trace for TRUE',
                    Ilo_Task.get_trace = FALSE
                   );
      print_result ('Check After SET: get_write_wall_time for FALSE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      -- Assert Success
      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check After SET if GET_CONFIG returns TRACE = TRUE',
                       v_trace = FALSE
                      );
         print_result ('CHECK After SET if GET_CONFIG returns WALL = FALSE',
                       v_wall = FALSE
                      );
      END IF;

      -- End of test

      -- Execute test code (TRUE, TRUE)
      Ilo_Task.set_config (TRACE => TRUE, write_wall_time => TRUE);
      -- Assert success
      print_result ('Check After SET: get_trace for TRUE',
                    Ilo_Task.get_trace = FALSE
                   );
      print_result ('Check After SET: get_write_wall_time for TRUE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      -- Assert Success
      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check After SET if GET_CONFIG returns TRACE = TRUE',
                       v_trace = FALSE
                      );
         print_result ('CHECK After SET if GET_CONFIG returns WALL = TRUE',
                       v_wall = FALSE
                      );
      END IF;

      -- END TEST

      -- Execute test code (FALSE, TRUE)
      Ilo_Task.set_config (TRACE => FALSE, write_wall_time => TRUE);
      -- Assert success
      print_result ('Check After SET: get_trace for FALSE',
                    Ilo_Task.get_trace = FALSE
                   );
      print_result ('Check After SET: get_write_wall_time for TRUE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      -- Assert Success
      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check After SET if GET_CONFIG returns TRACE = FALSE',
                       v_trace = FALSE
                      );
         print_result ('CHECK After SET if GET_CONFIG returns WALL = TRUE',
                       v_wall = FALSE
                      );
      END IF;

      -- End of test

      -- Execute test code (FALSE, FALSE)
      Ilo_Task.set_config (TRACE => FALSE, write_wall_time => FALSE);
      -- Assert success
      print_result ('Check After SET: get_trace for FALSE',
                    Ilo_Task.get_trace = FALSE
                   );
      print_result ('Check After SET: get_write_wall_time for FALSE',
                    Ilo_Task.get_write_wall_time = FALSE
                   );

      -- Assert Success
      IF (package_results)
      THEN
         -- SET BOOLEAN DEFAULTS
         v_trace := NULL;
         v_wall := NULL;
         -- Execute Test code
         Ilo_Task.get_config (v_trace, v_wall);
         -- Assert Success
         print_result ('Check After SET if GET_CONFIG returns TRACE = FALSE',
                       v_trace = FALSE
                      );
         print_result ('CHECK After SET if GET_CONFIG returns WALL = FALSE',
                       v_wall = FALSE
                      );
      END IF;
      -- End of test
   -- End of PROC
   END ut_config_set_get;

---------------------------------------------------------------------
--< ut_test_tasks >--------------------------------------------------
---------------------------------------------------------------------
   PROCEDURE ut_test_tasks
   IS
   BEGIN
      -- SETUP TABLE AND RECORD FOR COMPARISON
      v_rec_base.module := 'MODULE1';
      v_rec_base.action := 'ACTION1';
      v_rec_base.client_id := 'CLIENT1';
      v_rec_base.COMMENT := 'COMMENT1';
      v_tab_base.EXTEND;
      v_tab_base (v_tab_base.LAST) := v_rec_base;
      -- Now BEGIN THE TASK
      Ilo_Task.begin_task (module         => 'MODULE1',
                                  action         => 'ACTION1',
                                  client_id      => 'CLIENT1',
                                  COMMENT        => 'COMMENT1'
                                 );
      -- CHECK THE CURRENT TASK
      v_rec_return := Ilo_Task.get_current_task;
      -- Assert success
      print_result ('V_REC_BAS = V_REC_RETURN : Single Level',
                    Ut_Ilo_Task.test_stack_rec_t_equal (v_rec_base,v_rec_return) = TRUE);
      -- CHECK THE CURRENT STACK
      v_tab_return := Ilo_Task.get_task_stack;
      print_result ('V_TAB_BAS = V_TAB_RETURN : Single Level',
                    Ut_Ilo_Task.test_stack_eq (v_tab_base, v_tab_return) = TRUE);

      -- Add a new task and check again.
      IF (package_results)
      THEN
         -- Set up Base comparison
         v_rec_base.module := 'MODULE2';
         v_rec_base.action := 'ACTION2';
         v_rec_base.client_id := 'CLIENT2';
         v_rec_base.COMMENT := 'COMMENT2';
         v_tab_base.EXTEND;
         v_tab_base (v_tab_base.LAST) := v_rec_base;
         -- Execute the instrumentation
         Ilo_Task.begin_task (module         => 'MODULE2',
                                     action         => 'ACTION2',
                                     client_id      => 'CLIENT2',
                                     COMMENT        => 'COMMENT2'
                                    );
         -- CHECK THE CURRENT TASK
         v_rec_return := Ilo_Task.get_current_task;
         -- Assert success
         print_result ('V_REC_BAS = V_REC_RETURN : Two Levels',
                       Ut_Ilo_Task.test_stack_rec_t_equal (v_rec_base,v_rec_return) = TRUE);
         -- CHECK THE CURRENT STACK
         v_tab_return := Ilo_Task.get_task_stack;
         print_result ('V_TAB_BAS = V_TAB_RETURN : Two Levels',
                       Ut_Ilo_Task.test_stack_eq (v_tab_base, v_tab_return) = TRUE);
      END IF;

      -- Add a third task and check again.
      IF (package_results)
      THEN
         -- Set up Base comparison
         v_rec_base.module := 'MODULE3';
         v_rec_base.action := 'ACTION3';
         v_rec_base.client_id := 'CLIENT3';
         v_rec_base.COMMENT := 'COMMENT3';
         v_tab_base.EXTEND;
         v_tab_base (v_tab_base.LAST) := v_rec_base;
         -- Execute the instrumentation
         Ilo_Task.begin_task (module         => 'MODULE3',
                                     action         => 'ACTION3',
                                     client_id      => 'CLIENT3',
                                     COMMENT        => 'COMMENT3'
                                    );
         -- CHECK THE CURRENT TASK
         v_rec_return := Ilo_Task.get_current_task;
         -- Assert success
         print_result ('V_REC_BAS = V_REC_RETURN : Three Levels',
                       Ut_Ilo_Task.test_stack_rec_t_equal (v_rec_base,v_rec_return) = TRUE);
         -- CHECK THE CURRENT STACK
         v_tab_return := Ilo_Task.get_task_stack;
         print_result ('V_TAB_BAS = V_TAB_RETURN : Three Levels',
                       Ut_Ilo_Task.test_stack_eq (v_tab_base, v_tab_return) = TRUE);
      END IF;

      -- END a task and check again
      IF (package_results)
      THEN
         -- Set up Base comparison
         v_rec_base.module := 'MODULE2';
         v_rec_base.action := 'ACTION2';
         v_rec_base.client_id := 'CLIENT2';
         v_rec_base.COMMENT := 'COMMENT2';
         v_tab_base.TRIM;
         -- Execute the instrumentation
         Ilo_Task.end_task;
         -- CHECK THE CURRENT TASK
         v_rec_return := Ilo_Task.get_current_task;
         -- Assert success
         print_result ('V_REC_BAS = V_REC_RETURN : Two Levels After End',
                       Ut_Ilo_Task.test_stack_rec_t_equal (v_rec_base,v_rec_return) = TRUE);
         -- CHECK THE CURRENT STACK
         v_tab_return := Ilo_Task.get_task_stack;
         print_result ('V_TAB_BAS = V_TAB_RETURN : Two Levels After End',
                       Ut_Ilo_Task.test_stack_eq (v_tab_base, v_tab_return) = TRUE);
      END IF;

      -- END all tasks and check again
      IF (package_results)
      THEN
         -- Execute the instrumentation
         Ilo_Task.end_all_tasks;
         -- CHECK THE CURRENT TASK
         v_rec_return := Ilo_Task.get_current_task;
         -- Assert success
         print_result ('V_REC_EMPTY = V_REC_RETURN : AFTER END_ALL_TASKS',
                       Ut_Ilo_Task.test_stack_rec_t_equal (v_rec_empty,v_rec_return) = TRUE);
         -- CHECK THE CURRENT STACK
         v_tab_return := Ilo_Task.get_task_stack;
         print_result ('V_TAB_EMPTY = V_TAB_RETURN : AFTER END_ALL_TASKS',
                       Ut_Ilo_Task.test_stack_eq (v_tab_empty,v_tab_return) = TRUE);
      END IF;
   -- End of test
   END ut_test_tasks;

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
      debug('-- BEGIN ut_ilo_task');

      dbms_output.put_line(rpad('=',60,'='));
      dbms_output.put_line('Ilo_Task Unit tests for version '||Ilo_Task.get_version);
      dbms_output.put_line(rpad('=',60,'='));

      PACKAGE_RESULTS := TRUE;

      /* Process the test Procedures */
      debug('++ BEGIN ut_Ilo_Task.ut_nesting_level_set_get');
      ut_nesting_level_set_get;
      debug('++ BEGIN ut_Ilo_Task.ut_is_apps_set_get');
      ut_is_apps_set_get;
      debug('++ BEGIN ut_Ilo_Task.ut_config_set_get');
      ut_config_set_get;
      -- Turn on tracing for everything
      ilo_timer.set_mark_all_tasks_interesting(true);
      debug('++ BEGIN ut_Ilo_Task.ut_test_tasks');
      ut_test_tasks;

      /* End of Test Procedure List */

      -- Print the overall result of the procedure
      print_result('Package Results ', package_results);

      dbms_output.put_line(rpad('=',60,'='));
      if package_results then
        dbms_output.put_line('Ilo_Task Unit tests completed successfully.');
      else
        dbms_output.put_line('Ilo_Task Unit tests completed with failures.');
      end if;
      dbms_output.put_line(rpad('=',60,'='));

      -- Reset 
      ilo_timer.set_mark_all_tasks_interesting(false);
      
      debug('-- END ut_ilo_task');

      RETURN (package_results);
   END;
END Ut_Ilo_Task;
/
