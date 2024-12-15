# <ast>
# <structs-ast>
# structs:
#
# prefix ast
#
# type root_node
# has  cmnt_lst cmnt_lst
# has  tokens tokens
#
# type cmnt_lst
# has  head comment
# has  tail comment
#
# type comment
# has  str 
# has  next_ comment
#
# type tokens
# has  all_tok 
# has  tok_eoi 
# has  sets sets
#
# type sets
# has  alias_lst alias_lst
# has  set_lst set_lst
# has  parse_main parse_main
#
# type alias_lst
# has  head alias
# has  tail alias
#
# type alias
# has  name 
# has  data 
# has  next_ alias
#
# type set_lst
# has  head set
# has  tail set
#
# type set
# has  type 
# has  name 
# has  alias_name 
# has  next_ set
#
# type parse_main
# has  name 
# has  top_nont 
# has  err_var 
# has  fnc_lst fnc_lst
#
# type fnc_lst
# has  head fnc
# has  tail fnc
#
# type fnc
# has  name 
# has  cmnt_lst cmnt_lst
# has  code_lst code_lst
# has  next_ fnc
#
# type code_lst
# has  head code_node
# has  tail code_node
#
# type code_node
# has  code 
# has  next_ code_node
#
# type code_call
# has  is_esc 
# has  fname 
# has  arg 
#
# type code_ret
# has  const 
# has  call code_call
#
# type code_loop
# has  code_lst code_lst
#
# type code_continue
# has  none 
#
# type code_if
# has  cond code_call
# has  code_lst code_lst
#
# type code_else_if
# has  cond code_call
# has  code_lst code_lst
#
# type code_else
# has  code_lst code_lst
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

function ast_clear() {
	delete _STRUCTS_ast_db
	_ent_set("gen", _ent_get("gen")+1)
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
# <type-root_node>
function AST_ROOT_NODE() {return "root_node"}

function ast_root_node_make(cmnt_lst, tokens,     _ent) {
	_ent = ast_new("root_node")
	ast_root_node_set_cmnt_lst(_ent, cmnt_lst)
	ast_root_node_set_tokens(_ent, tokens)
	return _ent
}

function ast_root_node_set_cmnt_lst(ent, cmnt_lst) {
	_ast_type_chk(ent, "root_node")
	if (cmnt_lst)
		_ast_type_chk(cmnt_lst, "cmnt_lst")
	_ast_set(("cmnt_lst=" ent), cmnt_lst)
}
function ast_root_node_get_cmnt_lst(ent) {
	_ast_type_chk(ent, "root_node")
	return _ast_get(("cmnt_lst=" ent))
}

function ast_root_node_set_tokens(ent, tokens) {
	_ast_type_chk(ent, "root_node")
	if (tokens)
		_ast_type_chk(tokens, "tokens")
	_ast_set(("tokens=" ent), tokens)
}
function ast_root_node_get_tokens(ent) {
	_ast_type_chk(ent, "root_node")
	return _ast_get(("tokens=" ent))
}

# <\type-root_node>
# <type-cmnt_lst>
function AST_CMNT_LST() {return "cmnt_lst"}

function ast_cmnt_lst_make(head, tail,     _ent) {
	_ent = ast_new("cmnt_lst")
	ast_cmnt_lst_set_head(_ent, head)
	ast_cmnt_lst_set_tail(_ent, tail)
	return _ent
}

function ast_cmnt_lst_set_head(ent, head) {
	_ast_type_chk(ent, "cmnt_lst")
	if (head)
		_ast_type_chk(head, "comment")
	_ast_set(("head=" ent), head)
}
function ast_cmnt_lst_get_head(ent) {
	_ast_type_chk(ent, "cmnt_lst")
	return _ast_get(("head=" ent))
}

function ast_cmnt_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "cmnt_lst")
	if (tail)
		_ast_type_chk(tail, "comment")
	_ast_set(("tail=" ent), tail)
}
function ast_cmnt_lst_get_tail(ent) {
	_ast_type_chk(ent, "cmnt_lst")
	return _ast_get(("tail=" ent))
}

