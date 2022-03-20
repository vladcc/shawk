lex-first.awk -- the lex-build front end

I. General Framework

Each stage of the generation is a separate awk script. If you'd like to generate
a lexer in C from a description in input.lb:

$ awk -f lex-first.awk input.lb | awk -f lex-c.awk

Generally, the following lexing strategy is supposed to be used:

1. Classify characters - e.g. '(' is of class LPAR, '+' is of class PLUS, '0-9'
are of class NUM, 'a-zA-z_' are of class WORD, etc. LPAR, PLUS, NUM, and WORD
should be constants in the target language. The lexer looks up which character
is of which class.

2. Read a character and perform a primary action according to its class:

	2.1. Return a token if the character is a token by itself. E.g. you've read
	'(' and you know it can only be an opening parenthesis, so return TOK_LPAR.

	2.2. Return the result of a user defined function. E.g. you've read a
	character of class NUM and you know you need to read a numeric constant.
	This is supposed to be achieved by calling a user function. The user defines
	how numbers are read and evaluated, and returns TOK_NUM, or whatever the
	internal token representation is, to the lexer.

	2.3. Perform a non-token action. E.g. you've read a '\n', bump up the line
	counter.

3. Perform a secondary action to resolve multi character tokens:

	3.1. Peek at the next character and branch if needed. E.g. you've read '+',
	but "+", "++", and "+=" are all tokens in your language, so the lexer looks
	at the next character for resolution.

How each of the above steps are implemented depends on the particular target
language.

II. Front End and Syntax

1. Front End

lex-first.awk is the front end script. It does very little - expands character
ranges, generates automatic character classes so the user doesn't have to type
them all, and makes sure tokens, keywords, etc. do not repeat.

2. Syntax

The front end and the back ends read the same form of syntax. It constitutes of
five parts, each of which marked by a beginning delimiter and the string "end"

The data for each data part is split into two fields - the first filed is all
space delimited fields but the last, the second field is only the last space
delimited field. E.g.

id TOK_ID

creates a token identified by the constant TOK_ID and the string "id".

function call TOK_FCALL

creates a token identified by the constant TOK_FCALL and the string
"function call".

This field separation is implied in the text below, including the syntax
definitions. Note that it is useful mostly for the 'patterns' data part and can
be safely ignored where it does not make sense.

Comments can only appear outside of data parts and be full lines which
begin with a '#', possibly preceded by white space. Empty lines are ignored.

These actual data parts are:

2.1. char_tbl - contains the mapping for characters and their classes. It takes
the form:

<char>|<char-range>|<char-esc>    <const>

<char>       is a single character without any quotes around it, e.g. z
<char-range> is the usual character range syntax, e.g. a-z
<char-esc>   recognizes \t, \n, \0, \r, and \s. \s is the space character, since
it cannot exist literally in the input.
<const>      is the usual C const syntax I_AM_C0NST4NT, so '[A-Z][A-Z_0-9]+'
Note that this is not strongly enforced, but the constants are used to generate
identifiers, e.g. enums in C, or function names in other languages, so they
should comply to the rules for identifiers in the target language.

Example:
char_tbl
	\s    CH_CLS_SPACE
	\t    CH_CLS_SPACE
	a-z   CH_CLS_LOWER
	+     CH_CLS_PLUS
end

Output from lex-first.awk:
char_tbl
        \s      CH_CLS_SPACE
        \t      CH_CLS_SPACE
        a       CH_CLS_LOWER
        b       CH_CLS_LOWER
        ...
        z       CH_CLS_LOWER
        +       CH_CLS_PLUS
end

2.2. symbols - contains the list of multi character tokens. It takes the form:
<token>|<const>    <const>

<token> is the literal token string without any quotes, e.g. +=
<const> can appear in the first and the second field. In the first field it
signals a token which does not have a string representation, e.g. end of input.

Example:
symbols
	+    TOK_PLUS
	+=   TOK_PLUSEQ
	*    TOK_MULT
	&    TOK_AMPSND
	EOI  TOK_EOI
end

