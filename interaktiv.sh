docker run --rm -it  \
    --name borg-interactive \
    --env-file .env \
    -v /mnt/disks/WCK5DGVZ/borg-backup/:/mnt/backupdest \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && sh"




docker run --rm -it  \
    --name borg-interactive \
    --env-file .env \
    -v /mnt/disks/WCK5DGVZ/borg-backup/:/mnt/backupdest \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && borg list /mnt/backupdest"


docker run --rm -it  \
    --name borg-interactive \
    --env-file .env \
    -v /mnt/user/backups/borg/:/mnt/backupdest \
    alpine:latest \
    sh -c "apk add --no-cache borgbackup openssh && borg list /mnt/backupdest"
