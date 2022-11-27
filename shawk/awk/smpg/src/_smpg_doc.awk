# <smpg_messages>
function print_help() {
print SCRIPT_NAME() " -- a finite state machine parser generator"
print get_use_str()
print_nl()
print "All options are supplied in the typical '-v' awk fashion."
print_nl()
print "Options:"
print "-v Doc=1"
print "Print a description of the fsm parser idea and documentation for " SCRIPT_NAME()
print "If you unsure where to start, start here."
print_nl()
print "-v Template=1"
print "Print only the boilerplate code from the Doc option."
print_nl()
print "-v ExampleInput=1"
print "Print an example parser description."
print_nl()
print "-v ExampleData=1"
print "Print example data for the parser which can be generated from ExampleInput."
print_nl()
print "-v Help=1"
print "Print this screen."
print_nl()
print "-v Version=1"
print "Print version info."
print_nl()
print "To run the example:"
print "# get the parser description"
print "awk -f " SCRIPT_NAME() " -v ExampleInput=1 > example.smpg"
print_nl()
print "# generate the parser from the description"
print "awk -f " SCRIPT_NAME() " example.smpg > example.smpg.awk"
print_nl()
print "# get example data for the generated parser"
print "awk -f " SCRIPT_NAME() " -v ExampleData=1 > example.data.txt"
print_nl()
print "# give the data to the parser to generate a runnable test program"
print "awk -f example.smpg.awk example.data.txt > example.test.awk"
print_nl()
print "# finally, run the test program"
print "awk -f example.test.awk"
print_nl()
print "# clean up"
print "rm example.smpg example.smpg.awk example.data.txt example.test.awk"
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
}

function get_use_str() {
	return sprintf("Use: %s [options] <input-file>", SCRIPT_NAME())
}

function print_doc() {
print "1. Idea:"
print "A finite state machine parser recognizes a declarative language and is able"
print "to call user defined callbacks when each rule of that language is encountered."
print "When this is combined with awk's abilities for text processing, it becomes"
print "trivial to ensure correctness of input. The parser is line oriented and the"
print "first field of each line is the next state machine state. E.g. if the fsm was"
print "defined as:"
print_nl()
print "foo -> bar"
print "bar -> foo"
print_nl()
print "i.e. a 'foo' has to be followed by a 'bar', and a 'bar' has to be followed"
print "by a 'foo', then the parser will recognize files which look like:"
print_nl()
print "foo <something>"
print "bar <something>"
print "foo <something>"
print "bar <something>"
print "..."
print_nl()
print "That is, the first line must begin with 'foo', the one after that with 'bar',"
print "the one after that with 'foo' again and so on. Anything else than this"
print "constitutes an error and parsing stops. Each time 'foo' is read, a on_foo()"
print "function is called. This function is user defined and inside it is very"
print "easy to check if you have the <something>, what that <something> actually is,"
print "save it for later processing, etc. Respectively, a on_bar() function is called"
print "when a 'bar' is read. It is also very easy to make the parser read whole blocks"
print "instead of single lines by calling 'getline' from inside the handlers until"
print "some delimiter is read, e.g. 'end':"
print_nl()
print "foo"
print "<something>"
print "<something>"
print "..."
print "end"
print "bar"
print "<something>"
print "<something>"
print "..."
print "end"
print_nl()
print "2. " SCRIPT_NAME()
print SCRIPT_NAME() " is a fsm parser as described above which uses its input to"
print "generate another fsm parser. I.e. " SCRIPT_NAME() " is a fsm parser which"
print "takes a description of an fsm parser as input and outputs the fsm parser"
print "defined by that description. In practice, it's a lot simpler than it sounds."
print SCRIPT_NAME() " has the ability to include text, external files, and generate"
print "source code by regex text substitution. This gives it the ability to also"
print "generate itself. The description of " SCRIPT_NAME() " is:"
print_nl()
print DESCRIPT()
print_nl()
print "The included files are libraries and other functionality. The fsm rules"
print "are prepended by a '@', so they are distinguishable from their data. Lines"
print "which begin with a ';' are comments. Comments are only single line and take"
print "the whole line. The 'begin' and 'generate' state must appear alone on a line."
print "All other states are block oriented and delimited by '@END'. The full syntax"
print "is described below:"
print_nl()
print_template_code()
print_nl()
}

