---
layout: post
title:  "slmgr Install OA3xOriginalProductKey"
date:  2022-09-07 00:00:00 +1000
author: danijel
categories: [ sysprep ]
---

Install the original product key from the motherboard automatically. Can be scripted.

```powershell
slmgr /ipk $(Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService' | Select-Object -ExpandProperty OA3xOriginalProductKey)
```