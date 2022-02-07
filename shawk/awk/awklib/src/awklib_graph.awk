#@ <awklib_graph>
#@ Library: graph
#@ Description: An adjacency list graph implementation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2022-02-06
#@

# <public>

#
#@ Description: Clears 'graph'. 
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_init(graph) {

	graph[""]
	delete graph
}

#
#@ Description: Adds vertices 'a' and 'b' in 'graph', creates an edge from 'a'
#@ to 'b', if 'w' is given, that edge gets 'w' as a weight.
#@ Returns: Nothing.
#
function graph_add_directed(graph, a, b, w) {

	graph_add_vertex(graph, a)
	graph_add_vertex(graph, b)
	graph_add_edge(graph, a, b)
	
	if (w != "")
		graph_set_weight(graph, a, b, w)
}

#
#@ Description: Adds vertices 'a' and 'b' in 'graph', creates an edge from 'a'
#@ to 'b' and from 'b' to 'a', if 'w' is given, both edges get 'w' as a weight.
#@ Returns: Nothing.
#
function graph_add_non_directed(graph, a, b, w) {
	
	graph_add_vertex(graph, a)
	graph_add_vertex(graph, b)
	graph_add_edge(graph, a, b)
	graph_add_edge(graph, b, a)
	
	if (w != "") {
	
		graph_set_weight(graph, a, b, w)
		graph_set_weight(graph, b, a, w)
	}
}

#
#@ Description: Clears 'arr_out', fills 'arr_out' with the list of vertices in
#@ 'graph' in no particular order.
#@ Returns: The number of vertices, which is the same as the size of 'arr_out'.
#@ Complexity: O(n), where n is the number of vertices in 'graph'.
#
function graph_get_vertices(graph, arr_out,    _n, _end) {

	delete arr_out
	
	for (_n in graph)
		arr_out[++_end] = _n
	
	return _end
}

#
#@ Description: Adds 'vertex' to 'graph' if 'vertex' does not exist.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_add_vertex(graph, vertex) {

	if (!(vertex in graph))
		graph[vertex] = _GRAPH_SEP()
}

#
#@ Description: Indicates if 'vertex' exists in 'graph'.
#@ Returns: 1 if it does, 0 otherwise.
#@ Complexity: O(1)
#
function graph_has_vertex(graph, vertex) {

	return (vertex in graph)
}

#
#@ Description: Removes 'vertex' from 'graph'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_rm_vertex(graph, vertex,    _edges, _end, _i) {

	if (vertex in graph)
		delete graph[vertex]
}

#
#@ Description: Removes 'vertex' from 'graph', as well as all edges and weights
#@ to and from 'vertex'.
#@ Returns: Nothing.
#@ Complexity: O(n), where n is the number of vertices and weights in 'graph'.
#
function graph_purge_vertex(graph, vertex,    _n, _sep) {

	if (vertex in graph) {

		delete graph[vertex]

		_sep = _GRAPH_SEP()
		vertex = (_sep vertex _sep)
		for (_n in graph) {
		
			if (match(_n, vertex))
				delete graph[_n]
			else	
				gsub(vertex, _sep, graph[_n])
		}
	}
}

#
#@ Description: Adds an edge from 'from' to 'to' only if 'from' and 'to' are
#@ vertices in 'graph', and such edge does not already exist. Does nothing
#@ otherwise.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_add_edge(graph, from, to) {

	if ((from in graph) && (to in graph) && !graph_has_edge(graph, from, to))
		graph[from] = (graph[from] to _GRAPH_SEP())
}

#
#@ Description: Indicates whether and edge exists from 'from' to 'to' in
#@ 'graph'.
#@ Returns: 1 if and edge exists, 0 otherwise. 
#@ Complexity: O(n), where n is the number of edges of 'from'.
#
function graph_has_edge(graph, from, to) {

	if ((from in graph) && (to in graph))
		return !!(index(graph[from], (_GRAPH_SEP() to _GRAPH_SEP())))
	return 0
}

#
#@ Description: Indicates the number of edges 'vertex' has.
#@ Returns: The number of edges of 'vertex' in 'graph'.
#@ Complexity: O(n), where n is the number of edges.
#
function graph_num_edges(graph, vertex) {

	if (vertex in graph)
		return (gsub(_GRAPH_SEP(), _GRAPH_SEP(), graph[vertex]) - 1)
	return 0
}

#
#@ Description: Clears 'arr_out', provides a list of all edges of 'vertex' in
#@ 'arr_out'. E.g., if vertex "a" has edges to "b" and "c", then after a call t
#@ this function 'arr_out' will look like:
#@ arr_out[1] = "b"
#@ arr_out[2] = "c"
#@ Returns: The number of edges of 'vertex', which is the same as the size of
#@ 'arr_out'.
#@ Complexity: O(n), where n is the number of edges. 
#
function graph_get_edges(graph, vertex, arr_out,    _str) {

	delete arr_out
	if (vertex in graph) {
	
		_str = graph[vertex]
		gsub(_GRAPH_STRIP(), "", _str)
		return split(_str, arr_out, _GRAPH_SEP())
	}
	return 0
}

#
#@ Description: If 'from' and 'to' are vertices in 'graph', removes the edge
#@ from 'from' to 'to' if it exists. Does nothing otherwise.
#@ Returns: Nothing.
#@ Complexity: O(n), where n is the number of edges of 'from'.
#
function graph_rm_edge(graph, from, to) {

	if ((from in graph) && (to in graph))
		sub((_GRAPH_SEP() to _GRAPH_SEP()), _GRAPH_SEP(), graph[from])
}

#
#@ Description: If 'from' and 'to' are vertices in 'graph' and if an edge from
#@ 'from' to 'to' exists, sets a weight for that edge.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_set_weight(graph, from, to, weight) {

	if ((from in graph) && (to in graph) && graph_has_edge(graph, from, to))
		graph[_graph_make_weight(from, to)] = weight
}

#
#@ Description: Indicates whether there's a weight from 'from' to 'to'.
#@ Returns: 1 if there is, 0 otherwise.
#@ Complexity: O(1)
#
function graph_has_weight(graph, from, to) {

	return (_graph_make_weight(from, to) in graph)
}

#
#@ Description: Indicates the value of the weight for the edge from 'from' to
#@ 'to'.
#@ Returns: The value of the weight, "" if no such weight exists.
#@ Complexity: O(1)
#
function graph_get_weight(graph, from, to) {

	if (_graph_make_weight(from, to) in graph)
		return graph[_graph_make_weight(from, to)]
	return ""
}

#
#@ Description: Removes the weight for the edge from 'from' to 'to'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function graph_rm_weight(graph, from, to,    _weight) {

	if ((_weight = _graph_make_weight(from, to)) in graph)
		delete graph[_weight]
}
# </public>

# <private>
function _graph_make_weight(from, to) {

	return (_GRAPH_WEIGHT() from _GRAPH_SEP() to _GRAPH_SEP())
}

function _GRAPH_WEIGHT() {

	return "_weight\034"
}

function _GRAPH_SEP() {

	return "\034"
}

function _GRAPH_STRIP() {

	return "^\034|\034$"
}
# </private>

#@ </awklib_graph>
