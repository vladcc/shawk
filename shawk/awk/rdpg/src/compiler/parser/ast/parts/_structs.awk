# <structs-ast>
# structs:
#
# type start
# has  top_nont 
# has  mod 
# has  eoi_term 
# has  line_num 
# has  lhs_lst lhs_lst
#
# type lhs_lst
# has  head lhs
# has  tail lhs
#
# type lhs
# has  name 
# has  line_num 
# has  rule_lst rule_lst
# has  next_ lhs
#
# type rule_lst
# has  head rule
# has  tail rule
#
# type rule
# has  esc_lst esc_lst
# has  sym_lst sym_lst
# has  next_ rule
#
# type sym_lst
# has  head sym
# has  tail sym
#
# type sym
# has  type 
# has  name 
# has  mod 
# has  esc_lst esc_lst
# has  next_ sym
#
# type esc_lst
# has  head esc
# has  tail esc
#
# type esc
# has  name 
# has  next_ esc
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
# <type-start>
function AST_START() {return "start"}

function ast_start_make(top_nont, mod, eoi_term, line_num, lhs_lst,     _ent) {
	_ent = ast_new("start")
	ast_start_set_top_nont(_ent, top_nont)
	ast_start_set_mod(_ent, mod)
	ast_start_set_eoi_term(_ent, eoi_term)
	ast_start_set_line_num(_ent, line_num)
	ast_start_set_lhs_lst(_ent, lhs_lst)
	return _ent
}

function ast_start_set_top_nont(ent, top_nont) {
	_ast_type_chk(ent, "start")
	_ast_set(("top_nont=" ent), top_nont)
}
function ast_start_get_top_nont(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("top_nont=" ent))
}

function ast_start_set_mod(ent, mod) {
	_ast_type_chk(ent, "start")
	_ast_set(("mod=" ent), mod)
}
function ast_start_get_mod(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("mod=" ent))
}

function ast_start_set_eoi_term(ent, eoi_term) {
	_ast_type_chk(ent, "start")
	_ast_set(("eoi_term=" ent), eoi_term)
}
function ast_start_get_eoi_term(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("eoi_term=" ent))
}

function ast_start_set_line_num(ent, line_num) {
	_ast_type_chk(ent, "start")
	_ast_set(("line_num=" ent), line_num)
}
function ast_start_get_line_num(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("line_num=" ent))
}

function ast_start_set_lhs_lst(ent, lhs_lst) {
	_ast_type_chk(ent, "start")
	if (lhs_lst)
		_ast_type_chk(lhs_lst, "lhs_lst")
	_ast_set(("lhs_lst=" ent), lhs_lst)
}
function ast_start_get_lhs_lst(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("lhs_lst=" ent))
}

# <\type-start>
# <type-lhs_lst>
function AST_LHS_LST() {return "lhs_lst"}

function ast_lhs_lst_make(head, tail,     _ent) {
	_ent = ast_new("lhs_lst")
	ast_lhs_lst_set_head(_ent, head)
	ast_lhs_lst_set_tail(_ent, tail)
	return _ent
}

function ast_lhs_lst_set_head(ent, head) {
	_ast_type_chk(ent, "lhs_lst")
	if (head)
		_ast_type_chk(head, "lhs")
	_ast_set(("head=" ent), head)
}
function ast_lhs_lst_get_head(ent) {
	_ast_type_chk(ent, "lhs_lst")
	return _ast_get(("head=" ent))
}

function ast_lhs_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "lhs_lst")
	if (tail)
		_ast_type_chk(tail, "lhs")
	_ast_set(("tail=" ent), tail)
}
function ast_lhs_lst_get_tail(ent) {
	_ast_type_chk(ent, "lhs_lst")
	return _ast_get(("tail=" ent))
}

# <\type-lhs_lst>
# <type-lhs>
function AST_LHS() {return "lhs"}

function ast_lhs_make(name, line_num, rule_lst, next_,     _ent) {
	_ent = ast_new("lhs")
	ast_lhs_set_name(_ent, name)
	ast_lhs_set_line_num(_ent, line_num)
	ast_lhs_set_rule_lst(_ent, rule_lst)
	ast_lhs_set_next_(_ent, next_)
	return _ent
}

