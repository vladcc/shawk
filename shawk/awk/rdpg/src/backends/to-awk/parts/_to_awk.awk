#!/usr/bin/awk -f

# <to-awk>
function SCRIPT_NAME() {return "rdpg-to-awk.awk"}
function SCRIPT_VERSION() {return "2.0"}

function print_help_quit() {
print sprintf("-- %s - ir to awk translator --", SCRIPT_NAME())
print ""
print "Use: rdpg-comp.awk [options] <grammar> | rdpg-to-awk.awk > out.awk"
print ""
print "Required user callbacks:"
print "tok_next() - returns the next token in the stream"
print "tok_curr() - returns the current token; i.e. the one from the last tok_next()"
print "tok_err()  - called when the current token does not match what's expected"
print ""
print "The returned tokens must be logically comparable; TOK_A() == TOK_A() and"
print "TOK_A() != TOK_B() must evaluate to true."
print ""
print "Exported API:"
print "rdpg_parse()         - call to parse. Returns true if the parse encountered no"
print "errors, false otherwise."
print "rdpg_expect(arr_out) - call from tok_err(). Places the set of expected tokens"
print "in arr_out. Returns the length of arr_out."
print ""
print "Options:"
print "-v Out=<fnm> - output source code goes to <fnm>.awk"
print "-v Help=1    - this screen"
print "-v Version=1 - version info"
exit_success()
}
function print_version_quit() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
exit_success()
}

function init() {
	if (Help)
		print_help_quit()
	if (Version)
		print_version_quit()
	if (Out)
		stdout_set(sprintf("%s.awk", Out))
}

# <misc>
function _eoi_set(nm) {_B_eoi = nm}
function _eoi()       {return _B_eoi}

function _fn_name(nm) {return sprintf("_rdpg_%s", nm)}

function _RPREF()    {return "_RDPG_"}
function _rpref(str) {return (_RPREF() str)}

function _F_SEP()        {return _rpref("SEP")}
function _F_INIT_SETS()  {return _fn_name("init_sets")}

function _V_CURR_TOK() {return _rpref("curr_tok")}
function _V_ERR()      {return _rpref("had_error")}
function _V_EXP_TYPE() {return _rpref("expect_type")}
function _V_EXP_WHAT() {return _rpref("expect_what")}
function _V_EXP_SETS() {return _rpref("expect_sets")}

function _v_alias_str(nm) {return _rpref(sprintf("B_str_sym_%s", nm))}
function _v_alias_set(nm) {return _rpref(sprintf("sym_%s", nm))}
# </misc>

# <sets>
function _set_alias_save(name, data,    _c) {
	_c = ++_B_sets["alias.count"]
	_B_sets[sprintf("alias.name=%d", _c)] = name
	_B_sets[sprintf("alias.data=%d", _c)] = data
	_B_sets[sprintf("alias=%s", name)] = data
}
function _set_alias_count() {return _B_sets["alias.count"]}
function _set_alias_name_by_num(n) {return _B_sets[sprintf("alias.name=%d", n)]}
function _set_alias_data_by_num(n) {return _B_sets[sprintf("alias.data=%d", n)]}

function _set_save(type, name, alias_name,    _c) {
	_c = ++_B_sets[sprintf("set.count=%s", type)]
	_B_sets[sprintf("set.%s.name=%d", type, _c)] = name
	_B_sets[sprintf("set.%s.aname.d=%d", type, _c)] = alias_name
	_B_sets[sprintf("set.%s.aname.s=%s", type, name)] = alias_name
}
function _set_count(type) {return _B_sets[sprintf("set.count=%s", type)]}
function _set_get_name(type, n) {
	return _B_sets[sprintf("set.%s.name=%d", type, n)]
}
function _set_get_alias_name_by_num(type, n) {
	return _B_sets[sprintf("set.%s.aname.d=%d", type, n)]
}
function _set_get_alias_name_by_sname(type, name) {
	return _B_sets[sprintf("set.%s.aname.s=%s", type, name)]
}
function _set_prepare(set,    _rep) {
	_rep = sprintf(" %s ", _F_SEP())
	gsub(" ", _rep, set)
	gsub("[A-Z_]+", "&()", set)
	return set
}
# </sets>

