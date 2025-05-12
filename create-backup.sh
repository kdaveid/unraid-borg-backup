#!/bin/sh

set -u

if [ -n "$REPO_PATH" ]; then
    echo "Fehler: Die Umgebungsvariable REPO_PATH ist nicht gesetzt!"
    exit 1
else
    echo "REPO_PATH ist gesetzt."
fi
if [ -n "$REPO_NAME" ]; then
    echo "Fehler: Die Umgebungsvariable REPO_NAME ist nicht gesetzt!"
    exit 1
else
    echo "REPO_NAME ist gesetzt."
fi

if [ -n "$REPO_PASS" ]; then
    echo "Fehler: Die Umgebungsvariable REPO_PASS ist nicht gesetzt!"
    exit 1
else
    echo "REPO_PASS ist gesetzt."
fi


LOGFILE=/logs/log.txt
SSH_KEY="/root/.ssh/borg_key" # Pfad zum SSH-Key im Container

export BORG_PASSPHRASE=$REPO_PASS

# Set SSH command to use the specific key
export BORG_RSH="ssh -i $SSH_KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

echo "$(date "+%m-%d-%Y %T") : Borg backup has started" 2>&1 | tee -a $LOGFILE

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

# Prune old backups (optional)
borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=6 $REPO_PATH

# Unset the passphrase
unset BORG_PASSPHRASE

