col description   for a65
col sqlset_ownber for a15

select sqlset_name
      ,sqlset_owner
      ,description
      ,sqlset_id
      ,id
      ,owner
      ,created
from   dba_sqlset_references
where  owner = upper ('&owner');