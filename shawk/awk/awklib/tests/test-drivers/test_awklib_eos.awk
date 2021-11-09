#!/usr/bin/awk -f

function make_arr(arr_out, csv_in) {return split(csv_in, arr_out, ",")}

function test_eos_init(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_init()")

	_eos_dest["foo"]
	at_true("foo" in _eos_dest)
	
	eos_init(_eos_dest)
	at_true(!("foo" in _eos_dest))
}

function test_eos_init_arr(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_init_arr()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)

	eos_init_arr(_eos_d, _arr, _len)
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	_str = "4,5,6,7,4,6,7"
	_len = make_arr(_arr, _str)
	
	eos_init_arr(_eos_d, _arr, _len)
	at_true("4 5 6 7" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_add(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_add()")

	eos_init(_eos_d)
	at_true(0 == eos_size(_eos_d))
	at_true(1 == eos_is_empty(_eos_d))
	
	eos_add(_eos_d, "foo")
	at_true(1 == eos_size(_eos_d))
	at_true(0 == eos_is_empty(_eos_d))
	at_true("foo" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_add(_eos_d, "bar")
	at_true(2 == eos_size(_eos_d))
	at_true(0 == eos_is_empty(_eos_d))
	at_true("foo bar" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_add(_eos_d, "foo")
	at_true(2 == eos_size(_eos_d))
	at_true(0 == eos_is_empty(_eos_d))
	at_true("foo bar" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_del(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_del()")

	eos_init(_eos_d)
	at_true(0 == eos_size(_eos_d))
	at_true(1 == eos_is_empty(_eos_d))
	
	eos_add(_eos_d, "foo")
	at_true(1 == eos_size(_eos_d))
	at_true(0 == eos_is_empty(_eos_d))
	at_true("foo" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_add(_eos_d, "bar")
	at_true(2 == eos_size(_eos_d))
	at_true(0 == eos_is_empty(_eos_d))
	at_true("foo bar" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_del(_eos_d, "bar")
	at_true(1 == eos_size(_eos_d))
	at_true("foo" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_del(_eos_d, "foo")
	at_true(0 == eos_size(_eos_d))
	at_true(1 == eos_is_empty(_eos_d))
	at_true("" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_has(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_has()")

	_str = "foo,bar,baz,foo"
	_len = make_arr(_arr, _str)

	eos_init_arr(_eos_d, _arr, _len)
	at_true("foo bar baz" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	at_true(0 == eos_has(_eos_d, "bonk"))
	at_true(1 == eos_has(_eos_d, "foo"))
	at_true(2 == eos_has(_eos_d, "bar"))
	at_true(3 == eos_has(_eos_d, "baz"))
}

function test_eos_size(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_size()")
		
	eos_init(_eos_d)
	at_true(0 == eos_size(_eos_d))
	
	eos_add(_eos_d, "foo")
	at_true(1 == eos_size(_eos_d))
	
	eos_add(_eos_d, "bar")
	at_true(2 == eos_size(_eos_d))
	
	eos_del(_eos_d, "bar")
	at_true(1 == eos_size(_eos_d))
	
	_str = "4,5,6,7,4,6,7"
	_len = make_arr(_arr, _str)
	
	eos_init_arr(_eos_d, _arr, _len)
	at_true(4 == eos_size(_eos_d))
}

function test_eos_is_empty(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_is_empty()")

	eos_init(_eos_d)
	at_true(1 == eos_is_empty(_eos_d))
	
	eos_add(_eos_d, "foo")
	at_true(0 == eos_is_empty(_eos_d))
	
	eos_add(_eos_d, "bar")
	at_true(0 == eos_is_empty(_eos_d))
	
	eos_del(_eos_d, "bar")
	at_true(0 == eos_is_empty(_eos_d))
	
	eos_del(_eos_d, "foo")
	at_true(1 == eos_is_empty(_eos_d))
}

function test_eos_union(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_union()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_a, _arr, _len)
	
	eos_init(_eos_d)
	eos_add(_eos_d, "foo")
	
	eos_union(_eos_d, _eos_a, _eos_a)
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_union(_eos_d, _eos_b, _eos_b)
	at_true(eos_is_empty(_eos_d))
	
	eos_union(_eos_d, _eos_a, _eos_b)
	at_true(5 == eos_size(_eos_d))
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_init(_eos_b)
	eos_union(_eos_d, _eos_b, _eos_a)
	at_true(5 == eos_size(_eos_d))
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_union(_eos_d, _eos_a, _eos_a)
	at_true(5 == eos_size(_eos_d))
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	_str = "6,7,8,9,2"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)

	eos_union(_eos_d, _eos_a, _eos_b)
	at_true(8 == eos_size(_eos_d))
	at_true("2 3 4 5 6 7 8 9" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_init(_eos_d)
	at_true(1 == eos_is_empty(_eos_d))
	
	eos_union(_eos_d, _eos_b, _eos_a)
	at_true(8 == eos_size(_eos_d))
	at_true("6 7 8 9 2 3 4 5" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_intersect(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_intersect()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_a, _arr, _len)
	
	eos_init(_eos_d)
	eos_add(_eos_d, "foo")
	
	eos_intersect(_eos_d, _eos_a, _eos_a)
	at_true(arr_is_eq(_eos_d, eos_size(_eos_d),
		_eos_a, eos_size(_eos_a)))
	at_true(!eos_is_empty(_eos_d))
	
	eos_intersect(_eos_d, _eos_b, _eos_b)
	at_true(arr_is_eq(_eos_d, eos_size(_eos_d),
		_eos_b, eos_size(_eos_b)))
	at_true(eos_is_empty(_eos_d))
	
	eos_init(_eos_b)
	eos_intersect(_eos_d, _eos_a, _eos_b)
	at_true(0 == eos_size(_eos_d))
	at_true("" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_init(_eos_b)
	eos_intersect(_eos_d, _eos_b, _eos_a)
	at_true(0 == eos_size(_eos_d))
	at_true("" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_intersect(_eos_d, _eos_a, _eos_a)
	at_true(5 == eos_size(_eos_d))
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	_str = "6,7,8,9,2"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)

	eos_intersect(_eos_d, _eos_a, _eos_b)
	at_true(2 == eos_size(_eos_d))
	at_true("2 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_init(_eos_d)
	at_true(1 == eos_is_empty(_eos_d))
	
	eos_intersect(_eos_d, _eos_b, _eos_a)
	at_true(2 == eos_size(_eos_d))
	at_true("6 2" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_subtract(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_subtract()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_a, _arr, _len)
	
	eos_init(_eos_d)
	eos_add(_eos_d, "foo")
	
	eos_subtract(_eos_d, _eos_a, _eos_a)
	at_true(eos_is_empty(_eos_d))
	
	eos_subtract(_eos_d, _eos_b, _eos_b)
	at_true(eos_is_empty(_eos_d))
	
	eos_init(_eos_b)
	eos_subtract(_eos_d, _eos_a, _eos_b)
	at_true(5 == eos_size(_eos_d))
	at_true("2 3 4 5 6" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	eos_init(_eos_b)
	eos_subtract(_eos_d, _eos_b, _eos_a)
	at_true(0 == eos_size(_eos_d))
	at_true("" == arr_to_str(_eos_d, eos_size(_eos_d)))
	
	_str = "5,6,7,8"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)

	eos_subtract(_eos_d, _eos_a, _eos_b)
	
	at_true(3 == eos_size(_eos_d))
	at_true("2 3 4" == arr_to_str(_eos_d, eos_size(_eos_d)))

	eos_subtract(_eos_d, _eos_b, _eos_a)
	at_true(2 == eos_size(_eos_d))
	at_true("7 8" == arr_to_str(_eos_d, eos_size(_eos_d)))
}

function test_eos_are_disjoint(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_are_disjoint()")
	
	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_a, _arr, _len)
	
	eos_init(_eos_d)
	eos_add(_eos_d, "foo")
	
	eos_init(_eos_b)
	at_true(!eos_are_disjoint(_eos_a, _eos_a))
	at_true(eos_are_disjoint(_eos_a, _eos_b))
	at_true(eos_are_disjoint(_eos_b, _eos_a))
	at_true(eos_are_disjoint(_eos_b, _eos_b))
	
	_str = "6,7,8,9,2"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)
	at_true(!eos_are_disjoint(_eos_a, _eos_b))
	at_true(!eos_are_disjoint(_eos_b, _eos_a))
	
	_str = "7,8,9"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)
	at_true(eos_are_disjoint(_eos_a, _eos_b))
	at_true(eos_are_disjoint(_eos_b, _eos_a))
}

function test_eos_is_subset(    _eos_d, _eos_a, _eos_b, _arr, _str, _len) {
	at_test_begin("eos_is_subset()")
	
	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_a, _arr, _len)
	
	eos_init(_eos_b)
	at_true(eos_is_subset(_eos_a, _eos_a))
	at_true(eos_is_subset(_eos_b, _eos_b))
	at_true(eos_is_subset(_eos_b, _eos_a))
	at_true(!eos_is_subset(_eos_a, _eos_b))
	
	_str = "3,4,6"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)
	at_true(!eos_is_subset(_eos_a, _eos_b))
	at_true(eos_is_subset(_eos_b, _eos_a))
	
	_str = "7,8,9"
	_len = make_arr(_arr, _str)
	eos_init_arr(_eos_b, _arr, _len)
	at_true(!eos_is_subset(_eos_a, _eos_b))
	at_true(!eos_is_subset(_eos_b, _eos_a))
}

function main() {
	at_awklib_awktest_required()
	test_eos_init()
	test_eos_init_arr()
	test_eos_add()
	test_eos_del()
	test_eos_has()
	test_eos_size()
	test_eos_is_empty()
	test_eos_union()
	test_eos_intersect()
	test_eos_subtract()
	test_eos_are_disjoint()
	test_eos_is_subset()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
