---
title: IR Upgrade v36 Non-Prod
author: danijel
date: 2022-10-15 11:00:00 +1000
categories: [Upgrade, V36]
tags: [v36, ir, inlandrail, non-prod]
math: true
mermaid: true
image:
  path: /assets/commons/manhattan_logo.png
  width: 800
  height: 467
  alt: Manhattan logo
---

Process to upgrade Inland Rail Non-PROD to v36.

## Requirements

- PowerShell Profile [setup](/posts/init-profile-setup/) completed on each server
- file [`db-exp-imp-functions.ps1`](/downloads/files/powershell-profile-init/db-exp-imp-functions.ps1) in profile root
- file [`vault`](/downloads/files/powershell-profile-init/vault) in profile root

### Servers

List of servers being targeted in this article.

| Server | IP | Domain | VPN | Information |
|:-------|:---|:-------|:----|:------------|
| SYDA-NMH-ODPa | 10.229.5.150 | nonprod | OpenVPN 12.239.11.152 | Oracle Data Pump server |
| SYDA-NMH-APPa | 10.225.27.0 | nonprod | OpenVPN 12.239.11.152 | Manhattan Application Server A |
| SYDA-NMH-APPb | 10.225.58.187 | nonprod | OpenVPN 12.239.11.152 | Manhattan Application Server B |

## Oracle Database Part 1

### Connect and Verify

- Connect to `Data Pump` server _(Oracle Data Pump - ODPa)_ via RDP
- Get `dbadmin` credentials and test the `csql` connection, then exit

```powershell
Get-SqlEnv -c2 dbadmin -c1 syda-nmh-oraa | Set-SqlEnv
csql
Log in as dbadmin onto syda-nmh-oraa

SQL*Plus: Release 12.1.0.2.0 Production on Wed Oct 19 10:59:33 2022

Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Last Successful login time: Tue Oct 18 2022 18:24:01 +11:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production

SQL>exit
```

### Import Functions

- Source `db-exp-imp-function.ps1` file from home directory and list dump files

### Identify Target DMP

- Select the required dump using `Select-String`

```powershell
. ~\db-exp-imp-functions.ps1
List-Dump | Select-String "202210"
```

### Populdate Check-Env

- If not results returned, find the first file in the `S3` bucket _(ie - `s3://rews-syda-dbdump1/IR/inlandrail_prod_20220912-01.dmp`)_
- Clip file name to just name of the first file, replacing the index number with `%U` _(ie - `inlandrail_prod_20220912-%U.dmp`)_

- Populate the `Check-Env` details in notepad with the required values and paste it back into PowerShell prompt

```powershell
connection string : dbadmin/gpazVnAzrlK@syda-nmh-oraa
$env:dmp='inlandrail_prod_20220912-%U.dmp'
$env:client='IR'
$env:src_schema='inlandrail_prod'
$env:tgt_schema='inlandrail_sup'
$env:user_dmp=''
```

**Note:** Import into UAT, being used as an upgrade schema, upgrade shortcuts already created for QGAO. Being used as an upgrade environment. Run the autopatcher. Upgrade from SP11 to SP15, do the migration bits. Then the schema is already sitting there. Then we do the v36 build, GA, SP 1, 2 and 3. Technically we can make use of the same schema at the end of the upgrade. Using these exact steps, we can do IR PROD to IR SUP. When you get to the end of SP3, do an export of IR SUP, and transfer it to S3. Then go to PROD system and import the schema. Everything else is already setup in production. We just get the latest data next week and bring it to non-prod. Instead of doing a straight import, you just drop IR_SUP.

### Download DMP Files

- Verify the amount of files created from the dump _(this can be from S3 or from the system that generated the dump using `List-Dump`)_
- Start the download of the dump files, it doesn't matter which directory this starts from, replacing `2` with the correct number of dump files

```powershell
Download-Dump -Count 2
```

- Status of the data dump can be verified by executing `Transfer-Status` and checking for text `[INFO] The task has finished successfully` for all items
- Files visible by calling `List-Dump`

## Sql Schema

### Generate Schema

- Create the schema by passing the schema name and the target server

