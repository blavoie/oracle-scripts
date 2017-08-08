rem
rem Script:     dbms_space_use.sql
rem Author:     Jonathan Lewis
rem Dated:      Nov 2002
rem Purpose:    
rem
rem Last tested 
rem     12.1.0.2
rem     11.2.0.4
rem Not tested
rem     11.1.0.7
rem     10.2.0.5
rem      9.2.0.8
rem Not relevant
rem      8.1.7.4
rem
rem Notes:
rem For accuracy in free space you (once) needed to set the
rem scan limit; and for those rare objects cases where you 
rem had defined multiple freelist groups you still have to
rem work through each free list group in turn
rem
rem For the ASSM calls:
rem     FS1 => 0% - 25% free space
rem     FS2 => 25% - 50% free space
rem     FS3 => 50% - 75% free space
rem     FS4 => 75% - 100% free space
rem     Bytes = blocks * block size
rem
rem Expected errors:
rem     ORA-10614: Operation not allowed on this segment
rem         (MSSM segment, ASSM call)
rem     ORA-10618: Operation not allowed on this segment
rem         (ASSM segment, MSSM call)
rem     ORA-03200: the segment type specification is invalid
rem         (e.g. for LOBINDEX or LOBSEGMENT)
rem         11g - "LOB" is legal for LOB segments
rem             - use "INDEX" for the LOBINDEX
rem
rem For indexes
rem     Blocks are FULL or FS2 (re-usable)
rem
rem Special case: LOB segments.
rem The number of blocks reported by FS1 etc. is actually the
rem number of CHUNKS in use (and they're full or empty). So 
rem if your CHUNK size is not the same as your block size the
rem total "blocks" used doesn't match the number of blocks 
rem below the HWM.
rem
rem The package dbms_space is created by dbmsspu.sql
rem and the body is in prvtspcu.plb
rem
rem 11.2 overloads dbms_space.space_usage for securefile lobs
rem See dbms_space_use_sf.sql
rem
rem When supplying details about partitions the segment type
rem can consist of two words (e.g. LOB PARTITION), these 
rem must be surrounded by quotes to survive the script.
rem
rem You might want to set up two versions of this code with
rem all references to partitions removed from one of them
rem or you have to keep pressing return to bypass the 
rem requests for substitution variables
rem
 
define m_seg_owner  = &1
define m_seg_name   = &2
define m_seg_type   = '&3'
define m_part_name  = &4
 
define m_segment_owner  = &m_seg_owner
define m_segment_name   = &m_seg_name
define m_segment_type   = '&m_seg_type'
define m_partition_name = &m_part_name
 
@@setenv
 
spool dbms_space_use
 
prompt  ===================
prompt  Freelist management
prompt  ===================
 
declare
    wrong_ssm   exception;
    pragma exception_init(wrong_ssm, -10618);
 
    m_free  number(10);
begin
    dbms_space.free_blocks(
        segment_owner       => upper('&m_segment_owner'),
        segment_name        => upper('&m_segment_name'),
        segment_type        => upper('&m_segment_type'),
        partition_name      => upper('&m_partition_name'),
--      scan_limit      => 50,
        freelist_group_id   => 0,
        free_blks       => m_free
    );
    dbms_output.put_line('Free blocks below HWM: ' || m_free);
exception
    when wrong_ssm then
        dbms_output.put_line('Segment not freelist managed');
end;
/
 
 
prompt  ====
prompt  ASSM
prompt  ====
 
declare
    wrong_ssm   exception;
    pragma exception_init(wrong_ssm, -10614);
 
    m_unformatted_blocks    number;
    m_unformatted_bytes     number;
    m_fs1_blocks            number;
    m_fs1_bytes             number;
    m_fs2_blocks            number;  
    m_fs2_bytes             number;
 
    m_fs3_blocks            number;
    m_fs3_bytes             number;
    m_fs4_blocks            number; 
    m_fs4_bytes             number; 
    m_full_blocks           number;
    m_full_bytes            number;
 
begin
    dbms_space.SPACE_USAGE(
        segment_owner       => upper('&m_segment_owner'),
        segment_name        => upper('&m_segment_name'),
        segment_type        => upper('&m_segment_type'),
        unformatted_blocks  => m_unformatted_blocks,
        unformatted_bytes   => m_unformatted_bytes, 
        fs1_blocks      => m_fs1_blocks , 
        fs1_bytes       => m_fs1_bytes,
        fs2_blocks      => m_fs2_blocks,  
        fs2_bytes       => m_fs2_bytes,
        fs3_blocks      => m_fs3_blocks,  
        fs3_bytes       => m_fs3_bytes,
        fs4_blocks      => m_fs4_blocks,  
        fs4_bytes       => m_fs4_bytes,
        full_blocks     => m_full_blocks, 
        full_bytes      => m_full_bytes,
        partition_name      => upper('&m_partition_name')
    );
 
 
    dbms_output.new_line;
    dbms_output.put_line('Unformatted                   : ' || to_char(m_unformatted_blocks,'999,999,990') || ' / ' || to_char(m_unformatted_bytes,'999,999,999,990'));
    dbms_output.put_line('Freespace 1 (  0 -  25% free) : ' || to_char(m_fs1_blocks,'999,999,990') || ' / ' || to_char(m_fs1_bytes,'999,999,999,990'));
    dbms_output.put_line('Freespace 2 ( 25 -  50% free) : ' || to_char(m_fs2_blocks,'999,999,990') || ' / ' || to_char(m_fs2_bytes,'999,999,999,990'));
    dbms_output.put_line('Freespace 3 ( 50 -  75% free) : ' || to_char(m_fs3_blocks,'999,999,990') || ' / ' || to_char(m_fs3_bytes,'999,999,999,990'));
    dbms_output.put_line('Freespace 4 ( 75 - 100% free) : ' || to_char(m_fs4_blocks,'999,999,990') || ' / ' || to_char(m_fs4_bytes,'999,999,999,990'));
    dbms_output.put_line('Full                          : ' || to_char(m_full_blocks,'999,999,990') || ' / ' || to_char(m_full_bytes,'999,999,999,990'));
 
exception
    when wrong_ssm then
        dbms_output.put_line('Segment not ASSM');
end;
/
 
 
prompt  =======
prompt  Generic
prompt  =======
 
declare
    m_total_blocks          number;
    m_total_bytes           number;
    m_unused_blocks         number;
    m_unused_bytes          number;
    m_last_used_extent_file_id  number;
    m_last_used_extent_block_id number;
    m_last_used_block       number;
begin
    dbms_space.unused_space(
        segment_owner       => upper('&m_segment_owner'),
        segment_name        => upper('&m_segment_name'),
        segment_type        => upper('&m_segment_type'),
        total_blocks        => m_total_blocks,
        total_bytes         => m_total_bytes, 
        unused_blocks       => m_unused_blocks,  
        unused_bytes        => m_unused_bytes,
        last_used_extent_file_id    => m_last_used_extent_file_id, 
        last_used_extent_block_id   => m_last_used_extent_block_id,
        last_used_block     => m_last_used_block,
        partition_name      => upper('&m_partition_name')
    );
 
    dbms_output.put_line('Segment Total blocks: '  || to_char(m_total_blocks,'999,999,990'));
    dbms_output.put_line('Object Unused blocks: '  || to_char(m_unused_blocks,'999,999,990'));
 
end;
/
 
undefine 1
undefine 2
undefine 3
undefine 4
 
undefine m_seg_owner
undefine m_seg_name
undefine m_seg_type
undefine m_part_name
 
undefine m_segment_owner
undefine m_segment_name
undefine m_segment_type
undefine m_partition_name
 
spool off
