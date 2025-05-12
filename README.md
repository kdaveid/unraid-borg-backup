# Unraid Docker Script für Custom Scripts

## Vorbedingungen

- Env Variables
- Zielsystem  muss Borg installiert haben
- Benutzer borgbackup muss SSH-Zugriff haben
- Create-Docker-Scripts in /mnt/user/borg/


```bash
git clone https://github.com/kdaveid/unraid-borg-backup.git /mnt/user/borg/
```

In /mnt/user/borg/ muss es ein .env File geben mit dem Passwort.

```ini
REPO_PASS=mysupersecurepass
REPO_PATH="ssh://user@server/mnt/backups/"
SSH_KEY=/root/.ssh/borg_key
```


## Unraid Folder Backup via Custom Scripts

```bash
#!/bin/bash

export BACKUP_PATH=/mnt/user/paperless-export
export REPO_NAME=paperless
export LOG_PATH="/boot/logs/borg.log"

docker run --rm  \
--env-file .env \
-e REPO_NAME="$REPO_NAME" \
-v $BACKUP_PATH:/mnt/source \
-v $LOG_PATH:/logs/log.txt \
-v /boot/config/ssh/borg_key:/root/.ssh/borg_key:ro \
-v /mnt/user/borg/unraid-borg-backup/create-backup.sh:/backup.sh:ro \
alpine:latest \
sh -c "apk add --no-cache borgbackup openssh && sh /backup.sh"
```