```powershell
Create-Schema inlandrail_sup syda-nprod-dbu
```

```sql
CREATE USER "INLANDRAIL_SUP"  PROFILE "DEFAULT"
    IDENTIFIED BY "xxxxxxxxxxx" DEFAULT TABLESPACE INLANDRAIL_SUP
    TEMPORARY TABLESPACE "TEMP"
    ACCOUNT UNLOCK;

grant CREATE SESSION to INLANDRAIL_SUP;
grant RESOURCE  to INLANDRAIL_SUP;
grant CREATE TYPE to INLANDRAIL_SUP;
grant CREATE INDEXTYPE to INLANDRAIL_SUP;
grant CREATE MATERIALIZED VIEW to INLANDRAIL_SUP;
grant CREATE OPERATOR to INLANDRAIL_SUP;
grant CREATE PROCEDURE to INLANDRAIL_SUP;
grant CREATE SEQUENCE to INLANDRAIL_SUP;
grant CREATE SESSION to INLANDRAIL_SUP;
grant CREATE TABLE to INLANDRAIL_SUP;
grant CREATE TRIGGER to INLANDRAIL_SUP;
grant CREATE TYPE to INLANDRAIL_SUP;
grant CREATE VIEW to INLANDRAIL_SUP;
GRANT EXECUTE ON SYS.DBMS_CRYPTO to INLANDRAIL_SUP;
GRANT SELECT ON V$SESSION to INLANDRAIL_SUP;
grant unlimited tablespace to INLANDRAIL_SUP;
```

- Log into `csql` and create a new user tablespace, using the `DEFAULT` value

```powershell
csql
SQL> CREATE TABLESPACE INLANDRAIL_SUP
SQL> exit
```

- Re-run the `Create-Schema` command again and pass the `run` command to execute the entire process

```powershell
Create-Schema inlandrail_sup syda-nprod-dbu run
```

## Generate Import Dump

### Import Dump Files

- Use the `Import-Dump` command to generate the import command _(where `-Parallel` is the number of CPU to use)_

```powershell
Import-Dump -Parallel 2
```

- Check the command is correct for importing the data by reading the `$env:CMD`

```powershell
$env:CMD
```

- If the command is correct, re-run with `iex`

```powershell
iex $env:CMD
```

- The data will begin importing, swap to the Application Server and start configuring there

## Application Server A/B

### Create V36 Environment

- Copy the existing client environment in `adm` and rename to new environment from `E:\manhattan\<uniface_version>\uniface\adm`
  - Version 36::Uniface 10.3 - `E:\manhattan\u103`
  - Version 35::Uniface 9.7 - `E:\manhattan\u9704`
- Copy existing `inlandrail_uat` to `inlandrail_sup`

```powershell
Copy-Item -Path E:\manhattan\u103\uniface\adm\inlandrail_uat -Destination E:\manhattan\u103\uniface\adm\inlandrail_sup -Recurse -Force -Confirm:$false
```

### Replace Global Variables

- Open all the ASN files in [Notepad++](/downloads/notepad-plus-plus.md) ~~as an administrator~~

```powershell
(Get-ChildItem -Path E:\manhattan\u103\uniface\adm\inlandrail_sup -Filter *.asn).FullName | ForEach-Object { Start-Process -FilePath "C:\Program Files\Notepad++\notepad++.exe" }
```

- Search all open documents and replace `inlandrail_uat` with `inlandrail_sup`
- Open the `urouter.asn` file and identify the current port number
  - `$default_net = TCP:+13880|||` on line 2
- Deduct 10 digits from the current port number, this will be assigned the new port number
- Use the following to identiy which port is available to use for this service and prevent errors

```powershell
$i = 13880
do {
    $i = $i-10
} until ((Get-NetTCPConnection -State Listen | Where-Object -FilterScript {$_.LocalPort -like $i}).LocalAddress.Count -lt 1)
Write-Output "New TCP Port: ${i}"
```
- Replace all occurences of the port number `13880` with `13870` across all open files
- Replace all sub-occurences of the port number `TCP:localhost+1388` with `TCP:localhost+1387` across all open files

### Replace SQL Variables

