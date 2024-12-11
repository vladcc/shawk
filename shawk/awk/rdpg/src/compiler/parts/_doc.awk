# <user_messages>
function use_str() {
	return sprintf("Use: %s [options] <grammar-file>", SCRIPT_NAME())
}

function print_use_try() {
	pstderr(use_str())
	pstderr(sprintf("Try '%s -vHelp=1' for more info", SCRIPT_NAME()))
}

function print_version() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
}

function print_example() {
print "#"
print "# The venerable infix calculator example. Includes the most important aspects of"
print "# rdpg grammar: left + right associativity, alternation, modifiers, and actions."
print "#"
print "# Non-terminals are lowercase, terminals are upper case. Both can begin with a"
print "# letter or _ and be followed by more letters _ and digits."
print "#"
print "# Actions are called 'escapes' because they have the form:"
print "# \\<fname>"
print "# <fname> has the same lexical rules as non-terminals and is a user defined"
print "# function the parser will call while parsing."
print "#"
print "# Modifiers apply to the previous non-terminal like so:"
print "# <nont>? - zero or one times <nont>"
print "# <nont>* - zero or more times <nont>"
print "# <nont>+ - one or more times <nont>"
print "#"
print "# A grammar file has to begin with:"
print "# start : <top-sym>[mod] <eoi-token>"
print "#"
print ""
print "start : expr+ EOI ;"
print ""
print "expr : \\on_expr_start expr_add_sub? SEMI \\on_expr_end ;"
print ""
print "expr_add_sub : expr_mul_div add_sub* ;"
print ""
print "add_sub : PLUS  expr_mul_div \\on_add"
print "        | MINUS expr_mul_div \\on_sub ;"
print ""
print "expr_mul_div : expr_expon mul_div* ;"
print ""
print "mul_div : MUL expr_expon \\on_mul"
print "        | DIV expr_expon \\on_div ;"
print ""
print "expr_expon : expr_base expon? ;"
print ""
print "expon : POW expr_expon \\on_pow ;"
print ""
print "expr_base : MINUS base \\on_neg"
print "          | base ;"
print ""
print "base : NUMBER \\on_number"
print "     | L_PAR expr_add_sub R_PAR ;"
}

function print_help() {
print sprintf("--- %s ---", SCRIPT_NAME())
print ""
print "LL(1) recursive descent parser generator"
print ""
print use_str()
print ""
print "Options:"
printf("-v %s=<n> - quit after <n> number of errors; <n> is positive", OPT_FATAL_ERR())
print ""
printf("-v %s=1    - treat warnings as errors", OPT_WARN_ERR())
print ""
printf("-v %s=1    - turn on all warnings", OPT_WARN_ALL())
print ""
printf("-v %s=1  - warn about unreachable non-terminals", OPT_WARN_REACH())
print ""
printf("-v %s=1    - warn about unreachable escapes", OPT_WARN_ESC())
print ""
printf("-v %s=1      - quit after all grammar checks; don't generate code", OPT_CHECK())
print ""
printf("-v %s=1    - print the expanded grammar and quit", OPT_GRAMMAR())
print ""
printf("-v %s=1      - print the list of rules and quit", OPT_RULES())
print ""
printf("-v %s=1       - print the grammar sets and quit", OPT_SETS())
print ""
printf("-v %s=1      - print the parse table and quit", OPT_TABLE())
print ""
print "-v Example=1    - print example"
print "-v Help=1       - print this screen"
print "-v Version=1    - print version"
print ""
printf("-v %s=1 - default syncing. Same if no sync option is used. Every non-terminal\n", OPT_SYNC())
print "function syncs to the the first token found in the follow set of any of its"
print "rules and returns true. Returns false otherwise. Could lead to an error cascade."
print ""
printf("-v %s=0 - no syncing. All non-terminal functions return false. I.e. the parser\n", OPT_SYNC())
print "stops after a single error is encountered."
print ""
printf("-v %s=\"<nont>=<tok-csv>[;<nont>=<tok-csv>]\" - sync only non-terminals\n", OPT_SYNC())
print "<nont> on tokens in <tok-csv>. <nont> must exist and all tokens in <tok-csv>"
print "must be in its follow set. E.g. \"foo=TOK_A,TOK_B;bar=TOK_C;baz=EOI\" will sync"
print "non-terminal foo only on tokens TOK_A and TOK_B, bar on TOK_C, and baz on EOI."
}

# </user_messages>
