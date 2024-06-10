#!/usr/bin/awk -f

function test_str_set_init(    _sset) {
	at_test_begin("test_str_set_init")

	at_true(STR_SET_SEP() != _sset)

	_sset = str_set_init()
	at_true(STR_SET_SEP() == _sset)
}

function test_str_set_add_find_del_count_empty(    _sset) {
	at_test_begin("test_str_set_find")

	_sset = str_set_init()
	at_true(0 == str_set_count(_sset))
	at_true(str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(!str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "foo")
	at_true(1 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(!str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "foo")
	at_true(1 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(!str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "bar")
	at_true(2 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "bar")
	at_true(2 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "baz")
	at_true(3 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "baz")
	at_true(3 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "bar")
	_sset = str_set_add(_sset, "baz")
	_sset = str_set_add(_sset, "foo")
	at_true(3 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

	_sset = str_set_del(_sset, "")
	at_true(3 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

	_sset = str_set_del(_sset, "baz")
	at_true(2 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_del(_sset, "foo")
	at_true(1 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_del(_sset, "bar")
	at_true(0 == str_set_count(_sset))
	at_true(str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(!str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_del(_sset, "bar")
	at_true(0 == str_set_count(_sset))
	at_true(str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(!str_set_find(_sset, "bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "foo bar")
	at_true(1 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "foo bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, "foo bar")
	at_true(1 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "foo bar"))
	at_true(!str_set_find(_sset, "baz"))

	_sset = str_set_add(_sset, " foo bar ")
	at_true(2 == str_set_count(_sset))
	at_true(!str_set_is_empty(_sset))
	at_true(!str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, "foo bar"))
	at_true(str_set_find(_sset, " foo bar "))
	at_true(!str_set_find(_sset, "baz"))
	at_true(!str_set_find(_sset, ""))

	_sset = str_set_add(_sset, "")
	at_true(3 == str_set_count(_sset))
	at_true(str_set_find(_sset, ""))
	at_true(str_set_find(_sset, "foo bar"))
	at_true(str_set_find(_sset, " foo bar "))
	at_true(!str_set_find(_sset, "foo"))

	_sset = str_set_add(_sset, "foo")
	at_true(4 == str_set_count(_sset))
	at_true(str_set_find(_sset, ""))
	at_true(str_set_find(_sset, "foo bar"))
	at_true(str_set_find(_sset, " foo bar "))
	at_true(str_set_find(_sset, "foo"))
}

function test_str_set_init_add_del_arr(    _sset, _arr, _len) {
	at_test_begin("test_str_set_init_add_del_arr")

	_len = 0
	_arr[++_len] = "foo"
	_arr[++_len] = "bar"
	_arr[++_len] = ""
	_arr[++_len] = "bar"
	_arr[++_len] = "baz"

	at_true("" == _sset)

	_sset = str_set_init_arr(_arr, _len)
	at_true(4 == str_set_count(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, ""))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

	_len = 0
	_arr[++_len] = "foo"
	_arr[++_len] = "bar"
	_arr[++_len] = "bar"

	_sset = str_set_del_arr(_sset, _arr, _len)
	at_true(2 == str_set_count(_sset))
	at_true(str_set_find(_sset, ""))
	at_true(str_set_find(_sset, "baz"))

	_sset = str_set_add_arr(_sset, _arr, _len)
	at_true(4 == str_set_count(_sset))
	at_true(str_set_find(_sset, "foo"))
	at_true(str_set_find(_sset, ""))
	at_true(str_set_find(_sset, "bar"))
	at_true(str_set_find(_sset, "baz"))

}

function test_str_set_split(    _sset, _len, _arr) {
	at_test_begin("test_str_set_split")

	_sset = str_set_init()
	at_true(0 == str_set_split(_sset, _arr))

	_sset = str_set_add(_sset, "foo bar")
	_sset = str_set_add(_sset, " foo bar ")
	_sset = str_set_add(_sset, "baz")

	_len = str_set_split(_sset, _arr)
	at_true(3 == _len)
	at_true(str_set_count(_sset) == _len)
	at_true("foo bar" == _arr[1])
	at_true(" foo bar " == _arr[2])
	at_true("baz" == _arr[3])

	_sset = str_set_del(_sset, " foo bar ")
	_len = str_set_split(_sset, _arr)
	at_true(2 == _len)
	at_true(str_set_count(_sset) == _len)
	at_true("foo bar" == _arr[1])
	at_true("baz" == _arr[2])

	_sset = str_set_add(_sset, "")
	_len = str_set_split(_sset, _arr)
	at_true(3 == _len)
	at_true(str_set_count(_sset) == _len)
	at_true("foo bar" == _arr[1])
	at_true("baz" == _arr[2])
	at_true("" == _arr[3])

	_sset = str_set_add(_sset, "X")
	_len = str_set_split(_sset, _arr)
	at_true(4 == _len)
	at_true(str_set_count(_sset) == _len)
	at_true("foo bar" == _arr[1])
	at_true("baz" == _arr[2])
	at_true("" == _arr[3])
	at_true("X" == _arr[4])

	_sset = str_set_del(_sset, "")
	_len = str_set_split(_sset, _arr)
	at_true(3 == _len)
	at_true(str_set_count(_sset) == _len)
	at_true("foo bar" == _arr[1])
	at_true("baz" == _arr[2])
	at_true("X" == _arr[3])
}

function test_str_set_get(    _sset) {
	at_test_begin("test_str_set_get")

	_sset = str_set_init()
	at_true("" == str_set_get(_sset, 1))

	_sset = str_set_add(_sset, "foo bar")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true("" == str_set_get(_sset, 2))
	at_true("" == str_set_get(_sset, 3))

	_sset = str_set_add(_sset, " foo bar ")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true(" foo bar " == str_set_get(_sset, 2))
	at_true("" == str_set_get(_sset, 3))

	_sset = str_set_add(_sset, "baz")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true(" foo bar " == str_set_get(_sset, 2))
	at_true("baz" == str_set_get(_sset, 3))

	_sset = str_set_del(_sset, " foo bar ")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true("baz" == str_set_get(_sset, 2))

	_sset = str_set_add(_sset, "")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true("baz" == str_set_get(_sset, 2))
	at_true("" == str_set_get(_sset, 3))

	_sset = str_set_add(_sset, "zog")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true("baz" == str_set_get(_sset, 2))
	at_true("" == str_set_get(_sset, 3))
	at_true("zog" == str_set_get(_sset, 4))

	_sset = str_set_del(_sset, "")
	at_true("foo bar" == str_set_get(_sset, 1))
	at_true("baz" == str_set_get(_sset, 2))
	at_true("zog" == str_set_get(_sset, 3))
}

function test_str_set_is_eq(    _sset_a, _sset_b) {
	at_test_begin("test_str_set_is_eq")

	_sset_a = str_set_init()
	_sset_b = str_set_init()
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "")
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_init()
	_sset_b = str_set_init()
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "1")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "1")
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "2")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "2")
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "3")
	_sset_b = str_set_add(_sset_b, "4")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_del(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "3")
	at_true(str_set_is_eq(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_init()
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "2")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "3")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "")
	at_true(!str_set_is_eq(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "1")
	at_true(str_set_is_eq(_sset_a, _sset_b))
}

function test_str_set_union(    _sset_a, _sset_b, _sset_union) {
	at_test_begin("test_str_set_union")

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(str_set_is_empty(_sset_union))

	_sset_a = str_set_add(_sset_a, "1")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))

	_sset_a = str_set_add(_sset_a, "2")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))

	_sset_b = str_set_add(_sset_b, "2")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))

	_sset_b = str_set_add(_sset_b, "3")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(3 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))
	at_true(str_set_find(_sset_union, "3"))

	_sset_a = str_set_add(_sset_a, "")
	_sset_b = str_set_add(_sset_b, "")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(4 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))
	at_true(str_set_find(_sset_union, ""))
	at_true(str_set_find(_sset_union, "3"))

	_sset_a = str_set_del(_sset_a, "")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(4 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))
	at_true(str_set_find(_sset_union, ""))
	at_true(str_set_find(_sset_union, "3"))

	_sset_b = str_set_del(_sset_b, "")
	_sset_union = str_set_union(_sset_a, _sset_b)
	at_true(3 == str_set_count(_sset_union))
	at_true(str_set_find(_sset_union, "1"))
	at_true(str_set_find(_sset_union, "2"))
	at_true(str_set_find(_sset_union, "3"))
}

