#!/usr/bin/awk -f

function make_arr(arr_out, csv_in) {return split(csv_in, arr_out, ",")}

function test_arr_init(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_init()")

	_arr_a[1] = "will be deleted"
	at_true(1 in _arr_a)
	
	arr_init(_arr_a)
	at_true(!(1 in _arr_a))
}

function test_arr_from_map_keys(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_from_map_keys()")
	
	_arr_b["foo"] = "bar"
	_arr_b["zig"] = "zag"
	
	_arr_a[1] = "should be gone"
	_len_a = arr_from_map_keys(_arr_a, _arr_b)
	at_true(2 == _len_a)
	
	at_true(arr_find(_arr_a, _len_a, "foo"))
	at_true(arr_find(_arr_a, _len_a, "zig"))
}

function test_arr_from_map_vals(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_from_map_vals()")
	
	_arr_b["foo"] = "bar"
	_arr_b["zig"] = "zag"
	
	_arr_a[1] = "should be gone"
	_len_a = arr_from_map_vals(_arr_a, _arr_b)
	at_true(2 == _len_a)
	
	at_true(arr_find(_arr_a, _len_a, "bar"))
	at_true(arr_find(_arr_a, _len_a, "zag"))
}

function test_arr_range(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_range()")

	_str = "1,2,3,4,5,6,7,8,9"
	_len_a = make_arr(_arr_a, _str)
	at_true(9 == _len_a)
	
	_arr_b[1] = "shall be cleared"
	at_true(1 in _arr_b)
	
	at_true(0 == arr_range(_arr_b, _arr_a, 1000, _len_a))
	at_true(!(1 in _arr_b))
	
	_len_b = arr_range(_arr_b, _arr_a, 1, 9)
	at_true(9 == _len_b)
	at_true(_len_a == _len_b)
	at_true(_str == arr_to_str(_arr_b, _len_b, ","))
	at_true(arr_to_str(_arr_a, _len_a) == arr_to_str(_arr_b, _len_b))
	
	_len_b = arr_range(_arr_b, _arr_a, 1, 5)
	at_true(5 == _len_b)
	at_true("1 2 3 4 5" == arr_to_str(_arr_b, _len_b))
	
	_len_b = arr_range(_arr_b, _arr_a, 5, 9)
	at_true(5 == _len_b)
	at_true("5 6 7 8 9" == arr_to_str(_arr_b, _len_b))
	
	_len_b = arr_range(_arr_b, _arr_a, 3, 8)
	at_true(6 == _len_b)
	at_true("3 4 5 6 7 8" == arr_to_str(_arr_b, _len_b))
}

function test_arr_copy(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_copy()")

	_len_a = make_arr(_arr_a, "1,2,3,4,5")
	_arr_b[1] = "shall be cleared"
	at_true(1 in _arr_b)
	
	_len_b = arr_copy(_arr_b, _arr_a, 0)
	at_true(0 == _len_b)
	at_true(!(1 in _arr_b))
	
	_len_b = arr_copy(_arr_b, _arr_a, 3)
	at_true(3 == _len_b)
	at_true("1 2 3" == arr_to_str(_arr_b, _len_b))

	_len_b = arr_copy(_arr_b, _arr_a, _len_a)
	at_true(5 == _len_b)
	at_true(_len_a == _len_b)
	at_true("1 2 3 4 5" == arr_to_str(_arr_b, _len_b))
	at_true(arr_to_str(_arr_a, _len_a) == arr_to_str(_arr_b, _len_b))
}

