---
title: CBA October 2022 Prod Release
author: danijel
date: 2022-10-23 11:00:00 +1000
categories: [Reference, Server Config]
tags: [prod, cba, v35]
math: true
mermaid: true
image:
  path: /assets/img/post-headers/commbank.jpg
  width: 800
  height: 280
  alt: Commbank Logo
---

Process to update CBA Prod Release for 26th October, 2022 for Manhattan V35.

**Ticket:** RITM0068367

## Step 1: Stop Manhattan Schedulers

**VPN:** REWSAPAC

> This step requires elevated execution
{: .prompt-warning }

1. Log into `SYDA-PSCHA03-CBA` using RDP
1. Open `E:\Manhattan\Shortcuts\schedmon\schedulers.list.txt` file in Notepad++
1. Add a double hyphen `--` in front of each line that has `...|cbaprod|...` in the lines and save file
1. Launch `Windows Task Manager`and select Details tab
  - Scroll down to services starting with `uniface.exe`
  - Monitor for a job to run and exit at least once _(processed any pending jobs)_

```powershell
$orig = "E:\Manhattan\Shortcuts\schedmon\schedulers.list.txt"
$temp = "E:\Manhattan\Shortcuts\schedmon\schedulers.list.txt2"

Get-Content -Path $orig | ForEach-Object {
    if ($_ -match '.*\|cbaprod\|.*')
    {
        "--" + $_ | Out-File -FilePath $temp -Append
    }
    else
    {
        $_ | Out-File -FilePath $temp -Append
    }
}

Remove-Item -Path $orig -Force -Confirm:$false
Rename-Item -Path $temp -NewName $orig -Force
```

## Step 2: Stop Manhattan Prod Services

> This step requires elevated execution
{: .prompt-warning }

1. Log into `SYDA-PAPPA10` using RDP
  - Open `services.msc`
  - Stop process `Uniface Urouter CBAPROD`
1. Log into `SYDA-PAPPA08` using RDP
  - Open `services.msc`
  - Stop process `Uniface Urouter CBAPROD`

```powershell
$servName = "Uniface Urouter CBAPROD"
if ((Get-Service -Name $servName).Status -like "Running")
{
  Write-Host "Service [" -NoNewLine
  Write-Host $servName -ForegroundColor Yellow -NoNewLine
  Write-Host "] is " -NoNewLine
  Write-Host "RUNNING" -ForegroundColor Red
  #Get-Service -Name $servName | Stop-Service -Confirm:$false -Force
}
if ((Get-Service -Name $servName).Status -like "Stopped")
{
  Write-Host "Service [" -NoNewLine
  Write-Host $servName -ForegroundColor Yellow -NoNewLine
  Write-Host "] is " -NoNewLine
  Write-Host "RUNNING" -ForegroundColor Red
  Get-Service -Name $servName | Stop-Service -Confirm:$false -Force
}
```

## Step 3: Backup Manhattan

Using 7za, capture these:

- `E:\Manhattan\versions\Clients\CBAPROD\Manii`
- `\\rewsapac\dfs\iwms\inlandrail_prod\user_grids`
- `E:\Manhattan\Tomcat\CBAPROD`

name like this: `ritm0068367_cbaprod_<manii|usergrids|tomcat>_yyyyMMdd.7z`

upload them to S3:

`aws s3 cp s3://rews-syda-dbdump1/IR/ritm0068367_cbaprod_<manii|usergrids|tomcat>_yyyyMMdd.7z C:\temp\ritm0068367_cbaprod_<manii|usergrids|tomcat>_yyyyMMdd.7z`


patch config:

`"E:\Manhattan\versions\Clients\CBAPROD\CBAPROD.patchconfig"`

<!-- Entity ID https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod
Assertion Consumer Service URL  https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/Shibboleth.sso/SAML2/POST
Logout Url: https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/Shibboleth.sso/SLO/SOAP
Application URL: https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/manhattan.html -->

