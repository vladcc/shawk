#!/usr/bin/awk -f

function test_pft_init(    _pft, _str) {
	at_test_begin("pft_init()")

	_pft["foo"]
	at_true("foo" in _pft)
	
	pft_init(_pft)
	at_true(!("foo" in _pft))
}

function test_pft_insert(    _pft, _str) {
	at_test_begin("pft_insert()")

	pft_init(_pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")
	
	pft_insert(_pft, _str)
	at_true(_str in _pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")
	pft_insert(_pft, _str)
	at_true(_str in _pft)
	
	at_true("t" in _pft)
	at_true("h" == _pft["t"])
	at_true(("i" PFT_SEP() "a") == _pft[("t" PFT_SEP() "h")])
	at_true("s" == _pft[("t" PFT_SEP() "h" PFT_SEP() "i")])
	at_true("t" == _pft[("t" PFT_SEP() "h" PFT_SEP() "a")])
}

function test_pft_mark(    _pft, _str) {
	at_test_begin("pft_mark()")

	pft_init(_pft)
	
	at_true(!pft_is_marked(_pft, "t"))

	pft_mark(_pft, "t")	
	at_true(pft_is_marked(_pft, "t"))
}

function test_pft_is_marked(    _pft, _str) {
	at_test_begin("pft_is_marked()")

	pft_init(_pft)
	
	at_true(!pft_is_marked(_pft, "t"))

	pft_mark(_pft, "t")	
	at_true(pft_is_marked(_pft, "t"))
}

function test_pft_get(    _pft, _str) {
	at_test_begin("pft_get()")

	pft_init(_pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")
	
	pft_insert(_pft, _str)
	at_true(_str in _pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")
	pft_insert(_pft, _str)
	at_true(_str in _pft)
	
	at_true("h" == pft_get(_pft, "t"))
	at_true(("i" PFT_SEP() "a") == pft_get(_pft, ("t" PFT_SEP() "h")))
	at_true("s" == pft_get(_pft, ("t" PFT_SEP() "h" PFT_SEP() "i")))
	at_true("t" == pft_get(_pft, ("t" PFT_SEP() "h" PFT_SEP() "a")))
	at_true("" == pft_get(_pft,
		("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")))
	at_true("" == pft_get(_pft,
		("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")))
}

function test_pft_has(    _pft, _str) {
	at_test_begin("pft_has()")

	pft_init(_pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")
	
	pft_insert(_pft, _str)
	at_true(pft_has(_pft, _str))
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")
	pft_insert(_pft, _str)
	at_true(pft_has(_pft, _str))
	at_true(pft_has(_pft, "t"))
	at_true(pft_has(_pft, ("t" PFT_SEP() "h")))
	at_true(!pft_has(_pft, ("i" PFT_SEP() "a")))
	at_true(pft_has(_pft, ("t" PFT_SEP() "h" PFT_SEP() "i")))
	at_true(pft_has(_pft, ("t" PFT_SEP() "h" PFT_SEP() "a")))
	at_true(pft_has(_pft,
		("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")))
	at_true(pft_has(_pft,
		("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")))
}

function test_pft_split(    _pft, _str, _arr, _len) {
	at_test_begin("pft_split()")

	_str = ("a" PFT_SEP() "b" PFT_SEP() "c")
	_len = pft_split(_arr, _str)
	at_true(3 == _len)
	at_true("a" == _arr[1])
	at_true("b" == _arr[2])
	at_true("c" == _arr[3])

	pft_init(_pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")
	
	pft_insert(_pft, _str)
	at_true(pft_has(_pft, _str))
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "a" PFT_SEP() "t")
	pft_insert(_pft, _str)
	
	_len = pft_split(_arr, pft_get(_pft, ("t" PFT_SEP() "h")))
	at_true(2 == _len)
	at_true("i" == _arr[1])
	at_true("a" == _arr[2])
}

function test_pft_path_has(    _pft, _str) {
	at_test_begin("pft_path_has()")

	_str = ("t" PFT_SEP() "h" PFT_SEP() "e")
	
	at_true(!pft_path_has(_str, "s"))
	at_true(pft_path_has(_str, "t"))
	at_true(pft_path_has(_str, "h"))
	at_true(pft_path_has(_str, "e"))
	at_true(!pft_path_has(_str, "f"))
}

function test_pft_arr_to_pft_str(    _pft, _str, _arr) {
	at_test_begin("pft_arr_to_pft_str()")

	pft_init(_pft)
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s")
	
	_arr[1] = "t"
	_arr[2] = "h"
	_arr[3] = "i"
	_arr[4] = "s"

	at_true(_str == pft_arr_to_pft_str(_arr, 4))
}

function test_pft_cat(    _pft, _str) {
	at_test_begin("pft_cat()")

	at_true("a" == pft_cat("a"))
	at_true("b" == pft_cat("", "b"))
	at_true(("a" PFT_SEP() "b") == pft_cat("a", "b"))
}

function test_pft_pretty(    _pft, _str, _arr) {
	at_test_begin("pft_pretty()")

	_arr[1] = "t"
	_arr[2] = "h"
	_arr[3] = "e"

	pft_init(_pft)
	_str = pft_arr_to_pft_str(_arr, 3)
	at_true("t.h.e" == pft_pretty(_str))
	at_true("t-h-e" == pft_pretty(_str, "-"))
	
	_str = (_PFT_MARK_SEP() _str)
	at_true(".t.h.e" == pft_pretty(_str))
	at_true("-t-h-e" == pft_pretty(_str, "-"))
}

function test_pft_to_str_dfs(    _pft, _str, _arr, _len) {
	at_test_begin("pft_to_str_dfs()")

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
	
	
	at_true("this that than thank" == pft_to_str_dfs(_pft, "t"))
	at_true("t-h-i-s -> t-h-a-t -> t-h-a-n -> t-h-a-n-k" ==\
		pft_to_str_dfs(_pft, "t", " -> ", "-"))
	
	_str = ("t" PFT_SEP() "h" PFT_SEP() "a")
	at_true("that than thank" == pft_to_str_dfs(_pft, _str))
	at_true("t-h-a-t -> t-h-a-n -> t-h-a-n-k" ==\
		pft_to_str_dfs(_pft, _str, " -> ", "-"))
}

function test_pft_str_dump(    _pft, _str, _arr, _len) {
	at_test_begin("pft_str_dump()")

	pft_init(_pft)
	
	_len = split("th", _arr, "")
	_str = pft_arr_to_pft_str(_arr, _len)
	
	pft_insert(_pft, _str)
	
	at_true("pft[\"t.h\"] = \"\"\npft[\"t\"] = \"h\"" ==\
		pft_str_dump(_pft))
	
	at_true("pft[\"t-h\"] = \"\"\npft[\"t\"] = \"h\"" ==\
		pft_str_dump(_pft, "-"))
	
	pft_init(_pft)
	pft_mark(_pft, _str)
	
	at_true("pft[\".t.h\"] = \"\"" == pft_str_dump(_pft))
	at_true("pft[\"-t-h\"] = \"\"" == pft_str_dump(_pft, "-"))
}

function main() {
	at_awklib_awktest_required()
	test_pft_init()
	test_pft_insert()
	test_pft_mark()
	test_pft_is_marked()
	test_pft_get()
	test_pft_has()
	test_pft_split()
	test_pft_path_has()
	test_pft_arr_to_pft_str()
	test_pft_cat()
	test_pft_pretty()
	test_pft_to_str_dfs()
	test_pft_str_dump()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
