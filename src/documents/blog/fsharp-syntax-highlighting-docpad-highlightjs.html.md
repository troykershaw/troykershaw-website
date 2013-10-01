---
layout: post
title: F# syntax highlighting with Docpad and Highlight.js
description: DocPad is a great static site generator. I use it for this site, and am very happy with it. DocPad works very well with Highlight.js to provide syntax highlighting, unfortunately the npm module does not support F#. In this blog post I show you how to fix that.
date: 2013-09-23T08:29
tags:
	- F#
	- DocPad
	- Highlight.js
---
[DocPad](http://docpad.org) is a great static site generator. I use it for this site, and am very happy with it. DocPad works very well with [Highlight.js](http://softwaremaniacs.org/soft/highlight/en/) to provide syntax highlighting, unfortunately the __npm__ module does not support F#.

## Fixing it

Create a new file named __node_modules/docpad-plugin-highlightjs/node_modules/highlight.js/fsharp.js__ and paste in the following:
``` js
/*
Language: F#
Author: Jonas Follesø <jonas@follesoe.no>
Description: F# language definition.
*/
module.exports = function(hljs) {
  return {
    keywords:
      'abstract and as assert base begin class default delegate do done ' +
      'downcast downto elif else end exception extern false finally for ' +
      'fun function global if in inherit inline interface internal lazy let ' +
      'match member module mutable namespace new null of open or ' +
      'override private public rec return sig static struct then to ' +
      'true try type upcast use val void when while with yield',
    contains: [

      {
        className: 'string',
        begin: '@"', end: '"',
        contains: [{begin: '""'}]
      },
      {
        className: 'string',
        begin: '"""', end: '"""'
      },
      {
        className: 'comment',
        begin: '\\(\\*', end: '\\*\\)'
      },
      {
        className: 'class',
        beginWithKeyword: true, end: '\\(|=|$',
        keywords: 'type',
        contains: [
          {
            className: 'title',
            begin: hljs.UNDERSCORE_IDENT_RE
          }
        ]
      },
      {
        className: 'annotation',
        begin: '\\[<', end: '>\\]'
      },
      {
        className: 'attribute',
        begin: '\\B(\'[A-Za-z])\\b',
        contains: [hljs.BACKSLASH_ESCAPE]
      },
      hljs.C_LINE_COMMENT_MODE,
      hljs.inherit(hljs.QUOTE_STRING_MODE, {illegal: null}),
      hljs.C_NUMBER_MODE
    ]
  }
};
```
Now all we need to do is load this at startup. Open __node_modules/docpad-plugin-highlightjs/node_modules/highlight.js/highlight.js__, scroll all the way to the bottom and add
``` js
hljs.LANGUAGES['fsharp'] = require('./fsharp.js')(hljs);
```
just above
``` js
module.exports = hljs;
```
It should look something like
``` js
// ...

hljs.LANGUAGES['clojure'] = require('./clojure.js')(hljs);
hljs.LANGUAGES['go'] = require('./go.js')(hljs);
hljs.LANGUAGES['fsharp'] = require('./fsharp.js')(hljs);
module.exports = hljs;
```

## Using it
If you're writing in markdown, you just need to add __fsharp__ after your back-ticks.
```` markdown
``` fsharp
printf "Hello, world!"
``` 
````