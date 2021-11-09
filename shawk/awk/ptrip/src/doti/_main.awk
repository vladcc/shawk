#!/usr/bin/awk -f

# doti.awk -- turns dot notation into annotated boost ptree info syntax
# Vladimir Dinev
# vld.dinev@gmail.com
# 2021-11-03

# <misc>
function SCRIPT_NAME() {return "doti.awk"}
function SCRIPT_VERSION() {return "1.0"}

function err_fpos(msg) {
	error_print(sprintf("file '%s', line %d: %s", FILENAME, FNR, msg))
	error_flag_clear()
	skip_end_clear()
}

function split_path_val(arr_out,    _arr, _len) {
	# use $0 to for 0 copy
	
	if (index($0, "-|")) {
		# assume input comes from ptrip
		
		if ((_len = split($0, _arr, ":")) > 1)
			return split(_arr[_len], arr_out, " = ")
		else
			return 0 # assume a file name only line; signal nop
	} else {
		# assume generic dot notation
		return split($0, arr_out, " = ")
	}
}
# </misc>

# <tree>
function _tree_print(tree, node, tabs,    _str, _val, _next) {
	
	_val = _B_gtree_val_map[node]
	_str = (tabs gtr_get_val(tree, node))
	
	if (_val != "{null}")
		_str = (_str " " _val)
		
	print _str
	
	_next = gtr_down_of(node)
	if (gtr_has_node(tree, _next)) {
		print (tabs "{")
		_tree_print(tree, _next, (tabs "\t"))
		print (tabs "}")
	}
	
	_next = gtr_right_of(node)
	if (gtr_has_node(tree, _next))
		_tree_print(tree, _next, tabs)
}

function _tree_get_lvl_last(tree, node, val,    _arr, _len, _i, _ret) {
	
	if (!(_len = gtr_right_from(_arr, tree, node))) {
		gtr_put_val(tree, node, val)
		return node
	}
	
	_ret = _arr[_len]
	if (gtr_get_val(tree, _ret) == val)
		return _ret
	
	_ret = gtr_right_of(_ret)
	gtr_put_val(tree, _ret, val)
	return _ret
}

function _tree_node_of_path(tree, node, arr_path, len, pos,    _where, _val) {
	
	if (pos <= len) {
		_val = arr_path[pos]
		
		_where = _tree_get_lvl_last(tree, node, _val)
		
		if (pos == len)
			return _where
			
		_where = gtr_down_of(_where)
		return _tree_node_of_path(tree, _where, arr_path, len, pos+1)
	}
	
	# should never come here
	return ""
}

function tree_add(path, val,    _node, _arr, _len, _tmp) {

	_len = split(path, _arr, ".")
	_node = _tree_node_of_path(_B_gtree, GTR_ROOT(), _arr, _len, 1)
	
	if (tree_is_node_taken(_node)) {
 		_tmp = gtr_right_of(_node)
 		gtr_put_val(_B_gtree, _tmp, gtr_get_val(_B_gtree, _node))
 		_node = _tmp
	}
	
	_B_gtree_val_map[_node] = val
}
function tree_print() {_tree_print(_B_gtree, GTR_ROOT())}
function tree_is_node_taken(node) {return (node in _B_gtree_val_map)}

function tree_init() {
	gtr_init(_B_gtree)
	_B_gtree_val_map[""]
	delete _B_gtree_val_map
}
function dbg_tree_dump(    _n) {

	for (_n in _B_gtree)
		print sprintf("tree[ %s ] = '%s'", _n, _B_gtree[_n])
}
function dbg_val_dump(    _n) {

	for (_n in _B_gtree_val_map)
		print sprintf("val[ %s ] = '%s'", _n, _B_gtree_val_map[_n])
}
# </tree>

# <messages>
function USE_STR() {return sprintf("Use: %s <dot-file(s)>", SCRIPT_NAME())}

function print_use() {
	pstderr(USE_STR())
	pstderr(sprintf("Try: %s -v Help=1", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function print_help() {
print SCRIPT_NAME() " -- turns dot notation into annotated boost ptree info syntax"
print USE_STR()
print ""
print "Options:"
print "-v Version=1 - version info"
print "-v Help=1    - this screen"
	exit_success()
}

# </messages>

# <main>
function process_line(    _arr, _len) {
	
	_len = split_path_val(_arr)
	if (_len == 2)
		tree_add(_arr[1], _arr[2])
	else if (_len && _len != 2)
		err_fpos("ignoring bad line; syntax should be '<dot-path> = <value>'")
}

function init() {
	set_program_name(SCRIPT_NAME())
	if (Help)
		print_help()
	if (Version)
		print_version()	
	tree_init()
}

BEGIN {
	init()
}

/^[[:space:]]*#/ {next}
{process_line()}

END {
	#dbg_tree_dump()
	#dbg_val_dump()
	
	if (!should_skip_end())
		tree_print()
}
# </main>
