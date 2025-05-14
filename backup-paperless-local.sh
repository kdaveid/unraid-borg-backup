#!/bin/bash

export BACKUP_PATH=/mnt/user/paperless-export
export REPO_NAME=paperless
export REPO_PATH=/mnt/user/backups/borg/
export LOG_PATH="/boot/logs/borg-paperless-local.log"

touch $LOG_PATH

docker run --rm  \
    --env-file .env \
    -e REPO_NAME="$REPO_NAME" \
    -e REPO_PATH=/mnt/backupdest \
    -v $REPO_PATH:"/mnt/backupdest" \
    -v $BACKUP_PATH:/mnt/source \
    -v $LOG_PATH:/logs/log.txt \
    -v ./create-backup.sh:/backup.sh:ro \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && sh /backup.sh"