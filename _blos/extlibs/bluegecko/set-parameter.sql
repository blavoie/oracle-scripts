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

undefine v_root
undefine v_name
undefine v_target
undefine v_value

accept v_root prompt 'Set parameter matching parameter root (default %): ' DEFAULT '%'
accept v_name prompt 'Set parameter matching parameter name (default %): ' DEFAULT '%'
accept v_target prompt 'Set parameter matching parameter target (default %): ' DEFAULT '%'
accept v_value prompt 'Set parameter to: '


column parameter_root format a40
column parameter_name format a35;
column parameter_target format a30;
column parameter_value format a30;
column set_from_default foramt a10 heading 'Set From|Default';

select 'exec bg_config_util.set_parameter(''' || parameter_root || ''','''
             || parameter_name || ''',''' || parameter_target || ''',''&&v_value''); -- ' || parameter_value
from  bg_parameters
where parameter_root   like UPPER('&&v_root%')
and   parameter_name   like UPPER('&&v_name%')
and   parameter_target like UPPER('&&v_target%')
order by parameter_root
        ,parameter_name
        ,parameter_target
/
