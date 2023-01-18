---
title: Oracle SQL Commands
author: danijel
date: 2022-12-02 11:00:00 +1000
categories: [Reference]
tags: [reference, sql, oracle]
math: true
mermaid: true
image:
  path: /assets/img/logos/oracle-db580x224_tcm69-40873.jpg
  width: 580
  height: 224
  alt: Oracle DB Logo
---

Commands that make Oracle SQL even better.

## Finding Tables

Where the table we are targeting is called `FINTRANX`, this will confirm if it exists.

```sql
SELECT table_name FROM user_tables WHERE table_name='FINTRANX';
```

## Show Table Indexes

Ensure the `tablename` is in all upper case.

```sql
select index_name from dba_indexes where table_name='tablename';
```