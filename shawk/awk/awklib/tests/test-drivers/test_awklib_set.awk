#!/usr/bin/awk -f

function make_arr(arr_out, csv_in) {return split(csv_in, arr_out, ",")}

function test_set_init(    _set_d, _set_a, _set_b) {
	at_test_begin("set_init()")

	_set_d["foo"]
	at_true("foo" in _set_d)
	
	set_init(_set_d)
	at_true(!("foo" in _set_d))
}

function test_set_init_arr(    _set_d, _set_a, _set_b, _arr, _len) {
	at_test_begin("set_init_arr()")

	_set_d["foo"]
	at_true("foo" in _set_d)
	
	_len = make_arr(_arr, "bar,baz,zig,bar,baz")
	
	set_init_arr(_set_d, _arr, _len)
	at_true(3 == set_size(_set_d))
	at_true(set_has(_set_d, "bar"))
	at_true(set_has(_set_d, "baz"))
	at_true(set_has(_set_d, "zig"))
}

function test_set_copy(    _set_d, _set_a, _set_b) {
	at_test_begin("set_copy()")

	set_init(_set_a)
	set_place(_set_a, "foo")
	set_place(_set_a, "bar")
	set_place(_set_a, "foo")
	
	set_init(_set_b)
	set_place(_set_b, "should be gone")
	
	at_true(2 == set_copy(_set_b, _set_a))
	at_true(set_has(_set_b, "foo"))
	at_true(set_has(_set_b, "bar"))
}

function test_set_place(    _set_d, _set_a, _set_b) {
	at_test_begin("set_place()")

	set_init(_set_d)
	
	at_true(!("foo" in _set_d))
	
	set_place(_set_d, "foo")
	at_true("foo" in _set_d)
}

function test_set_del(    _set_d, _set_a, _set_b) {
	at_test_begin("set_del()")

	set_init(_set_d)
	
	at_true(!("foo" in _set_d))
	
	set_place(_set_d, "foo")
	at_true("foo" in _set_d)
	
	set_del(_set_d, "foo")
	at_true(!("foo" in _set_d))
}

function test_set_has(    _set_d, _set_a, _set_b) {
	at_test_begin("set_has()")

	set_init(_set_d)
	
	at_true(!("foo" in _set_d))
	at_true(!set_has(_set_d, "foo"))
	
	set_place(_set_d, "foo")
	at_true("foo" in _set_d)
	at_true(set_has(_set_d, "foo"))
}

function test_set_is_empty(    _set_d, _set_a, _set_b) {
	at_test_begin("set_is_empty()")

	set_init(_set_d)
	at_true(set_is_empty(_set_d))

	set_place(_set_d, "foo")
	at_true(!set_is_empty(_set_d))
	
	set_del(_set_d, "foo")
	at_true(set_is_empty(_set_d))
}

function test_set_union(    _set_d, _set_a, _set_b) {
	at_test_begin("set_union()")

	set_init(_set_a)
	set_init(_set_b)
	
	set_place(_set_a, "foo")
	
	set_init(_set_d)
	set_place(_set_d, "should disappear")
	
	set_union(_set_d, _set_a, _set_b)
	
	at_true(set_has(_set_d, "foo"))
	at_true(1 == set_size(_set_d))
	
	set_union(_set_d, _set_a, _set_a)
	at_true(!set_is_empty(_set_d))
	at_true(set_is_eq(_set_d, _set_a))
	
	set_union(_set_d, _set_b, _set_b)
	at_true(set_is_empty(_set_d))
	at_true(set_is_eq(_set_d, _set_b))
	
	set_union(_set_d, _set_b, _set_a)
	
	at_true(set_has(_set_d, "foo"))
	at_true(1 == set_size(_set_d))
	
	set_place(_set_b, "foo")
	set_place(_set_b, "bar")
	
	set_union(_set_d, _set_a, _set_b)
	
	at_true(set_has(_set_d, "foo"))
	at_true(set_has(_set_d, "bar"))
	at_true(2 == set_size(_set_d))
	
	set_place(_set_b, "foo")
	set_place(_set_b, "bar")
	
	set_union(_set_d, _set_b, _set_a)
	
	at_true(set_has(_set_d, "foo"))
	at_true(set_has(_set_d, "bar"))
	at_true(2 == set_size(_set_d))
	
}

