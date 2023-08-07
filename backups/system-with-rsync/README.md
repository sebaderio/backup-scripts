# Backups to external disk

It would be the best to save backups in NAS or some cloud storage, but for starters an external disk is fair enough.  
The entire logic is based on the publicly available script for rsync backups: [https://github.com/laurent22/rsync-time-backup](https://github.com/laurent22/rsync-time-backup).  

Probably it is easier and it makes more sense to use `duplicity` instead.

## Pros

1. Script has many great features like auto removal of old backups. It is a good example of how a good bash script should look like.

## Cons

1. No data encryption.
   1. It is possible to add a mechanism compressing data with tar and then encrypting with gpg before calling rsync, but there are many caveats. e.g Won't we break the "incremental backup" logic, because there will always be only one, compressed file?
   2. It is possible to encrypt the entire disk and don't care about data encryption, but what about data protection in trasit? Again, there are some caveats...
2. No data compression.

## How to prepare an external, fully encrypted disk to serve as a backup storage

### Links explaining almost everything. Steps below are just to summarize
- [https://kifarunix.com/encrypt-drives-with-luks-in-linux/](https://kifarunix.com/encrypt-drives-with-luks-in-linux/)
- [https://kifarunix.com/automount-luks-encrypted-device-in-linux/](https://kifarunix.com/automount-luks-encrypted-device-in-linux/)

1. Connect an external disk to the machine.
2. cryptsetup luksFormat the block device. Pass a path to the file with password as parameter.
3. cryptsetup luksOpen to mount the encrypted block to the virtual device mapper. Created mapper should be named `luks-backups-<external disk block UUID taken from >`.
4. Format virtual device mapper to ext4 file system.
5. Mount virtual device mapper at `/backups` path. Consider changing the owner of this directory to your current user `sudo chown sebastian:sebastian /backups`.
8. Make sure that your current user has exec permission for the `sudo chmod +x reconnect-encrypted-disk.sh` script.
9. Configure auto mounting on boot up you adding config to `/etc/crypttab` and `/etc/fstab`.
10. Add record to sudo crontab configuration that will run `reconnect-encrypted-disk.sh` 1 minute before running the backup script to make sure that the disk will be mounted properly at the time of running the backup script. Run `sudo crontab -e`, add record `29 7,19 * * * /home/sebastian/.machineconfig/scripts/backups/system-with-duplicity/reconnect-encrypted-disk.sh <external disk block UUID: 02fba679-148c-40d9-8087-aad653f551a4>`.
11. Prevent unmounting or unplugging when the backup is in progress. It may cause a data loss.
12. Before unplugging the external disk, unmount the virtual device mapper and luksClose the virtual device mapper.

## How to run the backup script

1. Make sure that the external disk is prepared to serve as a backup storage. [Description here.](#how-to-prepare-an-external-fully-encrypted-disk-to-serve-as-a-backup-storage)
2. Clone `rsync-tmbackup.sh` script from [remote repository](https://github.com/laurent22/rsync-time-backup).
3. Make sure that your current user has exec permission for the `sudo chmod +x rsync-tmbackup.sh` script.
4. Add record to `sudo crontab -e` that will run the backup script periodically `0 6,22 * * * if grep -qs /backups /proc/mounts; then /home/sebastian/.machineconfig/scripts/backups/system-with-rsync/rsync-tmbackup.sh <source path> <destination path e.g /backups/test-me>; fi`. Condition checks if the external disk is mounted at `/backups` path. You can run the script manually for the first time to check if script works as expected. You may need to create an empty file named `backup.marker` in the destination folder.
5. Useful resources:
   1. [https://github.com/laurent22/rsync-time-backup/blob/master/README.md](https://github.com/laurent22/rsync-time-backup/blob/master/README.md)
   2. [https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time](https://stackoverflow.com/questions/35574603/run-cron-job-everyday-at-specific-time)
