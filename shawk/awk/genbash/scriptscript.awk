#!/usr/bin/awk -f

# scriptscript.awk -- a	 parser generator
# for version look at SCRIPT_VERSION()
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2020-12-07

function SCRIPT_NAME() {return "scriptscript.awk"}
function SCRIPT_VERSION() {return "2.21"}

# <error_handling>
function error_bad_stx_msg(rule) {
	return sprintf("'%s' not a valid rule syntax; should match '%s'",
		rule, RL_REGX())
}
function error_syntax(str, line_no) {

	error_quit(sprintf("file '%s', line %d '%s': %s",
		FILENAME,
		line_no,
		in_line_get_by_actual_no(line_no),
		str))
}
function error_quit(msg) {
	print_stderr(sprintf("%s: error: %s", SCRIPT_NAME(), msg))
	exit_failure()
}
# </error_handling>

# <exit>
function exit_skip_end_set() {_B_skip_end = 1}
function exit_skip_end_get() {return _B_skip_end}
function exit_success() {exit_skip_end_set(); exit(0)}
function exit_failure() {exit_skip_end_set(); exit(1)}
# </exit>

# <input>
function RL_ARROW() {return "->"}
function RL_BAR() {return "|"}
function RL_REGX() {return "^[_[:alpha:]][_[:alnum:]]*$"}
function RL_MEM_FOLLOW() {return "follow"}
function RL_MEM_FLW_NUM() {return "num_of_follows"}
function RL_LINE_NO() {return "line_no"}

function in_rules_get_rules_count() {
	return _B_in_rules_count
}
function in_rules_save_rule(rule, line_no, line_str) {
	_B_in_rules_list[++_B_in_rules_count] = rule
	_B_in_rules_list[rule, RL_LINE_NO()] = line_no
}
function in_rules_save_flw_count(rule, flw_count) {
	_B_in_rules_list[rule, RL_MEM_FLW_NUM()] = flw_count
}
function in_rules_save_flw(rule, flw, flw_num) {
	_B_in_rules_list[rule, RL_MEM_FOLLOW(), flw_num] = flw
}
function in_rules_get_rule_name(n) {
	return _B_in_rules_list[n]
}
function in_rules_get_rule_line_no(rule) {
	return _B_in_rules_list[rule, RL_LINE_NO()]
}
function in_rules_get_flw_count(rule) {
	return _B_in_rules_list[rule, RL_MEM_FLW_NUM()]
}
function in_rules_get_flw(rule, flw_num) {
	return _B_in_rules_list[rule, RL_MEM_FOLLOW(), flw_num]
}
function in_rules_is_defined(rule,    i, end) {
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		if (in_rules_get_rule_name(i) == rule)
			return 1
	}
	return 0
}

function RL_ACTUAL_LNUM() {return "actual_line_no"}
function in_line_save(str, line_no) {
	_B_in_lines[++_B_in_next_line] = str
	_B_in_lines[RL_ACTUAL_LNUM(), line_no] = str
}
function in_line_get_count() {return _B_in_next_line}
function in_line_get_by_actual_no(n) {return _B_in_lines[RL_ACTUAL_LNUM(), n]}
function in_line_get_by_order(n) {return _B_in_lines[n]}

function in_process(line_str, line_no,    rule, rest, arr_spl, flw_count, i) {

	# remember original source line
	in_line_save(line_str, line_no)
	
	# remove spaces
	gsub(/[[:space:]]+/, "", line_str)

	# split rule from rest
	if (split(line_str, arr_spl, RL_ARROW()) != 2)
		error_syntax(sprintf("missing '%s'", RL_ARROW()), line_no)

	rule = arr_spl[1]
	rest = arr_spl[2]
	
	# check rule syntax
	if (!match(rule, RL_REGX()))
		error_syntax(error_bad_stx_msg(rule), line_no)
	
	if (!rest)
		error_syntax(sprintf("no follow up after rule '%s'", rule), line_no)
	
	if (in_rules_is_defined(rule))
		error_syntax(sprintf("rule '%s' redefined", rule), line_no)
		
	# save rule and line number for later error reporting
	in_rules_save_rule(rule, line_no)
	
	# split rule follow ups
	flw_count = split(rest, arr_spl, RL_BAR())
	in_rules_save_flw_count(rule, flw_count)
	
	for (i = 1; i <= flw_count; ++i) {
	
		if (match(arr_spl[i], RL_REGX()))
			in_rules_save_flw(rule, arr_spl[i], i)
		else
			error_syntax(error_bad_stx_msg(arr_spl[i]), line_no)
	}
}

$0 ~ /^[[:space:]]*$/ {next} # skip empty lines
$0 ~ /^[[:space:]]*#/ {next} # skip comments
{in_process($0, FNR)} # non-comments
# </input>