function test_set_intersect(    _set_d, _set_a, _set_b, _arr, _len) {
	at_test_begin("set_intersect()")

	set_init(_set_a)
	set_init(_set_b)
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_a, _arr, _len)
	
	set_init(_set_d)
	set_place(_set_d, "should disappear")
	
	set_intersect(_set_d, _set_a, _set_b)
	at_true(set_is_empty(_set_d))
	
	set_intersect(_set_d, _set_a, _set_a)
	at_true(!set_is_empty(_set_d))
	at_true(set_is_eq(_set_d, _set_a))
	
	set_intersect(_set_d, _set_b, _set_b)
	at_true(set_is_empty(_set_d))
	at_true(set_is_eq(_set_d, _set_b))
	
	set_intersect(_set_d, _set_b, _set_a)
	at_true(set_is_empty(_set_d))

	_len = make_arr(_arr, "bar,baz,zig")
	set_init_arr(_set_b, _arr, _len)
	
	set_intersect(_set_d, _set_a, _set_b)
	at_true(2 == set_size(_set_d))

	at_true(set_has(_set_d, "bar"))
	at_true(set_has(_set_d, "baz"))
	
	set_init(_set_d)
	at_true(set_is_empty(_set_d))
	
	set_intersect(_set_d, _set_b, _set_a)
	at_true(2 == set_size(_set_d))

	at_true(set_has(_set_d, "bar"))
	at_true(set_has(_set_d, "baz"))
}

function test_set_subtract(    _set_d, _set_a, _set_b, _arr, _len) {
	at_test_begin("set_subtract()")

	set_init(_set_a)
	set_init(_set_b)
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_a, _arr, _len)
	
	set_init(_set_d)
	set_place(_set_d, "should disappear")
	
	set_subtract(_set_d, _set_a, _set_b)
	at_true(set_is_eq(_set_d, _set_a))
	at_true(!set_is_empty(_set_d))

	set_subtract(_set_d, _set_b, _set_a)
	at_true(set_is_eq(_set_d, _set_b))
	at_true(set_is_empty(_set_d))

	set_subtract(_set_d, _set_a, _set_a)
	at_true(set_is_empty(_set_d))

	set_subtract(_set_d, _set_b, _set_b)
	at_true(set_is_empty(_set_d))
	
	_len = make_arr(_arr, "baz,zig,zag")
	set_init_arr(_set_b, _arr, _len)
	
	set_subtract(_set_d, _set_a, _set_b)
	at_true(set_has(_set_d, "foo"))
	at_true(set_has(_set_d, "bar"))

	set_subtract(_set_d, _set_b, _set_a)
	at_true(set_has(_set_d, "zig"))
	at_true(set_has(_set_d, "zag"))
}

function test_set_are_disjoint(    _set_d, _set_a, _set_b) {
	at_test_begin("set_are_disjoint()")

	set_init(_set_a)
	set_init(_set_b)
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_a, _arr, _len)
	
	at_true(!set_are_disjoint(_set_a, _set_a))
	at_true(set_are_disjoint(_set_b, _set_b))
	at_true(set_are_disjoint(_set_a, _set_b))
	at_true(set_are_disjoint(_set_b, _set_a))
	
	_len = make_arr(_arr, "foo,bar")
	set_init_arr(_set_b, _arr, _len)
	at_true(!set_are_disjoint(_set_a, _set_b))
	at_true(!set_are_disjoint(_set_b, _set_a))
	
	_len = make_arr(_arr, "zig,zag,zog")
	set_init_arr(_set_b, _arr, _len)
	at_true(set_are_disjoint(_set_a, _set_b))
	at_true(set_are_disjoint(_set_b, _set_a))
}

