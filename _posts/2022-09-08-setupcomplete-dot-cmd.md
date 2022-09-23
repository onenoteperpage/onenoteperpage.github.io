---
layout: post
title:  "autocomplete.cmd"
date: 2022-09-08 00:00:00 +1000
author: danijel
categories: [ sysprep ]
---

Two files that can be used to run [PowerShell](https://docs.microsoft.com/en-us/powershell/) commands when Windows finishes installing/upgrading.

### SetupComplete.cmd
```cmd
@echo off
SETLOCAL

cd "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0drivers.ps1"
:waitloop
TASKLIST |find /I "powershell.exe" >NUL
IF ERRORLEVEL 1 GOTO endloop
REM echo Notepad running. Waiting 1 second...
timeout /t 1 /nobreak>NUL
goto waitloop
:endloop
exit
```

### drivers.ps1

```powershell
Get-ChildItem -Path C:\DRIVERS -Filter "*.inf" -Recurse | ForEach-Object {
    pnputil /add-drive $_.FullName /install }
```
