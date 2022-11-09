---
title: BGIS V36 Upgrade
author: danijel
date: 2022-11-01 11:00:00 +1000
categories: [Reference, Server Config]
tags: [bgis]
math: true
mermaid: true
image:
  path: /assets/img/logos/bgis.png
  width: 888
  height: 213
  alt: BGIS Logo
---

Process to upgrade BGIS v35 (legacy prod) to v36 (new prod) using in-situ upgrade per Veera's instructions.

## Connection Info

| Server | IP Address | Service |
|:-------|:-----------|:--------|
| NWEB | _?_ | Non-Prod Web |
| NWEB2 | _?_ | Non-Prod Web 2 |
| NAPP | 172.16.1.100 | Non-Prod Application |
| NSCH | 172.16.1.101 | Non-Prod Scheduler |
| vPRODWEB01 | 192.168.10.20 | Prod Web |
| vPRODAPP01 | 172.16.1.120 | Prod App 1 |
| vPRODAPP02 | 172.16.1.121 | Prod App 2 |
| vPRODAPP03 | 172.16.1.122 | Prod App 3 |
| vPRODSC01 | 172.16.1.123 | Prod Scheduler 1 |
| vPRODSC02 | 172.16.1.124 | Prod Scheduler 2 |

**VPN Service:** FortiClient VPN provided by BGIS

## Background Information

- Sheet _Iteration 1 TRN Refresh Rollback_ includes steps to switch back to v35 on the Training environment. This was not used as UAT4 was rolled back to v35 whilst Veera was on holidays.
- Some issues were reporting in UAT4 which could not be identified at first and then identified that UAT4-v35 was upgraded to UAT4-v36 and then brought back UAT4-v35.
- TRN environment was refreshed with the v36 data from UAT4 and tested. This was switched back to TRN-v35 allowing it to be upgraded again.

### services.msc

> Where a service has **O19** in the name, is v35 after the Oracle 19 upgrade. Otherwise is v35 prior to Oracle 19.
{: .prompt-info }

> Services with **Manual** in the Startup Type allow us to swap between active environments for BGIS.
{: .prompt-info }

| Name | Status | Startup Type | Information |
|:-----|:-------|:-------------|:------------|
| urtouer_bgis_trn | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | Manual | Training v36 |
| urouter_bgis_uat04 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | Disabled | UAT04 v36 |
| urtouer_bgis_uat06 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | Automatic | UAT06 v36 |
| Apache Tomcat 7.0 BGISDEMO | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISDEV | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISPP | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISTRN | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISUAT01 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISUAT04 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISUAT05 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Apache Tomcat 7.0 BGISUAT06 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISDEMO | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISDEMO O19 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISDEV | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISDEV O19 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISPP | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISPP O19 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISTRN | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISTRN O19 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISUAT01 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISUAT01 O19 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISUAT04 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISUAT04 O19 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISUAT05 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISUAT05 O19 | <span style="color:white" class="badge rounded-pill bg-success">Running</span> | x | Unknown |
| Uniface Urouter BGISUAT06 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |
| Uniface Urouter BGISUAT06 O19 | <span style="color:white" class="badge rounded-pill bg-danger">Disabled</span> | x | Unknown |

### File Structure

V36 files are stored at `D:\Manhattan\versions\bgis_<trn|uat04|uat06>`

V35 files are stored at `D:\Manhattan\versions\BGIS<DEMO|DEV|PP|TRN|UAT01|UAT04|UAT05|UAT06|UPG>`

