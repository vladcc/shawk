## rdpg
LL(1) recursive descent compiler-compiler

rdpg takes a LL(1) context free grammar and translates it to a recursive descent
parser for a target language.

Its goals are simple and succinct grammar representation, portability, and
human readable, optimized where possible, non-pessimized where not output.

The frontend and the backends are separate awk programs. Running them has the
general form:

```
$ rdpg-comp.awk <grammar-file> | rdpg-to-<desired-language>.awk
```

rdpg-comp.awk compiles the grammar to IR, which is then piped into a backend in
the typical Unix fashion, give or take command line options. Checks are
performed on the grammar to confirm it's LL(1). Token synchronization on error
can be none, automatic, or specified by the user. The automatic one tends to
generate the usual error cascades in some cases, works well in others. The
cascades can be avoided by specifying how to synchronize as described in the
help message.

rdpg generates the parser only - a lexer which works with the tokens specified
in the grammar has to be implemented separately and provided by the user. The
API between the parser and lexer is specified per backend.

All `rdpg-*.awk` provide a help message when run with `-v Help=1`, e.g.

```
$ rdpg-to-c.awk -v Help=1
```

The compiler produces optimized code. Optimized meaning no tail recursion and
the branching logic tries to do the minimum work necessary, e.g. compare only a
single token rather than do a set lookup, where applicable.

The grammar rdpg takes looks like this:

```
#
# The venerable infix calculator example. Includes the most important aspects of
# rdpg grammar: left + right associativity, alternation, modifiers, and actions.
#
# Non-terminals are lowercase, terminals are upper case. Both can begin with a
# letter or _ and be followed by more letters _ and digits.
#
# Actions are called 'escapes' because they have the form:
# \<fname>
# <fname> has the same lexical rules as non-terminals and is a user defined
# function the parser will call while parsing.
#
# Modifiers apply to the previous non-terminal like so:
# <nont>? - zero or one times <nont>
# <nont>* - zero or more times <nont>
# <nont>+ - one or more times <nont>
#
# A grammar file has to begin with:
# start : <top-sym>[mod] <eoi-token>
#

start : expr+ EOI ;

expr : \on_expr_start expr_add_sub? SEMI \on_expr_end ;

expr_add_sub : expr_mul_div add_sub* ;

add_sub : PLUS  expr_mul_div \on_add
        | MINUS expr_mul_div \on_sub ;

expr_mul_div : expr_expon mul_div* ;

mul_div : MUL expr_expon \on_mul
        | DIV expr_expon \on_div ;

expr_expon : expr_base expon? ;

expon : POW expr_expon \on_pow ;

expr_base : MINUS base \on_neg
          | base ;

base : NUMBER \on_number
     | L_PAR expr_add_sub R_PAR ;
```

Note that the user does not, cannot, and does not need to use epsilon and tail
recursion to indicate optionality and repetition. This is achieved with the
`?*+` modifiers. Also, `?*+` always consume as much as they can.

Spaces and new lines in the syntax have no special meaning.

Upper case names are terminals and stand for the token the lexer is expected to
return. They translate to named constants, e.g. and an enum in C which both the
lexer and the parser know about.

Lower case names are non-terminals and translate to function calls. The escaped
non-terminals, e.g. `\on_number`, become calls to user defined functions with
the same name. The arguments they take, if any, are defined per backend.

The bar character `|` indicates alternation. It can literally be read as "or".

The colon character `:` begins the rule list for a certain left hand side
non-terminal. A semicolon `;` ends same rule list.

The `start` symbol is special and must always be present with the syntax
specified in the example.

To see what the generated code from the above grammar looks like, check the
`examples/` directory. For technical information, see HACK.md
