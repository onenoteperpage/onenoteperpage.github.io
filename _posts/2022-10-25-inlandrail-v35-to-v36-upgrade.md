---
title: InlandRail V35 to V36 Upgrade
author: danijel
date: 2022-10-25 11:00:00 +1000
categories: [Reference, Server Config]
tags: [ir]
math: true
mermaid: true
image:
  path: /assets/img/post-headers/inlandrail.png
  width: 514
  height: 98
  alt: ARTC InlandRail Logo
---

Process to upgrade Inland Rail v35 (legacy prod) to v36 (new prod) using QGAO upgate environment.

## Step 1: Set Maintenance Mode

### [SYDA-GGDB01:REWSAPAC]

> Requires AWS PowerShell credentials from web console via OKTA
{: .prompt-info }

1. Change to the `C:\Tools\Scripts` directory
1. Load the `maintenance.ps1` script into memory
1. Activate the **maintenance page** for `/inlandrail_prod/*` on `SYDA-PRODUCTION-WEB` load balancer

```powershell
<# enter AWS PowerShell credentials #>

Set-Location -Path C:\Tools\Scripts
. maintenance.ps1

<#
select the line that matches the DNS of the target load balancer

0       @{DNSName=LB-SYDA-PCS-INT-06e414d69b2328d7.elb.ap-southeast-2.amazonaws.com}
1       @{DNSName=LB-SYDA-P-SFT-56780bc8ba668d6b.elb.ap-southeast-2.amazonaws.com}
2       @{DNSName=LB-SYDA-P-FS-786c112c2c54a912.elb.ap-southeast-2.amazonaws.com}
3       @{DNSName=LB-SYDA-P-MAIL-9b4dd2a87a33e2b3.elb.ap-southeast-2.amazonaws.com}
4       @{DNSName=LB-SYDA-P-SFT-EXT-a4e5ce5209d10693.elb.ap-southeast-2.amazonaws.com}
5       @{DNSName=ELB-SYDA-PRODUCTION-WEB-1803624653.ap-southeast-2.elb.amazonaws.com}
6       @{DNSName=ELB-PRTG-Monitoring-Server-1172870506.ap-southeast-2.elb.amazonaws.com}
7       @{DNSName=internal-LB-SYDA-PSS-APP-48478545.ap-southeast-2.elb.amazonaws.com}
8       @{DNSName=LB-SYDA-PSS-WEB-436049559.ap-southeast-2.elb.amazonaws.com}
9       @{DNSName=SYDA-NPROD-ELB-1017979893.ap-southeast-2.elb.amazonaws.com}
10      @{DNSName=internal-LB-SYDA-PCS-IMP-42228723.ap-southeast-2.elb.amazonaws.com}
11      @{DNSName=LB-SYDA-PCS-RES-118069945.ap-southeast-2.elb.amazonaws.com}
12      @{DNSName=ALB-SYDA-PMH-WEB-1565104549.ap-southeast-2.elb.amazonaws.com}
please select::
#>

Show-Rule
Add-Rule -Pattern /inlandrail_prod/* -Template index.html -Priority 100
Show-Rule
```

## Step2: Disable Scheduler & Urouter Services

> Elevated PowerShell prompt required
{: .prompt-warning }

### [SYDA-PAPPA08:REWSAPAC]

1. Stop the `Uniface Urouter INLANDRAIL_PROD` service

```powershell
$servName = "Uniface Urouter INLANDRAIL_PROD"
$serviceStatus = (Get-Service -Name $servName).Status

switch ($serviceStatus)
{
    {$_ -like "Stopped"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "STOPPED" -ForegroundColor Red
        Get-Service -Name $servName | Start-Service -Confirm:$false -Force
        Write-Host "Status is now changed to [" -NoNewLine
        Write-Host "RUNNING" -ForegroundColor Green -NoNewLine
        Write-Host "]"
    }
    {$_ -like "Running"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "RUNNING" -ForegroundColor Green
        Get-Service -Name $servName | Stop-Service -Confirm:$false -Force
        Write-Host "Status is now changed to [" -NoNewLine
        Write-Host "STOPPED" -ForegroundColor Red -NoNewLine
        Write-Host "]"
    }
}
```

### [SYDA-PAPPA08:REWSAPAC]

1. Stop the `Uniface Urouter INLANDRAIL_PROD` service

```powershell
$servName = "Uniface Urouter INLANDRAIL_PROD"
$serviceStatus = (Get-Service -Name $servName).Status

switch ($serviceStatus)
{
    {$_ -like "Stopped"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "STOPPED" -ForegroundColor Red
        Get-Service -Name $servName | Start-Service -Confirm:$false -Force
        Write-Host "Status is now changed to [" -NoNewLine
        Write-Host "RUNNING" -ForegroundColor Green -NoNewLine
        Write-Host "]"
    }
    {$_ -like "Running"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "RUNNING" -ForegroundColor Green
        Get-Service -Name $servName | Stop-Service -Confirm:$false -Force
        Write-Host "Status is now changed to [" -NoNewLine
        Write-Host "STOPPED" -ForegroundColor Red -NoNewLine
        Write-Host "]"
    }
}
```

### [SYDA-PSCHA02:REWSAPAC]

### [SYDA-PMH-SCHB:REWSAPAC]

E:\Manhattan\Shortcuts\schedmon\schedulers.list.txt

### [SYDA-NMH-ODPA::REWSAPAC]

1. Set the sql environment variables

```powershell
Get-SqlEnv -c1 


<!-- Entity ID https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod
Assertion Consumer Service URL  https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/Shibboleth.sso/SAML2/POST
Logout Url: https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/Shibboleth.sso/SLO/SOAP
Application URL: https://sso-inlandrail-prod.ap.manhattan.one/inlandrail_prod/manhattan.html -->

