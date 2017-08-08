create or replace and resolve java source named "DateTimeUtils" as 
public class DateTimeUtils {

    public static final String TIMEZONE_ID = "America/Montreal";

    public static long getMilisFromDateTime(int year, int month, int day, int hour, int minute, int second) {
        java.util.Calendar cal = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone(TIMEZONE_ID));
        cal.clear();
        cal.set(year, month - 1, day, hour, minute, second);
        
        return cal.getTimeInMillis();
    }

    public static java.lang.String getDateTimeFromMilis(long millis) {
        java.util.Calendar cal = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone(TIMEZONE_ID));
        cal.clear();
        cal.setTimeInMillis(millis);
        
        return cal.get(java.util.Calendar.YEAR)         + "-" + 
               (cal.get(java.util.Calendar.MONTH) + 1)  + "-" + 
               cal.get(java.util.Calendar.DAY_OF_MONTH) + " " +
               cal.get(java.util.Calendar.HOUR_OF_DAY)  + ":" +
               cal.get(java.util.Calendar.MINUTE)       + ":" +
               cal.get(java.util.Calendar.SECOND);
    }
}
/

create or replace package java_date_utils as     
   function timestamp_to_millis(p_timestamp in timestamp)
      return number;
   
   function millis_to_timestamp(p_millis in number)
      return timestamp;   
end;
/

create or replace package body java_date_utils as
   ---------------------------------------------------------------------------------------------------------------------
   -- Private functions
   ---------------------------------------------------------------------------------------------------------------------
   function j_timestamp_to_millis(  p_annee         number
                                  , p_mois          number
                                  , p_jour          number
                                  , p_heure         number
                                  , p_minute        number
                                  , p_second        number)
      return number
   as
      language java
      name 'DateTimeUtils.getMilisFromDateTime(int, int, int, int, int, int) return long';
   
   
   function j_millis_to_timestamp(p_millis in number)
      return varchar2
   as
      language java
      name 'DateTimeUtils.getDateTimeFromMilis(long) return java.lang.String';

   ---------------------------------------------------------------------------------------------------------------------      
   -- Public functions
   ---------------------------------------------------------------------------------------------------------------------
   function timestamp_to_millis(p_timestamp in timestamp)
      return number
   is
   begin
      return j_timestamp_to_millis(  extract(year   from p_timestamp)
                                   , extract(month  from p_timestamp)
                                   , extract(day    from p_timestamp)
                                   , extract(hour   from p_timestamp)
                                   , extract(minute from p_timestamp)
                                   , extract(second from p_timestamp));
   end timestamp_to_millis;
   
   function millis_to_timestamp(p_millis in number)
      return timestamp
   is
   begin
      return to_timestamp(j_millis_to_timestamp(p_millis),'YYYY-MM-DD HH24:MI:SS');
   end;
      
end;
/