# <\type-cmnt_lst>
# <type-comment>
function AST_COMMENT() {return "comment"}

function ast_comment_make(str, next_,     _ent) {
	_ent = ast_new("comment")
	ast_comment_set_str(_ent, str)
	ast_comment_set_next_(_ent, next_)
	return _ent
}

function ast_comment_set_str(ent, str) {
	_ast_type_chk(ent, "comment")
	_ast_set(("str=" ent), str)
}
function ast_comment_get_str(ent) {
	_ast_type_chk(ent, "comment")
	return _ast_get(("str=" ent))
}

function ast_comment_set_next_(ent, next_) {
	_ast_type_chk(ent, "comment")
	if (next_)
		_ast_type_chk(next_, "comment")
	_ast_set(("next_=" ent), next_)
}
function ast_comment_get_next_(ent) {
	_ast_type_chk(ent, "comment")
	return _ast_get(("next_=" ent))
}

# <\type-comment>
# <type-tokens>
function AST_TOKENS() {return "tokens"}

function ast_tokens_make(all_tok, tok_eoi, sets,     _ent) {
	_ent = ast_new("tokens")
	ast_tokens_set_all_tok(_ent, all_tok)
	ast_tokens_set_tok_eoi(_ent, tok_eoi)
	ast_tokens_set_sets(_ent, sets)
	return _ent
}

function ast_tokens_set_all_tok(ent, all_tok) {
	_ast_type_chk(ent, "tokens")
	_ast_set(("all_tok=" ent), all_tok)
}
function ast_tokens_get_all_tok(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("all_tok=" ent))
}

function ast_tokens_set_tok_eoi(ent, tok_eoi) {
	_ast_type_chk(ent, "tokens")
	_ast_set(("tok_eoi=" ent), tok_eoi)
}
function ast_tokens_get_tok_eoi(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("tok_eoi=" ent))
}

function ast_tokens_set_sets(ent, sets) {
	_ast_type_chk(ent, "tokens")
	if (sets)
		_ast_type_chk(sets, "sets")
	_ast_set(("sets=" ent), sets)
}
function ast_tokens_get_sets(ent) {
	_ast_type_chk(ent, "tokens")
	return _ast_get(("sets=" ent))
}

# <\type-tokens>
# <type-sets>
function AST_SETS() {return "sets"}

function ast_sets_make(alias_lst, set_lst, parse_main,     _ent) {
	_ent = ast_new("sets")
	ast_sets_set_alias_lst(_ent, alias_lst)
	ast_sets_set_set_lst(_ent, set_lst)
	ast_sets_set_parse_main(_ent, parse_main)
	return _ent
}

function ast_sets_set_alias_lst(ent, alias_lst) {
	_ast_type_chk(ent, "sets")
	if (alias_lst)
		_ast_type_chk(alias_lst, "alias_lst")
	_ast_set(("alias_lst=" ent), alias_lst)
}
function ast_sets_get_alias_lst(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("alias_lst=" ent))
}

function ast_sets_set_set_lst(ent, set_lst) {
	_ast_type_chk(ent, "sets")
	if (set_lst)
		_ast_type_chk(set_lst, "set_lst")
	_ast_set(("set_lst=" ent), set_lst)
}
function ast_sets_get_set_lst(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("set_lst=" ent))
}

function ast_sets_set_parse_main(ent, parse_main) {
	_ast_type_chk(ent, "sets")
	if (parse_main)
		_ast_type_chk(parse_main, "parse_main")
	_ast_set(("parse_main=" ent), parse_main)
}
function ast_sets_get_parse_main(ent) {
	_ast_type_chk(ent, "sets")
	return _ast_get(("parse_main=" ent))
}

# <\type-sets>
# <type-alias_lst>
function AST_ALIAS_LST() {return "alias_lst"}

function ast_alias_lst_make(head, tail,     _ent) {
	_ent = ast_new("alias_lst")
	ast_alias_lst_set_head(_ent, head)
	ast_alias_lst_set_tail(_ent, tail)
	return _ent
}

