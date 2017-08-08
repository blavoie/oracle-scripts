set echo on
set linesize 300
set serveroutput on 


/******************************************************************************
   Étape 1: Créer les procédure réutilisables
******************************************************************************/

-- Afficher données importantes sur la table (stockage, stats, etc)
create or replace procedure show_space (
   p_segname             in varchar2,
   p_owner               in varchar2 default user,
   p_type                in varchar2 default 'TABLE',
   p_partition           in varchar2 default null
) 
is
   l_num_rows             number;
   l_free_blks            number;
   l_total_blocks         number;
   l_total_bytes          number;
   l_unused_blocks        number;
   l_unused_bytes         number;
   l_lastusedextfileid    number;
   l_lastusedextblockid   number;
   l_last_used_block      number;
   l_segment_space_mgmt   varchar2 (255);
   l_unformatted_blocks   number;
   l_unformatted_bytes    number;

   l_fs1_blocks           number;
   l_fs1_bytes            number;
   l_fs2_blocks           number;
   l_fs2_bytes            number;
   l_fs3_blocks           number;
   l_fs3_bytes            number;
   l_fs4_blocks           number;
   l_fs4_bytes            number;
   l_full_blocks          number;
   l_full_bytes           number;

   procedure p (p_label in varchar2, p_num in number)
   is
   begin
      dbms_output.put_line (rpad (p_label, 40, '.') || to_char (p_num, '999,999,999,999'));
   end;
begin
   select num_rows
   into   l_num_rows 
   from   user_tables   ut
   where  ut.table_name = p_segname;
   
   p ('Num rows', l_num_rows);

   dbms_space.space_usage (p_owner,
                           p_segname,
                           p_type,
                           l_unformatted_blocks,
                           l_unformatted_bytes,
                           l_fs1_blocks,
                           l_fs1_bytes,
                           l_fs2_blocks,
                           l_fs2_bytes,
                           l_fs3_blocks,
                           l_fs3_bytes,
                           l_fs4_blocks,
                           l_fs4_bytes,
                           l_full_blocks,
                           l_full_bytes,
                           p_partition);

   p ('Unformatted Blocks ', l_unformatted_blocks);
   p ('FS1 Blocks [ 0- 25[%  ', l_fs1_blocks);
   p ('FS2 Blocks [25- 50[% ', l_fs2_blocks);
   p ('FS3 Blocks [50- 75[% ', l_fs3_blocks);
   p ('FS4 Blocks [75-100[%',  l_fs4_blocks);
   p ('Full Blocks        ' ,  l_full_blocks);

   dbms_space.unused_space (
      segment_owner               => p_owner,
      segment_name                => p_segname,
      segment_type                => p_type,
      partition_name              => p_partition,
      total_blocks                => l_total_blocks,
      total_bytes                 => l_total_bytes,
      unused_blocks               => l_unused_blocks,
      unused_bytes                => l_unused_bytes,
      last_used_extent_file_id    => l_lastusedextfileid,
      last_used_extent_block_id   => l_lastusedextblockid,
      last_used_block             => l_last_used_block);

   p ('Total Blocks', l_total_blocks);
   p ('Total Bytes', l_total_bytes);
   p ('Total MBytes', trunc (l_total_bytes / 1024 / 1024));
   p ('Unused Blocks', l_unused_blocks);
   p ('Unused Bytes', l_unused_bytes);
   p ('Last Used Ext FileId', l_lastusedextfileid);
   p ('Last Used Ext BlockId', l_lastusedextblockid);
   p ('Last Used Block', l_last_used_block);  
end;
/

--
create or replace procedure analyser_table
is 
begin
   execute immediate 'analyze table t1 compute statistics';
   dbms_stats.gather_table_stats(ownname => user, tabname => 'T1', cascade => true, estimate_percent => 100); 
end;
/

/******************************************************************************
   Étape 2: créer la table initiale, analyser celle-ci et afficher les stats 
            originales  
******************************************************************************/

-- Drop table t1 (réentrant)
declare
begin
   execute immediate 'drop table t1';
exception
   when others then null;
end;
/ 

-- Créer les données de test...
create table t1 nologging as 
   select * from all_objects
      union all
   select * from all_objects
      union all
   select * from all_objects
      union all
   select * from all_objects
      union all
   select * from all_objects;

commit;

-- Afficher stats originales
exec analyser_table();
exec show_space('T1', USER);
   
/*****************************************************************************
   Étape 3: simuler en forçant un FTS à l'aide d'un count(*) sur notre table  
*****************************************************************************/

set autotrace traceonly explain statistics
select /*+ full(t1) */
       count(*)
from   t1;
set autotrace off

/*****************************************************************************
   Étape 4: Créer de l'espace au début de la table (50000 premières rows) et 
            de la fragmentation un peu partout ailleurs dans le segment.
*****************************************************************************/

delete  
from   t1 
where  rowid in (select rowid
                from   t1
                where  rownum <= 50000);               
commit;

delete 
from   t1
where  rowid in  (select rowid
                  from   (select t1.rowid
                          from t1
                          order by dbms_random.value)
                  where rownum <= 10000)

commit;

/*****************************************************************************
   Étape 5: 
*****************************************************************************/

-- Afficher nouvelles stats
exec analyser_table();
exec show_space('T1', USER);

-- Rouler la requête de tests
set autotrace traceonly explain statistics
select /*+ full(t1) */
       count(*)
from   t1;
set autotrace off        


/*****************************************************************************
 * Faire un Shrink
 *****************************************************************************/

select avg_space/(select value from v$parameter where name='db_block_size')
from   user_tables 
where  table_name = 'T1';