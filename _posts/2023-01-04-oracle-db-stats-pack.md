---
title: Oracle DB Stats Pack
author: danijel
date: 2023-01-05 11:00:00 +1000
categories: [Reference, Tools]
tags: [sql, statpack, statspack, stats, pack]
mermaid: true
comments: false
image:
  path: /assets/img/logos/oracle-db580x224_tcm69-40873.jpg
  width: 580
  height: 224
  alt: Oracle DB Logo
---
The Statspack package is a set of SQL, PL/SQL, and SQL*Plus scripts that allow the collection, automation, storage, and viewing of performance data. Statspack stores the performance statistics permanently in Oracle tables, which can later be used for reporting and analysis. The data collected can be analyzed using Statspack reports, which includes an instance health and load summary page, high resource SQL statements, and the traditional wait events and initialization parameters.

## Required
1. Open VPN to REWSAPAC (Legacy PROD)
1. Sql Tools installed
  - Account setup for `dbadmin` access
1. App Server _(prod or non-prod)_ in mRemoteNG
  - syda-pappa08
  - syda-nappa1

## Steps
1. Connect OpenVPN to REWSAPAC
1. Connect to App Server via mRemoteNG
1. Open SQL Tools
1. Find SQL Server and connect using `dbadmin` account
![DB Admin](/assets/img/2023/01/05/sqltools-connection-window.png)
1. Connection to AWS Console via webUI

## Query SQL for Snap IDs

With the SQL Tools connected to the required server and logged in as `dbadmin`, run the following to retrieve the snap records table:

```sql
SELECT snap_id, snap_time FROM stats$snapshot ORDER BY 1 DESC;
```

The results table will display the available snap ID's as a descending list. Finding the start and ending snap ID for the range selected:

![Select Snap ID](/assets/img/2023/01/05/select-snap-id-from-list.png)

With the starting snap ID and the ending snap ID for the required time frame, update the snap ID in the following SQL statement:

```sql
EXEC RDSADMIN.RDS_RUN_SPREPOR(<begin_id>,<end_id>);
```

The process will action a task that will result in a snap report being generated on the server. The SQL Tools confirmation message is shown:

![Processed Snap ID](/assets/img/2023/01/05/snap-id-processed.png)

## Download Stats Pack

Connect to the AWS Console, navigate to the correct environment (prod/non-prod) and select the DB Server. Open the Logs and organise by _Last Written_ then search for any report starting with _trace/ORCL_spreport_ text.

Select the line item and click on **Download** button. Reports are saved in `.lst` format. This can be converted to `.txt` to allow the file to associate with Notepad++ easier.