function ast_alias_lst_set_head(ent, head) {
	_ast_type_chk(ent, "alias_lst")
	if (head)
		_ast_type_chk(head, "alias")
	_ast_set(("head=" ent), head)
}
function ast_alias_lst_get_head(ent) {
	_ast_type_chk(ent, "alias_lst")
	return _ast_get(("head=" ent))
}

function ast_alias_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "alias_lst")
	if (tail)
		_ast_type_chk(tail, "alias")
	_ast_set(("tail=" ent), tail)
}
function ast_alias_lst_get_tail(ent) {
	_ast_type_chk(ent, "alias_lst")
	return _ast_get(("tail=" ent))
}

# <\type-alias_lst>
# <type-alias>
function AST_ALIAS() {return "alias"}

function ast_alias_make(name, data, next_,     _ent) {
	_ent = ast_new("alias")
	ast_alias_set_name(_ent, name)
	ast_alias_set_data(_ent, data)
	ast_alias_set_next_(_ent, next_)
	return _ent
}

function ast_alias_set_name(ent, name) {
	_ast_type_chk(ent, "alias")
	_ast_set(("name=" ent), name)
}
function ast_alias_get_name(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("name=" ent))
}

function ast_alias_set_data(ent, data) {
	_ast_type_chk(ent, "alias")
	_ast_set(("data=" ent), data)
}
function ast_alias_get_data(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("data=" ent))
}

function ast_alias_set_next_(ent, next_) {
	_ast_type_chk(ent, "alias")
	if (next_)
		_ast_type_chk(next_, "alias")
	_ast_set(("next_=" ent), next_)
}
function ast_alias_get_next_(ent) {
	_ast_type_chk(ent, "alias")
	return _ast_get(("next_=" ent))
}

# <\type-alias>
# <type-set_lst>
function AST_SET_LST() {return "set_lst"}

function ast_set_lst_make(head, tail,     _ent) {
	_ent = ast_new("set_lst")
	ast_set_lst_set_head(_ent, head)
	ast_set_lst_set_tail(_ent, tail)
	return _ent
}

function ast_set_lst_set_head(ent, head) {
	_ast_type_chk(ent, "set_lst")
	if (head)
		_ast_type_chk(head, "set")
	_ast_set(("head=" ent), head)
}
function ast_set_lst_get_head(ent) {
	_ast_type_chk(ent, "set_lst")
	return _ast_get(("head=" ent))
}

function ast_set_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "set_lst")
	if (tail)
		_ast_type_chk(tail, "set")
	_ast_set(("tail=" ent), tail)
}
function ast_set_lst_get_tail(ent) {
	_ast_type_chk(ent, "set_lst")
	return _ast_get(("tail=" ent))
}

# <\type-set_lst>
# <type-set>
function AST_SET() {return "set"}

function ast_set_make(type, name, alias_name, next_,     _ent) {
	_ent = ast_new("set")
	ast_set_set_type(_ent, type)
	ast_set_set_name(_ent, name)
	ast_set_set_alias_name(_ent, alias_name)
	ast_set_set_next_(_ent, next_)
	return _ent
}

function ast_set_set_type(ent, type) {
	_ast_type_chk(ent, "set")
	_ast_set(("type=" ent), type)
}
function ast_set_get_type(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("type=" ent))
}

function ast_set_set_name(ent, name) {
	_ast_type_chk(ent, "set")
	_ast_set(("name=" ent), name)
}
function ast_set_get_name(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("name=" ent))
}

function ast_set_set_alias_name(ent, alias_name) {
	_ast_type_chk(ent, "set")
	_ast_set(("alias_name=" ent), alias_name)
}
function ast_set_get_alias_name(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("alias_name=" ent))
}

function ast_set_set_next_(ent, next_) {
	_ast_type_chk(ent, "set")
	if (next_)
		_ast_type_chk(next_, "set")
	_ast_set(("next_=" ent), next_)
}
function ast_set_get_next_(ent) {
	_ast_type_chk(ent, "set")
	return _ast_get(("next_=" ent))
}

# <\type-set>
# <type-parse_main>
function AST_PARSE_MAIN() {return "parse_main"}

