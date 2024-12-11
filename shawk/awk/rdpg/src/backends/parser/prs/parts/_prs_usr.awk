# <export>
function sync_call() {return _B_prs_sync_call}
# </export>

# <dispatch>
function on_call()           {_prs_do("on_call")}
function on_call_arg()       {_prs_do("on_call_arg")}
function on_call_end()       {_prs_do("on_call_end")}
function on_call_esc()       {_prs_do("on_call_esc")}
function on_call_name()      {_prs_do("on_call_name")}
function on_cb_close()       {_prs_do("on_cb_close")}
function on_cb_open()        {_prs_do("on_cb_open")}
function on_comment()        {_prs_do("on_comment")}
function on_continue()       {_prs_do("on_continue")}
function on_else()           {_prs_do("on_else")}
function on_else_end()       {_prs_do("on_else_end")}
function on_else_if()        {_prs_do("on_else_if")}
function on_else_if_end()    {_prs_do("on_else_if_end")}
function on_err_var()        {_prs_do("on_err_var")}
function on_func_end()       {_prs_do("on_func_end")}
function on_func_start()     {_prs_do("on_func_start")}
function on_if()             {_prs_do("on_if")}
function on_if_end()         {_prs_do("on_if_end")}
function on_loop()           {_prs_do("on_loop")}
function on_loop_end()       {_prs_do("on_loop_end")}
function on_parse_main()     {_prs_do("on_parse_main")}
function on_parse_main_end() {_prs_do("on_parse_main_end")}
function on_parser()         {_prs_do("on_parser")}
function on_ret_const()      {_prs_do("on_ret_const")}
function on_return()         {_prs_do("on_return")}
function on_return_end()     {_prs_do("on_return_end")}
function on_set()            {_prs_do("on_set")}
function on_set_alias()      {_prs_do("on_set_alias")}
function on_set_alias_defn() {_prs_do("on_set_alias_defn")}
function on_set_alias_name() {_prs_do("on_set_alias_name")}
function on_set_elem()       {_prs_do("on_set_elem")}
function on_set_name()       {_prs_do("on_set_name")}
function on_sets()           {_prs_do("on_sets")}
function on_set_type()       {_prs_do("on_set_type")}
function on_tokens()         {_prs_do("on_tokens")}
function on_tok_eoi()        {_prs_do("on_tok_eoi")}
function on_tok_name()       {_prs_do("on_tok_name")}
function on_top_name()       {_prs_do("on_top_name")}

function _prs_do(what) {
	if (parsing_error_happened())          return
	else if ("on_call"           == what) _prs_on_call()
	else if ("on_call_arg"       == what) _prs_on_call_arg()
	else if ("on_call_end"       == what) _prs_on_call_end()
	else if ("on_call_esc"       == what) _prs_on_call_esc()
	else if ("on_call_name"      == what) _prs_on_call_name()
	else if ("on_cb_close"       == what) _prs_on_cb_close()
	else if ("on_cb_open"        == what) _prs_on_cb_open()
	else if ("on_comment"        == what) _prs_on_comment()
	else if ("on_continue"       == what) _prs_on_continue()
	else if ("on_else"           == what) _prs_on_else()
	else if ("on_else_end"       == what) _prs_on_else_end()
	else if ("on_else_if"        == what) _prs_on_else_if()
	else if ("on_else_if_end"    == what) _prs_on_else_if_end()
	else if ("on_err_var"        == what) _prs_on_err_var()
	else if ("on_func_end"       == what) _prs_on_func_end()
	else if ("on_func_start"     == what) _prs_on_func_start()
	else if ("on_if"             == what) _prs_on_if()
	else if ("on_if_end"         == what) _prs_on_if_end()
	else if ("on_loop"           == what) _prs_on_loop()
	else if ("on_loop_end"       == what) _prs_on_loop_end()
	else if ("on_parse_main"     == what) _prs_on_parse_main()
	else if ("on_parse_main_end" == what) _prs_on_parse_main_end()
	else if ("on_parser"         == what) _prs_on_parser()
	else if ("on_ret_const"      == what) _prs_on_ret_const()
	else if ("on_return"         == what) _prs_on_return()
	else if ("on_return_end"     == what) _prs_on_return_end()
	else if ("on_set"            == what) _prs_on_set()
	else if ("on_set_alias"      == what) _prs_on_set_alias()
	else if ("on_set_alias_defn" == what) _prs_on_set_alias_defn()
	else if ("on_set_alias_name" == what) _prs_on_set_alias_name()
	else if ("on_set_elem"       == what) _prs_on_set_elem()
	else if ("on_set_name"       == what) _prs_on_set_name()
	else if ("on_sets"           == what) _prs_on_sets()
	else if ("on_set_type"       == what) _prs_on_set_type()
	else if ("on_tokens"         == what) _prs_on_tokens()
	else if ("on_tok_eoi"        == what) _prs_on_tok_eoi()
	else if ("on_tok_name"       == what) _prs_on_tok_name()
	else if ("on_top_name"       == what) _prs_on_top_name()
	else error_quit(sprintf("parser: unknown action '%s'", what))
}
# </dispatch>

