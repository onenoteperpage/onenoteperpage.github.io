---
title: Patching E2E
author: danijel
date: 2022-12-01 11:00:00 +1000
categories: [Reference]
tags: [reference]
math: true
mermaid: true
# image:
#   path: /assets/img/logos/bgis.png
#   width: 888
#   height: 213
#   alt: BGIS Logo
---

Process to patch, end to end.

## Process Simplified

1. Stop the scheduler
1. Put up the OOO message
1. Stop Tomcat
1. Stop Urouter
1. Do the work
1. Reverse the order
1. Smiles



```powershell
switch ($serviceStatus)
{
    {$_ -like "Stopped"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "STOPPED" -ForegroundColor Red

    }
    {$_ -like "Running"} {
        Write-Host "Service [" -NoNewLine
        Write-Host $servName -ForegroundColor Yellow -NoNewLine
        Write-Host "] is " -NoNewLine
        Write-Host "RUNNING" -ForegroundColor Red
        #Get-Service -Name $servName | Stop-Service -Confirm:$false -Force
    }
}
```