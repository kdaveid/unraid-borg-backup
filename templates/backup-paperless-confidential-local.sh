#!/bin/bash

cd /mnt/user/borg/unraid-borg-backup

export NOTIFY_PATH=/usr/local/emhttp/webGui/scripts/notify
export BORG_CACHE_DIR=/mnt/user/borg/cache/paperless-conf-local/

export BACKUP_PATH=/mnt/user/paperless-confidential-export
export REPO_NAME=paperless-cnf
export REPO_PATH=/mnt/user/backups/borg/

export LOG_PATH="/boot/logs/borg-paperless-cnf-lcl.log"

touch $LOG_PATH

docker run --rm  \
    --env-file .env \
    -e REPO_NAME="$REPO_NAME" \
    -e REPO_PATH=/mnt/backupdest \
    -v $BORG_CACHE_DIR:/mnt/borg/cache \
    -v $REPO_PATH:"/mnt/backupdest" \
    -v $BACKUP_PATH:/mnt/source:ro \
    -v $LOG_PATH:/logs/log.txt \
    -v ./create-backup.sh:/backup.sh:ro \
    borg \
    sh /backup.sh

BORG_EXIT_CODE=$?

if [ $BORG_EXIT_CODE -eq 0 ]; then
    $NOTIFY_PATH -e $REPO_NAME -s "Rocket $REPO_NAME Backup succeeded" -d "Success" -i normal
elif [ $BORG_EXIT_CODE -eq 1 ]; then
    $NOTIFY_PATH -e $REPO_NAME -s "Rocket $REPO_NAME Backup warnings" -d "Completed with warnings, exit code: $BORG_EXIT_CODE" -i warning
else
    $NOTIFY_PATH -e $REPO_NAME -s "Rocket $REPO_NAME Backup FAILED" -d "Backup failed! Exit Code: $BORG_EXIT_CODE" -i warning
    exit $BORG_EXIT_CODE
fi