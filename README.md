# shawk
everyday parsing, language tools, and more

Welcome to shawk!

This project is dedicated to making the programmer life easier by providing
a tool set of small, light tools written mainly in awk with a pinch of bash here
and there added for extra power. If you are wondering why this combination,
please check the 'Why shell + awk?' section at the end.

Below is a short description of each sub-project. Note that the projects are
interdependent in their making but standalone in their execution. E.g. smpg
needs awklib to compile itself, but once compiled, smpg.awk can be taken as is
and used anywhere where awk is available. Similarly, each parser (e.g. ptrip)
would use rdpg and lex-build to generate its components, but once put together
it is standalone. rdpg and lex-build, in their turn, are built on top of awklib,
and so on.

## bash/:

### bashtest
A small, simple test library used throughout. Provides assertions and a stack
trace when an expectation fails.



## awk/:

### awklib
A set of libraries written in awk. Provides data structure abstractions
(vectors, sets, trees, heaps), finite state machine generation, command
execution and some nice conveniences like easy file input, indented output,
sorting and pattern splitting, in case you don't use gawk. awklib_awkdoc.awk is
used to generate documentation from comments, awklib_awktest.awk is used to test
awk scripts when no i/o is needed; i.e. functionality is tested rather than
output.

### genbash
Generates bash boilerplate which can parse short and/or long command line
options. Useful when writing bash wrappers.

### lex-build
Builds lexers. It's divided in a front end and multiple back ends. The front end
takes a short descriptions of all desired character classifications, tokens, key
words, and actions and expands this information so the back end would have the
needed information to generate a lexer. Back ends can be written for different
languages, or even for the same language but with different lexer goals in mind;
e.g. lexing the whole file at once rather than on token by token basis. The
performance of the lexer depends entirely on what the back end outputs.

### make-doc
A wrapper for awklib_awkdoc.awk. Give it an awk script commented according to
its convention and it generates documentation.

### make-test
Give it an awk script and it generates boilerplate test code compliant with
awklib_awktest.awk.

### prep
Prepares strings by substituting positional arguments. Great for command
generation. E.g.:

~~~
$ cat host-cmd
my.host.1;ls ~
my.host.2;rm foo
my.host.2;mkdir bar
$ cat host-cmd | awk -F';' -f prep.awk -vStr='ssh {1} bash -c "{2}"'
ssh my.host.1 bash -c "ls ~"
ssh my.host.2 bash -c "rm foo"
ssh my.host.2 bash -c "mkdir bar"
~~~

### ptrip
A set of tools for parsing the boost ptree info syntax and recreating its
original structure from a single file representation.
https://www.boost.org/doc/libs/1_65_1/doc/html/property_tree/parsers.html#property_tree.parsers.info_parser

### rdpg
A LL(1) optimizing recursive descent parser generator. It's divided in a front
end, a multi level optimizing stage, and (possibly) multiple back ends. It takes
a description of a context free grammar, outputs an intermediate representation
which may or may not pass through the optimizer, which then gets turned into
source code for a target language by a back end. Back ends are trivial to write.

### smpg
A state machine parser generator. Generates a line oriented state machine
parser. This parser works by calling a user defined handler on each state
transition. The first field of each line, excluding empty lines and comments, is
considered the state to transition into. An invalid state transition leads to a
fatal error and parsing stops. In the callback the user can check what (and if)
other data exists on the line and decide what to do with it. Therefore, making
sure an input file has the correct data in the correct order is easy to achieve,
especially with awk's regex. This makes small, domain specific, and mostly
declarative languages trivial to create. Works well for test and code
generators. One curiosity is that smpg is powerful enough to generate itself.
Another is that it is used to generate the parser for rdpg because writing a
compiler compiler without actually having to write a parser for it by hand was
one of the author's laziness goals.



## Why shell + awk?

Mainly because of this serendipitous observation:

The shell takes as input a string, executes one or more commands based on that
string, and these commands output more strings as their result. awk is really
good at working with strings. It can read them, write them, split them, compare
them, match a regex, mostly anything you would want to do with a string. With
the added bonus of doing math. The shell can call awk and awk can call the
shell. The shell can execute any process, thus awk can execute any process.
Therefore awk can provide any input you can provide to the shell and make sense
of any result. The shell and awk are best friends. With their help the Unix
environment turns into this huge high level API. The equivalent of a function
call is now running a process and all data gets an uniform representation - the
string. Which is perfectly readable and writable by humans as well as by awk.
Any script is now possible, all tedium begone! 

But wait - there's more. awk gives you the string, which can represent any
scalar value. It also gives you the hash table, which can represent any object
and data structure. It gives you a runtime stack, so you have recursion. It
gives you pass by reference, so you can return more than a single value. So as
long as your input and your output are text, any and all processing is possible.
And what's made out of text? Source code. You got everything you need to read
source, process source, and write source. And what can you do with that? Create
a language, of course. And that language could as well be able to call the
shell, which can call awk, which can call the shell, which...

P.S.
Also, bash and awk come with virtually any Unix environment, so that's pretty
nice as well.
