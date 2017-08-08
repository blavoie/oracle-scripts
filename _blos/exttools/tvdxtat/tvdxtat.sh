#!/bin/sh

#JAVA_HOME=/u00/app/oracle/product/10.2.0/jdk/jre
TVDXTAT_HOME=/home/bl/blos/exttools/tvdxtat

java -Xmx1024m -Dtvdxtat.home=$TVDXTAT_HOME -Djava.util.logging.config.file=$TVDXTAT_HOME/config/logging.properties -jar $TVDXTAT_HOME/lib/tvdxtat.jar $*
