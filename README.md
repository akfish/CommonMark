CommonMark
==========

CommonMark is a rationalized version of Markdown syntax,
with a [spec][the spec] and BSD-licensed reference
implementations in C and JavaScript.

[Try it now!](http://try.commonmark.org/)

[the spec]:  http://spec.commonmark.org/

For more details, see <http://commonmark.org>.

This repository contains the spec itself, along with tools for
running tests against the spec, and for creating HTML and PDF versions
of the spec.

The reference implementations live in separate repositories:

- <https://github.com/jgm/cmark> (C)
- <https://github.com/jgm/commonmark.js> (JavaScript)

There is a list of third-party libraries
in a dozen different languages
[here](https://github.com/jgm/CommonMark/wiki/List-of-CommonMark-Implementations).

About this fork
---------------

The `LiterateCoffeeScript` branch contains a modified spec.
It is intended for running automatic test of Literate CoffeeScript against the CommonMark spec.

Running tests against the spec
------------------------------

1. Clone this repo
2. Run `npm install`
3. Run `npm link`
4. Run `common-litcoffee`

The `common-litcoffee` command will try find CoffeeScript at:
1. cwd
2. cwd/node_modules/coffee-script
3. Bundled `coffee-script`

Run `common-litcoffee --help` for more information

The spec
--------

The source of [the spec] is `spec.txt`.  This is basically a Markdown
file.

If the Markdown source does not contain code blocks, we use the original 
shorthand form:

    ```````````````````````````````` example
    Markdown source
    .
    expected HTML output
    ````````````````````````````````

If the Markdown source contains valid CoffeeScript syntax, the example should
be written as:

    ```````````````````````````````` example
    Markdown source
    @
    expected JavaScript code (with --bare flag on)
    ````````````````````````````````

If the Markdown source contains empty code blocks, the expected output 
could be empty:

    ```````````````````````````````` example
    No coffee for you
    @
    ````````````````````````````````

Some valid Markdown source should be correctly parsed, but not necesserily 
yeild leagal CoffeeScript syntax. The compiler should parse it correctly,
then throw compiler errors. Such case is written as:

    ```````````````````````````````` example
    Markdown source
    !
    expected error message
    ````````````````````````````````

To allow fine-grained control over the spec adaptation,
a spec level tag can be specified:

    ```````````````````````````````` example [spec_level]
    Markdown source
    @
    expected JavaScript code (with --bare flag on)
    ````````````````````````````````

Possible values are:
* `pending` - This spec's status is not determined. (default)
* `proposed` - This spec is proposed but yet to be adapted by the compiler.
  Failing the test will result in a warning.
* `accepted` - This spec is accepted and will be enforced. 
  Failing the test will result in an error.


Note that **ALL** examples should be run against coffee compiler. The ones 
without CoffeeScript should output empty result.

<del>To build an HTML version of the spec, do `make spec.html`.  To build a
PDF version, do `make spec.pdf`.  For both versions, you must
have the lua rock `lcmark` installed:  after installing lua and
lua rocks, `luarocks install lcmark`.  For the PDF you must also
have xelatex installed.</del>

- [ ]TODO: add build script that supports extends error spec

The spec is written from the point of view of the human writer, not
the computer reader.  It is not an algorithm---an English translation of
a computer program---but a declarative description of what counts as a block
quote, a code block, and each of the other structural elements that can
make up a Markdown document.

Because John Gruber's [canonical syntax
description](http://daringfireball.net/projects/markdown/syntax) leaves
many aspects of the syntax undetermined, writing a precise spec requires
making a large number of decisions, many of them somewhat arbitrary.
In making them, we have appealed to existing conventions and
considerations of simplicity, readability, expressive power, and
consistency.  We have tried to ensure that "normal" documents in the many
incompatible existing implementations of Markdown will render, as far as
possible, as their authors intended.  And we have tried to make the rules
for different elements work together harmoniously.  In places where
different decisions could have been made (for example, the rules
governing list indentation), we have explained the rationale for
our choices.  In a few cases, we have departed slightly from the canonical
syntax description, in ways that we think further the goals of Markdown
as stated in that description.

For the most part, we have limited ourselves to the basic elements
described in Gruber's canonical syntax description, eschewing extensions
like footnotes and definition lists.  It is important to get the core
right before considering such things. However, we have included a visible
syntax for line breaks and fenced code blocks.

Differences from original Markdown
----------------------------------

There are only a few places where this spec says things that contradict
the canonical syntax description:

-   It allows all punctuation symbols to be backslash-escaped,
    not just the symbols with special meanings in Markdown. We found
    that it was just too hard to remember which symbols could be
    escaped.

-   It introduces an alternative syntax for hard line
    breaks, a backslash at the end of the line, supplementing the
    two-spaces-at-the-end-of-line rule. This is motivated by persistent
    complaints about the “invisible” nature of the two-space rule.

-   Link syntax has been made a bit more predictable (in a
    backwards-compatible way). For example, `Markdown.pl` allows single
    quotes around a title in inline links, but not in reference links.
    This kind of difference is really hard for users to remember, so the
    spec allows single quotes in both contexts.

-   The rule for HTML blocks differs, though in most real cases it
    shouldn't make a difference. (See the section on HTML Blocks
    for details.) The spec's proposal makes it easy to include Markdown
    inside HTML block-level tags, if you want to, but also allows you to
    exclude this. It is also makes parsing much easier, avoiding
    expensive backtracking.

-   It does not collapse adjacent bird-track blocks into a single
    blockquote:

        > this is two

        > blockquotes

        > this is a single
        >
        > blockquote with two paragraphs

-   Rules for content in lists differ in a few respects, though (as with
    HTML blocks), most lists in existing documents should render as
    intended. There is some discussion of the choice points and
    differences in the subsection of List Items entitled Motivation.
    We think that the spec's proposal does better than any existing
    implementation in rendering lists the way a human writer or reader
    would intuitively understand them. (We could give numerous examples
    of perfectly natural looking lists that nearly every existing
    implementation flubs up.)

-   The spec stipulates that two blank lines break out of all list
    contexts.  This is an attempt to deal with issues that often come up
    when someone wants to have two adjacent lists, or a list followed by
    an indented code block.

-   Changing bullet characters, or changing from bullets to numbers or
    vice versa, starts a new list. We think that is almost always going
    to be the writer's intent.

-   The number that begins an ordered list item may be followed by
    either `.` or `)`. Changing the delimiter style starts a new
    list.

-   The start number of an ordered list is significant.

-   Fenced code blocks are supported, delimited by either
    backticks (```` ``` ````) or tildes (` ~~~ `).

Contributing
------------

There is a [forum for discussing
CommonMark](http://talk.commonmark.org); you should use it instead of
github issues for questions and possibly open-ended discussions.
Use the [github issue tracker](http://github.com/jgm/CommonMark/issues)
only for simple, clear, actionable issues.

Authors
-------

The spec was written by John MacFarlane, drawing on

- his experience writing and maintaining Markdown implementations in several
  languages, including the first Markdown parser not based on regular
  expression substitutions ([pandoc](http://github.com/jgm/pandoc)) and
  the first markdown parsers based on PEG grammars
  ([peg-markdown](http://github.com/jgm/peg-markdown),
  [lunamark](http://github.com/jgm/lunamark))
- a detailed examination of the differences between existing Markdown
  implementations using [BabelMark 2](http://johnmacfarlane.net/babelmark2/),
  and
- extensive discussions with David Greenspan, Jeff Atwood, Vicent
  Marti, Neil Williams, and Benjamin Dumke-von der Ehe.

Since the first announcement, many people have contributed ideas.
Kārlis Gaņģis was especially helpful in refining the rules for
emphasis, strong emphasis, links, and images.
