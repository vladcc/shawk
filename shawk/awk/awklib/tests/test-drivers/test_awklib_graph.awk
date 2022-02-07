#!/usr/bin/awk -f

function test_graph_init(    _graph) {
	at_test_begin("graph_init()")

	_graph["foo"]
	at_true("foo" in _graph)
	
	graph_init(_graph)
	at_true(!("foo" in _graph))
}

function test_graph_add_directed(    _graph) {
	at_test_begin("graph_add_directed()")
	
	graph_init(_graph)

	at_true(!graph_has_vertex(_graph, "foo"))
	at_true(!graph_has_vertex(_graph, "bar"))
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_directed(_graph, "foo", "bar")
	
	at_true(graph_has_vertex(_graph, "foo"))
	at_true(graph_has_vertex(_graph, "bar"))
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_init(_graph)

	at_true(!graph_has_vertex(_graph, "foo"))
	at_true(!graph_has_vertex(_graph, "bar"))
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_directed(_graph, "foo", "bar", 5)
	
	at_true(graph_has_vertex(_graph, "foo"))
	at_true(graph_has_vertex(_graph, "bar"))
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(graph_has_weight(_graph, "foo", "bar"))
	at_true(5 == graph_get_weight(_graph, "foo", "bar"))
}

function test_graph_add_non_directed(    _graph) {
	at_test_begin("graph_add_non_directed()")
	
	graph_init(_graph)

	at_true(!graph_has_vertex(_graph, "foo"))
	at_true(!graph_has_vertex(_graph, "bar"))
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_non_directed(_graph, "foo", "bar")
	
	at_true(graph_has_vertex(_graph, "foo"))
	at_true(graph_has_vertex(_graph, "bar"))
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_init(_graph)

	at_true(!graph_has_vertex(_graph, "foo"))
	at_true(!graph_has_vertex(_graph, "bar"))
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "bar", "foo"))
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_non_directed(_graph, "foo", "bar", 5)
	
	at_true(graph_has_vertex(_graph, "foo"))
	at_true(graph_has_vertex(_graph, "bar"))
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(graph_has_edge(_graph, "bar", "foo"))
	at_true(graph_has_weight(_graph, "foo", "bar"))
	at_true(5 == graph_get_weight(_graph, "foo", "bar"))
	at_true(graph_has_weight(_graph, "bar", "foo"))
	at_true(5 == graph_get_weight(_graph, "bar", "foo"))
}

function test_graph_get_vertices(    _graph, _arr) {
	at_test_begin("graph_get_vertices()")
	
	graph_init(_graph)
	
	_arr["foo"]
	at_true("foo" in _arr)
	at_true(0 == graph_get_vertices(_graph, _arr))
	at_true(!("foo" in _arr))
	
	graph_add_vertex(_graph, "foo")
	at_true(1 == graph_get_vertices(_graph, _arr))
	at_true("foo" == _arr[1])
	
	graph_add_vertex(_graph, "bar")
	at_true(2 == graph_get_vertices(_graph, _arr))
	at_true(("foo" == _arr[1] && "bar" == _arr[2]) || \
		("foo" == _arr[2] && "bar" == _arr[1]))
}

function test_graph_add_vertex(    _graph) {
	at_test_begin("graph_add_vertex()")

	graph_init(_graph)
	
	at_true(!("foo" in _graph))
	
	graph_add_vertex(_graph, "foo")
	at_true("foo" in _graph)
	at_true(_GRAPH_SEP() == _graph["foo"])
	
	_graph["foo"] = 5
	graph_add_vertex(_graph, "foo")
	at_true("foo" in _graph)
	at_true(5 == _graph["foo"])
}

function test_graph_has_vertex(    _graph) {
	at_test_begin("graph_has_vertex()")

	graph_init(_graph)
	
	at_true(!(graph_has_vertex(_graph, "foo")))
	
	graph_add_vertex(_graph, "foo")
	at_true(graph_has_vertex(_graph, "foo"))
}

function test_graph_rm_vertex(    _graph) {
	at_test_begin("graph_rm_vertex()")

	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	at_true(graph_has_vertex(_graph, "foo"))
	
	graph_rm_vertex(_graph, "foo")
	at_true(!graph_has_vertex(_graph, "foo"))
}

