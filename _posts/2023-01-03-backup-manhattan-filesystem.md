---
title: Backup Manhattan File System
author: danijel
date: 2023-01-03 11:00:00 +1000
categories: [Reference]
tags: [manhattan, backup]
mermaid: true
comments: false
image:
  path: /assets/img/logos/manhattan_logo.png
  width: 800
  height: 467
  alt: Manhattan logo
---
Backup of Manhattan file system can be actioned automatically, using S3 CLI and 7-Zip.

## Required
1. 7za function loaded to PowerShell profile
1. 7-Zip installed
1. AWS S3 Cli tool installed and configured

## Steps
1. Set the date
1. Set client
1. Set the env
1. Set the S3 client env
1. Create the temporary directory
1. Zip the items
1. Transfer to AWS S3 bucket

## Set Date, Client, Env

- Client name from list
- Env from list

```powershell
[System.String]$todayDate = $((Get-Date).ToString('yyyyMMdd'))
[System.String]$client = "CBA".ToLower()
[System.String]$env = "PROD".ToLower()
[System.String]$s3ClientEnv = "CBA"
```

## Create temporary directory

```powershell
if (Test-Path -Path "C:\temp\${todayDate}")
{
  Remove-Item -Path "C:\temp\${todayDate}" -Recurse -Force -Confirm:$false
}
New-Item -Path "C:\temp" -ItemType Directory -Name $todayDate -Force -Confirm:$false
```

## Zip Items

```powershell
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_manii_${todayDate}.7z" "E:\Manhattan\versions\Clients\${client}_${env}\Manii"
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_user_grids_${todayDate}.7z" "\\rewsapac\dfs\iwms\${client}_${env}\user_grids"
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_webapps_${todayDate}.7z" "E:\Manhattan\Tomcat\${client}_${env}\webapps\${client}_${env}"
```

## Transfer to AWS S3 Bucket

```powershell
foreach ($i in (Get-ChildItem -Path "C:\temp\${todayDate}\" -Filter "*.7z"))
{
    $filePath = $i.FullName
    $fileName = $i.Name
    aws s3 cp "${filePath}" "s3://rews-syda-dbdump1/${s3ClientEnv}/${fileName}" 
}
```

## Single Script

```powershell
[System.String]$todayDate = $((Get-Date).ToString('yyyyMMdd'))
[System.String]$client = "CBA".ToLower()
[System.String]$env = "PROD".ToLower()
[System.String]$s3ClientEnv = "CBA"
if (Test-Path -Path "C:\temp\${todayDate}")
{
  Remove-Item -Path "C:\temp\${todayDate}" -Recurse -Force -Confirm:$false
}
New-Item -Path "C:\temp" -ItemType Directory -Name $todayDate -Force -Confirm:$false
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_manii_${todayDate}.7z" "E:\Manhattan\versions\Clients\${client}_${env}\Manii"
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_user_grids_${todayDate}.7z" "\\rewsapac\dfs\iwms\${client}_${env}\user_grids"
7za a -t7z "C:\temp\${todayDate}\${client}_${env}_webapps_${todayDate}.7z" "E:\Manhattan\Tomcat\${client}_${env}\webapps\${client}_${env}"
foreach ($i in (Get-ChildItem -Path "C:\temp\${todayDate}\" -Filter "*.7z"))
{
    $filePath = $i.FullName
    $fileName = $i.Name
    aws s3 cp "${filePath}" "s3://rews-syda-dbdump1/${s3ClientEnv}/${fileName}" 
}
```