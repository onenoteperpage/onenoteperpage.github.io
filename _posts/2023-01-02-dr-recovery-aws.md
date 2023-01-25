---
title: DR Recovery (AWS)
author: danijel
date: 2023-01-02 11:00:00 +1000
categories: [Reference]
tags: [dr, terraform]
mermaid: true
comments: false
image:
  path: /assets/img/logos/terraform.png
  width: 1280
  height: 307
  alt: Terraform logo
---
Using Terraform, we are able to restore our DR services to active.

## Required

1. Terraform _(installed)_
1. S3 CLI _(installed)_
1. IWMS Terraform DR Folder _(from S3 bucket)_

## Install Terraform

Terraform can be found on [Downloads](/downloads/terraform.html) page. Install the exe file to any path of the machine. Updated versions of Terraform can be found [here](https://developer.hashicorp.com/terraform/downloads)

## Init Setup (Optional)

**Note:** Optional steps if not using designated restore server

1. DR scripts are located in S3 bucket [s3://rews-syda-deployment/DR/iwms-prod](s3://rews-syda-deployment/DR/iwms-prod)
1. Each DR script revision has a date-time stamp and is named in format of `iwms-prod-yyyyMMdd.zip`
1. Copy the zip file to local machine, or a shared drive, of a machine that has access to AWS CLI tool
1. Expand ZIP file to local machine using 7za

```powershell
7za x .\iwms-prod-yyyyMMdd.zip .\
```


The DR script for are located in s3 bucket s3://rews-syda-deployment/DR/iwms-prod 

Copy the folder onto a shared drive, as after the restore has been undertaken, the tfstate will need to be shared in order for the DR infrastructure to be maintained. 

Download terraform for platform you are running on (i.e. windows or linux) 

Cd to iwms-prod “terraform init” to install provider 

Make sure the server / workstation has been set up to access AWS cli, the script assumes aws profile named “prod”. 