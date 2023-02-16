---
title: Environment Refresh E2E
author: danijel
date: 2023-02-13 11:00:00 +1000
categories: [Process]
tags: []
mermaid: true
comments: false
image:
  path: /assets/img/post-headers/refresh.jpg
  width: 845
  height: 321
  alt: Refresh-Image
---

## Create Restored RDS Instance

Follow guide to create an RDS instance with accessible endpoint. Obtain endpoint and proceed.

## Configure TNS

> This step requires elevated access to edit the file
{: .prompt-warning }

Locate the `tnsnames.ora` file at `E:\oracle\client\product\12.1.0\client_1\network\admin\tnsnames.ora` and edit in Notepad++. Add the following code to the end of the file, replacing the following:

| Placeholder | Replace with |
|:------------|:-------------|
| &lt;RITM_NUMBER&gt; | RITM number _(including text 'RITM')_ of the Service Now ticket | 
| &lt;CLIENT_ENV&gt; | Client environment name _(ie - CBAUAT4, CBAPROD, HNPROD, etc.)_ |
| &lt;yyyyMMdd&gt; | Date format in string format of `PS> (Get-Date).ToString('yyyyMMdd')` |
| xxxxxxxxxxxx.ap-southeast-2.rds.amazonaws.com | The AWS provided RDS endpoint |

```
<RITM_NUMBER> =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = <RITM_NUMBER>-<CLIENT_ENV>-<yyyyMMdd>.xxxxxxxxxxxx.ap-southeast-2.rds.amazonaws.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = ORCL)
    )
  )
```

Save the document then open the command prompt and test the connectivity by typing:

```cmd
tnsping <RITM_NUMBER>
```

![Desktop View](/assets/img/2023/02/13/tns-ora-ping.png){: width="838" height="168" }
_TNS Ping Output_

### Troubleshooting

- If the ping times out, review security group of the RDS instance

## Export Schema

Export the schema to the **DATA_PUMP_DIR** using the following command, replacing the values:

| Placeholder | Replace with | 
|:------------|:-------------|
| $PASSWORD | Password used for `dbadmin` account |
| $TNS_NAME | &lt;RITM_NUMBER&gt; as provided in the `tnsnames.ora` file earlier |
| $SOURCE_SCHEMA | The schema (SQL user) that is being exported from _(eg - CBAPROD->CBAUAT would be CBAPROD)_ |
| $DUMP_FILE_NAME | Configured with the $SOURCE_SCHEMA and the current date in yyyyMMdd format, utilising `_%U` for oracle formatting _(ie - `CBAPROD_20221224_%U.dmp`)_ |
| $LOG_FILE_NAME | Same as the $DUMP_FILE_NAME without `_U%` at the filename end |

```powershell
expdb dbadmin/$($PASSWORD)@$($TNS_NAME) schemas=$($SOURCE_SCHEMA) dumpfile=$($DUMP_FILE_NAME).dmp logfile=$($LOG_FILE_NAME).log directory=DATA_PUMP_DIR flashback_time=systimestamp
```

Example, using `passW0rd!` as the password and `RITM123458678` as the TNS Name:

```powershell
expdb dbadmin/passW0rd!@`RITM12345678 schemas=CBA9735UAT2 dumpfile=CBA9735UAT2_20221214_%U.dmp logfile=CBA9735UAT2_20221214.log directory=DATA_PUMP_DIR flashback_time=systimestamp
```