# <output>
function out_tabs(n,	i) {for (i = 0; i < n; ++i) printf("\t")}
function out_string(str, tabs) {out_tabs(tabs); printf("%s", str)}
function out_line(str, tabs) {out_tabs(tabs); print str}
function out_open_else(tabs) {out_line("else {", tabs)}
function out_close_block(tabs) {out_line("}", tabs)}
function out_open_tag(what) {out_line(sprintf("# <%s>", what))}
function out_close_tag(what) {out_line(sprintf("# </%s>", what))}
function out_get_rule_name(rule) {return sprintf("__R_%s", toupper(rule))}
function out_get_handler_name(what) {return "on_" what}

function out_fline(name, params, code) {
	out_line(sprintf("function %s(%s) {%s}", name, params, code))
}

function out_open_function(name, params) {
	out_line(sprintf("function %s(%s) {", name, params))
}

function out_open_if(condition, tabs) {
	out_line(sprintf("if (%s) {", condition), tabs)
}

function out_open_else_if(condition, tabs) {
	out_line(sprintf("else if (%s) {", condition), tabs)
}

function out_all() {
	out_header()
	out_line()
	out_script_info()
	out_line()
	out_user_api()
	out_divide()
	out_gen_parser()
	out_line()
	out_footer()
}

function out_header() {
	out_line("#!/usr/bin/awk -f")
}

function out_script_info() {
	out_fline(GEN_SCR_NM(), "", sprintf("return \"%s\"", ScriptName))
	out_fline(GEN_SCR_VER(), "", sprintf("return \"%s\"", ScriptVersion))
}

# <user_api>
function USER_API_TAG() {return "user_api"}
function out_user_api() {
	
	out_open_user_api()
	
	out_user_events()
	out_line()
	out_user_print()
	out_line()
	out_user_error()
	out_line()
	out_user_exit()
	out_line()
	out_utils()
	
	out_close_user_api()
}

function out_open_user_api() {out_open_tag(USER_API_TAG())}
function out_close_user_api() {out_close_tag(USER_API_TAG())}

# <user_events>
function USER_EVENTS_TAG() {return "user_events"}
function USER_EVENTS_BEGIN() {return "on_BEGIN"}
function USER_EVENTS_END() {return "on_END"}
function USER_EVENTS_INIT() {return "init"}
function USER_EVENTS_DATA_OR_ERR() {return "data_or_err"}

function out_user_events(	  str, i, end) {

	out_user_events_open()
	
	out_user_events_handlers()
	out_line()
	out_user_events_init()
	out_line()
	out_user_events_begin()
	out_line()
	out_user_events_end()
	out_line()
	out_user_messages()
	
	out_user_events_close()
}

function out_user_events_open() {out_open_tag(USER_EVENTS_TAG())}
function out_user_events_close() {out_close_tag(USER_EVENTS_TAG())}

function out_user_events_handlers(    str, i, end) {
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		str = in_rules_get_rule_name(i)
		out_open_function(out_get_handler_name(str))
		out_line(sprintf("%s()", USER_EVENTS_DATA_OR_ERR()), 1)
		out_line(sprintf("save_%s($2)", str), 1)
		out_line()
		out_close_block()
		
		if (i != end)
			out_line()
	}
}

function HELP_STR() {return "Help"}
function VER_STR() {return "Version"}

function out_user_events_init() {	

	out_open_function(USER_EVENTS_INIT())
	out_line(sprintf("if (%s)", HELP_STR()), 1)
	out_line(sprintf("%s()", USER_MESSAGES_HELP()), 2)
	
	out_line(sprintf("if (%s)", VER_STR()), 1)
	out_line(sprintf("%s()", USER_MESSAGES_VER()), 2)
	
	out_line("if (ARGC != 2)", 1)
	out_line(sprintf("%s()", USER_MESSAGES_USE_TRY()), 2)
	out_close_block()
}

function out_user_events_begin() {
	out_open_function(USER_EVENTS_BEGIN())
	out_line(sprintf("%s()", USER_EVENTS_INIT()), 1)
	out_close_block()
}

function out_user_events_end() {
	out_open_function(USER_EVENTS_END())
	out_line()
	out_close_block()
}
# </user_events>

# <user_print>
function PRINT() {return "print"}
function USER_PRINT_TAG() {return sprintf("user_%s", PRINT())}
function USER_PRINT_IND_VAR() {return "__indent_count__"}
function USER_PRINT_IND_LINE() {return sprintf("%s_ind_line", PRINT())}
function USER_PRINT_IND_STRING() {return sprintf("%s_ind_str", PRINT())}
function USER_PRINT_INC_IND() {return sprintf("%s_inc_indent", PRINT())}
function USER_PRINT_DEC_IND() {return sprintf("%s_dec_indent", PRINT())}
function USER_PRINT_TABS() {return sprintf("%s_tabs", PRINT())}
function USER_PRINT_NEW_LINES() {return sprintf("%s_new_lines", PRINT())}
function USER_PRINT_SET_IND() {return sprintf("%s_set_indent", PRINT())}
function USER_PRINT_GET_IND() {return sprintf("%s_get_indent", PRINT())}
function USER_PRINT_PUTS() {return sprintf("%s_puts", PRINT())}
function USER_PRINT_PUTS_ERR() {return sprintf("%s_puts_err", PRINT())}
function USER_PRINT_STDOUT() {return sprintf("%s_stdout", PRINT())}
function USER_PRINT_STDERR() {return sprintf("%s_stderr", PRINT())}
function USER_PRINT_SET_OUT() {return sprintf("%s_set_stdout", PRINT())}
function USER_PRINT_SET_ERR() {return sprintf("%s_set_stderr", PRINT())}
function USER_PRINT_GET_OUT() {return sprintf("%s_get_stdout", PRINT())}
function USER_PRINT_GET_ERR() {return sprintf("%s_get_stderr", PRINT())}


