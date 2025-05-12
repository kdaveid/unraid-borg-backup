#!/bin/sh

set -eu

log_message() {
    local message="$1"
    echo "$(date "+%m-%d-%Y %T") : $message" 2>&1 | tee -a /logs/log.txt
}

if [ -z "$REPO_PATH" ]; then
    log_message "Error: The environment variable REPO_PATH is not set!"
    exit 1
else
    log_message "Using repository path: $REPO_PATH"
fi
if [ -z "$REPO_NAME" ]; then
    log_message "Error: The environment variable REPO_NAME is not set!"
    exit 1
fi

if [ -z "$REPO_PASS" ]; then
    log_message "Error: The environment variable REPO_PASS is not set!"
    exit 1
fi


SSH_KEY="/root/.ssh/borg_key" # Pfad zum SSH-Key im Container

export BORG_PASSPHRASE=$REPO_PASS

# Set SSH command to use the specific key
export BORG_RSH="ssh -i $SSH_KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

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

log_message "Borg backup has finished, pruning old backups..."
log_message "Pruning: Keeping 7 daily, 4 weekly, and 6 monthly backups."
borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=6 $REPO_PATH

unset BORG_PASSPHRASE
