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

    echo "$TS [$LEVEL] MASTER [$MASTER_PORT] $MESSAGE" >> $LOGFILE
}

log INFO  "Sync data from original master: SLAVEOF $MASTER_IP $MASTER_PORT"

$REDISCLI SLAVEOF $MASTER_IP $MASTER_PORT
if [ $? -ne 0 ]; then
    log ERROR "Sync data from original master failed"
else
    log INFO "Sync data from original master ..."
fi

sleep 10

log INFO "Assuming data synchronization is complete, now switch Redis[$MASTER_PORT] to Master"
$REDISCLI SLAVEOF NO ONE
if [ $? -ne 0 ]; then
    log ERROR "Switch redis[$MASTER_PORT] to master failed"
else
    log INFO "Switch redis[$MASTER_PORT] to master succeed"
fi