# <stack>
function _prs_stack_push(n)    {_B_prs_stack[++_B_prs_stack_len] = n}
function _prs_stack_pop()      {--_B_prs_stack_len}
function _prs_stack_peek()     {return _B_prs_stack[_B_prs_stack_len]}
# </stack>

# <process>
function _prs_on_parser() {
	ast_root_set(ast_root_node_create())
	_prs_stack_push(ast_root())
}

function _prs_on_comment(    _ecmnt, _top, _type, _str) {
	if (!_B_prs_on_comment_rx)
		_B_prs_on_comment_rx = sprintf("^%s[[:space:]]*", IR_COMMENT())

	_str = lex_get_line()
	lex_next_line()
	sub(_B_prs_on_comment_rx, "", _str)
	_ecmnt = ast_comment_make(_str)

	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_ROOT_NODE() == _type) {
		ast_root_node_push_cmnt(_top, _ecmnt)
	} else if (AST_FNC() == _type) {
		ast_fnc_push_cmnt(_top, _ecmnt)
	} else {
		ast_ent_errq("_prs_on_comment()", _top, _type)
	}
}

function _prs_on_tokens(    _toks) {
	_toks = ast_tokens_make()
	ast_root_node_set_tokens(_prs_stack_peek(), _toks)
	_prs_stack_pop()
	_prs_stack_push(_toks)
}
function _prs_on_tok_name(    _toks, _all, _nm) {
	_toks = _prs_stack_peek()
	_nm = lex_get_name()
	_all = ast_tokens_get_all_tok(_toks)
	_all = (_all) ? (_all " " _nm) : _nm
	ast_tokens_set_all_tok(_toks, _all)
}
function _prs_on_tok_eoi() {
	ast_tokens_set_tok_eoi(_prs_stack_peek(), lex_get_name())
}

function _prs_on_sets(    _sets) {
	_sets = ast_sets_create()
	ast_tokens_set_sets(_prs_stack_peek(), _sets)
	_prs_stack_pop()
	_prs_stack_push(_sets)
}

function _prs_on_set_alias() {
	ast_sets_push_alias(_prs_stack_peek(), ast_alias_make())
}
function _prs_on_set_alias_defn() {
	ast_alias_set_name(ast_sets_last_alias(_prs_stack_peek()), lex_get_name())
}
function _prs_on_set_elem() {
	ast_alias_push_elem(ast_sets_last_alias(_prs_stack_peek()), lex_get_name())
}

function _prs_on_set() {
	ast_sets_push_set(_prs_stack_peek(), ast_set_make())
}
function _prs_on_set_type() {
	ast_set_set_type(ast_sets_last_set(_prs_stack_peek()), lex_get_curr_tok())
}
function _prs_on_set_name() {
	ast_set_set_name(ast_sets_last_set(_prs_stack_peek()), lex_get_name())
}
function _prs_on_set_alias_name() {
	ast_set_set_alias_name(ast_sets_last_set(_prs_stack_peek()), lex_get_name())
}