function ast_parse_main_make(name, top_nont, err_var, fnc_lst,     _ent) {
	_ent = ast_new("parse_main")
	ast_parse_main_set_name(_ent, name)
	ast_parse_main_set_top_nont(_ent, top_nont)
	ast_parse_main_set_err_var(_ent, err_var)
	ast_parse_main_set_fnc_lst(_ent, fnc_lst)
	return _ent
}

function ast_parse_main_set_name(ent, name) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("name=" ent), name)
}
function ast_parse_main_get_name(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("name=" ent))
}

function ast_parse_main_set_top_nont(ent, top_nont) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("top_nont=" ent), top_nont)
}
function ast_parse_main_get_top_nont(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("top_nont=" ent))
}

function ast_parse_main_set_err_var(ent, err_var) {
	_ast_type_chk(ent, "parse_main")
	_ast_set(("err_var=" ent), err_var)
}
function ast_parse_main_get_err_var(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("err_var=" ent))
}

function ast_parse_main_set_fnc_lst(ent, fnc_lst) {
	_ast_type_chk(ent, "parse_main")
	if (fnc_lst)
		_ast_type_chk(fnc_lst, "fnc_lst")
	_ast_set(("fnc_lst=" ent), fnc_lst)
}
function ast_parse_main_get_fnc_lst(ent) {
	_ast_type_chk(ent, "parse_main")
	return _ast_get(("fnc_lst=" ent))
}

# <\type-parse_main>
# <type-fnc_lst>
function AST_FNC_LST() {return "fnc_lst"}

function ast_fnc_lst_make(head, tail,     _ent) {
	_ent = ast_new("fnc_lst")
	ast_fnc_lst_set_head(_ent, head)
	ast_fnc_lst_set_tail(_ent, tail)
	return _ent
}

function ast_fnc_lst_set_head(ent, head) {
	_ast_type_chk(ent, "fnc_lst")
	if (head)
		_ast_type_chk(head, "fnc")
	_ast_set(("head=" ent), head)
}
function ast_fnc_lst_get_head(ent) {
	_ast_type_chk(ent, "fnc_lst")
	return _ast_get(("head=" ent))
}

function ast_fnc_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "fnc_lst")
	if (tail)
		_ast_type_chk(tail, "fnc")
	_ast_set(("tail=" ent), tail)
}
function ast_fnc_lst_get_tail(ent) {
	_ast_type_chk(ent, "fnc_lst")
	return _ast_get(("tail=" ent))
}

# <\type-fnc_lst>
# <type-fnc>
function AST_FNC() {return "fnc"}

function ast_fnc_make(name, cmnt_lst, code_lst, next_,     _ent) {
	_ent = ast_new("fnc")
	ast_fnc_set_name(_ent, name)
	ast_fnc_set_cmnt_lst(_ent, cmnt_lst)
	ast_fnc_set_code_lst(_ent, code_lst)
	ast_fnc_set_next_(_ent, next_)
	return _ent
}

function ast_fnc_set_name(ent, name) {
	_ast_type_chk(ent, "fnc")
	_ast_set(("name=" ent), name)
}
function ast_fnc_get_name(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("name=" ent))
}

function ast_fnc_set_cmnt_lst(ent, cmnt_lst) {
	_ast_type_chk(ent, "fnc")
	if (cmnt_lst)
		_ast_type_chk(cmnt_lst, "cmnt_lst")
	_ast_set(("cmnt_lst=" ent), cmnt_lst)
}
function ast_fnc_get_cmnt_lst(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("cmnt_lst=" ent))
}

function ast_fnc_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "fnc")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_fnc_get_code_lst(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("code_lst=" ent))
}

function ast_fnc_set_next_(ent, next_) {
	_ast_type_chk(ent, "fnc")
	if (next_)
		_ast_type_chk(next_, "fnc")
	_ast_set(("next_=" ent), next_)
}
function ast_fnc_get_next_(ent) {
	_ast_type_chk(ent, "fnc")
	return _ast_get(("next_=" ent))
}

# <\type-fnc>
# <type-code_lst>
function AST_CODE_LST() {return "code_lst"}