function out_user_print() {
	
	out_open_tag(USER_PRINT_TAG())
	
	out_fline(USER_PRINT_IND_LINE(), "str, tabs",
		sprintf("%s(tabs); %s(str)", USER_PRINT_TABS(), USER_PRINT_PUTS()))
	out_fline(USER_PRINT_IND_STRING(), "str, tabs",
		sprintf("%s(tabs); %s(str)", USER_PRINT_TABS(), USER_PRINT_STDOUT()))

	out_fline(USER_PRINT_INC_IND(), "",
		sprintf("%s(%s()+1)", USER_PRINT_SET_IND(), USER_PRINT_GET_IND()))
	out_fline(USER_PRINT_DEC_IND(), "",
		sprintf("%s(%s()-1)", USER_PRINT_SET_IND(), USER_PRINT_GET_IND()))
		
	out_open_function(USER_PRINT_TABS(), "tabs,	 i, end")
	out_line("end = tabs + " USER_PRINT_GET_IND() "()", 1)
	out_line("for (i = 1; i <= end; ++i)", 1)
	out_line(sprintf("%s(\"\\t\")", USER_PRINT_STDOUT()), 2)
	out_close_block()

	out_open_function(USER_PRINT_NEW_LINES(), "num,    i")
	out_line("for (i = 1; i <= num; ++i)", 1)
	out_line(sprintf("%s(\"\\n\")", USER_PRINT_STDOUT()), 2)
	out_close_block()
	
	out_line()
	
	out_fline(USER_PRINT_SET_IND(), "tabs",
		sprintf("%s = tabs", USER_PRINT_IND_VAR()))
	out_fline(USER_PRINT_GET_IND(), "tabs",
		sprintf("return %s", USER_PRINT_IND_VAR()))
		
	out_fline(USER_PRINT_PUTS(), "str", sprintf("%s(str)", GP_PRINT_PUTS()))
	out_fline(USER_PRINT_PUTS_ERR(), "str", sprintf("%s(str)",
		GP_PRINT_PUTS_ERR()))
		
	out_fline(USER_PRINT_STDOUT(), "str", sprintf("%s(str)",
		GP_PRINT_PRINT_OUT()))
	out_fline(USER_PRINT_STDERR(), "str", sprintf("%s(str)",
		GP_PRINT_PRINT_ERR()))
	
	out_fline(USER_PRINT_SET_OUT(), "str", sprintf("%s(str)",
		GP_PRINT_SET_OUT()))
	out_fline(USER_PRINT_SET_ERR(), "str", sprintf("%s(str)",
		GP_PRINT_SET_ERR()))
	
	out_fline(USER_PRINT_GET_OUT(), "", sprintf("return %s()",
		GP_PRINT_GET_OUT()))
	out_fline(USER_PRINT_GET_ERR(), "", sprintf("return %s()",
		GP_PRINT_GET_ERR()))
	
	out_close_tag(USER_PRINT_TAG())
}
# </user_print>

# <user_messages>
function USER_MESSAGES_TAG() {return "user_messages"}

function USER_MESSAGES_USE_TRY() {return sprintf("%s_use_try", PRINT())}
function USER_MESSAGES_HELP() {return sprintf("%s_help", PRINT())}
function USER_MESSAGES_VER() {return sprintf("%s_version", PRINT())}
function USER_MESSAGES_USE_STR() {return "use_str"}

function out_user_messages() {

	out_user_messages_open()
	
	out_user_messages_use()
	out_line()
	out_user_messages_use_try()
	out_line()
	out_user_messages_print_version()
	out_line()
	out_user_messages_print_help()
	
	out_user_messages_close()
}

function out_user_messages_open() {out_open_tag(USER_MESSAGES_TAG())}
function out_user_messages_close() {out_close_tag(USER_MESSAGES_TAG())}

function out_user_messages_use() {
	
	out_open_function(USER_MESSAGES_USE_STR())
	out_line(sprintf("return sprintf(\"Use: %%s <input-file>\", %s())",
		GEN_SCR_NM()), 1)
	out_close_block()
}

function out_user_messages_use_try() {
	out_open_function(USER_MESSAGES_USE_TRY())
	out_line(sprintf("%s(%s())",
		USER_PRINT_PUTS_ERR(), USER_MESSAGES_USE_STR()),
	1)
	out_line(sprintf("%s(sprintf(\"Try '%%s -v%s=1' for more info\", %s()))",
		USER_PRINT_PUTS_ERR(), HELP_STR(), GEN_SCR_NM()),
	1)
	out_line(sprintf("%s()", USER_EXIT_FAILURE()), 1)
	out_close_block()
}