- Open `common.asn` to replace the SQL connection string on `$UROUTER1` and `$UROUTER2`
  - Syntax is `ORA:<server>|<user>|<password>`
  - Details obtain from the `Create-Schema` command run on Oracle Data Pump server

### UServer Exe

- In the `urouter.asn` file, all the references to the `userver_inlandrail_sup.exe` file are not going to exist
- Create the appropriate files by copying the default into the directory and renaming

```powershell
Copy-Item -Path E:\manhattan\u103\common\bin\userver.exe -Destination E:\manhattan\u103\common\bin\userver_inlandrail_sup.exe -Force -Confirm:$false
Copy-Item -Path E:\manhattan\u103\common\bin\userver.exe -Destination E:\manhattan\u103\common\bin\userver_inlandrail_sup_dbg.exe -Force -Confirm:$false
foreach ($i in @("E:\manhattan\u103\common\bin\userver_inlandrail_sup.exe","E:\manhattan\u103\common\bin\userver_inlandrail_sup_dbg.exe"))
{
    if (-not (Test-Path -Path $i)) { Write-Error "File missing: ${i}" -Category InvalidResult }
}
```
### Webroot

- Create archive of requried directory using 7zip
- Rename folder in archive
- Extract archive to current directory
- Process assists with Windows file replication not corrupting data if using 7zip archives instead of copy/paste with rename
- Shortcut is to create an archive copy of the directories, rename them, and then export to the correct places
  - Using the built-in `7za` function from the PowerShell profile will provide this functionality out-of-box
  - New 7z archive is created, folder inside renamed on second pass
  - Third pass extracts it to the new directory as required

```powershell
7za a -t7 E:\temp\inlandrail_sup.7z E:\manhattan\tomcat\Tomcat_IWMS\webapps\inlandrail_uat\
7za rn E:\temp\inlandrail_sup.7z inlandrail_uat inlandrail_sup
7za x E:\temp\inlandrail_sup.7z -oE:\manhattan\tomcat\Tomcat_IWMS\webapps
Remove-Item -Path E:\temp\inlandrail_sup.7z -Force -Confirm:$false
```

**Note:** Do not use the `-aoa` switch to overwrite, we need to see errors being passed from the activity

### web.xml

- Rebase will overwrite the important changes we edit in the `web.xml` file and so a backup is created
- Replace all values of `inlandrail_uat` and `&lt;port_number$gt;` in the `E:\manhattan\tomcat\Tomcat_IWMS\webapps\inlandrail_sup\WEB-INF\web.xml` file

```powershell
$fPath = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\inlandrail_sup\WEB-INF\web.xml"

$srcString = Get-Content -Path $fPath -Raw
$output = [Regex]::Replace($srcString,[regex]::Escape("inlandrail_uat"),"inlandrail_sup",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
$output | Set-Content -Path $fPath -Force -Confirm:$false

$srcString = Get-Content -Path $fPath -Raw
$output = [Regex]::Replace($srcString,[regex]::Escape("13880"),"13870",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
$output | Set-Content -Path $fPath -Force -Confirm:$false
```

- Backup the file _(preventing overwrite with rebase)_

```powershell
Copy-Item -Path $fPath -Destination (Join-Path -Path (Split-Path -Path $fPath -Parent) -ChildPath ((Split-Path -Path $fPath -Leaf) + ".bak"))
```

### manhattan.htm

- Replace value `inlandrail_uat` with `inlandrail_sup` using regex

```powershell
$fPath = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\inlandrail_sup\manhattan.htm"

$srcString = Get-Content -Path $fPath -Raw
$output = [Regex]::Replace($srcString,[regex]::Escape("inlandrail_uat"),"inlandrail_sup",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
$output | Set-Content -Path $fPath -Force -Confirm:$false
```

- Backup the file _(preventing overwrite with rebase)_

```powershell
Copy-Item -Path $fPath -Destination (Join-Path -Path (Split-Path -Path $fPath -Parent) -ChildPath ((Split-Path -Path $fPath -Leaf) + ".bak"))
```

### pathConstants.js