function test_graph_purge_vertex(    _graph) {
	at_test_begin("graph_purge_vertex()")

	graph_init(_graph)

	graph_add_vertex(_graph, "foo")
	at_true(graph_has_vertex(_graph, "foo"))
	
	graph_add_vertex(_graph, "bar")
	at_true(graph_has_vertex(_graph, "bar"))
	
	graph_add_edge(_graph, "foo", "bar")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	
	graph_add_edge(_graph, "bar", "foo")
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP()) == _graph["bar"])

	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(5 == _graph[_graph_make_weight("foo", "bar")])
	
	graph_set_weight(_graph, "bar", "foo", 6)
	at_true(6 == _graph[_graph_make_weight("bar", "foo")])
	
	graph_purge_vertex(_graph, "foo")

	at_true(!graph_has_vertex(_graph, "foo"))
	at_true(_GRAPH_SEP() == _graph["bar"])
	at_true(!(_graph_make_weight("foo", "bar") in _graph))
	at_true(!(_graph_make_weight("bar", "foo") in _graph))
	
	graph_init(_graph)

	graph_add_vertex(_graph, "foo")
	graph_add_vertex(_graph, "bar")
	graph_add_vertex(_graph, "baz")
	graph_add_vertex(_graph, "zig")
	
	graph_add_edge(_graph, "foo", "bar")
	graph_set_weight(_graph, "foo", "bar", 1)
	graph_add_edge(_graph, "bar", "foo")
	graph_set_weight(_graph, "bar", "foo", 1)
	
	graph_add_edge(_graph, "foo", "baz")
	graph_set_weight(_graph, "foo", "baz", 2)
	graph_add_edge(_graph, "baz", "foo")
	graph_set_weight(_graph, "baz", "foo", 2)
	
	graph_add_edge(_graph, "foo", "zig")
	graph_set_weight(_graph, "foo", "zig", 3)
	graph_add_edge(_graph, "zig", "foo")
	graph_set_weight(_graph, "zig", "foo", 3)
	
	graph_add_edge(_graph, "baz", "zig")
	graph_set_weight(_graph, "baz", "zig", 4)
	graph_add_edge(_graph, "zig", "baz")
	graph_set_weight(_graph, "zig", "baz", 4)
	
	at_true(\
		(_GRAPH_SEP() "bar" _GRAPH_SEP() "baz" _GRAPH_SEP() "zig" _GRAPH_SEP())\
		==\
		_graph["foo"])
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP()) == _graph["bar"])
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP() "zig" _GRAPH_SEP()) == \
		_graph["baz"])
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP() "baz" _GRAPH_SEP()) == \
		_graph["zig"])
	at_true(1 == _graph[_graph_make_weight("foo", "bar")])
	at_true(1 == _graph[_graph_make_weight("bar", "foo")])
	at_true(2 == _graph[_graph_make_weight("foo", "baz")])
	at_true(2 == _graph[_graph_make_weight("baz", "foo")])
	at_true(3 == _graph[_graph_make_weight("foo", "zig")])
	at_true(3 == _graph[_graph_make_weight("zig", "foo")])
	at_true(4 == _graph[_graph_make_weight("baz", "zig")])
	at_true(4 == _graph[_graph_make_weight("zig", "baz")])
	
	graph_purge_vertex(_graph, "baz")
	
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP() "zig" _GRAPH_SEP()) == \
		_graph["foo"])
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP()) == _graph["bar"])
	at_true(!("baz" in _graph))
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP()) == _graph["zig"])
	at_true(1 == _graph[_graph_make_weight("foo", "bar")])
	at_true(1 == _graph[_graph_make_weight("bar", "foo")])
	at_true(!(_graph_make_weight("foo", "baz") in _graph))
	at_true(!(_graph_make_weight("baz", "foo") in _graph))
	at_true(3 == _graph[_graph_make_weight("foo", "zig")])
	at_true(3 == _graph[_graph_make_weight("zig", "foo")])
	at_true(!(_graph_make_weight("baz", "zig") in _graph))
	at_true(!(_graph_make_weight("zig", "baz") in _graph))
	
	graph_purge_vertex(_graph, "zig")
	
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	at_true((_GRAPH_SEP() "foo" _GRAPH_SEP()) == _graph["bar"])
	at_true(!("baz" in _graph))
	at_true(!("zig" in _graph))
	at_true(1 == _graph[_graph_make_weight("foo", "bar")])
	at_true(1 == _graph[_graph_make_weight("bar", "foo")])
	at_true(!(_graph_make_weight("foo", "baz") in _graph))
	at_true(!(_graph_make_weight("baz", "foo") in _graph))
	at_true(!(_graph_make_weight("foo", "zig") in _graph))
	at_true(!(_graph_make_weight("zig", "foo") in _graph))
	at_true(!(_graph_make_weight("baz", "zig") in _graph))
	at_true(!(_graph_make_weight("zig", "baz") in _graph))
}

