#!/bin/sh

set -eu

log_message() {
    local message="$1"
    echo "$(date "+%m-%d-%Y %T") : $message" 2>&1 | tee -a /logs/log.txt
}

SSH_KEY_PATH="/ssh/borg_key"

if [ -z "$REPO_PATH" ]; then
    echo "Error: The environment variable REPO_PATH is not set!"
    exit 1
else
    log_message "Using repository path: $REPO_PATH"
fi
if [ -z "$REPO_NAME" ]; then
    echo "Error: The environment variable REPO_NAME is not set!"
    exit 1
fi

if [ -z "$BORG_PASSPHRASE" ]; then
    echo "Error: The environment variable BORG_PASSPHRASE is not set!"
    exit 1
fi


# Set SSH command to use the specific key
export BORG_RSH="ssh -i $SSH_KEY_PATH -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
export BORG_CACHE_DIR='/mnt/borg/cache'

log_message "Borg backup has started" 

# Create a backup
borg create \
    --verbose                       \
    --info                          \
    --filter AMEx                   \
    --files-cache=mtime,size        \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --progress $REPO_PATH::"$REPO_NAME-{now:%Y-%m-%d_%H-%M-%S}" /mnt/source

BORG_EXIT_CODE=$?

if [ $BORG_EXIT_CODE -eq 0 ]; then
    log_message "Borg backup completed successfully."
    /unraid-scripts/notify -e $REPO_NAME -s "Rocket $REPO_NAME Backup succeeded" -d "Success" -i normal
elif [ $BORG_EXIT_CODE -eq 1 ]; then
    log_message "Borg backup completed with warnings."
    /unraid-scripts/notify -e $REPO_NAME -s "Rocket $REPO_NAME Backup warnings" -d "Completed with warnings, exit code: $BORG_EXIT_CODE" -i warning
else
    log_message "Borg backup failed with errors."
    /unraid-scripts/notify -e $REPO_NAME -s "Rocket $REPO_NAME Backup FAILED" -d "Backup failed! Exit Code: $BORG_EXIT_CODE" -i warning
    exit $BORG_EXIT_CODE
fi

log_message "Borg backup has finished, pruning old backups..."
log_message "Pruning: Keeping 7 daily, 4 weekly, and 6 monthly backups."

borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=6 $REPO_PATH -a $REPO_NAME

log_message "Pruning completed. Script finished successfully."

unset BORG_PASSPHRASE

