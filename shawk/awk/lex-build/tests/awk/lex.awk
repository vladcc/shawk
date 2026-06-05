#!/bin/usr/awk -f

function lex_usr_handle_slash() {}

function lex_usr_get_word() {
	lex_save_init()

	while (1) {

		lex_save_curr_ch()

		if (lex_is_next_ch_cls(__lex_G_CONST_ch_cls_word) ||
			lex_is_next_ch_cls(__lex_G_CONST_ch_cls_num))
			lex_read_ch()
		else
			break
	}

	return ((!lex_is_saved_a_keyword()) \
		? __lex_G_CONST_tok_id : lex_get_saved())
}

function lex_usr_get_number() {
	lex_save_init()

	while (1) {

		lex_save_curr_ch()

		if (lex_is_next_ch_cls(__lex_G_CONST_ch_cls_num))
			lex_read_ch()
		else
			break
	}

	return __lex_G_CONST_tok_num
}

function lex_usr_on_unknown_ch() {
	print sprintf("error: line %d, pos %d: unknown char '%s'",
		lex_get_line_num(), lex_get_pos(), lex_curr_ch())
	return TOK_ERROR()
}

function lex_usr_get_line() {

	__lex_G_getline_code = \
		(getline __lex_G_current_line < __lex_get_file_name())

	if (__lex_G_getline_code > 0) {
		return (__lex_G_current_line "\n")
	} else if (0 == __lex_G_getline_code) {
		return ""
	} else {
		print sprintf("error: file '%s': %s",
			__lex_get_file_name(), ERRNO) > "/dev/stderr"
		exit(1)
	}
}

function __lex_error_quit(msg) {
	print sprintf("lex.awk: error: %s", msg) > "/dev/stderr"
	exit(1)
}

function __lex_process(    _tok, _ccls, _ncls) {

	lex_init()
	while ((_tok = lex_next()) != __lex_G_CONST_tok_eoi) {
		# code coverage
		if (!lex_match_tok(lex_curr_tok()) ||
			lex_match_tok(__lex_G_CONST_tok_eoi)) {
			__lex_error_quit("token mismatch")
		}

		_ccls = lex_get_ch_cls(lex_curr_ch())
		_ncls = lex_get_ch_cls(lex_peek_ch())

		if (!lex_is_ch_cls(lex_curr_ch(), _ccls))
			__lex_error_quit("class lookup is wrong")

		if (!lex_is_curr_ch_cls(_ccls))
			__lex_error_quit("current char class mismatch")

		if (!lex_is_next_ch_cls(_ncls))
			__lex_error_quit("next char class mismatch")

		if (__lex_G_CONST_tok_if == _tok && !lex_is_saved_a_keyword())
			__lex_error_quit("keyword mismatch")

		if ((__lex_G_CONST_tok_id == _tok) || (__lex_G_CONST_tok_num == _tok)) {
			print sprintf("'%s' '%s' line %d, pos %d",
				lex_curr_tok(), lex_get_saved(),
				lex_get_line_num(), lex_get_pos())
		} else {
			print sprintf("'%s' line %d, pos %d",
				lex_curr_tok(), lex_get_line_num(), lex_get_pos())
		}
	}

	# make sure spaces in token strings are handled correctly
	print sprintf("'%s'", TOK_FCALL())
}

function __lex_str_pos(    _tok, _txt, _pos) {
	lex_init()
	while ((_tok = lex_next()) != __lex_G_CONST_tok_eoi) {

		if ((__lex_G_CONST_tok_id == _tok) || (__lex_G_CONST_tok_num == _tok))
			_txt = lex_get_saved()
		else if (__lex_G_CONST_tok_err == _tok)
			_txt = "x" # single character
		else
			_txt = _tok

		print sprintf("line %d, pos %d:", lex_get_line_num(), lex_get_pos())
		print lex_get_pos_str()

		_pos = lex_get_pos() - length(_txt) + 1
		print sprintf("line %d, pos %d:", lex_get_line_num(), _pos)
		print lex_get_pos_str(_txt)
	}

	# make sure no empty line is read
	lex_next()
	print sprintf("line %d, pos %d:", lex_get_line_num(), lex_get_pos())
	print lex_get_pos_str()
	lex_next()
	print sprintf("line %d, pos %d:", lex_get_line_num(), lex_get_pos())
	print lex_get_pos_str()
	lex_next()
	print sprintf("line %d, pos %d:", lex_get_line_num(), lex_get_pos())
	print lex_get_pos_str()
}

function __lex_assert(expr, which) {
	if (!expr) {
		print sprintf("assertion %s failed", which) > "/dev/stderr"
		exit(1)
	}
}

