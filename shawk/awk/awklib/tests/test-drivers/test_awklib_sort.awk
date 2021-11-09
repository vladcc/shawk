#!/usr/bin/awk -f

function make_sorted(arr_out, len,    _i) {

	delete arr_out
	for (_i = 1; _i <= len; ++_i)
		arr_out[_i] = _i
	return len
}

function make_reverse(arr_out, len,    _i) {

	delete arr_out
	for (_i = 1; _i <= len; ++_i)
		arr_out[_i] = len - _i
	return len
}

function make_random(arr_out, len,    _i) {

	delete arr_out
	
	do {
		srand()
		for (_i = 1; _i <= len; ++_i)
			arr_out[_i] = rand()
	} while (len > 1 && is_sorted(arr_out, len))
	return len
}

function test_pretest(    _arr, _len) {
	at_test_begin("pretest()")
	
	_arr[1] = "foo"
	at_true(5 == make_sorted(_arr, 5))
	at_true(1 == _arr[1])
	at_true(2 == _arr[2])
	at_true(3 == _arr[3])
	at_true(4 == _arr[4])
	at_true(5 == _arr[5])
	
	at_true(5 == make_reverse(_arr, 5))
	at_true(4 == _arr[1])
	at_true(3 == _arr[2])
	at_true(2 == _arr[3])
	at_true(1 == _arr[4])
	at_true(0 == _arr[5])
	
	make_random(_arr, 10)
	at_true(!is_sorted(_arr, 10))
}

function test_is_sorted(    _arr, _len) {
	at_test_begin("is_sorted()")

	at_true(is_sorted(_arr, 0))

	_arr[1] = 1
	at_true(is_sorted(_arr, 1))
	
	_arr[2] = 2
	at_true(is_sorted(_arr, 2))

	_arr[2] = 0
	at_true(!is_sorted(_arr, 2))

	make_sorted(_arr, 10)
	at_true(is_sorted(_arr, 10))

	make_reverse(_arr, 10)
	at_true(!is_sorted(_arr, 10))

	_arr[1] = 1
	_arr[2] = 1
	_arr[3] = 3
	_arr[4] = 2
	_arr[5] = 1
	at_true(!is_sorted(_arr, 5))
}

function test_qsort(    _arr, _len, _i) {
	at_test_begin("qsort()")
	
	for (_i = 1; _i <= lens_get_num(); ++_i) {
		
		_len = lens_get(_i)
		
		make_sorted(_arr, _len)
		qsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_reverse(_arr, _len)
		qsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_random(_arr, _len)
		qsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
	}
	at_true(_i != 1)
}


function test_msort(    _arr, _len,  _i) {
	at_test_begin("msort()")
	
	for (_i = 1; _i <= lens_get_num(); ++_i) {
		
		_len = lens_get(_i)
		
		make_sorted(_arr, _len)
		msort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_reverse(_arr, _len)
		msort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_random(_arr, _len)
		msort(_arr, _len)
		at_true(is_sorted(_arr, _len))
	}
	at_true(_i != 1)
}

function test__snsort(    _arr, _len, _i) {
	at_test_begin("_snsort()")
	
	for (_i = 1; _i <= lens_get_num(); ++_i) {
		
		_len = lens_get(_i)
		
		make_sorted(_arr, _len)
		_snsort(_arr, 1, _len)
		at_true(is_sorted(_arr, _len))
		make_reverse(_arr, _len)
		_snsort(_arr, 1, _len)
		at_true(is_sorted(_arr, 1, _len))
		make_random(_arr, _len)
		_snsort(_arr, 1, _len)
		at_true(is_sorted(_arr, _len))
	}
	at_true(_i != 1)
}

function test_nsort(    _arr, _len, _i) {
	at_test_begin("nsort()")
	
	for (_i = 1; _i <= lens_get_num(); ++_i) {
		
		_len = lens_get(_i)
		
		make_sorted(_arr, _len)
		nsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_reverse(_arr, _len)
		nsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
		make_random(_arr, _len)
		nsort(_arr, _len)
		at_true(is_sorted(_arr, _len))
	}
	at_true(_i != 1)
	
}

function lens_init() {
	
	B_lens[++B_lens_len] = 0
	B_lens[++B_lens_len] = 1
	B_lens[++B_lens_len] = 2
	B_lens[++B_lens_len] = 3
	B_lens[++B_lens_len] = 4
	B_lens[++B_lens_len] = 5
	B_lens[++B_lens_len] = 6
	B_lens[++B_lens_len] = 7
	B_lens[++B_lens_len] = 8
	B_lens[++B_lens_len] = 9
	B_lens[++B_lens_len] = 10
	B_lens[++B_lens_len] = 11
	B_lens[++B_lens_len] = 12
	B_lens[++B_lens_len] = 13
	B_lens[++B_lens_len] = 15
	B_lens[++B_lens_len] = 31
	B_lens[++B_lens_len] = 100
	B_lens[++B_lens_len] = 113
	B_lens[++B_lens_len] = 131
}
function lens_get_num() {return B_lens_len}
function lens_get(n) {return B_lens[B_lens_len]}

function main() {
	at_awklib_awktest_required()
	
	lens_init()
	
	test_pretest()
	test_is_sorted()
	test_qsort()
	test_msort()
	test__snsort()
	test_nsort()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