Tomcat files are stored under each environment by name, then subdivided using underscores to differentiate the folder paths. Tomcat base path is `D:\Manhattan\tomcat\BGIS<DEMO|DEV|PP|TRN|UAT01|UAT04|UAT05|UAT06>\webapps\`. Under this, there are folders relational to their version. The v35 folders are `bgis_uat04` and `bgis_uat04_portal` whereas the v36 folders are `bgisuat04` and `bgisuat04_portal` instead. This is for the APIs used to connect without changing URL.

### Links

- **UAT04-v35:** [https://test.apac.bgis.com/bgisuat04/manhattan.htm](https://test.apac.bgis.com/bgisuat04/manhattan.htm)
- **UAT04-v36:** [https://test.apac.bgis.com/bgis_uat04/manhattan.htm](https://test.apac.bgis.com/bgis_uat04/manhattan.htm) _(this would not work for the API, and be changed prior to release to production)_
- ***SharePoint:** [https://mrisoftware.sharepoint.com/teams/ManhattanAPACUC/APAC%20Clients/Forms/AllItems.aspx](https://mrisoftware.sharepoint.com/teams/ManhattanAPACUC/APAC%20Clients/Forms/AllItems.aspx)

### SQLPlus CLI

Connection string is made up of _schema\_user_, _password_, and _database_ and can be found in the `<environ>.patchconfig` files.

```sh
#> sqlplus <schema_user>/<password>@server
```

## 1: Rename Manhattan.htm to disable SSO access

_Rename Manhattan.htm to disable SSO access (Required only in Production)_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

## 2: Stop Services

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Log into the PAPP11 server and stop the services for Tomcat and Urouter

## 2a: Disable Schedulers in Production

<button type="button" class="btn btn-secondary position-relative">Veera</button>

> There is no _schedmon_ running in BGIS at this time
{: .prompt-info }

- Log into PSCH11 server to disable items under Task Scheduler
- v35 serivces do not have underscore in their name
- v36 have underscore and no spaces in their name

### Items to Disable

- BGISx BATCHPOST01
- BGISx BATCHPOST02
- BGISx BATCHRUN
- BGISx EMAILNOTIF
- BGISx SCHEDULE
- BGISx WOCOMPLETE
- BGISx WORKORDERS

## 3: Capture and disable triggers in Production

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Open **SQLTools** and connect to BGISUAT04 environment
- Open **Object List** window by pressing <kbd>ALT + 3</kbd> keys
- Select all items in list with `CTRL + A` and then right-click and select **Disable** on menu drop down

![Desktop View](/assets/img/2022-11-01/20221101-03-01.PNG){: width="583" height="547" }
_Disable Triggers_


## 4: Execute pre delete Row Count on Upgrade schema

<button type="button" class="btn btn-secondary position-relative">Veera</button>

_Execute pre delete Row Count on Upgrade schema to pre\_delete_row_counts.txt, and on Reference schema to reference\_row\_counts.txt and check these match._

- Upgrade folder at `D:\Manhattan\upgrade` contains some useful files placed there by Veera
- File `row_counts.sql` can be found in this directory
- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\Manhattan\upgrade\row_counts.sql"
```

## 5: Rename and Copy the Row Counts to Sharepoint

_Rename and copy the row counts to sharepoint folders_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- The file `upgrade_row_counts.txt` will be generated under in the directory the SQLPlus command prompt was started from _(ie - the `C:\Users\<username>` directory)_
- Rename the file to include the `pre_` prefix
- Copy it to somewhere locally, then upload it to SharePoint at `APAC Clients > BGIS > v36 Upgrade > Upgrade Documentation > 05 - Production Upgrade`

## 6: Run SQL script

_Run SQL script "D:\Manhattan\upgrade\v35_autopatch\combined\nutucs_contact.txt"_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\Manhattan\upgrade\v35_autopatch\combined\nutucs_contact.txt"
```

## 7: Run SQL script

_Run SQL script "D:\Manhattan\upgrade\sql\CREATE_CURRATTEMP_INTERFACE_ORA.txt"_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\Manhattan\upgrade\sql\CREATE_CURRATTEMP_INTERFACE_ORA.txt"
```

## 8: If no row in STGFPLINELEASE table

_If no row in STGFPLINELEASE table, add a SKIP for XMLDATAOUT & XMLDATAIN for SPR 90259_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Open **SQLTools** and connect to BGISUAT04 environment
- Run the following command to find if any data returns from table `STGFPLINELEASE`

```sql
SELECT * FROM STGFPLINELEASE
```

