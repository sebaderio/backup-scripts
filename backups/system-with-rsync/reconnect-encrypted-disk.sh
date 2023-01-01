#!/usr/bin/env bash

# Script takes one argument, UUID of block device. Run `lsblk -f` to see all block devices.

# Create log file if does not exist.
LOG_FILE=/var/log/duplicity/duplicity.log
if [[ ! -f "$LOG_FILE" ]]; then
    mkdir -p $(dirname $LOG_FILE)
    touch $LOG_FILE
fi

echo $(date -u) " Running reconnect-encrypted-disk.sh script..." >> $LOG_FILE

umount /backups &>> $LOG_FILE

LUKS_MAPPER_NAME="luks-backups-$1"
cryptsetup luksClose $LUKS_MAPPER_NAME &>> $LOG_FILE

# We need to fetch the mount path manually, because when testing mount path was changing
# from /dev/sda2 to /dev/sdb2 when I was connecting the disk again when external disk was not
# unmounted before unplugging. There was no difference when I called luksClose or not after unmount.
MOUNT_PATH=$(blkid | grep $1 | cut -d ":" -f 1)
cryptsetup luksOpen $MOUNT_PATH $LUKS_MAPPER_NAME --key-file /kv/BACKUP_DISK_PASSWORD &>> $LOG_FILE

mount -a &>> $LOG_FILE
