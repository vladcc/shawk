#!/bin/usr/awk -f

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

function process(    _tok, _ccls, _ncls) {

	lex_init()
	while ((_tok = lex_next()) != G_CONST_tok_eoi) {

		# code coverage
		if (!lex_match_tok(lex_curr_tok()) || lex_match_tok(G_CONST_tok_eoi))
			error_quit("token mismatch")

		_ccls = lex_get_ch_cls(lex_curr_ch())
		_ncls = lex_get_ch_cls(lex_peek_ch())

		if (!lex_is_ch_cls(lex_curr_ch(), _ccls))
			error_quit("class lookup is wrong")
		
		if (!lex_is_curr_ch_cls(_ccls))
			error_quit("current char class mismatch")

		if (!lex_is_next_ch_cls(_ncls))
			error_quit("next char class mismatch")

		if (G_CONST_tok_if == _tok && !lex_is_saved_a_keyword())
			error_quit("keyword mismatch")
		
		if ((G_CONST_tok_id == _tok) || (G_CONST_tok_num == _tok)) {
			print sprintf("'%s' '%s' line %d, pos %d",
				lex_curr_tok(), lex_get_saved(),
				lex_get_line_no(), lex_get_pos())
		} else {
			print sprintf("'%s' line %d, pos %d",
				lex_curr_tok(), lex_get_line_no(), lex_get_pos())
		}
	}
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
