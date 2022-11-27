#!/usr/bin/awk -f

# ptrip.awk -- parses boost ptree info syntax and outputs detailed dot notation
# Vladimir Dinev
# vld.dinev@gmail.com
# 2022-11-27

# <main>
function SCRIPT_NAME() {return "ptrip.awk"}
function SCRIPT_VERSION() {return "1.2"}

function set_file_name(str) {_B_file_name = str}
function get_file_name() {return _B_file_name}

function USE_STR() {return sprintf("Use: %s <info-file(s)>", SCRIPT_NAME())}

function print_use() {
	pstderr(USE_STR())
	pstderr(sprintf("Try: %s -v Help=1", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function print_help() {
print SCRIPT_NAME() " -- parses boost ptree info syntax and outputs detailed dot notation"
print USE_STR()
print ""
print "The syntax of the output is:"
print "'<include-lvl>|<file>' when a new file is opened."
print "'<include-lvl>|<file>:<line-num>:<item|annotation> = <value>' otherwise."
print sprintf("'<value>' is either the value, or '%s' if there was no value. Note",
	AN_NULL())
print "that no value is different than the empty value '\"\"'."
print "'<include-lvl>' is represented by a number of dashes starting from one."
print "'<file>' is the file being parsed at that particular point."
print "'<line-num>' is the line number of the item, or '-' for annotations, except"
print sprintf("the '%s' annotation.", AN_ERROR())
print "'<item>' is a dot notated path such as 'foo.bar.baz',  or '#include'."
print sprintf("'<annotation>' is one of '%s', '%s', '%s'.", AN_FILE_BEGIN(),
	AN_FILE_END(), AN_ERROR())
print ""
print sprintf("Note that '%s' annotates only file errors, e.g. recursive includes, or",
	AN_ERROR())
print "unavailable files. The parser can recover from these errors by simply ignoring"
print "the file. Syntax errors, on the other hand, are fatal. The output is printed"
print "only after parsing and if no syntax errors were encountered."
print ""
print "Options:"
print "-v Version=1 - version info"
print "-v Help=1    - this screen"
	exit_success()
}

function init() {
	set_program_name(SCRIPT_NAME())
	
	if (Help)
		print_help()
	if (Version)
		print_version()
}

function main(    _i) {
	init()
	
	if (ARGC < 2)
		print_use()
	
	for (_i = 1; _i < ARGC; ++_i) {
		parse_ptree_info(ARGV[_i])
		ARGV[_i] = ""
	}
	
	if (did_error_happen())
		exit_failure()
	else
		exit_success()
}

function error_fatal(msg) {
	error_print(sprintf("fatal: %s", msg))
	exit_failure()
}

BEGIN {
	main()
}
# </main>
# <parser_definitions>
# translated by rdpg-to-awk.awk 1.1
# generated by rdpg.awk 1.312
# optimized by rdpg-opt.awk 1.2 Olvl=5
function ptree_fmt(    _arr) {
# rule ptree_fmt
# defn ptree_items TOK_EOI
	ptree_tok_next()
	if (ptree_items()) {
		if (ptree_tok_match(TOK_EOI())) {
			ptree_tok_next()
			return 1
		} else {
			_arr[1] = TOK_EOI()
			ptree_tok_err_exp(_arr, 1)
		}
	}
	return 0
}
function ptree_items() {
# rule ptree_items
# defn ptree_new_line_star ptree_item ptree_items
	while (1) {
		if (ptree_new_line_star()) {
			if (ptree_item()) {
				continue
			} else {
				return 1
			}
		}
		return 0
	}
}
function ptree_item() {
# rule ptree_item?
# defn ptree_tree
# defn ptree_include
	if (ptree_tree()) {
		return 1
	} else {
		if (ptree_tok_match(TOK_INCLUDE())) {
			ptree_tok_next()
			if (ptree_include_fname()) {
				if (ptree_include_end()) {
					_ptree_on_include()
					return 1
				}
			}
		}
		return 0
	}
}
function ptree_tree() {
# rule ptree_tree
# defn ptree_key ptree_rest
	if (ptree_key()) {
		ptree_rest()
		return 1
	}
	return 0
}
function ptree_rest() {
# rule ptree_rest?
# defn ptree_new_line_plus ptree_opt_subtree
# defn ptree_val ptree_new_line_star ptree_opt_subtree
	if (ptree_new_line_plus()) {
		ptree_opt_subtree()
		return 1
	} else if (ptree_val()) {
		if (ptree_new_line_star()) {
			ptree_opt_subtree()
			return 1
		}
	}
	return 0
}
function ptree_include_end() {
# rule ptree_include_end
# defn ptree_new_line_plus
	if (ptree_new_line_plus()) {
		return 1
	} else {
		_ptree_bad_include()
	}
	return 1
}
function ptree_include_fname(    _arr) {
# rule ptree_include_fname
# defn TOK_STRING
	if (ptree_tok_match(TOK_STRING())) {
		_ptree_read_string()
		ptree_tok_next()
		return 1
	} else {
		_arr[1] = TOK_STRING()
		ptree_tok_err_exp(_arr, 1)
	}
	return 0
}
function ptree_key() {
# rule ptree_key
# defn ptree_read_opt
	if (ptree_read_opt()) {
		_ptree_on_key()
		return 1
	}
	return 0
}
function ptree_val() {
# rule ptree_val
# defn ptree_read_opt
	if (ptree_read_opt()) {
		_ptree_on_val()
		return 1
	}
	return 1
}
function ptree_read_opt() {
# rule ptree_read_opt?
# defn TOK_WORD
# defn TOK_STRING
	if (ptree_tok_match(TOK_WORD())) {
		_ptree_read_word()
		ptree_tok_next()
		return 1
	} else if (ptree_tok_match(TOK_STRING())) {
		_ptree_read_string()
		ptree_tok_next()
		return 1
	}
	return 0
}
function ptree_opt_subtree(    _arr) {
# rule ptree_opt_subtree?
# defn ptree_left_curly ptree_items ptree_right_curly
	if (ptree_left_curly()) {
		if (ptree_items()) {
			if (ptree_tok_match(TOK_R_CURLY())) {
				ptree_tok_next()
				if (ptree_new_line_star()) {
					_ptree_lvl_pop()
					return 1
				}
			} else {
				_arr[1] = TOK_R_CURLY()
				ptree_tok_err_exp(_arr, 1)
			}
			return 0
		} else {
			return 0
		}
	}
	return 1
}
function ptree_new_line_plus() {
# rule ptree_new_line_plus?
# defn TOK_NEW_LINE ptree_new_line_star
	if (ptree_tok_match(TOK_NEW_LINE())) {
		ptree_tok_next()
		while (1) {
			if (ptree_eat_new_line()) {
				continue
			}
			return 1
		}
	}
	return 0
}
function ptree_new_line_star() {
# rule ptree_new_line_star
# defn ptree_eat_new_line ptree_new_line_star
	while (1) {
		if (ptree_eat_new_line()) {
			continue
		}
		return 1
	}
}
function ptree_eat_new_line() {
# rule ptree_eat_new_line?
# defn TOK_NEW_LINE
	if (ptree_tok_match(TOK_NEW_LINE())) {
		ptree_tok_next()
		return 1
	}
	return 0
}
function ptree_left_curly() {
# rule ptree_left_curly?
# defn TOK_L_CURLY ptree_new_line_star
	if (ptree_tok_match(TOK_L_CURLY())) {
		ptree_tok_next()
		if (ptree_new_line_star()) {
			_ptree_lvl_push()
			return 1
		}
	}
	return 0
}
# </parser_definitions>
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
# <lex_awk>
# generated by lex-awk.awk 1.61

# <lex_usr_defined>
# The user implements the following:
# lex_usr_get_line()
# lex_usr_on_unknown_ch()
# lex_usr_new_line_hack()
# lex_usr_read_include()
# lex_usr_read_string()
# lex_usr_eat_comment()
# </lex_usr_defined>

# <lex_public>
# <lex_constants>

# the only way to have immutable values; use as constants
function TOK_L_CURLY() {return "{"}
function TOK_R_CURLY() {return "}"}
function TOK_NEW_LINE() {return "NEW_LINE"}
function TOK_INCLUDE() {return "INCLUDE"}
function TOK_WORD() {return "WORD"}
function TOK_STRING() {return "STRING"}
function TOK_EOI() {return "EOI"}
function TOK_ERROR() {return "error"}

function CH_CLS_SPACE() {return 1}
function CH_CLS_NEW_LINE() {return 2}
function CH_CLS_EOI() {return 3}
function CH_CLS_SEMI() {return 4}
function CH_CLS_L_CURLY() {return 5}
function CH_CLS_R_CURLY() {return 6}
function CH_CLS_HASH() {return 7}
function CH_CLS_QUOTE() {return 8}
# </lex_constants>

# read the next character; advance the input
function lex_read_ch() {
	# Note: the user defines lex_usr_get_line()

	_B_lex_curr_ch = _B_lex_input_line[_B_lex_line_pos++]
	_B_lex_peek_ch = _B_lex_input_line[_B_lex_line_pos]
	if (_B_lex_peek_ch != "")
		return _B_lex_curr_ch
	else
		split(lex_usr_get_line(), _B_lex_input_line, "")
	return _B_lex_curr_ch
}

# return the last read character
function lex_curr_ch()
{return _B_lex_curr_ch}

# return the next character, but do not advance the input
function lex_peek_ch()
{return _B_lex_peek_ch}

# return the position in the current line of input
function lex_get_pos()
{return (_B_lex_line_pos-1)}

# return the current line number
function lex_get_line_no()
{return _B_lex_line_no}

# return the last read token
function lex_curr_tok()
{return _B_lex_curr_tok}

# see if your token is the same as the one in the lexer
function lex_match_tok(str)
{return (str == _B_lex_curr_tok)}

# clear the lexer write space
function lex_save_init()
{_B_lex_saved = ""}

# save the last read character
function lex_save_curr_ch()
{_B_lex_saved = (_B_lex_saved _B_lex_curr_ch)}

# return the saved string
function lex_get_saved()
{return _B_lex_saved}

# character classes
function lex_is_ch_cls(ch, cls)
{return (cls == _B_lex_ch_tbl[ch])}

function lex_is_curr_ch_cls(cls)
{return (cls == _B_lex_ch_tbl[_B_lex_curr_ch])}

function lex_is_next_ch_cls(cls)
{return (cls == _B_lex_ch_tbl[_B_lex_peek_ch])}

function lex_get_ch_cls(ch)
{return _B_lex_ch_tbl[ch]}

# see if what's in the lexer's write space is a keyword
function lex_is_saved_a_keyword()
{return (_B_lex_saved in _B_lex_keywords_tbl)}

# call this first
function lex_init() {
	# '_B' variables are 'bound' to the lexer, i.e. 'private'
	if (!_B_lex_are_tables_init) {
		_lex_init_ch_tbl()
		_lex_init_keywords()
		_B_lex_are_tables_init = 1
	}
	_B_lex_curr_ch = ""
	_B_lex_curr_ch_cls_cache = ""
	_B_lex_curr_tok = "error"
	_B_lex_line_no = 1
	_B_lex_line_pos = 1
	_B_lex_peek_ch = ""
	_B_lex_peeked_ch_cache = ""
	_B_lex_saved = ""
	split(lex_usr_get_line(), _B_lex_input_line, "")
}

# return the next token; constants are inlined for performance
function lex_next() {
	_B_lex_curr_tok = "error"
	while (1) {
		_B_lex_curr_ch_cls_cache = _B_lex_ch_tbl[lex_read_ch()]
		if (1 == _B_lex_curr_ch_cls_cache) { # CH_CLS_SPACE()
			continue
		} else if (2 == _B_lex_curr_ch_cls_cache) { # CH_CLS_NEW_LINE()
			_B_lex_curr_tok = lex_usr_new_line_hack()
		} else if (3 == _B_lex_curr_ch_cls_cache) { # CH_CLS_EOI()
			_B_lex_curr_tok = TOK_EOI()
		} else if (4 == _B_lex_curr_ch_cls_cache) { # CH_CLS_SEMI()
			_B_lex_curr_tok = lex_usr_eat_comment()
		} else if (5 == _B_lex_curr_ch_cls_cache) { # CH_CLS_L_CURLY()
			_B_lex_curr_tok = "{"
		} else if (6 == _B_lex_curr_ch_cls_cache) { # CH_CLS_R_CURLY()
			_B_lex_curr_tok = "}"
		} else if (7 == _B_lex_curr_ch_cls_cache) { # CH_CLS_HASH()
			_B_lex_curr_tok = lex_usr_read_include()
		} else if (8 == _B_lex_curr_ch_cls_cache) { # CH_CLS_QUOTE()
			_B_lex_curr_tok = lex_usr_read_string()
		} else {
			_B_lex_curr_tok = lex_usr_on_unknown_ch()
		}
		break
	}
	return _B_lex_curr_tok
}
# </lex_public>

# <lex_private>
# initialize the lexer tables
function _lex_init_keywords() {
}
function _lex_init_ch_tbl() {
	_B_lex_ch_tbl[" "] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\f"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\r"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\t"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\v"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\n"] = CH_CLS_NEW_LINE()
	_B_lex_ch_tbl[""] = CH_CLS_EOI()
	_B_lex_ch_tbl[";"] = CH_CLS_SEMI()
	_B_lex_ch_tbl["{"] = CH_CLS_L_CURLY()
	_B_lex_ch_tbl["}"] = CH_CLS_R_CURLY()
	_B_lex_ch_tbl["#"] = CH_CLS_HASH()
	_B_lex_ch_tbl["\""] = CH_CLS_QUOTE()
}
# </lex_private>
# </lex_awk>
# <lex_usr_implementation>
function _file_error(fname) {
	error_print(sprintf("file '%s': %s", fname, ERRNO))
}

function lex_usr_get_line() {
	# _B_getline_code avoids creating a private variable on each call
	_B_getline_code = (getline _B_current_input_line < get_file_name())
		
	if (_B_getline_code > 0) {
		return (_B_current_input_line "\n")
	} else if (0 == _B_getline_code) {
		return ""
	} else {
		_file_error(get_file_name())
		exit_failure()
	} 
}

function _should_read_word_ch(ch) {
	return \
		(\
		!lex_is_ch_cls(ch, CH_CLS_SPACE()) && \
		!lex_is_ch_cls(ch, CH_CLS_L_CURLY()) && \
		!lex_is_ch_cls(ch, CH_CLS_R_CURLY()) && \
		!lex_is_ch_cls(ch, CH_CLS_SEMI()) && \
		!lex_is_ch_cls(ch, CH_CLS_NEW_LINE()) && \
		!lex_is_ch_cls(ch, CH_CLS_EOI()) \
		)
}

function LEX_USR_NO_CURLY() {return "not-a-curly"}
function _read_lex_word(    _ch) {
	lex_save_init()
	while (1) {
		lex_save_curr_ch()
		if (_should_read_word_ch((_ch = lex_peek_ch())))
			lex_read_ch()
		else
			break
	}
	
	# The below hack is needed, since a key, or value are not defined by what
	# characters they are, but rather by what characters they aren't.
	if (lex_is_ch_cls(_ch, CH_CLS_L_CURLY()) || \
		lex_is_ch_cls(_ch, CH_CLS_R_CURLY())) {
		
		# read the curly, so it shows in the error message
		lex_read_ch()
		lex_save_curr_ch()
		_arr[1] = LEX_USR_NO_CURLY()
		ptree_tok_err_exp(_arr, 1)
	}
}

function lex_usr_on_unknown_ch() {
	_read_lex_word()
	return TOK_WORD()
}

function LEX_USR_INCLUDE() {return "#include"}
function lex_usr_read_include(    _arr) {
	_read_lex_word()
	if (LEX_USR_INCLUDE() == lex_get_saved()) {
		return TOK_INCLUDE()
	} else {
		
		# Since the '#include' directive is never mandatory, reading one is
		# never mandatory as well - not returning one does not lead to a syntax
		# error. Therefore, the error needs to be detected here.
		_arr[1] = LEX_USR_INCLUDE()
		ptree_tok_err_exp(_arr, 1)
	}
	return TOK_ERROR()
}

function lex_usr_read_string() {
	# "foo "\
	# "bar "\
	# "baz"
	# becomes "foo bar baz"
	
	lex_save_init()
	while (1) {
		_B_lex_usr_read_string_peek_ch = lex_peek_ch()
		if ("\\" == lex_curr_ch() && "\"" == _B_lex_usr_read_string_peek_ch) {
			lex_save_curr_ch()
			lex_read_ch()
			lex_save_curr_ch()
		} else if ("\"" == _B_lex_usr_read_string_peek_ch) {
				lex_save_curr_ch()
				lex_read_ch()
				lex_save_curr_ch()
				_lex_usr_string_append(lex_get_saved())
			if ("\\" != lex_peek_ch()) {
				return TOK_STRING()
			} else {
				lex_read_ch()
				if (TOK_NEW_LINE() == lex_next()) {
					if (TOK_STRING() == lex_next())
						return TOK_STRING()
					else
						return TOK_ERROR()
				} else {
					return TOK_ERROR()
				}
			}
		} else {
			lex_save_curr_ch()
		}
		
		if (!lex_is_next_ch_cls(CH_CLS_NEW_LINE()) && \
			!lex_is_next_ch_cls(CH_CLS_EOI())) {
			lex_read_ch()
		} else {
			break
		}
	}
	return TOK_ERROR()
}

function lex_usr_eat_comment() {
	while (!lex_is_next_ch_cls(CH_CLS_NEW_LINE()) && \
		!lex_is_next_ch_cls(CH_CLS_EOI())) {
		lex_read_ch()
	}
	return lex_next()
}

function _lex_usr_string_append(str) {
	if (_B_lex_usr_get_saved_string_str) {
		# "foo " "bar" becomes "foo bar"
		sub("\"$", "", _B_lex_usr_get_saved_string_str)
		sub("^\"", "", str)
	}
	_B_lex_usr_get_saved_string_str = (_B_lex_usr_get_saved_string_str str)
}
function lex_usr_get_saved_string(    _ret) {
	_ret = _B_lex_usr_get_saved_string_str
	_B_lex_usr_get_saved_string_str = ""
	return _ret
}
function lex_usr_pos_msg(msg) {
	return sprintf("%s\n%s",
		sprintf("file '%s', line %d, pos %d: %s",
			get_file_name(), lex_get_line_no(), lex_get_pos(), msg),
		_lex_usr_pretty_pos())
}
function _lex_usr_pretty_pos(    _ptr, _arr, _ch, _i, _end) {
	split(_B_current_input_line, _arr, "")
	_end = lex_get_pos()
	for (_i = 1; _i < _end; ++_i) {
		_ch = _arr[_i]
		_ptr = (_ptr (_ch != "\t" ? " " : "\t"))
	}
	return (_B_current_input_line "\n" _ptr "^")
}
# </lex_usr_implementation>
# <lex_state_hack>
#
# !!!HACK!!!
# This section uses internal knowledge of the lexer implementation in order to
# save its current state so it can be restored later. This is done so '#include'
# directives can be parsed in a depth-first manner and a complete map of the
# info file jungle can be obtained. It is a dirty hack. It works with the lexer
#
# generated by lex-awk.awk 1.61
#
# The above line should be used to check if the version of the generated lexer
# matches. The 'state' of the lexer is defined as all variables which get
# initialized in lex_init().
#
function _LEX_STATE_HACK_SEP() {return "\034"}
function _lex_state_hack_get_lex_line_as_str(    _line, _i, _ch) {
	_line = _B_lex_input_line[++_i]
	while ((_ch = _B_lex_input_line[++_i]) != "")
		_line = (_line _ch)
	return _line
}
function lex_state_hack_push_state() {
	_B_lex_state_hack_stack[++_B_lex_state_hack_stack_pos] = \
		(\
		_lex_state_hack_get_lex_line_as_str()  _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_ch                         _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_ch_cls_cache               _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_tok                        _LEX_STATE_HACK_SEP()  \
		_B_lex_line_no                         _LEX_STATE_HACK_SEP()  \
		_B_lex_line_pos                        _LEX_STATE_HACK_SEP()  \
		_B_lex_peek_ch                         _LEX_STATE_HACK_SEP()  \
		_B_lex_peeked_ch_cache                 _LEX_STATE_HACK_SEP()  \
		_B_lex_saved                           _LEX_STATE_HACK_SEP()  \
		)
}
function lex_state_hack_pop_state(    _arr) {
	split(_B_lex_state_hack_stack[_B_lex_state_hack_stack_pos--], _arr,
		_LEX_STATE_HACK_SEP())
		
	split(_arr[1], _B_lex_input_line, "")
	_B_lex_curr_ch                  =  _arr[2]
	_B_lex_curr_ch_cls_cache        =  _arr[3]
	_B_lex_curr_tok                 =  _arr[4]
	_B_lex_line_no                  =  _arr[5]
	_B_lex_line_pos                 =  _arr[6]
	_B_lex_peek_ch                  =  _arr[7]
	_B_lex_peeked_ch_cache          =  _arr[8]
	_B_lex_saved                    =  _arr[9]
}
function lex_usr_new_line_hack() {
	++_B_lex_line_no
	_B_lex_line_pos = 1
	return TOK_NEW_LINE()
}
# </lex_state_hack>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling. Unlike
#@ other libraries, the function names for this library are not
#@ prepended.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	__LB_prog_program_name__ = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return __LB_prog_program_name__
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	__LB_prog_skip_end_flag__ = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	__LB_prog_skip_end_flag__ = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (__LB_prog_skip_end_flag__+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	__LB_prog_error_flag__ = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	__LB_prog_error_flag__ = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (__LB_prog_error_flag__+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {
	
	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
