#!/usr/bin/env bash

MASTER_IP=$1
MASTER_PORT=$2
PASSWORD=$3

REDISCLI="/usr/local/redis/bin/redis-cli -p $MASTER_PORT -a $PASSWORD"
LOGFILE="/data/logs/keepalived-redis-state.log"

function log() {
    local LEVEL=$1
    local MESSAGE=$2
    local TS=`date '+%Y-%m-%d %H:%M:%S'`

    echo "$TS [$LEVEL] BACKUP [$MASTER_PORT] $MESSAGE" >> $LOGFILE
}

log INFO "Waiting data sync..."

sleep 15

log INFO "Switching redis server $MASTER_PORT to slave mode"

$REDISCLI SLAVEOF $MASTER_IP $MASTER_PORT
if [ $? -ne 0 ]; then
    log ERROR "Switch redis server $MASTER_PORT to slave mode failed"
else
    log INFO "Switch redis server $MASTER_PORT to slave mode succeed"
fi