function test_str_set_intersect(    _sset_a, _sset_b, _sset_int) {
	at_test_begin("test_str_set_intersect")

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(str_set_is_empty(_sset_int))

	_sset_a = str_set_add(_sset_a, "1")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(str_set_is_empty(_sset_int))

	_sset_a = str_set_add(_sset_a, "2")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(str_set_is_empty(_sset_int))

	_sset_b = str_set_add(_sset_b, "1")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "1"))

	_sset_b = str_set_add(_sset_b, "3")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "1"))

	_sset_b = str_set_add(_sset_b, "2")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "1"))
	at_true(str_set_find(_sset_int, "2"))

	_sset_b = str_set_del(_sset_b, "2")
	_sset_b = str_set_add(_sset_b, "")
	_sset_b = str_set_add(_sset_b, "2")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "1"))
	at_true(str_set_find(_sset_int, "2"))

	_sset_a = str_set_add(_sset_a, "")
	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(3 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "1"))
	at_true(str_set_find(_sset_int, "2"))
	at_true(str_set_find(_sset_int, ""))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "2")
	_sset_a = str_set_add(_sset_a, "3")

	_sset_b = str_set_add(_sset_b, "3")
	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")

	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "3"))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "2")
	_sset_a = str_set_add(_sset_a, "3")

	_sset_b = str_set_add(_sset_b, "2")
	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")

	_sset_int = str_set_intersect(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_int))
	at_true(str_set_find(_sset_int, "2"))
}