function __lex_peek_1(    _a) {
	lex_init()

	__lex_assert(lex_get_pos() == 0, ++_a)
	__lex_assert(lex_get_line_num() == 1, ++_a)
	__lex_assert(lex_curr_ch() == "", ++_a)
	__lex_assert(lex_peek_ch() == "", ++_a)

	__lex_assert(lex_read_ch() == "f", ++_a)
	__lex_assert(lex_curr_ch() == "f", ++_a)
	__lex_assert(lex_peek_ch() == "o", ++_a)
	__lex_assert(lex_get_pos() == 1, ++_a)
	__lex_assert(lex_get_line_num() == 1, ++_a)

	__lex_assert(lex_read_ch() == "o", ++_a)
	__lex_assert(lex_curr_ch() == "o", ++_a)
	__lex_assert(lex_peek_ch() == "_", ++_a)
	__lex_assert(lex_get_pos() == 2, ++_a)
	__lex_assert(lex_get_line_num() == 1, ++_a)

	__lex_assert(lex_read_ch() == "_", ++_a)
	__lex_assert(lex_curr_ch() == "_", ++_a)
	__lex_assert(lex_peek_ch() == "\n", ++_a)
	__lex_assert(lex_get_pos() == 3, ++_a)
	__lex_assert(lex_get_line_num() == 1, ++_a)

	__lex_assert(lex_read_ch() == "\n", ++_a)
	__lex_assert(lex_curr_ch() == "\n", ++_a)
	__lex_assert(lex_peek_ch() == "F", ++_a)
	__lex_assert(lex_get_pos() == 0, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "F", ++_a)
	__lex_assert(lex_curr_ch() == "F", ++_a)
	__lex_assert(lex_peek_ch() == "O", ++_a)
	__lex_assert(lex_get_pos() == 1, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "O", ++_a)
	__lex_assert(lex_curr_ch() == "O", ++_a)
	__lex_assert(lex_peek_ch() == "_", ++_a)
	__lex_assert(lex_get_pos() == 2, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "_", ++_a)
	__lex_assert(lex_curr_ch() == "_", ++_a)
	__lex_assert(lex_peek_ch() == "\n", ++_a)
	__lex_assert(lex_get_pos() == 3, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "\n", ++_a)
	__lex_assert(lex_curr_ch() == "\n", ++_a)
	__lex_assert(lex_peek_ch() == "", ++_a)
	__lex_assert(lex_get_pos() == 4, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "", ++_a)
	__lex_assert(lex_curr_ch() == "", ++_a)
	__lex_assert(lex_peek_ch() == "", ++_a)
	__lex_assert(lex_get_pos() == 4, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)

	__lex_assert(lex_read_ch() == "", ++_a)
	__lex_assert(lex_curr_ch() == "", ++_a)
	__lex_assert(lex_peek_ch() == "", ++_a)
	__lex_assert(lex_get_pos() == 4, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)
}

function __lex_peek_2(    _a, _tok) {
	lex_init()

	_tok = lex_next()
	__lex_assert(TOK_ID() == _tok, ++_a)
	__lex_assert("fo_" == lex_get_saved(), ++_a)
	__lex_assert(lex_get_pos() == 3, ++_a)
	__lex_assert(lex_get_line_num() == 1, ++_a)
	__lex_assert(lex_curr_ch() == "_", ++_a)
	__lex_assert(lex_peek_ch() == "\n", ++_a)


	__lex_assert(lex_read_ch() == "\n", ++_a)
	__lex_assert(lex_curr_ch() == "\n", ++_a)
	__lex_assert(lex_peek_ch() == "F", ++_a)
	__lex_assert(lex_get_pos() == 0, ++_a)
	__lex_assert(lex_get_line_num() == 2, ++_a)
}

function __lex_set_file_name(str) {_B_file_name = str ? str : "/dev/stdin"}
function __lex_get_file_name() {return _B_file_name}

function __lex_init() {
	# global variables for performance
	# avoids function calls and local variable creations

	__lex_G_CONST_ch_cls_word = CH_CLS_WORD()
	__lex_G_CONST_ch_cls_num = CH_CLS_NUMBER()
	__lex_G_CONST_tok_if = TOK_IF()
	__lex_G_CONST_tok_id = TOK_ID()
	__lex_G_CONST_tok_num = TOK_NUMBER()
	__lex_G_CONST_tok_eoi = TOK_EOI()
	__lex_G_CONST_tok_err = TOK_ERROR()
	__lex_G_current_line
	__lex_G_getline_code
}

function __lex_main(    _i, _fname) {
	if (ARGC > 1) {
		for (_i = 1; _i < ARGC; ++_i) {
			_fname = ARGV[_i]
			ARGV[_i] = ""

			__lex_set_file_name(_fname)
			if (StrPos)
				__lex_str_pos()
			else if (1 == Peek)
				__lex_peek_1()
			else if (2 == Peek)
				__lex_peek_2()
			else
				__lex_process()
			close(__lex_get_file_name())
		}
	}
}

BEGIN {
	__lex_init()
	__lex_main()
}
