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

--  PL/SQL routine to unpin all cursors

DECLARE
    CURSOR unpin_cursors IS
     SELECT address || ',' || hash_value as cursor_string
       FROM v$sqlarea;
BEGIN
    FOR uc_rec IN unpin_cursors LOOP
      sys.dbms_shared_pool.unkeep(uc_rec.cursor_string,'C');
    END LOOP;
END;
/
