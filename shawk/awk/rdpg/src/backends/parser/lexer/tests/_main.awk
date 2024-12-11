BEGIN {
	main()
}

function rdpg_expect(arr) {
	arr[1] = "foo"
	return 1
}

function error_quit(msg) {
	print msg > "/dev/stderr"
	exit(1)
}

function main(    _tok) {
	lex_init()
	if (TestErrFirst) {
		tok_next()
		tok_err()
	} else if (TestErr) {
		tok_next()
		tok_next()
		tok_err()
	} else {
		while ((_tok = tok_next()) != EOI()) {
			if (IR_COMMENT() == _tok) {
				print _tok
				print lex_get_line()
			} else if (NAME() == _tok) {
				print sprintf("%s %s", _tok, lex_get_name())
			} else {
				print _tok
			}
			print _lex_get_pos_str()
		}
	}
}
