#!/usr/bin/env bash

set -euo pipefail

export PASSPHRASE=$(cat /kv/BACKUP_DATA_PASSWORD)

# Create log file if does not exist.
LOG_FILE=/var/log/duplicity/duplicity.log
if [[ ! -f "$LOG_FILE" ]]; then
    mkdir -p $(dirname $LOG_FILE)
    touch $LOG_FILE
fi

echo $(date -u) " Running duplicity-backup.sh script..." >> $LOG_FILE

# Create a new backup, duplicity makes a decision if it should be full or incremental backup.
duplicity \
--full-if-older-than 1M \
--include /home \
--include /etc \
--exclude '**' \
/ \
file://$1 \
&>>$LOG_FILE

# Remove old, redundant backups. Keep only the latest full backup
# and incremental backups based on the latest full backup.
duplicity \
remove-all-but-n-full 1 \
--force \
file://$1 \
&>>$LOG_FILE
