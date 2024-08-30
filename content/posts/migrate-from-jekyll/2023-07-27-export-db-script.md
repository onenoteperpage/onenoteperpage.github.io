---
title: Export DB Script
author: danijel
date: 2023-07-27 11:00:00 +1000
categories: [Reference]
tags: [sql]
series: ['MH Reference']
aliases: ['migrate-from-jekyl']
ShowToc: true
TocOpen: true
editPost:
    URL: 'https://github.com/onenoteperpage/mri-docs-v4/content'
    Text: 'Suggest Changes' # edit text
    appendFilePath: true # to append file path to Edit link
---

Using the following batch script from CMD, the process of exporting the DB can be automated. The script will require the `password` following `dbadmin/` to be updated with the correct password for the affected dbadmin account to work.

#### Usage
```cmd
C:\> export-db.cmd CLIENT_ENV RESTORE_DB_TNS
```

```cmd
@echo off

REM Check if both parameters are provided
if "%~2"=="" (
    echo Usage: export-db.cmd ^<CLIENTNAME^> ^<RESTOREDB^>
    exit /b 1
)

REM Get today's date in the format YYYYMMDD
for /f "tokens=1-3 delims=/" %%a in ('date /t') do (
    set "mm=%%a"
    set "dd=%%b"
    set "yy=%%c"
)

REM Remove leading zeros from the day and month
set "mm=%mm:~1%"
set "dd=%dd:~1%"

REM Combine to get today's date in YYYYMMDD format
set "today_date=%yy%%mm%%dd%"

REM Replace CLIENTNAME and RESTOREDB with command-line parameters
set "client_name=%~1"
set "restore_db=%~2"

REM Run expdp command with the replaced values
expdp dbadmin/password@%restore_db% schemas=%client_name% dumpfile=%client_name%_%today_date%_%%U.dmp parallel=4 logfile=%client_name%_%today_date%-expdp.log directory=DATA_PUMP_DIR
```




backup of CBA files
```powershell
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_manii.7z" "E:\Manhattan\versions\Clients\${client}${env}\Manii"
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_usergrids.7z" "\\rewsapac\dfs\iwms\${client}_${env}\user_grids"
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_webapps.7z" "E:\Manhattan\Tomcat\${client}${env}\webapps\${client}${env}"
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_portal.7z" "E:\Manhattan\Tomcat\${client}${env}\webapps\${client}${env}_portal"
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_mailmerge.7z" "\\rewsapac\dfs\iwms\cba9634prod\Filestore\Documents\MailMerge\Templates"
7za a -t7z "E:\Temp\${todayDate}\${client}_${env}_${todayDate}_pentaho-kettle.7z" "E:\Manhattan\versions\Clients\${client}\Pentaho"
```