- Replace value `inlandrail_uat` with `inlandrail_sup` using regex
- Set value of `pathConstants.js` to value and escape replace through document

```powershell
$fPath = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\inlandrail_sup\generic\jscript\constants\pathConstants.js"
$srcString = Get-Content -Path $fPath -Raw
$output = [Regex]::Replace($srcString,[regex]::Escape("inlandrail_uat"),"inlandrail_sup",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
$output | Set-Content -Path $fPath -Force -Confirm:$false
```

### Manii

- Each `manii` is located in the `E:\manhattan\forms` directory and exists for each client and env
- Shortcut is to create a 7zip archive of the directory and rename in-place then export out to current directory
- Create a duplicate of `inlandrail_uat` as `inlandrail_sup` in the archive then in-place deploy

```powershell
7za a -t7 E:\temp\manii_inlandrail_sup.7z E:\manhattan\forms\manii_inlandrail_uat\
7za rn E:\temp\manii_inlandrail_sup.7z inlandrail_uat inlandrail_sup
7za x E:\temp\manii_inlandrail_sup.7z -o E:\manhattan\forms
Remove-Item -Path E:\temp\manii_inlandrail_sup.7z -Force -Confirm:$false
```

### Register Urouter Service

- Use the logs template to create new logs directory

```powershell
Copy-Item -Path \\syda-n-fsx\share\IWMS\manhattan\logs\_template -Destination \\syda-n-fsx\share\IWMS\manhattan\logs\inlandrail_sup -Recurse -Force -Confirm:$false
```

- Remaining command required to be executed from Admin PowerShell prompt

```powershell
Start-Process powershell -Verb RunAs
```

- Find the existing Urouter services and ensure the target environment is not currently `Running` or `Stopped`

```powershell
Get-Service "*urouter*"

Status   Name               DisplayName
------   ----               -----------
Stopped  Uniface9 URouter   Uniface9 URouter (E:\manhattan\u970...
Running  urouter_ags_eng    urouter_ags_eng
Running  urouter_ags_sup    urouter_ags_sup
Running  urouter_ags_uat    urouter_ags_uat
Running  urouter_cba_uat2   urouter_cba_uat2
Running  urouter_cba_uat3   urouter_cba_uat3
Running  urouter_inlandr... urouter_inlandrail_sup
Running  urouter_inlandr... urouter_inlandrail_uat
Running  urouter_mqb_poc    urouter_mqb_poc
Running  urouter_qgao_dev   urouter_qgao_dev
Running  urouter_qgao_sup   urouter_qgao_sup
Running  urouter_qgao_trn   urouter_qgao_trn
Running  urouter_qgao_uat   urouter_qgao_uat
Running  urouter_qgao_upg   urouter_qgao_upg
Running  urouter_u9704      urouter_u9704
```

- Register the Urouter service for the new environment
- Start the service via Windows `Start-Service` command

```powershell
E:\manhattan\u103\common\bin\urouter.exe /install=urouter_inlandrail_sup /asn="E:\manhattan\u103\uniface\adm\inlandrail_sup\urouter.asn"
Get-Service -Name "urouter_inlandrail_sup" | Start-Service
if (-not(Get-Service -Name urouter_inlandrail_sup | Where-Object -FilterScript {$_.Status -like 'Running'})) { Write-Output "Error: Serivce not running -> urouter_inlandrail_sup" }
```

- If the service does not start running, verify the TCP port is not in use by another application using
- Remove the Urouter service
- Update all the ASN files with the correct port and port-ranges used
- Create a new Urouter service and start it again

```powershell
# Verify the TCP port is not in use
Get-NetTCPConnection -State Listen | Where-Object -FilterScript {$_.LocalPort -like 18870}

# Remove the newly created Urouter service if a match is found
E:\manhattan\u103\common\bin\urouter.exe /remove=urouter_inlandrail_sup

# Update all the ASN files
<# update using instructions above #>

# Create and start the Urtouer service again
E:\manhattan\u103\common\bin\urouter.exe /install=urouter_inlandrail_sup /asn="E:\manhattan\u103\uniface\adm\inlandrail_sup\urouter.asn"
Get-Service -Name "urouter_inlandrail_sup" | Start-Service
if (-not(Get-Service -Name urouter_inlandrail_sup | Where-Object -FilterScript {$_.Status -like 'Running'})) { Write-Output "Error: Serivce not running -> urouter_inlandrail_sup" }
```

