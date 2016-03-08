#!/bin/sh -x

############
# 1. clear #
############
echo "---start to clear---" > /tmp/camus-daily.log
# delete the [5 day ago] history folder
exp_date=`date -d "5 day ago" +%Y-%m-%d`
hadoop fs -rm -r /data/camus/exec/history/${exp_date}-* >> /tmp/camus-daily.log 2>&1

# delete the [5 day ago] camus's logs
exp_date=`date -d "5 day ago" +%Y%m%d`
rm -f /home/tandem/camus/log/camus_${exp_date}* >> /tmp/camus-daily.log 2>&1

#################################
# 2. add topics path & paritions#
#################################
echo "---start to add topics path & paritions---" >> /tmp/camus-daily.log
rm -f /tmp/add_paritions.sql
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOURS="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"
for HOUR in $HOURS
do
    hadoop fs -mkdir -p /data/camus/topics/openapi_invoke_log/hourly/$YEAR/$MONTH/$DAY/$HOUR
    #hadoop fs -mkdir -p /data/camus/topics/im_msg_monitor_topic/hourly/$YEAR/$MONTH/$DAY/$HOUR
    #hadoop fs -mkdir -p /data/camus/topics/halog/hourly/$YEAR/$MONTH/$DAY/$HOUR
    echo "alter table tandem.risk_log add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/risk_log/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
    echo "alter table tandem.openapi_invoke_base add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/openapi_invoke_log/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
    echo "alter table tandem.im_msg_monitor add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/im_msg_monitor_topic/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
    echo "alter table tandem.halog add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/opsdev_halog/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
    echo "alter table tandem.shopping_cart_log add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/shopping_cart_log/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
    echo "alter table tandem.shopping_checkout_log add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/shopping_checkout_log/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_paritions.sql
done

/usr/bin/beeline -u jdbc:hive2://10.17.28.193:10000 -n tandem -p tandem_123 --incremental=true -f /tmp/add_paritions.sql >> /tmp/camus-daily.log 2>&1
echo "---end!---" >> /tmp/camus-daily.log
