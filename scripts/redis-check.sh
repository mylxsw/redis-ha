#!/usr/bin/env bash

PORT=$1
PASSWORD=$2

REDISCLI="/usr/local/redis/bin/redis-cli -p $PORT -a $PASSWORD"
LOGFILE="/data/logs/keepalived-redis-state.log"

function log() {
    local LEVEL=$1
    local MESSAGE=$2
    local TS=`date '+%Y-%m-%d %H:%M:%S'`

    echo "$TS [$LEVEL] CHECK [$PORT] $MESSAGE" >> $LOGFILE
}

RESP=`$REDISCLI PING`
if [ "$RESP"x != "PONG"x ]; then
	log WARNING "Redis server PING request: No Response, Now restart..."
	systemctl restart redis-$PORT 
	sleep 3
	log INFO "Redis server restarted"
	if [ "`$REDISCLI PING`"x != "PONG"x ]; then
		log ERROR "Redis server has crashed" 
		exit 1
	else 
		log INFO "Redis server has been recovered"
		exit 0
	fi
else
	exit 0
fi
