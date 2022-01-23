#!/usr/bin/awk -f

# for awks which do not recognize hex constants
function _0xA() {return 10}
function _0xAA() {return 170}
function _0xAAA() {return 2730}
function _0xAAAA() {return 43690}
function _0xAAAAAA() {return 11184810}
function _0xAAAAAAAA() {return 2863311530}
function _0xAAAAAAAAAA() {return 733007751850}

function _0x5555() {return 21845}
function _0x555555() {return 5592405}
function _0x55555555() {return 1431655765}
function _0x5555555555() {return 366503875925}
function _0x555555555555() {return 93824992236885}

function _0xFFFF() {return 65535}
function _0xFFFFFF() {return 16777215}
function _0xFFFFFFFF() {return 4294967295}
function _0xFFFFFFFFFF() {return 1099511627775}

function _0x7FFFFFFF() {return 2147483647}
function _0xFFFFFFFE() {return 4294967294}

function _0xFFAA() {return 65450}

function _0xAABBCCDDEEFF() {return 187723572702975}

function test_bw_and() {
	at_test_begin("bw_and()")

	at_true(-1 == bw_and(-12321, 10))
	at_true(-1 == bw_and(24, -10))
	at_true(_0xA() == bw_and(_0xA(), _0xA()))
	at_true(_0xAA() == bw_and(_0xAA(), _0xAA()))
	at_true(_0xAAAA() == bw_and(_0xAAAA(), _0xAAAA()))
	at_true(_0xAAAAAAAA() == bw_and(_0xAAAAAAAA(), _0xAAAAAAAA()))
	
	at_true(_0xAAAAAAAA() == bw_and(_0xAAAAAAAAAA(), _0xAAAAAAAAAA()))
	
	at_true(0 == bw_and(_0xAAAAAAAA(), 0))
	at_true(0 == bw_and(0, _0xAAAAAAAA()))
	
	at_true(_0xAAA() == bw_and(_0xAAA(), _0xAAAAAAAAAA()))
	at_true(0 == bw_and(_0xAAAA(), _0x5555()))
	
	at_true(0 == bw_and(_0xA(), 1))
	at_true(2 == bw_and(_0xA(), 2))
}

function test_bw_or() {
	at_test_begin("bw_or()")

	at_true(-1 == bw_or(-5, 5))
	at_true(-1 == bw_or(5, -5))
	
	at_true(_0xAA() == bw_or(0, _0xAA()))
	at_true(_0xFFFFFF() == bw_or(_0x555555(), _0xAAAAAA()))
	at_true(1 == bw_or(0, 1))
	at_true(2 == bw_or(2, 0))
	
	at_true(_0xFFFFFFFF() == bw_or(_0x5555555555(), _0xAAAAAAAAAA()))
}

function test_bw_xor() {
	at_test_begin("bw_xor()")

	at_true(-1 == bw_xor(-5, 5))
	at_true(-1 == bw_xor(5, -5))

	at_true(0 == bw_xor(_0xAAA(), _0xAAA()))
	at_true(_0xFFFF() == bw_xor(_0x5555(), _0xAAAA()))
	at_true(_0xFFFF() == bw_xor(_0xAAAA(), _0x5555()))
	at_true(_0xAAAA() == bw_xor(_0xFFFF(), _0x5555()))
	at_true(_0x5555() == bw_xor(_0xFFFF(), _0xAAAA()))
	
	at_true(_0xFFFFFFFF() == bw_xor(_0x5555555555(), _0xAAAAAAAAAA()))
}

function test_bw_not() {
	at_test_begin("bw_not()")

	at_true(-1 == bw_not(-10))

	at_true(_BW_UVAL_MAX() == bw_not(0))
	at_true(0 == bw_not(_BW_UVAL_MAX()))
	
	at_true(0 == bw_not(_0xFFFFFFFF()))
	at_true(_0xFFFFFFFF() == bw_not(0))
	
	at_true(_0xFFFFFFFE() == bw_not(1))
	
	at_true(_0xAAAAAAAA() == bw_not(_0x55555555()))
	at_true(_0x55555555() == bw_not(_0xAAAAAAAA()))
	
	at_true(_0xAAAAAAAA() == bw_not(_0x5555555555()))
	at_true(_0x55555555() == bw_not(_0xAAAAAAAAAA()))
}