function test_arr_append(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_append()")

	_len_a = make_arr(_arr_a, "1,2,3,4")
	_len_b = make_arr(_arr_b, "")
	
	at_true(_len_a == arr_append(_arr_a, _len_a, _arr_b, _len_b))
	at_true("1 2 3 4" == arr_to_str(_arr_a, _len_a))
	
	_len_b = make_arr(_arr_b, "5,6,7")
	_len_a = arr_append(_arr_a, _len_a, _arr_b, _len_b)
	at_true(7 == _len_a)
	at_true("1 2 3 4 5 6 7" == arr_to_str(_arr_a, _len_a))
	at_true(3 == _len_b)
	at_true("5 6 7" == arr_to_str(_arr_b, _len_b))
	
	_len_a = arr_append(_arr_a, _len_a-1, _arr_b, 1)
	at_true(7 == _len_a)
	at_true("1 2 3 4 5 6 5" == arr_to_str(_arr_a, _len_a))
	at_true(3 == _len_b)
	at_true("5 6 7" == arr_to_str(_arr_b, _len_b))
}

function test_arr_gather(    _arr_a, _len_a, _arr_b, _len_b, _str,
 _arr_c, _len_c) {
	at_test_begin("arr_gather()")

	_len_a = make_arr(_arr_a, "1,2,3,4,5,6")
	
	_len_b = 0
	_arr_b[++_len_b] = 1;
	_arr_b[++_len_b] = 3;
	_arr_b[++_len_b] = 5;
	
	_arr_c[1] = "shall be deleted"
	_len_c = arr_gather(_arr_c, _arr_a, _arr_b, _len_b)
	at_true(3 == _len_c)
	at_true("1 3 5" == arr_to_str(_arr_c, _len_c))
}

