# <definitions>
# translated by rdpg-to-awk.awk 1.1
# generated by rdpg.awk 1.311
# optimized by rdpg-opt.awk 1.2 Olvl=4
function _prs_json(    _arr) {
# rule _prs_json
# defn _prs_value _TOK_EOI
	_tok_next()
	if (_prs_value()) {
		if (_tok_match(_TOK_EOI())) {
			_tok_next()
			return 1
		} else {
			_arr[1] = _TOK_EOI()
			_tok_err_exp(_arr, 1)
		}
	}
	return 0
}
function _prs_value(    _arr) {
# rule _prs_value
# defn _TOK_LCURL _prs_usr_on_obj_start _prs_obj_rest
# defn _TOK_LSQR _prs_usr_on_arr_start _prs_arr_rest
# defn _TOK_STRING
# defn _TOK_NUMBER
# defn _TOK_TRUE
# defn _TOK_FALSE
# defn _TOK_NULL
	if (_tok_match(_TOK_LCURL())) {
		_tok_next()
		if (_prs_usr_on_obj_start()) {
			if (_prs_obj_rest()) {
				_prs_usr_on_obj_end()
				return 1
			}
		}
	} else if (_tok_match(_TOK_LSQR())) {
		_tok_next()
		if (_prs_usr_on_arr_start()) {
			if (_prs_arr_rest()) {
				_prs_usr_on_arr_end()
				return 1
			}
		}
	} else if (_tok_match(_TOK_STRING())) {
		_prs_usr_on_string()
		_tok_next()
		return 1
	} else if (_tok_match(_TOK_NUMBER())) {
		_prs_usr_on_number()
		_tok_next()
		return 1
	} else if (_tok_match(_TOK_TRUE())) {
		_prs_usr_on_bool()
		_tok_next()
		return 1
	} else if (_tok_match(_TOK_FALSE())) {
		_prs_usr_on_bool()
		_tok_next()
		return 1
	} else if (_tok_match(_TOK_NULL())) {
		_prs_usr_on_null()
		_tok_next()
		return 1
	} else {
		_arr[1] = _TOK_LCURL()
		_arr[2] = _TOK_LSQR()
		_arr[3] = _TOK_STRING()
		_arr[4] = _TOK_NUMBER()
		_arr[5] = _TOK_TRUE()
		_arr[6] = _TOK_FALSE()
		_arr[7] = _TOK_NULL()
		_tok_err_exp(_arr, 7)
	}
	return 0
}
function _prs_parse_as_value_on_err_sync(    _arr) {
# rule _prs_parse_as_value_on_err_sync
# defn _prs_value
	return _prs_value()
}
function _prs_obj_rest(    _arr) {
# rule _prs_obj_rest
# defn _TOK_RCURL
# defn _prs_members _TOK_RCURL
	if (_tok_match(_TOK_RCURL())) {
		_tok_next()
		return 1
	} else if (_prs_members()) {
		if (_tok_match(_TOK_RCURL())) {
			_tok_next()
			return 1
		} else {
			_arr[1] = _TOK_RCURL()
			_tok_err_exp(_arr, 1)
		}
	} else {
		_arr[1] = _TOK_RCURL()
		_tok_err_exp(_arr, 1)
	}
	return 0
}
function _prs_arr_rest(    _arr) {
# rule _prs_arr_rest
# defn _TOK_RSQR
# defn _prs_values _TOK_RSQR
	if (_tok_match(_TOK_RSQR())) {
		_tok_next()
		return 1
	} else if (_prs_values()) {
		if (_tok_match(_TOK_RSQR())) {
			_tok_next()
			return 1
		} else {
			_arr[1] = _TOK_RSQR()
			_tok_err_exp(_arr, 1)
		}
	} else {
		_arr[1] = _TOK_RSQR()
		_tok_err_exp(_arr, 1)
	}
	return 0
}
function _prs_members(    _arr) {
# rule _prs_members
# defn _prs_member _prs_members_rest
	if (_prs_member()) {
		return _prs_members_rest()
	}
	return 0
}
function _prs_member(    _arr) {
# rule _prs_member
# defn _prs_member_name _TOK_COLON _prs_value
	if (_prs_member_name()) {
		if (_tok_match(_TOK_COLON())) {
			_tok_next()
			return _prs_value()
		} else {
			_arr[1] = _TOK_COLON()
			_tok_err_exp(_arr, 1)
		}
	}
	return 0
}
function _prs_member_name(    _arr) {
# rule _prs_member_name
# defn _TOK_STRING
	if (_tok_match(_TOK_STRING())) {
		_prs_usr_on_member_name()
		_tok_next()
		return 1
	} else {
		_arr[1] = _TOK_STRING()
		_tok_err_exp(_arr, 1)
	}
	return 0
}
function _prs_members_rest(    _arr) {
# rule _prs_members_rest
# defn _prs_member_next _prs_members_rest
	while (1) {
		if (_prs_member_next()) {
			continue
		}
		return 1
	}
}
function _prs_member_next(    _arr) {
# rule _prs_member_next?
# defn _TOK_COMMA _prs_member
	if (_tok_match(_TOK_COMMA())) {
		_tok_next()
		return _prs_member()
	}
	return 0
}
function _prs_values(    _arr) {
# rule _prs_values
# defn _prs_value _prs_values_rest
	if (_prs_value()) {
		return _prs_values_rest()
	}
	return 0
}
function _prs_values_rest(    _arr) {
# rule _prs_values_rest
# defn _prs_value_next _prs_values_rest
	while (1) {
		if (_prs_value_next()) {
			continue
		}
		return 1
	}
}
function _prs_value_next(    _arr) {
# rule _prs_value_next?
# defn _TOK_COMMA _prs_value
	if (_tok_match(_TOK_COMMA())) {
		_tok_next()
		return _prs_value()
	}
	return 0
}
# </definitions>
# <parser_usr_implemented>
function _tok_next(    _next) {
	if (vect_is_empty(_G_synchronization_stack))
		return _lex_next()
	return vect_peek(_G_synchronization_stack)
}
function _tok_match(tok) {
	if (vect_is_empty(_G_synchronization_stack))
		return _lex_match_tok(tok)
	
	if (vect_peek(_G_synchronization_stack) == tok) {
		vect_pop(_G_synchronization_stack)
		return 1
	}
	
	return 0
}

