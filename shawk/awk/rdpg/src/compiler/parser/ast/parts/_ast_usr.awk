# <error>
function ast_errq(msg) {error_quit(sprintf("ast: %s", msg))}
# </error>

# <tree>
function ast_root_set(root) {_B_ast_root = root}
function ast_root() {return _B_ast_root}

function ast_start_create(nont) {
	return ast_start_make(nont, "", "", lex_get_line_no(), ast_lhs_lst_make())
}
function ast_start_push_lhs(start, lhs,    _lst) {
	_lst = ast_start_get_lhs_lst(start)
	if (!ast_lhs_lst_get_head(_lst)) {
		ast_lhs_lst_set_head(_lst, lhs)
		ast_lhs_lst_set_tail(_lst, lhs)
	} else {
		ast_lhs_set_next_(ast_lhs_lst_get_tail(_lst), lhs)
		ast_lhs_lst_set_tail(_lst, lhs)
	}
}
function ast_start_first_lhs(start) {
	return ast_lhs_lst_get_head(ast_start_get_lhs_lst(start))
}
function ast_start_last_lhs(start) {
	return ast_lhs_lst_get_tail(ast_start_get_lhs_lst(start))
}

function ast_lhs_create(name, line_num) {
	if (!line_num)
		line_num = lex_get_line_no()
	return ast_lhs_make(name, line_num, ast_rule_lst_make())
}
function ast_lhs_push_rule(lhs, rule,    _lst) {
	_lst = ast_lhs_get_rule_lst(lhs)
	if (!ast_rule_lst_get_head(_lst)) {
		ast_rule_lst_set_head(_lst, rule)
		ast_rule_lst_set_tail(_lst, rule)
	} else {
		ast_rule_set_next_(ast_rule_lst_get_tail(_lst), rule)
		ast_rule_lst_set_tail(_lst, rule)
	}
}
function ast_lhs_first_rule(lhs) {
	return ast_rule_lst_get_head(ast_lhs_get_rule_lst(lhs))
}
function ast_lhs_last_rule(lhs) {
	return ast_rule_lst_get_tail(ast_lhs_get_rule_lst(lhs))
}

function ast_rule_create() {
	return ast_rule_make(ast_esc_lst_make(), ast_sym_lst_make())
}
function ast_rule_push_sym(rule, sym,    _lst) {
	_lst = ast_rule_get_sym_lst(rule)
	if (!ast_sym_lst_get_head(_lst)) {
		ast_sym_lst_set_head(_lst, sym)
		ast_sym_lst_set_tail(_lst, sym)
	} else {
		ast_sym_set_next_(ast_sym_lst_get_tail(_lst), sym)
		ast_sym_lst_set_tail(_lst, sym)
	}
}
function ast_rule_first_sym(rule) {
	return ast_sym_lst_get_head(ast_rule_get_sym_lst(rule))
}
function ast_rule_last_sym(rule) {
	return ast_sym_lst_get_tail(ast_rule_get_sym_lst(rule))
}
function ast_rule_push_esc(rule, esc,    _lst) {
	_lst = ast_rule_get_esc_lst(rule)
	if (!ast_esc_lst_get_head(_lst)) {
		ast_esc_lst_set_head(_lst, esc)
		ast_esc_lst_set_tail(_lst, esc)
	} else {
		ast_esc_set_next_(ast_esc_lst_get_tail(_lst), esc)
		ast_esc_lst_set_tail(_lst, esc)
	}
}
function ast_rule_first_esc(rule) {
	return ast_esc_lst_get_head(ast_rule_get_esc_lst(rule))
}
function ast_rule_last_esc(rule) {
	return ast_esc_lst_get_tail(ast_rule_get_esc_lst(rule))
}

function ast_sym_create(type, name) {
	return ast_sym_make(type, name, "", ast_esc_lst_make())
}
function ast_sym_push_esc(sym, esc,    _lst) {
	_lst = ast_sym_get_esc_lst(sym)
	if (!ast_esc_lst_get_head(_lst)) {
		ast_esc_lst_set_head(_lst, esc)
		ast_esc_lst_set_tail(_lst, esc)
	} else {
		ast_esc_set_next_(ast_esc_lst_get_tail(_lst), esc)
		ast_esc_lst_set_tail(_lst, esc)
	}
}
function ast_sym_first_esc(sym) {
	return ast_esc_lst_get_head(ast_sym_get_esc_lst(sym))
}
function ast_sym_last_esc(sym) {
	return ast_esc_lst_get_tail(ast_sym_get_esc_lst(sym))
}

function ast_esc_create(name) {return ast_esc_make(name)}
# </tree>

# <modifiers>
function ast_mod_mark(name, mod,    _curr) {
	if (!index((_curr = _B_ast_mod_db[name]), mod)) {
		_B_ast_mod_db[name] = (_curr mod)
		if (PLUS() == mod)
			ast_mod_mark(name, STAR())
	}
}
function ast_mod_has(name, mod) {
	return ((name in _B_ast_mod_db) && index(_B_ast_mod_db[name], mod))
}

