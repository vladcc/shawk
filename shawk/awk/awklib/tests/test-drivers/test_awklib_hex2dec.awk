#!/usr/bin/awk -f

function test_hex2dec() {
	at_test_begin("test_hex2dec()")

	at_true(0 == hex2dec("foo"))
	at_true(0 == hex2dec("0x0"))
	at_true(4096 == hex2dec("1000"))
	at_true(4096 == hex2dec("0x1000"))
	at_true(4096 == hex2dec("0X1000"))
	at_true(4096 == hex2dec("1000h"))
	at_true(4096 == hex2dec("1000H"))
	at_true(4096 == hex2dec("0x1000h"))
	at_true(0 == hex2dec("0x1000 "))
	at_true(0 == hex2dec(" 0x1000"))
}

function main() {
	at_awklib_awktest_required()
	test_hex2dec()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