function ast_lhs_set_name(ent, name) {
	_ast_type_chk(ent, "lhs")
	_ast_set(("name=" ent), name)
}
function ast_lhs_get_name(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("name=" ent))
}

function ast_lhs_set_line_num(ent, line_num) {
	_ast_type_chk(ent, "lhs")
	_ast_set(("line_num=" ent), line_num)
}
function ast_lhs_get_line_num(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("line_num=" ent))
}

function ast_lhs_set_rule_lst(ent, rule_lst) {
	_ast_type_chk(ent, "lhs")
	if (rule_lst)
		_ast_type_chk(rule_lst, "rule_lst")
	_ast_set(("rule_lst=" ent), rule_lst)
}
function ast_lhs_get_rule_lst(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("rule_lst=" ent))
}

function ast_lhs_set_next_(ent, next_) {
	_ast_type_chk(ent, "lhs")
	if (next_)
		_ast_type_chk(next_, "lhs")
	_ast_set(("next_=" ent), next_)
}
function ast_lhs_get_next_(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("next_=" ent))
}

# <\type-lhs>
# <type-rule_lst>
function AST_RULE_LST() {return "rule_lst"}

function ast_rule_lst_make(head, tail,     _ent) {
	_ent = ast_new("rule_lst")
	ast_rule_lst_set_head(_ent, head)
	ast_rule_lst_set_tail(_ent, tail)
	return _ent
}

function ast_rule_lst_set_head(ent, head) {
	_ast_type_chk(ent, "rule_lst")
	if (head)
		_ast_type_chk(head, "rule")
	_ast_set(("head=" ent), head)
}
function ast_rule_lst_get_head(ent) {
	_ast_type_chk(ent, "rule_lst")
	return _ast_get(("head=" ent))
}

function ast_rule_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "rule_lst")
	if (tail)
		_ast_type_chk(tail, "rule")
	_ast_set(("tail=" ent), tail)
}
function ast_rule_lst_get_tail(ent) {
	_ast_type_chk(ent, "rule_lst")
	return _ast_get(("tail=" ent))
}

# <\type-rule_lst>
# <type-rule>
function AST_RULE() {return "rule"}

function ast_rule_make(esc_lst, sym_lst, next_,     _ent) {
	_ent = ast_new("rule")
	ast_rule_set_esc_lst(_ent, esc_lst)
	ast_rule_set_sym_lst(_ent, sym_lst)
	ast_rule_set_next_(_ent, next_)
	return _ent
}

function ast_rule_set_esc_lst(ent, esc_lst) {
	_ast_type_chk(ent, "rule")
	if (esc_lst)
		_ast_type_chk(esc_lst, "esc_lst")
	_ast_set(("esc_lst=" ent), esc_lst)
}
function ast_rule_get_esc_lst(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("esc_lst=" ent))
}

function ast_rule_set_sym_lst(ent, sym_lst) {
	_ast_type_chk(ent, "rule")
	if (sym_lst)
		_ast_type_chk(sym_lst, "sym_lst")
	_ast_set(("sym_lst=" ent), sym_lst)
}
function ast_rule_get_sym_lst(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("sym_lst=" ent))
}

function ast_rule_set_next_(ent, next_) {
	_ast_type_chk(ent, "rule")
	if (next_)
		_ast_type_chk(next_, "rule")
	_ast_set(("next_=" ent), next_)
}
function ast_rule_get_next_(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("next_=" ent))
}

# <\type-rule>
# <type-sym_lst>
function AST_SYM_LST() {return "sym_lst"}

function ast_sym_lst_make(head, tail,     _ent) {
	_ent = ast_new("sym_lst")
	ast_sym_lst_set_head(_ent, head)
	ast_sym_lst_set_tail(_ent, tail)
	return _ent
}

function ast_sym_lst_set_head(ent, head) {
	_ast_type_chk(ent, "sym_lst")
	if (head)
		_ast_type_chk(head, "sym")
	_ast_set(("head=" ent), head)
}
function ast_sym_lst_get_head(ent) {
	_ast_type_chk(ent, "sym_lst")
	return _ast_get(("head=" ent))
}

