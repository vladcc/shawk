#!/usr/bin/awk -f

# genbash.awk -- a bash script generator
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2021-01-17

function SCRIPT_NAME() {return "bash-opt-gen.awk"}
function SCRIPT_VERSION() {return "1.0"}

# <user_api>
# <user_events>
function on_begin() {
	#data_or_err()
	#save_begin($2)
	reset_all()
}


function on_script_ver() {
	data_or_err()
	save_script_ver($2)

}

function on_opt_name() {
	data_or_err()
	save_opt_name(toupper($2))

}

function on_opt_takes_arg(    val) {
	data_or_err()
	
	val = $2
	if ("true" == val || "false" == val)
		save_opt_takes_arg(val)
	else
		error_input("value should be 'true' or 'false'")
}

function on_opt_short() {
	#data_or_err()
	save_opt_short($2)

}

function on_opt_long(    i) {
	#data_or_err()
	save_opt_long($2)
	
	i = get_opt_long_count()
	if (!get_opt_short(i) && !get_opt_long(i))
		error_input("short and long names are both empty")
}

function on_end() {
	#data_or_err()
	#save_end($2)
	
	generate()
}

function G_OPT() {return "G_OPT"}
function RO() {return "readonly"}
function NAME_VAR() {return "name_var"}
function SHORT_VAR() {return "short_var"}
function LONG_VAR() {return "long_var"}
function opt_save_short_var(n,    str) {
	str = get_opt_short(n)
	if (str)
		str = sprintf("%s_%s_S", G_OPT(), get_opt_name(n))
	_B_opts[n, SHORT_VAR()] = str
}
function opt_save_long_var(n,    str) {
	str = get_opt_long(n)
	if (str)
		str = sprintf("%s_%s_L", G_OPT(), get_opt_name(n))
	_B_opts[n, LONG_VAR()] = str
}
function opt_save_name_var(n) {
	_B_opts[n, NAME_VAR()] = sprintf("G_%s", get_opt_name(n))
}
function opt_get_short_var(n) {return _B_opts[n, SHORT_VAR()]}
function opt_get_long_var(n) {return _B_opts[n, LONG_VAR()]}
function opt_get_name_var(n) {return _B_opts[n, NAME_VAR()]}
function opt_get_var_unbound() {return "G_CMD_LINE_OTHER"}
function opt_get_match_var(n,    str) {
	str = sprintf("G_MATCH_%s", get_opt_name(n))
	return str
}
function opt_get_setter(n) {
	return sprintf("set_%s", tolower(get_opt_name(n)))
}

function make_var_names(    i, end) {
	end = get_opt_name_count()
	for (i = 1; i <= end; ++i) {
		opt_save_short_var(i)
		opt_save_long_var(i)
		opt_save_name_var(i)	
	}
}

function new_line() {print ""}
function print_var_defn(    i, end, shrt, lng, mch, xglob) {
	end = get_opt_name_count()
	for (i = 1; i <= end; ++i) {
		if (shrt = opt_get_short_var(i)) {
			print sprintf("%s %s=\"-%s\"", RO(), shrt, get_opt_short(i))
			xglob = sprintf("$%s", shrt)
		}
		if (lng = opt_get_long_var(i)) {
			print sprintf("%s %s=\"--%s\"", RO(), lng, get_opt_long(i))
			xglob = sprintf("$%s", lng)
		}
		if (shrt && lng)
				xglob = sprintf("$%s|$%s", shrt, lng)
		if (mch = opt_get_match_var(i))
			print sprintf("%s %s=\"@(%s)\"", RO(), mch, xglob)
		print sprintf("%s=\"\"", opt_get_name_var(i))
		new_line()
	}
	
	print sprintf("%s=\"\"", opt_get_var_unbound())
}

function FUNC() {return "function"}
function print_setters(    i, end, var) {
	end = get_opt_name_count()
	for (i = 1; i <= end; ++i) {
		var = (get_opt_takes_arg(i) == "true") ? "$2" : "yes"
		print sprintf("%s %s { %s=\"%s\"; }",
			FUNC(), opt_get_setter(i), opt_get_name_var(i), var)
	}
}

