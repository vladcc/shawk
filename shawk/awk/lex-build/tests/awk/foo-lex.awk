#!/bin/usr/awk -f

function foo_lex_usr_handle_slash() {}

function foo_lex_usr_get_word() {
	foo_lex_save_init()

	while (1) {

		foo_lex_save_curr_ch()

		if (foo_lex_is_next_ch_cls(__foo_lex_G_CONST_ch_cls_word) ||
			foo_lex_is_next_ch_cls(__foo_lex_G_CONST_ch_cls_num))
			foo_lex_read_ch()
		else
			break
	}

	return ((!foo_lex_is_saved_a_keyword()) \
		? __foo_lex_G_CONST_tok_id : foo_lex_get_saved())
}

function foo_lex_usr_get_number() {
	foo_lex_save_init()

	while (1) {

		foo_lex_save_curr_ch()

		if (foo_lex_is_next_ch_cls(__foo_lex_G_CONST_ch_cls_num))
			foo_lex_read_ch()
		else
			break
	}

	return __foo_lex_G_CONST_tok_num
}

function foo_lex_usr_on_unknown_ch() {
	print sprintf("error: line %d, pos %d: unknown char '%s'",
		foo_lex_get_line_num(), foo_lex_get_pos(), foo_lex_curr_ch())
	return FOO_TOK_ERROR()
}

function foo_lex_usr_get_line() {

	__foo_lex_G_getline_code = \
		(getline __foo_lex_G_current_line < __foo_lex_get_file_name())

	if (__foo_lex_G_getline_code > 0) {
		return (__foo_lex_G_current_line "\n")
	} else if (0 == __foo_lex_G_getline_code) {
		return ""
	} else {
		print sprintf("error: file '%s': %s",
			__foo_lex_get_file_name(), ERRNO) > "/dev/stderr"
		exit(1)
	}
}

function __foo_lex_error_quit(msg) {
	print sprintf("lex.awk: error: %s", msg) > "/dev/stderr"
	exit(1)
}

function __foo_lex_process(    _tok, _ccls, _ncls) {

	foo_lex_init()
	while ((_tok = foo_lex_next()) != __foo_lex_G_CONST_tok_eoi) {
		# code coverage
		if (!foo_lex_match_tok(foo_lex_curr_tok()) ||
			foo_lex_match_tok(__foo_lex_G_CONST_tok_eoi)) {
			__foo_lex_error_quit("token mismatch")
		}

		_ccls = foo_lex_get_ch_cls(foo_lex_curr_ch())
		_ncls = foo_lex_get_ch_cls(foo_lex_peek_ch())

		if (!foo_lex_is_ch_cls(foo_lex_curr_ch(), _ccls))
			__foo_lex_error_quit("class lookup is wrong")

		if (!foo_lex_is_curr_ch_cls(_ccls))
			__foo_lex_error_quit("current char class mismatch")

		if (!foo_lex_is_next_ch_cls(_ncls))
			__foo_lex_error_quit("next char class mismatch")

		if (__foo_lex_G_CONST_tok_if == _tok && !foo_lex_is_saved_a_keyword())
			__foo_lex_error_quit("keyword mismatch")

		if ((__foo_lex_G_CONST_tok_id == _tok) ||
			(__foo_lex_G_CONST_tok_num == _tok)) {
			print sprintf("'%s' '%s' line %d, pos %d",
				foo_lex_curr_tok(), foo_lex_get_saved(),
				foo_lex_get_line_num(), foo_lex_get_pos())
		} else {
			print sprintf("'%s' line %d, pos %d",
				foo_lex_curr_tok(), foo_lex_get_line_num(), foo_lex_get_pos())
		}
	}

	# make sure spaces in token strings are handled correctly
	print sprintf("'%s'", FOO_TOK_FCALL())
}

