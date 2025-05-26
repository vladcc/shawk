# <parser>
#@ <awklib_tabs>
#@ Library: tabs
#@ Description: String indentation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Adds a tab to the indentation string.
#@ Returns: Nothing.
#
function tabs_inc() {

	++_AWKLIB_tabs__tabs_num
	_AWKLIB_tabs__tabs_str = (_AWKLIB_tabs__tabs_str "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (_AWKLIB_tabs__tabs_num) {
		--_AWKLIB_tabs__tabs_num
		_AWKLIB_tabs__tabs_str = substr(_AWKLIB_tabs__tabs_str, 1,
			_AWKLIB_tabs__tabs_num)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return _AWKLIB_tabs__tabs_num
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (_AWKLIB_tabs__tabs_str "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (_AWKLIB_tabs__tabs_str str)
}

#
#@ Description: Prints the indented 'str' to stdout without a new line
#@ at the end.
#@ Returns: Nothing.
#
function tabs_print_str(str) {

	printf("%s", tabs_indent(str))
}

#
#@ Description: Prints the indented 'str' to stdout with a new line at
#@ the end.
#@ Returns: Nothing.
#
function tabs_print(str) {

	print tabs_indent(str)
}
#@ </awklib_tabs>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling.
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

	_AWKLIB_prog__program_name = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return _AWKLIB_prog__program_name
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

	_AWKLIB_prog__skip_end_flag = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	_AWKLIB_prog__skip_end_flag = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (_AWKLIB_prog__skip_end_flag+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	_AWKLIB_prog__error_flag = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	_AWKLIB_prog__error_flag = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (_AWKLIB_prog__error_flag+0)
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
# <print>
function tinc() {tabs_inc()}
function tdec() {tabs_dec()}
function tget() {return tabs_get()}
function tnum() {return tabs_num()}

function stdout_set(fnm) {_B_print_stdout = fnm}
function stdout_get() {
	if (!_B_print_stdout)
		_B_print_stdout = "/dev/stdout"
	return _B_print_stdout
}
function emit(str) {print (tget() str) > stdout_get()}
function nl()      {print "" > stdout_get()}
# </print>
# <names>
function is_terminal(nm) {
	return match(nm, "^[_[:upper:]][[:upper:][:digit:]_]*$")
}
function is_non_term(nm) {
	return match(nm, "^[_[:lower:]][[:lower:][:digit:]_]*$")
}
# </names>
# <bprint>
function bemit(buff, str) {buff[++buff[0]] = (tget() str)}
function bnl(buff)        {buff[++buff[0]] = ""}
function btostr(buff,    _i, _end, _str) {
	_end = buff[0]
	for (_i = 1; _i <= _end; ++_i)
		_str = (1 == _i) ? buff[_i] : (_str "\n" buff[_i])
	return _str
}
function bflush(buff,    _out, _i, _end) {
	_out = stdout_get()
	_end = buff[0]
	for (_i = 1; _i <= _end; ++_i)
		print buff[_i] > _out
}

function bstr_cat(str) {_B_bstr_str = (_B_bstr_str str)}
function bstr_extract(    _ret) {
	_ret = _B_bstr_str
	_B_bstr_str = ""
	return _ret
}
function bstr_peek() {return _B_bstr_str}
function bstr_emit() {emit(bstr_extract())}
function bstr_bemit(buff) {bemit(buff, bstr_extract())}
# </bprint>
# <lexer>
# <lex>
# The backend lexer. It's assumed every single token is separated by space.

function EOI() {return "eoi"}
function NAME() {return "name"}

function parsing_error_happened() {return _B_parsing_error_flag}
function parsing_error_set() {_B_parsing_error_flag = 1}

function _tok_prev_set(tok) {_B_lex_tok_prev = tok}
function _tok_prev()        {return _B_lex_tok_prev}
function tok_next() {
	_tok_prev_set(tok_curr())
	return _lex_next()
}
function tok_curr() {return lex_get_curr_tok()}
function tok_err(    _str, _i, _end, _arr, _exp, _prev) {
	parsing_error_set()

	_str = sprintf("unexpected '%s'", tok_curr())
	if (_prev = _tok_prev())
		_str = (_str sprintf(" after '%s'", _prev))
	_str = (_str "\n")
	_str = (_str sprintf("%s\n", _lex_get_pos_str(_B_lex_curr_nf)))

	_end = rdpg_expect(_arr)
	for (_i = 1; _i <= _end; ++_i)
		_exp = (_exp sprintf("'%s' ", _arr[_i]))

	if (1 == _end)
		_str = (_str sprintf("expected: %s", _exp))
	else if (_end > 1)
		_str = (_str sprintf("expected one of: %s", _exp))

	_lex_err_quit(_str)
}

function lex_init() {
	FS = " "
	RS = "\n"
	_lex_make_ir_set()
	lex_next_line()
}

function lex_get_line(    _ln) {
	_ln = $0
	sub("^[[:space:]]*", "", _ln)
	return _ln
}
function lex_get_curr_tok() {return _B_lex_curr_tok}
function lex_get_name()     {return _B_lex_saved_name}
function _lex_save_name(nm) {
	if (match(nm, "[_[:alpha:]][_[:alnum:]]*"))
		_B_lex_saved_name = nm
	else
		_lex_err_quit(sprintf("unknown token '%s'\n%s", nm, _lex_get_pos_str()))
}

function _lex_err_quit(msg) {
	error_quit(sprintf("file %s, line %d, field %d: %s", \
		FILENAME, FNR, _B_lex_curr_nf, msg))
}

function _lex_next() {
	++_B_lex_curr_nf
	_B_lex_curr_tok = ""
	if (_B_lex_curr_nf <= NF) {
		_B_lex_curr_tok = $_B_lex_curr_nf
		if (!(_B_lex_curr_tok in _B_lex_ir_set)) {
			_lex_save_name(_B_lex_curr_tok)
			_B_lex_curr_tok = NAME()
		}
	} else if (lex_next_line()) {
		return _lex_next()
	} else {
		_B_lex_curr_tok = EOI()
	}
	return _B_lex_curr_tok
}

function _lex_get_pos_str(    _target, _i, _end, _str, _fld, _len) {
	_target = _B_lex_curr_nf
	_end = NF
	for (_i = 1; _i <= _end; ++_i) {
		_fld = $_i
		if (_i < _target)
			_len += length(_fld) + (_i < _end)
		_str = (_str $_i)
		if (_i < _end)
			_str = (_str " ")
	}

	_fld = ""
	_end = _len
	for (_i = 1; _i <= _end; ++_i)
		_fld = (_fld " ")

	return (_str "\n" (_fld "^"))
}

function lex_next_line(    _res) {
	_B_lex_curr_nf = 0
	if ((_res = getline) > 0)
		return 1
	else if (0 == _res)
		return 0
	error_quit(sprintf("getline io with code %s", _res))
}

function _lex_make_ir_set() {
	_B_lex_ir_set[IR_ALIAS()]
	_B_lex_ir_set[IR_COMMENT()]
	_B_lex_ir_set[IR_SETS()]
	_B_lex_ir_set[IR_PREDICT()]
	_B_lex_ir_set[IR_EXPECT()]
	_B_lex_ir_set[IR_SYNC()]
	_B_lex_ir_set[IR_ESC()]
	_B_lex_ir_set[IR_FUNC()]
	_B_lex_ir_set[IR_CALL()]
	_B_lex_ir_set[IR_RETURN()]
	_B_lex_ir_set[IR_TRUE()]
	_B_lex_ir_set[IR_FALSE()]
	_B_lex_ir_set[IR_RDPG_PARSE()]
	_B_lex_ir_set[IR_AND()]
	_B_lex_ir_set[IR_BLOCK_OPEN()]
	_B_lex_ir_set[IR_BLOCK_CLOSE()]
	_B_lex_ir_set[IR_IF()]
	_B_lex_ir_set[IR_ELSE_IF()]
	_B_lex_ir_set[IR_ELSE()]
	_B_lex_ir_set[IR_LOOP()]
	_B_lex_ir_set[IR_CONTINUE()]
	_B_lex_ir_set[IR_TOKENS()]
	_B_lex_ir_set[IR_TOK_MATCH()]
	_B_lex_ir_set[IR_TOK_IS()]
	_B_lex_ir_set[IR_TOK_NEXT()]
	_B_lex_ir_set[IR_TOK_CURR()]
	_B_lex_ir_set[IR_TOK_EOI()]
	_B_lex_ir_set[IR_TOK_ERR()]
	_B_lex_ir_set[IR_WAS_NO_ERR()]
}
# <lex>
# <rdpg_ir>
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2024-06-24

# version 2.0
# A generic intermediate representation. If optimization is performed, it's
# performed on this. Then it's fed into a back-end for translation to the target
# language.
function IR_COMMENT() {return "#"}

function IR_SETS() {return "sets"}

function IR_ALIAS() {return "alias"}
function IR_PREDICT() {return "predict"}
function IR_EXPECT() {return "expect"}
function IR_SYNC() {return "sync"}

function IR_ESC() {return "\\"}
function IR_FUNC() {return "func"}
function IR_CALL() {return "call"}
function IR_RETURN() {return "return"}

function IR_TOKENS() {return "tokens"}

function IR_TRUE() {return "true"}
function IR_FALSE() {return "false"}

function IR_RDPG_PARSE() {return "rdpg_parse"}
function IR_AND() {return "&&"}

function IR_BLOCK_OPEN() {return "{"}
function IR_BLOCK_CLOSE() {return "}"}

function IR_IF() {return "if"}
function IR_ELSE_IF() {return "else_if"}
function IR_ELSE() {return "else"}

function IR_LOOP() {return "loop"}
function IR_CONTINUE() {return "continue"}

function IR_TOK_MATCH() {return "tok_match"}
function IR_TOK_IS() {return "tok_is"}
function IR_TOK_NEXT() {return "tok_next"}
function IR_TOK_CURR() {return "tok_curr"}
function IR_TOK_EOI() {return "tok_eoi"}
function IR_TOK_ERR() {return "tok_err"}
function IR_WAS_NO_ERR() {return "was_no_err"}
# </rdpg_ir>
# </lexer>
# <prs>
# <parse>
#
# translated by rdpg-to-awk.awk 2.1.1
# generated by rdpg-comp.awk 2.2.0
# 
# Immediate error detection: 1
# 
# Grammar:
# 
# 1. start : parser EOI
# 
# 2. parser : \on_parser comment_star tokens_ sets_ parse_main func__plus
# 
# 3. comment : IR_COMMENT \on_comment
# 
# 4. comment_star : comment comment_star
# 5. comment_star : 0
# 
# 6. tokens_ : tok_lst tok_eoi_
# 
# 7. tok_lst : IR_TOKENS \on_tokens tok_name_plus
# 
# 8. tok_name : NAME \on_tok_name
# 
# 9. tok_name_plus : tok_name tok_name_star
# 
# 10. tok_name_star : tok_name tok_name_star
# 11. tok_name_star : 0
# 
# 12. tok_eoi_ : IR_TOK_EOI NAME \on_tok_eoi
# 
# 13. sets_ : IR_SETS IR_BLOCK_OPEN \on_sets alias__plus set_plus IR_BLOCK_CLOSE
# 
# 14. alias_ : IR_ALIAS \on_set_alias NAME \on_set_alias_defn set_elem_plus
# 
# 15. alias__plus : alias_ alias__star
# 
# 16. alias__star : alias_ alias__star
# 17. alias__star : 0
# 
# 18. set_elem : NAME \on_set_elem
# 
# 19. set_elem_plus : set_elem set_elem_star
# 
# 20. set_elem_star : set_elem set_elem_star
# 21. set_elem_star : 0
# 
# 22. set : \on_set set_type NAME \on_set_name NAME \on_set_alias_name
# 
# 23. set_plus : set set_star
# 
# 24. set_star : set set_star
# 25. set_star : 0
# 
# 26. set_type : IR_PREDICT \on_set_type
# 27. set_type : IR_EXPECT \on_set_type
# 28. set_type : IR_SYNC \on_set_type
# 
# 29. parse_main : IR_FUNC IR_RDPG_PARSE \on_parse_main IR_BLOCK_OPEN IR_RETURN IR_CALL NAME \on_top_name IR_AND IR_WAS_NO_ERR \on_err_var IR_BLOCK_CLOSE \on_parse_main_end
# 
# 30. func_ : IR_FUNC NAME \on_func_start func_code_block \on_func_end
# 
# 31. func__plus : func_ func__star
# 
# 32. func__star : func_ func__star
# 33. func__star : 0
# 
# 34. func_code_block : IR_BLOCK_OPEN comment_star \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close
# 
# 35. code_block : IR_BLOCK_OPEN \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close
# 
# 36. ir_code : call_expr
# 37. ir_code : return_stmt
# 38. ir_code : loop_stmt
# 39. ir_code : IR_CONTINUE \on_continue
# 40. ir_code : if_stmt
# 
# 41. ir_code_plus : ir_code ir_code_star
# 
# 42. ir_code_star : ir_code ir_code_star
# 43. ir_code_star : 0
# 
# 44. call_expr : IR_CALL \on_call call_name call_arg_opt \on_call_end
# 
# 45. call_name : NAME \on_call_name
# 46. call_name : IR_TOK_IS \on_call_name
# 47. call_name : IR_ESC \on_call_esc NAME \on_call_name
# 48. call_name : IR_TOK_NEXT \on_call_name
# 49. call_name : IR_TOK_MATCH \on_call_name
# 50. call_name : IR_PREDICT \on_call_name
# 51. call_name : IR_EXPECT \on_call_name
# 52. call_name : IR_SYNC \on_call_name
# 
# 53. call_arg : NAME \on_call_arg
# 
# 54. call_arg_opt : call_arg
# 55. call_arg_opt : 0
# 
# 56. return_stmt : IR_RETURN \on_return return_rest \on_return_end
# 
# 57. return_rest : call_expr
# 58. return_rest : IR_TRUE \on_ret_const
# 59. return_rest : IR_FALSE \on_ret_const
# 
# 60. loop_stmt : IR_LOOP \on_loop code_block \on_loop_end
# 
# 61. if_stmt : IR_IF \on_if call_expr code_block \on_if_end else_if_stmt_star else_stmt_opt
# 
# 62. else_if_stmt : IR_ELSE_IF \on_else_if call_expr code_block \on_else_if_end
# 
# 63. else_if_stmt_star : else_if_stmt else_if_stmt_star
# 64. else_if_stmt_star : 0
# 
# 65. else_stmt : IR_ELSE \on_else code_block \on_else_end
# 
# 66. else_stmt_opt : else_stmt
# 67. else_stmt_opt : 0
# 

# <public>
function rdpg_parse()
{
	_rdpg_init_sets()
	return _rdpg_start() && !_RDPG_had_error
}
function rdpg_expect(arr_out,    _len) {
	delete arr_out
	if ("tok" == _RDPG_expect_type)
		arr_out[(_len = 1)] = _RDPG_expect_what
	else if ("set" == _RDPG_expect_type)
		_len = split(_RDPG_expect_sets[_RDPG_expect_what], arr_out, _RDPG_SEP())
	return _len
}
# </public>
# <internal>
function _RDPG_SEP() {return "\034"}
function _rdpg_tok_next() {
	_RDPG_curr_tok = tok_next()
}
function _rdpg_tok_is(tok) {
	return (tok == _RDPG_curr_tok)
}
function _rdpg_tok_match(tok,    _ret) {
	if (_ret = _rdpg_tok_is(tok))
		_rdpg_tok_next()
	return _ret
}
function _rdpg_init_sets(    _i, _len, _arr) {
	# alias
	_RDPG_B_str_sym_set_1 = (IR_COMMENT() _RDPG_SEP() IR_TOKENS())
	_RDPG_B_str_sym_set_2 = (IR_TOKENS() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_3 = (IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_4 = (IR_ALIAS() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_5 = (IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_6 = (IR_BLOCK_OPEN() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_7 = (IR_ELSE() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_8 = (IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_9 = (IR_COMMENT() _RDPG_SEP() IR_TOKENS() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_10 = (NAME() _RDPG_SEP() IR_TOK_EOI())
	_RDPG_B_str_sym_set_11 = (NAME() _RDPG_SEP() IR_ALIAS() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_12 = (IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_13 = (IR_FUNC() _RDPG_SEP() EOI())
	_RDPG_B_str_sym_set_14 = (IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_15 = (NAME() _RDPG_SEP() IR_TOK_IS() _RDPG_SEP() IR_ESC() _RDPG_SEP() IR_TOK_NEXT() _RDPG_SEP() IR_TOK_MATCH() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_16 = (NAME() _RDPG_SEP() IR_BLOCK_OPEN() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_17 = (IR_CALL() _RDPG_SEP() IR_TRUE() _RDPG_SEP() IR_FALSE())
	_RDPG_B_str_sym_set_18 = (IR_ELSE_IF() _RDPG_SEP() IR_ELSE() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_19 = (EOI())
	_RDPG_B_str_sym_set_20 = (IR_SETS())
	_RDPG_B_str_sym_set_21 = (IR_TOK_EOI())
	_RDPG_B_str_sym_set_22 = (IR_FUNC())
	_RDPG_B_str_sym_set_23 = (IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_24 = (NAME())

	_len = split(_RDPG_B_str_sym_set_1, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_1[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_2, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_2[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_3, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_3[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_4, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_4[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_5, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_5[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_6, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_6[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_7, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_7[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_8, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_8[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_9, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_9[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_10, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_10[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_11, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_11[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_12, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_12[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_13, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_13[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_14, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_14[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_15, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_15[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_16, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_16[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_17, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_17[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_18, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_18[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_19, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_19[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_20, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_20[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_21, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_21[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_22, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_22[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_23, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_23[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_24, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_24[_arr[_i]]

	# expect
	_RDPG_expect_sets["start"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["parser"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["comment_star"] = _RDPG_B_str_sym_set_9
	_RDPG_expect_sets["tok_name_star"] = _RDPG_B_str_sym_set_10
	_RDPG_expect_sets["alias__star"] = _RDPG_B_str_sym_set_4
	_RDPG_expect_sets["set_elem_star"] = _RDPG_B_str_sym_set_11
	_RDPG_expect_sets["set"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["set_plus"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["set_star"] = _RDPG_B_str_sym_set_12
	_RDPG_expect_sets["set_type"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["func__star"] = _RDPG_B_str_sym_set_13
	_RDPG_expect_sets["ir_code"] = _RDPG_B_str_sym_set_14
	_RDPG_expect_sets["ir_code_plus"] = _RDPG_B_str_sym_set_5
	_RDPG_expect_sets["ir_code_star"] = _RDPG_B_str_sym_set_8
	_RDPG_expect_sets["call_name"] = _RDPG_B_str_sym_set_15
	_RDPG_expect_sets["call_arg_opt"] = _RDPG_B_str_sym_set_16
	_RDPG_expect_sets["return_rest"] = _RDPG_B_str_sym_set_17
	_RDPG_expect_sets["else_if_stmt_star"] = _RDPG_B_str_sym_set_18
	_RDPG_expect_sets["else_stmt_opt"] = _RDPG_B_str_sym_set_7
}
function _rdpg_predict(set) {
	return (_RDPG_curr_tok in set)
}
function _rdpg_sync(set) {
	while (_RDPG_curr_tok) {
		if (_RDPG_curr_tok in set)
			return 1
		if (_rdpg_tok_is(EOI()))
			break
		_rdpg_tok_next()
	}
	return 0
}
function _rdpg_expect(type, what) {
	_RDPG_expect_type = type
	_RDPG_expect_what = what
	_RDPG_had_error = 1
	tok_err()
}
# </internal>
# <rd>
function _rdpg_start()
{
	# 1. start : parser EOI

	_rdpg_tok_next()
	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_parser())
		{
			if (_rdpg_tok_match(EOI()))
			{
				return 1
			}
			else
			{
				_rdpg_expect("tok", EOI())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "start")
	}
	return 0
}
function _rdpg_parser()
{
	# 2. parser : \on_parser comment_star tokens_ sets_ parse_main func__plus

	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		on_parser()
		if (_rdpg_comment_star())
		{
			if (_rdpg_tokens_())
			{
				if (_rdpg_sets_())
				{
					if (_rdpg_parse_main())
					{
						if (_rdpg_func__plus())
						{
							return 1
						}
					}
				}
			}
		}
	}
	else
	{
		_rdpg_expect("set", "parser")
	}
	return _rdpg_sync(_RDPG_sym_set_19)
}
function _rdpg_comment()
{
	# 3. comment : IR_COMMENT \on_comment

	if (_rdpg_tok_is(IR_COMMENT()))
	{
		on_comment()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", IR_COMMENT())
	}
	return _rdpg_sync(_RDPG_sym_set_9)
}
function _rdpg_comment_star()
{
	# 4. comment_star : comment comment_star
	# 5. comment_star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_COMMENT()))
		{
			if (_rdpg_comment())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_2))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "comment_star")
		}
		return _rdpg_sync(_RDPG_sym_set_2)
	}
}
function _rdpg_tokens_()
{
	# 6. tokens_ : tok_lst tok_eoi_

	if (_rdpg_tok_is(IR_TOKENS()))
	{
		if (_rdpg_tok_lst())
		{
			if (_rdpg_tok_eoi_())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOKENS())
	}
	return _rdpg_sync(_RDPG_sym_set_20)
}
function _rdpg_tok_lst()
{
	# 7. tok_lst : IR_TOKENS \on_tokens tok_name_plus

	if (_rdpg_tok_is(IR_TOKENS()))
	{
		on_tokens()
		_rdpg_tok_next()
		if (_rdpg_tok_name_plus())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOKENS())
	}
	return _rdpg_sync(_RDPG_sym_set_21)
}
function _rdpg_tok_name()
{
	# 8. tok_name : NAME \on_tok_name

	if (_rdpg_tok_is(NAME()))
	{
		on_tok_name()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_tok_name_plus()
{
	# 9. tok_name_plus : tok_name tok_name_star

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_tok_name())
		{
			if (_rdpg_tok_name_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_21)
}
function _rdpg_tok_name_star()
{
	# 10. tok_name_star : tok_name tok_name_star
	# 11. tok_name_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NAME()))
		{
			if (_rdpg_tok_name())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_TOK_EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "tok_name_star")
		}
		return _rdpg_sync(_RDPG_sym_set_21)
	}
}
function _rdpg_tok_eoi_()
{
	# 12. tok_eoi_ : IR_TOK_EOI NAME \on_tok_eoi

	if (_rdpg_tok_match(IR_TOK_EOI()))
	{
		if (_rdpg_tok_is(NAME()))
		{
			on_tok_eoi()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOK_EOI())
	}
	return _rdpg_sync(_RDPG_sym_set_20)
}
function _rdpg_sets_()
{
	# 13. sets_ : IR_SETS IR_BLOCK_OPEN \on_sets alias__plus set_plus IR_BLOCK_CLOSE

	if (_rdpg_tok_match(IR_SETS()))
	{
		if (_rdpg_tok_is(IR_BLOCK_OPEN()))
		{
			on_sets()
			_rdpg_tok_next()
			if (_rdpg_alias__plus())
			{
				if (_rdpg_set_plus())
				{
					if (_rdpg_tok_match(IR_BLOCK_CLOSE()))
					{
						return 1
					}
					else
					{
						_rdpg_expect("tok", IR_BLOCK_CLOSE())
					}
				}
			}
		}
		else
		{
			_rdpg_expect("tok", IR_BLOCK_OPEN())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_SETS())
	}
	return _rdpg_sync(_RDPG_sym_set_22)
}
function _rdpg_alias_()
{
	# 14. alias_ : IR_ALIAS \on_set_alias NAME \on_set_alias_defn set_elem_plus

	if (_rdpg_tok_is(IR_ALIAS()))
	{
		on_set_alias()
		_rdpg_tok_next()
		if (_rdpg_tok_is(NAME()))
		{
			on_set_alias_defn()
			_rdpg_tok_next()
			if (_rdpg_set_elem_plus())
			{
				return 1
			}
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ALIAS())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_alias__plus()
{
	# 15. alias__plus : alias_ alias__star

	if (_rdpg_tok_is(IR_ALIAS()))
	{
		if (_rdpg_alias_())
		{
			if (_rdpg_alias__star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ALIAS())
	}
	return _rdpg_sync(_RDPG_sym_set_3)
}
function _rdpg_alias__star()
{
	# 16. alias__star : alias_ alias__star
	# 17. alias__star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_ALIAS()))
		{
			if (_rdpg_alias_())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_3))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "alias__star")
		}
		return _rdpg_sync(_RDPG_sym_set_3)
	}
}
function _rdpg_set_elem()
{
	# 18. set_elem : NAME \on_set_elem

	if (_rdpg_tok_is(NAME()))
	{
		on_set_elem()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_11)
}
function _rdpg_set_elem_plus()
{
	# 19. set_elem_plus : set_elem set_elem_star

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_set_elem())
		{
			if (_rdpg_set_elem_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_set_elem_star()
{
	# 20. set_elem_star : set_elem set_elem_star
	# 21. set_elem_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NAME()))
		{
			if (_rdpg_set_elem())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_4))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "set_elem_star")
		}
		return _rdpg_sync(_RDPG_sym_set_4)
	}
}
function _rdpg_set()
{
	# 22. set : \on_set set_type NAME \on_set_name NAME \on_set_alias_name

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		on_set()
		if (_rdpg_set_type())
		{
			if (_rdpg_tok_is(NAME()))
			{
				on_set_name()
				_rdpg_tok_next()
				if (_rdpg_tok_is(NAME()))
				{
					on_set_alias_name()
					_rdpg_tok_next()
					return 1
				}
				else
				{
					_rdpg_expect("tok", NAME())
				}
			}
			else
			{
				_rdpg_expect("tok", NAME())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "set")
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_set_plus()
{
	# 23. set_plus : set set_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_set())
		{
			if (_rdpg_set_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "set_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_23)
}
function _rdpg_set_star()
{
	# 24. set_star : set set_star
	# 25. set_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_3))
		{
			if (_rdpg_set())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "set_star")
		}
		return _rdpg_sync(_RDPG_sym_set_23)
	}
}
function _rdpg_set_type()
{
	# 26. set_type : IR_PREDICT \on_set_type
	# 27. set_type : IR_EXPECT \on_set_type
	# 28. set_type : IR_SYNC \on_set_type

	if (_rdpg_tok_is(IR_PREDICT()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_EXPECT()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_SYNC()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "set_type")
	}
	return _rdpg_sync(_RDPG_sym_set_24)
}
function _rdpg_parse_main()
{
	# 29. parse_main : IR_FUNC IR_RDPG_PARSE \on_parse_main IR_BLOCK_OPEN IR_RETURN IR_CALL NAME \on_top_name IR_AND IR_WAS_NO_ERR \on_err_var IR_BLOCK_CLOSE \on_parse_main_end

	if (_rdpg_tok_match(IR_FUNC()))
	{
		if (_rdpg_tok_is(IR_RDPG_PARSE()))
		{
			on_parse_main()
			_rdpg_tok_next()
			if (_rdpg_tok_match(IR_BLOCK_OPEN()))
			{
				if (_rdpg_tok_match(IR_RETURN()))
				{
					if (_rdpg_tok_match(IR_CALL()))
					{
						if (_rdpg_tok_is(NAME()))
						{
							on_top_name()
							_rdpg_tok_next()
							if (_rdpg_tok_match(IR_AND()))
							{
								if (_rdpg_tok_is(IR_WAS_NO_ERR()))
								{
									on_err_var()
									_rdpg_tok_next()
									if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
									{
										on_parse_main_end()
										_rdpg_tok_next()
										return 1
									}
									else
									{
										_rdpg_expect("tok", IR_BLOCK_CLOSE())
									}
								}
								else
								{
									_rdpg_expect("tok", IR_WAS_NO_ERR())
								}
							}
							else
							{
								_rdpg_expect("tok", IR_AND())
							}
						}
						else
						{
							_rdpg_expect("tok", NAME())
						}
					}
					else
					{
						_rdpg_expect("tok", IR_CALL())
					}
				}
				else
				{
					_rdpg_expect("tok", IR_RETURN())
				}
			}
			else
			{
				_rdpg_expect("tok", IR_BLOCK_OPEN())
			}
		}
		else
		{
			_rdpg_expect("tok", IR_RDPG_PARSE())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_22)
}
function _rdpg_func_()
{
	# 30. func_ : IR_FUNC NAME \on_func_start func_code_block \on_func_end

	if (_rdpg_tok_match(IR_FUNC()))
	{
		if (_rdpg_tok_is(NAME()))
		{
			on_func_start()
			_rdpg_tok_next()
			if (_rdpg_func_code_block())
			{
				on_func_end()
				return 1
			}
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_func__plus()
{
	# 31. func__plus : func_ func__star

	if (_rdpg_tok_is(IR_FUNC()))
	{
		if (_rdpg_func_())
		{
			if (_rdpg_func__star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_19)
}
function _rdpg_func__star()
{
	# 32. func__star : func_ func__star
	# 33. func__star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_FUNC()))
		{
			if (_rdpg_func_())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "func__star")
		}
		return _rdpg_sync(_RDPG_sym_set_19)
	}
}
function _rdpg_func_code_block()
{
	# 34. func_code_block : IR_BLOCK_OPEN comment_star \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close

	if (_rdpg_tok_match(IR_BLOCK_OPEN()))
	{
		if (_rdpg_comment_star())
		{
			on_cb_open()
			if (_rdpg_ir_code_plus())
			{
				if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
				{
					on_cb_close()
					_rdpg_tok_next()
					return 1
				}
				else
				{
					_rdpg_expect("tok", IR_BLOCK_CLOSE())
				}
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_BLOCK_OPEN())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_code_block()
{
	# 35. code_block : IR_BLOCK_OPEN \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close

	if (_rdpg_tok_is(IR_BLOCK_OPEN()))
	{
		on_cb_open()
		_rdpg_tok_next()
		if (_rdpg_ir_code_plus())
		{
			if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
			{
				on_cb_close()
				_rdpg_tok_next()
				return 1
			}
			else
			{
				_rdpg_expect("tok", IR_BLOCK_CLOSE())
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_BLOCK_OPEN())
	}
	return _rdpg_sync(_RDPG_sym_set_18)
}
function _rdpg_ir_code()
{
	# 36. ir_code : call_expr
	# 37. ir_code : return_stmt
	# 38. ir_code : loop_stmt
	# 39. ir_code : IR_CONTINUE \on_continue
	# 40. ir_code : if_stmt

	if (_rdpg_tok_is(IR_CALL()))
	{
		if (_rdpg_call_expr())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_RETURN()))
	{
		if (_rdpg_return_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_LOOP()))
	{
		if (_rdpg_loop_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_CONTINUE()))
	{
		on_continue()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_IF()))
	{
		if (_rdpg_if_stmt())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "ir_code")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_ir_code_plus()
{
	# 41. ir_code_plus : ir_code ir_code_star

	if (_rdpg_predict(_RDPG_sym_set_5))
	{
		if (_rdpg_ir_code())
		{
			if (_rdpg_ir_code_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "ir_code_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_23)
}
function _rdpg_ir_code_star()
{
	# 42. ir_code_star : ir_code ir_code_star
	# 43. ir_code_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_5))
		{
			if (_rdpg_ir_code())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "ir_code_star")
		}
		return _rdpg_sync(_RDPG_sym_set_23)
	}
}
function _rdpg_call_expr()
{
	# 44. call_expr : IR_CALL \on_call call_name call_arg_opt \on_call_end

	if (_rdpg_tok_is(IR_CALL()))
	{
		on_call()
		_rdpg_tok_next()
		if (_rdpg_call_name())
		{
			if (_rdpg_call_arg_opt())
			{
				on_call_end()
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_CALL())
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_call_name()
{
	# 45. call_name : NAME \on_call_name
	# 46. call_name : IR_TOK_IS \on_call_name
	# 47. call_name : IR_ESC \on_call_esc NAME \on_call_name
	# 48. call_name : IR_TOK_NEXT \on_call_name
	# 49. call_name : IR_TOK_MATCH \on_call_name
	# 50. call_name : IR_PREDICT \on_call_name
	# 51. call_name : IR_EXPECT \on_call_name
	# 52. call_name : IR_SYNC \on_call_name

	if (_rdpg_tok_is(NAME()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_TOK_IS()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_ESC()))
	{
		on_call_esc()
		_rdpg_tok_next()
		if (_rdpg_tok_is(NAME()))
		{
			on_call_name()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else if (_rdpg_tok_is(IR_TOK_NEXT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_TOK_MATCH()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_PREDICT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_EXPECT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_SYNC()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "call_name")
	}
	return _rdpg_sync(_RDPG_sym_set_16)
}
function _rdpg_call_arg()
{
	# 53. call_arg : NAME \on_call_arg

	if (_rdpg_tok_is(NAME()))
	{
		on_call_arg()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_call_arg_opt()
{
	# 54. call_arg_opt : call_arg
	# 55. call_arg_opt : 0

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_call_arg())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_6))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "call_arg_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_return_stmt()
{
	# 56. return_stmt : IR_RETURN \on_return return_rest \on_return_end

	if (_rdpg_tok_is(IR_RETURN()))
	{
		on_return()
		_rdpg_tok_next()
		if (_rdpg_return_rest())
		{
			on_return_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_RETURN())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_return_rest()
{
	# 57. return_rest : call_expr
	# 58. return_rest : IR_TRUE \on_ret_const
	# 59. return_rest : IR_FALSE \on_ret_const

	if (_rdpg_tok_is(IR_CALL()))
	{
		if (_rdpg_call_expr())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_TRUE()))
	{
		on_ret_const()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_FALSE()))
	{
		on_ret_const()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "return_rest")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_loop_stmt()
{
	# 60. loop_stmt : IR_LOOP \on_loop code_block \on_loop_end

	if (_rdpg_tok_is(IR_LOOP()))
	{
		on_loop()
		_rdpg_tok_next()
		if (_rdpg_code_block())
		{
			on_loop_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_LOOP())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_if_stmt()
{
	# 61. if_stmt : IR_IF \on_if call_expr code_block \on_if_end else_if_stmt_star else_stmt_opt

	if (_rdpg_tok_is(IR_IF()))
	{
		on_if()
		_rdpg_tok_next()
		if (_rdpg_call_expr())
		{
			if (_rdpg_code_block())
			{
				on_if_end()
				if (_rdpg_else_if_stmt_star())
				{
					if (_rdpg_else_stmt_opt())
					{
						return 1
					}
				}
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_IF())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_else_if_stmt()
{
	# 62. else_if_stmt : IR_ELSE_IF \on_else_if call_expr code_block \on_else_if_end

	if (_rdpg_tok_is(IR_ELSE_IF()))
	{
		on_else_if()
		_rdpg_tok_next()
		if (_rdpg_call_expr())
		{
			if (_rdpg_code_block())
			{
				on_else_if_end()
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ELSE_IF())
	}
	return _rdpg_sync(_RDPG_sym_set_18)
}
function _rdpg_else_if_stmt_star()
{
	# 63. else_if_stmt_star : else_if_stmt else_if_stmt_star
	# 64. else_if_stmt_star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_ELSE_IF()))
		{
			if (_rdpg_else_if_stmt())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_7))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "else_if_stmt_star")
		}
		return _rdpg_sync(_RDPG_sym_set_7)
	}
}
function _rdpg_else_stmt()
{
	# 65. else_stmt : IR_ELSE \on_else code_block \on_else_end

	if (_rdpg_tok_is(IR_ELSE()))
	{
		on_else()
		_rdpg_tok_next()
		if (_rdpg_code_block())
		{
			on_else_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ELSE())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_else_stmt_opt()
{
	# 66. else_stmt_opt : else_stmt
	# 67. else_stmt_opt : 0

	if (_rdpg_tok_is(IR_ELSE()))
	{
		if (_rdpg_else_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_8))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "else_stmt_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
# </rd>
# </parse>
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
# </prs>
# <ast>
# <structs-ast>
# structs:
#
# prefix ast
#
# type root_node
# has  cmnt_lst cmnt_lst
# has  tokens tokens
#
# type cmnt_lst
# has  head comment
# has  tail comment
#
# type comment
# has  str 
# has  next_ comment
#
# type tokens
# has  all_tok 
# has  tok_eoi 
# has  sets sets
#
# type sets
# has  alias_lst alias_lst
# has  set_lst set_lst
# has  parse_main parse_main
#
# type alias_lst
# has  head alias
# has  tail alias
#
# type alias
# has  name 
# has  data 
# has  next_ alias
#
# type set_lst
# has  head set
# has  tail set
#
# type set
# has  type 
# has  name 
# has  alias_name 
# has  next_ set
#
# type parse_main
# has  name 
# has  top_nont 
# has  err_var 
# has  fnc_lst fnc_lst
#
# type fnc_lst
# has  head fnc
# has  tail fnc
#
# type fnc
# has  name 
# has  cmnt_lst cmnt_lst
# has  code_lst code_lst
# has  next_ fnc
#
# type code_lst
# has  head code_node
# has  tail code_node
#
# type code_node
# has  code 
# has  next_ code_node
#
# type code_call
# has  is_esc 
# has  fname 
# has  arg 
#
# type code_ret
# has  const 
# has  call code_call
#
# type code_loop
# has  code_lst code_lst
#
# type code_continue
# has  none 
#
# type code_if
# has  cond code_call
# has  code_lst code_lst
#
# type code_else_if
# has  cond code_call
# has  code_lst code_lst
#
# type code_else
# has  code_lst code_lst
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

function ast_clear() {
	delete _STRUCTS_ast_db
	_ent_set("gen", _ent_get("gen")+1)
}
function ast_is(ent) {return (ent in _STRUCTS_ast_db)}
function ast_type_of(ent) {
	if (ent in _STRUCTS_ast_db)
		return _STRUCTS_ast_db[ent]
	ast_errq(sprintf("'%s' not an entity", ent))
}
function ast_new(type,    _ent) {
	_ast_set("ents", (_ent = _ast_get("ents")+1))
	_ent = ("_ast-" _ast_get("gen")+0 "-" _ent)
	_ast_set(_ent, type)
	return _ent
}
# <types>
# <type-root_node>
function AST_ROOT_NODE() {return "root_node"}

function ast_root_node_make(cmnt_lst, tokens,     _ent) {
	_ent = ast_new("root_node")
	ast_root_node_set_cmnt_lst(_ent, cmnt_lst)
	ast_root_node_set_tokens(_ent, tokens)
	return _ent
}

function ast_root_node_set_cmnt_lst(ent, cmnt_lst) {
	_ast_type_chk(ent, "root_node")
	if (cmnt_lst)
		_ast_type_chk(cmnt_lst, "cmnt_lst")
	_ast_set(("cmnt_lst=" ent), cmnt_lst)
}
function ast_root_node_get_cmnt_lst(ent) {
	_ast_type_chk(ent, "root_node")
	return _ast_get(("cmnt_lst=" ent))
}

function ast_root_node_set_tokens(ent, tokens) {
	_ast_type_chk(ent, "root_node")
	if (tokens)
		_ast_type_chk(tokens, "tokens")
	_ast_set(("tokens=" ent), tokens)
}
function ast_root_node_get_tokens(ent) {
	_ast_type_chk(ent, "root_node")
	return _ast_get(("tokens=" ent))
}

# <\type-root_node>
# <type-cmnt_lst>
function AST_CMNT_LST() {return "cmnt_lst"}

function ast_cmnt_lst_make(head, tail,     _ent) {
	_ent = ast_new("cmnt_lst")
	ast_cmnt_lst_set_head(_ent, head)
	ast_cmnt_lst_set_tail(_ent, tail)
	return _ent
}

function ast_cmnt_lst_set_head(ent, head) {
	_ast_type_chk(ent, "cmnt_lst")
	if (head)
		_ast_type_chk(head, "comment")
	_ast_set(("head=" ent), head)
}
function ast_cmnt_lst_get_head(ent) {
	_ast_type_chk(ent, "cmnt_lst")
	return _ast_get(("head=" ent))
}

function ast_cmnt_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "cmnt_lst")
	if (tail)
		_ast_type_chk(tail, "comment")
	_ast_set(("tail=" ent), tail)
}
function ast_cmnt_lst_get_tail(ent) {
	_ast_type_chk(ent, "cmnt_lst")
	return _ast_get(("tail=" ent))
}

# <\type-cmnt_lst>
# <type-comment>
function AST_COMMENT() {return "comment"}

function ast_comment_make(str, next_,     _ent) {
	_ent = ast_new("comment")
	ast_comment_set_str(_ent, str)
	ast_comment_set_next_(_ent, next_)
	return _ent
}

function ast_comment_set_str(ent, str) {
	_ast_type_chk(ent, "comment")
	_ast_set(("str=" ent), str)
}
function ast_comment_get_str(ent) {
	_ast_type_chk(ent, "comment")
	return _ast_get(("str=" ent))
}

function ast_comment_set_next_(ent, next_) {
	_ast_type_chk(ent, "comment")
	if (next_)
		_ast_type_chk(next_, "comment")
	_ast_set(("next_=" ent), next_)
}
function ast_comment_get_next_(ent) {
	_ast_type_chk(ent, "comment")
	return _ast_get(("next_=" ent))
}

# <\type-comment>
# <type-tokens>
function AST_TOKENS() {return "tokens"}

function ast_tokens_make(all_tok, tok_eoi, sets,     _ent) {
	_ent = ast_new("tokens")
	ast_tokens_set_all_tok(_ent, all_tok)
	ast_tokens_set_tok_eoi(_ent, tok_eoi)
	ast_tokens_set_sets(_ent, sets)
	return _ent
}

function ast_tokens_set_all_tok(ent, all_tok) {
	_ast_type_chk(ent, "tokens")
	_ast_set(("all_tok=" ent), all_tok)
}
function ast_tokens_get_all_tok(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("all_tok=" ent))
}

function ast_tokens_set_tok_eoi(ent, tok_eoi) {
	_ast_type_chk(ent, "tokens")
	_ast_set(("tok_eoi=" ent), tok_eoi)
}
function ast_tokens_get_tok_eoi(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("tok_eoi=" ent))
}

function ast_tokens_set_sets(ent, sets) {
	_ast_type_chk(ent, "tokens")
	if (sets)
		_ast_type_chk(sets, "sets")
	_ast_set(("sets=" ent), sets)
}
function ast_tokens_get_sets(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("sets=" ent))
}

# <\type-tokens>
# <type-sets>
function AST_SETS() {return "sets"}

function ast_sets_make(alias_lst, set_lst, parse_main,     _ent) {
	_ent = ast_new("sets")
	ast_sets_set_alias_lst(_ent, alias_lst)
	ast_sets_set_set_lst(_ent, set_lst)
	ast_sets_set_parse_main(_ent, parse_main)
	return _ent
}

function ast_sets_set_alias_lst(ent, alias_lst) {
	_ast_type_chk(ent, "sets")
	if (alias_lst)
		_ast_type_chk(alias_lst, "alias_lst")
	_ast_set(("alias_lst=" ent), alias_lst)
}
function ast_sets_get_alias_lst(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("alias_lst=" ent))
}

function ast_sets_set_set_lst(ent, set_lst) {
	_ast_type_chk(ent, "sets")
	if (set_lst)
		_ast_type_chk(set_lst, "set_lst")
	_ast_set(("set_lst=" ent), set_lst)
}
function ast_sets_get_set_lst(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("set_lst=" ent))
}

function ast_sets_set_parse_main(ent, parse_main) {
	_ast_type_chk(ent, "sets")
	if (parse_main)
		_ast_type_chk(parse_main, "parse_main")
	_ast_set(("parse_main=" ent), parse_main)
}
function ast_sets_get_parse_main(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("parse_main=" ent))
}

# <\type-sets>
# <type-alias_lst>
function AST_ALIAS_LST() {return "alias_lst"}

function ast_alias_lst_make(head, tail,     _ent) {
	_ent = ast_new("alias_lst")
	ast_alias_lst_set_head(_ent, head)
	ast_alias_lst_set_tail(_ent, tail)
	return _ent
}

function ast_alias_lst_set_head(ent, head) {
	_ast_type_chk(ent, "alias_lst")
	if (head)
		_ast_type_chk(head, "alias")
	_ast_set(("head=" ent), head)
}
function ast_alias_lst_get_head(ent) {
	_ast_type_chk(ent, "alias_lst")
	return _ast_get(("head=" ent))
}

function ast_alias_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "alias_lst")
	if (tail)
		_ast_type_chk(tail, "alias")
	_ast_set(("tail=" ent), tail)
}
function ast_alias_lst_get_tail(ent) {
	_ast_type_chk(ent, "alias_lst")
	return _ast_get(("tail=" ent))
}

# <\type-alias_lst>
# <type-alias>
function AST_ALIAS() {return "alias"}

function ast_alias_make(name, data, next_,     _ent) {
	_ent = ast_new("alias")
	ast_alias_set_name(_ent, name)
	ast_alias_set_data(_ent, data)
	ast_alias_set_next_(_ent, next_)
	return _ent
}

function ast_alias_set_name(ent, name) {
	_ast_type_chk(ent, "alias")
	_ast_set(("name=" ent), name)
}
function ast_alias_get_name(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("name=" ent))
}

function ast_alias_set_data(ent, data) {
	_ast_type_chk(ent, "alias")
	_ast_set(("data=" ent), data)
}
function ast_alias_get_data(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("data=" ent))
}

function ast_alias_set_next_(ent, next_) {
	_ast_type_chk(ent, "alias")
	if (next_)
		_ast_type_chk(next_, "alias")
	_ast_set(("next_=" ent), next_)
}
function ast_alias_get_next_(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("next_=" ent))
}

# <\type-alias>
# <type-set_lst>
function AST_SET_LST() {return "set_lst"}

function ast_set_lst_make(head, tail,     _ent) {
	_ent = ast_new("set_lst")
	ast_set_lst_set_head(_ent, head)
	ast_set_lst_set_tail(_ent, tail)
	return _ent
}

function ast_set_lst_set_head(ent, head) {
	_ast_type_chk(ent, "set_lst")
	if (head)
		_ast_type_chk(head, "set")
	_ast_set(("head=" ent), head)
}
function ast_set_lst_get_head(ent) {
	_ast_type_chk(ent, "set_lst")
	return _ast_get(("head=" ent))
}

function ast_set_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "set_lst")
	if (tail)
		_ast_type_chk(tail, "set")
	_ast_set(("tail=" ent), tail)
}
function ast_set_lst_get_tail(ent) {
	_ast_type_chk(ent, "set_lst")
	return _ast_get(("tail=" ent))
}

# <\type-set_lst>
# <type-set>
function AST_SET() {return "set"}

function ast_set_make(type, name, alias_name, next_,     _ent) {
	_ent = ast_new("set")
	ast_set_set_type(_ent, type)
	ast_set_set_name(_ent, name)
	ast_set_set_alias_name(_ent, alias_name)
	ast_set_set_next_(_ent, next_)
	return _ent
}

function ast_set_set_type(ent, type) {
	_ast_type_chk(ent, "set")
	_ast_set(("type=" ent), type)
}
function ast_set_get_type(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("type=" ent))
}

function ast_set_set_name(ent, name) {
	_ast_type_chk(ent, "set")
	_ast_set(("name=" ent), name)
}
function ast_set_get_name(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("name=" ent))
}

function ast_set_set_alias_name(ent, alias_name) {
	_ast_type_chk(ent, "set")
	_ast_set(("alias_name=" ent), alias_name)
}
function ast_set_get_alias_name(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("alias_name=" ent))
}

function ast_set_set_next_(ent, next_) {
	_ast_type_chk(ent, "set")
	if (next_)
		_ast_type_chk(next_, "set")
	_ast_set(("next_=" ent), next_)
}
function ast_set_get_next_(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("next_=" ent))
}

# <\type-set>
# <type-parse_main>
function AST_PARSE_MAIN() {return "parse_main"}

function ast_parse_main_make(name, top_nont, err_var, fnc_lst,     _ent) {
	_ent = ast_new("parse_main")
	ast_parse_main_set_name(_ent, name)
	ast_parse_main_set_top_nont(_ent, top_nont)
	ast_parse_main_set_err_var(_ent, err_var)
	ast_parse_main_set_fnc_lst(_ent, fnc_lst)
	return _ent
}

function ast_parse_main_set_name(ent, name) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("name=" ent), name)
}
function ast_parse_main_get_name(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("name=" ent))
}

function ast_parse_main_set_top_nont(ent, top_nont) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("top_nont=" ent), top_nont)
}
function ast_parse_main_get_top_nont(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("top_nont=" ent))
}

function ast_parse_main_set_err_var(ent, err_var) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("err_var=" ent), err_var)
}
function ast_parse_main_get_err_var(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("err_var=" ent))
}

function ast_parse_main_set_fnc_lst(ent, fnc_lst) {
	_ast_type_chk(ent, "parse_main")
	if (fnc_lst)
		_ast_type_chk(fnc_lst, "fnc_lst")
	_ast_set(("fnc_lst=" ent), fnc_lst)
}
function ast_parse_main_get_fnc_lst(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("fnc_lst=" ent))
}

# <\type-parse_main>
# <type-fnc_lst>
function AST_FNC_LST() {return "fnc_lst"}

function ast_fnc_lst_make(head, tail,     _ent) {
	_ent = ast_new("fnc_lst")
	ast_fnc_lst_set_head(_ent, head)
	ast_fnc_lst_set_tail(_ent, tail)
	return _ent
}

function ast_fnc_lst_set_head(ent, head) {
	_ast_type_chk(ent, "fnc_lst")
	if (head)
		_ast_type_chk(head, "fnc")
	_ast_set(("head=" ent), head)
}
function ast_fnc_lst_get_head(ent) {
	_ast_type_chk(ent, "fnc_lst")
	return _ast_get(("head=" ent))
}

function ast_fnc_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "fnc_lst")
	if (tail)
		_ast_type_chk(tail, "fnc")
	_ast_set(("tail=" ent), tail)
}
function ast_fnc_lst_get_tail(ent) {
	_ast_type_chk(ent, "fnc_lst")
	return _ast_get(("tail=" ent))
}

# <\type-fnc_lst>
# <type-fnc>
function AST_FNC() {return "fnc"}

function ast_fnc_make(name, cmnt_lst, code_lst, next_,     _ent) {
	_ent = ast_new("fnc")
	ast_fnc_set_name(_ent, name)
	ast_fnc_set_cmnt_lst(_ent, cmnt_lst)
	ast_fnc_set_code_lst(_ent, code_lst)
	ast_fnc_set_next_(_ent, next_)
	return _ent
}

function ast_fnc_set_name(ent, name) {
	_ast_type_chk(ent, "fnc")
	_ast_set(("name=" ent), name)
}
function ast_fnc_get_name(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("name=" ent))
}

function ast_fnc_set_cmnt_lst(ent, cmnt_lst) {
	_ast_type_chk(ent, "fnc")
	if (cmnt_lst)
		_ast_type_chk(cmnt_lst, "cmnt_lst")
	_ast_set(("cmnt_lst=" ent), cmnt_lst)
}
function ast_fnc_get_cmnt_lst(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("cmnt_lst=" ent))
}

function ast_fnc_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "fnc")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_fnc_get_code_lst(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("code_lst=" ent))
}

function ast_fnc_set_next_(ent, next_) {
	_ast_type_chk(ent, "fnc")
	if (next_)
		_ast_type_chk(next_, "fnc")
	_ast_set(("next_=" ent), next_)
}
function ast_fnc_get_next_(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("next_=" ent))
}

# <\type-fnc>
# <type-code_lst>
function AST_CODE_LST() {return "code_lst"}

function ast_code_lst_make(head, tail,     _ent) {
	_ent = ast_new("code_lst")
	ast_code_lst_set_head(_ent, head)
	ast_code_lst_set_tail(_ent, tail)
	return _ent
}

function ast_code_lst_set_head(ent, head) {
	_ast_type_chk(ent, "code_lst")
	if (head)
		_ast_type_chk(head, "code_node")
	_ast_set(("head=" ent), head)
}
function ast_code_lst_get_head(ent) {
	_ast_type_chk(ent, "code_lst")
	return _ast_get(("head=" ent))
}

function ast_code_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "code_lst")
	if (tail)
		_ast_type_chk(tail, "code_node")
	_ast_set(("tail=" ent), tail)
}
function ast_code_lst_get_tail(ent) {
	_ast_type_chk(ent, "code_lst")
	return _ast_get(("tail=" ent))
}

# <\type-code_lst>
# <type-code_node>
function AST_CODE_NODE() {return "code_node"}

function ast_code_node_make(code, next_,     _ent) {
	_ent = ast_new("code_node")
	ast_code_node_set_code(_ent, code)
	ast_code_node_set_next_(_ent, next_)
	return _ent
}

function ast_code_node_set_code(ent, code) {
	_ast_type_chk(ent, "code_node")
	_ast_set(("code=" ent), code)
}
function ast_code_node_get_code(ent) {
	_ast_type_chk(ent, "code_node")
	return _ast_get(("code=" ent))
}

function ast_code_node_set_next_(ent, next_) {
	_ast_type_chk(ent, "code_node")
	if (next_)
		_ast_type_chk(next_, "code_node")
	_ast_set(("next_=" ent), next_)
}
function ast_code_node_get_next_(ent) {
	_ast_type_chk(ent, "code_node")
	return _ast_get(("next_=" ent))
}

# <\type-code_node>
# <type-code_call>
function AST_CODE_CALL() {return "code_call"}

function ast_code_call_make(is_esc, fname, arg,     _ent) {
	_ent = ast_new("code_call")
	ast_code_call_set_is_esc(_ent, is_esc)
	ast_code_call_set_fname(_ent, fname)
	ast_code_call_set_arg(_ent, arg)
	return _ent
}

function ast_code_call_set_is_esc(ent, is_esc) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("is_esc=" ent), is_esc)
}
function ast_code_call_get_is_esc(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("is_esc=" ent))
}

function ast_code_call_set_fname(ent, fname) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("fname=" ent), fname)
}
function ast_code_call_get_fname(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("fname=" ent))
}

function ast_code_call_set_arg(ent, arg) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("arg=" ent), arg)
}
function ast_code_call_get_arg(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("arg=" ent))
}

# <\type-code_call>
# <type-code_ret>
function AST_CODE_RET() {return "code_ret"}

function ast_code_ret_make(const, call,     _ent) {
	_ent = ast_new("code_ret")
	ast_code_ret_set_const(_ent, const)
	ast_code_ret_set_call(_ent, call)
	return _ent
}

function ast_code_ret_set_const(ent, const) {
	_ast_type_chk(ent, "code_ret")
	_ast_set(("const=" ent), const)
}
function ast_code_ret_get_const(ent) {
	_ast_type_chk(ent, "code_ret")
	return _ast_get(("const=" ent))
}

function ast_code_ret_set_call(ent, call) {
	_ast_type_chk(ent, "code_ret")
	if (call)
		_ast_type_chk(call, "code_call")
	_ast_set(("call=" ent), call)
}
function ast_code_ret_get_call(ent) {
	_ast_type_chk(ent, "code_ret")
	return _ast_get(("call=" ent))
}

# <\type-code_ret>
# <type-code_loop>
function AST_CODE_LOOP() {return "code_loop"}

function ast_code_loop_make(code_lst,     _ent) {
	_ent = ast_new("code_loop")
	ast_code_loop_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_loop_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_loop")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_loop_get_code_lst(ent) {
	_ast_type_chk(ent, "code_loop")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_loop>
# <type-code_continue>
function AST_CODE_CONTINUE() {return "code_continue"}

function ast_code_continue_make(none,     _ent) {
	_ent = ast_new("code_continue")
	ast_code_continue_set_none(_ent, none)
	return _ent
}

function ast_code_continue_set_none(ent, none) {
	_ast_type_chk(ent, "code_continue")
	_ast_set(("none=" ent), none)
}
function ast_code_continue_get_none(ent) {
	_ast_type_chk(ent, "code_continue")
	return _ast_get(("none=" ent))
}

# <\type-code_continue>
# <type-code_if>
function AST_CODE_IF() {return "code_if"}

function ast_code_if_make(cond, code_lst,     _ent) {
	_ent = ast_new("code_if")
	ast_code_if_set_cond(_ent, cond)
	ast_code_if_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_if_set_cond(ent, cond) {
	_ast_type_chk(ent, "code_if")
	if (cond)
		_ast_type_chk(cond, "code_call")
	_ast_set(("cond=" ent), cond)
}
function ast_code_if_get_cond(ent) {
	_ast_type_chk(ent, "code_if")
	return _ast_get(("cond=" ent))
}

function ast_code_if_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_if")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_if_get_code_lst(ent) {
	_ast_type_chk(ent, "code_if")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_if>
# <type-code_else_if>
function AST_CODE_ELSE_IF() {return "code_else_if"}

function ast_code_else_if_make(cond, code_lst,     _ent) {
	_ent = ast_new("code_else_if")
	ast_code_else_if_set_cond(_ent, cond)
	ast_code_else_if_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_else_if_set_cond(ent, cond) {
	_ast_type_chk(ent, "code_else_if")
	if (cond)
		_ast_type_chk(cond, "code_call")
	_ast_set(("cond=" ent), cond)
}
function ast_code_else_if_get_cond(ent) {
	_ast_type_chk(ent, "code_else_if")
	return _ast_get(("cond=" ent))
}

function ast_code_else_if_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_else_if")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_else_if_get_code_lst(ent) {
	_ast_type_chk(ent, "code_else_if")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_else_if>
# <type-code_else>
function AST_CODE_ELSE() {return "code_else"}

function ast_code_else_make(code_lst,     _ent) {
	_ent = ast_new("code_else")
	ast_code_else_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_else_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_else")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_else_get_code_lst(ent) {
	_ast_type_chk(ent, "code_else")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_else>
# <\types>
# <\structs-ast>
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
# </ast>
# </parser>
