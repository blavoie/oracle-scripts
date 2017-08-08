select paddr, 
       pserial#, 
       name, 
       description, 
       error as err -- renaming column because default ERROR column format exists with A65
from   v$bgprocess
where  paddr <> '00';

