---
title: SFTP Servers
author: danijel
date: 2022-10-09 11:00:00 +1000
categories: [Reference]
tags: [sftp, openvpn]
mermaid: true
comments: false
---
SecureFTP is controlled by [Cerberus FTP Server](https://www.cerberusftp.com/) application on desktop of SFTx servers. Accounts not provisioned for PROD will most likely use an SSH Public Certificate to connect.

## Account Setup


## New Stack

| Client | Environment | VPN | RDP Cluster | Server |
| CBA | UAT 3 | OpenVPN&nbsp;1[^fn-openvpn-1] | Production-TSS | SYDA-P-SFTa, SYDA-P-SFTb |


## VPN Servers

[^fn-openvpn-1]: IP WebUI: [http://13.239.11.251/?src=connect](http://13.239.11.251/?src=connect)