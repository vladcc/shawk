#!/usr/bin/awk -f

function test_prep_str(    _str, _subst, _ok, _map) {
	at_test_begin("prep_str()")

	_map["determ"] = "the"
	_map["animal-1"] = "fox"
	_map["animal-2"] = "dog"
	
	_ok = "the quick brown fox jumps over the lazy dog"
	_str = "{determ} quick brown {animal-1} jumps over {determ} "\
	"lazy {animal-2}"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())

	_ok = "the# quick brown fox# jumps over the# lazy dog#"
	_str = "{determ}# quick brown {animal-1}# jumps over "\
	"{determ}# lazy {animal-2}#"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())

	_ok = "the quick brown fox jumps over the lazy dog"
	_str = "#{determ}# quick brown #{animal-1}# jumps over "\
	"#{determ}# lazy #{animal-2}#"
	at_true(prep_str(_str, _map, "#[{]%s[}]#") == _ok)
	at_true(4 == prep_num_of_subs())
	
	delete _map
	_map["[-[:alnum:]]+"] = "foo"
	
	_ok = "foo quick brown foo jumps over foo lazy foo"
	_str = "{determ} quick brown {animal-1} jumps over "\
	"{determ} lazy {animal-2}"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())
	
	_ok = "the quick brown fox jumps over the lazy dog"
	_str = "{1} quick brown {2} jumps over {1} lazy {3}"
	delete _map
	_map["1"] = "the"
	_map["2"] = "fox"
	_map["3"] = "dog"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())
	
	delete _map
	_map["10"] = "the"
	_map["20"] = "fox"
	_map["30"] = "dog"
	at_true(prep_str(_str, _map) == _str)
	at_true(0 == prep_num_of_subs())
	
	_ok = "the quick brown fox jumps over the lazy dog"
	_str = "{10} quick brown {20} jumps over {10} lazy {30}"
	delete _map
	_map[10] = "the"
	_map[20] = "fox"
	_map[30] = "dog"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())
	
	delete _map
	_map["1"] = "the"
	_map["2"] = "fox"
	_map["3"] = "dog"
	at_true(prep_str(_str, _map) == _str)
	at_true(0 == prep_num_of_subs())
	
	delete _map
	_map["1"] = "the"
	_map["color"] = "brown"
	_map["[A-Z]+"] = "fox"
	
	_ok = "the quick brown fox jumps over the lazy dog"
	_str = "{1} quick {color} {ANIMAL} jumps over {1} lazy dog"
	at_true(prep_str(_str, _map) == _ok)
	at_true(4 == prep_num_of_subs())
	
	delete _map
	_map[1] = "foo"
	_map["arg"] = "bar"
	
	_ok = "foo bar"
	_str = "{1} {arg}"
	at_true(prep_str(_str, _map) == _ok)
	at_true(2 == prep_num_of_subs())
}

function main() {
	at_awklib_awktest_required()
	test_prep_str()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