- If no data returns, when using `D:\Manhattan\upgrade\v35_autopatch` find the `autopatch` file and add the **SKIP** instruction _(this has been pre-organised)_ 
- This will result in an error if not managed now, but not terminating, when applying the SPRs

## 9: TRUNCATE TABLE FINRPTSTAT

_TRUNCATE TABLE FINRPTSTAT and import file given by Neil using IDF_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Execute command

```sql
SQL> TRUNCATE TABLE FINRPTSTAT;

Table truncated.
```

- Import the file provided by Neil using the **02. IDF** tool, using the v35 version `D:\Manhattan\Shortcuts\BGISUAT04\02. IDF.lnk` as admin
- Command `/rma /imp "D:\Manhattan\upgrade\finrptstat-replacementdata.xml"`
- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Scroll to the bottom of the text file and verify no errors

![Desktop View](/assets/img/2022-11-01/20221101-09-01.PNG){: width="882" height="483" }
_IDF Import_

## 10: Update autopatcher

_Update autopatcher and Launch the Autopatcher (apply V35-SP4 to V35-SP15)_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

> **BGIS** is aka **BJC** in the _Client Specific_ area of Patching
{: .prompt-warning }

- In the Shortcuts for UAT04 launch the **01. Autopatcher** application as admin
- Open the patchconfig file `D:\Manhattan\version\BGISUAT04\BGISUAT04.patchconfig`
- Untick all the options next to _Manii Folder_ and _Webroot Folder_ as these will be rebased later

![Desktop View](/assets/img/2022-11-01/20221101-10-01.PNG){: width="609" height="245" }
_IDF Import_

- Copy the autopatch directory `D:\Manhattan\upgrade\v35_autopatch\combined` _(where file `sequence_ora.txt` is located)_ and put into the _Patch Folder_ path, then tab out
- Tick the **BJC** in Client Specific area
- Start patching using `Use VBS` and `Auto Step` options
- If error occurs, check the **Overwrite Newer** option then _Apply Patch_ again

## 11: Rebase the environment with V35-SP15

_Rebase the environment with V35-SP15 - manii and XML only_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Copy the `Manii` folder from `D:\Manhattan\upgrade\9.7.35-SP15_Manii\Manii` into `D:\Manhattan\versions\BGISUAT04`

```powershell
Copy-Item -Path "D:\Manhattan\upgrade\9.7.35-SP15_Manii\Manii" -Destination "D:\Manhattan\versions\BGISUAT04\" -Recurse -Container
```

- Open **SQLTools** and connect to BGISUAT04 environment
- Run the following SQL command as schema user to clear ULANA

```sql
DELETE FROM ulana WHERE u_var IN ('UDTD','USERVICE');
DELETE FROM oulana WHERE u_var IN ('UDTD','USERVICE');
DELETE FROM uobj WHERE uclabel!='U_FORMATS';
DELETE FROM ouobj WHERE uclabel!='U_FORMATS';
COMMIT;
```

- Open the **02. IDF** tool as admin
- Import the ULANA rebase XML file

