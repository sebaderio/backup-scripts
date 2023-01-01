# Manual backup of data stored in Google Drive and other services available in Google Account

We probably can trust the reliability and availability of Google, but it would be good to have a local copy of the data anyway.  
e.g All books in pdf format in Google Drive.

To export all data just follow the steps described in Google Help Center [How to download your Google data](https://support.google.com/accounts/answer/3024190). Compress and encrypt with GPG, if needed. After that save in the backup storage.  

To encrypt compressed file with GPG run `gpg --symmetric --cipher-algo AES256 <compressed-file-name>`. You will be prompted for password.