function test_arr_match_ind_first(    _arr_a, _len_a, _arr_b, _len_b,
_str) {
	at_test_begin("arr_match_ind_first()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	at_true(0 == arr_match_ind_first(_arr_a, _len_a, "zzz"))
	at_true(3 == arr_match_ind_first(_arr_a, _len_a, "bar"))
	at_true(2 == arr_match_ind_first(_arr_a, _len_a, "xxx"))
}

function test_arr_match_ind_all(    _arr_a, _len_a, _arr_b, _len_b,
_str) {
	at_test_begin("arr_match_ind_all()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	
	_arr_b[1] = "shall be removed"
	at_true(0 == arr_match_ind_all(_arr_b, _arr_a, _len_a, "zzz"))
	at_true(2 == arr_match_ind_all(_arr_b, _arr_a, _len_a, "ba"))
	at_true("3 5" == arr_to_str(_arr_b, 2))
}

function test_arr_dont_match_ind_first(    _arr_a, _len_a, _arr_b,
_len_b, _str) {
	at_test_begin("arr_dont_match_ind_first()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	at_true(2 == arr_dont_match_ind_first(_arr_a, _len_a, "foo"))
	at_true(1 == arr_dont_match_ind_first(_arr_a, _len_a, "xxx"))
}

function test_arr_dont_match_ind_all(    _arr_a, _len_a, _arr_b, _len_b,
_str) {
	at_test_begin("arr_dont_match_ind_all()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	
	_arr_b[1] = "shall be removed"
	at_true(0 == arr_dont_match_ind_all(_arr_b, _arr_a, _len_a, "."))
	at_true(5 == arr_dont_match_ind_all(_arr_b, _arr_a, _len_a, "zzz"))
	at_true("1 2 3 4 5" == arr_to_str(_arr_b, 5))
	at_true(3 == arr_dont_match_ind_all(_arr_b, _arr_a, _len_a, "xxx"))
	at_true("1 3 5" == arr_to_str(_arr_b, 3))
}

function test_arr_match(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_match()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	_arr_b[1] = "shall be cleared"
	at_true(1 in _arr_b)
	
	at_true(0 == arr_match(_arr_b, _arr_a, _len_a, "zig"))
	at_true(!(1 in _arr_b))
	
	_len_b = arr_match(_arr_b, _arr_a, _len_a, "foo|bar|baz")
	at_true(3 == _len_b)
	at_true("foo bar baz" == arr_to_str(_arr_b, _len_b))
	
	_len_b = arr_match(_arr_b, _arr_a, _len_a-1, "foo|bar|baz")
	at_true(2 == _len_b)
	at_true("foo bar" == arr_to_str(_arr_b, _len_b))
}

function test_arr_dont_match(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_dont_match()")

	_len_a = make_arr(_arr_a, "foo,xxx,bar,xxx,baz")
	_arr_b[1] = "shall be cleared"
	at_true(1 in _arr_b)
	
	at_true(0 == arr_dont_match(_arr_b, _arr_a, _len_a, "."))
	at_true(!(1 in _arr_b))
	
	_len_b = arr_dont_match(_arr_b, _arr_a, _len_a, "xxx")
	at_true(3 == _len_b)
	at_true("foo bar baz" == arr_to_str(_arr_b, _len_b))
	
	_len_b = arr_dont_match(_arr_b, _arr_a, _len_a-1, "xxx")
	at_true(2 == _len_b)
	at_true("foo bar" == arr_to_str(_arr_b, _len_b))
}

function test_arr_sub(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_sub()")

	_len_a = make_arr(_arr_a, "11,22,33,44")

	at_true(0 == arr_sub(_arr_a, _len_a, "foo", "a"))
	
	_len_b = arr_sub(_arr_a, _len_a, "[[:digit:]]", "a")
	at_true(4 == _len_b)
	at_true("a1 a2 a3 a4" == arr_to_str(_arr_a, _len_a))
}

function test_arr_gsub(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_gsub()")

	_len_a = make_arr(_arr_a, "11,22,33,44")

	at_true(0 == arr_sub(_arr_a, _len_a, "foo", "a"))
	
	_len_b = arr_gsub(_arr_a, _len_a, "[[:digit:]]", "a")
	at_true(8 == _len_b)
	at_true("aa aa aa aa" == arr_to_str(_arr_a, _len_a))
}

function test_arr_is_eq(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_is_eq()")

	_len_a = make_arr(_arr_a, "1,2,3,4")
	_len_b = make_arr(_arr_b, "1,2,3,4,5")
	at_true(0 == arr_is_eq(_arr_a, _len_a, _arr_b, _len_b))
	at_true(0 == arr_is_eq(_arr_b, _len_b, _arr_a, _len_a))
	
	_len_b = make_arr(_arr_b, "1,2,3,5")
	at_true(0 == arr_is_eq(_arr_a, _len_a, _arr_b, _len_b))
	at_true(0 == arr_is_eq(_arr_b, _len_b, _arr_a, _len_a))
	
	_len_b = make_arr(_arr_b, "1,2,3,4")
	at_true(1 == arr_is_eq(_arr_a, _len_a, _arr_b, _len_b))
	at_true(1 == arr_is_eq(_arr_a, _len_b, _arr_a, _len_a))
}

function test_arr_find(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_find()")

	_len_a = make_arr(_arr_a, "1,2,4,8,16")
	at_true(0 == arr_find(_arr_a, _len_a, 0))
	at_true(1 == arr_find(_arr_a, _len_a, 1))
	at_true(3 == arr_find(_arr_a, _len_a, 4))
	at_true(5 == arr_find(_arr_a, _len_a, 16))
	at_true(0 == arr_find(_arr_a, _len_a, 32))
}

function test_arr_to_str(    _arr_a, _len_a, _arr_b, _len_b, _str) {
	at_test_begin("arr_to_str()")

	_str = "1,2,3,4,5"
	_len_a = make_arr(_arr_a, _str)
	
	at_true("1 2 3 4 5" == arr_to_str(_arr_a, _len_a))
	at_true(_str == arr_to_str(_arr_a, _len_a, ","))
	at_true("1 2 3 4" == arr_to_str(_arr_a, _len_a-1))
}

function main() {
	at_awklib_awktest_required()
	test_arr_init()
	test_arr_from_map_keys()
	test_arr_from_map_vals()
	test_arr_range()
	test_arr_copy()
	test_arr_append()
	test_arr_gather()
	test_arr_match_ind_first()
	test_arr_match_ind_all()
	test_arr_match()
	test_arr_dont_match_ind_first()
	test_arr_dont_match_ind_all()
	test_arr_dont_match()
	test_arr_sub()
	test_arr_gsub()
	test_arr_is_eq()
	test_arr_find()
	test_arr_to_str()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
