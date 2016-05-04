#!/bin/bash
#
#Copyright 2013 Intel Corporation, All Rights Reserved.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
#

#-------------------------------
# COSBENCH STARTUP SCRIPT
#-------------------------------

CONF_DIR=./conf
RUN_DIR=./run
LIB_DIR=.

LOG_DIR=$RUN_DIR/log

SERVICE_NAME=$1

BOOT_LOG=$LOG_DIR/${SERVICE_NAME}_boot.log

OSGI_BUNDLES="$2"

OSGI_CONSOLE_PORT=$3

OSGI_CONFIG=$CONF_DIR/.$SERVICE_NAME

TOMCAT_CONFIG=$CONF_DIR/$SERVICE_NAME-tomcat-server.xml

TOOL="nc"
TOOL_PARAMS="-i 0"

#-------------------------------
# MAIN
#-------------------------------

mkdir -p $RUN_DIR
cp -r $OSGI_CONFIG $RUN_DIR/
OSGI_CONFIG=$RUN_DIR/.$SERVICE_NAME

rm -f $BOOT_LOG
mkdir -p $LOG_DIR

echo "Launching osgi framwork ... "

/usr/bin/nohup java -Dosgi.logfile="$LOG_DIR/${SERVICE_NAME}_osgi.log" \
  -DCOSBENCH_LOG_DIR="$LOG_DIR" -DCOSBENCH_CONF_DIR="$CONF_DIR" \
  -Dcosbench.$SERVICE_NAME.config="$CONF_DIR/$SERVICE_NAME.conf" \
  -DCOSBENCH_RUN_DIR="$RUN_DIR" -Dcosbench.tomcat.config=$TOMCAT_CONFIG \
  -Dcosbench.web.cosbenchUsers="$CONF_DIR/cosbench-users.xml" \
  -Dosgi.framework=$LIB_DIR/osgi/org.eclipse.osgi_3.9.0.v20130529-1710.jar \
  -server -cp $LIB_DIR/main/* org.eclipse.equinox.launcher.Main -configuration $OSGI_CONFIG \
  -console $OSGI_CONSOLE_PORT 1> $BOOT_LOG 2>&1 &

if [ $? -ne 0 ];
then
        echo "Error in launching osgi framework!"
        cat $BOOT_LOG
        exit 1
fi

sleep 1

echo "Successfully launched osgi framework!"

echo "Booting cosbench $SERVICE_NAME ... "

succ=1

which $TOOL 1>&2 >/dev/null
if [ $? -ne 0 ]; then
	echo "No appropriate tool found to detect cosbench $SERVICE_NAME status."
	attemps=60
	while [ $attemps -gt 0 ]; do
		attemps=`expr $attemps - 1`
		echo -n "."
		sleep 1
	done
	succ=2
	echo
	echo "Started cosbench $SERVICE_NAME!"
else

for module in $OSGI_BUNDLES
do
        ready=0
        attempts=60
        while [ $ready -ne 1 ];
        do
                echo "ss -s ACTIVE cosbench" | $TOOL $TOOL_PARAMS 0.0.0.0 $OSGI_CONSOLE_PORT | grep $module >> /dev/null
                if [ $? -ne 0 ];
                then
                        attempts=`expr $attempts - 1`
                        if [ $attempts -eq 0 ];
                        then
                                if [ $attempts -ne 60 ]; then echo ""; fi
                                echo "Starting    $module    [ERROR]"
                                succ=0
                                break
                        else
                                echo -n "."
                                sleep 1
                        fi
                else
                        if [ $attempts -ne 60 ]; then echo ""; fi
                        echo "Starting    $module    [OK]"
                        ready=1
                fi
        done
done
fi

if [ $succ -eq 0 ];
then
        echo "Error in booting cosbench $SERVICE_NAME!"
        exit 1
elif [ $succ -eq 1 ]; then
	echo "Successfully started cosbench $SERVICE_NAME!"
fi

cat $BOOT_LOG

exit 0
