---
title: WSL2 Distro Failing to Startup [4294967295]
author: danijel
date: 2023-04-25 11:00:00 +1000
categories: [Other]
tags: [wsl,wsl2,windows]
series: ['MH Reference']
aliases: ['migrate-from-jekyl']
ShowToc: true
TocOpen: true
editPost:
    URL: 'https://github.com/onenoteperpage/mri-docs-v4/content'
    Text: 'Suggest Changes' # edit text
    appendFilePath: true # to append file path to Edit link
cover:
  image: /images/2023/05/09/Shibboleth_logo.png
---

Github issue [5092](https://github.com/microsoft/WSL/issues/5092) suggests the following two options:

### Option 1

```powershell
❯ netsh winsock reset

Sucessfully reset the Winsock Catalog.
You must restart the computer in order to complete the reset.
```
Reboot computer

### Option 2

```powershell
DISM /online /disable-feature /featurename:VirtualMachinePlatform /norestart
DISM /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
```

Reboot computer, then do:

```powershell
DISM /online /enable-feature /featurename:VirtualMachinePlatform /norestart
DISM /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
```