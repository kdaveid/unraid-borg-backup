#!/bin/bash

cd /mnt/user/borg/unraid-borg-backup

export BACKUP_PATH=/mnt/user/photos/immich/
export REPO_NAME=photos
export LOG_PATH="/boot/logs/borg-photos-remote.log"

export BORG_CACHE_DIR='/mnt/user/appdata/borg/cache/'

touch $LOG_PATH

docker run --rm  \
    --name borg-photos-remote \
    --env-file .env \
    -e REPO_NAME="$REPO_NAME" \
    -v /root/.ssh/:/ssh/ \
    -v $BORG_CACHE_DIR:/mnt/borg/cache \
    -v $BACKUP_PATH:/mnt/source:ro \
    -v $LOG_PATH:/logs/log.txt \
    -v /usr/local/emhttp/webGui/scripts/:/unraid-scripts:ro \
    -v ./create-backup.sh:/backup.sh:ro \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && sh /backup.sh"

