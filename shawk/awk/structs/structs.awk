#!/usr/bin/awk -f

# generated by smpg.awk 2.0

# <description>
function DESCRIPT_INCLUDES() {
return \
"included files:\n"\
"awklib_prog.awk\n"\
"awklib_tabs.awk\n"\
}
function DESCRIPT_FSM() {
return \
"fsm rules:\n"\
"start  -> prefix | type\n"\
"prefix -> type\n"\
"type   -> has\n"\
"has    -> has | type | end\n"\
"end    -> start\n"\
"\n"\
"'->' is read as 'must be followed by'\n"\
"'|' is read as 'or'"
}
function DESCRIPT() {
	return (DESCRIPT_INCLUDES() "\n" DESCRIPT_FSM())
}
# </description>

# <other>
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2024-08-06

function SCRIPT_NAME() {return "structs.awk"}
function SCRIPT_VERSION() {return "1.1"}

# <awk_rules>
function init() {
	set_program_name(SCRIPT_NAME())

	if (Fsm)
		print_fsm()
	if (Help)
		print_help()
	if (Version)
		print_version()
	if (ARGC != 2)
		print_use_try()
}
BEGIN {
	init()
}

# ignore empty lines and comments
/^[[:space:]]*(#|$)/ {next}

# strip spaces and fsm
{
	gsub("^[[:space:]]+|[[:space:]]+$", "", $0)
	fsm_next(G_the_fsm, $1)
}
# </awk_rules>

function data_or_err() {
	if (NF < 2)
		error_qfpos(sprintf("no data after '%s'", $1))
}
function error_qfpos(msg) {
	error_quit(sprintf("file '%s' line %d: %s", FILENAME, FNR, msg))
}
# </other>

# <templated>
# 'prefix|type'
function on_prefix(v) {prefix_save(v)}

function on_type(v) {type_save(v)}

# 'has'
function on_has(memb, type) {has_save(memb, type)}
# </templated>

# <fsm>
# <handlers>
function fsm_on_start() {
	prefix_save("ent")
}
function fsm_on_prefix() {
	data_or_err()
	on_prefix($2)
}
function fsm_on_type() {
	data_or_err()
	on_type($2)
}
function fsm_on_has() {
	data_or_err()
	on_has($2, $3)
}
function fsm_on_end() {
	generate()
	exit_success()
}
function fsm_on_error(curr_st, expected, got) {
	error_qfpos(sprintf("'%s' expected, but got '%s' instead", expected, got))
}
# </handlers>

# <constants>
function FSM_START() {return "start"}
function FSM_PREFIX() {return "prefix"}
function FSM_TYPE() {return "type"}
function FSM_HAS() {return "has"}
function FSM_END() {return "end"}
function _FSM_STATE() {return "state"}
# </constants>

# <functions>
function fsm_get_state(fsm) {return fsm[_FSM_STATE()]}
function _fsm_set_state(fsm, next_st) {fsm[_FSM_STATE()] = next_st}
function fsm_next(fsm, next_st,    _st) {

	_st = fsm_get_state(fsm)
	if ("" == _st) {
		if (FSM_START() == next_st)
		{fsm_on_start(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_START(), next_st)}
	}
	else if (FSM_START() == _st) {
		if (FSM_PREFIX() == next_st)
		{fsm_on_prefix(); _fsm_set_state(fsm, next_st)}
		else if (FSM_TYPE() == next_st)
		{fsm_on_type(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_PREFIX()"|"FSM_TYPE(), next_st)}
	}
	else if (FSM_PREFIX() == _st) {
		if (FSM_TYPE() == next_st)
		{fsm_on_type(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_TYPE(), next_st)}
	}
	else if (FSM_TYPE() == _st) {
		if (FSM_HAS() == next_st)
		{fsm_on_has(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_HAS(), next_st)}
	}
	else if (FSM_HAS() == _st) {
		if (FSM_HAS() == next_st)
		{fsm_on_has(); _fsm_set_state(fsm, next_st)}
		else if (FSM_TYPE() == next_st)
		{fsm_on_type(); _fsm_set_state(fsm, next_st)}
		else if (FSM_END() == next_st)
		{fsm_on_end(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_HAS()"|"FSM_TYPE()"|"FSM_END(), next_st)}
	}
	else if (FSM_END() == _st) {
		if (FSM_START() == next_st)
		{fsm_on_start(); _fsm_set_state(fsm, next_st)}
		else
		{fsm_on_error(_st, FSM_START(), next_st)}
	}
}
# </functions>
# </fsm>

# <includes>
# ../awklib/src/awklib_prog.awk
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	_AWKLIB_prog__program_name = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return _AWKLIB_prog__program_name
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	_AWKLIB_prog__skip_end_flag = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	_AWKLIB_prog__skip_end_flag = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (_AWKLIB_prog__skip_end_flag+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	_AWKLIB_prog__error_flag = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	_AWKLIB_prog__error_flag = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (_AWKLIB_prog__error_flag+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {

	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
# ../awklib/src/awklib_tabs.awk
#@ <awklib_tabs>
#@ Library: tabs
#@ Description: String indentation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Adds a tab to the indentation string.
#@ Returns: Nothing.
#
function tabs_inc() {

	++_AWKLIB_tabs__tabs_num
	_AWKLIB_tabs__tabs_str = (_AWKLIB_tabs__tabs_str "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (_AWKLIB_tabs__tabs_num) {
		--_AWKLIB_tabs__tabs_num
		_AWKLIB_tabs__tabs_str = substr(_AWKLIB_tabs__tabs_str, 1,
			_AWKLIB_tabs__tabs_num)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return _AWKLIB_tabs__tabs_num
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (_AWKLIB_tabs__tabs_str "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (_AWKLIB_tabs__tabs_str str)
}

#
#@ Description: Prints the indented 'str' to stdout without a new line
#@ at the end.
#@ Returns: Nothing.
#
function tabs_print_str(str) {

	printf("%s", tabs_indent(str))
}

#
#@ Description: Prints the indented 'str' to stdout with a new line at
#@ the end.
#@ Returns: Nothing.
#
function tabs_print(str) {

	print tabs_indent(str)
}
#@ </awklib_tabs>
# </includes>
# <generate>
# <data>
function _set(k, v) {_B_structs[k] = v}
function _get(k) {return _B_structs[k]}
function _has(k) {return (k in _B_structs)}

function prefix_save(str) {_set("prefix", str)}
function prefix_get() {return _get("prefix")}

function type_save(str,    _n) {
	_set("type.count", (_n = _get("type.count")+1))
	_set(sprintf("type=%d", _n), str)
	_set(sprintf("type.set=%s", str))
}
function type_count() {return _get("type.count")}
function type_get(n) {return _get(sprintf("type=%d", n))}
function type_last() {return type_get(type_count())}
function type_is(str) {return _has(sprintf("type.set=%s", str))}

function has_save(memb, mtype,    _type, _n, _x) {
	_type = type_last()
	_x = sprintf("has.count=%s", _type)
	_set(_x, (_n = _get(_x)+1))
	_x = sprintf("has.memb.%d=%s", _n, _type)
	_set(_x, memb)
	_x = sprintf("has.mtype.%d=%s", _n, _type)
	_set(_x, mtype)
}
function has_count(type) {return _get(sprintf("has.count=%s", type))}
function has_get_memb(type, n) {return _get(sprintf("has.memb.%d=%s", n, type))}
function has_get_mtype(type, n) {
	return _get(sprintf("has.mtype.%d=%s", n, type))
}
# </data>

function tag_structs() {return ("structs-" prefix_get())}
function tag_open(tag) {print sprintf("# <%s>", tag)}
function tag_close(tag) {print sprintf("# <\\%s>", tag)}
function make_fnm(str,    _pref) {return (prefix_get() "_" str)}
function make_dbnm() {return sprintf("_STRUCTS_%s_db", prefix_get())}

function emit(str) {tabs_print(str)}

function gen_base(    _fname, _db_nm) {
	tag_open("private")
	_db_nm = make_dbnm()

	_fname = ("_" make_fnm("set"))
	emit(sprintf("function %s(k, v) {%s[k] = v}", _fname, _db_nm))

	_fname = ("_" make_fnm("get"))
	emit(sprintf("function %s(k) {return %s[k]}", _fname, _db_nm))

	_fname = ("_" make_fnm("type_chk"))
	emit(sprintf("function %s(ent, texp) {", _fname))
	tabs_inc()
		emit(sprintf("if (%s(ent) == texp)", make_fnm("type_of")))
			tabs_inc()
			emit("return")
			tabs_dec()
		emit(sprintf("%s_errq(sprintf(\"entity '%%s' expected type '%%s', " \
			"actual type '%%s'\", \\\n\t\t ent, texp, %s(ent)))", \
			prefix_get(), make_fnm("type_of")))
	tabs_dec()
	emit("}")
	tag_close("private")

	emit("")

	_fname = make_fnm("clear")
	emit(sprintf("function %s() {delete %s}", _fname, _db_nm))

	_fname = make_fnm("is")
	emit(sprintf("function %s(ent) {return (ent in %s)}", _fname, _db_nm))

	_fname = make_fnm("type_of")
	emit(sprintf("function %s(ent) {", _fname))
	tabs_inc()
		emit(sprintf("if (ent in %s)", _db_nm))
		tabs_inc()
			emit(sprintf("return %s[ent]", _db_nm, _db_nm))
		tabs_dec()
		emit(sprintf("%s_errq(sprintf(\"'%%s' not an entity\", ent))", \
			prefix_get()))
	tabs_dec()
	emit("}")

	_fname = make_fnm("new")
	emit(sprintf("function %s(type,    _ent) {", _fname))
	tabs_inc()
		emit(sprintf("\t_%s(\"ents\", (_ent = _%s(\"ents\")+1))", \
			make_fnm("set"), make_fnm("get")))
		emit("_ent = (\"_n\" _ent)")
		emit(sprintf("_%s(_ent, type)", make_fnm("set")))
		emit("return _ent")
	tabs_dec()
	emit("}")
}

function gen_type(type,    _i, _end, _memb, _mtype, _pref, _fname) {
	_pref = prefix_get()
	_end = has_count(type)
	_fname = sprintf("function %s_make(", make_fnm(type))
	for (_i = 1; _i <= _end; ++_i)
		_fname = (_fname sprintf("%s, ", has_get_memb(type, _i)))
	emit(sprintf("%s    _ent) {", _fname))
	tabs_inc()
		emit(sprintf("_ent = %s(\"%s\")", make_fnm("new"), type))
		for (_i = 1; _i <= _end; ++_i) {
			_memb = has_get_memb(type, _i)
			_fname = sprintf("%s_%s_set_%s", _pref, type, _memb)
			emit(sprintf("%s(_ent, %s)", _fname, _memb))
		}
		emit("return _ent")
	tabs_dec()
	emit("}")
	emit("")

	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get_memb(type, _i)
		_mtype = has_get_mtype(type, _i)

		_fname = sprintf("%s_%s_set_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent, %s) {", _fname, _memb))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), type))
			if (_mtype) {
				emit(sprintf("if (%s)", _memb))
				tabs_inc()
					emit(sprintf("_%s(%s, \"%s\")", \
						make_fnm("type_chk"), _memb, _mtype))
				tabs_dec()
			}
			emit(sprintf("_%s((\"%s=\" ent), %s)", \
				make_fnm("set"), _memb, _memb))
		tabs_dec()
		emit("}")

		_fname = sprintf("%s_%s_get_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent) {", _fname))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), type))
			emit(sprintf("return _%s((\"%s=\" ent))", make_fnm("get"), _memb))
		tabs_dec()
		emit("}")
		emit("")
	}
}

