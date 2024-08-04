#!/usr/bin/awk -f

# generated by smpg.awk 2.0

# <description>
function DESCRIPT_INCLUDES() {
return \
"included files:\n"\
"awklib_prog.awk\n"\
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
# 2024-08-03

function SCRIPT_NAME() {return "structs.awk"}
function SCRIPT_VERSION() {return "1.0"}

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
# 'prefix|type|has'
function on_prefix(v) {prefix_save(v)}

function on_type(v) {type_save(v)}

function on_has(v) {has_save(v)}
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
	on_has($2)
}
function fsm_on_end() {
	tag_open(tag_structs())
	generate()
	tag_close(tag_structs())
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
# </includes>