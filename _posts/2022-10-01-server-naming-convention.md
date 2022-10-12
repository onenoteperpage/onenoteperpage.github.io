---
title: Server Naming Conventions
author: danijel
date: 2022-10-01 11:00:00 +1000
categories: [Server Config]
tags: [naming convention, rdp, openvpn]
mermaid: true
comments: false
---
Servers are connected to via RDP. Some servers require a VPN connection, and this should be installed separately. [OpenVPN](https://openvpn.net/) is not able to be downloaded from the web but can be accessed directly from [this link](/downloads/openvpn.html).

## REWSAPAC

### Admin

| DNS          | IP Address   | Port | VPN | Logon Domain | Service           |
|:-------------|:-------------|:-----|:----|:-------------|:------------------|
| SYDA-DCA01   | 10.216.12.31 | 3389 | ? | rewsapac | Domain Controller 1 |
| SYDA-DCA02   | 10.216.13.31 | 3389 | ? | rewsapac | Domain Controller 2 |
| SYDA-LAB04   | 10.216.31.46 | 3389 | ? | rewsapac | BGIS RDP via Fortinet _(Legacy)_ |
| SYDA-LAB03   | 10.216.31.45 | 3389 | ? | rewsapac | Unknown |
| SYDA-ADFS    | 10.230.2.238 | 3389 | ? | rewsapac | AD Federated Server |
| SYDA-MONA01  | 10.216.12.81 | 3389 | ? | rewsapac | Unknown |
| SYDA-PORTRAL | 10.216.2.91  | 3389 | ? | rewsapac | Unknown |
| SYDA-WSUS01  | 10.216.12.32 | 3389 | ? | rewsapac | Windows WSUS

### Non Prod

| DNS          | IP Address   | Port | VPN     | Logon Domain | Service           |
|:-------------|:-------------|:-----|:--------|:-------------|:------------------|
| syda-nweba1 | 10.216.30.10 | 3389 | ? | rewsapac | Non-Prod Web A1 |
| syda-nspc01 | 10.216.30.14 | 3389 | ? | rewsapac | Non-Prod Space _?_ |
| syda-nscha01 | 10.216.31.25 | 3389 | ? | rewsapac | Scheduling App 01 |
| syda-nscha05 | 10.216.31.65 | 3389 | ? | rewsapac | Scheduling App 05 |
| syda-nfsa01 | 10.216.31.61 | 3389 | ? | rewsapac | _?_ |
| syda-nappa1 | 10.216.31.21 | 3389 | ? | rewsapac | Application Server 1 |
| syda-nappa3 | 10.216.31.63 | 3389 | ? | rewsapac | Application Server 1 |
| syda-nappa5 | 10.216.31.107 | 3389 | ? | rewsapac | Application Server 1 |
| syda-nmh-ora1 | 10.216.31.41 | 3389 | ? | rewsapac | Oracle DB 1 _?_ |
| syda-nmh-upg01 | 10.216.31.67 | 3389 | ? | rewsapac | Upgrade 01 _?_ |
| pweb1a-lab | 10.216.31.81 | 3389 | ? | rewsapac | _?_ |
| pweb1b-lab | 10.216.31.82 | 3389 | ? | rewsapac | _?_ |

### PROD

Some text here

