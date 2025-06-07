BEGIN {
	main()
}

function list_make() {return foo_list_make()}
function list_head(lst) {return foo_list_get_head(lst)}
function list_push(lst, data) {
	foo_list_set_head(lst, foo_node_make(data, foo_list_get_head(lst)))
}

function node_make() {return foo_node_make()}
function node_set_data(nd, data) {foo_node_set_data(nd, data)}
function node_data(nd) {return foo_node_get_data(nd)}
function node_next(nd) {return foo_node_get_next_(nd)}
function node_set_next(nd, nxt) {return foo_node_set_next_(nd, nxt)}

function foo_errq(msg) {
	print sprintf("error: %s", msg) > "/dev/stderr"
	exit(1)
}

function test_ok(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "baz_")
	list_push(_lst, "bar_")
	list_push(_lst, "foo_")

	print foo_is("zoing_")
	print foo_is(_lst)
	print foo_type_of(_lst)

	_node = list_head(_lst)
	while (_node) {
		print node_data(_node)
		_node = node_next(_node)
	}
}

function test_use_bad_type(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo_")
	_node = list_head(_lst)
	list_push(_node, "bar_")
}

function test_assign_bad_type(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo_")
	_node = list_head(_lst)
	node_set_next(_node, _lst)
}

function test_no_ent() {
	list_push("foo_")
}

function test_clear(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo_")
	_node = list_head(_lst)
	foo_clear()
	node_set_data(_node, "bar_")
}

function test_gen_ind(    _lst) {
	_lst = list_make()
	list_head(_lst)
	print _lst
	print list_make()
	foo_clear()
	print list_make()
	print list_make()
	list_head(_lst)
}

function main() {
	if (Ok)
		test_ok()
	else if (UseBadType)
		test_use_bad_type()
	else if (AssignBadType)
		test_assign_bad_type()
	else if (NoEnt)
		test_no_ent()
	else if (Clear)
		test_clear()
	else if (GenInd)
		test_gen_ind()
}
