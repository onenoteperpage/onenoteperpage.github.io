---
layout: post
title:  "complete:13: command not found: compdef"
author: danijel
categories: [ zsh ]
tags: [red, yellow ]
#image: assets/images/OIP.jfif
description: "complete:13: command not found: compdef"
featured: false
hidden: false
---

Loading [zsh]() each time on my Terminal produces this result:

```zsh
complete:13: command not found: compdef
```

To rememdy this, add the following lines in the `~/.zshrc` file:

```zsh
# COMPDEF FIX
autoload -Uz compinit
compinit
```
