#!/usr/bin/awk -f

function test_read_file(    _arr, _len) {
	at_test_begin("read_file()")

	_len = read_file("./data/awklib_read_file_data.txt", _arr)
	at_true(5 == _len)
	at_true("line 1" == _arr[1])
	at_true("  " == _arr[2])
	at_true("line 2" == _arr[3])
	at_true("" == _arr[4])
	at_true("line 3" == _arr[5])
}

function test_read_lines_all(    _arr, _len, _str) {
	at_test_begin("read_lines_all()")
	
	_str = \
"begin line\n"\
"foo\n"\
"\n"\
"bar\n"\
"# comment\n"\
"	baz\n"\
"  # another comment\n"\
"end line\n"\
"another line"

	_len = read_lines(_arr)
	at_true(_str == arr_to_str(_arr, _len, "\n"))
}

function test_read_lines_until(    _arr, _len, _str) {
	at_test_begin("read_lines_until()")
	
	_str = \
"begin line\n"\
"foo\n"\
"\n"\
"bar\n"\
"# comment\n"\
"	baz\n"\
"  # another comment"

	_len = read_lines(_arr, "end")
	at_true(_str == arr_to_str(_arr, _len, "\n"))
}

function test_read_lines_ignore(    _arr, _len, _str) {
	at_test_begin("read_lines_ignore()")
	
	_str = \
"begin line\n"\
"foo\n"\
"\n"\
"bar\n"\
"	baz\n"\
"end line\n"\
"another line"

	_len = read_lines(_arr, "", "^[[:space:]]*#")
	at_true(_str == arr_to_str(_arr, _len, "\n"))
}

function test_read_lines_until_ignore_diff(    _arr, _len, _str) {
	at_test_begin("read_lines_until_ignore_diff()")
	
	_str = \
"begin line\n"\
"foo\n"\
"\n"\
"bar\n"\
"	baz"

	_len = read_lines(_arr, "end", "^[[:space:]]*#")
	at_true(_str == arr_to_str(_arr, _len, "\n"))
}

function test_read_lines_until_ignore_same(    _arr, _len, _str) {
	at_test_begin("read_lines_until_ignore_same()")
	
	_str = \
"begin line\n"\
"foo\n"\
"\n"\
"bar"

	_len = read_lines(_arr, "^[[:space:]]*#", "^[[:space:]]*#")
	at_true(_str == arr_to_str(_arr, _len, "\n"))
}

function main() {
	at_awklib_awktest_required()
	
	if (0 == ReadLines)
		test_read_file()
	else if (1 == ReadLines)
		test_read_lines_all()
	else if (2 == ReadLines)
		test_read_lines_until()
	else if (3 == ReadLines)
		test_read_lines_ignore()
	else if (4 == ReadLines)
		test_read_lines_until_ignore_diff()
	else if (5 == ReadLines)
		test_read_lines_until_ignore_same()
		
	if (Report)
		at_report()
}

BEGIN {
	main()
}
