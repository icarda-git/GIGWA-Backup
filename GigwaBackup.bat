:: Name:     GigwaBackup.bat
:: Purpose:  Create a backup of the Genotype Investigator for Genome-Wide Analyses (GIGWA)
:: Author:   Khaled Al-Shamaa <k.el-shamaa@cgiar.org>
:: Version:  1.1
:: Revision: v1.1 - 12 Mar 2019 - use wildcards for MongoDB & Tomcat sub folders / version
::                              - add config.properties & applicationContext-data.xml
:: Revision: v1.0 - 22 Oct 2018 - initial version
:: License:  GPLv3

:: Acknowledgement: This work is derivative from the auto MySQL backup for Windows servers 
:: by Matt Moeller v.1.5: https://www.redolive.com/automated-mysql-backup-for-windows/

@ECHO OFF

SET year=%DATE:~10,4%
SET day=%DATE:~7,2%
SET mnt=%DATE:~4,2%
SET hr=%TIME:~0,2%
SET min=%TIME:~3,2%

IF %day% LSS 10 SET day=0%day:~1,1%
IF %mnt% LSS 10 SET mnt=0%mnt:~1,1%
IF %hr% LSS 10 SET hr=0%hr:~1,1%
IF %min% LSS 10 SET min=0%min:~1,1%

SET backuptime=%year%-%mnt%-%day%-%hr%-%min%

ECHO %backuptime%

:: SETTINGS AND Path 

:: Root of Gigwa Installation
SET gigwadir=C:\Gigwa\

:: S3 Backup Path (check the "AWS Remote S3 Backup" section below)
SET s3backup=s3://mybucket/Gigwa/backup/

:: MongoDB Dump Path
SET mongobin=%gigwadir%mongodb-*\bin\

:: MongoDB Port (e.g. 27017)
:: Recent bundles are configured MongoDB port as 59393 to avoid conflicts
SET mongoport=59393

:: Dump Folder Path
SET backupdump=%gigwadir%backup\dump\

:: Apache Tomcat WEB-INF Classes
SET tomcatclass=%gigwadir%apache-tomcat-*\webapps\gigwa\WEB-INF\classes\

:: Backup Folder Path
SET backupfolder=%gigwadir%backup\backupfiles\

:: Backup File Prefix
SET pre=FullGigwaBackup

:: ZIP Executable Path
:: 7za.exe is a standalone command line version of 7-Zip file archiver
:: Source code of 7za.exe and 7-Zip can be found at http://www.7-zip.org/
SET zipper=%gigwadir%backup\zip\7za.exe

:: Number of days to retain .zip backup files 
SET retaindays=30

:: DONE WITH SETTINGS

:: GO FORTH AND BACKUP EVERYTHING!
CD %mongobin%
mongodump.exe --port %mongoport% --out %backupdump%

CD %tomcatclass%
COPY users.properties %backupdump%users.properties
COPY datasources.properties %backupdump%datasources.properties
COPY config.properties %backupdump%config.properties
COPY applicationContext-data.xml %backupdump%applicationContext-data.xml

:: ZIP MongoDB Dump
%zipper% a -tzip "%backupfolder%%pre%.%backuptime%.zip" "%backupdump%*"

:: Delete Dump Files
DEL /s /q /f "%backupdump%*"
FOR /D %%p IN ("%backupdump%*") DO RMDIR "%%p" /s /q

:: Delete ZIP Files Older Than Specified Retain Days
Forfiles -p %backupfolder% -s -m *.* -d -%retaindays% -c "cmd /c DEL /q @path"

:: AWS Remote S3 Backup 
:: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
:: Uncomment the following lines if you have setup AWS CLI and S3 infrastructure
:: aws configure set AWS_ACCESS_KEY_ID XXXXXXXXXXXX
:: aws configure set AWS_SECRET_ACCESS_KEY XXXXXXXXXXXX
:: aws s3 cp %backupfolder%%pre%.%backuptime%.zip %s3backup%%pre%.%backuptime%.zip

CD %gigwadir%backup