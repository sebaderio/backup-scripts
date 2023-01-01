# Backup to external disk with [Duplicity](https://manpages.ubuntu.com/manpages/focal/man1/duplicity.1.html#a%20note%20on%20symmetric%20encryption%20and%20signing)

`duplicity` is the most robust, easy-to-use backup solution from all tested by me.  

Script backups the content of `/home` and `/etc` directories to the destination folder specified as a script parameter.  
There might be some issues when script user will not be wise enough to use the script properly. There is no input parameters validation etc. Read all sections below and check the script implementation to better understand how the script works.

## Duplicity Pros

1. Tool working out of the box.
2. Built-in compression with tar.gz file format.
3. Built-in data encryption with GPG. Both symmetric and asymmetric.
4. Once encrypted, data is secure both in transit and at rest.

## Duplicity Cons

1. You need to run at least 2 commands to create a new backup and remove old, redundant backups.

## How to prepare an external, fully encrypted disk to serve as a backup storage

1. Connect an external disk to the computer.
2. cryptsetup luksFormat the block device. Pass a path to the file with password as parameter.
3. cryptsetup luksOpen to mount the encrypted block to the virtual device mapper. Created mapper name should have name `luks-backups-<external disk block UUID>`.
4. Format virtual device mapper to ext4 file system.
5. Mount virtual device mapper at `/backups` path. Consider changing the owner of this directory `sudo chown sebastian:sebastian /backups`, if needed for convenience.
6. Configure auto luksOpen of virtual device mapper on boot up.
7. Configure auto mount of the virtual device mapper on boot up.
8. Make sure that your user has exec permission for the `sudo chmod +x reconnect-encrypted-disk.sh` script.
9. Add record to sudo crontab configuration that will run `reconnect-encrypted-disk.sh` 1 minute before running the backup script to make sure that even when disk was plugged in after the computer booted up or disk was removed uncorrectly and later plugged in again, disk will be mounted at the time of running the backup script. Run `sudo crontab -e` and add record `29 7,19 * * * /home/sebastian/.machineconfig/scripts/backups/system-with-duplicity/reconnect-encrypted-disk.sh <external disk block UUID: 02fba679-148c-40d9-8087-aad653f551a4>`. Adjust time spec accordingly, if needed.
10. Do your best to prevent the situation when disk is being unmounted, unplugged when backup is in progress. It may cause data loss. Before unplugging the external disk you should unmount the virtual device mapper and luksClose the virtual device mapper. Take commands to run from one of resources below or `reconnect-encrypted-disk.sh` script.
11. Useful resources:
    1. [https://kifarunix.com/encrypt-drives-with-luks-in-linux/](https://kifarunix.com/encrypt-drives-with-luks-in-linux/)
    2. [https://kifarunix.com/automount-luks-encrypted-device-in-linux/](https://kifarunix.com/automount-luks-encrypted-device-in-linux/)

## How to run the backup script

1. Make sure that the external disk is prepared to serve as a backup storage. [Description here.](#how-to-prepare-an-external-fully-encrypted-disk-to-serve-as-a-backup-storage)
2. Install `duplicity`.
3. Make sure that your user has exec permission for the `sudo chmod +x duplicity-backup.sh` script.
4. Create `/kv/BACKUP_DATA_PASSWORD` file. Change file permissions to `sudo chmod 600 /kv/BACKUP_DATA_PASSWORD`. Save password for symmetric encryption of backups in this file. The password will be taken automatically when running the script. Script assumes that the file exists. The same passphrase is needed to decrypt the backup when restoring.
5. Add record to `sudo crontab -e` configuration that will run the backup script periodically. e.g `30 7,19 * * * if grep -qs /backups /proc/mounts; then /home/sebastian/.machineconfig/scripts/backups/system-with-duplicity/duplicity-backup.sh /backups/<some-custom-dir-name>; fi`. If condition checks if the external disk is mounted at `/backups` path. Please provide correct, absolute path to some existing destination directory as script execution parameter. Script will not create the directory when it does not exist yet. You can run the script manually for the first time to check if script works as expected.
6. Useful resources:
   1. [https://manpages.ubuntu.com/manpages/kinetic/en/man1/duplicity.1.html](https://manpages.ubuntu.com/manpages/kinetic/en/man1/duplicity.1.html)
   2. [https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time](https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time)