function test_graph_add_edge(    _graph) {
	at_test_begin("graph_add_edge()")

	graph_init(_graph)
	
	graph_add_vertex(_graph, "foo")
	graph_add_vertex(_graph, "bar")
	
	at_true(_GRAPH_SEP() == _graph["foo"])
	at_true(_GRAPH_SEP() == _graph["bar"]) 
	
	graph_add_edge(_graph, "foo", "bar")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	
	graph_add_edge(_graph, "foo", "bar")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	
	graph_add_edge(_graph, "foo", "zig")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	
	graph_add_vertex(_graph, "zig")
	graph_add_edge(_graph, "foo", "zig")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP() "zig" _GRAPH_SEP()) == \
		_graph["foo"])
	
	at_true(!("baz" in _graph))
	graph_add_edge(_graph, "baz", "foo")
	at_true(!("baz" in _graph))
}

function test_graph_has_edge(    _graph) {
	at_test_begin("graph_has_edge()")

	graph_init(_graph)

	graph_add_vertex(_graph, "foo")
	graph_add_vertex(_graph, "bar")
	
	at_true(_GRAPH_SEP() == _graph["foo"])
	at_true(_GRAPH_SEP() == _graph["bar"]) 
	
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	
	graph_add_edge(_graph, "foo", "bar")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP()) == _graph["foo"])
	at_true(graph_has_edge(_graph, "foo", "bar"))
	
	at_true(!graph_has_edge(_graph, "foo", "zig"))
	
	graph_add_edge(_graph, "foo", "zig")
	at_true(!graph_has_edge(_graph, "foo", "zig"))
	
	graph_add_vertex(_graph, "zig")
	graph_add_edge(_graph, "foo", "zig")
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP() "zig" _GRAPH_SEP()) == \
		_graph["foo"])
	at_true(graph_has_edge(_graph, "foo", "zig"))
}

function test_graph_num_edges(    _graph) {
	at_test_begin("graph_num_edges()")

	graph_init(_graph)

	at_true(0 == graph_num_edges(_graph, "foo"))
	
	graph_add_vertex(_graph, "foo")
	at_true(0 == graph_num_edges(_graph, "foo"))
	
	graph_add_vertex(_graph, "bar")
	graph_add_edge(_graph, "foo", "bar")
	at_true(1 == graph_num_edges(_graph, "foo"))
	
	graph_add_vertex(_graph, "baz")
	graph_add_edge(_graph, "foo", "baz")
	at_true(2 == graph_num_edges(_graph, "foo"))
	
	graph_add_vertex(_graph, "zig")
	graph_add_edge(_graph, "foo", "zig")
	at_true(3 == graph_num_edges(_graph, "foo"))
}

function test_graph_get_edges(    _graph, _arr) {
	at_test_begin("graph_get_edges()")

	graph_init(_graph)
	
	_arr["foo"]
	at_true(0 == graph_get_edges(_graph, "foo", _arr))
	at_true(!("foo" in _arr))

	graph_add_vertex(_graph, "foo")
	at_true(0 == graph_get_edges(_graph, "foo", _arr))
	
	graph_add_vertex(_graph, "bar")
	graph_add_edge(_graph, "foo", "bar")
	at_true(1 == graph_get_edges(_graph, "foo", _arr))
	at_true("bar" == _arr[1])
	
	graph_add_vertex(_graph, "baz")
	graph_add_edge(_graph, "foo", "baz")
	at_true(2 == graph_get_edges(_graph, "foo", _arr))
	at_true("bar" == _arr[1])
	at_true("baz" == _arr[2])
	
	graph_add_vertex(_graph, "zig")
	graph_add_edge(_graph, "foo", "zig")
	at_true(3 == graph_get_edges(_graph, "foo", _arr))
	at_true("bar" == _arr[1])
	at_true("baz" == _arr[2])
	at_true("zig" == _arr[3])
}

