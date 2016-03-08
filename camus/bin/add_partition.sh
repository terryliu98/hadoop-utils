#!/bin/sh -x

YEAR=$1
MONTH=$2
DAY=$3
HOURS="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"

rm -f /tmp/add_p.sql

for HOUR in $HOURS
do
     echo "alter table default.track_exps add if not exists partition (ds='$YEAR-$MONTH-$DAY' , hour='$HOUR' ,step='0') location '/data/share/track_exps/ds=$YEAR-$MONTH-$DAY/hour=$HOUR/step=0';" >> /tmp/add_p.sql
    # echo "alter table aaaaaaaaaaaaaaaaaaa add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/risk_log/hourly/$YEAR/$MONTH/$DAY/$HOUR';" >> /tmp/add_p.sql 
    #echo "alter table tandem.halog add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/halog/hourly/2015/$MONTH/$DAY/$HOUR';" >> /tmp/add_p.sql
   # echo "alter table tandem.shopping_checkout_log add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/shopping_checkout_log/hourly/2015/$MONTH/$DAY/$HOUR';" >> /tmp/add_p.sql
    #echo "alter table tandem.shopping_cart_log add if not exists partition (y='$YEAR', m='$MONTH', d='$DAY', h='$HOUR') location '/data/camus/topics/shopping_cart_log/hourly/2015/$MONTH/$DAY/$HOUR';" >> /tmp/add_p.sql
done

/usr/bin/beeline -u jdbc:hive2://10.17.28.193:10000 -n tandem -p tandem_123 -f /tmp/add_p.sql
