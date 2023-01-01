# Backups to external disk

It would be the best to save backups in NAS or some cloud storage, but for starters an external disk is fair enough.  
The entire logic is based on the publicly available script for rsync backups: [https://github.com/laurent22/rsync-time-backup](https://github.com/laurent22/rsync-time-backup).  

Probably it is easier and it makes more sense to use `duplicity` instead.

## Pros

1. Script has many great features like auto removal of old backups. It is a good example of how good bash script should look like. The cleanest, well managed bash script I have ever seen.

## Cons

1. No data encryption.
   1. You could add a mechanism compressing data with tar and then encrypting with gpg before calling rsync, but there are many caveats. e.g Won't we break the "incremental backup" logic, because there will always be only one, compressed file?
   2. You can encrypt the entire disk and don't care about data encryption, but what about data protection in trasit? Again, there are some caveats...
2. No data compression.

## How to prepare an external, fully encrypted disk to serve as a backup storage

1. Connect an external disk to the computer.
2. cryptsetup luksFormat the block device. Pass a path to the file with password as parameter.
3. cryptsetup luksOpen to mount the encrypted block to the virtual device mapper. Created mapper name should have name `luks-backups-<external disk block UUID>`.
4. Format virtual device mapper to ext4 file system.
5. Mount virtual device mapper at `/backups` path. Consider changing the owner of this directory `sudo chown sebastian:sebastian /backups`, if needed for convenience.
6. Configure auto luksOpen of virtual device mapper on boot up.
7. Configure auto mount of the virtual device mapper on boot up.
8. Make sure that your user has exec permission for the `sudo chmod +x reconnect-encrypted-disk.sh` script.
9. Add record to sudo crontab configuration that will run `reconnect-encrypted-disk.sh` 1 minute before running the backup script to make sure that even when disk was plugged in after the computer booted up or disk was removed uncorrectly and later plugged in again, disk will be mounted at the time of running the backup script. Run `sudo crontab -e` and later `59 5,21 * * * /home/sebastian/.machineconfig/scripts/backups/system-with-rsync/reconnect-encrypted-disk.sh <external disk block UUID: 02fba679-148c-40d9-8087-aad653f551a4>`. Adjust time spec accordingly, if needed.
10. Do your best to prevent the situation when disk is being unmounted, unplugged when backup is in progress. It may cause data loss. Before unplugging the external disk you should unmount the virtual device mapper and luksClose the virtual device mapper. Take commands to run from one of resources below or `reconnect-encrypted-disk.sh` script.
11. Useful resources:
    1. [https://kifarunix.com/encrypt-drives-with-luks-in-linux/](https://kifarunix.com/encrypt-drives-with-luks-in-linux/)
    2. [https://kifarunix.com/automount-luks-encrypted-device-in-linux/](https://kifarunix.com/automount-luks-encrypted-device-in-linux/)

## How to run the backup script

1. Make sure that the external disk is prepared to serve as a backup storage. [Description here.](#how-to-prepare-an-external-fully-encrypted-disk-to-serve-as-a-backup-storage)
2. Clone `rsync-tmbackup.sh` script from [remote repository](https://github.com/laurent22/rsync-time-backup).
3. Make sure that your user has exec permission for the `sudo chmod +x rsync-tmbackup.sh` script.
4. Add record to `sudo crontab -e` configuration that will run the backup script periodically. e.g `0 6,22 * * * if grep -qs /backups /proc/mounts; then /home/sebastian/.machineconfig/scripts/backups/system-with-rsync/rsync-tmbackup.sh <source path> <destination path e.g /backups/test-me>; fi`. If condition checks if the external disk is mounted at `/backups` path. You can run the script manually for the first time to check if script works as expected. You may need to create an empty file named `backup.marker` in the destination folder.
5. Useful resources:
   1. [https://github.com/laurent22/rsync-time-backup/blob/master/README.md](https://github.com/laurent22/rsync-time-backup/blob/master/README.md)
   2. [https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time](https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time)
