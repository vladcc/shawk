BEGIN {
	if (rdpg_parse())
		exprs_process()
	else
		exit(1)
}
function error_quit(msg) {
	error_print(msg)
	exit(1)
}
function error_print(msg) {
	print msg > "/dev/stderr"
}

function parsing_error_set() {_B_parsing_error_flag = 1}
function parsing_error_happened() {return _B_parsing_error_flag}

function _tok_prev_set(tok) {_B_lex_tok_prev = tok}
function _tok_prev()        {return _B_lex_tok_prev}

function tok_next() {
	_tok_prev_set(lex_curr_tok())
	return lex_next()
}
function tok_curr() {return lex_curr_tok()}
function tok_err(    _str, _i, _end, _arr, _exp, _prev) {
	parsing_error_set()

	_str = sprintf("file %s, line %d, pos %d: unexpected '%s'", \
		lex_fname(), lex_line_num(), lex_pos(), lex_curr_tok())

	if (_prev = _tok_prev())
		_str = (_str sprintf(" after '%s'", _prev))
	_str = (_str "\n")

	if (_lex_str())
		_str = (_str sprintf("%s\n", lex_get_pos_str()))

	_end = rdpg_expect(_arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (_exp)
			_exp = (_exp " ")
		_exp = (_exp sprintf("'%s'", _arr[_i]))
	}

	if (1 == _end)
		_str = (_str sprintf("expected: %s", _exp))
	else if (_end > 1)
		_str = (_str sprintf("expected one of: %s", _exp))

	error_print((_str "\n"))
}

function _lex_getline(    _res) {
	if ((_res = getline) > 0)
		return ($0 "\n")
	else if (0 == _res)
		return ""

	error_quit(sprintf("getline io with code %s", _res))
}
function _lex_next_ln() {
	_B_lex_str = _lex_getline()
	++_B_lex_ln_num
	_B_lex_ln_pos = 1
	_B_lex_ch_arr_len = split(_B_lex_str, _B_lex_ch_arr, "")
}
function _lex_get_ch() {
	return _B_lex_ch_arr[_B_lex_ln_pos++]
}
function _lex_next_ch() {
	return _B_lex_ch_arr[_B_lex_ln_pos]
}
function _lex_str() {
	return _B_lex_str
}

function _lex_is_digit(ch) {return (ch >= "0" && ch <= "9")}

function NUMBER() {return "number"}
function PLUS()   {return "+"}
function MINUS()  {return "-"}
function MUL()    {return "*"}
function DIV()    {return "/"}
function POW()    {return "^"}
function L_PAR()  {return "("}
function R_PAR()  {return ")"}
function SEMI()   {return ";"}
function EOI()    {return "eoi"}
function ERROR()  {return "error"}

function lex_get_num() {return _B_lex_text}

function lex_next() {
	_B_lex_curr_tok = ERROR()

	if ("" == _B_lex_curr_ch)
		_lex_next_ln()

	while (" " == (_B_lex_curr_ch = _lex_get_ch()) || "\t" == _B_lex_curr_ch)
		continue

	if (_lex_is_digit(_B_lex_curr_ch)) {
		_B_lex_text = ""
		while (1) {
			_B_lex_text = (_B_lex_text _B_lex_curr_ch)
			if (_lex_is_digit(_lex_next_ch()))
				_B_lex_curr_ch = _lex_get_ch()
			else
				break
		}
		_B_lex_curr_tok = NUMBER()
	} else if ("+" == _B_lex_curr_ch || "-" == _B_lex_curr_ch \
		|| "*" == _B_lex_curr_ch || "/" == _B_lex_curr_ch     \
		|| "^" == _B_lex_curr_ch || "(" == _B_lex_curr_ch     \
		|| ")" == _B_lex_curr_ch || ";" == _B_lex_curr_ch) {
			_B_lex_curr_tok = _B_lex_curr_ch
	} else if ("\n" == _B_lex_curr_ch) {
		_B_lex_curr_ch = ""
		_B_lex_curr_tok = lex_next()
	} else if (!_B_lex_curr_ch) {
		_B_lex_curr_tok = EOI()
	}

	return _B_lex_curr_tok
}

function lex_fname()    {return FILENAME}
function lex_line_num() {return _B_lex_ln_num}
function lex_pos()      {return _B_lex_ln_pos-1}
function lex_curr_tok() {return _B_lex_curr_tok}

