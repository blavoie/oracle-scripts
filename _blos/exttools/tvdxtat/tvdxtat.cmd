@echo off
set JAVA_HOME=C:\Oracle\product\10.2.0\jdk\jre
set TVDXTAT_HOME=C:\Program Files\tvdxtat

"%JAVA_HOME%"\bin\java -Xmx1024m -Dtvdxtat.home="%TVDXTAT_HOME%" -Djava.util.logging.config.file="%TVDXTAT_HOME%\config\logging.properties" -jar "%TVDXTAT_HOME%\lib\tvdxtat.jar" %*
