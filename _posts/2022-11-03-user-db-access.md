---
title: DB User Access
author: danijel
date: 2022-11-03 11:00:00 +1000
categories: [Reference]
tags: [reference, sql, idm]
math: true
mermaid: true
image:
  path: /assets/img/logos/sql-illustration.png
  width: 800
  height: 300
  alt: SQL Banner Image
---

Users have access to SQL via dbadmin. How to check they have access and grant their access.

## Required

1. SQLTools setup with `dbadmin` for the target environment


## Check User Account Status

Verify the status of an account using query to list accounts:

```sql
SELECT username, account_status FROM dba_users ORDER BY username DESC;
```

![sql query result 03](/assets/img/2022/11/03/sql-query-03.PNG){: width="359" heigh="201" }


## Verify User Has Access

Firstly, we need to identify if the user has access to the environment we are targeting.

From SQLTools, run the following command to list all the environments that a user has access to _(per user 'AMoffatt')_:

```sql
SELECT * FROM proxy_users WHERE proxy LIKE 'amoffatt%';
```

The returned result shows that user `amoffatt` has access to `CBA9735UAT4`:

![sql query result 01](/assets/img/2022/11/03/sql-query-01.PNG){: width="620" heigh="114" }


## Verify User Priviledge

User has privilidges to particular schemas, if it has been explicitly provided _(per the `RW` being Read/Write and `CBA9735UAT3` being the environment)_:

```sql
SELECT * FROM dba_role_privs WHERE granted_role = 'RW_CBA9735UAT3';
```

The returned result showing that user account `AMOFFATT` does not have Read/Write access to CBA9735UAT3:

![sql query result 02](/assets/img/2022/11/03/sql-query-02.PNG){: width="699" heigh="139" }


## Granting Access

Dependant on user requiring `RO` or `RW` access, select from either command to run as `dbadmin` to trigger. Update the TXT file located at root of environment folder too on APPa/APP1 server to include in environment area too:

```sql
-- grant Read Only access
GRANT RW_CBA9735UAT3 TO amoffatt;

-- grand Read Write access
GRANT RW_CBA9735UAT3 TO amoffatt;
```

Update the `re-grant.txt` file in environment using the following format, to include acess and for auditing purposes:

```text
--RITM0012345
alter user CBA9735UAT3 grant connect through <USERNAME>;
```
