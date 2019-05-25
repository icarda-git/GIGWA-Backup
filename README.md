# GIGWA Backup/Restore for Windows Server

Setup instructions:

* Create a “backup” directory within your bundled GIGWA folder, and “download ZIP” of this repository contents, then unzip it and copy all files/folders inside the “GIGWA-Backup-master” into the “backup” directory that you just created.

* Edit both of the “GigwaBackup.bat” and “GigwaRestore.bat” batch files to setup the root of GIGWA installation (i.e. gigwadir) and the number of days to retain .zip backup files (i.e. retaindays), all other settings should work fine with bundled GIGWA archive. 

* Finally create a scheduled task in windows to run the batch file on a schedule, remember to choose “Run whether user is logged on or not” otherwise it will fail.

> _**Notification:** This backup/restore batch scripts solution has been developed and tested for the bundled Gigwa archive (i.e. both of the Apache Tomcat and MongoDB are running on the same server)._

## Copyright (C) 2018-2019, ICARDA.
This program is free software provided "AS IS" and comes with ABSOLUTELY NO WARRANTY. It is made available under the terms of the [GNU General Public License version 3](https://www.gnu.org/licenses/gpl-3.0.en.html)

## To cite this work in your publications please use:
Khaled Al-Shamaa (2019). GIGWA Backup/Restore on Windows Server. ICARDA, Cairo, Egypt. URL [https://github.com/icarda-git/GIGWA-Backup](https://github.com/icarda-git/GIGWA-Backup).
