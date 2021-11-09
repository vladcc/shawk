#!/bin/usr/awk -f

function foo_lex_usr_get_word() {
	foo_lex_save_init()
	
	while (1) {
	
		foo_lex_save_curr_ch()

		if (foo_lex_is_next_ch_cls(G_CONST_ch_cls_word) ||
			foo_lex_is_next_ch_cls(G_CONST_ch_cls_num))
			foo_lex_read_ch()
		else
			break
	}
	
	return ((!foo_lex_is_saved_a_keyword()) ?
		G_CONST_tok_id : foo_lex_get_saved())
}

function foo_lex_usr_get_number() {
	foo_lex_save_init()
	
	while (1) {

		foo_lex_save_curr_ch()
		
		if (foo_lex_is_next_ch_cls(G_CONST_ch_cls_num))
			foo_lex_read_ch()
		else
			break
	}

	return G_CONST_tok_num
}

function foo_lex_usr_on_unknown_ch() {
	print sprintf("error: line %d, pos %d: unknown char '%s'", 
		foo_lex_get_line_no(), foo_lex_get_pos(), foo_lex_curr_ch())
	return FOO_TOK_ERROR()
}

function foo_lex_usr_get_line() {

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

function process(    _tok, _ccls, _ncls) {

	foo_lex_init()
	while ((_tok = foo_lex_next()) != G_CONST_tok_eoi) {

		# code coverage
		if (!foo_lex_match_tok(foo_lex_curr_tok()) ||
			foo_lex_match_tok(G_CONST_tok_eoi))
			error_quit("token mismatch")

		_ccls = foo_lex_get_ch_cls(foo_lex_curr_ch())
		_ncls = foo_lex_get_ch_cls(foo_lex_peek_ch())

		if (!foo_lex_is_ch_cls(foo_lex_curr_ch(), _ccls))
			error_quit("class lookup is wrong")
		
		if (!foo_lex_is_curr_ch_cls(_ccls))
			error_quit("current char class mismatch")

		if (!foo_lex_is_next_ch_cls(_ncls))
			error_quit("next char class mismatch")

		if (G_CONST_tok_if == _tok && !foo_lex_is_saved_a_keyword())
			error_quit("keyword mismatch")
		
		if ((G_CONST_tok_id == _tok) || (G_CONST_tok_num == _tok)) {
			print sprintf("'%s' '%s' line %d, pos %d",
				foo_lex_curr_tok(), foo_lex_get_saved(),
				foo_lex_get_line_no(), foo_lex_get_pos())
		} else {
			print sprintf("'%s' line %d, pos %d",
				foo_lex_curr_tok(), foo_lex_get_line_no(), foo_lex_get_pos())
		}
	}
}

function set_file_name(str) {_B_file_name = str ? str : "/dev/stdin"}
function get_file_name() {return _B_file_name}

function init() {
	# global variables for performance
	# avoids function calls and local variable creations
	
	G_CONST_ch_cls_word = FOO_CH_CLS_WORD()
	G_CONST_ch_cls_num = FOO_CH_CLS_NUMBER()
	G_CONST_tok_if = FOO_TOK_IF()
	G_CONST_tok_id = FOO_TOK_ID()
	G_CONST_tok_num = FOO_TOK_NUMBER()
	G_CONST_tok_eoi = FOO_TOK_EOI()
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