function __foo_lex_str_pos(    _tok, _txt, _pos) {
	foo_lex_init()
	while ((_tok = foo_lex_next()) != __foo_lex_G_CONST_tok_eoi) {

		if ((__foo_lex_G_CONST_tok_id == _tok) ||
			(__foo_lex_G_CONST_tok_num == _tok)) {
			_txt = foo_lex_get_saved()
		} else if (__foo_lex_G_CONST_tok_err == _tok) {
			_txt = "x" # single character
		} else {
			_txt = _tok
		}

		print sprintf("line %d, pos %d:",
			foo_lex_get_line_num(), foo_lex_get_pos())
		print foo_lex_get_pos_str()

		_pos = foo_lex_get_pos() - length(_txt) + 1
		print sprintf("line %d, pos %d:", foo_lex_get_line_num(), _pos)
		print foo_lex_get_pos_str(_txt)
	}

	# make sure no empty line is read
	foo_lex_next()
	print sprintf("line %d, pos %d:", foo_lex_get_line_num(), foo_lex_get_pos())
	print foo_lex_get_pos_str()
	foo_lex_next()
	print sprintf("line %d, pos %d:", foo_lex_get_line_num(), foo_lex_get_pos())
	print foo_lex_get_pos_str()
	foo_lex_next()
	print sprintf("line %d, pos %d:", foo_lex_get_line_num(), foo_lex_get_pos())
	print foo_lex_get_pos_str()
}

function __foo_lex_assert(expr, which) {
	if (!expr) {
		print sprintf("assertion %s failed", which) > "/dev/stderr"
		exit(1)
	}
}

function __foo_lex_peek_1(    _a) {
	foo_lex_init()

	__foo_lex_assert(foo_lex_get_pos() == 0, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 1, ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "", ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "f", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "f", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "o", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 1, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 1, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "o", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "o", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 2, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 1, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 3, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 1, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "F", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 0, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "F", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "F", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "O", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 1, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "O", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "O", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 2, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 3, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 4, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 4, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)

	__foo_lex_assert(foo_lex_read_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 4, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)
}

function __foo_lex_peek_2(    _a, _tok) {
	foo_lex_init()

	_tok = foo_lex_next()
	__foo_lex_assert(FOO_TOK_ID() == _tok, ++_a)
	__foo_lex_assert("fo_" == foo_lex_get_saved(), ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 3, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 1, ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "_", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "\n", ++_a)


	__foo_lex_assert(foo_lex_read_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_curr_ch() == "\n", ++_a)
	__foo_lex_assert(foo_lex_peek_ch() == "F", ++_a)
	__foo_lex_assert(foo_lex_get_pos() == 0, ++_a)
	__foo_lex_assert(foo_lex_get_line_num() == 2, ++_a)
}

function __foo_lex_set_file_name(str) {_B_file_name = str ? str : "/dev/stdin"}
function __foo_lex_get_file_name() {return _B_file_name}

function __foo_lex_init() {
	# global variables for performance
	# avoids function calls and local variable creations

	__foo_lex_G_CONST_ch_cls_word = FOO_CH_CLS_WORD()
	__foo_lex_G_CONST_ch_cls_num = FOO_CH_CLS_NUMBER()
	__foo_lex_G_CONST_tok_if = FOO_TOK_IF()
	__foo_lex_G_CONST_tok_id = FOO_TOK_ID()
	__foo_lex_G_CONST_tok_num = FOO_TOK_NUMBER()
	__foo_lex_G_CONST_tok_eoi = FOO_TOK_EOI()
	__foo_lex_G_CONST_tok_err = FOO_TOK_ERROR()
	__foo_lex_G_current_line
	__foo_lex_G_getline_code
}

function __foo_lex_main(    _i, _fname) {
	if (ARGC > 1) {
		for (_i = 1; _i < ARGC; ++_i) {
			_fname = ARGV[_i]
			ARGV[_i] = ""

			__foo_lex_set_file_name(_fname)
			if (StrPos)
				__foo_lex_str_pos()
			else if (1 == Peek)
				__foo_lex_peek_1()
			else if (2 == Peek)
				__foo_lex_peek_2()
			else
				__foo_lex_process()
			close(__foo_lex_get_file_name())
		}
	}
}

BEGIN {
	__foo_lex_init()
	__foo_lex_main()
}
