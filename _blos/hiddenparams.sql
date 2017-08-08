/*
 *    Show hidden parameters.
 *
 *    Must be DBA.
 */
select pin.ksppinm   param, 
       pcv.ksppstvl  val,
       pin.ksppdesc  descr
from   sys.x$ksppi  pin, 
       sys.x$ksppcv pcv
where  pin.inst_id   =  userenv('Instance')
and    pcv.inst_id   =  pin.inst_id
and    pin.indx      =  pcv.indx
and    pin.ksppinm   like '\_%' escape '\'
order by 
       pin.ksppinm
/
