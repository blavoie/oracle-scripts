#!/bin/bash

# TODO: if not defined, prompt for auth string.
#       or use / as default?
AUTH=
export AUTH

sqlplus -S -L /nolog << EOT
set verify off
set linesize 300
set pagesize 50
connect $AUTH
--$*
@tools/latchprof/latchprof.sql sid,username,name % % 1000
exit;
EOT
