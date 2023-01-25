---
title: Maintnenace Page
author: danijel
date: 2022-11-02 11:00:00 +1000
categories: [Reference]
tags: [reference]
math: true
mermaid: true
image:
  path: /assets/img/logos/share-files.png
  width: 680
  height: 371
  alt: Share Files
---

Set or clear the maintnence page when applying patches to Manhattan products on PROD/Non-Prod environments.

## Required

1. AWS CLI tool installed
1. AWS command line setup from web portal loaded into memory
1. AWSPowerShell.NetCore module installed _(PowerShell Core)_

## Setup/Config

### AWS CLI

- AWS CLI can be insalled on 64-bit Windows
- Admin rights required to install

1. Download and run the AWS CLI MSI installer for Windows (64-bit): [https://awscli.amazonaws.com/AWSCLIV2.msi](https://awscli.amazonaws.com/AWSCLIV2.msi)
  - Alternatively use `msiexec` to install MSI file directly:

  ```powershell
  msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
  ```

> Where a service has **O19** in the name, is v35 after the Oracle 19 upgrade. Otherwise is v35 prior to Oracle 19.
{: .prompt-info }

![Desktop View](/assets/img/2022-11-01/20221101-03-01.PNG){: width="583" height="547" }
_Disable Triggers_