## Oracle Database Part 2

### Read Log for Errors

- Obtain a list of the files in the `datapump/` directory from the RDS
- From the output, read the log file name to a file using `Read-DPFile`
- Output is the current working directory

```powershell
List-Dump
List-Dump | Select-String inlandrail
...
Read-DPFile inlandrail_prod-20220912-202210121144-imp.log | Out-File inlandrail_prod-20220912-202210121144-imp.log
```

- Skim through the log file to make sure there are no critical errors
- Many of the errors can be ignored
- Capture all the `ORA-xxxxx` error codes to a log and the result to build a db

### Setup Shortcuts Directory

- Shortcuts are specific to each environment and client
- All stem from a template directory
- Start by declaring the source, target and copy the files recursively

```powershell
$srcPath = "E:\manhattan\shortcuts\inlandrail_uat"
$destPath = "E:\manhattan\shortcuts\inlandrail_puff"
Copy-Item -Path $srcPath -Destination $destPath -Recurse -Force -Confirm:$false
```

- Create a WShell object to manage the shortcut files
- Replace all the matching values for the target on each `.lnk` file in the target directory

```powershell
$origArgs = "inlandrail_uat"
$updateArgs = "inlandrail_puff"

$obj = New-Object -ComObject WScript.Shell

$files = Get-ChildItem -Path $destPath -Filter *.lnk | Select-Object -ExpandProperty FullName
foreach ($file in $files)
{
    $link = $obj.CreateShortcut($file)
    $newLinkArgs = $link.Arguments -replace $origArgs,$updateArgs
    $link.Arguments = $newLinkArgs
    $link.Save()
}
```

### Test Db via common.asn

- When the Tomcat service runs any queries that require db access, Tomcat will use the `common.asn` file to direct queries
- Open the `common.asn` file and comment out the `$UROUTER1` and `$UROUTER2` using semi colon character
- Copy the lines from a working `common.asn` file _(eg - inlandrail_uat)_
- The `common.asn` file is located in `E:\manhattan\u102\uniface\adm\inlandrail_<env>\common.asn`

### Validate Portal Access

- Using `Get-SqlEnv` select the fieldman user account matching username/password as used in the `common.asn` above
- Log into portal and verify login passes
- Remove the added lines to the `common.asn` file now that the testing is complete

## Preparation for Auto Patcher

### Update Sql Connection String

- Standard process is to create an upgrade environment for the client _(upg)_
- Set everything up to point to that upgrade environment
- Run autopatcher against that environment
- Because we already have QGAO upgrade environment, we can use that and not required to recreate the environment
- The file extension `.patchconfig` specifies the patching configuration used by the `idf_common.asn` file to patch the schema
- All configuration is in this file
- Edit the `data.asn` file and replace the connection strings with the current connection strings from `Get-SqlEnv` command output

```
[PATHS]
$UROUTER1			ORA:syda-nprod-dbu|inlandrail_<env>|xxxxxxxxxxx
$UROUTER2			ORA:syda-nprod-dbu|inlandrail_<env>|xxxxxxxxxxx
```

### Signature Files

- The `SIGS` directory is located in the current patch service pack directory
- Open the path `C:\temp\v35-releases` and find the latest Service Pack _(9.7.35-SP15)_
- Navigate to the `PATCHSOFTWARE\SIGS` sub-directory

```powershell
C:\temp\v35-releases\9.7.35-SP15\PATCHSOFTWARE\SIGS
```

- These files will need to go into `08. XML` shortcut directory after removing all files found there

```powershell
# remove existing XML files from target path
Get-ChildItem -Path \\syda-n-fs\iwms\manhattan\xml\qgao_upg -Filter *.xml -File | ForEach-Object { Remove-Item -Path $_.FullName -Force -Confirm:$false }

# replace with current SIGS files
Get-ChildItem -Path C:\temp\v35-releases\9.7.35-SP15\PATCHSOFTWARE\SIGS -Filter *.xml -File | ForEach-Object { Copy-Item -Path $_.FullName -Destination \\syda-n-fs\iwms\manhattan\xml\qgao_upg\ -Force -Confirm:$false }
```

