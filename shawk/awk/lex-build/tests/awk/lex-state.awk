#!/bin/usr/awk -f

function lex_usr_handle_slash() {}

function lex_usr_get_word() {
	lex_save_init()

	while (1) {

		lex_save_curr_ch()

		if (lex_is_next_ch_cls(G_CONST_ch_cls_word) ||
			lex_is_next_ch_cls(G_CONST_ch_cls_num))
			lex_read_ch()
		else
			break
	}

	return ((!lex_is_saved_a_keyword()) ? G_CONST_tok_id : lex_get_saved())
}

function lex_usr_get_number() {
	lex_save_init()

	while (1) {

		lex_save_curr_ch()

		if (lex_is_next_ch_cls(G_CONST_ch_cls_num))
			lex_read_ch()
		else
			break
	}

	return G_CONST_tok_num
}

function lex_usr_on_unknown_ch() {
	print sprintf("error: line %d, pos %d: unknown char '%s'",
		lex_get_line_no(), lex_get_pos(), lex_curr_ch())
	return TOK_ERROR()
}

function lex_usr_get_line() {

	G_getline_code = (getline G_current_line < get_file_name())

	if (G_getline_code > 0) {
		return (G_current_line "\n")
	} else if (0 == G_getline_code) {
		return ""
	} else {
		print sprintf("error: file '%s': %s",
			get_file_name(), ERRNO) > "/dev/stderr"
		exit(1)
	}
}

function error_quit(msg) {
	print sprintf("lex.awk: error: %s", msg) > "/dev/stderr"
	exit(1)
}

function assert(expr_val, expr_str) {
	if (!expr_str)
			error_quit("assert() called without expr_str")
	if (!expr_val)
		error_quit(sprintf("%s is false", expr_str))
}

function _state_get(    _1, _2, _3, _4, _5, _6, _7, _8, _9) {
	return \
	( \
	_1 _LEX_SEP() \
	_2 _LEX_SEP() \
	_3 _LEX_SEP() \
	_4 _LEX_SEP() \
	_5 _LEX_SEP() \
	_6 _LEX_SEP() \
	_7 _LEX_SEP() \
	_8 _LEX_SEP() \
	_9 _LEX_SEP() \
	)
}

function process(    _st_local_a, _st_local_b, _st_lex) {

	lex_init()
	lex_next()

	assert("=\n" == _B_lex_line_str, "\"=\\n\" == _B_lex_line_str")
	assert("=" == _B_lex_curr_ch, "\"=\" == _B_lex_curr_ch")
	assert(CH_CLS_AUTO_1_() == _B_lex_curr_ch_cls_cache,
		   "CH_CLS_AUTO_1_() == _B_lex_curr_ch_cls_cache")
	assert(TOK_EQ() == _B_lex_curr_tok, "TOK_EQ() == _B_lex_curr_tok")
	assert(1 == _B_lex_line_no, "1 == _B_lex_line_no")
	assert(2 == _B_lex_line_pos, "2 == _B_lex_line_pos")
	assert("\n" == _B_lex_peek_ch, "\"\\n\" == _B_lex_peek_ch")
	assert("\n" == _B_lex_peeked_ch_cache, "\"\\n\" == _B_lex_peeked_ch_cache")
	assert("" == _B_lex_saved, "\"\" == _B_lex_saved")

	_st_local_a = _state_get( \
		"=\n",
		"=",
		CH_CLS_AUTO_1_(),
		TOK_EQ(),
		1,
		2,
		"\n",
		"\n",
		""                    \
	)
	_st_lex = lex_state_get()
	assert(_st_local_a == _st_lex, "_st_local_a == _st_lex")

	_st_local_b = _state_get(            \
		_B_lex_line_str          = "foo",
		_B_lex_curr_ch           = "!",
		_B_lex_curr_ch_cls_cache = 777,
		_B_lex_curr_tok          = "baz",
		_B_lex_line_no           = 1000,
		_B_lex_line_pos          = 2000,
		_B_lex_peek_ch           = "@",
		_B_lex_peeked_ch_cache   = "#",
		_B_lex_saved             = "zog" \
	)
	assert(_st_local_b != _st_lex, "_st_local_b != _st_lex")
	_st_lex = lex_state_get()
	assert(_st_local_b == _st_lex, "_st_local_b == _st_lex")

	assert("foo" == _B_lex_line_str, "\"foo\" == _B_lex_line_str")
	assert("!" == _B_lex_curr_ch, "\"!\" == _B_lex_curr_ch")
	assert(777 == _B_lex_curr_ch_cls_cache, "777 == _B_lex_curr_ch_cls_cache")
	assert("baz" == _B_lex_curr_tok, "\"baz\" == _B_lex_curr_tok")
	assert(1000 == _B_lex_line_no, "1000 == _B_lex_line_no")
	assert(2000 == _B_lex_line_pos, "2000 == _B_lex_line_pos")
	assert("@" == _B_lex_peek_ch, "\"@\" == _B_lex_peek_ch")
	assert("#" == _B_lex_peeked_ch_cache, "\"#\" == _B_lex_peeked_ch_cache")
	assert("zog" == _B_lex_saved, "\"zog\" == _B_lex_saved")

	lex_state_set(_st_local_a)
	_st_lex = lex_state_get()
	assert(_st_local_a == _st_lex, "_st_local_a == _st_lex")
	assert(_st_local_b != _st_lex, "_st_local_b != _st_lex")

	assert("=\n" == _B_lex_line_str, "\"=\\n\" == _B_lex_line_str")
	assert("=" == _B_lex_curr_ch, "\"=\" == _B_lex_curr_ch")
	assert(CH_CLS_AUTO_1_() == _B_lex_curr_ch_cls_cache,
		   "CH_CLS_AUTO_1_() == _B_lex_curr_ch_cls_cache")
	assert(TOK_EQ() == _B_lex_curr_tok, "TOK_EQ() == _B_lex_curr_tok")
	assert(1 == _B_lex_line_no, "1 == _B_lex_line_no")
	assert(2 == _B_lex_line_pos, "2 == _B_lex_line_pos")
	assert("\n" == _B_lex_peek_ch, "\"\\n\" == _B_lex_peek_ch")
	assert("\n" == _B_lex_peeked_ch_cache, "\"\\n\" == _B_lex_peeked_ch_cache")
	assert("" == _B_lex_saved, "\"\" == _B_lex_saved")
}

function set_file_name(str) {_B_file_name = str ? str : "/dev/stdin"}
function get_file_name() {return _B_file_name}

function init() {
	# global variables for performance
	# avoids function calls and local variable creations

	G_CONST_ch_cls_word = CH_CLS_WORD()
	G_CONST_ch_cls_num = CH_CLS_NUMBER()
	G_CONST_tok_if = TOK_IF()
	G_CONST_tok_id = TOK_ID()
	G_CONST_tok_num = TOK_NUMBER()
	G_CONST_tok_eoi = TOK_EOI()
	G_CONST_tok_err = TOK_ERROR()
	G_current_line
	G_getline_code
}

function main(    _i, _fname) {
	if (ARGC > 1) {
		for (_i = 1; _i < ARGC; ++_i) {
			_fname = ARGV[_i]
			ARGV[_i] = ""

			set_file_name(_fname)
			process()
			close(get_file_name())
		}
	}
}

BEGIN {
	init()
	main()
}
