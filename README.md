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
PASSPHRASE=mysupersecurepass
REPO_PATH="ssh://user@server/mnt/backups/"
```


## Unraid Folder Backup via Custom Scripts

```bash
#!/bin/bash

export BACKUP_PATH=/mnt/user/paperless-export
export REPO_NAME=paperless


docker run --rm  \
--env-file .env \
-e REPO_NAME="$REPO_NAME" \
-v $BACKUP_PATH:/mnt/source \
-v /boot/logs/borg.log:/logs/log.txt \
-v /boot/config/ssh/borg_key:/root/.ssh/borg_key:ro \
-v ./create-backup.sh:/backup.sh:ro \
alpine:latest \
sh -c "apk add --no-cache borgbackup openssh && sh /backup.sh"
```