function G_SCRN() {return "G_SCRIPT_NAME"}
function G_SCRD() {return "G_SCRPIT_DIR"}
function G_SCRV() {return "G_SCRIPT_VER"}
function ECHO()   {return "echo"}
function print_hdr() {
	print "#!/bin/bash"
	new_line()
	print "set -u"
	new_line()
	print sprintf("%s %s=\"$(basename $0)\"", RO(), G_SCRN());
	print sprintf("%s %s=\"$(dirname $(realpath $0))\"", RO(), G_SCRD());
	print sprintf("%s %s=\"%s\"", RO(), G_SCRV(), get_script_ver(1))
	print sprintf("%s print_version { %s \"$%s $%s\"; }",
		FUNC(), ECHO(), G_SCRN(), G_SCRV())
}

function print_base() {
print sprintf("%s print_fd2    { %s \"$@\" >&2; }", FUNC(), ECHO())
print sprintf("%s error_print  { print_fd2 \"$0: error: $@\"; }",
	FUNC(), ECHO())
print sprintf("%s error_exit   { error_print \"$@\"; exit_failure; }",
	FUNC(), ECHO())
print sprintf("%s exit_success { exit 0; }",
	FUNC(), ECHO())
print sprintf("%s exit_failure { exit 1; }",
	FUNC(), ECHO())
}

function L_UARG() {return "L_UNBOUND_ARG"}
function L_OARG() {return "L_OPT_ARG"}
function L_NOARG() {return "L_OPT_NO_ARG"}

function make_case(val, str) {
print_ind_line(sprintf("%s)", val))
print_inc_indent()
print_ind_line(str)
print_dec_indent()
print_ind_line(";;")
}

function print_end_arg_cases() {
make_case(sprintf("$%s", L_UARG()), "error_exit \"'$1' unknown option\"")
make_case("*", sprintf("%s=\"${%s}'$1' \"",
	opt_get_var_unbound(), opt_get_var_unbound()))
}

function print_cases(    i, end, mvar, opt_nopt) {
	end = get_opt_name_count()
	for (i = 1; i <= end; ++i) {
		mvar = opt_get_match_var(i)
		
		opt_nopt = (get_opt_takes_arg(i) == "true") ? L_OARG() : L_NOARG()
		opt_nopt = sprintf("%s=\"%s\"", opt_nopt, opt_get_setter(i))
		
		make_case(sprintf("$%s", mvar), opt_nopt)
	}
	print_end_arg_cases()
}

function GET_ARGS() {return "get_args"}
function SHIFT() {return "shift"}
function print_get_args() {
print_ind_line(sprintf("%s %s", FUNC(), GET_ARGS()))
print_ind_line("{")

print_inc_indent()
print_ind_line("shopt -s extglob")
print_ind_line(sprintf("local %s=\"-*\"", L_UARG()))
new_line()
print_ind_line("while [ \"$#\" -gt 0 ]; do")

print_inc_indent()
print_ind_line(sprintf("local %s=\"\"", L_OARG()))
print_ind_line(sprintf("local %s=\"\"", L_NOARG()))
new_line()
print_ind_line("case \"$1\" in")

print_inc_indent()
print_cases()
print_dec_indent()
print_ind_line("esac")

new_line()
print_ind_line(sprintf("if [ ! -z \"$%s\" ]; then", L_OARG()))

print_inc_indent()
print_ind_line("if [ \"$#\" -lt 2 ] || [ \"${2:0:1}\" == \"-\" ]; then")

print_inc_indent()
print_ind_line("error_exit \"'$1' missing argument\"")
print_dec_indent()
print_ind_line("fi")
print_ind_line(sprintf("eval \"$%s '$1' '$2'\"", L_OARG()))
print_ind_line(sprintf("%s 2", SHIFT()))
print_dec_indent()

print_ind_line(sprintf("elif [ ! -z \"$%s\" ]; then", L_NOARG()))

print_inc_indent()
print_ind_line(sprintf("eval \"$%s '$1'\"", L_NOARG()))
print_ind_line(SHIFT())
print_dec_indent()
print_ind_line("else")

print_inc_indent()
print_ind_line(SHIFT())
print_dec_indent()
print_ind_line("fi")
print_dec_indent()
print_ind_line("done")
print_dec_indent()
print_ind_line("}")
}

