---
layout: post
title: Audio on your Mac stopped working? Here's how to start it again
description: If you have a Mac and your audio keeps stopping, I sincerely empathise with your pain. While I haven't got a solution for you, I can help you get it started again with rebooting.
date: 2014-02-14T10:50
tags:
	- Mac
	- OSX
	- Alfred
---
I spend a lot of time deleting emails. I usually have to reply to them first to fit in with social norms, but it is essentially a means to an end; deleting emails is the real goal. My only saving grace is the ability to listen to some nice, relaxing, Nine Inch Nails tracks at the same time. 

This difficult multitasking requirement clearly meant I needed to trade in my solid, robust, fault free 2011 Macbook Air for one of those fancy new Haswell processor models (I needed the i7 of course). 

A few weeks ago, while engaged in a lovely email/music session, tranquility was violently torn from me as my music stopped and refused to start again. Now at least once a day I get to dream of how great my life would be with a Lenovo Yoga 2 Pro. Why? My computer is rebooting because there was another catastrophic, system wide failure of the audio.

While I haven't got a solution yet, I can get the audio started again without rebooting. Just open a terminal and run the following:

``` bash
sudo kextunload /System/Library/Extensions/AppleHDA.kext
sudo kextload /System/Library/Extensions/AppleHDA.kext
```

This will unload and then reload the audio kernel extension.

Do you use [Alfred](http://www.alfredapp.com)? [Download my Alfred workflow](/files/fix-audio.alfredworkflow) to make this nice and simple. Just open Alfred and type 'Fix Audio'.