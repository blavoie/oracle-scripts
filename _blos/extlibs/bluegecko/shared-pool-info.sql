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
REM #DESC       : Show shared pool info
REM Usage       : No parameters
REM Description : Show shared pool info
REM -----------------------------------------------------
-- 'Shared pool'

select KSMCHCOM, ksmchtyp, sum(ksmchsiz)/1024/1024 "MB"
from x$ksmsp
group by KSMCHCOM, ksmchtyp
having sum(ksmchsiz)/1024/1024 >= 1
order by 3 desc;

-- 'Shared pool reserved'

select KSMCHCOM, ksmchtyp, sum(ksmchsiz)/1024/1024 "MB"
from x$ksmspr
group by KSMCHCOM, ksmchtyp
order by 3 desc;

