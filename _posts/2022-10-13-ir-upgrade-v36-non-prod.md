---
title: IR Upgrade v36 Non-Prod
author: danijel
date: 2022-01-13 11:00:00 +1000
categories: [Process]
tags: [ir, upgrade, non-prod]
mermaid: true
comments: false
---

Upgrade process for Inland Rail v36.

## Pre-Requisites

### VPN

Using OpenVPN, connect to VPN1 `13.239.11.251`.

![VPN Connection](/assets/img/ir-upgrade-v36-non-prod/vpn%20logon.png)
_VPN1 Connection_

### PowerShell Profile

Update PowerShell profile to include required custom functions:

 - Get-SqlEnv

Verify the PowerShell Profile exists by the following command, else add the data required.

```powershell
if (-not (Test-Path -Path $profile))
{
    mkdir -p $(Split-Path -Path $profile -Parent)
    New-Item -Path $profile -ItemType File -Confirm:$false -Force
    notepad $profile
}
```

Verify the `$env:KEY` value is input to the profile too. This can be loaded manually per instance of PowerShell to prevent secrets being captured.

### Servers

| Server | IP | VPN | Description |
|:-------|:---|:----|:------------|
| NONPROD\SYDA-NMH-ODPa | 10.229.5.150 | VPN1 | Oracle Data Pump (Server A) |
