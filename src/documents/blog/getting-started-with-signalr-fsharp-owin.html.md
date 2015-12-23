---
layout: post
title: Getting Started with SignalR using F# and OWIN
description: SignalR allows us to easily push messages back and forth between a client and server using websockets. In this post we're going to create a SignalR server and push some messages back and forth from a website. 
date: 2015-12-23
tags:
	- SignalR
	- F#
	- OWIN
---

[SignalR](http://signalr.net/) allows us to easily push messages back and forth between a client (usually a website) and server using websockets. All of the pain of creating a connection, keeping the connection alive, reconnecting, serialising and deserialising messages, plus lots, lots more is taken care of for you.

In this post we're going to create a SignalR server and push some messages back and forth from a website. You can see the completed source at [github.com/troykershaw/signalr-fsharp-getting-started](https://github.com/troykershaw/signalr-fsharp-getting-started).

Note: This will probably only run on Windows.

## Get the project set up

- Create a new console application. I chose to use .NET 4.6.1, but anything in the 4.x range should work.

  
### Hello, Paket
We're going to use Paket to download and manage our dependencies. Compared to nuget [Paket](https://fsprojects.github.io/Paket/) requires a little effort to set up for a new project but it's totally worth it. Here's how to do it, basically pulled straight from Paket's [Getting Started](https://fsprojects.github.io/Paket/getting-started.html) page

- Open a command window (because it's hard to create a folder with a dot in front of it from Windows Explorer)
- Create a `.paket` folder in the root of your solution (`mkdir .paket`).
- Download the latest [paket.bootstrapper.exe](https://github.com/fsprojects/Paket/releases/latest) into that folder.
- Run .paket/paket.bootstrapper.exe. This will download the latest paket.exe.
- Commit .paket/paket.bootstrapper.exe into your repo and add .paket/paket.exe to your .gitignore file.
- Create a `paket.dependencies` file in your project's root and paste in the following:

```
source https://nuget.org/api/v2

nuget Microsoft.AspNet.SignalR.SelfHost
nuget Microsoft.Owin.Cors
nuget Microsoft.Owin.StaticFiles
nuget FSharp.Interop.Dynamic
```

- In your project create a file named `paket.references` and paste in the following:

```
Microsoft.AspNet.SignalR.SelfHost
Microsoft.Owin.Cors
Microsoft.Owin.StaticFiles
FSharp.Interop.Dynamic
```

- Run the command `.paket\paket.exe install` to install all the dependencies.

Now you've got everything you need for the rest of this blog post.

## Let's get the server running
SignalR is part of the ASP.NET family and runs nicely in a standalone [OWIN](http://owin.org/) server, so let's do that.

- Create a new file called `Signalr.fs` and put it above `Program.fs.
- Here's all we need to get the server running, so paste it in

```fsharp
module Signalr

open Owin
open FSharp.Interop.Dynamic
open Microsoft.AspNet.SignalR
open Microsoft.Owin.Hosting
open Microsoft.Owin.Cors
open Microsoft.AspNet.SignalR.Hubs

type Server (host:string) =
    let startup (a:IAppBuilder) =
        a.UseCors(CorsOptions.AllowAll) |> ignore
        a.MapSignalR() |> ignore

    do
        WebApp.Start(host, startup) |> ignore
        printfn "Signalr server running on %s" host
```

But of course that won't do anything yet.

- Open `Program.fs` and make it look like:

```fsharp
[<EntryPoint>]
let main _ =
    let signalr = Signalr.Server "http://localhost:7777"

    System.Console.ReadLine() |> ignore
    0
```

Now you can run it, and get a loose confirmation that it worked because it printed something to the Console window.

What's happening is `Program.fs` creates an instance of our SignalR server and then doesn't exit because it's waiting for you to press `Enter`. `Signalr.fs` creates a `startup` function that enables CORS and enables Signalr, then we start the OWIN server using that configuration.

## Send some messages to a web page
To actually be useful let's send a message to a web page. We, of course, first need to create a web page and some way of serving that page. We _could_ just tack it on to our current SignalR server but because OWIN servers are so easy to write let's create a new one.

- Create a new file called `Static.fs`, put it above `Program.fs` and paste in the following:

```fsharp
module Static

open Owin
open Microsoft.Owin.Hosting

type Server (host:string) =
    let startup (a:IAppBuilder) =
        a.UseFileServer(true) |> ignore

    do
        WebApp.Start(host, startup) |> ignore
        printfn "Static server running on %s" host
```

We now have a server that serves static files. Let's start it.

- In `Program.fs` add `let staticServer = Static.Server "http://localhost:8777"` after the SignalR server.
- Create an `index.html` page and set the property __Copy to Output Directory__ to __Copy always__.
- Also, paste in the following:

```html
<!DOCTYPE html>
<html>
<body>
    <pre id="message"></pre>
    <script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-2.1.4.min.js"></script>
    <script src="http://ajax.aspnetcdn.com/ajax/signalr/jquery.signalr-2.2.0.min.js"></script>
    <script src="http://localhost:7777/signalr/hubs"></script>

    <script type="text/javascript">
        $(function () {
            // set our hub url
            $.connection.hub.url = "http://localhost:7777/signalr";

            // get our hub
            var hub = $.connection.myFirstHub;

            // function that the server will call
            hub.client.messageToTheClient = function (message) {
                var json = JSON.stringify(message, null, 2);

                // add the message to the page
                $('#message').text(json);
            }

            // connect to the server
            $.connection.hub.start()
                .done(function () {
                    // we've connected, so let's send a message!
                    hub.server.messageToTheServer("Hello from the client!");
                });
        });
    </script>
</body>
</html>
```

When you go to [http://localhost:8777/index.html]() you'll get a blank web page! Yay!

## MyFirstHub

The SignalR client and server relationship communicates over 'hubs', so let's create one of those.

- Within the `Signalr.fs` file and above the `Server` class put this:

```fsharp
[<HubName("myFirstHub")>]
type MyFirstHub () =
    inherit Hub ()

    member x.MessageToTheServer message =
        printfn "Someone sent us a message! - %s" message
```

The `MessageToTheServer` method is what SignalR clients call. If you run our app now and refresh the web page the web page will send the message "Hello from the client!" to our server which you can confirm is happening because it prints it to the console.

## Sending messages
Sending messages to our clients is quite easy, we don't even need to update our hub. What we will do, however, is create a method that consumers of our server can call to send a message.

- Above the `do` in the SignalR `Server` class put:

```fsharp
let clients = GlobalHost.ConnectionManager.GetHubContext<MyFirstHub>().Clients
```
This gives us an easy way to get to our clients.

- Right at the bottom of the class put:

```fsharp
member x.Send message = clients.All?messageToTheClient message
```

In the `Send` method we simply push the message to all clients (`clients.All`) and call the function `messageToTheClient` on the client.

Let's call `signalr.Send` in `Program.fs`. Actually, let's send a message every second.

- Replace `System.Console.ReadLine() |> ignore` with

```fsharp
let rec loop message =
    async {
        signalr.Send message
        do! Async.Sleep 1000
        return! loop message
    }

"The server says hello!"
|> loop
|> Async.RunSynchronously
```

Run our app, refresh the page and the server message appears on the screen. Magic!

## Debugging in Chrome
It's easy to see what's being sent to the client from the server in Chrome.

Go to our webpage, open dev tools (`Ctrl + Shift + I`), select the 'Network' tab and select the 'WS' filter.

Reload the page and you'll see something pop up under 'Name' that reads similar to 'connect?transport=webSockets&clientProtocol=1.5&connectionToken=...'. Select it and then press 'Frames' just to the right of it.

Sure enough, at the top of the list we see the message the client sent and every second after that we see a new message from the server. The `{}` messages are a 10 second heart beat.

## Sending something a little more interesting
Sending a string is fun but there's not a lot we can do with that. Let's send something a little more complex.

We've had too much excitement up until now so I'll bring the mood down a bit by creating a boring `Customer` type.

- Create a new file above all the others called `Customer.fs` and enter the following

```fsharp
module Customer

type Customer =
    {
        Name : string
        Phone : string
        Email : string
        Address : Address
    }

and Address =
    {
        Street : string
        Suburb : string
        City : string
        ZipCode : string
        Planet : string
    }
```

- In `Program.fs` put an `open Customer` at the top of the file and replace the current message we're sending ("The server says hello!") with the following:

```fsharp
{
    Name = "Philip J. Fry"
    Phone = "201 289 654"
    Email = "fry@planetexpress.com"
    Address =
        {
            Street = "Robot Arms Apartments, Apt 00100100"
            Suburb = "Manhattan"
            City = "New New York"
            ZipCode = "10007"
            Planet = "Earth"
        }
}
```

Now when we run the app our web page gets the customer message as nice looking json:

```json
{
  "Name": "Philip J. Fry",
  "Phone": "201 289 654",
  "Email": "fry@planetexpress.com",
  "Address": {
    "Street": "Robot Arms Apartments, Apt 00100100",
    "Suburb": "Manhattan",
    "City": "New New York",
    "ZipCode": "10007",
    "Planet": "Earth"
  }
}
```

## Sending F# things
What happens when we send F# specific things though?

- Update the `Customer` module to use options and those nice [single option discriminated unions that Scott Wlaschin is harping on about](http://fsharpforfunandprofit.com/ddd/)

```fsharp
module Customer

type Customer =
    {
        Name : string
        Phone : Phone option
        Email : Email option
        Address : Address option
    }

and Phone = Phone of string

and Email = Email of string

and Address =
    {
        Street : string
        Suburb : string
        City : string
        ZipCode : ZipCode
        Planet : string
    }

and ZipCode = ZipCode of string
```

- Update the message we're sending in `Program.fs` to:

```fsharp
{
    Name = "Philip J. Fry"
    Phone = Phone "201 289 654" |> Some
    Email = Email "fry@planetexpress.com" |> Some
    Address =
        {
            Street = "Robot Arms Apartments, Apt 00100100"
            Suburb = "Manhattan"
            City = "New New York"
            ZipCode = ZipCode "10007"
            Planet = "Earth"
        } |> Some
}
```

Run everything again.

It worked! Although the json is really, really ugly.

```json
{
  "Name": "Philip J. Fry",
  "Phone": {
    "Case": "Some",
    "Fields": [
      {
        "Case": "Phone",
        "Fields": [
          "201 289 654"
        ]
      }
    ]
  },
  "Email": {
    "Case": "Some",
    "Fields": [
      {
        "Case": "Email",
        "Fields": [
          "fry@planetexpress.com"
        ]
      }
    ]
  },
  "Address": {
    "Case": "Some",
    "Fields": [
      {
        "Street": "Robot Arms Apartments, Apt 00100100",
        "Suburb": "Manhattan",
        "City": "New New York",
        "ZipCode": {
          "Case": "ZipCode",
          "Fields": [
            "10007"
          ]
        },
        "Planet": "Earth"
      }
    ]
  }
}
```

Look at all of those `Case`s and `Field`s. Yuck.

## The good news and the bad news
The good news is that we can serialise _and_ deserialise our Customer record into really clean json. The bad news is that you're going to have to wait for the next installment.

Remember you can check out the source for this post at [github.com/troykershaw/signalr-fsharp-getting-started](https://github.com/troykershaw/signalr-fsharp-getting-started).

Merry Christmas everyone!
