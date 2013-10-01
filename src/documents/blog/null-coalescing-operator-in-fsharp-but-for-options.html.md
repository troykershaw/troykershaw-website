---
layout: post
title: ?? operator in F# (but for Options!)
description: ?? in C# is expressive and awesome. In this post I show how you can do the same thing in F#, but for Options as well.
date: 2013-08-21
tags:
	- F#
	- Operators
---
## tl;dr

`??` in C# is expressive and awesome. You can do the same thing in F# for `option` values by defining the following operator:
``` fsharp
let inline (|?) (a: 'a option) b = if a.IsSome then a.Value else b
```
which lets you do this:
``` fsharp
let someDate = Some DateTime.Now
let (noneDate: DateTime option) = None

//prints the current date & time
printf "%A" (someDate |? DateTime.MinValue)

//prints 1/01/0001 12:00:00 AM
printf "%A" (noneDate |? DateTime.MinValue)
```

## What the ?? is null-coalescing?

One thing I really miss in F# is the `??` operator in C#. It's called **null-coalescing** and [MSDN has a pretty good description](http://msdn.microsoft.com/en-us/library/ms173224.aspx) of what it does:

> A nullable type can contain a value, or it can be undefined. The ?? operator defines the default value to be returned when a nullable type is assigned to a non-nullable type. If you try to assign a nullable value type to a non-nullable value type without using the ?? operator, you will generate a compile-time error. If you use a cast, and the nullable value type is currently undefined, an InvalidOperationException exception will be thrown.

To summarise, I think of `??` as **if [left] is not null then [left] else [right]**.

It's really useful when dealing with Nullable types. So instead of this...
``` csharp
var nullDate = new DateTime? ();
if (nullDate.HasValue) {
	Console.WriteLine (nullDate.Value);
} else {
	Console.WriteLine (DateTime.MinValue);
}
```
you can write this...
``` csharp
var nullDate = new DateTime? ();
Console.WriteLine (nullDate ?? DateTime.MinValue);
```
## Do it in F\# ##
F# doesn't have an equivalent operator, so let's define one.
``` fsharp
let inline (|??) (a: 'a Nullable) b = if a.HasValue then a.Value else b
```
Now you can use `|??` in F# just as you would in C#. Here's an example:
``` fsharp
let nullDate = new (DateTime Nullable)()
printf "%A" (nullDate |?? DateTime.MinValue)
```
We're on par with C#'s simplicity, but let's be honest, `null` is for the uneducated.

## Option-coalescing (yep, just made that up)
Let's do the same thing for **option** values, ie. **if [left] is Some then [left] else [right]**. Implementing this is as easy as it sounds, the hardest part is coming up with another operator.
``` fsharp
let inline (|?) (a: 'a option) b = if a.IsSome then a.Value else b
```
Here we're defining a new operator `|?` that takes an `option` on the left and the default value on the right. Here's how you use it:
``` fsharp
let someDate = Some DateTime.Now
let (noneDate: DateTime option) = None

//prints the current date & time
printf "%A" (someDate |? DateTime.MinValue)

//prints 1/01/0001 12:00:00 AM
printf "%A" (noneDate |? DateTime.MinValue)
```
You get some nice type checking with this implementation too, as the right side of the operator must have the same underlying type as the `option` on the left. This means the following won't compile:
``` fsharp
printf "%A" (optionDate |? "This will error as it's not a DateTime")
```
I hope it helps.