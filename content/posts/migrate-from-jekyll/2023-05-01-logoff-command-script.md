---
title: Logoff Command Script
author: danijel
date: 2023-04-25 11:00:00 +1000
categories: [Other]
tags: [windows]
series: ['MH Reference']
aliases: ['migrate-from-jekyl']
ShowToc: true
TocOpen: true
editPost:
    URL: 'https://github.com/onenoteperpage/mri-docs-v4/content'
    Text: 'Suggest Changes' # edit text
    appendFilePath: true # to append file path to Edit link
---

Logoff command can be installed onto desktops directly

```pwsh
if (Test-Path -Path ~\Desktop\Logoff.cmd)
{
  Remove-Item -Path ~\Desktop\Logoff.cmd -Force -Confirm:$false
}

Add-Content -Path ~\Desktop\Logoff.cmd -Value "@echo off"
Add-Content -Path ~\Desktop\Logoff.cmd -Value 'powershell -executionpolicy bypass -command "logoff"'
```

This will create the required command script on the desktop to auto logoff from a server.