function test_graph_rm_edge(    _graph) {
	at_test_begin("graph_rm_edge()")
	
	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	graph_add_vertex(_graph, "bar")
	graph_add_vertex(_graph, "baz")
	graph_add_vertex(_graph, "zig")
	
	graph_add_edge(_graph, "foo", "bar")
	graph_add_edge(_graph, "foo", "baz")
	graph_add_edge(_graph, "foo", "zig")
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(graph_has_edge(_graph, "foo", "baz"))
	at_true(graph_has_edge(_graph, "foo", "zig"))
	at_true(3 == graph_num_edges(_graph, "foo"))
	at_true(\
		(_GRAPH_SEP() "bar" _GRAPH_SEP() "baz" _GRAPH_SEP() "zig" _GRAPH_SEP())\
			==\
				_graph["foo"])
				
	graph_rm_edge(_graph, "foo", "baz")
	at_true(graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "foo", "baz"))
	at_true(graph_has_edge(_graph, "foo", "zig"))
	at_true(2 == graph_num_edges(_graph, "foo"))
	at_true((_GRAPH_SEP() "bar" _GRAPH_SEP() "zig" _GRAPH_SEP()) ==\
		_graph["foo"])		
	
	graph_rm_edge(_graph, "foo", "bar")
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "foo", "baz"))
	at_true(graph_has_edge(_graph, "foo", "zig"))
	at_true(1 == graph_num_edges(_graph, "foo"))
	at_true((_GRAPH_SEP() "zig" _GRAPH_SEP()) == _graph["foo"])
	
	graph_rm_edge(_graph, "foo", "zig")
	at_true(!graph_has_edge(_graph, "foo", "bar"))
	at_true(!graph_has_edge(_graph, "foo", "baz"))
	at_true(!graph_has_edge(_graph, "foo", "zig"))
	at_true(0 == graph_num_edges(_graph, "foo"))
	at_true(_GRAPH_SEP() == _graph["foo"])
}

function test_graph_set_weight(    _graph) {
	at_test_begin("graph_set_weight()")

	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	
	at_true(!(_graph_make_weight("foo", "bar") in _graph))

	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(!(_graph_make_weight("foo", "bar") in _graph))
	
	graph_add_vertex(_graph, "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(!(_graph_make_weight("foo", "bar") in _graph))
	
	graph_add_edge(_graph, "foo", "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(5 == _graph[_graph_make_weight("foo", "bar")])
}

function test_graph_has_weight(    _graph) {
	at_test_begin("graph_has_weight()")

	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	
	at_true(!graph_has_weight(_graph, "foo", "bar"))

	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_vertex(_graph, "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(!graph_has_weight(_graph, "foo", "bar"))
	
	graph_add_edge(_graph, "foo", "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(graph_has_weight(_graph, "foo", "bar"))
}

function test_graph_get_weight(    _graph) {
	at_test_begin("graph_get_weight()")

	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	
	at_true("" == graph_get_weight(_graph, "foo", "bar"))

	graph_set_weight(_graph, "foo", "bar", 5)
	at_true("" == graph_get_weight(_graph, "foo", "bar"))
	
	graph_add_vertex(_graph, "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true("" == graph_get_weight(_graph, "foo", "bar"))
	
	graph_add_edge(_graph, "foo", "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	at_true(5 == graph_get_weight(_graph, "foo", "bar"))
}

function test_graph_rm_weight(    _graph) {
	at_test_begin("graph_rm_weight()")

	graph_init(_graph)
	graph_add_vertex(_graph, "foo")
	graph_add_vertex(_graph, "bar")
	graph_add_edge(_graph, "foo", "bar")
	graph_set_weight(_graph, "foo", "bar", 5)
	
	at_true(graph_has_weight(_graph, "foo", "bar"))
	at_true(5 == graph_get_weight(_graph, "foo", "bar"))
	
	graph_rm_weight(_graph, "foo", "bar")
	
	at_true(0 == graph_has_weight(_graph, "foo", "bar"))
	at_true("" == graph_get_weight(_graph, "foo", "bar"))
}

function main() {
	at_awklib_awktest_required()
	test_graph_init()
	test_graph_add_directed()
	test_graph_add_non_directed()
	test_graph_get_vertices()
	test_graph_add_vertex()
	test_graph_has_vertex()
	test_graph_rm_vertex()
	test_graph_purge_vertex()
	test_graph_add_edge()
	test_graph_has_edge()
	test_graph_num_edges()
	test_graph_get_edges()
	test_graph_rm_edge()
	test_graph_set_weight()
	test_graph_has_weight()
	test_graph_get_weight()
	test_graph_rm_weight()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