function out_user_messages_print_version() {
	out_open_function(USER_MESSAGES_VER())
	out_line(sprintf("%s(sprintf(\"%%s %%s\", %s(), %s()))",
		USER_PRINT_PUTS(), GEN_SCR_NM(), GEN_SCR_VER()),
	1)
	
	out_line(sprintf("%s()", USER_EXIT_SUCCESS()), 1)
	out_close_block()
}

function out_user_messages_print_help() {
	out_open_function(USER_MESSAGES_HELP())
out_line(sprintf("print sprintf(\"--- %%s %%s ---\", %s(), %s())",
	GEN_SCR_NM(), GEN_SCR_VER()))
out_line(sprintf("print %s()", USER_MESSAGES_USE_STR()))
out_line("print \"A line oriented state machine parser.\"")
out_line("print \"\"")
out_line("print \"Options:\"")
out_line(sprintf("print \"-v%s=1 - print version\"", VER_STR()))
out_line(sprintf("print \"-v%s=1    - print this screen\"", HELP_STR()))
out_line("print \"\"")
out_line("print \"Rules:\"")
out_line("print \"'->' means 'must be followed by'\"")
out_line("print \"'|'  means 'or'\"")
out_line("print \"Each line of the input file must begin with a rule.\"")
out_line("print \"The rules must appear in the below order of definition.\"")
out_line("print \"Empty lines and lines which start with '#' are ignored.\"")
out_line("print \"\"")
	end = in_line_get_count()
	for (i = 1; i <= end; ++i)
		out_line(sprintf("print \"%s\"", in_line_get_by_order(i)))
	
	out_line(sprintf("%s()", USER_EXIT_SUCCESS()), 1)
	out_close_block()
}
# </user_messages>

# <user_error>
function ERROR() {return "error"}
function USER_ERROR_TAG() {return "user_error"}
function USER_ERROR() {return ERROR()}
function USER_ERROR_FINPUT() {return sprintf("%s_input", USER_ERROR())}

function out_user_error() {
	out_open_tag(USER_ERROR_TAG())
	
	out_fline(USER_ERROR(), "msg", sprintf("%s(msg)", GP_ERROR_BASE()))
	out_fline(USER_ERROR_FINPUT(), "msg", sprintf("%s(msg)", GP_ERROR_INPUT()))
	
	out_close_tag(USER_ERROR_TAG())
}
# </user_error>

# <user_exit>
function EXIT() {return "exit"}
function USER_EXIT_TAG() {return sprintf("user_%s", EXIT())}
function USER_EXIT_SUCCESS() {return sprintf("%s_success", EXIT())}
function USER_EXIT_FAILURE() {return sprintf("%s_failure", EXIT())}

function out_user_exit() {
	out_open_tag(USER_EXIT_TAG())
	
	out_fline(USER_EXIT_SUCCESS(), "", sprintf("%s()", GP_EXIT_SUCCESS()))
	out_fline(USER_EXIT_FAILURE(), "", sprintf("%s()", GP_EXIT_FAIL()))
	
	out_close_tag(USER_EXIT_TAG())
}
# </user_exit>

# <user_utils>
function USER_UTILS_TAG() {return "user_utils"}
function USER_UTILS_GET_LAST_RULE() {return "get_last_rule"}

function out_utils() {
	out_utils_open()
		
	out_utils_data_or_err()
	out_line()	
	out_utils_reset_all()
	out_line()
	out_utils_get_last_rule_name()
	out_line()
	out_utils_save_gets()
	
	out_utils_close()
}

function out_utils_open() {out_open_tag(USER_UTILS_TAG())}
function out_utils_close() {out_close_tag(USER_UTILS_TAG())}

function out_utils_data_or_err() {
	out_open_function(USER_EVENTS_DATA_OR_ERR())
	out_line("if (NF < 2)", 1)
	out_line(sprintf("%s(sprintf(\"no data after '%%s'\", $1))", 
	   USER_ERROR_FINPUT()), 2)
	out_close_block()
}

function out_utils_reset_all(    i, end) {
	end = in_rules_get_rules_count()
	out_open_function("reset_all")
	for (i = 1; i <= end; ++i)
		out_line(sprintf("reset_%s()", in_rules_get_rule_name(i)), 1)
	out_close_block()
}

function out_utils_get_last_rule_name() {
	out_fline(USER_UTILS_GET_LAST_RULE(), "",
		sprintf("return %s()", GP_STATE_MACHINE_GET()))
}

