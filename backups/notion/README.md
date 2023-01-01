# Manual backup of data stored in Notion

We probably can trust the reliability and availability of Notion, but it would be good to have a local copy of the data anyway.  
Notion is your second brain. Such a pain would be to loose all the valuable information.

There is an option in Notion settings to simply download all the data in zip format. Just encrypt with GPG and save in the backup storage.  

To encrypt compressed file with GPG run `gpg --symmetric --cipher-algo AES256 <compressed-file-name>`. You will be prompted for password.
