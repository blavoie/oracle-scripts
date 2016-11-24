/*
    Documentation: http://docs.oracle.com/cd/E18283_01/appdev.112/e16760/d_stats.htm#i1036461

    Accepts either of the following options, or both in combination:
        FOR ALL [INDEXED | HIDDEN] COLUMNS [size_clause]
        FOR COLUMNS [size clause] column [size_clause] [,column [size_clause]...]

        size_clause is defined as size_clause := SIZE {integer | REPEAT | AUTO | SKEWONLY}
        column is defined as column := column_name | extension name | extension

        - integer : Number of histogram buckets. Must be in the range [1,254]. 
        - REPEAT : Collects histograms only on the columns that already have histograms
        - AUTO : Oracle determines the columns to collect histograms based on data distribution and the workload of the columns.
        - SKEWONLY : Oracle determines the columns to collect histograms based on the data distribution of the columns.
        - column_name : Name of a column
        - extension : can be either a column group in the format of (column_name, Colume_name [, ...]) or an expression
*/

prompt Gather Table Statistics for table &1....
exec dbms_stats.gather_table_stats(ownname => sys_context('userenv','current_schema'), tabname => upper('&1'), method_opt=> 'FOR ALL COLUMNS SIZE AUTO', cascade=>true, estimate_percent => dbms_stats.auto_sample_size);
--exec dbms_stats.gather_table_stats(user, upper('&1'), null, method_opt=> 'FOR ALL COLUMNS SIZE REPEAT', cascade=>true);
--exec dbms_stats.gather_table_stats(user, upper('&1'), null, method_opt=> 'FOR ALL COLUMNS SIZE 0', cascade=>true);

