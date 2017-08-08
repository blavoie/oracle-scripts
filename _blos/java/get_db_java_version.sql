create or replace function getjavaproperty (myprop in varchar2)
    return varchar2
is
    language java
    name 'java.lang.System.getProperty(java.lang.String) return java.lang.String';

select getjavaproperty ('java.version') from dual;