```sh
/rma /imp D:\Manhattan\upgrade\9.7.35-SP15_XML\*.xml
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file

## 12: Swap the prepared v35 SP15 ASNs

_Swap the prepared v35 SP15 ASNs (files, common and urouter)_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

> Leave the original files with the _sp15\__ prefix in-place
{: .prompt-info }

- Navigate to ASN folder at `D:\Manhattan\uniface9705\uniface\adm\clients\BGISUAT04`
- Create copies of `sp15_common.asn` and `sp15_files.asn` and rename them to `common.asn` and `files.asn` respectively
- Nagivate to `D:\Manhattan\uniface9705\common\adm`
- Create copy of `sp15_urouter_bgisuat04.asn` and rename to `urtouer_bgisuat04.asn` in-place

## 13: Export Uniface 9 Source

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Open the **02. IDF** tool as admin
- Execute command

```sh
/rma /tst CSUTPCLIUGRID
```

- Output file `client_usergrid.xml` is in predefined XML folder _(ie - `D:\Manhattan\XML\BGISUAT04`)_
- Copy it to somewhere locally, then upload it to SharePoint at `APAC Clients > BGIS > v36 Upgrade > Upgrade Documentation > 05 - Production Upgrade`

## 14: Create EDC records

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Create the folder `D:\Manhattan\versions\BGISUAT04\Manii\edc`

```powershell
New-Item -Path D:\Manhattan\versions\BGISUAT04\Manii\edc -Force -Confirm:$false
```

- Open the **02. IDF** tool as admin
- Execute command

```sh
/rma /tst csutpcliedc
```

- Output file in the `D:\Manhattan\versions\BGISUAT04\Manii\edc` folder
- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file

## 15: Setup Uniface 10 Source

<button type="button" class="btn btn-secondary position-relative">Veera</button>

> RUN UNIFACE 10 FROM HERE ON
{: .prompt-danger }

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Load the required SQL file

```sql
SQL> @"D:\manhattan\upgrade\sql\1drop_repository.sql"
```

## 16: Create the Uniface Repository Tables 

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Load the required SQL file

```sql
SQL> @"D:\manhattan\upgrade\sql\2umeta_ora_dict_createtable2.sql"
```

## 17: Create the Manii / Webapps structure

_Create the Manii / Webapps structure from the v36-Builds (Rebase) (Take UAT06 manii)_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Copy the following folder and paste into UAT04 `D:\Manhattan\upgrade\36-SP3_Manii\manii`
- Retain the old Manii folder with _old\__ prefix

```powershell
Rename-Item -Path D:\Manhattan\versions\bgis_uat04\manii -NewName old_manii
Copy-Item -Path D:\Manhattan\upgrade\36-SP3_Manii\manii -Destination D:\Manhattan\versions\bgis_uat04\ -Recurse -Container
```

- Copy the following folders and paste them into webroot `D:\Manhattan\upgrade\36-SP3_Webroot\<bgisuat04|bgisuat04_portal>`

```powershell
Copy-Item -Path "D:\Manhattan\upgrade\36-SP3_Webroot\bgisuat04" -Destination "D:\Manhattan\tomcat\BGISUAT04\webapps\" -Recurse -Container
COpy-Item -Path "D:\Manhattan\upgrade\36-SP3_Webroot\bgisuat04_portal" -Destination "D:\Manhattan\tomcat\BGISUAT04\webapps\" -Recurse -Container
```

- Copy over the _EDC_ folder created earlier from the v35 area

```powershell
Copy-Item -Path "D:\Manhattan\version\BGISUAT04\Manii\edc" -Destination "D:\M anhattan\version\bgis_uat04\manii\" -Recurse -Container -Force -Confirm:$false
```

If the webroot is copied from any other environment, do the following additional steps:
- Update web.xml (uniface port number, webappurls & UST names)
- Copy over manhattan.htm and sso_logout.htm from D:\Manhattan\tomcat\BGISTRN\webapps\bgistrn
- Update web.xml under portal (uniface port number, webappurls & UST names)
- Update pathConstants.js
- Update api.json

```powershell
Write-Output "Update web.xml"
Copy-Item -Path D:\Manhattan\tomcat\BGISUAT04\webapps\old_bgisuat04\WEB-INF\web.xml -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04\WEB-INF\web.xml -Force -Confirm:$false

Write-Output "Copy over manhattan.htm and sso_logout.htm"
Copy-Item -Path D:\Manhattan\tomcat\BGISTRN\webapps\bgistrn\manhattan.htm -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04\manhattan.htm -Force -Confirm:$false
Copy-Item -Path D:\Manhattan\tomcat\BGISTRN\webapps\bgistrn\sso_logout.htm -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04\sso_logout.htm -Force -Confirm:$false

Write-Output "Update web.xml under portal"
Copy-Item -Path D:\Manhattan\tomcat\BGISUAT04\webapps\old_bgisuat04_portal\WEB-INF\web.xml -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04_portal\WEB-INF\web.xml -Force -Confirm:$false

Write-Output "Update pathConstants.js"
Copy-Item -Path D:\Manhattan\tomcat\BGISUAT04\webapps\old_bgisuat04\generic\jscript\constants\pathConstants.js -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04\generic\jscript\contstants\pathConstants.js -Force -Confirm:$false

