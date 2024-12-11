# <error>
function ast_errq(msg) {error_quit(sprintf("ast: %s", msg))}
function ast_ent_errq(where, ent, type) {
	error_quit(sprintf("%s: entity '%s' of unexpected type '%s'", \
		where, ent, type))
}
# </error>

# <tree>
function ast_root_set(root) {_B_ast_root = root}
function ast_root() {return _B_ast_root}

function ast_root_node_create() {
	return ast_root_node_make(ast_cmnt_lst_make(), "")
}
function ast_root_node_push_cmnt(root_node, cmnt) {
	_ast_cmnt_lst_push(ast_root_node_get_cmnt_lst(root_node), cmnt)
}
function ast_root_node_head_cmnt(root_node) {
	return ast_cmnt_lst_get_head(ast_root_node_get_cmnt_lst(root_node))
}

function _ast_cmnt_lst_push(lst, cmnt) {
	if (!ast_cmnt_lst_get_head(lst)) {
		ast_cmnt_lst_set_head(lst, cmnt)
		ast_cmnt_lst_set_tail(lst, cmnt)
	} else {
		ast_comment_set_next_(ast_cmnt_lst_get_tail(lst), cmnt)
		ast_cmnt_lst_set_tail(lst, cmnt)
	}
}

function ast_sets_create() {
	return ast_sets_make(ast_alias_lst_make(), ast_set_lst_make(), "")
}
function ast_sets_push_alias(sets, alias,    _lst) {
	_lst = ast_sets_get_alias_lst(sets)
	if (!ast_alias_lst_get_head(_lst)) {
		ast_alias_lst_set_head(_lst, alias)
		ast_alias_lst_set_tail(_lst, alias)
	} else {
		ast_alias_set_next_(ast_alias_lst_get_tail(_lst), alias)
		ast_alias_lst_set_tail(_lst, alias)
	}
}
function ast_sets_last_alias(sets) {
	return ast_alias_lst_get_tail(ast_sets_get_alias_lst(sets))
}
function ast_sets_push_set(sets, set,    _lst) {
	_lst = ast_sets_get_set_lst(sets)
	if (!ast_set_lst_get_head(_lst)) {
		ast_set_lst_set_head(_lst, set)
		ast_set_lst_set_tail(_lst, set)
	} else {
		ast_set_set_next_(ast_set_lst_get_tail(_lst), set)
		ast_set_lst_set_tail(_lst, set)
	}
}
function ast_sets_last_set(sets) {
	return ast_set_lst_get_tail(ast_sets_get_set_lst(sets))
}

function ast_alias_push_elem(alias, elem,    _data) {
	_data = ast_alias_get_data(alias)
	_data = (!_data) ? elem : (_data " " elem)
	ast_alias_set_data(alias, _data)
}

function ast_parse_main_create(name) {
	return ast_parse_main_make(name, "", "", ast_fnc_lst_make())
}
function ast_parse_main_push_fnc(main, fnc,    _lst) {
	_lst = ast_parse_main_get_fnc_lst(main)
	if (!ast_fnc_lst_get_tail(_lst)) {
		ast_fnc_lst_set_head(_lst, fnc)
		ast_fnc_lst_set_tail(_lst, fnc)
	} else {
		ast_fnc_set_next_(ast_fnc_lst_get_tail(_lst), fnc)
		ast_fnc_lst_set_tail(_lst, fnc)
	}
}

function ast_fnc_create(name) {
	return ast_fnc_make(name, ast_cmnt_lst_make(), ast_code_lst_make())
}
function ast_fnc_push_cmnt(fnc, cmnt) {
	_ast_cmnt_lst_push(ast_fnc_get_cmnt_lst(fnc), cmnt)
}

function ast_code_loop_create() {
	return ast_code_loop_make(ast_code_lst_make())
}

function ast_code_if_create() {
	return ast_code_if_make("", ast_code_lst_make())
}

function ast_code_else_if_create() {
	return ast_code_else_if_make("", ast_code_lst_make())
}

function ast_code_else_create() {
	return ast_code_else_make(ast_code_lst_make())
}

function ast_code_lst_push_code_node(lst, node) {
	if (!ast_code_lst_get_tail(lst)) {
		ast_code_lst_set_head(lst, node)
		ast_code_lst_set_tail(lst, node)
	} else {
		ast_code_node_set_next_(ast_code_lst_get_tail(lst), node)
		ast_code_lst_set_tail(lst, node)
	}
}
# </tree>

