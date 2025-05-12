#!/bin/sh

if [ -n "$PASSPHRASE" ]; then
    echo "Fehler: Die Umgebungsvariable PASSPHRASE ist nicht gesetzt!"
    exit 1
else
    echo "PASSPHRASE ist gesetzt."
fi
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


LOGFILE=/logs/log.txt
SOURCE="/mnt/source" # Der gemountete Pfad, der gesichert werden soll
SSH_KEY="/root/.ssh/borg_key" # Pfad zum SSH-Key im Container

# Export Borg passphrase
export BORG_PASSPHRASE=$PASSPHRASE

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
    --progress $REPO_PATH::"$REPO_NAME-{now:%Y-%m-%d_%H-%M-%S}" $SOURCE

# Prune old backups (optional)
borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=6 $REPO_PATH

# Unset the passphrase
unset BORG_PASSPHRASE