Write-Output "Update api.json"
Copy-Item -Path D:\Manhattan\tomcat\BGISUAT04\webapps\old_bgisuat04\API\api.json -Destination D:\Manhattan\tomcat\BGISUAT04\webapps\bgisuat04\API\api.json -Force -Confirm:$false
```

- Ensure all the values in the _pathConstants.js_ have been updated to reflect the new environment properly

![Desktop View](/assets/img/2022-11-01/20221101-17-01.PNG){: width="979" height="298" }
_pathConstants.js_

If the config files (ASN) are copied from any other environment, do the following additional steps:
- update the urouter port number
- search and replace bgis_uat04 to bgis_trn
- update DB credentials
- update MRE string
- search for webapps and check the folder name inside
- update urouter & tomcat port numbers in ini files

## 18: Copy EDC files into manii

_Copy EDC files into manii, and copy webroot prepared from UAT06_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

 

Copy EDC folder from E:\Manhattan\versions\BGISPROD\Manii to E:\Manhattan\versions\bgis_prod\manii 
 

Delete the bgisprod folder from E:\Manhattan\tomcat\BGISPROD\webapps first, then 

Copy bgisprod folder from E:\Manhattan\upgrade\36-SP3_uat06_Webroot to E:\Manhattan\tomcat\BGISPROD\webapps 

 

Copy bgisprod_portal folder from E:\Manhattan\upgrade\36-SP3_uat06_Webroot to E:\Manhattan\tomcat\BGISPROD\webapps 

## 19: Import Umeta.xml

<button type="button" class="btn btn-secondary position-relative">Veera</button>

- Open the **02. IDF** tool using Uniface 10 shortcut as admin
- Run the command `/rma /imp D:\Manhattan\upgrade\upgrade_exports\umeta.xml`

```sh
mkdir -p D:\Manhattan\upgrade\upgrade_exports
/rma /imp D:\Manhattan\upgrade\upgrade_exports\umeta.xml
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename IDF log file

## 20: Configure the v36 SP3 ASNs

_Configure the v36 SP3 ASNs as per the new folder structure (separate v35 & v36)_

<button type="button" class="btn btn-secondary position-relative">Veera</button>

> Veera - where is the infomration for this step?
{: .prompt-danger }

## 21: Import User Grid Source

<button type="button" class="btn btn-secondary position-relative">Veera</button>
<button type="button" class="btn btn-warning position-relative">Ken</button>

> From Step 13, Export Uniface 9 Source, copy the `client_usergrid.xml` file from SharePoint
{: .prompt-warning }

- Open the **02. IDF** tool as admin
- Run the command `/rma /imp D:\Manhattan\xml\BGISUAT04\client_usergrid.xml`

```sh
/rma /imp D:\Manhattan\xml\BGISUAT04\client_usergrid.xml`
```

## 22: Import Uniface 10 Grid Template Source

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Open the **02. IDF** tool as admin
- Run the followimg import commands one after another

```sh
/rma /imp D:\Manhattan\upgrade\upgrade_exports\36ntier_include_procs.xml 
/rma /imp D:\Manhattan\upgrade\upgrade_exports\36gridtemplate_source.xml
/rma /imp D:\Manhattan\upgrade\upgrade_exports\gridtemplate_source.xml
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file

## 23: Update autopatcher to latest v36

_Update autopatcher to latest v36 (given by Neil)_

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Rename the `manii` folder at `D:\Manhattan\Upgrade\v36_autopatch\36-SP3\PATCHSOFTWARE\manii` to `old_manii`
- Copy the `manii` folder and it's contents provided by Neil to `D:\Manhattan\Upgrade\v36_autopatch\36-SP3\PATCHSOFTWARE\manii`

## 24: Launch the Autopatcher Upgrade to v36 SP3

<button type="button" class="btn btn-warning position-relative">Ken</button>

