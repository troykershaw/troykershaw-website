---
ignored: true
layout: post
title: How to host a static site on AWS S3
description: From mid June Route 53 allows us to configure Alias (A) records that map to CloudFront. This means that we can host a static website on S3 and deliver it to the world with CloudFront using a root domain.
date: 2013-07-15
tags:
	- S3
	- AWS
---
## What's a static website and why should I care?
You're looking at one, and it's fast and secure.



S3 (or Simple Storage Service) is Amazon's file storage
From mid June Route 53 allows us to configure Alias (A) records that map to CloudFront. This means that we can host a static website on S3 and deliver it to the world with CloudFront using a root domain.

Here's how I set up troykershaw.com to do just that:

## S3 Static Website
Create a new S3 bucket named exactly the same as your domain name. For this site, it was **troykershaw.com**.

Use the cheapest region, as we're pushing it out to CloudFront Edge locations anyway. At the time of writing, this was **US Standard**.

The **Permissions** section will give your account full access to the bucket, but we need to add a policy so that anyone can download content.
Click on **Add Bucket Policy** and paste in the following json. You'll need to change **troykershaw.com** to the name of the bucket.
```json
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Sid": "AddPerm",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::troykershaw.com/*"
		}
	]
}
```
Expand **Static Website Hosting** and make a note of the **Endpoint**, we'll be using this in a moment. Click **Enable website hosting** and enter what the index and error files are for your static site. Make sure to click **Save** before moving on.

Now is a great time to upload your site. You can use the AWS Management Console, or one of many apps. Personally, I use [Transmit by Panic]("http://panic.com/transmit/", "Panic") and am very happy with it. 

Go to the endpoint we took note of earlier (mine was `troykershaw.com.s3-website-us-east-1.amazonaws.com`) to see your site. If your CSS is not being applied, you will need to add the text/css content-type header to each CSS file. Navigate to each CSS file in the S3 console, select Properties > Metadata > Add more metadata and set the key as **content-type** and value as "text/css".

If you're using Transmit, go to **Preferences > Cloud** and add a new extension **css** with the name of **content-type** and value of "text/css".

## CloudFront
It's now time to enable CloudFront for this bucket. Make sure the static website is working before starting this, as it will make solving any problems easier as it takes a few minutes for CloudFront to sync with the S3 bucket after each change.

### Origin Settings

Open the CloudFront Console and click **Create Distribution** and choose the **Download** delivery method.

Paste in the S3 Bucket endpoint into **Origin Domain Name** field. While it seems similar, DO NOT select the bucket from the dropdown, as it will cause access problems later (ask me how I know). 

**Origin ID** allows you to name the origin, I'm boring and kept the default. **Restrict Bucket Access** allows you to disable direct access to your S3 Bucket so that users must go through CloudFront. This sounds like a piece of complexity I don't need, so I left it as **No**, but your needs may be different to mine.

### Default Cache Behavior Settings
Custom CloudFront SSL Certificates cost $600 a month, so I'm going to stick with **HTTP and HTTPS*** for **Viewer Protocol Policy** :)

The defaults for everything else met my needs nicely, but go ahead and click those other radio buttons if you like.

### Distribution Settings
I'm using All Edge Locations under Price Class, you can use less locations to save some coin.

In Alternate Domain Names enter the following, obviously changing troykershaw.com to your domain name: troykershaw.com,www.troykershaw.com

Leave the rest as defaults.

When you're ready, go ahead and click **Create Distribution**. Under **Status** you will see an In Progress animation as your bucket is pushed out to all the CloudFront Edge locations. This can take a while, so go and get something to eat or drink, and I'll see you back here in a few minutes.

Once the distribution has done it's thing, select it and click on the **Distribution Settings** button, copy the **Domain Name** and open it in the browser.

Your website delivered entirely from CloudFront! Quite a nice milestone. Let's point your domain name to it.

## Route 53
Open up the Route 53 Console, click on Create Hosted Zone, enter your domain name and press Create Hosted Zone down the bottom.

Click Go To Record Sets and click Create Record Set.
Leave the name blank, select A - IPv4 address for the Type, and select Yes for Alias.
In Alias Target, enter the endpoint for your CloudFront Distribution. Mine was d2m904fnelmhkf.cloudfront.net

Set the Routing Policy to Simple.

Click Create Record Set

Add another Record Set for the www subdomain. Name: www, Type: A, Alias: Yes, Alias Target: troykershaw.com.	

Next we're going to update our domain name servers to point to the Route 53 ones. This means that we will lose any DNS entries from your old provider, so make sure to create Record Sets for them before moving on.

Go back to Hosted Zones, select the new zone we just created and take note of the name servers in **Delegation Set**. You now need to change your domain settings to point to these name servers. You're on your own for this one, but leave a comment if you're having issues.

Once this is done, we play the usual name server update waiting game. It could be 5 minutes, it could be hours. Once your new web site loads open a terminal and run an nslookup for your domain. Here's what mine looks like:

```bash
$ nslookup troykershaw.com
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	troykershaw.com
Address: 54.230.125.6
Name:	troykershaw.com
Address: 54.230.126.113
Name:	troykershaw.com
Address: 54.230.124.222
Name:	troykershaw.com
Address: 54.230.127.6
Name:	troykershaw.com
Address: 54.230.127.122
Name:	troykershaw.com
Address: 54.230.125.72
Name:	troykershaw.com
Address: 54.230.127.7
Name:	troykershaw.com
Address: 54.230.125.152
```
Now that's a healthy looking name record!