function print_scr_help(    i, end, svar, lvar, str) {
print sprintf("%s print_help", FUNC())
print "{"

	end = get_opt_name_count()
	for (i = 1; i <= end; ++i) {
		svar = opt_get_short_var(i)
		lvar = opt_get_long_var(i)
		
		if (svar && lvar)
			str = sprintf("$%s, $%s", svar, lvar)
		else if (svar)
			str = sprintf("$%s", svar)
		else if (lvar)
			str = sprintf("$%s", lvar)
			
		print sprintf("%s \"%s\"", ECHO(), str)
		print sprintf("%s \"\"", ECHO())
	}

print "}"
}

function MAIN() {return "main"}
function print_main() {
print_ind_line(sprintf("%s %s", FUNC(), MAIN()))
print_ind_line("{")

print_inc_indent()
print_ind_line(sprintf("%s \"$@\"", GET_ARGS()))
print_dec_indent()
print_ind_line("}")
new_line()
print_ind_line(sprintf("%s \"$@\"", MAIN()))
}

function generate() {
	make_var_names()
	
	print_hdr(); new_line()
	print_base(); new_line()
	print_var_defn(); new_line()
	print_setters(); new_line()
	print_get_args(); new_line()
	print_scr_help(); new_line()
	print_main()
}

function init() {
	if (Help)
		print_help()
	if (Version)
		print_version()
	if (ARGC != 2)
		print_use_try()
}

function on_BEGIN() {
	init()
}

function on_END() {

}

# <user_messages>
function use_str() {
	return sprintf("Use: %s <input-file>", SCRIPT_NAME())
}

