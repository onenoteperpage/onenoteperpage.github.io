---
layout: post
title:  "slmgr Install OA3xOriginalProductKey"
author: danijel
categories: [ sysprep ]
tags: [red, yellow ]
#image: assets/images/image-2-1024x540.png
description: "Install product key from motherboard"
featured: false
hidden: false
---

Install the original product key from the motherboard automatically. Can be scripted.

```powershell
slmgr /ipk $(Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService' | Select-Object -ExpandProperty OA3xOriginalProductKey)
```