#!/bin/bash

cd /mnt/user/borg/unraid-borg-backup

export BACKUP_PATH=/mnt/user/photos-db_dumps
export REPO_NAME=photos-db-dumps
export REPO_PATH=/mnt/disks/WCK5DGVZ/borg-backup/
export LOG_PATH="/boot/logs/borg-photos-db-lcl-ext-disk.log"

touch $LOG_PATH

docker run --rm  \
    --name borg-photos-db-lcl-ext-disk \
    --env-file .env \
    -e REPO_NAME="$REPO_NAME" \
    -e REPO_PATH=/mnt/backupdest \
    -v $REPO_PATH:"/mnt/backupdest" \
    -v $BACKUP_PATH:/mnt/source:ro \
    -v $LOG_PATH:/logs/log.txt \
    -v /usr/local/emhttp/webGui/scripts/:/unraid-scripts:ro \
    -v ./create-backup.sh:/backup.sh:ro \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && sh /backup.sh"