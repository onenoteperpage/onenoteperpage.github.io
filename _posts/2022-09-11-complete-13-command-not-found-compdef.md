---
layout: post
title:  "complete:13: command not found: compdef"
date:  2022-09-11 00:00:00 +1000
author: danijel
categories: [ zsh ]
---

Loading [zsh]() each time on my Terminal produces this result:

{% highlight bash %}
complete:13: command not found: compdef
{% endhighlight %}

To rememdy this, add the following lines in the `~/.zshrc` file:

{% highlight bash %}
# COMPDEF FIX
autoload -Uz compinit
compinit
{% endhighlight %}
