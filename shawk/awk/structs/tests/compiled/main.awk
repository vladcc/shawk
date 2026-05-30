BEGIN {
	main()
}

function list_make() {return ent_list_make()}
function list_head(lst) {return ent_list_get_head(lst)}
function list_push(lst, data) {
	ent_list_set_head(lst, ent_node_make(data, ent_list_get_head(lst)))
}

function node_make() {return ent_node_make()}
function node_set_data(nd, data) {ent_node_set_data(nd, data)}
function node_data(nd) {return ent_node_get_data(nd)}
function node_next(nd) {return ent_node_get_next_(nd)}
function node_set_next(nd, nxt) {return ent_node_set_next_(nd, nxt)}

function ent_errq(msg) {
	print sprintf("error: %s", msg) > "/dev/stderr"
	exit(1)
}

function test_ok(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "baz")
	list_push(_lst, "bar")
	list_push(_lst, "foo")

	print ent_is("zoing")
	print ent_is(_lst)
	print ent_type_of(_lst)

	_node = list_head(_lst)
	while (_node) {
		print node_data(_node)
		_node = node_next(_node)
	}
}

function test_use_bad_type(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo")
	_node = list_head(_lst)
	list_push(_node, "bar")
}

function test_assign_bad_type(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo")
	_node = list_head(_lst)
	node_set_next(_node, _lst)
}

function test_no_ent() {
	list_push("foo")
}

function test_clear(    _lst, _node) {
	_lst = list_make()
	list_push(_lst, "foo")
	_node = list_head(_lst)
	ent_clear()
	node_set_data(_node, "bar")
}

function test_gen_ind(    _lst) {
	_lst = list_make()
	list_head(_lst)
	print _lst
	print list_make()
	ent_clear()
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
