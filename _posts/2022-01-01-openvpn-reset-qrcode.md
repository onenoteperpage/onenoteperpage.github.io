---
title: OpenVPN Reset QRCode
author: danijel
date: 2022-01-01 11:00:00 +1000
categories: [IdM]
tags: [openvpn, vpn1, vpn2]
mermaid: true
comments: false
---
OpenVPN QR Codes cannot be reset via GUI instead using OpenVPN CLI. Requiring an admin account, login to server via SSH to generate new QR code for end-user.

## Required
1. SSH Key Files
  - <code>C:\Users\John.Law\OneDrive - MRI Software\CloudOps Documents (Latest)\02 - Security\AWS Key Files</code>
  - AWS-APAC-SUPPORT
1. SSH Client ([Putty](/downloads/putty.html))

## Steps
1. Open AWS Console
1. Find matching server in AWS EC2
1. Verify the **Key pair name** _(image 1)_ matches the key for the EC2 SSH server
1. Connect to VPN server with RDP
1. Execute reset on OpenVPN CLI for GoogleAuthRegen
  - <code>sudo /usr/local/openvpn_as/scripts/sacli -u &lt;userID&gt; GoogleAuthRegen</code>
1. Ask user to login again to OpenVPN via browser and setup Auth Token via QRCode again


## Images
Image 1
![Image 1](/assets/img/2022-01-01-openvpn-reset-qrcode-01.png)