function print_template_code() {
print "; any line which begins with a ';' is a comment"
print "; the '@BEGIN' states tells the parser to initialize its data structures"
print_begin()
print_nl()
print_include()
print "; this block must exist even if empty"
print "; any file names which appear here will be appended verbatim to"
print "; the final script"
print "; this is one way to get libraries and other code in your parser"
print_end()
print_nl()
print_fsm("<fsm-name>")
print "; the syntax for the '@FSM' state is '@FSM <fsm-name>'"
print "; the <fsm-name> is prepended to all generated fsm functions"
print "; the rest of the text in this block is the fsm specification for the"
print "; parser which is to be generated"
print "; each fsm state gets its own handler function with the name:"
print "; '<fsm-name>_on_<state-name>()'"
print "; an implicit error handler with the name and arguments:"
print "; '<fsm-name>_on_error(curr_st, expected, got)' is also generated"
print "; for details on the fsm description syntax see examples, or awklib_fsm.awk"
print_end()
print_nl()
print_handler("<regex> [args]")
print "; <regex> is matched against the state names specified in the '@FSM' state"
print "; the non-comment text in this block then appears in the body of the handlers"
print "; for the state names which matched"
print "; any appearance of '{&}' in this text is replaced by the state name which"
print "; matched once for each match"
print "; [args], if given, are pasted verbatim in each handler's argument list"
print "; e.g., given:"
print "; '@HANDLER a|b _foo, _bar"
print "; \t{&}_save($0)"
print "; @END"
print "; function m_on_a(    _foo, _bar) {"
print "; \ta_save($0)"
print "; }"
print "; function m_on_b(    _foo, _bar) {"
print "; \tb_save($0)"
print "; }"
print "; is generated, assuming 'm' is the name given in '@FSM' and 'a' and 'b' are"
print "; state names which appear in the specification for 'm'"
print "; an arbitrary number of '@HANDLER' blocks can appear after each other,"
print "; however, once a state name is matched, it is not consider in subsequent"
print "; '@HANDLER' blocks"
print_end()
print_nl()
print_template("<regex>")
print "; the '@TEMPLATE' block works much like the '@HANDLER' block, except that"
print "; the '@TEMPLATE' block is used to generate functions, rather than source"
print "; for a specific function, e.g."
print "; @TEMPLATE a|b"
print "; \tfunction {&}_save(str) {_{&}_arr[++_{&}_arr_len] = str}"
print "; @END"
print "; will generate"
print "; function a_save(str) {_a_arr[++_a_arr_len] = str}"
print "; function b_save(str) {_b_arr[++_b_arr_len] = str}"
print "; again, assuming 'a' and 'b' are states of 'm' as above"
print "; like '@HANDLER', an arbitrary number of '@TEMPLATE' blocks can appear after"
print "; each other and once a state has matched it is not considered in any further"
print "; matching"
print_end()
print_nl()
print_other()
print "; any non-comment text which appears in this block is pasted verbatim in"
print "; the final script"
print_end()
print_nl()
print "; source generation begins when the '@GENERATE' state is reached"
print "; since the parser is a fsm, '@GENERATE' is reached only if all input"
print "; is correct"
print_generate()
}

function print_nl() {print ""}
function print_begin() {print "@BEGIN"}
function print_generate() {print "@GENERATE"}
function print_include() {print "@INCLUDE"}
function print_fsm(str) {print ("@FSM " str)}
function print_handler(str) {print ("@HANDLER " str)}
function print_template(str) {print ("@TEMPLATE " str)}
function print_other() {print "@OTHER"}
function print_end() {print "@END"}