function test_bw_lshift() {
	at_test_begin("bw_lshift()")

	at_true(-1 == bw_lshift(-10, 5))
	at_true(-1 == bw_lshift(10, -5))
	at_true(-1 == bw_lshift(1, 32))
	
	at_true(1 == bw_lshift(1, 0))
	at_true(2 == bw_lshift(1, 1))
	at_true(4 == bw_lshift(1, 2))
	at_true(8 == bw_lshift(1, 3))
	at_true(16 == bw_lshift(1, 4))
	
	at_true(1024 == bw_lshift(1, 10))
	
	at_true(2^31 == bw_lshift(1, 31))
	
	at_true(1000 == bw_lshift(500, 1))
	at_true(2000 == bw_lshift(500, 2))
}

function test_bw_rshift() {
	at_test_begin("bw_rshift()")

	at_true(-1 == bw_rshift(-10, 5))
	at_true(-1 == bw_rshift(10, -5))
	at_true(-1 == bw_rshift(1, 32))
	
	at_true(1 == bw_rshift(2, 1))

	at_true(2^10 == bw_rshift(2^11, 1))
	at_true(2^9 == bw_rshift(2^11, 2))
	at_true(2^8 == bw_rshift(2^11, 3))
	
	at_true(_0x7FFFFFFF() == bw_rshift(_0xFFFFFFFF(), 1))
	at_true(_0x7FFFFFFF() == bw_rshift(_0xFFFFFFFFFF(), 1))
}

function test_bw_bin_str() {
	at_test_begin("bw_bin_str()")
	
	at_true(-1 == bw_bin_str(-5))
	
	at_true("00000000" == bw_bin_str(0, "", 1))
	
	at_true("0000 0000 0000 0000 1111 1111 1111 1111" == \
		bw_bin_str(_0xFFFF(), " "))
	
	at_true("1111-1111-1111-1111" == \
		bw_bin_str(_0xFFFF(), "-", 2))
	
	at_true("0000-0000-0000-0000-1010-1010-1010-1010" == \
		bw_bin_str(_0xAAAA(), "-"))
	
	at_true("1010-1010-1010-1010" == \
		bw_bin_str(_0xAAAA(), "-", 2))
	
	at_true("1010--1010" == \
		bw_bin_str(_0xFFAA(), "--", 1))
	
	at_true("10101010" == \
		bw_bin_str(_0xFFAA(), "", 1))
	
	at_true("1100 1100 1101 1101 1110 1110 1111 1111" == \
		bw_bin_str(_0xAABBCCDDEEFF(), " "))

	at_true("1010 1010 1011 1011 1100 1100 1101 1101 1110 1110 1111 1111" == \
		bw_bin_str(_0xAABBCCDDEEFF(), " ", 6))
}

function test_bw_hex_str() {
	at_test_begin("bw_hex_str()")

	at_true(-1 == bw_hex_str(-50))

	at_true("AA BB CC DD EE FF" == \
		bw_hex_str(_0xAABBCCDDEEFF(), " ", 6))

	at_true("CC DD EE FF" == \
		bw_hex_str(_0xAABBCCDDEEFF(), " "))

	at_true("CCDDEEFF" == \
		bw_hex_str(_0xAABBCCDDEEFF()))

	at_true("00--00--00" == bw_hex_str(0, "--", 3))
}

function main() {
	at_awklib_awktest_required()
	test_bw_and()
	test_bw_or()
	test_bw_xor()
	test_bw_not()
	test_bw_lshift()
	test_bw_rshift()
	test_bw_bin_str()
	test_bw_hex_str()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
