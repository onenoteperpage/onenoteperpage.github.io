---
title: Check Table Exists in Oracle SQL
author: danijel
date: 2023-04-23 11:00:00 +1000
categories: [Other]
tags: [wsl,wsl2,windows]
series: ['MH Reference']
aliases: ['migrate-from-jekyl']
ShowToc: true
TocOpen: true
editPost:
    URL: 'https://github.com/onenoteperpage/mri-docs-v4/content'
    Text: 'Suggest Changes' # edit text
    appendFilePath: true # to append file path to Edit link
---

Verify a table exists, and the number of rows:

```sql
SELECT COUNT(*)
FROM all_tables
WHERE table_name = 'your_table_name' AND owner = 'your_schema_name';
```

Get the data out of said table:

```sql
SELECT * FROM 'your_table_name';
```