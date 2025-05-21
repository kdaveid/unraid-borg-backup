
docker run --rm -it  \
    --name borg-interactive \
    --env-file .env \
    -e BORG_REPO=/mnt/backupdest \
    -v /mnt/disks/WCK5DGVZ/borg-backup/:/mnt/backupdest \
    borg borg info


docker run --rm -it  \
    --name borg-interactive \
    --env-file .env \
    -e BORG_REPO=/mnt/backupdest \
    -v /mnt/user/backups/borg/:/mnt/backupdest \
    borg borg info
