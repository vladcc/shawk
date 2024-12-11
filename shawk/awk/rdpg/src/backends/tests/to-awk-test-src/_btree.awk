# <structs-ast>
# structs:
#
# type node
# has  left 
# has  right 
#
# type num
# has  num 
# has  node node
#
# type op
# has  op 
# has  node node
#
# <private>
function _ast_set(k, v) {_STRUCTS_ast_db[k] = v}
function _ast_get(k) {return _STRUCTS_ast_db[k]}
function _ast_type_chk(ent, texp) {
	if (ast_type_of(ent) == texp)
		return
	ast_errq(sprintf("entity '%s' expected type '%s', actual type '%s'", \
		 ent, texp, ast_type_of(ent)))
}
# <\private>

function ast_clear() {delete _STRUCTS_ast_db}
function ast_is(ent) {return (ent in _STRUCTS_ast_db)}
function ast_type_of(ent) {
	if (ent in _STRUCTS_ast_db)
		return _STRUCTS_ast_db[ent]
	ast_errq(sprintf("'%s' not an entity", ent))
}
function ast_new(type,    _ent) {
		_ast_set("ents", (_ent = _ast_get("ents")+1))
	_ent = ("_n" _ent)
	_ast_set(_ent, type)
	return _ent
}
# <types>
# <type-node>
function AST_NODE() {return "node"}

function ast_node_make(left, right,     _ent) {
	_ent = ast_new("node")
	ast_node_set_left(_ent, left)
	ast_node_set_right(_ent, right)
	return _ent
}

function ast_node_set_left(ent, left) {
	_ast_type_chk(ent, "node")
	_ast_set(("left=" ent), left)
}
function ast_node_get_left(ent) {
	_ast_type_chk(ent, "node")
	return _ast_get(("left=" ent))
}

function ast_node_set_right(ent, right) {
	_ast_type_chk(ent, "node")
	_ast_set(("right=" ent), right)
}
function ast_node_get_right(ent) {
	_ast_type_chk(ent, "node")
	return _ast_get(("right=" ent))
}

# <\type-node>
# <type-num>
function AST_NUM() {return "num"}

function ast_num_make(num, node,     _ent) {
	_ent = ast_new("num")
	ast_num_set_num(_ent, num)
	ast_num_set_node(_ent, node)
	return _ent
}

function ast_num_set_num(ent, num) {
	_ast_type_chk(ent, "num")
	_ast_set(("num=" ent), num)
}
function ast_num_get_num(ent) {
	_ast_type_chk(ent, "num")
	return _ast_get(("num=" ent))
}

function ast_num_set_node(ent, node) {
	_ast_type_chk(ent, "num")
	if (node)
		_ast_type_chk(node, "node")
	_ast_set(("node=" ent), node)
}
function ast_num_get_node(ent) {
	_ast_type_chk(ent, "num")
	return _ast_get(("node=" ent))
}

# <\type-num>
# <type-op>
function AST_OP() {return "op"}

function ast_op_make(op, node,     _ent) {
	_ent = ast_new("op")
	ast_op_set_op(_ent, op)
	ast_op_set_node(_ent, node)
	return _ent
}

function ast_op_set_op(ent, op) {
	_ast_type_chk(ent, "op")
	_ast_set(("op=" ent), op)
}
function ast_op_get_op(ent) {
	_ast_type_chk(ent, "op")
	return _ast_get(("op=" ent))
}

function ast_op_set_node(ent, node) {
	_ast_type_chk(ent, "op")
	if (node)
		_ast_type_chk(node, "node")
	_ast_set(("node=" ent), node)
}
function ast_op_get_node(ent) {
	_ast_type_chk(ent, "op")
	return _ast_get(("node=" ent))
}

# <\type-op>
# <\types>
# <\structs-ast>
