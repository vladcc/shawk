#!/usr/bin/awk -f

function test_GTR_ROOT() {
	at_test_begin("GTR_ROOT()")
	at_true("r" == GTR_ROOT())
}

function test_gtr_init(    _tree, _node) {
	at_test_begin("gtr_init()")
	
	_tree["foo"]
	at_true("foo" in _tree)
	
	gtr_init(_tree)
	at_true(!("foo" in _tree))
}

function test_gtr_get_val(    _tree, _node) {
	at_test_begin("gtr_get_val()")
	
	_tree["foo"] = "bar"
	at_true("bar" == gtr_get_val(_tree, "foo"))
	
	at_true(!("fooz" in _tree))
	at_true("" == gtr_get_val(_tree, "fooz"))
	at_true(!("fooz" in _tree))
}

function test_gtr_put_val(    _tree, _node) {
	at_test_begin("gtr_put_val()")

	gtr_put_val(_tree, "foo", "bar")
	at_true("bar" == _tree["foo"])
}

function test_gtr_has_node(    _tree, _node) {
	at_test_begin("gtr_has_node()")

	at_true(!(gtr_has_node(_tree, "foo")))
	gtr_put_val(_tree, "foo", "bar")
	at_true((gtr_has_node(_tree, "foo")))
}

function test_gtr_down_of(    _tree, _node) {
	at_test_begin("gtr_down_of()")
	
	at_true("rd" == gtr_down_of("r"))
	at_true("rdd" == gtr_down_of("rd"))
}

function test_gtr_right_of(    _tree, _node) {
	at_test_begin("gtr_right_of()")
	
	at_true("rn" == gtr_right_of("r"))
	at_true("rnn" == gtr_right_of("rn"))
}

function test_gtr_right_from(    _tree, _node, _arr, _len) {
	at_test_begin("gtr_right_from()")
	
	_tree["r"] = "foo"
	_tree["rn"] = "bar"
	_tree["rnn"] = "baz"

	_tree["rd"] = "zig"
	_tree["rdn"] = "zag"
	_tree["rdnn"] = "zog"

	_len = gtr_right_from(_arr, _tree, "r")
	at_true(3 == _len)
	at_true("r" == _arr[1])
	at_true("rn" == _arr[2])
	at_true("rnn" == _arr[3])
	at_true("foo" == gtr_get_val(_tree, _arr[1]))
	at_true("bar" == gtr_get_val(_tree, _arr[2]))
	at_true("baz" == gtr_get_val(_tree, _arr[3]))

	_len = gtr_right_from(_arr, _tree, "rn")
	at_true(2 == _len)
	at_true("rn" == _arr[1])
	at_true("rnn" == _arr[2])
	at_true("bar" == gtr_get_val(_tree, _arr[1]))
	at_true("baz" == gtr_get_val(_tree, _arr[2]))

	_len = gtr_right_from(_arr, _tree, "rd")
	at_true(3 == _len)
	at_true("rd" == _arr[1])
	at_true("rdn" == _arr[2])
	at_true("rdnn" == _arr[3])
	at_true("zig" == gtr_get_val(_tree, _arr[1]))
	at_true("zag" == gtr_get_val(_tree, _arr[2]))
	at_true("zog" == gtr_get_val(_tree, _arr[3]))
	
	_len = gtr_right_from(_arr, _tree, "rdn")
	at_true(2 == _len)
	at_true("rdn" == _arr[1])
	at_true("rdnn" == _arr[2])
	at_true("zag" == gtr_get_val(_tree, _arr[1]))
	at_true("zog" == gtr_get_val(_tree, _arr[2]))
}

function test_gtr_marked(    _tree, _node, _arr, _len) {
	at_test_begin("gtr_mark*()")

	gtr_init(_tree)

	_node = "foo"

	at_true(0 == (_gtr_mark_str(_node) in _tree))
	at_true(0 == gtr_is_marked(_tree, _node))
	at_true(0 == (_gtr_mark_str(_node) in _tree))

	gtr_mark(_tree, _node)
	at_true(1 == (_gtr_mark_str(_node) in _tree))
	at_true(1 == gtr_is_marked(_tree, _node))
	at_true(1 == (_gtr_mark_str(_node) in _tree))

	gtr_unmark(_tree, _node)
	at_true(0 == (_gtr_mark_str(_node) in _tree))
	at_true(0 == gtr_is_marked(_tree, _node))
	at_true(0 == (_gtr_mark_str(_node) in _tree))
}

function main() {
	at_awklib_awktest_required()
	test_GTR_ROOT()
	test_gtr_init()
	test_gtr_get_val()
	test_gtr_put_val()
	test_gtr_has_node()
	test_gtr_down_of()
	test_gtr_right_of()
	test_gtr_right_from()
	test_gtr_marked()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
