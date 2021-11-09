#!/usr/bin/awk -f

function test_sc_re_prepare(    _map, _res) {
	at_test_begin("sc_re_prepare()")

	_map["foo"] = "should be gone"
	
	_res = sc_re_prepare(_map)
	at_true("" == _res)
	at_true(!(_SC_MATCH() in _map))
	at_true(!("foo" in _map))
	
	_res = sc_re_prepare(_map, 2, "foo")
	at_true("'foo': syntax should be '<*|num|csv|range><nsep><regex>'" == _res)
	
	_res = sc_re_prepare(_map, 2, "foo=bar")
	at_true("'foo' must be '*', a number > 0, csv, or a range" == \
		_res)
	
	_res = sc_re_prepare(_map, 2, "1=bar")
	at_true("" == _res)
	at_true(_SC_MATCH() in _map)
	
	_res = sc_re_prepare(_map, 2, "3=bar")
	at_true("'3=bar': field id '3' out of range" == _res)
	
	_res = sc_re_prepare(_map, 3, "1-1=bar")
	at_true("'1-1=bar': bad range '1-1'; first should be < second" == _res)
	
	_res = sc_re_prepare(_map, 3, "2-1=bar")
	at_true("'2-1=bar': bad range '2-1'; first should be < second" == _res)
	
	_res = sc_re_prepare(_map, 3, "1-5=bar")
	at_true("'1-5=bar': field id '4' out of range" == _res)
	
	_res = sc_re_prepare(_map, 3, "1,=bar")
	at_true("'1,' must be '*', a number > 0, csv, or a range" == _res)
	
	_res = sc_re_prepare(_map, 3, ",1=bar")
	at_true("',1' must be '*', a number > 0, csv, or a range" == _res)
	
	_res = sc_re_prepare(_map, 3, "1,5,3=bar")
	at_true("'1,5,3=bar': field id '5' out of range" == _res)
	
	_res = sc_re_prepare(_map, 1, "*=bar")
	at_true("bar" == _map[1])
	at_true(!(2 in _map))
	
	_res = sc_re_prepare(_map, 2, "*=bar")
	at_true("bar" == _map[1])
	at_true("bar" == _map[2])
	at_true(!(3 in _map))
	
	_res = sc_re_prepare(_map, 3, "*=bar")
	at_true("" == _res)
	at_true("bar" == _map[1])
	at_true("bar" == _map[2])
	at_true("bar" == _map[3])
	at_true(!(4 in _map))
	
	_res = sc_re_prepare(_map, 3, "*=bar;1=foo")
	at_true("" == _res)
	at_true("foo" == _map[1])
	at_true("bar" == _map[2])
	at_true("bar" == _map[3])
	
	_res = sc_re_prepare(_map, 3, "*=bar;2-3=foo")
	at_true("" == _res)
	at_true("bar" == _map[1])
	at_true("foo" == _map[2])
	at_true("foo" == _map[3])
	
	_res = sc_re_prepare(_map, 3, "1=[0-9];2=[a-z]")
	at_true("" == _res)
	at_true("[0-9]" == _map[1])
	at_true("[a-z]" == _map[2])
	
	_res = sc_re_prepare(_map, 3, "*=bar;1=baz;2-3=foo")
	at_true("" == _res)
	at_true("baz" == _map[1])
	at_true("foo" == _map[2])
	at_true("foo" == _map[3])
	
	_res = sc_re_prepare(_map, 3, "*=bar;1=;2-3=foo")
	at_true("'1=': syntax should be '<*|num|csv|range><nsep><regex>'" == _res)
	
	_res = sc_re_prepare(_map, 5, "*=bar;1,3,5=foo")
	at_true("" == _res)
	at_true("foo" == _map[1])
	at_true("bar" == _map[2])
	at_true("foo" == _map[3])
	at_true("bar" == _map[4])
	at_true("foo" == _map[5])
	
	_res = sc_re_prepare(_map, 5, "*=bar;3,1,5=fo-o")
	at_true("" == _res)
	at_true("fo-o" == _map[1])
	at_true("bar" == _map[2])
	at_true("fo-o" == _map[3])
	at_true("bar" == _map[4])
	at_true("fo-o" == _map[5])
	
	_res = sc_re_prepare(_map, 5, "*=bar;1,3,5=foo f;2-3=baz")
	at_true("" == _res)
	at_true("foo f" == _map[1])
	at_true("baz" == _map[2])
	at_true("baz" == _map[3])
	at_true("bar" == _map[4])
	at_true("foo f" == _map[5])
	
	_res = sc_re_prepare(_map, 5, "*#bar@1,3,5#foo@2-3#baz", "@", "#")
	at_true("" == _res)
	at_true("foo" == _map[1])
	at_true("baz" == _map[2])
	at_true("baz" == _map[3])
	at_true("bar" == _map[4])
	at_true("foo" == _map[5])
	
	_res = sc_re_prepare(_map, 7, "*=[0-9];1=[a-z];2,6=[A-Z];3-5=[.]")
	at_true("" == _res)
	at_true("[a-z]" == _map[1])
	at_true("[A-Z]" == _map[2])
	at_true("[.]" == _map[3])
	at_true("[.]" == _map[4])
	at_true("[.]" == _map[5])
	at_true("[A-Z]" == _map[6])
	at_true("[0-9]" == _map[7])
}

