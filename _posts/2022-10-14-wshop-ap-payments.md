---
title: Workshop AP Payments (PARTNER)
author: danijel
date: 2022-01-15 11:00:00 +1000
categories: [Reference, Environments]
tags: [wshop, workshop, reference, env, partner]
mermaid: true
comments: false
---

Workshop is specific to CBA. Workshop is run within the `PARTNER` domain on Windows servers. PARTNER exists on AWS within the **Non-Prod** environment. Steps provided will allow the service to be restarted.

**Portal URL:**&nbsp;&nbsp;[https://syda-prt-portal.manhatta-online.com/RDWeb/Pages/en-US/default.aspx](https://syda-prt-portal.manhatta-online.com/RDWeb/Pages/en-US/default.aspx)
**Domain:**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PARTNER

## Prod Environment

_There are no Prod environments in PARTNER domain._

## Non-Prod Environment

| AWS Env | Hostname | IP Address | Domain | VPN |
|:--------|:---------|:-----------|:-------|:----|
| CloudOps: Non-Prod | PTR-EQUISYS-ORA | 10.212.0.184 | PARTNER | Non-Prod |

### Services

| Name | Display Name | Description | Startup Type | Log On As |
|:-----|:-------------|:------------|:-------------|:----------|
| CBA9735WSHOP | Apache Tomcat 7.0 CBA9735WSHOP | n/a | Automatic | Local System account |
| Uniface Urouter CBA9735WSHOP | Uniface Urouter CBA9735WSHOP | Uniface Urouter CBA9735WSHOP | Automatic | .\userver_cba||&lt;password&gt; |

### Restart Services

```powershell
Get-Service -Name "Uniface Urouter CBA9735WSHOP" | Restart-Service -Force -Confirm:$false
Get-Service -Name "CBA9735WSHOP" | Restart-Service -Force -Confirm:$false
```

### Confirm Services Running

```powershell
if (-not((Get-Service -Name "CBA9735WSHOP").Status -eq "Running")) { "Service not running: Apache Tomcat CBA9735WSHOP" }
if (-not((Get-Service -Name "Uniface Urouter CBA9735WSHOP").Status -eq "Running")) { "Service not running: Uniface Urouter CBA9735WSHOP" }
```

## Remote Execution