function out_utils_save_gets(    i, end, tmp, tmp_arr_name, tmp_num) {
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		tmp = in_rules_get_rule_name(i)
		
		tmp_arr_name = sprintf("__%s_arr__", tmp)
		tmp_num = sprintf("__%s_num__", tmp)
		
		out_fline(sprintf("save_%s", tmp), tmp,
			sprintf("%s[++%s] = %s", tmp_arr_name, tmp_num, tmp))
		
		out_fline(sprintf("get_%s_count", tmp), "",
			sprintf("return %s", tmp_num))
		
		out_fline(sprintf("get_%s", tmp), "num",
			sprintf("return %s[num]", tmp_arr_name))
		
		out_fline(sprintf("reset_%s", tmp), "",
			sprintf("delete %s; %s = 0", tmp_arr_name, tmp_num))
			
		if (i != end)
			out_line()
	}
}
# </user_utils>
# </user_api>

# <divide>
function out_divide(	i, end) {
	out_string("#")
	end = 78
	for (i = 1; i <= end; ++i) { out_string("=") }
	out_string("#\n")
	
	out_string("#")
	end = 24
	for (i = 1; i <= end; ++i) { out_string(" ") }
	out_string("machine generated parser below")
	for (i = 1; i <= end; ++i) { out_string(" ") }
	out_string("#\n")
	
	out_string("#")
	end = 78
	for (i = 1; i <= end; ++i) { out_string("=") }
	out_string("#\n")
}
# </divide>

# <gen_parser>
function GEN_PARSER_TAG() {return "gen_parser"}
function out_gen_parser() {
	
	out_open_gen_parser()
	
	out_gp_print()
	out_gp_exit()
	out_gp_error()
	out_gp_state_machine()
	out_gp_awk_rules()
	
	out_close_gen_parser()
}

function out_open_gen_parser() {out_open_tag(GEN_PARSER_TAG())}
function out_close_gen_parser() {out_close_tag(GEN_PARSER_TAG())}

# <gp_print>
function GP_PRINT_BASE() {return PRINT()}
function GP_PRINT_STDOUT() {return "stdout"}
function GP_PRINT_DEVOUT() {return "\"/dev/stdout\""}
function GP_PRINT_DEVERR() {return "\"/dev/stderr\""}
function GP_PRINT_STDERR() {return "stderr"}
function GP_PRINT_TAG() {return sprintf("gp_%s", PRINT())}
function GP_PRINT_ERR_VAR() {return "__gp_ferr__"}
function GP_PRINT_OUT_VAR() {return "__gp_fout__"}

function GP_PRINT_SET_OUT() {
	return sprintf("__%s_set_%s", GP_PRINT_BASE(), GP_PRINT_STDOUT())
}
function GP_PRINT_GET_OUT() {
	return sprintf("__%s_get_%s", GP_PRINT_BASE(), GP_PRINT_STDOUT())
}
function GP_PRINT_PRINT_OUT() {
	return sprintf("__%s_%s", GP_PRINT_BASE(), GP_PRINT_STDOUT())
}
function GP_PRINT_PUTS(){
	return sprintf("%s_puts", GP_PRINT_PRINT_BASE())
}
function GP_PRINT_SET_ERR() {
	return sprintf("__%s_set_%s", GP_PRINT_BASE(), GP_PRINT_STDERR())
}
function GP_PRINT_GET_ERR() {
	return sprintf("__%s_get_%s", GP_PRINT_BASE(), GP_PRINT_STDERR())
}
function GP_PRINT_PRINT_ERR() {
	return sprintf("__%s_%s", GP_PRINT_BASE(), GP_PRINT_STDERR())
}
function GP_PRINT_PUTS_ERR(){
	return sprintf("%s_puts_err", GP_PRINT_PRINT_BASE())
}
function GP_PRINT_PRINT_BASE() {
	return sprintf("__%s", GP_PRINT_BASE())
}

function out_gp_print() {
	
	out_gp_print_open()
	
	out_gp_print_stdout()
	out_gp_print_stderr()
	out_gp_print_print()
	
	out_gp_print_close()
}

function out_gp_print_open() {out_open_tag(GP_PRINT_TAG())}
function out_gp_print_close() {out_close_tag(GP_PRINT_TAG())}

function out_gp_print_stdout() {
	out_fline(GP_PRINT_SET_OUT(), "f",
		sprintf("%s = ((f) ? f : %s)",
			GP_PRINT_OUT_VAR(), GP_PRINT_DEVOUT()))
	
	out_fline(GP_PRINT_GET_OUT(), "", sprintf("return %s", GP_PRINT_OUT_VAR()))
	
	out_fline(GP_PRINT_PRINT_OUT(), "str",
		sprintf("%s(str, %s())", GP_PRINT_PRINT_BASE(), GP_PRINT_GET_OUT()))
		
	out_fline(GP_PRINT_PUTS(), "str",
		sprintf("%s(sprintf(\"%%s\\n\", str))", GP_PRINT_PRINT_OUT()))
}

function out_gp_print_stderr() {
	out_fline(GP_PRINT_SET_ERR(), "f",
		sprintf("%s = ((f) ? f : %s)",
			GP_PRINT_ERR_VAR(), GP_PRINT_DEVERR()))
	
	out_fline(GP_PRINT_GET_ERR(), "", sprintf("return %s", GP_PRINT_ERR_VAR()))
	
	out_fline(GP_PRINT_PRINT_ERR(), "str",
		sprintf("%s(str, %s())", GP_PRINT_PRINT_BASE(), GP_PRINT_GET_ERR()))
		
	out_fline(GP_PRINT_PUTS_ERR(), "str", 
		sprintf("%s(sprintf(\"%%s\\n\", str))", GP_PRINT_PRINT_ERR()))
}

