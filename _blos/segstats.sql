select statistic_name,
       object_type,
       object_name,
       value
from   (
            select ss.statistic_name,
                   ss.object_type,
                   ss.object_name,
                   value,
                   rank() over (partition by statistic_name order by value desc) rank
            from   v$segment_statistics ss
            where  ss.owner = 'ICU'

        )
where rank <= 20        