function ast_code_lst_make(head, tail,     _ent) {
	_ent = ast_new("code_lst")
	ast_code_lst_set_head(_ent, head)
	ast_code_lst_set_tail(_ent, tail)
	return _ent
}

function ast_code_lst_set_head(ent, head) {
	_ast_type_chk(ent, "code_lst")
	if (head)
		_ast_type_chk(head, "code_node")
	_ast_set(("head=" ent), head)
}
function ast_code_lst_get_head(ent) {
	_ast_type_chk(ent, "code_lst")
	return _ast_get(("head=" ent))
}

function ast_code_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "code_lst")
	if (tail)
		_ast_type_chk(tail, "code_node")
	_ast_set(("tail=" ent), tail)
}
function ast_code_lst_get_tail(ent) {
	_ast_type_chk(ent, "code_lst")
	return _ast_get(("tail=" ent))
}

# <\type-code_lst>
# <type-code_node>
function AST_CODE_NODE() {return "code_node"}

function ast_code_node_make(code, next_,     _ent) {
	_ent = ast_new("code_node")
	ast_code_node_set_code(_ent, code)
	ast_code_node_set_next_(_ent, next_)
	return _ent
}

function ast_code_node_set_code(ent, code) {
	_ast_type_chk(ent, "code_node")
	_ast_set(("code=" ent), code)
}
function ast_code_node_get_code(ent) {
	_ast_type_chk(ent, "code_node")
	return _ast_get(("code=" ent))
}

function ast_code_node_set_next_(ent, next_) {
	_ast_type_chk(ent, "code_node")
	if (next_)
		_ast_type_chk(next_, "code_node")
	_ast_set(("next_=" ent), next_)
}
function ast_code_node_get_next_(ent) {
	_ast_type_chk(ent, "code_node")
	return _ast_get(("next_=" ent))
}

# <\type-code_node>
# <type-code_call>
function AST_CODE_CALL() {return "code_call"}

function ast_code_call_make(is_esc, fname, arg,     _ent) {
	_ent = ast_new("code_call")
	ast_code_call_set_is_esc(_ent, is_esc)
	ast_code_call_set_fname(_ent, fname)
	ast_code_call_set_arg(_ent, arg)
	return _ent
}

function ast_code_call_set_is_esc(ent, is_esc) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("is_esc=" ent), is_esc)
}
function ast_code_call_get_is_esc(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("is_esc=" ent))
}

function ast_code_call_set_fname(ent, fname) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("fname=" ent), fname)
}
function ast_code_call_get_fname(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("fname=" ent))
}

function ast_code_call_set_arg(ent, arg) {
	_ast_type_chk(ent, "code_call")
	_ast_set(("arg=" ent), arg)
}
function ast_code_call_get_arg(ent) {
	_ast_type_chk(ent, "code_call")
	return _ast_get(("arg=" ent))
}

# <\type-code_call>
# <type-code_ret>
function AST_CODE_RET() {return "code_ret"}

function ast_code_ret_make(const, call,     _ent) {
	_ent = ast_new("code_ret")
	ast_code_ret_set_const(_ent, const)
	ast_code_ret_set_call(_ent, call)
	return _ent
}

function ast_code_ret_set_const(ent, const) {
	_ast_type_chk(ent, "code_ret")
	_ast_set(("const=" ent), const)
}
function ast_code_ret_get_const(ent) {
	_ast_type_chk(ent, "code_ret")
	return _ast_get(("const=" ent))
}

function ast_code_ret_set_call(ent, call) {
	_ast_type_chk(ent, "code_ret")
	if (call)
		_ast_type_chk(call, "code_call")
	_ast_set(("call=" ent), call)
}
function ast_code_ret_get_call(ent) {
	_ast_type_chk(ent, "code_ret")
	return _ast_get(("call=" ent))
}

# <\type-code_ret>
# <type-code_loop>
function AST_CODE_LOOP() {return "code_loop"}