# <internal-code>
function _gen_internal(    _i, _end, _set, _nm) {
	emit("function rdpg_expect(arr_out,    _len) {")
	tinc()
		emit("delete arr_out")
		emit(sprintf("if (\"tok\" == %s)", _V_EXP_TYPE()))
		tinc()
			emit(sprintf("arr_out[(_len = 1)] = %s", _V_EXP_WHAT()))
		tdec()
			emit(sprintf("else if (\"set\" == %s)", _V_EXP_TYPE()))
		tinc()
			emit(sprintf("_len = split(%s[%s], arr_out, %s())", \
				_V_EXP_SETS(), _V_EXP_WHAT(), _F_SEP()))
		tdec()
		emit("return _len")
	tdec()
	emit("}")
	emit("# </public>")

	emit("# <internal>")
	emit(sprintf("function %s() {return \"\\034\"}", _F_SEP()))
	emit(sprintf("function %s() {", _fn_name(IR_TOK_NEXT())))
	tinc()
		emit(sprintf("%s()", IR_TOK_NEXT()))
		emit(sprintf("%s = %s()", _V_CURR_TOK(), IR_TOK_CURR()))
	tdec()
	emit("}")

	emit(sprintf("function %s(tok) {", _fn_name(IR_TOK_IS())))
	tinc()
		emit(sprintf("return (tok == %s)", _V_CURR_TOK()))
	tdec()
	emit("}")

	emit(sprintf("function %s(tok,    _ret) {", _fn_name(IR_TOK_MATCH())))
		tinc()
		emit(sprintf("if (_ret = %s(tok))", _fn_name(IR_TOK_IS())))
		tinc()
			emit(sprintf("%s()", _fn_name(IR_TOK_NEXT())))
		tdec()
		emit(sprintf("return _ret"))
	tdec()
	emit("}")

	emit(sprintf("function %s(    _i, _len, _arr) {", _F_INIT_SETS()))
	tinc()
		_type = IR_ALIAS()
		emit(sprintf("# %s", _type))
		_end = _set_alias_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nm = _v_alias_str(_set_alias_name_by_num(_i))
			_set = _set_prepare(_set_alias_data_by_num(_i))
			emit(sprintf("%s = (%s)", _nm, _set))
		}
		nl()
		for (_i = 1; _i <= _end; ++_i) {
			_nm = _set_alias_name_by_num(_i)
			_set = _v_alias_set(_nm)
			_nm = _v_alias_str(_nm)
			emit(sprintf("_len = split(%s, _arr, %s())", _nm, _F_SEP()))
			emit("for (_i = 1; _i <= _len; ++_i)")
			tinc()
				emit(sprintf("%s[_arr[_i]]", _set))
			tdec()
			nl()
		}
		_type = IR_EXPECT()
		emit(sprintf("# %s", _type))
		_end = _set_count(_type)
		for (_i = 1; _i <= _end; ++_i) {
			_nm = _set_get_name(_type, _i)
			_set = _v_alias_str(_set_get_alias_name_by_num(_type, _i))
			emit(sprintf("%s[\"%s\"] = %s", _V_EXP_SETS(), _nm, _set))
		}
	tdec()
	emit("}")

	emit(sprintf("function %s(set) {", _fn_name(IR_PREDICT())))
	tinc()
		emit(sprintf("return (%s in set)", _V_CURR_TOK()))
	tdec()
	emit("}")

	if (sync_call()) {
		emit(sprintf("function %s(set) {", _fn_name(IR_SYNC())))
		tinc()
			emit(sprintf("while (%s) {", _V_CURR_TOK()))
			tinc()
				emit(sprintf("if (%s in set)", _V_CURR_TOK()))
				tinc()
					emit("return 1")
				tdec()
				emit(sprintf("if (%s(%s()))", _fn_name(IR_TOK_IS()), _eoi()))
				tinc()
					emit("break")
				tdec()
				emit(sprintf("%s()", _fn_name(IR_TOK_NEXT())))
			tdec()
			emit("}")
			emit("return 0")
		tdec()
		emit("}")
	}

	emit(sprintf("function %s(type, what) {", _fn_name(IR_EXPECT())))
	tinc()
		emit(sprintf("%s = type", _V_EXP_TYPE()))
		emit(sprintf("%s = what", _V_EXP_WHAT()))
		emit(sprintf("%s = 1", _V_ERR()))
		emit(sprintf("%s()", IR_TOK_ERR()))
	tdec()
	emit("}")
	emit("# </internal>")
}
# </internal-code>

