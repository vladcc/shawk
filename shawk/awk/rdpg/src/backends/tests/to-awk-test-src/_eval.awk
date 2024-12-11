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