- In the Shortcuts for UAT04 launch the **01. Autopatcher** application as admin
- Load the config from `D:\Manhattan\version\bgis_uat04\bgis_uat04.patchconfig`
- Set the _Patch Folder_ to `D:\Manhattan\upgrade\v36_autopatch\combined` and tab out of path
- Untick options for _Manii Folder_ and _Webroot Folder_

![Desktop View](/assets/img/2022-11-01/20221101-10-01.PNG){: width="609" height="245" }
_Autopatcher Manii Folder and Webroot Folder Unchecked_

- Ensure _Overwrite Newer_ is checked
- Click on _Apply Patch_ button
- CLick on _Use VBS_ and _Auto Step_ options then click _Next_ button

## 25: TRUNCATE TABLE FINRPTSTAT and import file

_TRUNCATE TABLE FINRPTSTAT and import file given by Neil (2nd time)_

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Execute command

```sql
SQL> TRUNCATE TABLE FINRPTSTAT;
```

- Open the **02. IDF** tool as admin
- Run the command `/rma /imp "D:\Manhattan\upgrade\finrptstat-replacementdata.xml"`

```sh
/rma /imp "D:\Manhattan\upgrade\finrptstat-replacementdata.xml"
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file

## 26: Compile user grids and VC_GRIDCOMPARE

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Open the **02. IDF** tool as admin
- Run the command `/rma /con UVIEW`

```sh
/rma /con UVIEW
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File

- Open the **02. IDF** tool as admin
- Run the command `/rma /svc UGRID*`

```sh
/rma /svc UGRID*
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File

- Open the **02. IDF** tool as admin
- Run the command `/rma /tst VC_GRIDCOMPARE`

```sh
/tst VC_GRIDCOMPARE
```

- Window pops up, click on _Compare_ button

![Desktop View](/assets/img/2022-11-01/20221101-26-01.PNG){: width="424" height="174" }
_Click on the Compare button_

- Once the process is compelte, click on the _Update_ button

![Desktop View](/assets/img/2022-11-01/20221101-26-02.PNG){: width="480" height="299" }
_Click on the Update button_

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File


## 27: Compile and Enable triggers

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Open **SQLTools** and connect to BGISUAT04 environment
- Open **Object List** window by pressing <keyb>ALT + 3</keyb> keys
- Select all items in list with `CTRL + A` and then right-click and select **Compile** on menu drop down
- Select all items in list with `CTRL + A` and then right-click and select **Enable** on menu drop down

![Desktop View](/assets/img/2022-11-01/20221101-27-01.PNG){: width="673" height="540" }
_Compile then Enable the triggers_

## COMMS

> Actioned by  Naeem
{: .prompt-info }


## 28: Execute Row Count to PROD_END_COUNT.txt

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\Manhattan\Upgrade\row_counts.sql"
```

## 29: Copy the row count document to sharepoint

<button type="button" class="btn btn-warning position-relative">Ken</button>

- The file `post_upgrade_row_counts.txt` will be generated under in the directory the SQLPlus command prompt was started from _(ie - the `C:\Users\<username>` directory)_
- Rename the file to include the `pre_` prefix
- Copy it to somewhere locally, then upload it to SharePoint at `APAC Clients > BGIS > v36 Upgrade > Upgrade Documentation > 05 - Production Upgrade`

## 30: Apply v36 SP3+ releases as per SPR log

<button type="button" class="btn btn-warning position-relative">Ken</button>

> Veera - see video ts7:36:40
{: .prompt-danger }

## 31: Delete session table statistics and lock indexes

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\Manhattan\upgrade\sql\delete_stats.txt"
SQL> @"D:\Manhattan\upgrade\sql\lock_stats.txt"
```

## 32: Update version in the database and path constants

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Run the following commands

```sql
SQL> UPDATE SYST_TIT SET ST_TITLE = 'BGIS_PROD v36-SP3' WHERE ST_TYPE = 'V';
SQL> COMMIT;
```

## 33: change the param IMAGE_WEBFOLDER

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Run the following commands

```sql
SQL> SELECT * FROM def_params WHERE dp_ref= 'IMAGE_WEBFOLDER';
SQL> UPDATE def_params SET dp_vc255 = 'https://test.apac.bgis.com/bgisuat04/generic/images/userimages/' WHERE dp_ref= 'IMAGE_WEBFOLDER';;
```


## 34: Run compile.sql a few times to compile DB objects

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"D:\manhattan\upgrade\compile.sql"
```

