This documents explains some technical aspects about the project.

## The building process

Any final script which the user is supposed to run (i.e. `rdpg-comp.awk` and the
backends) is called a target. A target may be composed of multiple parts, which
may in turn be targets. The process of building a target involves recursively
building its parts, if any, compiling the final script by cat-ing all its parts
together, testing it, and placing it in a delivery directory. Building is done
with make. A typical make looks like this:

```
$ make
make target   - compiler + sure + place to project dir
make compiler - make the compiler
make sure     - test + check
make test     - run tests
make testv    - run verbose tests
make help     - this screen
```

E.g. if you run `make target` for the compiler in `src/compiler`, the compiler's
parser will need to be built first, so make will run `make target` in
`src/compiler/parser`. To build the parser, the lexer will have to be built
first, so make will run `make target` in `src/compiler/parser/lexer`. If
successful, make will put a final `_lexer.awk` file in
`src/compiler/parser/parts`, which will then be used for the parser. Similarly,
when the parser is put together, make will put a final `_parser.awk` in
`src/compiler/parts`, which will then be used for the compiler. Finally, make
will assemble the final `rdpg-comp.awk`, put it in the project root directory,
and make it executable.

If there is a failure along the way, let's say when building the lexer, make
stops. The already existing `src/compiler/parser/parts/_lexer.awk` file is not
changed, which means that running `make parser` in `src/compiler/parser` can
still produce a parser with the previous version of the lexer.

The above is not only convenient but also important because rdpg is
self-hosting. E.g. to build `rdpg-comp`, `rdpg-comp` and `rdpg-to-awk` are used.
If a new version of `rdpg-comp`, let's say, fails a test, it will not be
delivered outside of `src/compiler`, leaving the previous, working version of
`rdpg-comp` in the project's root directory available to build `rdpg-comp`
again.

For the backends building is not as hierarchical as for the frontend because all
backends share the same parser and main file. This means if you run `make to-c`
from `src/backends`, the parser will be built and placed in
`src/backends/common`, then make will run `make target` in `src/backends/to-c`,
which will use `src/backends/common/_parser.awk`. If you run `make to-c`, or
`make target` from `src/backends/to-c`, however, make will try to compile only
the C backend without building the parser first.

## Testing

Testing is done with shell scripts. It's nothing more than running the
executable with some input, asserting exit codes, and diff-ing the output
with an accepted output file.

For the frontend it's very straightforward - each component has its own tests.

For the backends testing is divided into a common set of tests which are
performed for all backends in `src/backends/tests` and each backend has its own
tests in e.g. `src/backends/to-c/test-base`. The backend specific test code is
in `test-base/src.sh`, which gets sourced by `src/backends/tests/run-tests.sh`,
which then calls the custom code.

## Writing a backend

Rdpg is engineered so writing backends is as easy as possible, abstracting away
the common and leaving only the target language specific parts to worry about.
Backends look very much the same in structure, e.g.

```
$ tree src/backends/to-c/
src/backends/to-c/
├── makefile
├── parts
│   └── _to_c.awk
├── rdpg-to-c.awk
└── test-base
    ├── accept
    │   ├── err.txt
    │   ├── help.txt
    │   └── version.txt
    ├── expected_tests.txt
    ├── performed_tests.txt
    └── src.sh
```

```
$ tree src/backends/to-awk/
src/backends/to-awk/
├── makefile
├── parts
│   └── _to_awk.awk
├── rdpg-to-awk.awk
└── test-base
    ├── accept
    │   ├── err.txt
    │   ├── help.txt
    │   └── version.txt
    ├── expected_tests.txt
    ├── performed_tests.txt
    └── src.sh
```

`parts/_to_c.awk and parts/_to_awk.awk` contain both a copy of
`src/backends/template/_bd_template.awk` along with the language specific stuff.

`_bd_template.awk` is a list of the callbacks a backend has to implement, such
as `on_if()`, `on_else_if()` and so on. These functions are called by the common
parser after parsing the IR and constructing the AST (see `_ast_traverse()` in
`src/backends/parser/ast/parts/_ast_usr.awk`). This makes outputting the final
program more convenient but also means there isn't necessarily a 1-to-1
relationship between how the IR reads and how the callbacks are called.

A backend is concerned only with how to output the target language from the
callbacks. Not only to make sure the final syntax is correct but also to answer
questions like how many files would be needed and how the API between the parser
and the lexer would look like.

E.g. two files are needed for C - a source and a header. `to-c` also makes sure
static variables are not used in the parser and public functions can be
generated with different names, e.g. `rdpg_parse_foo()`, `rdpg_parse_bar()`,
therefore making the parser thread safe and making it possible to have more than
one parser in the same program. It also makes sure all sets are statically
initialized, therefore omitting the work of run-time initialization.

`to-awk`, on the other hand, does not shy away from using static variables and,
as of the time of writing, is not concerned with providing more than one parser
per program. Also, with awk static initialization is not an option - the sets
need to be initialized on run-time before running the parser.

## General structure

```
$ tree -d rdpg/
rdpg/
├── examples                    # examples of generated code
│   ├── awk
│   ├── c
│   └── ir
└── src                         # all rdpg source
    ├── backends                # all backend source
    │   ├── common              # common source for all backends
    │   ├── parser              # one IR parser for all backends
    │   │   ├── ast
    │   │   │   └── parts
    │   │   ├── lexer
    │   │   │   ├── parts
    │   │   │   └── tests
    │   │   │       ├── accept
    │   │   │       └── data
    │   │   ├── parts
    │   │   ├── prs
    │   │   │   └── parts
    │   │   └── tests
    │   │       ├── accept
    │   │       └── data
    │   ├── template            # the source template for all backend events
    │   ├── tests
    │   │   ├── accept
    │   │   ├── grammar
    │   │   ├── inputs
    │   │   ├── to-awk-test-src
    │   │   └── to-c-test-src
    │   ├── to-awk              # awk specific
    │   │   ├── parts
    │   │   └── test-base
    │   │       └── accept
    │   └── to-c                # C specific
    │       ├── parts
    │       └── test-base
    │           └── accept
    ├── common                  # files common to the front and backends
    └── compiler                # the frontend
        ├── parser
        │   ├── ast
        │   │   └── parts
        │   ├── lexer
        │   │   ├── parts
        │   │   └── tests
        │   │       ├── accept
        │   │       └── data
        │   ├── parts
        │   ├── prs
        │   │   └── parts
        │   └── tests
        │       ├── accept
        │       └── grammars
        ├── parts
        ├── sync
        │   ├── parts
        │   └── tests
        │       └── accept
        └── tests
            ├── accept
            │   ├── checks
            │   │   ├── err
            │   │   └── warn
            │   ├── fatal_err
            │   ├── flags
            │   │   ├── grammar
            │   │   ├── rules
            │   │   ├── sets
            │   │   └── tbl
            │   ├── messages
            │   ├── misc
            │   ├── sets
            │   └── sync
            └── data
                ├── checks
                │   ├── err
                │   └── warn
                ├── fatal_err
                ├── flags
                ├── misc
                ├── sets
                └── sync

81 directories
```
