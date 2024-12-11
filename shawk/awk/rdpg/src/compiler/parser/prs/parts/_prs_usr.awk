# <dispatch>
function on_top_sym()    {_prs_do("on_top_sym")}
function on_eoi_term()   {_prs_do("on_eoi_term")}
function on_lhs_start()  {_prs_do("on_lhs_start")}
function on_rule_start() {_prs_do("on_rule_start")}
function on_esc()        {_prs_do("on_esc")}
function on_term()       {_prs_do("on_term")}
function on_nont()       {_prs_do("on_nont")}
function on_qmark()      {_prs_do("on_qmark")}
function on_star()       {_prs_do("on_star")}
function on_plus()       {_prs_do("on_plus")}

function _prs_do(what) {
	if (parsing_error_happened())     return
	else if ("on_top_sym"    == what) _prs_on_start(lex_get_saved())
	else if ("on_eoi_term"   == what) _prs_start_set_eoi_term(lex_get_saved())
	else if ("on_lhs_start"  == what) _prs_on_lhs(lex_get_saved())
	else if ("on_rule_start" == what) _prs_on_rule()
	else if ("on_esc"        == what) _prs_on_esc(lex_get_saved())
	else if ("on_term"       == what) _prs_on_sym(TERM(), lex_get_saved())
	else if ("on_nont"       == what) _prs_on_sym(NONT(), lex_get_saved())
	else if ("on_qmark"      == what) _prs_on_mod(QMARK())
	else if ("on_star"       == what) _prs_on_mod(STAR())
	else if ("on_plus"       == what) _prs_on_mod(PLUS())
	else error_quit(sprintf("parser: unknown actions '%s'", what))
}
# </dispatch>

# <process>
function _prs_esc_type_set(type) {_B_prs_esc_type = type}
function _prs_esc_type()         {return _B_prs_esc_type}
function _prs_mod_type_set(type) {_B_prs_mod_type = type}
function _prs_mod_type()         {return _B_prs_mod_type}
# <ast-wrapper>
function _prs_set_start(ent) {ast_root_set(ent)}
function _prs_get_start() {return ast_root()}

function _prs_set_top_lhs(ent) {ast_start_push_lhs(_prs_get_start(), ent)}
function _prs_get_top_lhs() {return ast_start_last_lhs(_prs_get_start())}

function _prs_set_top_rule(ent) {ast_lhs_push_rule(_prs_get_top_lhs(), ent)}
function _prs_get_top_rule() {return ast_lhs_last_rule(_prs_get_top_lhs())}

function _prs_set_top_sym(ent) {ast_rule_push_sym(_prs_get_top_rule(), ent)}
function _prs_get_top_sym() {return ast_rule_last_sym(_prs_get_top_rule())}

function _prs_set_rule_top_esc(ent) {
	ast_rule_push_esc(_prs_get_top_rule(), ent)
}
function _prs_get_rule_top_esc() {return ast_rule_last_esc(_prs_get_top_rule())}

function _prs_set_sym_top_esc(ent) {ast_sym_push_esc(_prs_get_top_sym(), ent)}
function _prs_get_sym_top_esc() {return ast_sym_last_esc(_prs_get_top_sym())}

function _prs_on_start(nont) {
	_prs_set_start(ast_start_create(nont))
	_prs_mod_type_set(AST_START())
}
function _prs_start_set_eoi_term(term) {
	ast_start_set_eoi_term(_prs_get_start(), term)
}
function _prs_on_lhs(name) {
	_prs_set_top_lhs(ast_lhs_create(name))
}
function _prs_on_rule() {
	_prs_set_top_rule(ast_rule_create())
	_prs_esc_type_set(AST_RULE())
}
function _prs_on_sym(type, name) {
	_prs_set_top_sym(ast_sym_create(type, name))
	_prs_esc_type_set(AST_SYM())
	_prs_mod_type_set(AST_SYM())
}
function _prs_on_esc(name,    _esc, _type) {
	_esc = ast_esc_create(name)
	_type = _prs_esc_type()
	if (AST_RULE() == _type)
		_prs_set_rule_top_esc(_esc)
	else if (AST_SYM() == _type)
		_prs_set_sym_top_esc(_esc)
}
function _prs_on_mod(mod,    _type) {
	_type = _prs_mod_type()
	if (AST_START() == _type)
		ast_start_set_mod(_prs_get_start(), mod)
	else if (AST_SYM() == _type)
		ast_sym_set_mod(_prs_get_top_sym(), mod)
}
# </ast-wrapper>
# </process>