function test_set_is_eq(    _set_d, _set_a, _set_b, _arr, _len) {
	at_test_begin("set_is_eq()")

	set_init(_set_a)
	set_init(_set_b)
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_a, _arr, _len)
	
	at_true(!set_is_eq(_set_a, _set_b))
	at_true(!set_is_eq(_set_b, _set_a))
	at_true(set_is_eq(_set_a, _set_a))
	at_true(set_is_eq(_set_b, _set_b))
	
	len = make_arr(_arr, "foo,bar")
	set_init_arr(_set_b, _arr, _len)

	at_true(!set_is_eq(_set_a, _set_b))
	at_true(!set_is_eq(_set_b, _set_a))
	at_true(set_is_eq(_set_a, _set_a))
	at_true(set_is_eq(_set_b, _set_b))
	
	len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_b, _arr, _len)
	
	at_true(set_is_eq(_set_a, _set_b))
	at_true(set_is_eq(_set_b, _set_a))
	at_true(set_is_eq(_set_a, _set_a))
	at_true(set_is_eq(_set_b, _set_b))
}

function test_set_is_subset(    _set_d, _set_a, _set_b, _arr, _len) {
	at_test_begin("set_is_subset()")

	set_init(_set_a)
	set_init(_set_b)
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_a, _arr, _len)
	
	at_true(set_is_subset(_set_a, _set_a))
	at_true(set_is_subset(_set_b, _set_b))
	at_true(!set_is_subset(_set_a, _set_b))
	at_true(set_is_subset(_set_b, _set_a))
	
	_len = make_arr(_arr, "foo,bar")
	set_init_arr(_set_b, _arr, _len)
	at_true(!set_is_subset(_set_a, _set_b))
	at_true(set_is_subset(_set_b, _set_a))
	
	_len = make_arr(_arr, "zig,zag")
	set_init_arr(_set_b, _arr, _len)
	at_true(!set_is_subset(_set_a, _set_b))
	at_true(!set_is_subset(_set_b, _set_a))
}

function test_set_size(    _set_d, _set_a, _set_b) {
	at_test_begin("set_size()")

	set_init(_set_d)
	at_true(0 == set_size(_set_d))
	
	set_place(_set_d, "foo")
	at_true(1 == set_size(_set_d))
	
	set_del(_set_d, "foo")
	at_true(0 == set_size(_set_d))
	
	_len = make_arr(_arr, "foo,bar,baz")
	set_init_arr(_set_d, _arr, _len)

	at_true(3 == set_size(_set_d))
	set_del(_set_d, "foo")
	at_true(2 == set_size(_set_d))
	set_del(_set_d, "bar")
	at_true(1 == set_size(_set_d))
	set_del(_set_d, "baz")
	at_true(0 == set_size(_set_d))
}

function test_set_to_str(    _set_d, _set_a, _set_b, _str) {
	at_test_begin("set_to_str()")

	set_init(_set_d)
	_len = make_arr(_arr, "foo,bar")
	set_init_arr(_set_d, _arr, _len)

	# no guarantee about order
	_str = set_to_str(_set_d)
	at_true(("foo bar" == _str) || ("bar foo" == _str))
	_str = set_to_str(_set_d, "-")
	at_true(("foo-bar" == _str) || ("bar-foo" == _str))
}

function main() {
	at_awklib_awktest_required()
	test_set_init()
	test_set_init_arr()
	test_set_copy()
	test_set_place()
	test_set_del()
	test_set_has()
	test_set_is_empty()
	test_set_union()
	test_set_intersect()
	test_set_subtract()
	test_set_are_disjoint()
	test_set_is_eq()
	test_set_is_subset()
	test_set_size()
	test_set_to_str()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