function test_str_set_subtract(    _sset_a, _sset_b, _sset_diff) {
	at_test_begin("test_str_set_subtract")

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(1 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "1"))

	_sset_b = str_set_add(_sset_b, "1")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(0 == str_set_count(_sset_diff))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_b = str_set_add(_sset_b, "1")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(0 == str_set_count(_sset_diff))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "2")
	_sset_a = str_set_add(_sset_a, "3")

	_sset_b = str_set_add(_sset_b, "2")
	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")

	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "1"))
	at_true(str_set_find(_sset_diff, "3"))

	_sset_diff = str_set_subtract(_sset_b, _sset_a)
	at_true(2 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "4"))
	at_true(str_set_find(_sset_diff, "5"))

	_sset_b = str_set_add(_sset_b, "")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "1"))
	at_true(str_set_find(_sset_diff, "3"))

	_sset_a = str_set_add(_sset_a, "")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(2 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "1"))
	at_true(str_set_find(_sset_diff, "3"))

	_sset_b = str_set_del(_sset_b, "")
	_sset_diff = str_set_subtract(_sset_a, _sset_b)
	at_true(3 == str_set_count(_sset_diff))
	at_true(str_set_find(_sset_diff, "1"))
	at_true(str_set_find(_sset_diff, "3"))
	at_true(str_set_find(_sset_diff, ""))
}

function test_str_set_are_disjoint(    _sset_a, _sset_b) {
	at_test_begin("test_str_set_are_disjoint")

	_sset_a = str_set_init()
	_sset_b = str_set_init()
	at_true(str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "2")
	_sset_a = str_set_add(_sset_a, "3")

	_sset_b = str_set_add(_sset_b, "2")
	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")
	at_true(!str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "3")

	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")
	at_true(str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_b = str_set_add(_sset_b, "4")
	_sset_b = str_set_add(_sset_b, "5")
	at_true(str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_init()
	_sset_b = str_set_init()

	_sset_a = str_set_add(_sset_a, "1")
	_sset_a = str_set_add(_sset_a, "3")
	at_true(str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "")
	at_true(str_set_are_disjoint(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "")
	at_true(!str_set_are_disjoint(_sset_a, _sset_b))

	_sset_a = str_set_del(_sset_a, "")
	at_true(str_set_are_disjoint(_sset_a, _sset_b))
}

function test_str_set_is_subset(    _sset_a, _sset_b) {
	at_test_begin("test_str_set_is_subset")

	_sset_a = str_set_init()
	_sset_b = str_set_init()
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "1")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "2")
	at_true(!str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "2")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "1")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "3")
	at_true(!str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "3")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "4")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "5")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_a = str_set_add(_sset_a, "")
	at_true(!str_set_is_subset(_sset_a, _sset_b))

	_sset_b = str_set_add(_sset_b, "")
	at_true(str_set_is_subset(_sset_a, _sset_b))

	_sset_a = str_set_del(_sset_a, "")
	at_true(str_set_is_subset(_sset_a, _sset_b))
}

function test_str_set_make_printable(    _sset) {
	at_test_begin("test_str_set_make_printable")

	_sset = str_set_init()
	at_true("|" == str_set_make_printable(_sset))
	at_true("@" == str_set_make_printable(_sset, "@"))

	_sset = str_set_add(_sset, "1")
	_sset = str_set_add(_sset, "2")
	_sset = str_set_add(_sset, "")
	_sset = str_set_add(_sset, "3")

	at_true("|1|2||3|" == str_set_make_printable(_sset))
	at_true("-1-2--3-" == str_set_make_printable(_sset, "-"))

	_sset = str_set_del(_sset, "")

	at_true("|1|2|3|" == str_set_make_printable(_sset))
}

function main() {
	at_awklib_awktest_required()
	test_str_set_init()
	test_str_set_add_find_del_count_empty()
	test_str_set_init_add_del_arr()
	test_str_set_split()
	test_str_set_get()
	test_str_set_is_eq()
	test_str_set_union()
	test_str_set_intersect()
	test_str_set_subtract()
	test_str_set_are_disjoint()
	test_str_set_is_subset()
	test_str_set_make_printable()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