- Open the `01. IDF` shortcut as user _(do not use admin)_
- Execute the command `/rma /imp *.xml` to import the XML files from the upgrade folder on FSX
- Close the resulting window

### Manii Files

- The `Manii` directory is located in the current patch service pack directory
- Open the path `C:\temp\v35-releases` and find the latest Service Pack _(9.7.35-SP15)_
- Navigate to the `PATCHSOFTWARE\Manii` sub-directory

```powershell
C:\temp\v35-releases\9.7.35-SP15\PATCHSOFTWARE\Manii
```

- These files will need to go into `00. Manii` shortcut replacing any files that exist in the target path being overwritten _(average 20 files)_
- **Note:** Needs to be run in the admin console

```powershell
# copy and replace all files recursively to target from source
Copy-Item -Path C:\temp\v35-releases\9.7.35-SP15\PATCHSOFTWARE\Manii\ -Destination E:\manhattan\forms\manii_qgao_upg -Recurse -Force -Confirm:$false
```

## Auto Patcher

### Loading Defaults

- Open shortcut `01. Autopatcher` _(as an admin)_ and click on `Load Config` button
- Navigate to the `QGAO_UPG` directory and select the `inlandrail_upg.patchconfig` file
- Update the schema name _(Username)_ and Password in the middle section using the correct username and password for the environment
- Rename the `Unique Area Name` at the top of the window
- Click on `Validate Config` button to verify settings
- Click on `Save Config` button as filename `inlandrail_sup.patchconfig` file in same directory

### Execute the Row Counts SQL

- Change directory to `E:\upgrade\inlandrail` in PowerShell prompt
- Verify file `row_counts.sql` exists
- Set the Sql environment variables

```powershell
# query and set sql connection string
Get-SqlEnv -c2 inlandrail_sup -c1 syda-nprod-dbu | Set-SqlEnv

# verify the connection string is valid
Check-Env

# drop into sql prompt
sql
```

- From the sql prompt, import the file

```sql
SQL> @row_counts.sql
```

- Sql prompt will drop the connection
- File remaining will be `upgrade_row_counts.txt` which should be renamed to identify the env and client it's related to

```powershell
Rename-Item -Path .\upgrade_row_counts.txt -NewName .\inlandrail_sup_pre-upgrade_row_counts.txt -Force
```

###  Apply Uniface Patch

- Navigate back to the Uniface Patch tool
- Set the `Patch Folder` to the first patch directory _(Service Pack directory)_ of `C:\temp\v35-releases\9.7.35-SP11`
- Tab out of the field to update the patching tool
- Click `Is this the first package` option
- Click on `Apply Patch` button to bring up patching interface
- Verify the `Area`, `Patch` and `DB` values are correct

| Area | Patch | DB |
|:-----|:------|:---|
| INLANDRAIL_UPG | 9.7.35-SP11 | ORA |

- Click on `Next` button a few times to ensure the patches apply
- Select `Use VBS` and `Auto Step` after a few passes and click on `Next` button to auto-process
- Everytime the patching stops on `README` function, click on `Next` button to continue
- Close the Auto Patcher window and confirm to exit
- Update the path to point to the next upgrade in the path _(SP11 becomes SP12)_ and tab out of field to update
- Do not need to re-validate
- Uncheck `Is this the first package` option
- Click `Apply Patch` button
- Loop through steps until complete
  -  Select `Use VBS` and `Auto Step` after a few passes and click on `Next` button to auto-process
  - Everytime the patching stops on `README` function, click on `Next` button to continue
  - Close the Auto Patcher window and confirm to exit
- Close the Autopatcher tool so it does not have a write-lock on any files to be updated in manii rebase

## Rebase Manii

### 9.7.35-SP15_Manii.7z