function lex_get_pos_str(    _sp) {
	_sp = substr(_B_lex_str, 1, lex_pos()-1)
	gsub("[^[:space:]]", " ", _sp)
	_sp = (_sp "^")
	return (_B_lex_str _sp)
}
# <structs-ast>
# structs:
#
# type node
# has  left 
# has  right 
#
# type num
# has  num 
# has  node node
#
# type op
# has  op 
# has  node node
#
# <private>
function _ast_set(k, v) {_STRUCTS_ast_db[k] = v}
function _ast_get(k) {return _STRUCTS_ast_db[k]}
function _ast_type_chk(ent, texp) {
	if (ast_type_of(ent) == texp)
		return
	ast_errq(sprintf("entity '%s' expected type '%s', actual type '%s'", \
		 ent, texp, ast_type_of(ent)))
}
# <\private>

function ast_clear() {delete _STRUCTS_ast_db}
function ast_is(ent) {return (ent in _STRUCTS_ast_db)}
function ast_type_of(ent) {
	if (ent in _STRUCTS_ast_db)
		return _STRUCTS_ast_db[ent]
	ast_errq(sprintf("'%s' not an entity", ent))
}
function ast_new(type,    _ent) {
		_ast_set("ents", (_ent = _ast_get("ents")+1))
	_ent = ("_n" _ent)
	_ast_set(_ent, type)
	return _ent
}
# <types>
# <type-node>
function AST_NODE() {return "node"}

function ast_node_make(left, right,     _ent) {
	_ent = ast_new("node")
	ast_node_set_left(_ent, left)
	ast_node_set_right(_ent, right)
	return _ent
}

function ast_node_set_left(ent, left) {
	_ast_type_chk(ent, "node")
	_ast_set(("left=" ent), left)
}
function ast_node_get_left(ent) {
	_ast_type_chk(ent, "node")
	return _ast_get(("left=" ent))
}

function ast_node_set_right(ent, right) {
	_ast_type_chk(ent, "node")
	_ast_set(("right=" ent), right)
}
function ast_node_get_right(ent) {
	_ast_type_chk(ent, "node")
	return _ast_get(("right=" ent))
}

# <\type-node>
# <type-num>
function AST_NUM() {return "num"}

function ast_num_make(num, node,     _ent) {
	_ent = ast_new("num")
	ast_num_set_num(_ent, num)
	ast_num_set_node(_ent, node)
	return _ent
}

function ast_num_set_num(ent, num) {
	_ast_type_chk(ent, "num")
	_ast_set(("num=" ent), num)
}
function ast_num_get_num(ent) {
	_ast_type_chk(ent, "num")
	return _ast_get(("num=" ent))
}

function ast_num_set_node(ent, node) {
	_ast_type_chk(ent, "num")
	if (node)
		_ast_type_chk(node, "node")
	_ast_set(("node=" ent), node)
}
function ast_num_get_node(ent) {
	_ast_type_chk(ent, "num")
	return _ast_get(("node=" ent))
}

# <\type-num>
# <type-op>
function AST_OP() {return "op"}

function ast_op_make(op, node,     _ent) {
	_ent = ast_new("op")
	ast_op_set_op(_ent, op)
	ast_op_set_node(_ent, node)
	return _ent
}

function ast_op_set_op(ent, op) {
	_ast_type_chk(ent, "op")
	_ast_set(("op=" ent), op)
}
function ast_op_get_op(ent) {
	_ast_type_chk(ent, "op")
	return _ast_get(("op=" ent))
}

function ast_op_set_node(ent, node) {
	_ast_type_chk(ent, "op")
	if (node)
		_ast_type_chk(node, "node")
	_ast_set(("node=" ent), node)
}
function ast_op_get_node(ent) {
	_ast_type_chk(ent, "op")
	return _ast_get(("node=" ent))
}

# <\type-op>
# <\types>
# <\structs-ast>
function vect_init(vect)      {delete vect}
function vect_push(vect, val) {vect[++vect[0]] = val}
function vect_pop(vect, val)  {return vect[vect[0]--]}
function vect_last(vect)      {return vect[vect[0]]}
function vect_len(vect)       {return vect[0]}

function stack_init()     {vect_init(_B_run_stack)}
function stack_push(n)    {vect_push(_B_run_stack, n)}
function stack_peek()     {return vect_last(_B_run_stack)}
function stack_pop()      {return vect_pop(_B_run_stack)}
function stack_is_empty() {return !vect_len(_B_run_stack)}

