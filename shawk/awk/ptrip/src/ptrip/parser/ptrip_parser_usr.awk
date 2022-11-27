# <ptrip_parser_usr>

function _parser_usr_state_init() {
	_key_init()
	_val_init()
}

# <key_functions>
function _key_init() {
	_stack_init(_B_ptree_stack_tree_key_lvl)
	_stack_init(_B_ptree_stack_key_lines)
	_B_ptree_current_key_num = 0
	_B_ptree_current_key_str = ""
}
function _key_path_push() {
	if (_stack_size(_B_ptree_stack_tree_key_lvl)) {
		_stack_push(_B_ptree_stack_tree_key_lvl,
		(_stack_peek(_B_ptree_stack_tree_key_lvl) "." _B_ptree_current_key_str))
	} else {
		_stack_push(_B_ptree_stack_tree_key_lvl, _B_ptree_current_key_str)
	}
}
function _key_path_get(key) {
	if (_stack_size(_B_ptree_stack_tree_key_lvl))
		return (_stack_peek(_B_ptree_stack_tree_key_lvl) "." key)
	return key
}
function _key_path_pop() {_stack_pop(_B_ptree_stack_tree_key_lvl)}
function _key_line_save(str) {_stack_push(_B_ptree_stack_key_lines, str)}
function _key_line_get(n) {return _B_ptree_stack_key_lines[n]}
function _key_get_count() {return _B_ptree_current_key_num}
function _key_save(key) {
	_B_ptree_current_key_str = key
	++_B_ptree_current_key_num
}
# </key_functions>

# <value_functions>
function _val_init() {
	_stack_init(_B_ptree_map_values)
}
function _val_save(val) {_B_ptree_map_values[_key_get_count()] = val}
function _val_get(key_no) {
	if (key_no in _B_ptree_map_values)
		return _B_ptree_map_values[key_no]
	return AN_NULL()
}
# </value_functions>

# <output_preparation>
function _OUTPUT_LINE_RESERVED() {return "\034"}
function _output_clear() {
	_stack_init(_B_ptree_stack_output)
}
function _output_line_push(str) {_stack_push(_B_ptree_stack_output, str)}
function _output_line_reserve_slot() {
	_stack_push(_B_ptree_stack_output, _OUTPUT_LINE_RESERVED())
}
function _output_print(    _i, _end, _k, _line) {
	_end = _stack_size(_B_ptree_stack_output)
	for (_i = 1; _i <= _end; ++_i) {
		_line = _B_ptree_stack_output[_i]
		if (_OUTPUT_LINE_RESERVED() == _line)
			print sprintf("%s = %s", _key_line_get(++_k), _val_get(_k))
		else
			print _line
	}
}
# </output_preparation>

# <file_functions>
function _file_lvl_push() {
	if (_B_ptree_file_lvl_str)
		_B_ptree_file_lvl_str = (_B_ptree_file_lvl_str "-")
	else
		_B_ptree_file_lvl_str = "-"
	
	_stack_push(_B_ptree_file_chain, get_file_name())
}
function _file_lvl_pop() {
	if (_B_ptree_file_lvl_str) {
		_B_ptree_file_lvl_str = \
			substr(_B_ptree_file_lvl_str,
				1, length(_B_ptree_file_lvl_str)-1)
	}
	
	_stack_pop(_B_ptree_file_chain)
}
function _file_lvl_is_open(fname,    _i, _end) {
	_end = _stack_size(_B_ptree_file_chain)
	for (_i = 1; _i <= _end; ++_i) {
		if (fname == _B_ptree_file_chain[_i])
			return 1
	}
	return 0
}
function _file_lvl_get_top_file() {
	return _stack_peek(_B_ptree_file_chain)
}
function _file_lvl_get_lvl_string() {
	return sprintf("%s|%s", _B_ptree_file_lvl_str, _file_lvl_get_top_file())
}
# </file_functions>

# <include_functions>

function _include_save_line(    _incl) {
	
	_output_line_push(_make_out_string(_file_lvl_get_lvl_string(),
			_last_symbol_get_line_no(),
			_key_path_get(LEX_USR_INCLUDE()),
			_last_symbol_get_str()))
}
# </include_functions>

# <misc>
function _make_out_string(file_part, line_no, key_part, value_part) {
	return sprintf("%s:%s:%s = %s", file_part, line_no, key_part, value_part)
}

function _remove_quotes(str) {
	gsub("^\"|\"$", "", str)
	return str
}

function _last_symbol_get_str() {return _B_ptree_last_symbol_str}
function _last_symbol_get_line_no() {return _B_ptree_last_symbol_line_no}
function _last_symbol_save(str, line_no) {
	_B_ptree_last_symbol_str = str
	_B_ptree_last_symbol_line_no = line_no
}

function _mark_file(what) {
	_output_line_push(_make_out_string(_file_lvl_get_lvl_string(),
			"-",
			_key_path_get(what),
			_file_lvl_get_top_file()))
}

