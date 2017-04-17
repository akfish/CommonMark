pkg     = require '../package.json'
_       = require 'lodash'
program = require 'commander'

options = program
    .version(pkg.version)
    .description(pkg.description)
    .option('-f --spec [file]', 'Specify custom spec files')
    .option('-t --throw', 'Throw error on first error')

# Get options from args
#
# @return {Options}
#
# interface Options {
#     // Spec file path
#     spec: string
#     // Throw error on first error
#     throw: boolean
# }
exports.get = ->
    parsed = options.parse process.argv

    _.pick parsed, 'spec', 'throw'