function ast_code_loop_make(code_lst,     _ent) {
	_ent = ast_new("code_loop")
	ast_code_loop_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_loop_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_loop")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_loop_get_code_lst(ent) {
	_ast_type_chk(ent, "code_loop")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_loop>
# <type-code_continue>
function AST_CODE_CONTINUE() {return "code_continue"}

function ast_code_continue_make(none,     _ent) {
	_ent = ast_new("code_continue")
	ast_code_continue_set_none(_ent, none)
	return _ent
}

function ast_code_continue_set_none(ent, none) {
	_ast_type_chk(ent, "code_continue")
	_ast_set(("none=" ent), none)
}
function ast_code_continue_get_none(ent) {
	_ast_type_chk(ent, "code_continue")
	return _ast_get(("none=" ent))
}

# <\type-code_continue>
# <type-code_if>
function AST_CODE_IF() {return "code_if"}

function ast_code_if_make(cond, code_lst,     _ent) {
	_ent = ast_new("code_if")
	ast_code_if_set_cond(_ent, cond)
	ast_code_if_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_if_set_cond(ent, cond) {
	_ast_type_chk(ent, "code_if")
	if (cond)
		_ast_type_chk(cond, "code_call")
	_ast_set(("cond=" ent), cond)
}
function ast_code_if_get_cond(ent) {
	_ast_type_chk(ent, "code_if")
	return _ast_get(("cond=" ent))
}

function ast_code_if_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_if")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_if_get_code_lst(ent) {
	_ast_type_chk(ent, "code_if")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_if>
# <type-code_else_if>
function AST_CODE_ELSE_IF() {return "code_else_if"}

function ast_code_else_if_make(cond, code_lst,     _ent) {
	_ent = ast_new("code_else_if")
	ast_code_else_if_set_cond(_ent, cond)
	ast_code_else_if_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_else_if_set_cond(ent, cond) {
	_ast_type_chk(ent, "code_else_if")
	if (cond)
		_ast_type_chk(cond, "code_call")
	_ast_set(("cond=" ent), cond)
}
function ast_code_else_if_get_cond(ent) {
	_ast_type_chk(ent, "code_else_if")
	return _ast_get(("cond=" ent))
}

function ast_code_else_if_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_else_if")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_else_if_get_code_lst(ent) {
	_ast_type_chk(ent, "code_else_if")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_else_if>
# <type-code_else>
function AST_CODE_ELSE() {return "code_else"}

function ast_code_else_make(code_lst,     _ent) {
	_ent = ast_new("code_else")
	ast_code_else_set_code_lst(_ent, code_lst)
	return _ent
}

function ast_code_else_set_code_lst(ent, code_lst) {
	_ast_type_chk(ent, "code_else")
	if (code_lst)
		_ast_type_chk(code_lst, "code_lst")
	_ast_set(("code_lst=" ent), code_lst)
}
function ast_code_else_get_code_lst(ent) {
	_ast_type_chk(ent, "code_else")
	return _ast_get(("code_lst=" ent))
}

# <\type-code_else>
# <\types>
# <\structs-ast>
# <error>
function ast_errq(msg) {error_quit(sprintf("ast: %s", msg))}
function ast_ent_errq(where, ent, type) {
	error_quit(sprintf("%s: entity '%s' of unexpected type '%s'", \
		where, ent, type))
}
# </error>

# <tree>
function ast_root_set(root) {_B_ast_root = root}
function ast_root() {return _B_ast_root}

function ast_root_node_create() {
	return ast_root_node_make(ast_cmnt_lst_make(), "")
}
function ast_root_node_push_cmnt(root_node, cmnt) {
	_ast_cmnt_lst_push(ast_root_node_get_cmnt_lst(root_node), cmnt)
}
function ast_root_node_head_cmnt(root_node) {
	return ast_cmnt_lst_get_head(ast_root_node_get_cmnt_lst(root_node))
}

function _ast_cmnt_lst_push(lst, cmnt) {
	if (!ast_cmnt_lst_get_head(lst)) {
		ast_cmnt_lst_set_head(lst, cmnt)
		ast_cmnt_lst_set_tail(lst, cmnt)
	} else {
		ast_comment_set_next_(ast_cmnt_lst_get_tail(lst), cmnt)
		ast_cmnt_lst_set_tail(lst, cmnt)
	}
}

function ast_sets_create() {
	return ast_sets_make(ast_alias_lst_make(), ast_set_lst_make(), "")
}
function ast_sets_push_alias(sets, alias,    _lst) {
	_lst = ast_sets_get_alias_lst(sets)
	if (!ast_alias_lst_get_head(_lst)) {
		ast_alias_lst_set_head(_lst, alias)
		ast_alias_lst_set_tail(_lst, alias)
	} else {
		ast_alias_set_next_(ast_alias_lst_get_tail(_lst), alias)
		ast_alias_lst_set_tail(_lst, alias)
	}
}
function ast_sets_last_alias(sets) {
	return ast_alias_lst_get_tail(ast_sets_get_alias_lst(sets))
}
function ast_sets_push_set(sets, set,    _lst) {
	_lst = ast_sets_get_set_lst(sets)
	if (!ast_set_lst_get_head(_lst)) {
		ast_set_lst_set_head(_lst, set)
		ast_set_lst_set_tail(_lst, set)
	} else {
		ast_set_set_next_(ast_set_lst_get_tail(_lst), set)
		ast_set_lst_set_tail(_lst, set)
	}
}
function ast_sets_last_set(sets) {
	return ast_set_lst_get_tail(ast_sets_get_set_lst(sets))
}

function ast_alias_push_elem(alias, elem,    _data) {
	_data = ast_alias_get_data(alias)
	_data = (!_data) ? elem : (_data " " elem)
	ast_alias_set_data(alias, _data)
}

function ast_parse_main_create(name) {
	return ast_parse_main_make(name, "", "", ast_fnc_lst_make())
}
function ast_parse_main_push_fnc(main, fnc,    _lst) {
	_lst = ast_parse_main_get_fnc_lst(main)
	if (!ast_fnc_lst_get_tail(_lst)) {
		ast_fnc_lst_set_head(_lst, fnc)
		ast_fnc_lst_set_tail(_lst, fnc)
	} else {
		ast_fnc_set_next_(ast_fnc_lst_get_tail(_lst), fnc)
		ast_fnc_lst_set_tail(_lst, fnc)
	}
}

function ast_fnc_create(name) {
	return ast_fnc_make(name, ast_cmnt_lst_make(), ast_code_lst_make())
}
function ast_fnc_push_cmnt(fnc, cmnt) {
	_ast_cmnt_lst_push(ast_fnc_get_cmnt_lst(fnc), cmnt)
}

function ast_code_loop_create() {
	return ast_code_loop_make(ast_code_lst_make())
}

function ast_code_if_create() {
	return ast_code_if_make("", ast_code_lst_make())
}

function ast_code_else_if_create() {
	return ast_code_else_if_make("", ast_code_lst_make())
}

function ast_code_else_create() {
	return ast_code_else_make(ast_code_lst_make())
}

function ast_code_lst_push_code_node(lst, node) {
	if (!ast_code_lst_get_tail(lst)) {
		ast_code_lst_set_head(lst, node)
		ast_code_lst_set_tail(lst, node)
	} else {
		ast_code_node_set_next_(ast_code_lst_get_tail(lst), node)
		ast_code_lst_set_tail(lst, node)
	}
}
# </tree>

# <traverse>
function ast_traverse_for_backed() {
	bd_on_begin()
	_ast_traverse(ast_root())
	bd_on_end()
}
function _ast_traverse(node,    _type) {
	if (!node)
		return

	_type = ast_type_of(node)
	if (AST_ROOT_NODE() == _type) {
		_ast_traverse(ast_root_node_get_cmnt_lst(node))
		_ast_traverse(ast_root_node_get_tokens(node))
	} else if (AST_CMNT_LST() == _type) {
		_ast_traverse(ast_cmnt_lst_get_head(node))
	} else if (AST_COMMENT() == _type) {
		bd_on_comment(ast_comment_get_str(node))
		if (!ast_comment_get_next_(node))
			bd_on_comments_end()
		else
			_ast_traverse(ast_comment_get_next_(node))
	} else if (AST_TOKENS() == _type) {
		bd_on_tokens(ast_tokens_get_all_tok(node))
		bd_on_tok_eoi(ast_tokens_get_tok_eoi(node))
		_ast_traverse(ast_tokens_get_sets(node))
	} else if (AST_SETS() == _type) {
		bd_on_sets_begin()
		_ast_traverse(ast_sets_get_alias_lst(node))
		_ast_traverse(ast_sets_get_set_lst(node))
		bd_on_sets_end()
		_ast_traverse(ast_sets_get_parse_main(node))
	} else if (AST_ALIAS_LST() == _type) {
		_ast_traverse(ast_alias_lst_get_head(node))
	} else if (AST_ALIAS() == _type) {
		bd_on_alias(ast_alias_get_name(node), ast_alias_get_data(node))
		_ast_traverse(ast_alias_get_next_(node))
	} else if (AST_SET_LST() == _type) {
		_ast_traverse(ast_set_lst_get_head(node))
	} else if (AST_SET() == _type) {
		bd_on_set(ast_set_get_type(node), ast_set_get_name(node), \
			ast_set_get_alias_name(node))
		_ast_traverse(ast_set_get_next_(node))
	} else if (AST_PARSE_MAIN() == _type) {
		bd_on_parse_main(ast_parse_main_get_name(node))
		bd_on_cb_open()
		bd_on_parse_main_code()
		bd_on_return()
		bd_on_call(ast_parse_main_get_top_nont(node))
		bd_on_and()
		bd_on_err_var(ast_parse_main_get_err_var(node))
		bd_on_return_end()
		bd_on_cb_close()
		bd_on_parse_main_end()
		_ast_traverse(ast_parse_main_get_fnc_lst(node))
	} else if (AST_FNC_LST() == _type) {
		_ast_traverse(ast_fnc_lst_get_head(node))
	} else if (AST_FNC() == _type) {
		bd_on_func(ast_fnc_get_name(node))
		bd_on_cb_open()
		_ast_traverse(ast_fnc_get_cmnt_lst(node))
		_ast_traverse(ast_fnc_get_code_lst(node))
		bd_on_cb_close()
		_ast_traverse(ast_fnc_get_next_(node))
	} else if (AST_CODE_LST() == _type) {
		_ast_traverse(ast_code_lst_get_head(node))
	} else if (AST_CODE_NODE() == _type) {
		_ast_traverse(ast_code_node_get_code(node))
		_ast_traverse(ast_code_node_get_next_(node))
	} else if (AST_CODE_CALL() == _type) {
		bd_on_call(ast_code_call_get_fname(node), ast_code_call_get_arg(node), \
			ast_code_call_get_is_esc(node))
	} else if (AST_CODE_RET() == _type) {
		if (ast_code_ret_get_const(node)) {
			bd_on_return(ast_code_ret_get_const(node))
			bd_on_return_end()
		} else {
			bd_on_return()
			_ast_traverse(ast_code_ret_get_call(node))
			bd_on_return_end()
		}
	} else if (AST_CODE_LOOP() == _type) {
		bd_on_loop()
		bd_on_cb_open()
		_ast_traverse(ast_code_loop_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_CONTINUE() == _type) {
		bd_on_continue()
	} else if (AST_CODE_IF() == _type) {
		bd_on_if()
		bd_on_cond()
		_ast_traverse(ast_code_if_get_cond(node))
		bd_on_cond_end()
		bd_on_cb_open()
		_ast_traverse(ast_code_if_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_ELSE_IF() == _type) {
		bd_on_else_if()
		bd_on_cond()
		_ast_traverse(ast_code_else_if_get_cond(node))
		bd_on_cond_end()
		bd_on_cb_open()
		_ast_traverse(ast_code_else_if_get_code_lst(node))
		bd_on_cb_close()
	} else if (AST_CODE_ELSE() == _type) {
		bd_on_else()
		bd_on_cb_open()
		_ast_traverse(ast_code_else_get_code_lst(node))
		bd_on_cb_close()
	} else {
		ast_ent_errq("_ast_traverse()", node, _type)
	}
}
# </traverse>
# </ast>
