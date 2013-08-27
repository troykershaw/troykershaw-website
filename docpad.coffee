# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:
        site:
            url: 'http://troykershaw.com'
            author: 'Troy Kershaw'
            twitter: 'troykershaw'
            twitterUrl: 'https://twitter.com/troykershaw'
            github: 'troykershaw'
            githubUrl: 'https://github.com/troykershaw'
            email: 'hello@troykershaw.com'
            emailUrl: 'mailto:hello@troykershaw.com'
            title: 'Troy Kershaw' 
            description: 'A blog about F#'
            tagline: 'A blog about F#'
            nav: [
                name: 'Home'
                url: '/'
                icon: 'icon-home'
            ,
                name: 'Blog'
                url: '/blog/'
                icon: 'icon-pencil'
            ]
            services:
                twitterTweetButton: 'troykershaw'
                twitterFollowButton: 'troykershaw'
                githubFollowButton: 'troykershaw'
                disqus: 'troykershaw'
                googleAnalytics: 'UA-40785803-1'

            social: [
                name: 'Github'
                url: 'https://github.com/troykershaw'
                icon: 'icon-github-sign'
            ,
                name: 'Twitter'
                url: 'https://twitter.com/troykershaw'
                icon: 'icon-twitter-sign'
            ,
                name: 'Feed'
                url: 'http://feeds.feedburner.com/TroyKershaw'
                url: '/feed'
                icon: 'icon-rss-sign'
            ,
                name: 'Email'
                url: 'mailto:#{site.email}'
                url: 'mailto:hello@troykershaw.com'
                icon: 'icon-envelope'
            ]
            
            googleAnalytics: 'UA-40785803-1'

        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')


    # =================================
    # Collections

    collections:
        posts: ->
            @getCollection("html").findAllLive({relativeOutDirPath: 'blog'}, [date:-1])
    

    # =================================
    # Plugins

    plugins:
        navlinks:
          collections:
            posts: -1
        cleanurls:
            trailingSlashes: true



    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki
    events:
        # Write After
        # Used to minify our assets with grunt
        writeAfter: (opts,next) ->
            # Prepare
            balUtil = require('bal-util')
            docpad = @docpad
            rootPath = docpad.config.rootPath

            command = ["#{rootPath}/node_modules/.bin/grunt", 'default']
            # Execute
            balUtil.spawn(command, {cwd:rootPath,output:true}, next)
            # Chain
            @
}

# Export the DocPad Configuration
module.exports = docpadConfig