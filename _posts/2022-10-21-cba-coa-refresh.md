---
title: CBA COA Refresh
author: danijel
date: 2022-10-21 11:00:00 +1000
categories: [Category]
tags: [prod, cba]
math: true
mermaid: true
image:
  path: /assets/img/post-headers/commbank.jpg
  width: 800
  height: 280
  alt: Commbank Logo
---

Process to update COA and Charge Codes for CBA Production.

## Pre-Reqs

### AWS Cli

Install AWS Cli and reboot computer. Application can be installed from [AWS download page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

> Reboot the machine after installing this tool as it may not always load into the current profile correctly
{: .prompt-tip }

### AWS Tools for PowerShell

> This step requires elevated PowerShell window
{: .prompt-warning }

AWS Tools for PowerShell are required and can be installed from NuGet directly.

```powershell
Install-Module -Name AWS.Tools.Common
```

### AWS PowerShell Profile Functions

Ensure code is loaded into the PowerShell profile.

```powershell
$env:AWS_CLI_AUTO_PROMPT='off'
$Env:AWS_PROFILELOCATION="$home\.aws\credentials"

$Env:AWS_CSM_ENABLED=$true
$Env:AWS_CSM_PORT=31000
$Env:AWS_CSM_HOST=127.0.0.1

function stc
{
	param($pf)
	$Env:AWS_ACCESS_KEY_ID 

	Set-AWSCredentials -AccessKey $Env:AWS_ACCESS_KEY_ID -SecretKey $Env:AWS_SECRET_ACCESS_KEY -SessionToken $Env:AWS_SESSION_TOKEN -StoreAs $pf -ProfileLocation $Env:AWS_PROFILELOCATION
}

function sac
{
	param($pf)
	$Env:AWS_PROFILE=$pf
	Set-AWSCredential -ProfileName $pf -ProfileLocation $env:AWS_PROFILELOCATION
	$Cred=Get-AWSCredential -ProfileName $pf -ProfileLocation $env:AWS_PROFILELOCATION
	$Env:AWS_ACCESS_KEY_ID=$cred.GetCredentials().AccessKey
	$Env:AWS_SECRET_ACCESS_KEY=$cred.GetCredentials().SecretKey
	$Env:AWS_SESSION_TOKEN=$cred.GetCredentials().Token
}
```

### Maintenace.ps1

Copy of `maintenance.ps1` stored in root of user profile. File can be downloaded from [here](/downloads/files/aws-cli/maintenance.ps1) or via [S3](s3://rews-syda-deployment/maintenance/maintenance.ps1) link.

### Servers

| Name | Stack | VPN | Collection | IP Address | Logon Domain |
|:-----|:------|:----|:-----------|:-----------|:-------------|
| SYDA-PAPPA10 | REWSAPAC | 13.55.248.48 | PROD | 10.216.13.42 | rewsapac |
| SYDA-PAPPA08 | REWSAPAC | 13.55.248.48 | PROD | 10.216.13.41 | rewsapac |
| SYDA-PSCHA03-CBA | REWSAPAC | 13.55.248.48 | PROD | 10.216.12.25 | rewsapac |


## Step 2: Disable SSO Login

### Pre-Load Environment

1. Log into the AWS console page, obtain a copy of the *AWS environment variables*
1. Paste them into a powershell window

![Desktop View](/assets/img/aws/aws-environment-variables-powershell.png){: width="733" height="318" }
_AWS Environment Variables in PowerShell_

1. Execute the following commands to preload all files required

```powershell
stc prod
sac prod
aws s3 cp s3://rews-syda-deployment/maintenance/maintenance.ps1 maintenance.ps1
Set-DefaultAWSRegion ap-southeast-2
. .\maintenance.ps1
Show-Rule
```

### Add SSO Disable Rule

1. Add the rule to the Elastic Load Balancer (ELB) to re-route users away from SSO

```powershell
Add-Rule -Pattern /cbaprod/* -Template s3://rews-syda-deployment/maintenance/index.html -Priority 90
Show-Rule
Get-Rule /cbaprod/*
```

> **Note:** If an error occurs on the Priorty, deduct 1 digit and try again until successful
{: .prompt-tip }

## Step 3: Stop Services & Backup

### Stop Services

1. Log onto `SYDA-PAPPA10` using RDP
  - Open `services.msc`
  - Stop process `Uniface Urouter CBAPROD`
1. Log onto `SYDA-PAPPA08` using RDP
  - Open `services.msc`
  - Stop process `Uniface Urouter CBAPROD`

### Stop Backup

1. Log into SYDA-PSCHA03-CBA
1. Open `E:\Manhattan\Shortcuts\schedmon\schedulers.list.txt` file in Notepad++
1. Add a double hyphen `--` in front of each line that has `...|cbaprod|...` in the lines and save file
1. Launch `Windows Task Manager`and select Details tab
  - Scroll down to services starting with `uniface.exe`
  - Monitor for a job to run and exit at least once _(processed any pending jobs)_

## Step 4: RDS Snapshot

1. Connect to AWS Cloud Services Prod Console environment

![Desktop View](/assets/img/aws/aws-cloud-services-prod-console.png){: width="783" height="270" }
_AWS Cloud Services Prod Console_

1. Change region to `ap-southeast-2` _(Sydney)_
1. Open RDS window _(Link: [https://ap-southeast-2.console.aws.amazon.com/rds/home?region=ap-southeast-2#](https://ap-southeast-2.console.aws.amazon.com/rds/home?region=ap-southeast-2#))_
1. Select `rds-syda-p-ora03` database for CBAPROD environment
1. From *Actions* button, select *Take snapshot* option
1. Name snapshot with `&lt;ticket number&gt;-&lt;client environment&gt;-&lt;date&gt;-&lt;time&gt;` all in lowercase
  - `ritm000xxxx-cbaprod-yyyyMMdd-HHmm`

## Step 5: Lockout and Logout Users

### Lock User Accounts

> Record any output of SQL commands into the Teams chat and word doc log
{: .prompt-info }

1. Access `Manhattan APAC` git repo on Azure DevOps
  - '[https://dev.azure.com/mrisoftware/ManhattanTechnicalServices/_git/manhattan_apac](https://dev.azure.com/mrisoftware/ManhattanTechnicalServices/_git/manhattan_apac)'
1. Open `SQLTools` and run the following scripts
  - `manhattan_apac\CBA\Scripts\user updates for COA go live\00_CREATE_TABLE_USERS_BACK.txt`
  - `manhattan_apac\CBA\Scripts\user updates for COA go live\01_LOCK_USERS.txt`

#### 00_CREATE_TABLE_USERS_BACK

```sql
create table USERS_BACK AS SELECT * FROM USERS;
```

#### 01_LOCK_USERS.txt

```sql
--Step 2 lock all users that currently have access, users on the access list are not included
update USERS set U_LOCK = 'T', U_DATE = TRUNC(sysdate), u_time = sysdate
where U_LOCK is null and U_USER not IN ('PENA494592', 'LEMA826768', 'RIFO626071', 'geoff', 'EDSO435004', 'DARI173671', 'AMProd', 'SHProd', 'fieldman');
--Step 3 allow access for the users on the list that are currently locked like fieldman
UPDATE USERS SET U_LOCK = NULL, U_DATE = NULL, U_TIME = NULL 
where U_LOCK = 'T' and U_USER IN ('PENA494592', 'LEMA826768', 'RIFO626071', 'geoff', 'EDSO435004', 'DARI173671', 'AMProd', 'SHProd', 'fieldman');
commit;
```


## Step 6: Charge Code Deletion Script (script 1 only) and IFRS scripts (TBC)

### Charge Code Deletion Script 00

> Record any output of SQL commands into the Teams chat and word doc log
{: .prompt-info }

1. Open `SQLTools` and run the following scripts
  - `manhattan_apac\CBA\Scripts\Charge Code Replacements\00 - CREATE_TABLE_CHARGE_TEMP.txt`
  - `manhattan_apac\CBA\Scripts\Charge Code Replacements\01 - DELETE_CHARGE_CODES.txt`

#### 00 - CREATE_TABLE_CHARGE_TEMP

```sql
CREATE TABLE CHARGE_TEMP AS SELECT * FROM CHARGE;
```

#### 01 - DELETE_CHARGE_CODES

```sql
DELETE FROM CHARGE;
COMMIT;
```

##  Step 7: Restart Manhattan Services

> Scheduler services to remain offline at this stage
{: .prompt-warning }

### Start Services

1. Log onto `SYDA-PAPPA10` using RDP
  - Open `services.msc`
  - Start process `Uniface Urouter CBAPROD`
1. Log onto `SYDA-PAPPA08` using RDP
  - Open `services.msc`
  - Start process `Uniface Urouter CBAPROD`

## Step 8: Deployment Status Email

Send an email to the MRI Team that Manhattan services are now re-enabled