function out_gp_print_print() {
	out_fline(GP_PRINT_PRINT_BASE(), "str, file", "printf(\"%s\", str) > file")
}
# </gp_print>

# <gp_exit>
function GP_EXIT_TAG() {return sprintf("gp_%s", EXIT())}
function GP_EXIT_SKIP_END_VAR() {return sprintf("__%s__", GP_EXIT_SKIP_END())}
function GP_EXIT_SKIP_END() {return sprintf("%s_skip_end", EXIT())}
function GP_EXIT_SKIP_FBASE() {return sprintf("__%s", GP_EXIT_SKIP_END())}
function GP_EXIT_SKIP_END_FSET() {
	return sprintf("%s_set", GP_EXIT_SKIP_FBASE())
}
function GP_EXIT_SKIP_END_FCLEAR() {
	return sprintf("%s_clear", GP_EXIT_SKIP_FBASE())
}
function GP_EXIT_SKIP_END_FGET() {
	return sprintf("%s_get", GP_EXIT_SKIP_FBASE())
}
function GP_EXIT_FAIL() {return sprintf("__%s_failure", EXIT())}
function GP_EXIT_SUCCESS() {return sprintf("__%s_success", EXIT())}

function out_gp_exit() {
	out_open_tag(GP_EXIT_TAG())

	out_fline(GP_EXIT_SKIP_END_FSET(), "", 
		sprintf("%s = 1", GP_EXIT_SKIP_END_VAR()))
	
	out_fline(GP_EXIT_SKIP_END_FCLEAR(), "",
		sprintf("%s = 0", GP_EXIT_SKIP_END_VAR()))
	
	out_fline(GP_EXIT_SKIP_END_FGET(), "",
		sprintf("return %s", GP_EXIT_SKIP_END_VAR()))
	
	out_fline(GP_EXIT_SUCCESS(), "",
		sprintf("%s(); %s(0)", GP_EXIT_SKIP_END_FSET(), EXIT()))
	
	out_fline(GP_EXIT_FAIL(), "",
		sprintf("%s(); %s(1)", GP_EXIT_SKIP_END_FSET(), EXIT()))
	
	out_close_tag(GP_EXIT_TAG())
}
# </gp_exit>

# <gp_error>
function GP_ERROR_TAG() {return sprintf("gp_%s", ERROR())}
function GP_ERROR() {return ERROR()}
function GP_ERROR_BASE() {return sprintf("__%s", GP_ERROR())}
function GP_ERROR_INPUT() {return sprintf("%s_input", GP_ERROR_BASE())}
function GP_ERROR_PARSE() {return sprintf("%s_parse", GP_ERROR_BASE())}
function GP_ERROR_EXPECT() {return "GP_ERROR_EXPECT"}

function out_gp_error(	   spf_str, expect_str) {
	out_open_tag(GP_ERROR_TAG())

	out_open_function(GP_ERROR_BASE(), "msg")
	out_line(sprintf("%s(sprintf(\"%%s: error: %%s\", %s(), msg))",
		GP_PRINT_PUTS_ERR(), GEN_SCR_NM()),
	1)
	out_line(sprintf("%s()", GP_EXIT_FAIL()), 1)
	out_close_block()
	
	out_open_function(GP_ERROR_INPUT(), "msg")
	spf_str = "sprintf(\"file '%s', line %d: %s\", FILENAME, FNR, msg)"
	out_line(sprintf("%s(%s)", GP_ERROR_BASE(), spf_str), 1)
	out_close_block()
	
	expect_str = "\"'%s' expected, but got '%s' instead\""
	out_fline(GP_ERROR_EXPECT(), "", sprintf("return %s", expect_str))
		
	out_open_function(GP_ERROR_PARSE(), "expect, got")
	spf_str = sprintf("sprintf(%s(), expect, got)", GP_ERROR_EXPECT())
	out_line(sprintf("%s(%s)", GP_ERROR_INPUT(), spf_str), 1)
	out_close_block()
	
	out_close_tag(GP_ERROR_TAG())
}
# </gp_error>

# <gp_state_machine>
function _NEXT() {return "_next"}
function STATE() {return "state"}
function GP_STATE_MACHINE_TAG() {return sprintf("gp_%s_machine", STATE())}
function GP_STATE_MACHINE_BASE() {return sprintf("__%s", STATE())}
function GP_STATE_MACHINE_SET() {
	return sprintf("%s_set", GP_STATE_MACHINE_BASE())
}
function GP_STATE_MACHINE_GET() {
	return sprintf("%s_get", GP_STATE_MACHINE_BASE())
}
function GP_STATE_MACHINE_MATCH() {
	return sprintf("%s_match", GP_STATE_MACHINE_BASE())
}
function GP_STATE_MACHINE_TRANSITION() {return "__state_transition"}
function GP_STATE_MACHINE_VAR() {return sprintf("__%s__", STATE())}

