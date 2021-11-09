#!/usr/bin/awk -f

function test_psplit(    _arr, _str, _pat, _len) {
	at_test_begin("psplit()")

	_str="this 'is' a 'string' with 'single quoted' sub-strings ''"	
	_arr[1] = "foo"
	_len = psplit(_arr, _str, "'[^']*'")
	
	at_true(4 == _len)
	at_true("'is'" == _arr[1])
	at_true("'string'" == _arr[2])
	at_true("'single quoted'" == _arr[3])
	at_true("''" == _arr[4])
	
	_str="this 'is' a 'string' with 'single quoted' sub-strings '' foo"
	_arr[1] = "foo"
	_len = psplit(_arr, _str, "'[^']*'")
	
	at_true(4 == _len)
	at_true("'is'" == _arr[1])
	at_true("'string'" == _arr[2])
	at_true("'single quoted'" == _arr[3])
	at_true("''" == _arr[4])
	
	
	_str="'is' a 'string' with 'single quoted' sub-strings '' foo"
	_arr[1] = "foo"
	_len = psplit(_arr, _str, "'[^']*'")
	
	at_true(4 == _len)
	at_true("'is'" == _arr[1])
	at_true("'string'" == _arr[2])
	at_true("'single quoted'" == _arr[3])
	at_true("''" == _arr[4])
	
	
	_str="'is' a 'string' with 'single quoted' sub-strings ''"
	_arr[1] = "foo"
	_len = psplit(_arr, _str, "'[^']*'")
	
	at_true(4 == _len)
	at_true("'is'" == _arr[1])
	at_true("'string'" == _arr[2])
	at_true("'single quoted'" == _arr[3])
	at_true("''" == _arr[4])
}

function main() {
	at_awklib_awktest_required()
	test_psplit()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
