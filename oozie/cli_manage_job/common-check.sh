#!/bin/sh

###################
# check app exists #
###################
if [ ! -d $1/$2 ]; then
    MESSAGE="$1/$2 does not exists or be not a directory."
    echo $MESSAGE
    exit 1
fi

##############################
# check rules for app's name #
##############################
APP_NAME=$2
USER_NAME=`basename $1`

## rule 1 ##
if [ $APPS_HOME != "`dirname $1`" ]; then
    MESSAGE="app[$APP_NAME] must be located in $APPS_HOME/[username]."
    echo $MESSAGE
    exit 1
fi

## rule 2 ##
if [ "co" != "`echo $APP_NAME | cut -d_ -f1`" ]; then
    MESSAGE="app's name[$APP_NAME] must be like \"co_[username]_xxxx\"."
    echo $MESSAGE
    exit 1
fi

## rule 3 ##
if [ "$USER_NAME" != "`echo $APP_NAME | cut -d_ -f2`" ]; then
    MESSAGE="app's name[$APP_NAME] must be like \"co_[username]_xxxx\"."
    echo $MESSAGE
    exit 1
fi