function ast_sym_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "sym_lst")
	if (tail)
		_ast_type_chk(tail, "sym")
	_ast_set(("tail=" ent), tail)
}
function ast_sym_lst_get_tail(ent) {
	_ast_type_chk(ent, "sym_lst")
	return _ast_get(("tail=" ent))
}

# <\type-sym_lst>
# <type-sym>
function AST_SYM() {return "sym"}

function ast_sym_make(type, name, mod, esc_lst, next_,     _ent) {
	_ent = ast_new("sym")
	ast_sym_set_type(_ent, type)
	ast_sym_set_name(_ent, name)
	ast_sym_set_mod(_ent, mod)
	ast_sym_set_esc_lst(_ent, esc_lst)
	ast_sym_set_next_(_ent, next_)
	return _ent
}

function ast_sym_set_type(ent, type) {
	_ast_type_chk(ent, "sym")
	_ast_set(("type=" ent), type)
}
function ast_sym_get_type(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("type=" ent))
}

function ast_sym_set_name(ent, name) {
	_ast_type_chk(ent, "sym")
	_ast_set(("name=" ent), name)
}
function ast_sym_get_name(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("name=" ent))
}

function ast_sym_set_mod(ent, mod) {
	_ast_type_chk(ent, "sym")
	_ast_set(("mod=" ent), mod)
}
function ast_sym_get_mod(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("mod=" ent))
}

function ast_sym_set_esc_lst(ent, esc_lst) {
	_ast_type_chk(ent, "sym")
	if (esc_lst)
		_ast_type_chk(esc_lst, "esc_lst")
	_ast_set(("esc_lst=" ent), esc_lst)
}
function ast_sym_get_esc_lst(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("esc_lst=" ent))
}

function ast_sym_set_next_(ent, next_) {
	_ast_type_chk(ent, "sym")
	if (next_)
		_ast_type_chk(next_, "sym")
	_ast_set(("next_=" ent), next_)
}
function ast_sym_get_next_(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("next_=" ent))
}

# <\type-sym>
# <type-esc_lst>
function AST_ESC_LST() {return "esc_lst"}

function ast_esc_lst_make(head, tail,     _ent) {
	_ent = ast_new("esc_lst")
	ast_esc_lst_set_head(_ent, head)
	ast_esc_lst_set_tail(_ent, tail)
	return _ent
}

function ast_esc_lst_set_head(ent, head) {
	_ast_type_chk(ent, "esc_lst")
	if (head)
		_ast_type_chk(head, "esc")
	_ast_set(("head=" ent), head)
}
function ast_esc_lst_get_head(ent) {
	_ast_type_chk(ent, "esc_lst")
	return _ast_get(("head=" ent))
}

function ast_esc_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "esc_lst")
	if (tail)
		_ast_type_chk(tail, "esc")
	_ast_set(("tail=" ent), tail)
}
function ast_esc_lst_get_tail(ent) {
	_ast_type_chk(ent, "esc_lst")
	return _ast_get(("tail=" ent))
}

# <\type-esc_lst>
# <type-esc>
function AST_ESC() {return "esc"}

function ast_esc_make(name, next_,     _ent) {
	_ent = ast_new("esc")
	ast_esc_set_name(_ent, name)
	ast_esc_set_next_(_ent, next_)
	return _ent
}

function ast_esc_set_name(ent, name) {
	_ast_type_chk(ent, "esc")
	_ast_set(("name=" ent), name)
}
function ast_esc_get_name(ent) {
	_ast_type_chk(ent, "esc")
	return _ast_get(("name=" ent))
}

function ast_esc_set_next_(ent, next_) {
	_ast_type_chk(ent, "esc")
	if (next_)
		_ast_type_chk(next_, "esc")
	_ast_set(("next_=" ent), next_)
}
function ast_esc_get_next_(ent) {
	_ast_type_chk(ent, "esc")
	return _ast_get(("next_=" ent))
}

# <\type-esc>
# <\types>
# <\structs-ast>
