#!/usr/bin/awk -f

function test_str_list_init(    _slist) {
	at_test_begin("test_str_list_init")

	at_true(STR_LIST_SEP() != _slist)

	_slist = str_list_init()
	at_true(STR_LIST_SEP() == _slist)
}

function test_str_list_add_del_find_count_get_empty(    _slist) {
	at_test_begin("test_str_list_add_del_find_count_get_empty")

	at_true(!str_list_is_empty(_slist))

	_slist = str_list_init()
	at_true(str_list_is_empty(_slist))
	at_true(0 == str_list_size(_slist))
	at_true(!str_list_find(_slist, ""))
	at_true(!str_list_find(_slist, "foo"))

	_slist = str_list_add(_slist, "foo")
	at_true(!str_list_is_empty(_slist))
	at_true(1 == str_list_size(_slist))
	at_true(!str_list_find(_slist, ""))
	at_true(str_list_find(_slist, "foo"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("" == str_list_get(_slist, 2))
	at_true("" == str_list_get(_slist, 100))

	_slist = str_list_add(_slist, "foo")
	at_true(!str_list_is_empty(_slist))
	at_true(2 == str_list_size(_slist))
	at_true(!str_list_find(_slist, ""))
	at_true(str_list_find(_slist, "foo"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("foo" == str_list_get(_slist, 2))

	_slist = str_list_add(_slist, "")
	at_true(!str_list_is_empty(_slist))
	at_true(3 == str_list_size(_slist))
	at_true(str_list_find(_slist, ""))
	at_true(str_list_find(_slist, "foo"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("foo" == str_list_get(_slist, 2))
	at_true("" == str_list_get(_slist, 3))

	_slist = str_list_add(_slist, "bar")
	at_true(!str_list_is_empty(_slist))
	at_true(4 == str_list_size(_slist))
	at_true(str_list_find(_slist, ""))
	at_true(str_list_find(_slist, "foo"))
	at_true(str_list_find(_slist, "bar"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("foo" == str_list_get(_slist, 2))
	at_true("" == str_list_get(_slist, 3))
	at_true("bar" == str_list_get(_slist, 4))

	_slist = str_list_del(_slist, "")
	at_true(!str_list_is_empty(_slist))
	at_true(3 == str_list_size(_slist))
	at_true(!str_list_find(_slist, ""))
	at_true(str_list_find(_slist, "foo"))
	at_true(str_list_find(_slist, "bar"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("foo" == str_list_get(_slist, 2))
	at_true("bar" == str_list_get(_slist, 3))

	_slist = str_list_del(_slist, "foo")
	at_true(!str_list_is_empty(_slist))
	at_true(2 == str_list_size(_slist))
	at_true(str_list_find(_slist, "foo"))
	at_true(str_list_find(_slist, "bar"))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("bar" == str_list_get(_slist, 2))

	_slist = str_list_del(_slist, "bar")
	at_true(!str_list_is_empty(_slist))
	at_true(1 == str_list_size(_slist))
	at_true(str_list_find(_slist, "foo"))
	at_true(!str_list_find(_slist, "bar"))
	at_true("foo" == str_list_get(_slist, 1))

	_slist = str_list_del(_slist, "foo")
	at_true(str_list_is_empty(_slist))
	at_true(0 == str_list_size(_slist))
	at_true(!str_list_find(_slist, "foo"))
}

function test_str_list_init_add_del_arr(    _slist, _arr, _len) {
	at_test_begin("test_str_list_init_add_del_arr")

	_len = 0
	_arr[++_len] = "foo"
	_arr[++_len] = ""
	_arr[++_len] = "foo"
	_arr[++_len] = "bar baz"

	_slist = str_list_init_arr(_arr, _len)
	at_true(4 == str_list_size(_slist))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("" == str_list_get(_slist, 2))
	at_true("foo" == str_list_get(_slist, 3))
	at_true("bar baz" == str_list_get(_slist, 4))

	_len = 0
	_arr[++_len] = ""
	_arr[++_len] = "foo"

	_slist = str_list_del_arr(_slist, _arr, _len)
	at_true(2 == str_list_size(_slist))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("bar baz" == str_list_get(_slist, 2))

	_slist = str_list_add_arr(_slist, _arr, _len)
	at_true(4 == str_list_size(_slist))
	at_true("foo" == str_list_get(_slist, 1))
	at_true("bar baz" == str_list_get(_slist, 2))
	at_true("" == str_list_get(_slist, 3))
	at_true("foo" == str_list_get(_slist, 4))
}

function test_str_list_how_many(    _slist) {
	at_test_begin("test_str_list_how_many")

	_slist = str_list_init()
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "foo baz")
	_slist = str_list_add(_slist, "zig")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")

	at_true(9 == str_list_size(_slist))
	at_true("foo" == str_list_get(_slist, 1))
	at_true(4 == str_list_how_many(_slist, "foo"))
	at_true(2 == str_list_how_many(_slist, "bar"))
	at_true(1 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))
}

function test_str_list_del_all(    _slist) {
	at_test_begin("test_str_list_del_all")

	_slist = str_list_init()
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "foo baz")
	_slist = str_list_add(_slist, "zig")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")

	at_true(9 == str_list_size(_slist))
	at_true(4 == str_list_how_many(_slist, "foo"))
	at_true(2 == str_list_how_many(_slist, "bar"))
	at_true(1 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_slist = str_list_del_all(_slist, "foo")
	at_true(5 == str_list_size(_slist))
	at_true("" == str_list_get(_slist, 1))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(2 == str_list_how_many(_slist, "bar"))
	at_true(1 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_slist = str_list_del_all(_slist, "foo baz")
	at_true(4 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(2 == str_list_how_many(_slist, "bar"))
	at_true(0 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_slist = str_list_del_all(_slist, "bar")
	at_true(2 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(0 == str_list_how_many(_slist, "bar"))
	at_true(0 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_slist = str_list_del_all(_slist, "zig")
	at_true(1 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(0 == str_list_how_many(_slist, "bar"))
	at_true(0 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(0 == str_list_how_many(_slist, "zig"))

	_slist = str_list_del_all(_slist, "")
	at_true(str_list_is_empty(_slist))
	at_true(0 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(0 == str_list_how_many(_slist, "bar"))
	at_true(0 == str_list_how_many(_slist, "foo baz"))
	at_true(0 == str_list_how_many(_slist, ""))
	at_true(0 == str_list_how_many(_slist, "zig"))
}

function test_str_list_del_arr_all(    _slist, _arr, _len) {
	at_test_begin("test_str_list_del_arr_all")

	_slist = str_list_init()
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "foo baz")
	_slist = str_list_add(_slist, "zig")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")

	at_true(9 == str_list_size(_slist))
	at_true(4 == str_list_how_many(_slist, "foo"))
	at_true(2 == str_list_how_many(_slist, "bar"))
	at_true(1 == str_list_how_many(_slist, "foo baz"))
	at_true(1 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_len = 0
	_arr[++_len] = "foo"
	_arr[++_len] = "bar"
	_arr[++_len] = ""

	_slist = str_list_del_arr_all(_slist, _arr, _len)
	at_true(2 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(0 == str_list_how_many(_slist, "bar"))
	at_true(1 == str_list_how_many(_slist, "foo baz"))
	at_true(0 == str_list_how_many(_slist, ""))
	at_true(1 == str_list_how_many(_slist, "zig"))

	_len = 0
	_arr[++_len] = "foo"
	_arr[++_len] = "foo baz"
	_arr[++_len] = "zig"

	_slist = str_list_del_arr_all(_slist, _arr, _len)
	at_true(0 == str_list_size(_slist))
	at_true(0 == str_list_how_many(_slist, "foo"))
	at_true(0 == str_list_how_many(_slist, "bar"))
	at_true(0 == str_list_how_many(_slist, "foo baz"))
	at_true(0 == str_list_how_many(_slist, ""))
	at_true(0 == str_list_how_many(_slist, "zig"))
}

function test_str_list_append_list(    _slist_a, _slist_b) {
	at_test_begin("test_str_list_append_list")

	_slist_a = str_list_init()
	_slist_b = str_list_init()

	_slist_a = str_list_add(_slist_a, "foo")
	at_true(1 == str_list_size(_slist_a))
	at_true("foo" == str_list_get(_slist_a, 1))

	_slist_b = str_list_add(_slist_b, "bar baz")
	_slist_b = str_list_add(_slist_b, "zig")
	at_true(2 == str_list_size(_slist_b))
	at_true("bar baz" == str_list_get(_slist_b, 1))
	at_true("zig" == str_list_get(_slist_b, 2))

	_slist_a = str_list_append_list(_slist_a, _slist_b)
	at_true(3 == str_list_size(_slist_a))
	at_true("foo" == str_list_get(_slist_a, 1))
	at_true("bar baz" == str_list_get(_slist_a, 2))
	at_true("zig" == str_list_get(_slist_a, 3))
}

function test_str_list_split(    _slist, _arr, _len) {
	at_test_begin("test_str_list_split")

	_slist = str_list_init()
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")
	at_true(4 == str_list_size(_slist))

	_len = str_list_split(_slist, _arr)
	at_true(4 == _len)
	at_true("foo" == _arr[1])
	at_true("" == _arr[2])
	at_true("foo" == _arr[3])
	at_true("bar" == _arr[4])
}

function test_str_list_make_printable(    _slist) {
	at_test_begin("test_str_list_make_printable")

	_slist = str_list_init()
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "")
	_slist = str_list_add(_slist, "foo")
	_slist = str_list_add(_slist, "bar")

	at_true("@foo@@foo@bar@" == str_list_make_printable(_slist))
	at_true("|foo||foo|bar|" == str_list_make_printable(_slist, "|"))

}

function main() {
	at_awklib_awktest_required()
	test_str_list_init()
	test_str_list_add_del_find_count_get_empty()
	test_str_list_init_add_del_arr()
	test_str_list_how_many()
	test_str_list_del_all()
	test_str_list_del_arr_all()
	test_str_list_append_list()
	test_str_list_split()
	test_str_list_make_printable()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
