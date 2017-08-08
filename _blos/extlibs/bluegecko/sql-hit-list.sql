/*
Copyright (c) 2007 Blue Gecko, Inc
License:

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

--  Looks for sql statements doing nasty things to large objects

undefine v_option;

accept v_option prompt 'Look for option? (FULL, FULL SCAN, FAST FULL SCAN,FULL SCAN DESCENDING) : '
accept min_obj_size prompt 'Please enter the minimum object size to look for (m): '
/*
column object_name format a30
column object_tpe format a30

select distinct vp.hash_value,vp.object#,do.object_name,do.object_type
      ,vp.options
      ,vs.executions
from v$sql_plan vp
    ,v$sqlarea vs
    ,dba_objects do
where do.object_id = vp.object#
and   vs.hash_value = vp.hash_value
and vp.options = '&&v_option'
order by 3
/
 
*/

DECLARE
CURSOR plan_cur(P_OPTION IN VARCHAR2) IS  
select distinct object#, hash_value
from v$sql_plan 
where  options = P_OPTION
order by object#, hash_value;

v_obj_name VARCHAR2(30);
v_obj_size NUMBER;
v_executions NUMBER;
v_txt VARCHAR2(250);
v_first_load_time VARCHAR2(19);
BEGIN
  
  FOR p IN plan_cur('&&v_option') LOOP
    
   SELECT object_name INTO v_obj_name
   FROM   dba_objects
   WHERE  object_id = p.object#;
   
   SELECT NVL(sum(bytes)/1024/1024,0) INTO v_obj_size
   FROM   dba_segments
   WHERE  segment_name = v_obj_name;

   IF v_obj_size > &&min_obj_size THEN
     SELECT executions,first_load_time 
     INTO v_executions, v_first_load_time
     FROM   v$sqlarea
     WHERE  hash_value = p.hash_value;
     
     v_txt := RPAD(p.hash_value,15) || ' ' || RPAD(v_obj_name,30);
     v_txt := v_txt || ' ' || v_obj_size || ' Execs -> ' ||v_executions;
     v_txt := v_txt ||'  '|| v_first_load_time;
     dbms_output.put_line(v_txt);
   END IF;
  END LOOP;


END;
/