- The purpose of rebase is to overwrite the Manii, not everything, but the files that we are targeting will be targeted by the provided 7zip file
- Copy the file `9.7.35-SP15_Manii.7z` to `E:\manhattan\forms` directory
- Rename the containing folder in the archive from `Manii` to `manii_qgao_upg`
- Extract over the current directory and replace the files

```powershell
# copy the 7zip file to the E drive
Copy-Item -Path C:\temp\v35-releases\9.7.35-SP15_Manii.7z -Destination E:\manhattan\forms\9.7.35-SP15_Manii.7z -Force -Confirm:$false

# rename the folder in the archive
7za rn E:\manhattan\forms\9.7.35-SP15_Manii.7z Manii manii_qgao_upg

# extract contents over the top of the existing files/folders for manii 
7za x E:\manhattan\forms\9.7.35-SP15_Manii.7z -oE:\manhattan\forms -aoa

# remove the 7zip file we copied across, it wastes space
Remove-Item -Path E:\manhattan\forms\9.7.35-SP15_Manii.7z -Force -Confirm:$false
```

### 9.7.35-SP15_XML.7z

- The v35 release of XML files needs to be injected to the `08. XML` shortcut directory
- Remove all files in the target directory first
- Extract the contents of the 7zip file across

```powershell
# remove all XML files already in 08. XML
Remove-Item -Path \\syda-n-fs\iwms\manhattan\xml\qgao_upg\*.xml -Force -Confirm:$false

# export 7zip XML 
7za x C:\temp\v35-releases\9.7.35-SP15_XML.7z -o\\syda-n-fs\iwms\manhattan\xml\qgao_upg -aoa
```

- Open the `01. IDF` shortcut as user _(do not use admin)_
- Execute the command `/rma /imp *.xml` to import the XML files from the upgrade folder on FSX
- Wait approximately 15-20 minutes
- Close the resulting window
- Once complete, run the command to generate the `client_usergrid.xml` file

### Export Uniface 9 Source

- **Note:** Rebase on SP14 on maii's is required first to complete _(previous step)_
- Output file `client_usergrid.xml` is created in predefined `08. XML` folder, then copied to `C:\temp\Export Uniface 9 Source\client_usergrid.xml`
- Open the `01. IDF` shortcut as user _(do not use admin)_
- Execute the command `/rma /tst CSUTPCLIUGRID ` to export the client grid XML file
- Resulting window will close on it's own
- File can be found at `\\syda-n-fs\iwms\manhattan\xml\qgao_upg\client_usergrid.xml`

### Create EDC Records

- Open the `01. IDF` shortcut as user _(run as administrator)_
- Execute the command `/rma /tst csutpcliedc` to generate the `EDC` content
- Open the `00. Manii` shortcut and open the `edc` directory to verify the newly created files

## Install V36 Base Form

- Base Form is an internal name for a ZIP/7z archive with the version initial release
- Find latest production manii ZIP file in `E:\manhattan\forms` directory with prefix `stcfg_prod_manii_` on file identified as `stcfg_prod_manii_2022-02-14.zip` in this instance
- Expand the contents of the ZIP file into the `E:\manhattan\forms\manii_inlandrail_sup` directory with overwrite enabled
- Copy the manii from `E:\manhattan\forms\manii_qgao_upg` into the `E:\manhattan\forms\manii_inlandrail_sup` directory with overwrite enabled

```powershell
# extract zip file and overwrite
7za x E:\manhattan\forms\stcfg_prod_manii_2022-02-14.zip -oE:\manhattan\forms\manii_inlandrail_sup -aoa

# copy from qgao_upg and overwrite
Copy-Item -Path E:\manhattan\forms\manii_qgao_upg -Destination E:\manhattan\forms\manii_inlandrail_sup -Recurse -Force -Confirm:$false
```

### Test 01. IDF

- Open the `01. IDF` shortcut for `inlandrail_sup` directory at `E:\manhattan\shortcuts\inlandrail_sup`
- If error occures, rename the `.ini` file at `E:\manhattan\u103\uniface\adm\inlandrail_sup\inlandrail_uat.ini` to `inlandrail_sup.ini` and re-launch

