#!/usr/bin/awk -f

function test_ch_num_init() {
	at_test_begin("ch_num_init()")

	at_true(0 == ch_to_num("a"))
	at_true("" == num_to_ch(97))
	
	ch_num_init()
	at_true(97 == ch_to_num("a"))
	at_true("a" == num_to_ch(97))
}

function test_ch_to_num(    _i) {
	at_test_begin("ch_to_num()")

	ch_num_init()
	for (_i = 0; _i <= 127; ++_i) {
		
		if (0 == _i) at_true(ch_to_num("\\0") == 0)
		else if (7 == _i) at_true(ch_to_num("\\a") == 7)
		else if (8 == _i) at_true(ch_to_num("\\b") == 8)
		else if (9 == _i) at_true(ch_to_num("\\t") == 9)
		else if (10 == _i) at_true(ch_to_num("\\n") == 10)
		else if (11 == _i) at_true(ch_to_num("\\v") == 11)
		else if (12 == _i) at_true(ch_to_num("\\f") == 12)
		else if (13 == _i) at_true(ch_to_num("\\r") == 13)
		else if (27 == _i) at_true(ch_to_num("\\e") == 27)
		else at_true(_i == ch_to_num(sprintf("%c", _i)))
	}
}

function test_num_to_ch() {
	at_test_begin("num_to_ch()")

	ch_num_init()
	for (_i = 0; _i <= 127; ++_i) {
	
		if (0 == _i) at_true(num_to_ch(0) == "\\0")
		else if (7 == _i) at_true(num_to_ch(7) == "\\a")
		else if (8 == _i) at_true(num_to_ch(8) == "\\b")
		else if (9 == _i) at_true(num_to_ch(9) == "\\t")
		else if (10 == _i) at_true(num_to_ch(10) == "\\n")
		else if (11 == _i) at_true(num_to_ch(11) == "\\v")
		else if (12 == _i) at_true(num_to_ch(12) == "\\f")
		else if (13 == _i) at_true(num_to_ch(13) == "\\r")
		else if (27 == _i) at_true(num_to_ch(27) == "\\e")
		else at_true(sprintf("%c", _i) == num_to_ch(_i))
	}
}

function main() {
	at_awklib_awktest_required()
	test_ch_num_init()
	test_ch_to_num()
	test_num_to_ch()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
