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
