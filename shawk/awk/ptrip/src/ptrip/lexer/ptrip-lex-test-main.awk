#!/usr/bin/awk -f

function SCRIPT_NAME() {return "ptrip-lex.awk"}
function SCRIPT_VERSION() {return "1.0"}

function exit_failure() {exit(1)}
function error_print(msg) {print msg > "/dev/stderr"}
function ptree_tok_err_exp(arr, len) {}

function lex_it(    _tok) {

	lex_init()
	print ""
	print ("input " get_file_name())
	while ((_tok = lex_next()) != TOK_EOI()) {
		
		if (TOK_INCLUDE() == _tok || TOK_WORD() == _tok)
			print (_tok " '" lex_get_saved() "'")
		else if (TOK_STRING() == _tok)
			print (_tok " " lex_usr_get_saved_string())
		else if (TOK_ERROR() == _tok)
			err_pretty(_tok)
		else if (TOK_NEW_LINE() == _tok)
			continue
		else
			print "'" _tok "'"
	}
}
function process_file(fname) {
	set_file_name(fname)
	lex_it()
	close(fname)
}
function main(    _i, _fname) {
	for (_i = 1; _i < ARGC; ++_i) {
		_fname = ARGV[_i]
		ARGV[_i] = ""
		process_file(_fname)
	}
}

BEGIN {
	main()
}

function set_file_name(fname) {_B_file_name = fname}
function get_file_name() {return _B_file_name}

function err_pretty(msg) {
	err_print(lex_usr_pos_msg(msg))
}
function err_print(msg) {
	print sprintf("%s: error: %s", SCRIPT_NAME(), msg)
}