Output from lex-first.awk:
char_tbl
        +       CH_CLS_AUTO_1_
        *       CH_CLS_AUTO_2_
        &       CH_CLS_AUTO_3_
end
symbols
        +       TOK_PLUS
        +=      TOK_PLUSEQ
        *       TOK_MULT
        &       TOK_AMPSND
        EOI     TOK_EOI
end

Note that the front end creates character classes automatically if the first
character of a token is not in char_tbl already. The symbols are used for
literal string representation of the tokens and also for generating if - else if
trees. E.g. in C:

...
case CH_CLS_AUTO_1_: /* + */
	tok = TOK_PLUS
	if ('=' == peek_ch())
	{
		tok = TOK_PLUSEQ
...


2.3. keywords - this is the hacky part. Keywords are treated differently than
other tokens. Usually, when a user reads an id, they will then have to see if
that id is really an id, or if it's a keyword. The exact way this is done
depends on the target language, but it's usually something like:

function usr_read_id() {
	lex_save_init() # zero out the save buffer
	lex_save_ch()   # we know current char is of CH_CLS_WORD
	
	while (lex_is_next_ch_cls(CH_CLS_WORD)) {
		lex_read()
		lex_save_ch()
	}

	# return TOK_ID if what is saved is not a keyword, or the keyword otherwise
	return lex_keyword_or_base(TOK_ID)
}

Has the form:
<string>    <const>

Example:
keywords
        if    TOK_IF
        else  TOK_ELSE
        elif  TOK_ELIF
        while TOK_WHILE
end

Keywords pass through and are not processed by the front end.

2.4. patterns - this is where more complex tokens are listed, like numeric
constants and ids. Has the form:
<string>    <const>

Example:
patterns
        id     TOK_ID
        number TOK_NUMBER
end

Not that these are place holders only. Nothing else is supposed to be done with
them other than insert them in the token representation table, so when the user
requests the string for TOK_ID, they get back "id". To actually read the id or
number, a user defined function is called. See below.

2.5. actions - this is where character classes get associated with actions. The
writer of the back end distinguishes between the different kinds of actions and
handles them in accordance to their target language. Has the form:
<const>    <fcall>|<special>|<const>

The <const> in the first field is supposed to be a previously defined character
class. It can be anything in the second field, as it'd be left for the writer to
handle.
<fcall>     represents a user callback. It is any string which ends in (),
e.g. get_word()
<special>   there are two special actions - next_ch and next_line. next_ch is
supposed to represent moving on to the next character, and next_line,
unsurprisingly, moving on to the next line. Both help specify now to handle
spaces and new line characters.

Example:
actions
        CH_CLS_SPACE    next_ch
        CH_CLS_NEW_LINE next_line
        CH_CLS_EOI      TOK_EOI
        CH_CLS_WORD     get_word()
        CH_CLS_NUMBER   get_number()
end

A full listing of an example input:
--------------------------------------------------------------------------------
# comment
char_tbl
	\s  CH_CLS_SPACE
	\t  CH_CLS_SPACE
	_   CH_CLS_WORD
	a-z CH_CLS_WORD
	A-Z CH_CLS_WORD
	0-9 CH_CLS_NUMBER
	<   CH_CLS_LESS_THAN
	>   CH_CLS_GREATER_THAN
	\n  CH_CLS_NEW_LINE
	\0  CH_CLS_EOI
end

symbols
	=  TOK_EQ
	== TOK_EQEQ
	=== TOK_EQEQEQ
	==! TOK_NEQEQEQ
	=! TOK_NEQ
	<  TOK_LESS
	>  TOK_GT
	<= TOK_LEQ
	>= TOK_GEQ
	&  TOK_AND
	EOI TOK_EOI
end

keywords
	if    TOK_IF
	else  TOK_ELSE
	elif  TOK_ELIF
	while TOK_WHILE
end

patterns
	id     TOK_ID
	number TOK_NUMBER
end

actions
	CH_CLS_SPACE    next_ch
	CH_CLS_NEW_LINE next_line
	CH_CLS_EOI      TOK_EOI
	CH_CLS_WORD     get_word()
	CH_CLS_NUMBER   get_number()
end
--------------------------------------------------------------------------------