function gen_types(    _i, _end, _type, _fname) {
	_end = type_count()
	for (_i = 1; _i <= _end; ++_i) {
		_type = type_get(_i)
		_fname = toupper(make_fnm(_type))
		tag_open(sprintf("type-%s", _type))
		emit(sprintf("function %s() {return \"%s\"}", _fname, _type))
		emit("")
		gen_type(_type)
		tag_close(sprintf("type-%s", _type))
	}
}

function check_mtypes(    _i, _ie, _j, _je, _type, _mtype, _err) {
	_ie = type_count()
	for (_i = 1; _i <= _ie; ++_i) {
		_type = type_get(_i)
		_je = has_count(_type)
		for (_j = 1; _j <= _je; ++_j) {
			_mtype = has_get_mtype(_type, _j)
			if (_mtype && !type_is(_mtype)) {
				_err = sprintf("struct '%s', member '%s' '%s' is not a type", \
					_type, has_get_memb(_type, _j), _mtype)
				error_quit(_err)
			}
		}
	}
}
function checks() {check_mtypes()}

function gen_struct_cmnts(    _i, _ie, _j, _je, _type, _memb, _mtype) {
	emit("# structs:")
	_ie = type_count()
	for (_i = 1; _i <= _ie; ++_i) {
		_type = type_get(_i)
		emit("#")
		emit(sprintf("# type %s", _type))
		_je = has_count(_type)
		for (_j = 1; _j <= _je; ++_j) {
			_memb = has_get_memb(_type, _j)
			_mtype = has_get_mtype(_type, _j)
			emit(sprintf("# has  %s %s", _memb, _mtype))
		}
	}
	emit("#")
}

