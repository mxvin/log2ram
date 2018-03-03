#!/usr/bin/env sh

## -------- LOGDOG -------- ##
## ---- Systemlog size Watch and Send ramlog to Remote Server ---- ##

. /etc/default/logdog

LOG_DIR="/var/log"
TARGET_SIZE="35" # in MB (default 35)
TRACKER_ID="$LOG_DIR/.logdog.id"

REMOTE_IP="root@10.10.0.1" # username@Remote IP - LEFT EMPTY to disable/stop sync
REMOTE_PATH="/tmp/server/1/log/"
SSH_PORT='8080'
SSH_KEY="/home/alvin/.ssh/remote"

syncToRemote() {
    if [ ! -z "$REMOTE_IP" ]; then
        rsync -avzhe 'ssh -p $SSH_PORT -i $SSH_KEY' $1 $REMOTE_IP:$REMOTE_PATH
    fi
}

prepareFile() {
    logrotate /etc/logrotate.d/logdog
    syncToRemote $(cat $TRACKER_ID)
}

check() {
    DISK_LEFT=$(df $LOG_DIR -m | awk 'FNR==2 {print $3}') # get disk used
    if [ $DISK_LEFT -le $TARGET_SIZE ]; then
        prepareFile
    fi
}

clean() {
    rm -rf $TRACKER
    rm $TRACKER_PATH
}

check
exit 0