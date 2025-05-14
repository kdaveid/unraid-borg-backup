#!/bin/sh

set -u

log_message() {
    local message="$1"
    echo "$(date "+%m-%d-%Y %T") : $message" 2>&1 | tee -a /logs/log.txt
}

if [ -z "$REPO_PATH" ]; then
    echo "Error: The environment variable REPO_PATH is not set!"
    exit 1
fi
if [ -z "$REPO_NAME" ]; then
    echo "Error: The environment variable REPO_NAME is not set!"
    exit 1
fi

if [ -z "$BORG_PASSPHRASE" ]; then
    echo "Error: The environment variable BORG_PASSPHRASE is not set!"
    exit 1
fi


LOGFILE=/logs/log.txt
SSH_KEY="/root/.ssh/borg_key" # Pfad zum SSH-Key im Container


# Set SSH command to use the specific key
export BORG_RSH="ssh -i $SSH_KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"


# Check if repository exists, initialize if not
if ! borg info "$REPO_PATH" > /dev/null 2>&1; then
  log_message "Repository does not exist. Initializing repository..."
  borg init --encryption=repokey "$REPO_PATH"
  INIT_EXIT_CODE=$?
  if [ $INIT_EXIT_CODE -ne 0 ]; then
    log_message "ERROR: Failed to initialize repository. Exit code $INIT_EXIT_CODE."
    exit $INIT_EXIT_CODE
  fi
else
  log_message "Repository exists."
fi


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

log_message "Pruning completed. Script finished successfully."

# Unset the passphrase
unset BORG_PASSPHRASE

