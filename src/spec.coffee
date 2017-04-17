# Spec Loader
#
# This script parse CommonMark spec into an array of
# ```ts
# interface SpecFile {
#     filename: string
#     specCount: number
#     groups: SpecGroup[]
# }
#
# interface SpecGroup {
#     path: string[]
#     description: string
#     specs: Spec[]
# }
# interface Spec {
#     id: number
#     level: 'pending' | 'proposed' | 'accepted'
#     source: string
#     expected: string
#     expectError: boolean
#     expectCode: boolean
#     map: number[]
# }
# ```

MarkdownIt = require 'markdown-it'
Promise    = require 'bluebird'
{ join }   = require 'path'
readFile   = Promise.promisify require('fs').readFile

md = new MarkdownIt()

# `load` method
# Loads and parses CommonMark spec
#
# @param file {string} Path to spec.txt. If not specified, the default one will be used.
# @return {Promise<SpecFile>} A promise of SpecFile object
#
# ```ts
# interface LoadMethod {
#     (file: string): Promise<SpecGroup[]>
# }
# ```
exports.load = (file) ->
    if not file
        file = join __dirname, '../spec.txt'
    console.log "Loading specs from #{file}"
    readFile file, 'utf-8'
        .then (content) -> 
            f = _parse content
            f.filename = file
            f
        .catch (e) -> console.error e

INFO_STR_REGEX = /^\s*example\s*(\w+)?/
EXAMPLE_REGEX = /^([\s\S]*?)\n+([.!@])\n+([\s\S]*)/gm
HEADING_TAG_REGEX = /^h(\d)/
# `_parse` method (private)
#
# @param content {string} Content of loaded spec.txt
# @return {SpecGroup[]} A SpecGroup array
#
# ```ts
# interface ParseMethod {
#     (content: string): SpecGroup[]
# }
# ```
_parse = (content) ->
    exampleCount = 0
    offset = 0
    currentPath = []
    currentDescription = ''
    moved = false


    # First we parse the file content into tokens with MarkdownIt
    tokens = md.parse(content, {})

    # Conventions:
    # Methods named tryParseXxx will return an offset, possibly mofified
    # Methods named tryGetXxx will return an nullable object without changing offset

    # Advance the offset by one, if no tryParseXxx methods has changed it
    next = () ->
        if not moved
            offset++
        moved = false

    # Check if current block is an example code block
    # If so, try parsing it into an Spec object
    # The example code block should only be top level fence code blocks 
    # marked as `example`.
    # (token: MarkdownIt.Token) => Spec
    tryGetExample = -> 
        token = tokens[offset]
        return null if not token

        {type, tag, info, content, map} = token
        if type is 'fence' and tag is 'code'
            # parse info string
            m1 = INFO_STR_REGEX.exec info
            return null if not m1

            [x, level] = m1

            # parse content
            m2 = EXAMPLE_REGEX.exec content
            if not m2
                console.warn 'WARN:  Could not parse example block'
                console.warn 'Line: ', map
                console.warn 'Path: ', currentPath.join '>'
                console.warn 'Desc: ', currentDescription
                console.warn 'Token: ', token
                return null

            [x, source, splitter, expected] = m2

            # Replace → into \t
            source = source.replace /→/g, '\t'
            spec =
                id: ++exampleCount
                level: level or 'pending'
                source: source
                expected: expected
                expectError: splitter is '!'
                expectCode: splitter is '@'
                map: map

            return spec
        null

    # (
    #   prefix: string, 
    #   token: MarkdownIt.Token, 
    #   cb: (open: MarkdownIt.Token, inline: MarkdownIt.Token, close: MarkdownIt.Token) => void)
    tryParseBlock = (prefix, cb) ->
        token = tokens[offset]
        moved = false if not moved
       
        # Not the beginning of a block
        return offset if token.type isnt "#{prefix}_open"

        # The 2nd token type should be 'inline'
        inline = tokens[offset + 1]
        console.assert(inline.type is 'inline', "expect inline, got #{inline.type}")

        # The 3rd token type should be #{prefix}_close
        close = tokens[offset + 2]
        console.assert(close.type is "#{prefix}_close", "expect #{prefix}_close, got #{close.type}")

        moved = true
        cb token, inline, close
        return offset + 3

        
    # (token: MarkdownIt.Token) => number
    tryParseHeading = ->
        tryParseBlock 'heading', ({tag}, inline) ->
            # Parse level from tag
            [x, level] = HEADING_TAG_REGEX.exec tag
            level = parseInt(level)

            oldPath = currentPath.join()

            # level is 1-based number === index in path + 1
            if level > currentPath.length
                # If the heading is a lower level
                # Push the content into path array
                currentPath.push inline.content
            else
                # Keep paths until last level
                currentPath = currentPath.slice 0, level - 1
                currentPath.push inline.content

            # Reset currentDescription every time the path changes
            currentDescription = '' if oldPath isnt currentPath.join()

    # (token: MarkdownIt.Token) => number
    tryParseParagraph = ->
        tryParseBlock 'paragraph', (open, {content}, close) ->
            currentDescription = content

    groups = []

    newGroup = (path = [], description = '') ->
        # console.log path, description
        path: currentPath.slice()
        description: currentDescription
        specs: []


    currentGroup = newGroup()

    isGroupChanged = ->
        pathChanged = currentGroup.path.join() isnt currentPath.join()
        descriptionChanged = currentGroup.description isnt currentDescription

        pathChanged or descriptionChanged

    pushToGroup = (spec) ->
        if isGroupChanged()
            groups.push(currentGroup) if currentGroup.specs.length > 0
            currentGroup = newGroup(currentPath, currentDescription)
        currentGroup.specs.push(spec) 

    resetRegex = ->
        INFO_STR_REGEX.lastIndex = 0
        EXAMPLE_REGEX.lastIndex = 0
        HEADING_TAG_REGEX.lastIndex = 0


    while offset < tokens.length
        resetRegex()
        offset = tryParseHeading()
        offset = tryParseParagraph()
        next()

        spec = tryGetExample() #token

        pushToGroup(spec) if spec?
    
    # Push last group
    groups.push(currentGroup) if currentGroup.specs.length > 0

    specCount: exampleCount
    groups: groups

