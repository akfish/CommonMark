Log         = require './log'
{ expect }  = require 'chai'

COFFEE_OPTS =
    bare: true
    literate: true

module.exports = class Runner
    # @param Coffee {CoffeeScriptModule}
    # @param spec {SpecFile}
    # @param opts {Options}
    constructor: (@Coffee, @spec, @opts) ->

    run: =>
        # { [level: string]: number }
        totalScore = {}
        # { [level: string]: number }
        errorScore = {}
        # {spec: Spec, error: Error}[]
        errors = []
        console.log "Running #{@spec.groups.length} groups of #{@spec.specCount} specs with coffee-script@#{@Coffee.VERSION}"

        _incCount = ({level}) =>
            totalScore[level] = 0 if not totalScore[level]?
            totalScore[level]++

        _incerrorScore = ({level}) =>
            errorScore[level] = 0 if not errorScore[level]?
            errorScore[level]++

        # @param group {SpecGroup}
        _runGroup = (group) =>
            Log.printGroupHeader group

            group.specs.forEach _runSpec

        # @param spec {Spec}
        _runSpec = (spec) =>
            {id, level, source, expected, expectError, expectCode, map} = spec
            [startLine, endLine] = map

            _incCount spec

            # If we are not expecting either error or code, 
            # the source should not contain any code.
            # In such case, the spec is neutral and the compiler
            # should yield empty result.
            isNeutral = not (expectError or expectCode)
            expected = '\n' if isNeutral

            compile = => @Coffee.compile source, COFFEE_OPTS

            try
                if not expectError
                    actual = compile()
                    expect(actual).to.equal(expected)
                else
                    expect(compile).to.throw(expected)
                Log.printSpecInfo spec, 'passed'
            catch e
                if @opts.throw then throw e
                _incerrorScore spec
                errors.push { spec, error: e }
                Log.printSpecInfo spec, 'failed', errors.length

        @spec.groups.forEach _runGroup

        # Print errors
        Log.printErrors errors

        # Print summary
        Log.printScore errorScore, totalScore

        { totalScore, errorScore, errors }