function out_gp_state_machine() {	
	out_gp_state_machine_open()
	
	out_gp_state_machine_set_get()
	out_gp_state_machine_transition()
	
	out_gp_state_machine_close()
}

function out_gp_state_machine_open() {out_open_tag(GP_STATE_MACHINE_TAG())}
function out_gp_state_machine_close() {out_close_tag(GP_STATE_MACHINE_TAG())}

function out_gp_state_machine_set_get() {
	out_fline(GP_STATE_MACHINE_SET(), STATE(),
		sprintf("%s = %s", GP_STATE_MACHINE_VAR(), STATE()))

	out_fline(GP_STATE_MACHINE_GET(), "",
		sprintf("return %s", GP_STATE_MACHINE_VAR()))
	
	out_fline(GP_STATE_MACHINE_MATCH(), STATE(), 
		sprintf("return (%s() == %s)", GP_STATE_MACHINE_GET(), STATE()))
}

function out_gp_state_machine_transition(    i, end) {

	out_open_function(GP_STATE_MACHINE_TRANSITION(), _NEXT())
	
	out_gp_state_machine_first()
	
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i)
		out_gp_state_machine_next(in_rules_get_rule_name(i))

	out_close_block()
}

function out_gp_state_machine_first(    first_rule, out_rule_name) {
	out_open_if(sprintf("%s(\"\")", GP_STATE_MACHINE_MATCH()), 1)
	
	first_rule = in_rules_get_rule_name(1)
	out_rule_name = out_get_rule_name(first_rule)
	
	out_string(sprintf("if (%s() == %s) ", out_rule_name, _NEXT()), 2)
	out_gp_state_machine_state_change()
	out_line(sprintf("else %s(%s(), %s)",
		GP_ERROR_PARSE(), out_rule_name, _NEXT()),
	2)
	out_close_block(1)
}

function out_gp_state_machine_next(rule,
    i, end, in_rule_flw, out_rule_name, if_type, err_str) {
	
	out_rule_name = out_get_rule_name(rule)
	out_open_else_if(sprintf("%s(%s())",
		GP_STATE_MACHINE_MATCH(), out_rule_name),
	1)
		
	err_str = ""
	end = in_rules_get_flw_count(rule)
	for (i = 1; i <= end; ++i) {
		in_rule_flw = in_rules_get_flw(rule, i)
		out_rule_name = out_get_rule_name(in_rule_flw)
		
		if_type = "if (%s() == %s) "
		if (i > 1)
			if_type = sprintf("else %s", if_type)
			
		out_string(sprintf(if_type, out_rule_name, _NEXT()), 2)
		out_gp_state_machine_state_change()
			
		err_str = (!err_str) ?
			sprintf("%s()", out_rule_name) :
				sprintf("%s\"|\"%s()", err_str, out_rule_name)
	}
	
	out_line(sprintf("else %s(%s, %s)",
		GP_ERROR_PARSE(), err_str, _NEXT()),
	2)
	out_close_block(1)
}

function out_gp_state_machine_state_change(tabs) {
	out_line(sprintf("%s(%s)", GP_STATE_MACHINE_SET(), _NEXT()), tabs)
}
# </gp_state_machine>

# <gp_awk_rules>
function GP_AWK_RULES_TAG() {return "gp_awk_rules"}

function out_gp_awk_rules() {
	
	out_gp_awk_rules_open()
	
	out_gp_awk_rules_constans()
	out_line()
	out_gp_awk_rules_line_rules()
	out_line()
	out_gp_awk_rules_begin()
	out_line()
	out_gp_awk_rules_end()
	
	out_gp_awk_rules_close()
}

function out_gp_awk_rules_open() {out_open_tag(GP_AWK_RULES_TAG())}
function out_gp_awk_rules_close() {out_close_tag(GP_AWK_RULES_TAG())}

function out_gp_awk_rules_constans() {
		
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		rule_name = in_rules_get_rule_name(i)
		
		out_fline(out_get_rule_name(rule_name), "",
			sprintf("return \"%s\"", rule_name))
	}
}

function out_gp_awk_rules_line_rules(    i, end, rule_name, rule_line) {
	
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		rule_name = in_rules_get_rule_name(i)
		
		rule_line = sprintf("$1 == %s() {%s($1); %s(); next}",
			out_get_rule_name(rule_name),
			GP_STATE_MACHINE_TRANSITION(),
			out_get_handler_name(rule_name))
		
		out_line(rule_line)
	}
	
	out_line("$0 ~ /^[[:space:]]*$/ {next} # ignore empty lines")
	out_line("$0 ~ /^[[:space:]]*#/ {next} # ignore comments")
	out_line(sprintf("{%s(sprintf(\"'%%s' unknown\", $1))} # all else is error",
		GP_ERROR_INPUT()))
}

function GEN_SCR_NM() {return "SCRIPT_NAME"}
function GEN_SCR_VER() {return "SCRIPT_VERSION"}
function GP_AWK_RULES_INIT() {return sprintf("__%s", "init")}