function expr_list_add(node) {vect_push(_B_expr_list, node)}
function expr_list_get(n)    {return _B_expr_list[n]}
function expr_list_len()     {return vect_len(_B_expr_list)}

function ast_op_create(op) {return ast_op_make(op, ast_node_make())}
function ast_op_left(op) {return ast_node_get_left(ast_op_get_node(op))}
function ast_op_right(op) {return ast_node_get_right(ast_op_get_node(op))}

function ast_num_create(num) {return ast_num_make(num, ast_node_make())}

function op_bin(op,    _l, _r, _op) {
	_op = ast_op_create(op)
	_r = stack_pop()
	_l = stack_pop()
	ast_node_set_left(ast_op_get_node(_op), _l)
	ast_node_set_right(ast_op_get_node(_op), _r)
	stack_push(_op)
}

# <dispatch>
function on_add()        {_prs_do("on_add")}
function on_div()        {_prs_do("on_div")}
function on_mul()        {_prs_do("on_mul")}
function on_neg()        {_prs_do("on_neg")}
function on_pow()        {_prs_do("on_pow")}
function on_sub()        {_prs_do("on_sub")}
function on_expr_end()   {_prs_do("on_expr_end")}
function on_expr_start() {_prs_do("on_expr_start")}
function on_number()     {_prs_do("on_number")}

function _prs_do(what) {
	if (parsing_error_happened())     return
	else if ("on_add"        ==  what)  _prs_on_add()
	else if ("on_div"        ==  what)  _prs_on_div()
	else if ("on_mul"        ==  what)  _prs_on_mul()
	else if ("on_neg"        ==  what)  _prs_on_neg()
	else if ("on_pow"        ==  what)  _prs_on_pow()
	else if ("on_sub"        ==  what)  _prs_on_sub()
	else if ("on_expr_end"   ==  what)  _prs_on_expr_end()
	else if ("on_expr_start" ==  what)  _prs_on_expr_start()
	else if ("on_number"     ==  what)  _prs_on_number()
	else error_quit(sprintf("parser: unknown action '%s'", what))
}

# </dispatch>

# <prs>
function num_push(num) {
	stack_push(ast_num_create(num))
}

function _prs_on_expr_start() {
	stack_init()
}
function _prs_on_expr_end() {
	if (!stack_is_empty())
		expr_list_add(stack_pop())
}

function _prs_on_number() {
	num_push(lex_get_num())
}

function _prs_on_mul() {op_bin(MUL())}
function _prs_on_div() {op_bin(DIV())}

function _prs_on_add() {op_bin(PLUS())}
function _prs_on_sub() {op_bin(MINUS())}

function _prs_on_pow() {op_bin(POW())}

function _prs_on_neg(    _r) {
	_r = stack_pop()
	num_push(0)
	stack_push(_r)
	op_bin(MINUS())
}
# </prs>

function exprs_process(    _i, _end, _n, _v) {
	_end = expr_list_len()
	for (_i = 1; _i <= _end; ++_i) {
		_n = expr_list_get(_i)
		print "Expr:"
		expr_print(_n)
		print ""
		print "Eval:"
		_v = expr_eval(_n)
		print "Result:"
		print _v
		print ""
	}
}

function ast_errq(msg) {error_quit(("ast: " msg))}

function expr_print(node,    _type, _str, _left, _right) {
	if (!node)
		return

	_type = ast_type_of(node)
	if (AST_OP() == _type) {
		_str = ast_op_get_op(node)
		_left = ast_op_left(node)
		_right = ast_op_right(node)
	} else if (AST_NUM() == _type) {
		_str = ast_num_get_num(node)
	}

	if (_left)
		printf("(")
	expr_print(_left)
	printf("%s", _str)
	expr_print(_right)
	if (_right)
		printf(")")
}

function expr_eval(node,    _type, _op, _a, _b, _v) {
	if (!node)
		return 0

	_type = ast_type_of(node)
	if (AST_OP() == _type) {
		_op = ast_op_get_op(node)
		_a = expr_eval(ast_op_left(node))
		_b = expr_eval(ast_op_right(node))

		if      (PLUS()  == _op) _v = _a + _b
		else if (MINUS() == _op) _v = _a - _b
		else if (MUL()   == _op) _v = _a * _b
		else if (DIV()   == _op) _v = _a / _b
		else if (POW()   == _op) _v = _a ^ _b

		print sprintf("%s %s %s = %s", _a, _op, _b, _v)
		return _v
	} else if (AST_NUM() == _type) {
		return ast_num_get_num(node)+0
	}
}
