#!/bin/sh

HOME=`dirname $0`
START_TIME=`date "+%Y%m%d%H%M"`
LOG_FILE="camus_${START_TIME}.log"
MIN=`date "+%M"`

###############
# 1. get time #
###############
# start/end time for openapi_invoke_monitor
SYEAR_OPENAPIMONI=`date -d "11 min ago" +%Y`
SMONTH_OPENAPIMONI=`date -d "11 min ago" +%m`
SDAY_OPENAPIMONI=`date -d "11 min ago" +%d`
SHOUR_OPENAPIMONI=`date -d "11 min ago" +%H`
STIME_OPENAPIMONI=`date -d "11 min ago" "+%Y-%m-%d %H:%M:00"`
ETIME_OPENAPIMONI=`date -d "1 min ago" "+%Y-%m-%d %H:%M:00"`

#################
# 2. move camus's tracker-related to /data/share/track_exps
#################
if [ "$MIN" == "01" ]; then
    BYEAR=`date -d "1 hour ago" +%Y`
    BMONTH=`date -d "1 hour ago" +%m`
    BDAY=`date -d "1 hour ago" +%d`
    BHOUR=`date -d "1 hour ago" +%H`

    CAMUS_TR_PATH="/data/camus/topics/tracker-related/hourly/$BYEAR/$BMONTH/$BDAY/$BHOUR"
    BI_TR_PATH="/data/share/track_exps/ds=$BYEAR-$BMONTH-$BDAY/hour=$BHOUR/step=0"

    hadoop fs -mkdir -p $BI_TR_PATH
    hadoop fs -mv $CAMUS_TR_PATH/* $BI_TR_PATH
fi

##################
# 3. start camus #
##################
echo "START_TIME=$START_TIME" > $HOME/log/$LOG_FILE

hadoop jar $HOME/camus-example-0.1.0-SNAPSHOT-shaded.jar com.linkedin.camus.etl.kafka.CamusJob -P $HOME/camus.properties >> $HOME/log/$LOG_FILE 2>&1

END_TIME=`date "+%Y%m%d%H%M"`
echo "END_TIME=$END_TIME" >> $HOME/log/$LOG_FILE
chmod 666 $HOME/log/$LOG_FILE

###################################
# 4. start openapi_invoke_monitor #
###################################
echo "set mapreduce.job.queuename=tandem;" > /tmp/openapi_invoke_monitor.sql
echo "set mapreduce.job.reduces=1;" >> /tmp/openapi_invoke_monitor.sql
echo "set mapreduce.input.fileinputformat.split.maxsize=256000000;" >> /tmp/openapi_invoke_monitor.sql
echo "set mapreduce.input.fileinputformat.split.minsize.per.node=256000000;" >> /tmp/openapi_invoke_monitor.sql
echo "set mapreduce.input.fileinputformat.split.minsize.per.rack=256000000;" >> /tmp/openapi_invoke_monitor.sql
echo "insert into table tandem.openapi_invoke_monitor SELECT concat(unix_timestamp(\"$STIME_OPENAPIMONI\")*1000, \"_\", nvl(appid,-1), \"_\", nvl(max(categoryId),-1), \"_\", nvl(max(isvId),-1), \"_\", nvl(invokemethod,-1)), cast(appid as string), cast(max(categoryId) as string), cast(max(isvId) as string), invokemethod, cast(count(invokemethod) as string), cast(cast(round(avg(visittimecost)) as bigint) as string), cast(sum(invokestatus) as string), from_unixtime(unix_timestamp()) FROM tandem.openapi_invoke_base where y='$SYEAR_OPENAPIMONI' and m='$SMONTH_OPENAPIMONI' and d='$SDAY_OPENAPIMONI' and h='$SHOUR_OPENAPIMONI' and visitTime >= '$STIME_OPENAPIMONI' and visitTime <'$ETIME_OPENAPIMONI' and appid is not null GROUP BY appid, invokemethod;" >> /tmp/openapi_invoke_monitor.sql

/usr/bin/beeline -u jdbc:hive2://10.17.28.193:10000 -n tandem -p tandem_123 --incremental=true -f /tmp/openapi_invoke_monitor.sql &

#######################
# 5. move camus's tracker-related to bi path 
#######################
if [ "$MIN" == "01" ]; then
    CNT=1 
    while (( $CNT <= 12 ))
    do  
        BYEAR=`date -d "$CNT hour ago" +%Y`
        BMONTH=`date -d "$CNT hour ago" +%m`
        BDAY=`date -d "$CNT hour ago" +%d`
        BHOUR=`date -d "$CNT hour ago" +%H`
        
        CAMUS_TR_PATH="/data/camus/topics/tracker-related/hourly/$BYEAR/$BMONTH/$BDAY/$BHOUR"
        BI_TR_PATH="/data/share/track_exps/ds=$BYEAR-$BMONTH-$BDAY/hour=$BHOUR/step=0"
        
        hadoop fs -mv $CAMUS_TR_PATH/* $BI_TR_PATH
        CNT=$(($CNT+1))
    done
fi
