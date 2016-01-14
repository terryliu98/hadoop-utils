#!/bin/sh

#########################################
# Submit & Run One Special App On Ooize #
#########################################

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

#####################
# upload app to hdfs#
#####################
USERNAME=`basename $APP_PATH`
$COMMON_SH_PATH/common-upload.sh $USERNAME $APP_NAME
if [ $? -ne 0 ]; then
    exit 1
fi

############
# Kill App #
############
$COMMON_SH_PATH/stop.sh $1

###########
# Run App #
###########
oozie job -oozie $OOZIE_URL -config $1/job.properties -run -D nameNode=$NAME_NODE -D jobTracker=$JOB_TRACKER -D oozie.use.system.libpath=True -D oozie.coord.application.path=$APPS_HDFS_HOME/$USERNAME/$APP_NAME -D wf_application_path=$APPS_HDFS_HOME/$USERNAME/$APP_NAME -D apps_hdfs_home=$APPS_HDFS_HOME -D app_name=$APP_NAME

