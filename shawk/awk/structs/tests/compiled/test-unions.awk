# <structs-ent>
# structs:
#
# prefix ent
#
# union uA
# name type_a
# name type_b
#
# union uB
# name uA
# name type_c
#
# union uC
# name type_d
# name uB
#
# type type_a
# has x 
#
# type type_b
# has x 
#
# type type_c
# has x 
#
# type type_d
# has x 
#
# type testu
# # uC is type_d|type_a|type_b|type_c
# has x uC
#
# type type_no
# has x 
#
# <private>
function _ent_set(k, v) {_STRUCTS_ent_db[k] = v}
function _ent_get(k) {return _STRUCTS_ent_db[k]}
function _ent_type_chk(ent, texp) {
	if (ent_type_of(ent) ~ texp)
		return
	ent_errq(sprintf("entity '%s': expected type match '%s', entity type '%s'", 
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
# <type-type_a>
function ENT_TYPE_A() {return "type_a"}

function ent_type_a_make(x,     _ent) {
	_ent = ent_new("type_a")
	ent_type_a_set_x(_ent, x)
	return _ent
}

function ent_type_a_set_x(ent, x) {
	_ent_type_chk(ent, "^(type_a)$")
	_ent_set((ent ".x"), x)
}
function ent_type_a_get_x(ent) {
	_ent_type_chk(ent, "^(type_a)$")
	return _ent_get((ent ".x"))
}

# <\type-type_a>
# <type-type_b>
function ENT_TYPE_B() {return "type_b"}

function ent_type_b_make(x,     _ent) {
	_ent = ent_new("type_b")
	ent_type_b_set_x(_ent, x)
	return _ent
}

function ent_type_b_set_x(ent, x) {
	_ent_type_chk(ent, "^(type_b)$")
	_ent_set((ent ".x"), x)
}
function ent_type_b_get_x(ent) {
	_ent_type_chk(ent, "^(type_b)$")
	return _ent_get((ent ".x"))
}

# <\type-type_b>
# <type-type_c>
function ENT_TYPE_C() {return "type_c"}

function ent_type_c_make(x,     _ent) {
	_ent = ent_new("type_c")
	ent_type_c_set_x(_ent, x)
	return _ent
}

function ent_type_c_set_x(ent, x) {
	_ent_type_chk(ent, "^(type_c)$")
	_ent_set((ent ".x"), x)
}
function ent_type_c_get_x(ent) {
	_ent_type_chk(ent, "^(type_c)$")
	return _ent_get((ent ".x"))
}

# <\type-type_c>
# <type-type_d>
function ENT_TYPE_D() {return "type_d"}

function ent_type_d_make(x,     _ent) {
	_ent = ent_new("type_d")
	ent_type_d_set_x(_ent, x)
	return _ent
}

function ent_type_d_set_x(ent, x) {
	_ent_type_chk(ent, "^(type_d)$")
	_ent_set((ent ".x"), x)
}
function ent_type_d_get_x(ent) {
	_ent_type_chk(ent, "^(type_d)$")
	return _ent_get((ent ".x"))
}

# <\type-type_d>
# <type-testu>
function ENT_TESTU() {return "testu"}

function ent_testu_make(x,     _ent) {
	_ent = ent_new("testu")
	ent_testu_set_x(_ent, x)
	return _ent
}

function ent_testu_set_x(ent, x) {
	_ent_type_chk(ent, "^(testu)$")
	if (x)
		_ent_type_chk(x, "^(type_d|type_a|type_b|type_c)$")
	_ent_set((ent ".x"), x)
}
function ent_testu_get_x(ent) {
	_ent_type_chk(ent, "^(testu)$")
	return _ent_get((ent ".x"))
}

# <\type-testu>
# <type-type_no>
function ENT_TYPE_NO() {return "type_no"}

function ent_type_no_make(x,     _ent) {
	_ent = ent_new("type_no")
	ent_type_no_set_x(_ent, x)
	return _ent
}

function ent_type_no_set_x(ent, x) {
	_ent_type_chk(ent, "^(type_no)$")
	_ent_set((ent ".x"), x)
}
function ent_type_no_get_x(ent) {
	_ent_type_chk(ent, "^(type_no)$")
	return _ent_get((ent ".x"))
}

# <\type-type_no>
# <\types>
# <\structs-ent>
