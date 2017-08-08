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

REM ------------------------------------------------------------------------------------------------
REM #DESC      : Show submitted jobs along with owner info
REM Usage      :
REM Description: List all submitted jobs
REM ------------------------------------------------------------------------------------------------

@plusenv

col jid  format 999999  heading 'Job#' 
col owner format a10 heading 'Owner'
col subu format a10  heading 'Submitter'     trunc 
col secd format a10  heading 'Security'      trunc 
col what format a40  heading 'What'          word_wrapped 
col lsd  format a5   heading 'Last|Ok|Date'  
col lst  format a5   heading 'Last|Ok|Time' 
col nrd  format a5   heading 'Next|Run|Date' 
col nrt  format a5   heading 'Next|Run|Time' 
col fail format 999  heading 'Errs' 
col broken   format a6   heading 'Broken' 
 
select 
  job                        jid, 
  schema_user		     owner,
  log_user                   subu, 
  priv_user                  secd, 
  what                       what, 
  to_char(last_date,'MM/DD') lsd, 
  substr(last_sec,1,5)       lst, 
  to_char(next_date,'MM/DD') nrd, 
  substr(next_sec,1,5)       nrt, 
  failures 		     fail, 
  decode(broken,'Y','Y','N')  Broken
from dba_jobs 
/ 

