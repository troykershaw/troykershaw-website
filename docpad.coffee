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
            email: 'hello@troykershaw.com'
            title: 'Troy Kershaw' 
            description: 'A blog about F#, cycling (road bikes and mountain bikes) and creating music'         
            tagline: 'A blog about F#, cycling and creating music.'
            shortBio: '<t render="md">[F# is awesome](http://www.tryfsharp.org/ "Try F#"), I consider [myself a mountain biker](http://www.strava.com/athletes/tkershaw "My Strava page") but in reality I spend more time on my road bike, and I dabble in music creation using [Ableton Live](https://www.ableton.com/ "Ableton Live").</t>'
            nav: [
                name: 'Blog'
                url: '/blog'
            ,
            ]

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