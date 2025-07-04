# Test definitions
function parsing_error_happened() {return _B_parsing_error_flag}
function parsing_error_set() {_B_parsing_error_flag = 1}

function if_fatal_exit() {}
function error_print(msg) {
	G_error_happend = 1
	print sprintf("error: %s", msg) > "/dev/stderr"
}
function exit_failure() {
    # pass through for testing
}
function error_quit(msg) {
	error_print(msg)
	if (match(msg, "getline "))
		exit(1)
}

function rdpg_expect(arr) {
	++_B_num_calls
	if (1 == _B_num_calls) {
		arr[1] = "foo"
		return 1
	} else {
		arr[1] = "zig"
		arr[2] = "zag"
		return 2
	}
}

function out(msg) {
	print sprintf("%d:%d: %s", lex_get_line_no(), lex_get_pos(), msg)
	print lex_get_pos_str()
}

function fname() {return FILENAME}

function lex(    _tok) {
	lex_init()
	if (TokErr) {
		_tok = lex_next()
		tok_err()
		_tok = lex_next()
		tok_err()

	} else {
		while ((_tok = lex_next()) != TOK_EOI()) {
			if (!G_error_happend) {
				if (START_SYM() == _tok || TERM() == _tok || NONT() == _tok)
					out(sprintf("%s %s", _tok, lex_get_saved()))
				else
					out(sprintf("%s", _tok))
			}
		}
	}

	if (G_error_happend)
		exit(1)
}

BEGIN {
	lex()
}