function _sync_fake_parse_as_values(    _tok) {
	
	while (1) {
		
		while (1) {
			_tok = _lex_curr_tok()
			if (_tok != _TOK_COLON() &&
				_tok != _TOK_COMMA() &&
				_tok != _TOK_EOI())
				_lex_next()
			else
				break
		}
		
		if (_TOK_COLON() == _tok) {
			
			vect_push(_G_synchronization_stack, _TOK_COLON())
			vect_push(_G_synchronization_stack, _TOK_STRING())
			vect_push(_G_synchronization_stack, _TOK_LCURL())

			if (_prs_parse_as_value_on_err_sync())
				continue
				
		} else if (_TOK_COMMA() == _tok) {
			
			_lex_next()
			if (_prs_parse_as_value_on_err_sync())
				continue
				
		}
		
		exit_failure()
	}
}
function _tok_err_exp(arr, len) {
	error_print(sprintf("file '%s', line %d, pos %d",
		get_file_name(), _lex_get_line_no(), _lex_get_pos()))
		
	error_print(sprintf("expected '%s', got '%s' instead",
				_expected_str(arr, len), _lex_curr_tok()))
		
	pstderr(_lex_pretty_pos(_G_current_input_line))

	if (_get_fatal_error()) {
		pstderr(sprintf("%s: quitting because of -vFatalError=1",
			get_program_name()))
		exit_failure()
	}

	_sync_fake_parse_as_values()
}
function _expected_str(arr, len,    _i, _str) {
	for (_i = 1; _i <= len; ++_i) {
		_str = (_str arr[_i])
		if (_i != len)
			_str = (_str " ")
	}
	return _str
}

function _subsep(a, b) {
	if (!a) return b
	else if (!b) return a
	return (a PFT_SEP() b)
}
function _no_quotes(str) {
	gsub("\"", "", str)
	return str
}