function _prs_on_parse_main() {
	_prs_stack_push(ast_parse_main_create(lex_get_curr_tok()))
}
function _prs_on_top_name() {
	ast_parse_main_set_top_nont(_prs_stack_peek(), lex_get_name())
}
function _prs_on_err_var() {
	ast_parse_main_set_err_var(_prs_stack_peek(), lex_get_curr_tok())
}
function _prs_on_parse_main_end(    _main) {
	_main = _prs_stack_peek()
	_prs_stack_pop()
	ast_sets_set_parse_main(_prs_stack_peek(), _main)
	_prs_stack_pop()
	_prs_stack_push(_main)
}

function _prs_on_func_start() {
	_prs_stack_push(ast_fnc_create(lex_get_name()))
}
function _prs_on_func_end(    _fnc) {
	_fnc = _prs_stack_peek()
	_prs_stack_pop()
	ast_parse_main_push_fnc(_prs_stack_peek(), _fnc)
}

function _prs_on_cb_open(    _top, _type, _code_lst) {
	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_FNC() == _type) {
		_code_lst = ast_fnc_get_code_lst(_top)
	} else if (AST_CODE_LOOP() == _type) {
		_code_lst = ast_code_loop_get_code_lst(_top)
	} else if (AST_CODE_IF() == _type) {
		_code_lst = ast_code_if_get_code_lst(_top)
	} else if (AST_CODE_ELSE_IF() == _type) {
		_code_lst = ast_code_else_if_get_code_lst(_top)
	} else if (AST_CODE_ELSE() == _type) {
		_code_lst = ast_code_else_get_code_lst(_top)
	} else {
		ast_ent_errq("_prs_on_cb_open()", _top, _type)
	}
	_prs_stack_push(_code_lst)
}
function _prs_on_cb_close() {
	_prs_stack_pop()
}

function _prs_on_call() {
	_prs_stack_push(ast_code_call_make())
}
function _prs_on_call_esc() {
	ast_code_call_set_is_esc(_prs_stack_peek(), 1)
}

function _sync_call_set() {_B_prs_sync_call = 1}
function _prs_on_call_name(    _nm) {
	_nm = lex_get_curr_tok()
	if (NAME() == _nm)
		_nm = lex_get_name()
	if (IR_SYNC() == _nm)
		_sync_call_set()
	ast_code_call_set_fname(_prs_stack_peek(), _nm)
}
function _prs_on_call_arg() {
	ast_code_call_set_arg(_prs_stack_peek(), lex_get_name())
}
function _prs_on_call_end(    _call, _top, _type) {
	_call = _prs_stack_peek()
	_prs_stack_pop()
	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_CODE_RET() == _type) {
		ast_code_ret_set_call(_top, _call)
	} else if (AST_CODE_IF() == _type) {
		ast_code_if_set_cond(_top, _call)
	} else if (AST_CODE_ELSE_IF() == _type) {
		ast_code_else_if_set_cond(_top, _call)
	} else if (AST_CODE_LST() == _type) {
		ast_code_lst_push_code_node(_top, ast_code_node_make(_call))
	} else {
		ast_ent_errq("_prs_on_call_end()", _top, _type)
	}
}

function _prs_on_return() {
	_prs_stack_push(ast_code_ret_make())
}
function _prs_on_ret_const() {
	ast_code_ret_set_const(_prs_stack_peek(), lex_get_curr_tok())
}
function _prs_on_return_end(    _ret) {
	_ret = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_ret))
}

function _prs_on_loop() {
	_prs_stack_push(ast_code_loop_create())
}
function _prs_on_loop_end(    _loop) {
	_loop = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_loop))
}

function _prs_on_continue() {
	ast_code_lst_push_code_node(_prs_stack_peek(), \
		ast_code_node_make(ast_code_continue_make()))
}

function _prs_on_if() {
	_prs_stack_push(ast_code_if_create())
}
function _prs_on_if_end(    _if) {
	_if = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_if))
}

function _prs_on_else_if() {
	_prs_stack_push(ast_code_else_if_create())
}
function _prs_on_else_if_end(    _elif) {
	_elif = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_elif))
}

function _prs_on_else() {
	_prs_stack_push(ast_code_else_create())
}
function _prs_on_else_end(    _else) {
	_else = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_else))
}
# </process>
