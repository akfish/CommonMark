Promise = require 'bluebird'
{ join } = require 'path'

tryGetCoffee = (modPath) ->
    try
        console.log "Looking for CoffeeScript at #{modPath}"
        cof = require modPath
        console.assert(typeof cof.VERSION is 'string')
        console.assert(typeof cof.compile is 'function')
        return cof
    catch e
        return null

# `find` method
# Find and require a CoffeeScript module
# It tries to look for CoffeeScript in the following order:
# 1. Check if process.cwd() is a CoffeeScript fork
# 2. Check if process.cwd()/node_modules contains CoffeeScript installation 
# 3. Load CoffeeScript bundled in this package as fallback
#
## interface CoffeeScriptModule {
#     VERSION: number
#     compile: (source: string, compilerOpts: CoffeeOptions) => string
#     // Other CoffeeScript APIs
# }
#
# @return {Promise<CoffeeScriptModule>} Promise of a CoffeeScript module
exports.find = ->
    # Find in process.cwd()
    cwd = process.cwd()
    Coffee = tryGetCoffee cwd 
    Coffee = tryGetCoffee join(cwd, 'node_modules/coffee-script') if not Coffee
    if not Coffee
        console.log "Fall back to bundled coffee-script"
        Coffee = require('coffee-script')
    Promise.resolve Coffee