# <annotations>
function AN_FILE_BEGIN() {return ";FILE_BEGIN"}
function AN_FILE_END() {return ";FILE_END"}
function AN_ERROR() {return ";ERROR"}
function AN_NULL() {return "{null}"}
# </annotations>

function _mark_file_begin() {_mark_file(AN_FILE_BEGIN())}
function _mark_file_end() {_mark_file(AN_FILE_END())}

function _stack_init(stack) {stack[""]; delete stack}
function _stack_push(stack, val) {stack[++stack["len"]] = val}
function _stack_pop(stack) {stack[--stack["len"]]}
function _stack_place(stack, val) {stack[stack["len"]] = val}
function _stack_size(stack) {return stack["len"]}
function _stack_peek(stack){return stack[stack["len"]]}

function _save_file_lvl_str() {_output_line_push(_file_lvl_get_lvl_string())}

function _can_read_file(fname,    _line, _ret) {
	_ret = ((getline _line < fname) >= 0)
	if (_ret)
		close(fname)
	return _ret
}

function _error_do(msg,    _err) {
	_err = _make_out_string(_file_lvl_get_lvl_string(),
			_last_symbol_get_line_no(),
			AN_ERROR(),
			msg)
	_output_line_push(_err)
	error_print(_err)
}
# </misc>

# <parser_callbacks>
function ptree_tok_match(tok) {return (lex_curr_tok() == tok)}
function ptree_tok_next() {return lex_next()}

function _tokstr(tok) {
	
	if (TOK_L_CURLY() == tok)
		return "{"
	else if (TOK_R_CURLY() == tok)
		return "}"
	else if (TOK_NEW_LINE() == tok)
		return "new line"
	else if (TOK_INCLUDE() == tok)
		return "#include"
	else if (TOK_WORD() == tok)
		return "word"
	else if (TOK_STRING() == tok)
		return "string"
	else if (TOK_EOI() == tok)
		return "end of input"
	else if (TOK_ERROR() == tok)
		return "error"
	else if (LEX_USR_INCLUDE() == tok)
		return LEX_USR_INCLUDE()
	else if (LEX_USR_NO_CURLY() == tok)
		return LEX_USR_NO_CURLY()
	
	return TOK_ERROR()
}

function ptree_tok_err_exp(arr, len,    _i, _str) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (_str)
			_str = sprintf("%s, '%s'", _str, _tokstr(arr[_i]))
		else
			_str = sprintf("'%s'", _tokstr(arr[_i]))
	}
	
	error_fatal(\
		lex_usr_pos_msg(\
			sprintf("%s expected, got '%s'", _str, _tokstr(lex_curr_tok()))))
}
function _ptree_lvl_push() {_key_path_push()}
function _ptree_lvl_pop() {_key_path_pop()}
function _ptree_read_string() {
	_last_symbol_save(lex_usr_get_saved_string(), lex_get_line_no())
}
function _ptree_read_word() {
	_last_symbol_save(lex_get_saved(), lex_get_line_no())
}
function _ptree_on_include(    _fprev, _fnext) {
	_fprev = get_file_name()
	
	_fnext = _remove_quotes(_last_symbol_get_str())
	_include_save_line()
	
	if (_file_lvl_is_open(_fnext)) {
		_error_do(sprintf("\"recursive include of file '%s'\"", _fnext))
	} else if (!_can_read_file(_fnext)) {
		_error_do(sprintf("\"file '%s': %s\"", _fnext, ERRNO))
	} else {
		lex_state_hack_push_state()
		_parse_ptree_info(_fnext)
		lex_state_hack_pop_state()
		set_file_name(_fprev)
	}
}
function _ptree_bad_include() {
	error_fatal(lex_usr_pos_msg("bad include line"))
}
function _ptree_on_key(    _key, _path) {
	_key = _last_symbol_get_str()
	_key_save(_key)
	_key_line_save(sprintf("%s:%s:%s",
			_file_lvl_get_lvl_string(),
			_last_symbol_get_line_no(),
			_key_path_get(_key)))
	_output_line_reserve_slot()
}
function _ptree_on_val() {_val_save(_last_symbol_get_str())}
# </parser_callbacks>

# <parser_io>
function _ptree_dump() {_output_print()}
function _parse_ptree_info(fname) {
	set_file_name(fname)
	
	if (_can_read_file(fname)) {
		_file_lvl_push()
		_save_file_lvl_str()
		
		_mark_file_begin()
		lex_init()
		ptree_fmt()
		close(fname)
		_mark_file_end()
		
		_file_lvl_pop()
	} else {
		_file_error(fname)
	}
}
function parse_ptree_info(fname) {
	_output_clear()
	_parser_usr_state_init()
	_parse_ptree_info(fname)
	_ptree_dump()
}
# </parser_io>
# </ptrip_parser_usr>