# <events>
function bd_on_begin() {
	emit("# <parse>")
	emit("#")
	emit(sprintf("# translated by %s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
}
function bd_on_end() {
	emit("# </rd>")
	emit("# </parse>")
}

function bd_on_comment(str) {
	emit(sprintf("# %s", str))
}
function bd_on_comments_end() {
	nl()
}

function bd_on_alias(name, data) {
	_set_alias_save(name, data)
}

function bd_on_set(type, name, alias_name) {
	_set_save(type, name, alias_name)
}
function bd_on_sets_begin() {

}
function bd_on_sets_end() {

}

function bd_on_tokens(all_toks) {

}
function bd_on_tok_eoi(name) {
	_eoi_set(name)
}

function bd_on_cb_open() {
	emit("{")
	tinc()
}
function bd_on_cb_close() {
	tdec()
	emit("}")
}

function bd_on_parse_main(name) {
	emit("# <public>")
	emit(sprintf("function %s()", name))
}
function bd_on_parse_main_code() {
	emit(sprintf("%s()", _F_INIT_SETS()))
}
function bd_on_parse_main_end() {
	_gen_internal()
	emit("# <rd>")
}

function bd_on_func(name) {
	emit(sprintf("function %s()", _fn_name(name)))
}

function bd_on_return(val) {
	bstr_cat("return ")
	if (IR_TRUE() == val)
		bstr_cat("1")
	else if (IR_FALSE() == val)
		bstr_cat("0")
}
function bd_on_return_end() {
	bstr_emit()
}

function bd_on_call(name, arg, is_esc,    _call, _act_name) {
	_act_name = is_esc ? name : _fn_name(name)

	if (arg) {
		if (is_terminal(arg)) {
			arg = (arg "()")
			if (IR_EXPECT() == name)
				arg = sprintf("\"tok\", %s", arg)
		} else if (is_non_term(arg)) {
			if (IR_PREDICT() == name || IR_SYNC() == name)
				arg = _v_alias_set(_set_get_alias_name_by_sname(name, arg))
			else if (IR_EXPECT() == name)
				arg = sprintf("\"set\", \"%s\"", arg)
		}
		_call = sprintf("%s(%s)", _act_name, arg)
	} else {
		_call = sprintf("%s()", _act_name)
	}

	bstr_cat(_call)
	if (bstr_peek() == _call)
		bstr_emit()
}

function bd_on_and() {
	bstr_cat(" && ")
}
function bd_on_err_var(name) {
	bstr_cat(sprintf("!%s", _V_ERR()))
}

function bd_on_if() {
	bstr_cat("if ")
}
function bd_on_cond() {
	bstr_cat("(")
}
function bd_on_cond_end() {
	bstr_cat(")")
	bstr_emit()
}
function bd_on_else_if() {
	bstr_cat("else if ")
}
function bd_on_else() {
	emit("else")
}

function bd_on_loop() {
	emit("while (1)")
}
function bd_on_continue() {
	emit("continue")
}
# </events>
# </to-awk>
