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
		
		if (0x00 == _i) at_true(ch_to_num("\\0") == 0x00)
		else if (0x07 == _i) at_true(ch_to_num("\\a") == 0x07)
		else if (0x08 == _i) at_true(ch_to_num("\\b") == 0x08)
		else if (0x09 == _i) at_true(ch_to_num("\\t") == 0x09)
		else if (0x0A == _i) at_true(ch_to_num("\\n") == 0x0A)
		else if (0x0B == _i) at_true(ch_to_num("\\v") == 0x0B)
		else if (0x0C == _i) at_true(ch_to_num("\\f") == 0x0C)
		else if (0x0D == _i) at_true(ch_to_num("\\r") == 0x0D)
		else if (0x1B == _i) at_true(ch_to_num("\\e") == 0x1B)
		else at_true(_i == ch_to_num(sprintf("%c", _i)))
	}
}

function test_num_to_ch() {
	at_test_begin("num_to_ch()")

	ch_num_init()
	for (_i = 0; _i <= 127; ++_i) {
	
		if (0x00 == _i) at_true(num_to_ch(0x00) == "\\0")
		else if (0x07 == _i) at_true(num_to_ch(0x07) == "\\a")
		else if (0x08 == _i) at_true(num_to_ch(0x08) == "\\b")
		else if (0x09 == _i) at_true(num_to_ch(0x09) == "\\t")
		else if (0x0A == _i) at_true(num_to_ch(0x0A) == "\\n")
		else if (0x0B == _i) at_true(num_to_ch(0x0B) == "\\v")
		else if (0x0C == _i) at_true(num_to_ch(0x0C) == "\\f")
		else if (0x0D == _i) at_true(num_to_ch(0x0D) == "\\r")
		else if (0x1B == _i) at_true(num_to_ch(0x1B) == "\\e")
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
