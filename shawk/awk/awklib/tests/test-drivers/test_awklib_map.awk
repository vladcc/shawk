#!/usr/bin/awk -f

function test_map_init(    _map) {
	at_test_begin("map_init()")

	_map["foo"]
	at_true("foo" in _map)
	
	map_init(_map)
	at_true(!("foo" in _map))
}

function test_map_add(    _map) {
	at_test_begin("map_add()")

	map_init(_map)
	at_true(!("foo" in _map))
	
	map_add(_map, "foo", "bar")
	at_true("foo" in _map)
	at_true("bar" == map_get_val(_map, "foo"))
}

function test_map_del(    _map) {
	at_test_begin("map_del()")

	map_init(_map)
	at_true(!("foo" in _map))
	
	map_add(_map, "foo", "bar")
	at_true("foo" in _map)
	
	map_del(_map, "foo")
	at_true(!("foo" in _map))
}

function test_map_get_val(    _map) {
	at_test_begin("map_get_val()")

	map_init(_map)
	at_true(!("foo" in _map))
	at_true("" == map_get_val(_map, "foo"))
	at_true(!("foo" in _map))
	
	map_add(_map, "foo", "bar")
	at_true("foo" in _map)
	at_true("bar" == map_get_val(_map, "foo"))
}

function test_map_has_key(    _map) {
	at_test_begin("map_has_key()")

	map_init(_map)
	at_true(!("foo" in _map))
	at_true(0 == map_has_key(_map, "foo"))
	map_add(_map, "foo", "bar")
	at_true("foo" in _map)
	at_true(1 == map_has_key(_map, "foo"))
}

function test_map_has_val(    _map) {
	at_test_begin("map_has_val()")

	map_init(_map)
	at_true(0 == map_has_val(_map, "bar"))
	map_add(_map, "foo", "bar")
	at_true(1 == map_has_val(_map, "bar"))
}

function test_map_size(    _map) {
	at_test_begin("test_map_size()")
	
	map_init(_map)
	at_true(0 == map_size(_map))
	
	map_add(_map, "foo", "bar")
	map_add(_map, "zig", "zag")
	map_add(_map, "100", "200")
	
	at_true(3 == map_size(_map))
}

function test_map_get_key(    _map) {
	at_test_begin("map_get_key()")

	map_init(_map)
	at_true("" == map_get_key(_map, "bar"))
	map_add(_map, "foo", "bar")
	at_true("foo" == map_get_key(_map, "bar"))
}

function test_map_copy(    _map_a, _map_b) {
	at_test_begin("map_copy()")

	map_init(_map_a)
	map_init(_map_b)
	
	at_true(0 == map_copy(_map_b, _map_a))
	at_true(0 == map_has_key(_map_b, "foo"))
	
	map_add(_map_a, "foo", "bar")
	map_add(_map_a, "zig", "zag")
	map_add(_map_b, "no", "removed")
	
	at_true(2 == map_copy(_map_b, _map_a))
	
	at_true("foo" == map_get_key(_map_b, "bar"))
	at_true("bar" == map_get_val(_map_b, "foo"))
	at_true("zig" == map_get_key(_map_b, "zag"))
	at_true("zag" == map_get_val(_map_b, "zig"))
}

function test_map_is_eq(    _map_a, _map_b) {
	at_test_begin("map_is_eq()")

	map_init(_map_a)
	map_init(_map_b)
	
	map_add(_map_a, "foo", "bar")
	map_add(_map_a, "zig", "zag")
	
	at_true(0 == map_is_eq(_map_a, _map_b))
	at_true(0 == map_is_eq(_map_b, _map_a))
	
	at_true(2 == map_copy(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_a, _map_b))
	at_true(1 == map_is_eq(_map_b, _map_a))
}

