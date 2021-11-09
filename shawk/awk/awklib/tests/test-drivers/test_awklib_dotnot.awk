#!/usr/bin/awk -f

function test_dotnot_parse_errors(    _str, _parsed) {
	at_test_begin("test_dotnot_parse_errors()")

	at_true(!dotnot_get_error_str())
	at_true(!dotnot_get_error_pos())
	
	
	
	# no string
	_str = ""
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())

	_str = "."
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = "..."
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = "foo."
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(5 == dotnot_get_error_pos())
	
	_str = ".foo"
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = ".\"foo"
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = "\"foo \"."
	at_true("" == dotnot_parse(_str))
	at_true("string or word expected" == dotnot_get_error_str())
	at_true(8 == dotnot_get_error_pos())
	
	
	
	# unquoted characters
	_str = " "
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = "\t"
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = " \t  "
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(1 == dotnot_get_error_pos())
	
	_str = "foo\""
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(4 == dotnot_get_error_pos())
	
	_str = "foo\"."
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(4 == dotnot_get_error_pos())
	
	_str = "foo\"bar"
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(4 == dotnot_get_error_pos())
	
	str = "foo bar"
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(4 == dotnot_get_error_pos())
	
	str = "foo\tbar"
	at_true("" == dotnot_parse(_str))
	at_true("character should be quoted" == dotnot_get_error_str())
	at_true(4 == dotnot_get_error_pos())
	
	
	
	# no closing quote
	_str = "\"foo"
	at_true("" == dotnot_parse(_str))
	at_true("no closing quote" == dotnot_get_error_str())
	at_true(5 == dotnot_get_error_pos())
	
	_str = "\"foo .bar"
	at_true("" == dotnot_parse(_str))
	at_true("no closing quote" == dotnot_get_error_str())
	at_true(10 == dotnot_get_error_pos())
	
	
	
	# bad separator
	_str = "\"foo bar\"\""
	at_true("" == dotnot_parse(_str))
	at_true("bad separator" == dotnot_get_error_str())
	at_true(10 == dotnot_get_error_pos())
}

function test_dotnot_parse(    _str, _parsed, _arr) {
	at_test_begin("dotnot_parse()")
	
	_str = "foo"
	_parsed = dotnot_parse(_str)
	at_true("foo"== _parsed)
	
	_str = "\"foo\""
	_parsed = dotnot_parse(_str)
	at_true("\"foo\""== _parsed)
	
	_str = "foo.bar"
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "bar") == _parsed)
	
	_str = "foo.\"bar\""
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "\"bar\"") == _parsed)
	
	_str = "\"foo.bar\""
	_parsed = dotnot_parse(_str)
	at_true(_str == _parsed)
	
	_str = "\"\""
	_parsed = dotnot_parse(_str)
	at_true(_str == _parsed)
	
	_str = "foo.\"\".bar"
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "\"\"" _DOTNOT_SEP() "bar") == _parsed)
	
	_str = "foo.\"this is \\\" a string\""
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "\"this is \\\" a string\"") == _parsed)
	
	_str = "foo.\"this is \\\" a string\".bar"
	_parsed = dotnot_parse(_str)
	at_true(\
		("foo" _DOTNOT_SEP() "\"this is \\\" a string\"" _DOTNOT_SEP() "bar") \
			== _parsed)
	
	_str = "a.b.c.d.e.f.g"
	at_true(!_dotnot_cache_has(_str))
	_parsed = dotnot_parse(_str)
	at_true(_dotnot_cache_has(_str))
	at_true(_parsed == _dotnot_cache_get(_str))
	at_true(_str == dotnot_pretty(_parsed))
	at_true("a-b-c-d-e-f-g" == dotnot_pretty(_parsed, "-"))
	at_true(7 == dotnot_split(_arr, _parsed))
	
	_str = "a.b.c.d.e.f.g"
	at_true(_dotnot_cache_has(_str))
	_parsed = dotnot_parse(_str)
	at_true(_dotnot_cache_has(_str))
	at_true(_parsed == _dotnot_cache_get(_str))
	at_true(_str == dotnot_pretty(_parsed))
	at_true("a-b-c-d-e-f-g" == dotnot_pretty(_parsed, "-"))
	at_true(7 == dotnot_split(_arr, _parsed))
	
	_str = "\"a . b\".c"
	_parsed = dotnot_parse(_str)
	at_true(("\"a . b\"" _DOTNOT_SEP() "c") == _parsed)
	at_true(_str == dotnot_pretty(_parsed))
	at_true(2 == dotnot_split(_arr, _parsed))
	at_true("\"a . b\"" == _arr[1])
	at_true("c" == _arr[2])
	
	_str = "\"a . b\".c.\" de \t f \""
	_parsed = dotnot_parse(_str)
	at_true(("\"a . b\"" _DOTNOT_SEP() "c" _DOTNOT_SEP() "\" de \t f \"") == \
		_parsed)
	at_true(_str == dotnot_pretty(_parsed))
	at_true(3 == dotnot_split(_arr, _parsed))
	at_true("\"a . b\"" == _arr[1])
	at_true("c" == _arr[2])
	at_true("\" de \t f \"" == _arr[3])
	
	_str = "foo.bar.baz.zig"
	_parsed = dotnot_parse(_str)
	at_true(\
		("foo" _DOTNOT_SEP() "bar" _DOTNOT_SEP() "baz" _DOTNOT_SEP() "zig") == \
		_parsed)
	
	_str = "\"foo.bar\".baz.zig"
	_parsed = dotnot_parse(_str)
	at_true(("\"foo.bar\"" _DOTNOT_SEP() "baz" _DOTNOT_SEP() "zig") == _parsed)
	
	_str = "foo.\"bar.baz\".zig"
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "\"bar.baz\"" _DOTNOT_SEP() "zig") == _parsed)
	
	_str = "foo.bar.\"baz.zig\""
	_parsed = dotnot_parse(_str)
	at_true(("foo" _DOTNOT_SEP() "bar" _DOTNOT_SEP() "\"baz.zig\"") == _parsed)
}

function main() {
	at_awklib_awktest_required()
	test_dotnot_parse_errors()
	test_dotnot_parse()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
