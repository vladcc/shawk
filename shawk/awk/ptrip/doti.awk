#!/usr/bin/awk -f

# doti.awk -- turns dot notation into annotated boost ptree info syntax
# Vladimir Dinev
# vld.dinev@gmail.com
# 2021-11-30

# <misc>
function SCRIPT_NAME() {return "doti.awk"}
function SCRIPT_VERSION() {return "1.02"}

function err_fpos(msg) {
	error_print(sprintf("file '%s', line %d: %s", FILENAME, FNR, msg))
	error_flag_clear()
	skip_end_clear()
}

function split_path_val(arr_out,    _arr, _len) {
	# use $0 to for 0 copy
	
	if (index($0, "-|")) {
		# assume input comes from ptrip
		
		if ((_len = split($0, _arr, ":([0-9]+|-):")) > 1)
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
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling. Unlike
#@ other libraries, the function names for this library are not
#@ prepended.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	__LB_prog_program_name__ = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return __LB_prog_program_name__
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	__LB_prog_skip_end_flag__ = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	__LB_prog_skip_end_flag__ = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (__LB_prog_skip_end_flag__+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	__LB_prog_error_flag__ = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	__LB_prog_error_flag__ = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (__LB_prog_error_flag__+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {
	
	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
#@ <awklib_gtree>
#@ Library: gtr
#@ Description: A generic tree interface. Each node can have an arbitrary number
#@ of siblings and children. The tree can be traversed in two directions - down
#@ and right. The user passes around the node values. A node value is 'the
#@ address' of a node, which is a string. E.g. if the root is "r", then right of
#@ the root, its first sibling, is "rn" (n for next). Its second, "rnn".
#@ Similarly, down from the root, its first child, is "rd". The first sibling of
#@ the first child is "rdn", the second, "rdnn", and so on.
#@ Version: 1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-11-30
#@

# <public>
#
#@ Description: Represents the first root node.
#@ Returns: A string constant.
#
function GTR_ROOT() {
	return "r"
}

#
#@ Description: Clears out 'tree'.
#@ Returns: Nothing.
#
function gtr_init(tree) {
	tree[""]
	delete tree
}

#
#@ Description: Retrieval the value for 'node' in 'tree'.
#@ Returns: "" if 'node' does not exist in 'tree', 'tree[node]' otherwise.
#
function gtr_get_val(tree, node) {
	return gtr_has_node(tree, node) ? tree[node] : ""
}

#
#@ Description: Writes 'val' at 'tree[node]'.
#@ Returns: Nothing.
#
function gtr_put_val(tree, node, val) {
	tree[node] = val
}

#
#@ Description: Indicates whether 'tree[node]' exists.
#@ Returns: 1 if it does, 0 otherwise.
#
function gtr_has_node(tree, node) {
	return (node in tree)
}

#
#@ Description: Generates the address of the node which would be right below
#@ 'node'.
#@ Returns: The index string for the node below 'node'.
#
function gtr_down_of(node) {
	return (node "d")
}

#
#@ Description: Generates the address of the node exactly to the right of
#@ 'node'.
#@ Returns: The index string for the node on the right of 'node'. 
#
function gtr_right_of(node) {
	return (node "n")
}

#
#@ Description: Clears 'arr_out', collects the addresses of all nodes to the
#@ right of 'node' which exist in 'tree', starting with and including 'node'.
#@ Returns: The number of nodes to the right of 'node'.
#
function gtr_right_from(arr_out, tree, node,    _n) {

	delete arr_out
	_n = 0
	
	while (gtr_has_node(tree, node)) {
		arr_out[++_n] = node
		node = gtr_right_of(node)
	}
	return _n
}

#
#@ Description: 'Marks' the string 'node' in 'tree', so it can be checked later.
#@ This provides a way to e.g. make a list of nodes to filter out when
#@ traversing the tree. I.e. mark something as removed instead of actually
#@ removing it, which would be a way more expensive and complicated operation.
#@ Returns: Nothing.
#
function gtr_mark(tree, node) {
	tree[_gtr_mark_str(node)]
}

#
#@ Description: Unmark 'node' from 'tree' if it was marked.
#@ Returns: Nothing.
#
function gtr_unmark(tree, node) {
	if (gtr_is_marked(tree, node))
		delete tree[_gtr_mark_str(node)]
}

#
#@ Description: Indicates if 'node' is marked in 'tree'.
#@ Returns: 1 if it is, 0 otherwise.
#
function gtr_is_marked(tree, node) {
	return (_gtr_mark_str(node) in tree)
}
# </public>

function _gtr_mark_str(str) {return ("\034mark\034" str)}
#@ </awklib_gtree>