- Run it again

```sql
SQL> @"D:\manhattan\upgrade\compile.sql"
```

## 35: Compile invalid objects via SQL tools

<button type="button" class="btn btn-warning position-relative">Ken</button>

- Open **SQLTools** and connect to BGISUAT04 environment
- Open **Object List** window by pressing <keyb>ALT + 3</keyb> keys
- Select the **Invalid Objects** tab
- Select all items in list with `CTRL + A` and then right-click and select **Compile** on menu drop down

![Desktop View](/assets/img/2022-11-01/20221101-38-01.PNG){: width="785" height="615" }
_Regenerating grids via frontend_


> Can **Compile** more than once to determine if the objects will compile
{: .prompt-info }

## 36: Copy manii / webroot folders

_Copy manii / webroot folders to all other app / scheduler servers_

<button type="button" class="btn btn-warning position-relative">Ken</button>

_There is no info for this step_

## Turn on Archive Logging and Restart Oracle (Only for Prod)

> Actioned by BGIS
{: .prompt-info }


## Gather Schema Statistics

> Actioned by BGIS
{: .prompt-info }


## 37: Restart Apache, Tomcat, Urouter Services

<button type="button" class="btn btn-info position-relative">Danijel</button>

- Start Urouter services
- Start Tomcat services
- Restart Apache services

> Veera - on web servers, what is IP address?
{: .prompt-danger }

## 38: Enable v36 schedulers if not using schedmon

<button type="button" class="btn btn-info position-relative">Danijel</button>

> Must be actioned in exact order
{: .prompt-warning }

- Enable the Scheduler services using this exact order
- vPRODSC01 actioned first, in order, do not enable the other 3 services even though they are visible
- PSCH22 actioned second, in order, do not enable the other 4 services even though they are visible

| Server | IP Address | Service 1 | Service 2 | Service 3 | Service 4 |
|:-------|:-----------|:----------|:----------|:----------|:----------|
| vPRODSC01 | 172.16.1.123 | BATCHPOST01 | BATCHPOST02 | BATCHRUN | SCHEDULE |
| PSCH22 | 172.16.1.124 | EMAILNOTIF | WOCOMPLETE | WORKORDERS |



## COMMS

> Actioned by Naeem
{: .prompt-info }


## 39: Rebuild Tabs

<button type="button" class="btn btn-info position-relative">Danijel</button>

- Open the **02. IDF** tool as admin
- Run the followimg import commands one after another

```sh
/rma /tst csutprebuildtabs
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file

## 40: Recompile the user grids - Step 1 (con UVIEW)

<button type="button" class="btn btn-info position-relative">Danijel</button>

> Veera - is this correct?
{: .prompt-danger }

> Veera - this was done at step 34 already?
{: .prompt-danger }

- Open the **02. IDF** tool as admin
- Run the command `/rma /con UVIEW`

```sh
/rma /con UVIEW
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File

## 41: Re-generate Grids via frontend

<button type="button" class="btn btn-info position-relative">Danijel</button>