function test_map_overlay_new(    _map_a, _map_b, _map_c) {
	at_test_begin("map_overlay_new()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zag", "400")
	
	map_add(_map_b, "foo", "1")
	map_add(_map_b, "zig", "10")
	map_add(_map_b, "zag", "20")
	
	map_add(_map_c, "foo", "1")
	map_add(_map_c, "bar", "200")
	map_add(_map_c, "baz", "300")
	map_add(_map_c, "zig", "10")
	map_add(_map_c, "zag", "20")
	
	at_true(2 == map_overlay_new(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_overlay_all(    _map_a, _map_b, _map_c) {
	at_test_begin("map_overlay_all()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zag", "400")
	
	map_add(_map_b, "foo", "1")
	map_add(_map_b, "zig", "10")
	map_add(_map_b, "zag", "20")
	
	map_add(_map_c, "foo", "100")
	map_add(_map_c, "bar", "200")
	map_add(_map_c, "baz", "300")
	map_add(_map_c, "zig", "10")
	map_add(_map_c, "zag", "400")
	
	at_true(4 == map_overlay_all(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_match_key(    _map_a, _map_b, _map_c) {
	at_test_begin("map_match_key()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zig", "400")
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_c, "bar", "200")
	map_add(_map_c, "baz", "300")
	
	at_true(0 == map_match_key(_map_b, _map_a, "bonk"))
	at_true(0 == map_has_key(_map_b, "no"))
	
	at_true(2 == map_match_key(_map_b, _map_a, "a"))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_dont_match_key(    _map_a, _map_b, _map_c) {
	at_test_begin("map_dont_match_key()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zig", "400")
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_c, "foo", "100")
	map_add(_map_c, "zig", "400")
	
	at_true(0 == map_dont_match_key(_map_b, _map_a, "."))
	at_true(0 == map_has_key(_map_b, "no"))
	
	at_true(2 == map_dont_match_key(_map_b, _map_a, "a"))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_match_val(    _map_a, _map_b, _map_c) {
	at_test_begin("map_match_val()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zig", "400")
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_c, "bar", "200")
	map_add(_map_c, "baz", "300")
	
	at_true(0 == map_match_val(_map_b, _map_a, "bonk"))
	at_true(0 == map_has_key(_map_b, "no"))
	
	at_true(2 == map_match_val(_map_b, _map_a, "200|300"))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_dont_match_val(    _map_a, _map_b, _map_c) {
	at_test_begin("map_dont_match_val()")

	map_init(_map_a)
	map_init(_map_b)
	map_init(_map_c)
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "200")
	map_add(_map_a, "baz", "300")
	map_add(_map_a, "zig", "400")
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_c, "foo", "100")
	map_add(_map_c, "zig", "400")
	
	at_true(0 == map_dont_match_val(_map_b, _map_a, "."))
	at_true(0 == map_has_key(_map_b, "no"))
	
	at_true(2 == map_dont_match_val(_map_b, _map_a, "200|300"))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_reverse_once(    _map_a, _map_b, _map_c) {
	at_test_begin("map_reverse_once()")

	map_init(_map_a)
	map_init(_map_b)
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "100")
	map_add(_map_a, "baz", "300")
	
	map_add(_map_c, "100", "foo")
	map_add(_map_c, "300", "baz")
	
	at_true(2 == map_reverse_once(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))
	
	at_true(2 == map_reverse_once(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))	
}

function test_map_reverse(    _map_a, _map_b, _map_c) {
	at_test_begin("map_reverse()")

	map_init(_map_a)
	map_init(_map_b)
	
	map_add(_map_b, "no", "removed")
	
	map_add(_map_a, "foo", "100")
	map_add(_map_a, "bar", "100")
	map_add(_map_a, "baz", "300")
	
	map_add(_map_c, "100", "bar")
	map_add(_map_c, "300", "baz")
	
	at_true(3 == map_reverse(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))
	
	at_true(3 == map_reverse(_map_b, _map_a))
	at_true(1 == map_is_eq(_map_b, _map_c))
}

function test_map_to_str(    _map, _str) {
	at_test_begin("map_to_str()")

	map_init(_map)
	map_add(_map, "foo", "100")
	map_add(_map, "bar", "200")

	_str = map_to_str(_map)
	
	# no guarantee of order
	at_true(("foo 100\nbar 200\n" == _str) || 
		("bar 200\nfoo 100\n" == _str))
	
	_str = map_to_str(_map, "%s = %s|")
	at_true(("foo = 100|bar = 200|" == _str) ||
		("bar = 200|foo = 100|" == _str))
}

function main() {
	at_awklib_awktest_required()
	test_map_init()
	test_map_add()
	test_map_del()
	test_map_get_val()
	test_map_has_key()
	test_map_has_val()
	test_map_size()
	test_map_get_key()
	test_map_copy()
	test_map_is_eq()
	test_map_overlay_new()
	test_map_overlay_all()
	test_map_match_key()
	test_map_dont_match_key()
	test_map_match_val()
	test_map_dont_match_val()
	test_map_reverse_once()
	test_map_reverse()
	test_map_to_str()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