# <traverse>
function ast_traverse_for_backed() {
	bd_on_begin()
	_ast_traverse(ast_root())
	bd_on_end()
}
function _ast_traverse(node,    _type) {
	if (!node)
		return

	_type = ast_type_of(node)
	if (AST_ROOT_NODE() == _type) {
		_ast_traverse(ast_root_node_get_cmnt_lst(node))
		_ast_traverse(ast_root_node_get_tokens(node))
	} else if (AST_CMNT_LST() == _type) {
		_ast_traverse(ast_cmnt_lst_get_head(node))
	} else if (AST_COMMENT() == _type) {
		bd_on_comment(ast_comment_get_str(node))
		if (!ast_comment_get_next_(node))
			bd_on_comments_end()
		else
			_ast_traverse(ast_comment_get_next_(node))
	} else if (AST_TOKENS() == _type) {
		bd_on_tokens(ast_tokens_get_all_tok(node))
		bd_on_tok_eoi(ast_tokens_get_tok_eoi(node))
		_ast_traverse(ast_tokens_get_sets(node))
	} else if (AST_SETS() == _type) {
		bd_on_sets_begin()
		_ast_traverse(ast_sets_get_alias_lst(node))
		_ast_traverse(ast_sets_get_set_lst(node))
		bd_on_sets_end()
		_ast_traverse(ast_sets_get_parse_main(node))
	} else if (AST_ALIAS_LST() == _type) {
		_ast_traverse(ast_alias_lst_get_head(node))
	} else if (AST_ALIAS() == _type) {
		bd_on_alias(ast_alias_get_name(node), ast_alias_get_data(node))
		_ast_traverse(ast_alias_get_next_(node))
	} else if (AST_SET_LST() == _type) {
		_ast_traverse(ast_set_lst_get_head(node))
	} else if (AST_SET() == _type) {
		bd_on_set(ast_set_get_type(node), ast_set_get_name(node), \
			ast_set_get_alias_name(node))
		_ast_traverse(ast_set_get_next_(node))
	} else if (AST_PARSE_MAIN() == _type) {
		bd_on_parse_main(ast_parse_main_get_name(node))
		bd_on_cb_open()
		bd_on_parse_main_code()
		bd_on_return()
		bd_on_call(ast_parse_main_get_top_nont(node))
		bd_on_and()
		bd_on_err_var(ast_parse_main_get_err_var(node))
		bd_on_return_end()
		bd_on_cb_close()
		bd_on_parse_main_end()
		_ast_traverse(ast_parse_main_get_fnc_lst(node))
	} else if (AST_FNC_LST() == _type) {
		_ast_traverse(ast_fnc_lst_get_head(node))
	} else if (AST_FNC() == _type) {
		bd_on_func(ast_fnc_get_name(node))
		bd_on_cb_open()
		_ast_traverse(ast_fnc_get_cmnt_lst(node))
		_ast_traverse(ast_fnc_get_code_lst(node))
		bd_on_cb_close()
		_ast_traverse(ast_fnc_get_next_(node))
	} else if (AST_CODE_LST() == _type) {
		_ast_traverse(ast_code_lst_get_head(node))
	} else if (AST_CODE_NODE() == _type) {
		_ast_traverse(ast_code_node_get_code(node))
		_ast_traverse(ast_code_node_get_next_(node))
	} else if (AST_CODE_CALL() == _type) {
		bd_on_call(ast_code_call_get_fname(node), ast_code_call_get_arg(node), \
			ast_code_call_get_is_esc(node))
	} else if (AST_CODE_RET() == _type) {
		if (ast_code_ret_get_const(node)) {
			bd_on_return(ast_code_ret_get_const(node))
			bd_on_return_end()
		} else {
			bd_on_return()
			_ast_traverse(ast_code_ret_get_call(node))
			bd_on_return_end()
		}
	} else if (AST_CODE_LOOP() == _type) {
		bd_on_loop()
		bd_on_cb_open()
		_ast_traverse(ast_code_loop_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_CONTINUE() == _type) {
		bd_on_continue()
	} else if (AST_CODE_IF() == _type) {
		bd_on_if()
		bd_on_cond()
		_ast_traverse(ast_code_if_get_cond(node))
		bd_on_cond_end()
		bd_on_cb_open()
		_ast_traverse(ast_code_if_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_ELSE_IF() == _type) {
		bd_on_else_if()
		bd_on_cond()
		_ast_traverse(ast_code_else_if_get_cond(node))
		bd_on_cond_end()
		bd_on_cb_open()
		_ast_traverse(ast_code_else_if_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_ELSE() == _type) {
		bd_on_else()
		bd_on_cb_open()
		_ast_traverse(ast_code_else_get_code_lst(node))
		bd_on_cb_close()
	} else {
		ast_ent_errq("_ast_traverse()", node, _type)
	}
}
# </traverse>
