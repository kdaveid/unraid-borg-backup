#!/bin/sh

if [ -f .env ]; then
    # Variablen aus der .env-Datei laden
    set -o allexport
    . .env
    set -o noallexport
else
    echo "Fehler: .env-Datei nicht gefunden!"
    exit 1
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

