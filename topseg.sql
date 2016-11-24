-- show top segments in size for a specific user (or all)
-- TODO: accept &1 and &2

col owner        format a30
col segment_name format a30

define defnbr=20
accept owner   char prompt 'Owner [all]: '
accept nbr     char prompt 'Number of segments [&&defnbr]: '

select *
from   (
         select ds.owner,
                ds.segment_name,
                ds.segment_type,
                to_char(round(ds.bytes/1024/1024, 2), '99990.99')       as size_mb,
                to_char(round(ds.bytes/1024/1024/1024, 2), '99990.99')  as size_gb
         from   dba_segments ds
         where  ds.owner = nvl(upper('&owner'), ds.owner)
         order by ds.bytes desc
       )
where rownum <= nvl('&nbr', &&defnbr);

undefine defnbr
undefine owner
undefine nbr

col owner        clear
col segment_name clear
