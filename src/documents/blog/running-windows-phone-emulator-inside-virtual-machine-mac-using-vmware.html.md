---
layout: post
title: Running the Windows Phone Emulator inside a virtual machine on a Mac using VMware
description: The Windows Phone Emulator doesn't run in a virtual machine using VWware Fusion on the Mac...or does it?
date: 2014-02-12T21:30
tags:
	- Windows Phone
	- Mac
	- VMware Fusion
---
I've been wanting to have a play with Windows Phone 8 development recently, especially as I'm planning on trading in my worn out iPhone 4s for one of the new Nokia Lumias. I do most of my Windows development on a Mac using VMware Fusion so I fired up a Windows VM, installed the Windows Phone SDK and created a new project.

Pressing play was when everything went wrong.

![Windows Phone Emulator error when running in VMware Fusion](/images/windows-phone-emulator-error-when-running-in-vmware-fusion.png)

You see, the Windows Phone Emulator runs as a virtual machine in Hyper-V, and VMware doesn't like it when you run virtualisation inside of virtualisation.

Fortunately the answer turned out to be rather simple, I just needed to change the virtual machine settings and set 'OS' to **Hyper-V (unsupported)**. You'll find it under the 'Microsoft Windows' group.

![Hyper-V VMware Fusion Settings](/images/hyper-v-vmware-fusion-settings.png)

Start the VM up again, run your project, et voilà: a working Windows Phone Emulator!

I'm not sure what the **(unsupported)** warning means in the OS name, but at the time of writing I've been running it for over three months, so it's pretty stable.