function _full_name(name) {
	return _subsep(_get_pos(), name)
}
function _prs_init_pos() {
	vect_push(_G_position_stack, JSON_ROOT())
	vect_push(_G_input_order_keeper, JSON_ROOT())
}
function _push_pos(pos) {
	pos = _full_name(pos)
	vect_push(_G_position_stack, pos)
	vect_push(_G_input_order_keeper, pos)
}
function _get_pos() {return vect_peek(_G_position_stack)}
function _pop_pos(    _ret) {
	_ret = vect_peek(_G_position_stack)
	vect_pop(_G_position_stack)
	return _ret
}

function _add_type(type) {map_set(_G_json_type_tbl, _get_pos(), type)}
function _add_val(val) {map_set(_G_json_values_tbl, _get_pos(), val)}

function _push_jarr_ind() {vect_push(_G_array_index_stack, 0)}
function _next_arr_ind(    _ind) {
	_ind = 1 + vect_peek(_G_array_index_stack)
	vect_pop(_G_array_index_stack)
	vect_push(_G_array_index_stack, _ind)
	return _ind
}
function _pop_jarr_ind() {vect_pop(_G_array_index_stack)}

function _push_nest_obj() {vect_push(_G_nest_type_stack, JT_OBJECT())}
function _push_nest_arr() {vect_push(_G_nest_type_stack, JT_ARRAY())}
function _get_nest_type() {return vect_peek(_G_nest_type_stack)}
function _pop_nest_type(    _ret) {
	_ret = vect_peek(_G_nest_type_stack)
	vect_pop(_G_nest_type_stack)
	return _ret
}

function _handle_paths(type) {
	if (_get_nest_type() == JT_ARRAY())
		_push_pos(_next_arr_ind())
	_add_type(type)
}
function _prs_usr_on_obj_start() {
	_handle_paths(JT_OBJECT())
	_add_val(JV_OBJECT())
	_push_nest_obj()
	return 1
}
function _prs_usr_on_obj_end() {
	_pop_pos()
	_pop_nest_type()
}
function _prs_usr_on_arr_start() {
	_handle_paths(JT_ARRAY())
	_add_val(JV_ARRAY())
	_push_nest_arr()
	_push_jarr_ind()
	return 1
}
function _prs_usr_on_arr_end() {
	_pop_pos()
	_pop_jarr_ind()
	_pop_nest_type()
}
function _prs_usr_on_member_name() {
	_push_pos(_no_quotes(_lex_get_saved()))
}
function _prs_usr_on_string() {
	_handle_paths(JT_STRING())
	_add_val(_no_quotes(_lex_get_saved()))
	_pop_pos()
}
function _prs_usr_on_bool() {
	_handle_paths(JT_BOOL())
	_add_val(_lex_get_saved())
	_pop_pos()
}
function _prs_usr_on_number() {
	_handle_paths(JT_NUMBER())
	_add_val(_lex_get_saved())
	_pop_pos()
}
function _prs_usr_on_null() {
	_handle_paths(JT_NULL())
	_add_val(JV_NULL())
	_pop_pos()
}

function _prs_usr_init_type_set() {
	_B_awkson_type_tbl[JT_OBJECT()] = 1
	_B_awkson_type_tbl[JT_ARRAY()] = 1
	_B_awkson_type_tbl[JT_STRING()] = 1
	_B_awkson_type_tbl[JT_BOOL()] = 1
	_B_awkson_type_tbl[JT_NUMBER()] = 1
	_B_awkson_type_tbl[JT_NULL()] = 1
	
	_B_awkson_type_default_val[JT_OBJECT()] = JV_OBJECT()
	_B_awkson_type_default_val[JT_ARRAY()] = JV_ARRAY()
	_B_awkson_type_default_val[JT_STRING()] = ""
	_B_awkson_type_default_val[JT_BOOL()] = _TOK_FALSE()
	_B_awkson_type_default_val[JT_NUMBER()] = 0
	_B_awkson_type_default_val[JT_NULL()] = _TOK_NULL()
}
function _prs_usr_type_set_has(type) {
	return (type in _B_awkson_type_tbl)
}
function _prs_usr_type_get_default_val(type) {
	return _B_awkson_type_default_val[type]
}
# </parser_usr_implemented>