```powershell
if (Test-Path -Path E:\manhattan\u103\uniface\adm\inlandrail_sup\inlandrail_uat.ini)
{
    Rename-Item -Path E:\manhattan\u103\uniface\adm\inlandrail_sup\inlandrail_uat.ini -NewName inlandrail_sup.ini -Force -Confirm:$false
}
```

- Load the `.patchconfig` file `E:\manhattan\u103\uniface\adm\inlandrail_sup\others\inlandrail_uat.patchconfig` in Autopatcher
- Change all references of `inlandrail_uat` to `inlandrail_sup` in all places, retaining case sensitivity
- Update the schema name _(Username)_ and Password in the middle section using the correct username and password for the environment
- Rename the `Unique Area Name` at the top of the window
- Click on `Validate Config` button to verify settings
- Click on `Save Config` button as filename `inlandrail_sup.patchconfig` file in `E:\manhattan\u103\uniface\adm\inlandrail_sup\others` directory
- Select a patch folder _(without patching)_ to validate the `.patchconfig` is working
- Paste value `C:\temp\9.7.36\36-BUILDS` into the `Patch Folder` path and tab out
- Click on `Apply Patch` button to validate the Autopatcher is able to execute the pre-requisite tasks and validate all configuration elements
- This verifies all the components required are valid/found

## Setup Uniface 10 Source

### v35-36 Upgrade (Drop Tables)

- Navigate to `E:\upgrade\v35-36` directory
- File to be executed is `drop_repository.txt` in `SqlTools` in `C:\tools\sqltools\SQLTools.exe`
- Pop up windows may appear
  - Encrypted data corrupt, click `OK` button
  - Terminated snapshot, click `No` button
  - Clear crash status, click `Yes` button
- Click on `Connect` button _(power plug, first icon second row)_

![Desktop View](/assets/img/sqltools_icons/connect.PNG){: width="36" height="35" }
_SQL Tools Connect_

- Populate the connection window with the connection details
- Click `Test` button to validate

 ![Desktop View](/assets/img/sqltools_icons/connection_window.png){: width="733" height="406" }

| Tag | User | Password | Bypass tsnames.ora | Host | TCP Port | SID |
|:----|:-----|:---------|:-------------------|:-----|:---------|:----|
| inlandrail_sup | inlandrail_sup | xxxxxxxxx | Ticked | syda-nprod-dbu | 1521 | ORCL |

- Once validated, click `Save` button
- Click `Connect` button
- Open the `drop_repository.txt` file from `E:\upgrade\v35-36` directory
- Click on `Execute Script` button in tool bar

![Desktop View](/assets/img/sqltools_icons/execute_script.PNG){: width="29" height="31" }
_SQL Tools Execute Script_

### v35-v36 Upgrade (Create Tables)

- In SQLTools open the `umeta_ora_dict_createtable2.txt` file from `E:\upgrade\v35-36` directory
- Click on `Execute Script` button in tool bar
- Click on `Disconnect` button in tool bar to commit changes and disconnect from server

![Desktop View](/assets/img/sqltools_icons/disconnect.PNG){: width="29 height="29" }

### Import XML

- Verify the path on the `01. IDF` shortcut is pointing to the right set of folders
  - `E:\manhattan\u103\common\bin\idf.exe /rma /asn=E:\manhattan\u103\uniface\adm\inlandrail_sup\idf.asm /ini=E:\manhattan\u103\uniface\adm\inlandrail_sup\inlandrail_sup.ini ?`
  - Re-create the shortcuts if they are incorrectly pointing to targets _(see steps above)_
- Open the `01. IDF` shortcut as user _(do not use admin)_
- Execute the command `/imp imp E:\upgrade\v35-v36\upgrade_exports\umeta.xml` to import the umeta XML file
- Close the resulting window

### Overwrite v36 edc with v35

- Copy the contents of the v35 edc directory over top of the v36 edc directory
- This takes some time to process
- _In video at 4hr 40min, John mentioned this is not required?_

```powershell
Copy-Item -Path E:\manhattan\forms\manii_inlandrail_upg\edc -Destination E:\manhattan\forms\manii_inlandrail_sup\edc -Recurse -Force -Confirm:$false
```

Video stopped at 4hr 40min to sleep