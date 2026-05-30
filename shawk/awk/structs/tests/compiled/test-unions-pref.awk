# <structs-ast>
# structs:
#
# prefix ast
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
function _ast_set(k, v) {_STRUCTS_ast_db[k] = v}
function _ast_get(k) {return _STRUCTS_ast_db[k]}
function _ast_type_chk(ent, texp) {
	if (ast_type_of(ent) ~ texp)
		return
	ast_errq(sprintf("entity '%s': expected type match '%s', entity type '%s'", 
		 ent, texp, ast_type_of(ent)))
}
# <\private>

function ast_clear() {
	delete _STRUCTS_ast_db
	_ast_set("gen", _ast_get("gen")+1)
}
function ast_is(ent) {return (ent in _STRUCTS_ast_db)}
function ast_type_of(ent) {
	if (ent in _STRUCTS_ast_db)
		return _STRUCTS_ast_db[ent]
	ast_errq(sprintf("'%s' not an entity", ent))
}
function ast_new(type,    _ent) {
	_ast_set("ents", (_ent = _ast_get("ents")+1))
	_ent = ("_ast-" _ast_get("gen")+0 "-" _ent)
	_ast_set(_ent, type)
	return _ent
}
# <types>
# <type-type_a>
function AST_TYPE_A() {return "type_a"}

function ast_type_a_make(x,     _ent) {
	_ent = ast_new("type_a")
	ast_type_a_set_x(_ent, x)
	return _ent
}

function ast_type_a_set_x(ent, x) {
	_ast_type_chk(ent, "^(type_a)$")
	_ast_set((ent ".x"), x)
}
function ast_type_a_get_x(ent) {
	_ast_type_chk(ent, "^(type_a)$")
	return _ast_get((ent ".x"))
}

# <\type-type_a>
# <type-type_b>
function AST_TYPE_B() {return "type_b"}

function ast_type_b_make(x,     _ent) {
	_ent = ast_new("type_b")
	ast_type_b_set_x(_ent, x)
	return _ent
}

function ast_type_b_set_x(ent, x) {
	_ast_type_chk(ent, "^(type_b)$")
	_ast_set((ent ".x"), x)
}
function ast_type_b_get_x(ent) {
	_ast_type_chk(ent, "^(type_b)$")
	return _ast_get((ent ".x"))
}

# <\type-type_b>
# <type-type_c>
function AST_TYPE_C() {return "type_c"}

function ast_type_c_make(x,     _ent) {
	_ent = ast_new("type_c")
	ast_type_c_set_x(_ent, x)
	return _ent
}

function ast_type_c_set_x(ent, x) {
	_ast_type_chk(ent, "^(type_c)$")
	_ast_set((ent ".x"), x)
}
function ast_type_c_get_x(ent) {
	_ast_type_chk(ent, "^(type_c)$")
	return _ast_get((ent ".x"))
}

# <\type-type_c>
# <type-type_d>
function AST_TYPE_D() {return "type_d"}

function ast_type_d_make(x,     _ent) {
	_ent = ast_new("type_d")
	ast_type_d_set_x(_ent, x)
	return _ent
}

function ast_type_d_set_x(ent, x) {
	_ast_type_chk(ent, "^(type_d)$")
	_ast_set((ent ".x"), x)
}
function ast_type_d_get_x(ent) {
	_ast_type_chk(ent, "^(type_d)$")
	return _ast_get((ent ".x"))
}

# <\type-type_d>
# <type-testu>
function AST_TESTU() {return "testu"}

function ast_testu_make(x,     _ent) {
	_ent = ast_new("testu")
	ast_testu_set_x(_ent, x)
	return _ent
}

function ast_testu_set_x(ent, x) {
	_ast_type_chk(ent, "^(testu)$")
	if (x)
		_ast_type_chk(x, "^(type_d|type_a|type_b|type_c)$")
	_ast_set((ent ".x"), x)
}
function ast_testu_get_x(ent) {
	_ast_type_chk(ent, "^(testu)$")
	return _ast_get((ent ".x"))
}

# <\type-testu>
# <type-type_no>
function AST_TYPE_NO() {return "type_no"}

function ast_type_no_make(x,     _ent) {
	_ent = ast_new("type_no")
	ast_type_no_set_x(_ent, x)
	return _ent
}

function ast_type_no_set_x(ent, x) {
	_ast_type_chk(ent, "^(type_no)$")
	_ast_set((ent ".x"), x)
}
function ast_type_no_get_x(ent) {
	_ast_type_chk(ent, "^(type_no)$")
	return _ast_get((ent ".x"))
}

# <\type-type_no>
# <\types>
# <\structs-ast>