function out_gp_awk_rules_begin(    i, end, rule_name) {
		
	out_open_function(sprintf("%s", GP_AWK_RULES_INIT()))
	out_line(sprintf("%s()", GP_PRINT_SET_OUT()), 1)
	out_line(sprintf("%s()", GP_PRINT_SET_ERR()), 1)
	out_line(sprintf("%s()", GP_EXIT_SKIP_END_FCLEAR()), 1)
	out_close_block()
	
	out_line("BEGIN {")
	out_line(sprintf("%s()", GP_AWK_RULES_INIT()), 1)
	out_line(sprintf("%s()", USER_EVENTS_BEGIN()), 1)
	out_close_block()
}

function out_gp_awk_rules_end() {
	out_line("END {")
	out_line(sprintf("if (!%s()) {", GP_EXIT_SKIP_END_FGET()), 1)
	out_line(sprintf("if (%s() != %s())",
		GP_STATE_MACHINE_GET(),
		out_get_rule_name(in_rules_get_rule_name(in_rules_get_rules_count()))),
	2)
	out_line(sprintf("%s(%s(), %s())",
		GP_ERROR_PARSE(),
		out_get_rule_name(in_rules_get_rule_name(in_rules_get_rules_count())),
		GP_STATE_MACHINE_GET()),
	3)
	out_line("else", 2)
	out_line(sprintf("%s()", USER_EVENTS_END()), 3)
	out_close_block(1)
	out_close_block()
}
# </gp_awk_rules>

# <gp_user_input>
function USER_INPUT_TAG() {return "user_input"}
function out_source(	i, end) {
	out_open_tag(USER_INPUT_TAG())
	
	out_line("# Command line:")
	out_line(sprintf("# -v%s=%s", VSCRIPT_NAME(), ScriptName))
	out_line(sprintf("# -v%s=%s", VSCRIPT_VER(), ScriptVersion))
	
	out_line("# Rules:")
	end = in_line_get_count()
	for (i = 1; i <= end; ++i)
		out_line(sprintf("# %s", in_line_get_by_order(i)))
	out_close_tag(USER_INPUT_TAG())
}
# </gp_user_input>

function out_footer() {
	out_source()
	out_line(sprintf("# generated by %s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
}
# </output>

# <begin>	
function VSCRIPT_NAME() {return "ScriptName"}
function VSCRIPT_VER() {return "ScriptVersion"}

function print_stderr(str) {
	print str > "/dev/stderr"
}

function use_str() {
	return sprintf("Use: %s -v%s=<name> -v%s=<version> <rules-file>",
		SCRIPT_NAME(), VSCRIPT_NAME(), VSCRIPT_VER())
}

function print_use_try() {
	print_stderr(use_str())
	print_stderr(sprintf("Try '%s -vHelp=1' for help", SCRIPT_NAME()))
	exit_failure()
}

function print_help() {
print sprintf("--- %s %s ---", SCRIPT_NAME(), SCRIPT_VERSION())
print use_str()
print "Generates a line oriented state machine parser in awk."
print ""
print "Mandatory:"
print sprintf("-v%s=<name>       - the name of the generated script",
	VSCRIPT_NAME())
print sprintf("-v%s=<version> - the version of the generated script",
	VSCRIPT_VER())
print ""
print "Options:"
print sprintf("-v%s=1 - print this script version", VER_STR())
print sprintf("-v%s=1    - print this screen", HELP_STR())
	exit_success()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function init() {
	if (Help)
		print_help()
	
	if (Version)
		print_version()
	
	arg_check()
	
	if (!ScriptName) {
		error_quit(sprintf("%s not given; forgot -v%s=<name>?",
			VSCRIPT_NAME(), VSCRIPT_NAME()))
	}
	
	if (!ScriptVersion) {
		error_quit(sprintf("%s not given; forgot -v%s=<version>?",
			VSCRIPT_VER(), VSCRIPT_VER()))
	}
}

function arg_check(    i) {
	if (ARGC != 2)
		print_use_try()
}

BEGIN {
	init()
}
# </begin>

# <end>
function check_rule_count() {
	if (!in_rules_get_rules_count())
		error_quit(sprintf("input file '%s' has no rules", FILENAME))
}

function check_all_flw_defined(	   i, end, j, jend, rule, flw) {
	end = in_rules_get_rules_count()
	for (i = 1; i <= end; ++i) {
		rule = in_rules_get_rule_name(i)
		jend = in_rules_get_flw_count(rule)
		
		for (j = 1; j <= jend; ++j) {
			flw = in_rules_get_flw(rule, j)
			
			if (!in_rules_is_defined(flw)) {
				error_syntax(sprintf("'%s' rule undefined", flw),
					in_rules_get_rule_line_no(rule))
			}
		}
	}
}

function checks() {
	check_rule_count()
	check_all_flw_defined()
}

function generate() {
	out_all()
}

END {
	if (!exit_skip_end_get()) {
		checks()
		generate()
	}
}
# </end>
# </gen_parser>