function _ast_mod_rename(name, mod) {
	if (QMARK() == mod)
		mod = "_opt"
	else if (STAR() == mod)
		mod = "_star"
	else if (PLUS() == mod)
		mod = "_plus"
	return (name mod)
}
function _ast_mod_discover(ent,    _type, _name, _mod, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_name = ast_start_get_top_nont(ent)
		if (_mod = ast_start_get_mod(ent)) {
			ast_mod_mark(_name, _mod)
			_name = _ast_mod_rename(_name, _mod)
			ast_start_set_top_nont(ent, _name)
			ast_start_set_mod(ent, "")
		}
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		_ast_mod_discover(ast_lhs_first_rule(ent))
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_mod_discover(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
	} else if (AST_SYM() == _type) {
		_name = ast_sym_get_name(ent)
		if (_mod = ast_sym_get_mod(ent)) {
			ast_mod_mark(_name, _mod)
			_name = _ast_mod_rename(_name, _mod)
			ast_sym_set_name(ent, _name)
			ast_sym_set_mod(ent, "")
		}
		_next = ast_sym_get_next_(ent)
	}

	_ast_mod_discover(_next)
}

# <rewrite>
function ZERO() {return "0"}
function NO_LINE() {return "-"}
function _ast_lhs_create_nl(name) {return ast_lhs_create(name, NO_LINE())}

function _ast_mod_defn_star(lhs,    _name, _mod_name, _rule, _ropt, _next) {
	# foo* becomes
	# foo_star : foo foo_star | 0

	_name = ast_lhs_get_name(lhs)
	_mod_name = _ast_mod_rename(_name, STAR())

	_ropt = ast_rule_create()
	ast_rule_push_sym(_ropt, ast_sym_create(ZERO(), ZERO()))

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _mod_name))

	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)
	ast_lhs_push_rule(_next, _ropt)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn_plus(lhs,    _name, _mod_name, _next, _rule) {
	# foo+ becomes
	# foo_plus : foo foo_star

	_name = ast_lhs_get_name(lhs)

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))
	_mod_name = _ast_mod_rename(_name, STAR())
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _mod_name))

	_mod_name = _ast_mod_rename(_name, PLUS())
	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn_opt(lhs,    _name, _mod_name, _next, _rule, _ropt) {
	# foo? becomes
	# foo_opt : foo | 0

	_name = ast_lhs_get_name(lhs)
	_mod_name = _ast_mod_rename(_name, QMARK())

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))

	_ropt = ast_rule_create()
	ast_rule_push_sym(_ropt, ast_sym_create(ZERO(), ZERO()))

	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)
	ast_lhs_push_rule(_next, _ropt)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn(lhs,    _name) {
	_name = ast_lhs_get_name(lhs)
	if (ast_mod_has(_name, STAR()))
		_ast_mod_defn_star(lhs)
	if (ast_mod_has(_name, PLUS()))
		_ast_mod_defn_plus(lhs)
	if (ast_mod_has(_name, QMARK()))
		_ast_mod_defn_opt(lhs)
}
function _ast_mod_resolve(ent,    _type, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		_ast_mod_defn(ent)
		_next = ast_lhs_get_next_(ent)
	}

	_ast_mod_resolve(_next)
}
function ast_mod_rewrite(    _root) {
	_root = ast_root()
	_ast_mod_discover(_root)
	_ast_mod_resolve(_root)
}
# </rewrite>
# </modifiers>

# <to-sym-tbl>
function _ast_tst_add_lhs(lhs) {st_lhs_add(lhs)}
function _ast_tst_add_sym_term(term) {
	st_name_term_add(term)
	st_rule_pos_add(term)
}
function _ast_tst_add_sym_nont(nont) {
	st_name_nont_add(nont)
	st_rule_pos_add(nont)
}

function _ast_tst_place_rule(arr_names, arr_types, len,    _i, _rs, _nm, _tp) {
	for (_i = 1; _i <= len; ++_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (ESC() == _tp)
			_nm = ("\\" _nm)

		_rs = (_rs _nm)
		if (_i < len)
			_rs = (_rs " ")
	}

	st_lhs_rule_add(_rs)

	for (_i = 1; _i <= len; ++_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (TERM() == _tp) {
			st_name_term_add(_nm)
			st_rule_pos_add(_nm)
		} else if (NONT() == _tp) {
			st_name_nont_add(_nm)
			st_rule_pos_add(_nm)
		} else if (ZERO() == _tp) {
			st_name_mark_can_null(st_lhs_last())
			st_name_mark_can_null(st_rule_name_last())
			st_rule_pos_add(ZERO())
		} else if (ESC() == _tp) {
			st_rule_pos_esc_add(_nm)
		}
	}

	for (_i = len; _i > 0; --_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (ESC() != _tp) {
			if (NONT() == _tp && st_lhs_last() == _nm) {
				st_name_mark_tail_rec(st_lhs_last())
				st_name_mark_tail_rec(st_rule_name_last())
			}

			break
		}
	}
}

