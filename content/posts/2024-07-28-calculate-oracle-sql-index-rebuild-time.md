---
title: "Calculate Oracle SQL Index Rebuild Time"
date: 2024-07-26T09:51:00+10:00
# weight: 1
# aliases: ["/first"]
tags: ["oracle","sql"]
author: "Me"
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Calculate Oracle SQL Index Rebuild Time"
disableHLJS: true # to disable highlightjs
disableShare: true
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "/images/logos/PL-SQL-Commands1.jpg" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---

To count the length of time an index rebuild takes _(regardless of using EE or SE editions of Oracle SQL)_ use the following Oracle SQL command _(this rebuilds the 'ACTIVITY_F1' index)_:

```sql
DECLARE
   v_start_time TIMESTAMP;
   v_end_time TIMESTAMP;
BEGIN
   v_start_time := SYSTIMESTAMP;
   DBMS_OUTPUT.PUT_LINE('Start Time: ' || TO_CHAR(v_start_time, 'YYYY-MM-DD HH24:MI:SS.FF'));

   -- Rebuild the index
   EXECUTE IMMEDIATE 'ALTER INDEX ACTIVITY_F1 REBUILD ONLINE';

   v_end_time := SYSTIMESTAMP;
   DBMS_OUTPUT.PUT_LINE('End Time: ' || TO_CHAR(v_end_time, 'YYYY-MM-DD HH24:MI:SS.FF'));

   DBMS_OUTPUT.PUT_LINE('Duration (seconds): ' || (v_end_time - v_start_time) * 86400);
END;
/
```