- Login to the application [https://test.apac.bgis.com/bgisuat04/manhattan.htm](https://test.apac.bgis.com/bgisuat04/manhattan.htm)
- Use the fieldman login details
- In the navigation pane, select the path `Administration > Utilities > Regenerate User Grids`
- Click on **Regenerate** button on fly-out window at bottom of screen

![Desktop View](/assets/img/2022-11-01/20221101-43-01.PNG){: width="415" height="173" }
_Invalid Objects_

- 2 errors are expected

## 42: Recompile the user grids

_Recompile the user grids - Step 2 (svc UGRID*) (log file size should be 100+ MB)_

<button type="button" class="btn btn-info position-relative">Danijel</button>

> Veera - is this correct?
{: .prompt-danger }

> Veera - this was done at step 34 already?
{: .prompt-danger }

- Open the **02. IDF** tool as admin
- Run the command `/rma /svc UGRID*`

```sh
/rma /svc UGRID*
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File


## 43: In case of Initialise_grid error

_In case of Initialise_grid error, do the steps in the notes column_

<button type="button" class="btn btn-info position-relative">Danijel</button>

Imported umeta, 36ntier, 36grid_template. Then /con uview. Then regenerated grids via frontend. Then /svc ugrid*

### Umeta

- Open the **02. IDF** tool using Uniface 10 shortcut as admin
- Run the command `/rma /imp D:\Manhattan\upgrade\upgrade_exports\umeta.xml`

```sh
mkdir -p D:\Manhattan\upgrade\upgrade_exports
/rma /imp D:\Manhattan\upgrade\upgrade_exports\umeta.xml
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename IDF log file

### 36ntier and 36grid_template

- Open the **02. IDF** tool as admin
- Run the followimg import commands one after another

```sh
/rma /imp D:\Manhattan\upgrade\upgrade_exports\36ntier_include_procs.xml 
/rma /imp D:\Manhattan\upgrade\upgrade_exports\36gridtemplate_source.xml
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log file


> At step 22, there is a command to Import Uniface 10 Grid Template Source, there is a 3rd line `/rma /imp D:\Manhattan\upgrade\upgrade_exports\gridtemplate_source.xml` <- do not do this!
{: .prompt-danger }

### /con uview

- Open the **02. IDF** tool as admin
- Run the command `/rma /con UVIEW`

```sh
/rma /con UVIEW
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File

### Regenerate Grids via Frontend

- Login to the application [https://test.apac.bgis.com/bgisuat04/manhattan.htm](https://test.apac.bgis.com/bgisuat04/manhattan.htm)
- Use the fieldman login details
- In the navigation pane, select the path `Administration > Utilities > Regenerate User Grids`
- Click on **Regenerate** button on fly-out window at bottom of screen

![Desktop View](/assets/img/2022-11-01/20221101-43-01.PNG){: width="415" height="173" }
_Invalid Objects_

- 2 errors are expected

### /svc ugrid*

- Open the **02. IDF** tool as admin
- Run the command `/rma /svc UGRID*`

```sh
/rma /svc UGRID*
```

- Check the logs at `D:\Manhattan\logs\BGISUAT04\idf` and search for the files by date/time
- Rename the log File

## 44: Drop and create index ACTIVITY_F1

_Drop and create index ACTIVITY_F1 , CREATE index ORDERH_

<button type="button" class="btn btn-info position-relative">Danijel</button>

- Log into SQLPlus using command line

```sh
#> sqlplus bgisuat04/Btgis$9uat04@mhtest
```

- Copy the path of the target file, execute using SQL load file convention

```sql
SQL> @"E:\Manhattan\upgrade\sql\recreate_ACTIVITY_F1_index.txt"
SQL> @"E:\Manhattan\upgrade\sql\create_ORDERH_index.txt"
```

## 45: DevOps Smoke Test

<button type="button" class="btn btn-info position-relative">Danijel</button>

- Log into the application prod URL [https://manhattand.bgis.com/bgisprod/manhattan.htm](https://manhattand.bgis.com/bgisprod/manhattan.htm)
- In the navigation pane, select the path `Administration > Scheduler Management`
- Check the schedulers are running in the main window
- Check the _Start Date_ and _Start Time_ are current
- In the navigation pane, select the path `Reporting > Reports > Test Report`
- Select `Standard Report` from the drop down
- Click on _Generate_ report and if report generates, the Java is the correct version and the PDF will be generated
- Take note of the Area Name and Version info
- Launch a Manhattan User Grid
- Launch a Manhattan Grid

> Veera - what are the two grids being asked here?
{: .prompt-danger }

## Buffer for any overflow tasks or issue resolution

<button type="button" class="btn btn-secondary position-relative">Veera</button>
<button type="button" class="btn btn-warning position-relative">Ken</button>
<button type="button" class="btn btn-info position-relative">Danijel</button>

_This is time available for anyone to have an overflow of time in contention with the original timings_
