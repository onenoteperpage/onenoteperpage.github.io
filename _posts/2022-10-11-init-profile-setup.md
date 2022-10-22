---
title: Init Profile Setup
author: danijel
date: 2022-10-11 11:00:00 +1000
categories: [Reference, Tools]
tags: [powershell, profile, tools, cli]
mermaid: true
---

## Setup Initial Profile

1. Copy text from $PROFILE_TEMPLATE here.
2. Execute PowerShell to create profile if not exists, if Notepad opens, paste text in, else skip to next section.

```powershell
if (-not (Test-Path -Path $PROFILE))
{
    New-Item -Path (Split-Path -Path $PROFILE -Parent) -ItemType Directory -Confirm:$false -Force
    New-Item -Path $PROFILE -ItemType File -Confirm:$false -Force
    notepad $PROFILE
    . $PROFILE
}
```

## Copy SQLTools Logons

1. Obtain copy of `SQLToolsU-yyyyMMdd.7z` from here.
1. Copy to root of user profile on target server.
1. Rename the file from `SQLToolsU-yyyyMMdd.7z` to `SQLToolsU.7z` for compatability.
1. Execute PowerShell to unzip

```powershell
7za x ~\SQLToolsU.7z -o~\AppData\Roaming\GNU -aoa
Remove-Item -Path ~\SQLToolsU.7z -Force -Confirm:$false
```
