#!/usr/bin/awk -f

function SCRIPT_NAME() {return "awkson-lex.awk"}
function SCRIPT_VERSION() {return "1.0"}

function _prs_usr_type_set_has(x) {}
function _prs_usr_type_get_default_val(x) {}

function lex_it(    _tok) {

	_lex_init()
	while ((_tok = _lex_next()) != _TOK_EOI())
		pretty_print(_tok)
}
function process_file(fname) {
	_set_file_name(fname)
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

function _run_once() {
	_lex_usr_init_hex_digit()
	_lex_usr_init_esc_chars()
}
BEGIN {
	_run_once()
	main()
}

function lex_pretty_pos(line,    _ptr, _arr, _ch, _i, _end) {
	split(line, _arr, "")
	
	_end = _lex_get_pos()
	for (_i = 1; _i < _end; ++_i) {
		_ch = _arr[_i]
		_ptr = (_ptr (_ch != "\t" ? " " : "\t"))
	}
		
	return (line "\n" _ptr "^")
}
function pretty_print(msg) {
	print sprintf("file '%s', line %d, pos %d: %s",
		get_file_name(), _lex_get_line_no(), _lex_get_pos(), msg)
	print lex_pretty_pos(_lex_get_line_str())
}