function _ast_tst_add_rule(ent,    _arr_nm, _arr_tp, _len, _n) {
	_n = ast_rule_first_esc(ent)
	while (_n) {
		++_len
		_arr_nm[_len] = ast_esc_get_name(_n)
		_arr_tp[_len] = ESC()
		_n = ast_esc_get_next_(_n)
	}

	_n = ast_rule_first_sym(ent)
	_len = _ast_tst_get_rule_syms(_n, _arr_nm, _arr_tp, _len)
	_ast_tst_place_rule(_arr_nm, _arr_tp, _len)
}
function _ast_tst_get_rule_syms(ent, arr_out_names, arr_out_types, len,    _n) {
	if (!ent)
		return len

	++len
	arr_out_names[len] = ast_sym_get_name(ent)
	arr_out_types[len] = ast_sym_get_type(ent)

	_n = ast_sym_first_esc(ent)
	while (_n) {
		++len
		arr_out_names[len] = ast_esc_get_name(_n)
		arr_out_types[len] = ESC()
		_n = ast_esc_get_next_(_n)
	}

	_n = ast_sym_get_next_(ent)
	return _ast_tst_get_rule_syms(_n, arr_out_names, arr_out_types, len)
}

function _ast_tst_add_start(ent,    _term, _nont, _rstr) {
	_nont = ast_start_get_top_nont(ent)
	_term = ast_start_get_eoi_term(ent)
	_rstr = sprintf("%s %s", _nont, _term)

	st_lhs_add(START_SYM(), ast_start_get_line_num(ent))
	st_lhs_rule_add(_rstr)
	st_name_nont_add(_nont)
	st_rule_pos_add(_nont)
	st_name_term_add(_term)
	st_rule_pos_add(_term)
	st_eoi_set(_term)
}
function ast_to_sym_tbl() {_ast_to_sym_tbl(ast_root())}
function _ast_to_sym_tbl(ent,    _type, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_ast_tst_add_start(ent)
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		st_lhs_add(ast_lhs_get_name(ent), ast_lhs_get_line_num(ent))
		_ast_to_sym_tbl(ast_lhs_first_rule(ent))
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_tst_add_rule(ent)
		_next = ast_rule_get_next_(ent)
	}

	_ast_to_sym_tbl(_next)
}
# </to-sym-tbl>

# <print>
# <dbg>
function ast_print_grammar() {_ast_print_grammar(ast_root())}
function _ast_print_grammar(ent,    _type, _next, _tmp) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		printf("start : %s", ast_start_get_top_nont(ent))

		if (_tmp = ast_start_get_mod(ent))
			printf("%s", _tmp)
		printf(" ")
		print ast_start_get_eoi_term(ent)
		print ""

		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		printf("%s : ", ast_lhs_get_name(ent))

		_ast_print_grammar(ast_lhs_first_rule(ent))
		print ""
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_print_grammar(ast_rule_first_esc(ent))
		_ast_print_grammar(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
		if (_next && AST_RULE() == ast_type_of(_next))
			printf("\n\t| ")
		else
			print ""
	} else if (AST_SYM() == _type) {
		if (_tmp = ast_sym_get_name(ent))
			printf("%s", _tmp)
		if (_tmp = ast_sym_get_mod(ent))
			printf("%s", _tmp)

		printf(" ")
		_ast_print_grammar(ast_sym_first_esc(ent))

		_next = ast_sym_get_next_(ent)
	} else if (AST_ESC() == _type) {
		if (_tmp = ast_esc_get_name(ent))
			printf("\\%s ", _tmp)

		_next = ast_esc_get_next_(ent)
	}

	_ast_print_grammar(_next)
}

# <dbg>
function ast_dbg_print(ent,    _type, _next, _tmp) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		printf("start (line %s) : %s", ast_start_get_line_num(ent), \
			ast_start_get_top_nont(ent))

		if (_tmp = ast_start_get_mod(ent))
			printf("%s", _tmp)
		printf(" ")
		print ast_start_get_eoi_term(ent)
		print ""

		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		printf("%s (line %s) : ", ast_lhs_get_name(ent), \
			ast_lhs_get_line_num(ent))

		ast_dbg_print(ast_lhs_first_rule(ent))
		print ""
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		ast_dbg_print(ast_rule_first_esc(ent))
		ast_dbg_print(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
		if (_next && AST_RULE() == ast_type_of(_next))
			printf("\n\t| ")
		else
			print ""
	} else if (AST_SYM() == _type) {
		if (_tmp = ast_sym_get_name(ent))
			printf("%s", _tmp)
		if (_tmp = ast_sym_get_mod(ent))
			printf("%s", _tmp)

		printf(" ")
		ast_dbg_print(ast_sym_first_esc(ent))

		_next = ast_sym_get_next_(ent)
	} else if (AST_ESC() == _type) {
		if (_tmp = ast_esc_get_name(ent))
			printf("\\%s ", _tmp)

		_next = ast_esc_get_next_(ent)
	}

	ast_dbg_print(_next)
}
# </dbg>
# </print>