function print_use_try() {
	print_puts_err(use_str())
	print_puts_err(sprintf("Try '%s -vHelp=1' for more info", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print_puts(sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
	exit_success()
}

function print_help() {
print sprintf("--- %s %s ---", SCRIPT_NAME(), SCRIPT_VERSION())
print use_str()
print "A line oriented state machine parser."
print ""
print "Options:"
print "-vVersion=1 - print version"
print "-vHelp=1    - print this screen"
print ""
print "Rules:"
print "'->' means 'must be followed by'"
print "'|'  means 'or'"
print "Each line of the input file must begin with a rule."
print "The rules must appear in the below order of definition."
print "Empty lines and lines which start with '#' are ignored."
print ""
print "begin -> opt_name"
print "opt_name -> opt_takes_arg"
print "opt_takes_arg -> opt_short"
print "opt_short -> opt_long"
print "opt_long -> opt_name | end"
print "end -> begin"
	exit_success()
}
# </user_messages>
# </user_events>

# <user_print>
function print_ind_line(str, tabs) {print_tabs(tabs); print_puts(str)}
function print_ind_str(str, tabs) {print_tabs(tabs); print_stdout(str)}
function print_inc_indent() {print_set_indent(print_get_indent()+1)}
function print_dec_indent() {print_set_indent(print_get_indent()-1)}
function print_tabs(tabs,	 i, end) {
	end = tabs + print_get_indent()
	for (i = 1; i <= end; ++i)
		print_stdout("\t")
}
function print_new_lines(num,    i) {
	for (i = 1; i <= num; ++i)
		print_stdout("\n")
}

function print_set_indent(tabs) {__indent_count__ = tabs}
function print_get_indent(tabs) {return __indent_count__}
function print_puts(str) {__print_puts(str)}
function print_puts_err(str) {__print_puts_err(str)}
function print_stdout(str) {__print_stdout(str)}
function print_stderr(str) {__print_stderr(str)}
function print_set_stdout(str) {__print_set_stdout(str)}
function print_set_stderr(str) {__print_set_stderr(str)}
function print_get_stdout() {return __print_get_stdout()}
function print_get_stderr() {return __print_get_stderr()}
# </user_print>

# <user_error>
function error(msg) {__error(msg)}
function error_input(msg) {__error_input(msg)}
# </user_error>

# <user_exit>
function exit_success() {__exit_success()}
function exit_failure() {__exit_failure()}
# </user_exit>

# <user_utils>
function data_or_err() {
	if (NF < 2)
		error_input(sprintf("no data after '%s'", $1))
}

function reset_all() {
	reset_begin()
	reset_script_ver()
	reset_opt_name()
	reset_opt_takes_arg()
	reset_opt_short()
	reset_opt_long()
	reset_end()
}

function get_last_rule() {return __state_get()}

function save_begin(begin) {__begin_arr__[++__begin_num__] = begin}
function get_begin_count() {return __begin_num__}
function get_begin(num) {return __begin_arr__[num]}
function reset_begin() {delete __begin_arr__; __begin_num__ = 0}

function save_script_ver(script_ver) {__script_ver_arr__[++__script_ver_num__] = script_ver}
function get_script_ver_count() {return __script_ver_num__}
function get_script_ver(num) {return __script_ver_arr__[num]}
function reset_script_ver() {delete __script_ver_arr__; __script_ver_num__ = 0}

function save_opt_name(opt_name) {__opt_name_arr__[++__opt_name_num__] = opt_name}
function get_opt_name_count() {return __opt_name_num__}
function get_opt_name(num) {return __opt_name_arr__[num]}
function reset_opt_name() {delete __opt_name_arr__; __opt_name_num__ = 0}

function save_opt_takes_arg(opt_takes_arg) {__opt_takes_arg_arr__[++__opt_takes_arg_num__] = opt_takes_arg}
function get_opt_takes_arg_count() {return __opt_takes_arg_num__}
function get_opt_takes_arg(num) {return __opt_takes_arg_arr__[num]}
function reset_opt_takes_arg() {delete __opt_takes_arg_arr__; __opt_takes_arg_num__ = 0}

function save_opt_short(opt_short) {__opt_short_arr__[++__opt_short_num__] = opt_short}
function get_opt_short_count() {return __opt_short_num__}
function get_opt_short(num) {return __opt_short_arr__[num]}
function reset_opt_short() {delete __opt_short_arr__; __opt_short_num__ = 0}

function save_opt_long(opt_long) {__opt_long_arr__[++__opt_long_num__] = opt_long}
function get_opt_long_count() {return __opt_long_num__}
function get_opt_long(num) {return __opt_long_arr__[num]}
function reset_opt_long() {delete __opt_long_arr__; __opt_long_num__ = 0}

function save_end(end) {__end_arr__[++__end_num__] = end}
function get_end_count() {return __end_num__}
function get_end(num) {return __end_arr__[num]}
function reset_end() {delete __end_arr__; __end_num__ = 0}
# </user_utils>
# </user_api>
#==============================================================================#
#                        machine generated parser below                        #
#==============================================================================#
# <gen_parser>
# <gp_print>
function __print_set_stdout(f) {__gp_fout__ = ((f) ? f : "/dev/stdout")}
function __print_get_stdout() {return __gp_fout__}
function __print_stdout(str) {__print(str, __print_get_stdout())}
function __print_puts(str) {__print_stdout(sprintf("%s\n", str))}
function __print_set_stderr(f) {__gp_ferr__ = ((f) ? f : "/dev/stderr")}
function __print_get_stderr() {return __gp_ferr__}
function __print_stderr(str) {__print(str, __print_get_stderr())}
function __print_puts_err(str) {__print_stderr(sprintf("%s\n", str))}
function __print(str, file) {printf("%s", str) > file}
# </gp_print>
# <gp_exit>
function __exit_skip_end_set() {__exit_skip_end__ = 1}
function __exit_skip_end_clear() {__exit_skip_end__ = 0}
function __exit_skip_end_get() {return __exit_skip_end__}
function __exit_success() {__exit_skip_end_set(); exit(0)}
function __exit_failure() {__exit_skip_end_set(); exit(1)}
# </gp_exit>
# <gp_error>
function __error(msg) {
	__print_puts_err(sprintf("%s: error: %s", SCRIPT_NAME(), msg))
	__exit_failure()
}
function __error_input(msg) {
	__error(sprintf("file '%s', line %d: %s", FILENAME, FNR, msg))
}
function GP_ERROR_EXPECT() {return "'%s' expected, but got '%s' instead"}
function __error_parse(expect, got) {
	__error_input(sprintf(GP_ERROR_EXPECT(), expect, got))
}
# </gp_error>
# <gp_state_machine>
function __state_set(state) {__state__ = state}
function __state_get() {return __state__}
function __state_match(state) {return (__state_get() == state)}
function __state_transition(_next) {
	if (__state_match("")) {
		if (__R_BEGIN() == _next) __state_set(_next)
		else __error_parse(__R_BEGIN(), _next)
	}
	else if (__state_match(__R_BEGIN())) {
		if (__R_SCRIPT_VER() == _next) __state_set(_next)
		else __error_parse(__R_SCRIPT_VER(), _next)
	}
	else if (__state_match(__R_SCRIPT_VER())) {
		if (__R_OPT_NAME() == _next) __state_set(_next)
		else __error_parse(__R_OPT_NAME(), _next)
	}
	else if (__state_match(__R_OPT_NAME())) {
		if (__R_OPT_TAKES_ARG() == _next) __state_set(_next)
		else __error_parse(__R_OPT_TAKES_ARG(), _next)
	}
	else if (__state_match(__R_OPT_TAKES_ARG())) {
		if (__R_OPT_SHORT() == _next) __state_set(_next)
		else __error_parse(__R_OPT_SHORT(), _next)
	}
	else if (__state_match(__R_OPT_SHORT())) {
		if (__R_OPT_LONG() == _next) __state_set(_next)
		else __error_parse(__R_OPT_LONG(), _next)
	}
	else if (__state_match(__R_OPT_LONG())) {
		if (__R_OPT_NAME() == _next) __state_set(_next)
		else if (__R_END() == _next) __state_set(_next)
		else __error_parse(__R_OPT_NAME()"|"__R_END(), _next)
	}
	else if (__state_match(__R_END())) {
		if (__R_BEGIN() == _next) __state_set(_next)
		else __error_parse(__R_BEGIN(), _next)
	}
}
# </gp_state_machine>
# <gp_awk_rules>
function __R_BEGIN() {return "begin"}
function __R_SCRIPT_VER() {return "script_ver"}
function __R_OPT_NAME() {return "opt_name"}
function __R_OPT_TAKES_ARG() {return "opt_takes_arg"}
function __R_OPT_SHORT() {return "opt_short"}
function __R_OPT_LONG() {return "opt_long"}
function __R_END() {return "end"}

$1 == __R_BEGIN() {__state_transition($1); on_begin(); next}
$1 == __R_SCRIPT_VER() {__state_transition($1); on_script_ver(); next}
$1 == __R_OPT_NAME() {__state_transition($1); on_opt_name(); next}
$1 == __R_OPT_TAKES_ARG() {__state_transition($1); on_opt_takes_arg(); next}
$1 == __R_OPT_SHORT() {__state_transition($1); on_opt_short(); next}
$1 == __R_OPT_LONG() {__state_transition($1); on_opt_long(); next}
$1 == __R_END() {__state_transition($1); on_end(); next}
$0 ~ /^[[:space:]]*$/ {next} # ignore empty lines
$0 ~ /^[[:space:]]*#/ {next} # ignore comments
{__error_input(sprintf("'%s' unknown", $1))} # all else is error

function __init() {
	__print_set_stdout()
	__print_set_stderr()
	__exit_skip_end_clear()
}
BEGIN {
	__init()
	on_BEGIN()
}

END {
	if (!__exit_skip_end_get()) {
		if (__state_get() != __R_END())
			__error_parse(__R_END(), __state_get())
		else
			on_END()
	}
}
# </gp_awk_rules>
# </gen_parser>

# <user_input>
# Command line:
# -vScriptName=bash-opt-gen.awk
# -vScriptVersion=1.0
# Rules:
# begin -> script_ver
# script_ver -> opt_name
# opt_name -> opt_takes_arg
# opt_takes_arg -> opt_short
# opt_short -> opt_long
# opt_long -> opt_name | end
# end -> begin
# </user_input>
# generated by scriptscript.awk 2.21
