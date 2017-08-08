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

REM -----------------------------------------------------                                                                     
REM $Id: find-no-bind-sql.sql,v 1.1 2002/03/14 00:01:49 hien Exp $
REM Author      : Murray Ed
REM #DESC       : Find and count the similar/same repeated sql
REM Usage       : stmt_length - length of a substring for search
REM Description : Find and count the similar/same repeated sql
REM               AKA SQL that doesn't use bind variables                                                                     
REM -----------------------------------------------------                                                                     
undefine stmt_length                                                                                                          
                                                                                                                              
accept stmt_length prompt 'Enter length of substring for search:';                                                            
                                                                                                                              
set lines 200                                                                                                                 
                                                                                                                              
col module format a15                                                                                                         
col osuser format a8                                                                                                          
col machine format a10                                                                                                        
col program format a40                                                                                                        
col last_command format a10 heading 'Last|Command'                                                                            
col sql_text format a80                                                                                                       
set trunc off                                                                                                                 
break on machine skip 1 on osuser on process                                                                                  
                                                                                                                              
select count(*), SUBSTR(t.sql_text,1,&STMT_LENGTH)                                                                            
from    v$sqlarea t                                                                                                           
group by SUBSTR(t.sql_text,1,&STMT_LENGTH)                                                                                    
having count(*) > 1                                                                                                           
order by 1                                                                                                                    
;                                                                                                                             
-- order by s.machine, s.osuser, s.process;                                                                                   
                                                                                                                              
undefine stmt_length         
