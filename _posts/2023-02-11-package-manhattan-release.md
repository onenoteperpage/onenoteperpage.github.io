---
title: Package Manhattan Release
author: danijel
date: 2023-02-11 11:00:00 +1000
categories: [Process, Packaging]
tags: []
mermaid: true
comments: false
image:
  path: /assets/img/post-headers/refresh.jpg
  width: 845
  height: 321
  alt: Refresh-Image
---

Packaging SPR using Pre-Req tool for Manhattan release.

## Connect to Engineering Prereq Tool via RDP

1. Open browser and navigate to [https://lhra-e-portal.trimble-app.uk/RDWeb/Pages/en-US/login.aspx](https://lhra-e-portal.trimble-app.uk/RDWeb/Pages/en-US/login.aspx)
1. Login with `eng\<username>` and password
1. Select **Prereq Tool** icon from applications available
1. RDP file will download to local system, open this to connect to the application
1. May be prompted to login again using same credentials

![prereq tool](/assets/img/2023/02/11/select-prereq-tool.png){: width="681" heigh="284" }

## Select Client

1. Select client from the drop down `Client` and then the area from drop down `Area`
1. Click on the small **dot** button next to the client to open up SPR history _(see blue arrow)_

![prereq tool 01](/assets/img/2023/02/11/prereq-01.png){: width="632" heigh="179" }

## Review SPR History

1. Review the SPR history
1. The order of patches can be used to confirm what has been requested previously

![prereq tool 02](/assets/img/2023/02/11/prereq-02.png){: width="1156" heigh="542" }

## Add SPRs to Pre-Req

1. CLick on the **Multiple** button _(orange)_ to open the **VC_PREREQ_LIST** window
1. Paste in all the SPRs, one per line _(blue)_, with no spaces
1. Click on the **green tick** button _(green)_ to accept

![prereq tool 02](/assets/img/2023/02/11/prereq-02.png){: width="736" heigh="307" }
