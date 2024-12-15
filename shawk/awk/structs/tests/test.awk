# <structs-ent>
# structs:
#
# prefix ent
#
# type list
# has  head node
#
# type node
# has  data 
# has  next_ node
#
# <private>
function _ent_set(k, v) {_STRUCTS_ent_db[k] = v}
function _ent_get(k) {return _STRUCTS_ent_db[k]}
function _ent_type_chk(ent, texp) {
	if (ent_type_of(ent) == texp)
		return
	ent_errq(sprintf("entity '%s' expected type '%s', actual type '%s'", \
		 ent, texp, ent_type_of(ent)))
}
# <\private>

function ent_clear() {
	delete _STRUCTS_ent_db
	_ent_set("gen", _ent_get("gen")+1)
}
function ent_is(ent) {return (ent in _STRUCTS_ent_db)}
function ent_type_of(ent) {
	if (ent in _STRUCTS_ent_db)
		return _STRUCTS_ent_db[ent]
	ent_errq(sprintf("'%s' not an entity", ent))
}
function ent_new(type,    _ent) {
	_ent_set("ents", (_ent = _ent_get("ents")+1))
	_ent = ("_ent-" _ent_get("gen")+0 "-" _ent)
	_ent_set(_ent, type)
	return _ent
}
# <types>
# <type-list>
function ENT_LIST() {return "list"}

function ent_list_make(head,     _ent) {
	_ent = ent_new("list")
	ent_list_set_head(_ent, head)
	return _ent
}

function ent_list_set_head(ent, head) {
	_ent_type_chk(ent, "list")
	if (head)
		_ent_type_chk(head, "node")
	_ent_set(("head=" ent), head)
}
function ent_list_get_head(ent) {
	_ent_type_chk(ent, "list")
	return _ent_get(("head=" ent))
}

# <\type-list>
# <type-node>
function ENT_NODE() {return "node"}

function ent_node_make(data, next_,     _ent) {
	_ent = ent_new("node")
	ent_node_set_data(_ent, data)
	ent_node_set_next_(_ent, next_)
	return _ent
}

function ent_node_set_data(ent, data) {
	_ent_type_chk(ent, "node")
	_ent_set(("data=" ent), data)
}
function ent_node_get_data(ent) {
	_ent_type_chk(ent, "node")
	return _ent_get(("data=" ent))
}

function ent_node_set_next_(ent, next_) {
	_ent_type_chk(ent, "node")
	if (next_)
		_ent_type_chk(next_, "node")
	_ent_set(("next_=" ent), next_)
}
function ent_node_get_next_(ent) {
	_ent_type_chk(ent, "node")
	return _ent_get(("next_=" ent))
}

# <\type-node>
# <\types>
# <\structs-ent>
