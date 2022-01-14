#!/bin/bash

function main
{
	echo ./*/* | awk \
'function phony(str) {print ".PHONY: " str}

function rule_help() {
	phony("help")
	print "help:"
	print "\t@echo \"make all     - rebuild test\""
	print "\t@echo \"make rebuild - rebuild all projects\""
	print "\t@echo \"make test    - test all projects\""
	print "\t@echo \"make help    - this screen\""
	print ""
}

function all_proj(what,    _path, _arr, _len, _i, _ret, _j) {
	
	for (_j = 1; _j <= ProjectsLen; ++_j) {	
		_path = Projects[_j]
		
		_len = split(_path, _arr)
		for (_i = 1; _i <= _len; ++_i)
			_ret = (_ret (what basename(_arr[_i])) " ")
	}
	
	return _ret
}

function rule_test(path,    _dir, _base, _rule) {
	_dir = dirname(path)
	_base = basename(path)
	_rule = ("test_" _base)
	phony(_rule)
	print sprintf("%s:\n\tcd %s && $(MAKE) test", _rule, path)
	print ""
}

function rule_rebuild(path,    _dir, _base, _rule) {
	_dir = dirname(path)
	_base = basename(path)
	_rule = ("rebuild_" _base)
	phony(_rule)
	print sprintf("%s:\n\tcd %s && $(MAKE) -B all", _rule, path)
	print ""
}

function dirname(str) {
	if (match(str, "/[^/]+$"))
		return substr(str, 1, RSTART-1)
	return str
}

function basename(str) {	
	if (match(str, "/[^/]+$"))
		return substr(str, RSTART+1, RLENGTH-1)
	return str
}

function gen(    _arr, _len, _i) {
	
	rule_help()
	
	phony("all")
	print "all: rebuild test"
	print ""
	
	print sprintf("TEST_PROJ = %s", all_proj("test_"))
	phony("test")
	print "test: $(TEST_PROJ)"
	print ""
	
	print sprintf("REBUILD_PROJ = %s", all_proj("rebuild_"))
	phony("rebuild")
	print "rebuild: $(REBUILD_PROJ)"
	print ""
	
	for (_i = 1; _i <= ProjectsLen; ++_i)
		_gen(Projects[_i])
}

function _gen(paths,    _arr, _len, _rule, _i) {
	
	_len = split(paths, _arr)
	
	for (_i = 1; _i <= _len; ++_i)
		rule_rebuild(_arr[_i])
	
	for (_i = 1; _i <= _len; ++_i)
		rule_test(_arr[_i])
}

{Projects[++ProjectsLen] = $0}
END {gen()}'
}

main
