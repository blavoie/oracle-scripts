create or replace procedure copy_data (
    p_src_schema   in varchar2
   ,p_src_table    in varchar2
   ,p_dst_schema   in varchar2 default null
   ,p_dst_table    in varchar2 default null
   ,p_dblink       in varchar2 default '@enprod11.ulaval.ca'
   ,p_filtre       in varchar2 default null
)
    authid current_user
is
    l_dst_schema   varchar2 (30);
    l_dst_table    varchar2 (30);
begin
    -- Si le schéma de destination n'est pas spécifié, nous utiliserons le schéma courant par défaut.
    if p_dst_schema is null
    then
        l_dst_schema   := user;
    else
        l_dst_schema   := p_dst_schema;
    end if;

    -- Si la table de destination n'est pas spécifiée, nous utiliserons le même nom de la table source.
    if p_dst_table is null
    then
        l_dst_table   := p_src_table;
    else
        l_dst_table   := p_dst_table;
    end if;

    -- Supprimer le contenu de la table dans la BD locale
    execute immediate 'truncate table ' || l_dst_schema || '.' || l_dst_table || ' drop storage';

    -- Mettre la table en nologging
    execute immediate 'alter table ' || l_dst_schema || '.' || l_dst_table || ' nologging';

    -- Importer les données de la BD source vers la BD locale
    execute immediate
           'insert /*+ append */ into '
        || l_dst_schema
        || '.'
        || l_dst_table
        || ' select * from '
        || p_src_schema
        || '.'
        || p_src_table
        || p_dblink
        || ' where 1=1 '
        || p_filtre;

    -- Ramasser stats
    dbms_stats.gather_table_stats (upper (l_dst_schema), upper (l_dst_table));
end;
/