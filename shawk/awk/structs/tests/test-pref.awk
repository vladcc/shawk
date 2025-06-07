# <structs-foo>
# structs:
#
# prefix foo
#
# type list
# has  head node
#
# type node
# has  data 
# has  next_ node
#
# <private>
function _foo_set(k, v) {_STRUCTS_foo_db[k] = v}
function _foo_get(k) {return _STRUCTS_foo_db[k]}
function _foo_type_chk(ent, texp) {
	if (foo_type_of(ent) == texp)
		return
	foo_errq(sprintf("entity '%s' expected type '%s', actual type '%s'", \
		 ent, texp, foo_type_of(ent)))
}
# <\private>

function foo_clear() {
	delete _STRUCTS_foo_db
	_foo_set("gen", _foo_get("gen")+1)
}
function foo_is(ent) {return (ent in _STRUCTS_foo_db)}
function foo_type_of(ent) {
	if (ent in _STRUCTS_foo_db)
		return _STRUCTS_foo_db[ent]
	foo_errq(sprintf("'%s' not an entity", ent))
}
function foo_new(type,    _ent) {
	_foo_set("ents", (_ent = _foo_get("ents")+1))
	_ent = ("_foo-" _foo_get("gen")+0 "-" _ent)
	_foo_set(_ent, type)
	return _ent
}
# <types>
# <type-list>
function FOO_LIST() {return "list"}

function foo_list_make(head,     _ent) {
	_ent = foo_new("list")
	foo_list_set_head(_ent, head)
	return _ent
}

function foo_list_set_head(ent, head) {
	_foo_type_chk(ent, "list")
	if (head)
		_foo_type_chk(head, "node")
	_foo_set(("head=" ent), head)
}
function foo_list_get_head(ent) {
	_foo_type_chk(ent, "list")
	return _foo_get(("head=" ent))
}

# <\type-list>
# <type-node>
function FOO_NODE() {return "node"}

function foo_node_make(data, next_,     _ent) {
	_ent = foo_new("node")
	foo_node_set_data(_ent, data)
	foo_node_set_next_(_ent, next_)
	return _ent
}

function foo_node_set_data(ent, data) {
	_foo_type_chk(ent, "node")
	_foo_set(("data=" ent), data)
}
function foo_node_get_data(ent) {
	_foo_type_chk(ent, "node")
	return _foo_get(("data=" ent))
}

function foo_node_set_next_(ent, next_) {
	_foo_type_chk(ent, "node")
	if (next_)
		_foo_type_chk(next_, "node")
	_foo_set(("next_=" ent), next_)
}
function foo_node_get_next_(ent) {
	_foo_type_chk(ent, "node")
	return _foo_get(("next_=" ent))
}

# <\type-node>
# <\types>
# <\structs-foo>
