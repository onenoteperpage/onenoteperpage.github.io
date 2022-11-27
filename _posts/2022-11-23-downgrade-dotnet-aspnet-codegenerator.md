---
layout: post
title:  "Downgrade dotnet aspnet codegenerator"
date:  2022-11-23 00:00:00 +1000
author: danijel
categories: [ dotnet-cli ]
---

Recently having installed [.NET 7.0](https://dotnet.microsoft.com/en-us/download/dotnet/7.0), I accidentally updated my [dotnet-aspnet-codegenerator](https://github.com/dotnet/Scaffolding) scaffolding tool too.

Nuget did not show any previous packages that I could install, so I removed it globally, then following the advise of [this github ticket](https://github.com/dotnet/Scaffolding/issues/1518) I was able to install the correct version I need again.

```zsh
# list all tools installed
dotnet tools list --global

# uninstall
dotnet tool uninstall dotnet-aspnet-codegenerator --global

# install correct version
dotnet tool install dotnet-aspnet-codegenerator --version="6.0.10" --global
```

Also in the root directory, create a `global.json` file:

```json
{
  "sdk": {
    "version": "6.0.403"
  }
}
```
