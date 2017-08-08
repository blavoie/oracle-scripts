library(RJDBC)

drv <-JDBC("oracle.jdbc.driver.OracleDriver","/path/to/jdbc/ojdbc6.jar")
conn<-dbConnect(drv,"jdbc:oracle:thin:@grahn-dev.us.oracle.com:1521:orcl","scott","tiger")
data <-dbGetQuery(conn, "select * from emp")

write.table(data, file="out.csv", sep = ",", row.names=FALSE)