function generate() {
	checks()
	tag_open(tag_structs())
	gen_struct_cmnts()
	gen_base()
	tag_open("types")
	gen_types()
	tag_close("types")
	tag_close(tag_structs())
}
# </generate>
# <doc>
function print_help() {
print sprintf("%s %s - type compiler", SCRIPT_NAME(), SCRIPT_VERSION())
print ""
print use_str()
print ""
print "Compiles type descriptions into a type system in awk. 'Compiles in awk'"
print "means it generates awk source code for setters/getters for each type's"
print "members, along with facilities to create an entity of a certain type, check"
print "its type, and a table to remember what values all type variables have. For"
print "an example use the following as an input file:"
print ""
print "start"
print "type btree"
print "has  data"
print "has  left  btree"
print "has  right btree"
print "end"
print ""
print "Options:"
print "-vFsm=1     - print the fsm 'grammar'"
print "-vVersion=1 - version information"
print "-vHelp=1    - this screen"
exit_success()
}
function print_fsm() {
	print DESCRIPT_FSM()
	exit_success()
}
function print_version() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
exit_success()
}
function use_str() {return sprintf("Use: %s <structs-file>", SCRIPT_NAME())}
function print_use_try() {
pstderr(use_str())
pstderr(sprintf("Try: %s -vHelp=1", SCRIPT_NAME()))
exit_failure()
}
# </doc>
