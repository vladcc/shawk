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

	G_getline_code = (getline G_current_line < G_current_file)
	
	if (G_getline_code > 0) {
		return (G_current_line "\n")
	} else if (0 == G_getline_code) {
		return ""
		close(G_current_file)
	} else {
		print sprintf("error: file '%s': %s",
			G_current_file, ERRNO) > "/dev/stderr"
		exit(1)
	} 
}

function process() {
	lex_init()

	if (ARGC > 2) {
		while (lex_next() != G_CONST_tok_eoi) 
			print lex_curr_tok()
	} else {
		while (lex_next() != G_CONST_tok_eoi)
			continue
	}
}

function set_file_name(str) {return str ? str : "/dev/stdin"}

function init() {
	# global variables for performance
	# avoids function calls and local variable creations
	
	G_CONST_ch_cls_word = CH_CLS_WORD()
	G_CONST_ch_cls_num = CH_CLS_NUMBER()
	G_CONST_tok_id = ID()
	G_CONST_tok_num = NUM()
	G_CONST_tok_eoi = TOK_EOI()
	G_current_line = ""
	G_getline_code = 0
	G_current_file = set_file_name(ARGV[1])
}

BEGIN {
	init()
	process()
}
