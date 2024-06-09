#!/usr/bin/awk -f

function test_arr_print(    _arr) {

	_arr[1] = "arr_foo"
	_arr[2] = "arr_bar"
	_arr[3] = "arr_baz"

	arr_print(_arr, 3)
	arr_print(_arr, 3, "-")
}

function test_map_print(    _map) {

	_map["map_foo"] = 1
	_map["map_bar"] = 2
	_map["map_baz"] = 3

	map_print(_map)
}

function test_set_print(    _set) {

	_set["set_foo"]
	_set["set_bar"]
	_set["set_baz"]
	set_print(_set, "\n")
}

function test_tabs_print() {

	tabs_inc()
	tabs_print_str("tabs_foo")
	print ""
	tabs_print("tabs_foo")
}

function test_unpredictable(    _map, _set) {

	# The order of the elements in the printed string is not guaranteed

	_map["map_foo"] = 1
	_map["map_bar"] = 2
	_map["map_baz"] = 3
	map_print(_map, "%s %s|")

	_set["set_foo"]
	_set["set_bar"]
	_set["set_baz"]
	set_print(_set, "-")
}

function test_pftree(    _arr, _len, _str, _pft) {

	# Use pft_mark() as well
	pft_init(_pft)
	_len = split("this", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	_len = split("that", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	_len = split("than", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)
	pft_mark(_pft, _str)

	_len = split("thank", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	pft_print_dump(_pft)
	pft_print_dump(_pft, "-")

	pft_print_dfs(_pft, "t")
	pft_print_dfs(_pft, "t", " -> ", "-")

	# No pft_mark()
	pft_init(_pft)
	_len = split("this", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	_len = split("that", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	_len = split("thank", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	pft_insert(_pft, _str)

	pft_print_dump(_pft)
	pft_print_dump(_pft, "-")

	pft_print_dfs(_pft, "t")
	pft_print_dfs(_pft, "t", " -> ", "-")
}

function test_str_set(    _sset) {

	_sset = str_set_init()
	str_set_print(_sset, "@")

	_sset = str_set_add(_sset, "1")
	_sset = str_set_add(_sset, "2")
	_sset = str_set_add(_sset, "")
	_sset = str_set_add(_sset, "3")
	str_set_print(_sset)
}

function main() {

	if (Unpredictable) {
		test_unpredictable()
	} else {
		test_arr_print()
		test_map_print()
		test_set_print()
		test_tabs_print()
		test_pftree()
		test_str_set()
	}
}

BEGIN {
	main()
}
