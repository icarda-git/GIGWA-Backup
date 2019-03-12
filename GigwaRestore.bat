:: Name:     GigwaRestore.bat
:: Purpose:  Restore a backup of the Genotype Investigator for Genome-Wide Analyses (GIGWA)
:: Author:   Khaled Al-Shamaa <k.el-shamaa@cgiar.org>
:: Version:  1.1
:: Revision: v1.1 - 12 Mar 2019 - use wildcards for MongoDB & Tomcat sub folders / version
::                              - add config.properties & applicationContext-data.xml
:: Revision: v1.0 - 22 Oct 2018 - initial version

@ECHO OFF

:: SETTINGS AND Path 

:: Root of Gigwa Installation
SET gigwadir=C:\Gigwa\

:: MongoDB Dump Path
SET mongobin=%gigwadir%mongodb-*\bin\

:: MongoDB Port (e.g. 27017)
:: Recent bundles are configured MongoDB port as 59393 to avoid conflicts
SET mongoport=59393

:: Apache Tomcat Port (e.g. 8080)
:: Recent bundles are configured Apache Tomcat port as 59395 to avoid conflicts
SET tomcatport=59395

:: Dump Folder Path
SET backupdump=%gigwadir%backup\dump\

:: Apache Tomcat WEB-INF Classes
SET tomcatclass=%gigwadir%apache-tomcat-*\webapps\gigwa\WEB-INF\classes\

:: ZIP Executable Path
:: 7za.exe is a standalone command line version of 7-Zip file archiver
:: Source code of 7za.exe and 7-Zip can be found at http://www.7-zip.org/
SET zipper=%gigwadir%backup\zip\7za.exe

:: DONE WITH SETTINGS

:: Clean the Dump Folder First
DEL /s /q /f "%backupdump%*"
FOR /D %%p IN ("%backupdump%*") DO RMDIR "%%p" /s /q

:: UNZIP MongoDB Dump
%zipper% x %1 -o%backupdump%

:: Restore MangoDB
CD %mongobin%
mongorestore.exe --drop --port %mongoport% %backupdump%

:: Restore Users Permissions & Databases Information
CD %tomcatclass%
COPY /Y %backupdump%users.properties users.properties
COPY /Y %backupdump%datasources.properties datasources.properties
COPY /Y %backupdump%config.properties config.properties
COPY /Y %backupdump%applicationContext-data.xml applicationContext-data.xml

:: Clean Dump Folder
DEL /s /q /f "%backupdump%*"
FOR /D %%p IN ("%backupdump%*") DO RMDIR "%%p" /s /q

:: Restart Gigwa
CALL %gigwadir%stopGigwa.bat

:WAITINGPORT
netstat -o -n -a | find "LISTENING" | find ":%tomcatport% " > NUL
ECHO "Waiting Gigwa Shutdown to Restart!"
if "%ERRORLEVEL%" equ "0" (
  PING -n 5 127.0.0.1 >nul
  GOTO :WAITINGPORT
)

CALL %gigwadir%startGigwa.bat
