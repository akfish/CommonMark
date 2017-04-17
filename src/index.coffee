#!/usr/bin/env node
# Literate Coffee Script CommonMark Spec Test Runner
# This script exports the main API of this runner

# Require internal modules

Coffee     = require './coffee'
Spec       = require './spec'
Runner     = require './runner'
Options    = require './options'

# Require external modules
Promise    = require 'bluebird'

## `Run` Method
# Runs the test spec against provided compile function:
#
# @param opts {Options} Options
# @return {Promise<RunnerResult>} Promise of a RunnerResult object
#
# ```ts
# interface RunMethod {
#     (opts: Options): Promise<RunnerResult>
# }
#
# interface CoffeeOptions {
#     // CoffeeScript compiler options
# }
#
# ```
exports.run = run = (opts) ->
    Promise.all [
        Coffee.find()
        Spec.load(opts.spec)
    ]
        .then ([CoffeeScript, specs]) ->
            new Runner(CoffeeScript, specs, opts)
                .run()
        .then ({ errors }) ->
            # TODO: only exit with 1 with certain spec level failed
            if errors.length > 0
                process.exit(1)

exports.main = ->
    run Options.get()