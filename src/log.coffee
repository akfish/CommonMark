chalk = require 'chalk' # @param group {SpecGroup}

indent = (str, ind) ->
    str.split('\n')
        .map (line) -> ind + line
        .join('\n')

exports.printGroupHeader = ({path, description}) ->
    console.log chalk.bold.inverse path.join(' > ')
    console.log chalk.yellow indent "#{description}", '  '

# @param spec {Spec}
# @param status {'skipped'|'passed'|'failed'}
# @param errorIndex {number}
exports.printSpecInfo = ({id, map, level}, status = 'passed', errorIndex = -1) ->
    [startLine, endLine] = map
    name = chalk.white "    Example #{id}"
    pos = chalk.grey "@ #{startLine + 1}~#{endLine + 1}"
    switch level
        when 'pending'  then level = chalk.grey level
        when 'proposed' then level = chalk.blue level
        when 'accepted' then level = chalk.cyan level
    level = chalk.white.bold('[') + chalk.grey(level) + chalk.white.bold(']\t')

    result = chalk.green.inverse 'PASS'

    switch status
        when 'failed' then result = chalk.red.inverse   'FAIL'
        when 'skipped' then result = chalk.grey.inverse  'SKIP'
    
    index = if errorIndex > 0 then chalk.red.bold "(#{errorIndex})" else ''

    console.log name, pos, level, result, index

# @param errors {{ spec: Spec, error: Error }[]}
exports.printErrors = (errors) ->
    if errors.length > 0
        console.log()
        console.error chalk.red.inverse "Errors"
        errors.forEach ({spec, error}, i) ->
            console.error chalk.red "(#{i+1}) #{error.message}"
            [startLine, endLine] = spec.map
            console.error chalk.grey "@ #{startLine + 1}~#{endLine + 1}"
            console.error chalk.red indent(JSON.stringify(spec, null, 2), '    ')
            console.error()

# @param level {string}
# @param error {Map<number>}
# @param total {Map<number>}
exports.printScore = (errorMap, totalMap) ->
    console.log()
    console.log chalk.bold.inverse "Summary (error counts)"
    for lvl, total of totalMap
        error = errorMap[lvl] ? 0
        if error == 0
            console.log chalk.green "  #{lvl}: #{error}/#{total}"
        else
            console.error chalk.red "  #{lvl}: #{error}/#{total}"