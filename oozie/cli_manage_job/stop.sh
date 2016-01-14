#!/bin/sh

#################################
# Kill One Special App On Ooize #
#################################

########
# init #
########
### check argu num ###
if [ $# -ne 1 ]; then
    MESSAGE="Usage: $0 [app's path]\nexample: $0 $APPS_HOME/tandem/co_tandem_xxx"
    echo -e $MESSAGE
    exit 1
fi

### get shell's absolute path ###
x=`echo $0 | grep "^/"`
if test "${x}"; then
    COMMON_SH_PATH=`dirname $0`
else
    ME=`pwd`/$0
    COMMON_SH_PATH=`dirname $ME`
fi

### get app's absolute path ###
APP_NAME=`basename $1`
x=`echo $1 | grep "^/"`
if test "${x}"; then
    APP_PATH=`dirname $1`
else
    ME=`pwd`/$1
    APP_PATH=`dirname $ME`
fi
APP_PATH=`(cd $APP_PATH;pwd)`

### setup env ###
source $COMMON_SH_PATH/common-env.sh

### check argu ###
$COMMON_SH_PATH/common-check.sh $APP_PATH $APP_NAME
if [ $? -ne 0 ]; then
    exit 1
fi

############
# Kill App #
############
JOB_ID=`oozie jobs -oozie $OOZIE_URL -filter "name=$APP_NAME;status=RUNNING;status=PREP" -jobtype coordinator -len 10000 | awk '{print $1}' | grep -E '[0-9]+.+'`
if [ X"$JOB_ID" != "X" ]; then
    oozie job -oozie $OOZIE_URL -kill $JOB_ID
fi

