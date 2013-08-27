---
ignored: true
layout: post
title: F# XML Type Provider Memory Leak
description: M
date: 2013-07-14
tags:
	- F#
	- Type Provider
---

#tl;dr
The F# XML Type Provider leaks memory, well `System.Xml.Linq` does anyway. While there is no `Dispose()` method to force dereferencing, calling delete on XElement will reduce the memory use by plenty.




Install `FSharp.Data` from Nuget and add a reference to `System.Xml.Linq`