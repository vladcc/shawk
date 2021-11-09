# use with a generated parser

# <lexing>
function PLUS() {return "\\+"}
function MINUS() {return "\\-"}
function MUL() {return "\\*"}
function DIV() {return "\\/"}
function EXP() {return "\\^"}
function LPAR() {return "\\("}
function RPAR() {return "\\)"}
function SEMI() {return ";"}
function SINGLE() {
	return sprintf("%s|%s|%s|%s|%s|%s|%s|%s",
		PLUS(), MINUS(), MUL(), DIV(), EXP(), LPAR(), RPAR(), SEMI())
}
function NUMBER() {return "[[:digit:]]+"}
function EOI() {return ""}

function tok_str_tbl_add(tok, str) {_B_tok_str_tbl[tok] = str}
function tok_str_tbl_get(tok) {return _B_tok_str_tbl[tok]}
function tok_to_str_init() {
	tok_str_tbl_add(PLUS(), "+")
	tok_str_tbl_add(MINUS(), "-")
	tok_str_tbl_add(MUL(), "*")
	tok_str_tbl_add(DIV(), "/")
	tok_str_tbl_add(EXP(), "^")
	tok_str_tbl_add(LPAR(), "(")
	tok_str_tbl_add(RPAR(), ")")
	tok_str_tbl_add(SEMI(), ";")
	tok_str_tbl_add(NUMBER(), "number")
	tok_str_tbl_add(EOI(), "EOI")
	tok_str_tbl_add("+", PLUS())
	tok_str_tbl_add("-", MINUS())
	tok_str_tbl_add("*", MUL())
	tok_str_tbl_add("/", DIV())
	tok_str_tbl_add("^", EXP())
	tok_str_tbl_add("(", LPAR())
	tok_str_tbl_add(")", RPAR())
	tok_str_tbl_add(";", SEMI())
	tok_str_tbl_add("EOI", "EOI")
}
function tok_to_str(tok) {return tok_str_tbl_get(tok)}
function tok_str_to_tok(str) {
	if (match(str, ("^" NUMBER() "$")))
		return NUMBER()
	else
		return tok_str_tbl_get(str)
}

function tok_curr_set(tok) {_B_tok_curr = tok; ++_B_tok_num}
function tok_curr_get() {return _B_tok_curr} 
function tok_get_tok_num() {return _B_tok_num}
function tok_last_err_set() {_B_tok_last_err = tok_get_tok_num()}
function tok_last_err_get() {return _B_tok_last_err}
function tok_match(tok) {return match(tok_curr_get(), ("^" tok "$"))}
function tok_next(    _line, _next, _new_start) {
	_line = get_line()
	
	if (!_line) {
		tok_curr_set(EOI())
		return ""
	}
	
	_new_start = 1+1
	
	sub("^[[:space:]]+", "", _line)
	if (match(_line, ("^" NUMBER())) ||
		match(_line, ("^" SINGLE()))) {
	
		_new_start = RLENGTH+1
		_next = substr(_line, RSTART, RLENGTH)
		tok_curr_set(_next)
	} else {
		_next = substr(_line, 1, 1)
		printf("warning: ignoring unknown char '%c'\n", _next);
		
		set_line(substr(_line, _new_start))
		return tok_next()
	}
	
	set_line(substr(_line, _new_start))
	return _next
}

# <error_handling>
function tok_err_exp(arr, len,    _i, _pos) {
	
	if (tok_get_tok_num() == tok_last_err_get())
		return
	
	tok_last_err_set()
	stop_compute_set()
	
	printf("error: expected ")
	for (_i = 1; _i <= len; ++_i)
		printf("'%s', ", tok_to_str(arr[_i]))
	printf("got '%s' instead\n", tok_to_str(tok_str_to_tok(tok_curr_get())))
	
	_pos = length($0) - length(get_line()) + (tok_curr_get() == EOI())
	
	print $0
	for (_i = 1; _i < _pos; ++_i)
		printf(" ")
	print "^"
}
function sync(tok,    _next, _eoi) {
	_next = tok_str_to_tok(tok_next())

	_eoi = tok_to_str(EOI())
	while (_next != tok && _next != _eoi)
		_next = tok_str_to_tok(tok_next())
		
	if (_eoi == _next) {
		printf("error: couldn't synchronize on '%s'\n", tok_to_str(tok))
		return 0
	}
	
	tok_next()
	return (_next == tok)
}
# </error_handling>
# </lexing>

# <evaluation>
function negate_clear() {_B_negate = 0}
function negate_set() {_B_negate = 1}
function negate_get() {return _B_negate}
function stop_compute_clear() {_B_stop_compute = 0}
function stop_compute_set() {_B_stop_compute = 1}
function stop_compute_get() {return _B_stop_compute}
function stack_push(val) {
	if (negate_get()) {
		val = -val
		negate_clear()
	}
	_B_stack[++_B_stack_pos] = val
}
function stack_pop() {return _B_stack[_B_stack_pos--]}
function push_val() {stack_push(tok_curr_get())}

function out_arith(op, a, b, res) {
	op = tok_to_str(op)
	print sprintf("%.2f %s %.2f = %.2f", a, op, b, res)
}
function add(    _a, _b, _res) {
	if (stop_compute_get())
		return
		
	_b = stack_pop()
	_a = stack_pop()
	_res = _a+_b
	out_arith(PLUS(), _a, _b, _res)
	stack_push(_res)
}
function subt(    _a, _b, _res) {
	if (stop_compute_get())
		return
		
	_b = stack_pop()
	_a = stack_pop()
	_res = _a-_b
	out_arith(MINUS(), _a, _b, _res)
	stack_push(_res)
}
function mult(    _a, _b, _res) {
	if (stop_compute_get())
		return
		
	_b = stack_pop()
	_a = stack_pop()
	_res = _a*_b
	out_arith(MUL(), _a, _b, _res)
	stack_push(_res)
}
function divd(    _a, _b, _res) {
	if (stop_compute_get())
		return
		
	_b = stack_pop()
	_a = stack_pop()
	_res = _a/_b
	out_arith(DIV(), _a, _b, _res)
	stack_push(_res)
}
function power(    _a, _b, _res) {
	if (stop_compute_get())
		return
		
	_b = stack_pop()
	_a = stack_pop()
	_res = _a^_b
	out_arith(EXP(), _a, _b, _res)
	stack_push(_res)
}
function neg() {
	if (stop_compute_get())
		return
		
	negate_set()
}
# </evaluation>

# <input_handling>
function set_line(str) {_B_line = str}
function get_line() {return _B_line}
function parse_line(str,    _tmp) {
	set_line(str)
	print str
	stop_compute_clear()
	if (!parse())
		printf("error: file '%s', line %d\n", FILENAME, FNR)
	else
		print ""
}
# </input_handling>

# <awk_rules>
function init() {tok_to_str_init()}
BEGIN {
	init()
}
$0 ~ /^#/ {next}
$0 ~ /^[[:space:]]*$/ {next}
{parse_line($0)}
# </awk_rules>