function test_sc_check_str(    _ofs, _res, _map) {
	at_test_begin("sc_check_str()")

	_ofs = FS
	FS = " "
	_res = sc_check_str("foo")
	at_true("2 fields expected, got 1" == _res)
	
	_res = sc_check_str("foo bar")
	at_true("" == _res)
	FS = _ofs
	
	_res = sc_check_str("foo bar", 1, ";")
	at_true("" == _res)
	
	_res = sc_check_str("foo bar", 2, ";")
	at_true("2 fields expected, got 1" == _res)
	
	_res = sc_check_str("foo bar", "foo", ";")
	at_true("2 fields expected, got 1" == _res)
	
	_res = sc_check_str("foo bar", -2, ";")
	at_true("2 fields expected, got 1" == _res)
	
	_res = sc_check_str("foo bar", 3, ";")
	at_true("3 fields expected, got 1" == _res)
	
	_res = sc_check_str("foo;bar;baz", 3, ";")
	at_true("" == _res)
	
	_res = sc_re_prepare(_map, 3, "*=[[:digit:]]+")
	at_true("" == _res)
	
	_res = sc_check_str("5;66;777", 3, ";", _map)
	at_true("" == _res)
	
	_res = sc_check_str("5;foo;777", 3, ";", _map)
	at_true("field 2 'foo' did not match '[[:digit:]]+'" == _res)
	
	_res = sc_re_prepare(_map, 3, "1,3=[[:digit:]]+")
	at_true("" == _res)

	_res = sc_check_str("5;foo;777", 3, ";", _map)
	at_true("" == _res)
	
	_res = sc_check_str("5;foo;777", 3, ";", _map, 1)
	at_true("strict: no regex for field 2" == _res)
}

function test_SC_SYNTAX(    _str) {
	at_test_begin("SC_SYNTAX()")
	
	_str = \
"<*|num|csv|range><nsep><regex>[<rsep><*|num|csv|range><nsep><regex>...]\n"\
"'*' means 'all fields'. By default, 'nsep' is '=', and 'rsep' is ';'.\n"\
"Latter expressions overwrite earlier ones. E.g. given 7 fields and:\n"\
"'*=[0-9];1=[a-z];2,6=[A-Z];3-5=[.]', field 1 will be matched to '[a-z]',\n"\
"fields 2 and 6 to '[A-Z]', fields 3, 4, and 5 to '[.]', field 7 to '[0-9]'"

	at_true(SC_SYNTAX() == _str)
}

function main() {
	at_awklib_awktest_required()
	test_sc_re_prepare()
	test_sc_check_str()
	test_SC_SYNTAX()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
