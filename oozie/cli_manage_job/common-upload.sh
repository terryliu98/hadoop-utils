#!/bin/sh

USERNAME=$1
APP_NAME=$2

########################
# rm old app from hdfs #
########################
MSG=`hadoop fs -rm -r -f $APPS_HDFS_HOME/$USERNAME/$APP_NAME 2>&1`
if [ $? -ne 0 ]; then
    MESSAGE="failed to rm app from hdfs: $MSG"
    echo $MESSAGE
    exit 1
fi

MSG=`hadoop fs -rm -r -f $APPS_HDFS_HOME/$USERNAME/common 2>&1`
if [ $? -ne 0 ]; then
    MESSAGE="failed to rm common from hdfs: $MSG"
    echo $MESSAGE
    exit 1
fi

#######################
# put new app to hdfs #
#######################
MSG=`hadoop fs -put $APPS_HOME/$USERNAME/$APP_NAME $APPS_HDFS_HOME/$USERNAME/ 2>&1`
if [ $? -ne 0 ]; then
    MESSAGE="failed to put app to hdfs: $MSG"
    echo $MESSAGE
    exit 1
fi

if [ -d $APPS_HOME/$USERNAME/common ]; then
    MSG=`hadoop fs -put $APPS_HOME/$USERNAME/common $APPS_HDFS_HOME/$USERNAME/ 2>&1`
    if [ $? -ne 0 ]; then
        MESSAGE="failed to put common to hdfs: $MSG"
        echo $MESSAGE
        exit 1
    fi
fi