function print_example_input() {

print "; this is example " SCRIPT_NAME() " input"
print "; it generates an awk finite state machine parser which generates an awk"
print "; test program for a few trivial math functions along with these functions"
print "; the generated state machine parser will accept files with the format:"
print ";"
print "; begin"
print "; func_name <func>"
print "; input <input>"
print "; output <output>"
print "; generate"
print ";"
print "; each 'func_name' can have one or more inputs and outputs, however, each"
print "; input must have an output after a 'generate', another 'begin' can follow"
print_nl()

print_begin()
print_nl()
print_include()
tabs_inc()
tabs_print("; this block must exist even if empty any file whose name appears here")
tabs_print("; will be appended to the final script verbatim")
tabs_dec()
print_end()
print_nl()

print "; the syntax for the fsm block is '@FSM <fsm-name>'"
print "; <fsm-name> prefixes the generated fsm functions"
print_fsm("stm")
tabs_inc()
tabs_print("begin -> func_name")
tabs_print("func_name -> input")
tabs_print("input -> output")
tabs_print("output -> input | generate")
tabs_print("generate -> begin")
tabs_dec()
print_end()
print_nl()

print "; the syntax for the handler block is '@HANDLER <name> [args]'"
print "; <name> is a regular expression which gets matched against all"
print "; state machine states in order"
print "; if [args] appear, they are pasted literally in the"
print "; handler's argument list"
print_handler("begin")
tabs_inc()
tabs_print("; any code here will appear in the stm_on_begin() function")
tabs_print("init()")
tabs_dec()
print_end()
print_nl()

print "; the '{&}' will be replaced by each handler's name"
print_handler("func_name|input|output")
tabs_inc()
tabs_print("; this is going to generate the same type of code for the three handlers")
tabs_print("; specified by the regex")
tabs_print("check_for_data()")
tabs_print("{&}_save($2)")
tabs_dec()
print_end()
print_nl()

print_handler("generate")
tabs_inc()
tabs_print("{&}()")
tabs_dec()
print_end()
print_nl()

print_handler("error")
tabs_inc()
tabs_print("; the error handler has these implicit arguments as per awklib_fsm")
tabs_print("error(\"line \" FNR \": expected \" expected \", got \" got)")
tabs_dec()
print_end()
print_nl()

print "; the template block works much like the handler blocks, except that a"
print "; template blocks generates general awk source code, while the handler"
print "; block generates the source for a specific handler function"
print "; the syntax for a template block is '@TEMPLATE <regex>'"
print_template("func_name|input|output")
print "function {&}_save(str) {_{&}_data[++_{&}_num] = str}"
print "function {&}_count() {return _{&}_num}"
print "function {&}_get(n) {return _{&}_data[n]}"
print "function {&}_clear() {delete _{&}_data; _{&}_num = 0}"
print_end()
print_nl()

print "; everything in the '@OTHER' block gets pasted as is in the final script"
print "; except any ';' line comments"
print "; here's where all the plumbing can get defined"
print_other()
print "function error(msg) {print \"error: \" msg; exit(1)}"
print "function check_for_data() {"
tabs_inc()
tabs_print("if (NF < 2)")
tabs_inc()
tabs_print("error(sprintf(\"line %d: data expected\", FNR))")
tabs_dec()
tabs_dec()
tabs_print("}")
print "function init() {"
tabs_inc()
tabs_print("func_name_clear()")
tabs_print("input_clear()")
tabs_print("output_clear()")
tabs_dec()
print "}"

print "BEGIN { "
print "\tprint \"function error(msg) {print \\\"error: \\\" msg; exit(1)}\""
print "\tprint \"function abs(n) {return (n < 0) ? -n : n}\""
print "\tprint \"function square(n) {return n*n}\""
print "\tprint \"BEGIN {\""
print "}"

print "function generate(    _func_name, _i, _end, _str) {"
tabs_inc()
tabs_print("_func_name = func_name_get(1)")
tabs_print("_end = input_count()")
tabs_print("for (_i = 1; _i <= _end; ++_i) {")
tabs_inc()
tabs_print("_str = sprintf(\"%s(%s) != %s\",")
tabs_print("_func_name, input_get(_i), output_get(_i))")
tabs_print("print sprintf(\"\\tif (%s)\", _str)")
tabs_print("print \"\\t\\terror(\\\"\" _str \"\\\")\"")
tabs_dec()
tabs_print("}")
tabs_dec()
print "}"
print "END { print \"}\"}"
print "/^[[:space:]]*#|^[[:space:]]*$/ {next}"
print "{stm_next(the_stm, $1)}"
print_end()
print_nl()
print_generate()
}

function print_example_data() {
print "begin"
print "func_name abs"
print "input -5"
print "output 5"
print "input 10"
print "output 10"
print "generate"
print ""
print "begin"
print "func_name square"
print "input 5"
print "output 25"
print "input 6"
print "output 36"
print ""
print "# intentional error"
print "input 7"
print "output 94"
print "generate"
}
# </smpg_messages>
