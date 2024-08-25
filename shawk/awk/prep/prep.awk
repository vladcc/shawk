#!/usr/bin/awk -f

# prep.awk -- prepares strings with positional arguments from the command line
# Vladimir Dinev
# vld.dinev@gmail.com
# 2021-10-03

# <prep_main>
function SCRIPT_NAME() {return "prep.awk"}
function SCRIPT_VERSION() {return "1.0"}

function init(    _res) {

	set_program_name(SCRIPT_NAME())
	
	if (Version) {
		print_version()
		exit_success()
	}
	
	if (Help) {
		print_help()
		exit_success()
	}
	
	Fields = (Fields) ? Fields : 2
	ReCheck = (ReCheck) ? ReCheck : ""
	Rsep = Rsep
	Nsep = Nsep
	Strict = Strict+0
	
	if (!Str)
		error_quit("-v Str=<str> must be given; try -v Help=1")
		
	if (ReCheck) {
		if (_res = sc_re_prepare(G_field_re_map, Fields, ReCheck, Rsep, Nsep))
			error_quit(_res)
	}
}

function do_prep(    _res, _i, _map) {
	
	if (_res = sc_check_str($0, Fields, FS, G_field_re_map, Strict))
		error_quit(sprintf("file '%s', line %d: %s", FILENAME, FNR, _res))
	
	for (_i = 0; _i <= NF; ++_i)
		_map[_i] = $_i
		
	print prep_str(Str, _map)
}

function print_version() {
	print (SCRIPT_NAME() " " SCRIPT_VERSION())
}

function print_help() {
print SCRIPT_NAME() " -- prepares strings with positional arguments from the command line"
print "Use: " SCRIPT_NAME() " -v Str=<str> [OPTIONS...]"
print ""
print "The idea:"
print "The user feeds a text file which is assumed to be an uniform table of arguments."
print SCRIPT_NAME() " then takes each line of this table and puts these arguments in its"
print "template string given by the '-v Str=<str>' option."
print ""
print "Example:"
print "Let's say the user wants to connect via ssh to a bunch of hosts on different"
print "ports with different usernames, execute the 'ls' command and redirect the output"
print "to separate files with name format <host>-<user>.txt"
print ""
print "$ cat data.txt"
print "user_a host_A 23"
print "user_b host_B 24"
print "user_c host_B 24"
print "user_d host_C 25"
print ""
print "then " SCRIPT_NAME() " can be used to generate the ssh commands like so:"
print ""
print "$ ./prep.awk -vFields=3 -vStr='ssh -n {1}@{2} -p {3} ls > {2}-{1}.txt' data.txt"
print "ssh -n user_a@host_A -p 23 ls > host_A-user_a.txt"
print "ssh -n user_b@host_B -p 24 ls > host_B-user_b.txt"
print "ssh -n user_c@host_B -p 24 ls > host_B-user_c.txt"
print "ssh -n user_d@host_C -p 25 ls > host_C-user_d.txt"
print ""
print "which can then be piped to bash, or executed in some other way, assuming ssh can"
print "login automatically. The positional arguments are always {<field-number>}. {0}"
print "means 'the whole line', much like '$0' is the whole input like in awk. The"
print "arguments can be switched around and repeated as needed."
print ""
print "Options:"
print "All options are passed in the '-v <variable>=<value>' awk fashion."
print ""
print "-v Str=<str>"
print "The template string whose positional arguments get replaced by the fileds of"
print "the input file."
print ""
print "-v Fields=<num>"
print "Used to make sure every line of the input file has exactly <num> number of"
print "fields. Defaults to 2 if not given."
print ""
print "-v ReCheck=<field-num-to-regex-map>"
print "If givem, used to match the fields of each input line to a given regex, thus"
print "providing a basic syntax checking. The syntax of <field-num-to-regex-map> is as"
print "per awklib_str_check.awk:"
print SC_SYNTAX()
print ""
print "-v Rsep=<rsep>"
print "Used to separate the field-regex pairs. Default is ';' Needs to be changed if"
print "any regex contains a ';'"
print ""
print "-v Nsep=<nse>"
print "Used to separate the field number from the regex. Default is '=' Needs to be"
print "changed if any regex contains a '='"
print ""
print "-v Strict=1"
print "If given, the <field-num-to-regex-map> of ReCheck must cover all input fields."
print ""
print "-v Help=1    - print this screen"
print "-v Version=1 - print version info"
}

BEGIN {init()}
{do_prep()}
# </prep_main>
#@ <awklib_prep>
#@ Library: prep
#@ Description: Prepares strings by replacing named arguments.
#@ By default, the argument needs to appear between '{}' and can be any
#@ string. The argument name is matched as a regular expression. I.e.
#@ the default format for the named arguments is the printf string
#@ "[{]%s[}]" which, after being processed by 'sprintf()', is matched as
#@ a regular expression. The '[]' are needed to make sure the '{}' are
#@ matched literally, and the '%s' is the argument name. The '%s' is
#@ replaced by each argument name and the whole expression is replaced,
#@ if matched in the target string, by the argument value.
#@ E.g.:
#@
#@ Given the string:
#@
#@ "{1} quick {color} {ANIMAL} jumps over {1} lazy dog"
#@
#@ and the map:
#@
#@ m["1"] = "the"
#@ m["color"] = "brown"
#@ m["[A-Z]+"] = "fox"
#@
#@ the result is:
#@
#@ "the quick brown fox jumps over the lazy dog"
#@
#@ Note that only the '%s' part of the argument name needs to appear as
#@ an index in the map.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-29
#@

# <public>
#@ Description: The argument format as a printf string.
#@ Returns: The default value for the argument format.
#
function PREP_ARG() {return "[{]%s[}]"}

#
#@ Description: Replaces the named arguments in 'str' according to
#@ 'map'. E.g. if 'str' is "{1} {arg}" and 'map' is 'map[1] = "foo"'
#@ 'map["arg"] = "bar"', the result is "foo bar". If 'fmt' is not given,
#@ 'PREP_ARG()' is used. If it is given, it must contain a single '%s',
#@ which shall be replaced by the argument name. The '%s' can be
#@ surrounded by non printf string specifier.
#@ Returns: 'str' after all arguments found in 'map' have been replaced.
#
function prep_str(str, map, fmt) {

	if (!fmt)
		fmt = PREP_ARG()

	return _prep_str(str, map, fmt)
}

#
#@ Description: Indicates how many substitutions were made in the last
#@ call to 'prep_str()'
#@ Returns: The number of substitutions made.
#
function prep_num_of_subs() {return _AWKLIB_prep__number_of_substitutions}
# </public>

function _prep_str(str, map, fmt,    _n, _subs) {

	_subs = 0
	for (_n in map)
		_subs += gsub(sprintf(fmt, _n), map[_n], str)
	_prep_set_subs(_subs)
	return str
}

function _prep_set_subs(n) {_AWKLIB_prep__number_of_substitutions = n}

#@ </awklib_prep>
#@ <awklib_str_check>
#@ Library: sc
#@ Description: Check the number and content of fields in a string.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-10-02
#@

#
#@ Description: Splits 'str' using 'fsep' as a field separator, checks if the
#@ split string has exactly 'fnum' number of fields. If 'sc_re_map' is given,
#@ each field mapped in 'sc_re_map' is checked against the regex in the map for
#@ that field. If 'strict' is != 0, each field from 'str' must have a
#@ corresponding regex in 'sc_re_map'. 'fnum' defaults to 2 if not given, or <
#@ 1. If 'fsep' is not given, it defaults to FS. 'sc_re_map' must be first
#@ compiled by calling 'sc_re_prepare()'.
#@ Returns: "" on success, a string containing an error message otherwise.
#
function sc_check_str(str, fnum, fsep, sc_re_map, strict,    _arr, _len, _i) {
	
	if ((fnum+0) < 1)
		fnum = 2
	
	if (!fsep)
		fsep = FS
		
	_len = split(str, _arr, fsep)
	
	if (_len != fnum)
		return sprintf("%d fields expected, got %d", fnum, _len)

	if (_SC_MATCH() in sc_re_map) {

		for (_i = 1; _i <= _len; ++_i) {
			
			if (_i in sc_re_map) {
				
				if (!match(_arr[_i], sc_re_map[_i])) {
				
					return sprintf("field %d '%s' did not match '%s'",
						_i, _arr[_i], sc_re_map[_i])
				}
			} else if (strict) {
				
				return sprintf("strict: no regex for field %d", _i)
			}
		}
	}

	return ""
}

#
#@ Description: Clears 'sc_re_map_out', compiles a field number to regex map in
#@ 'sc_re_map_out' according to 'fnum' and 're_str'. 'fnum' is the max number of
#@ fields; defaults to 2 if not given, or < 1. 'rsep' separates the field-regex
#@ pairs; default is ';'. 'nsep' separates the field and its regex; defaults is
#@ '='. The syntax of 're_str' is as described by SC_SYNTAX(). For a short
#@ example: given 're_str' is '1=[0-9];2=[a-z]', upon return 'sc_re_map_out'
#@ will contain:
#@ 'sc_re_map_out[1] = "[0-9]"'
#@ 'sc_re_map_out[2] = "[a-z]"'
#@ Later, assuming 'sc_re_map_out' is passed to 'sc_check_str()', the 1 and 2
#@ field of the 'str' argument of 'sc_check_str()' will be matched against
#@ '[0-9]' and '[a-z]', respectively.
#@ Returns: "" on success, a string containing an error message otherwise.
#
function sc_re_prepare(sc_re_map_out, fnum, re_str, rsep, nsep,    _arr_re,
_len_arr_re, _i, _arr_num_re, _arr_range, _num_re, _num, _re, _j,
_l, _h) {
	
	delete sc_re_map_out
	
	if (re_str) {

		if ((fnum+0) < 1)
			fnum = 2

		if (!nsep)
			nsep = "="
			
		if (!rsep)
			rsep = ";"
		
		sc_re_map_out[_SC_MATCH()] = 1

		_len_arr_re = split(re_str, _arr_re, rsep)
		for (_i = 1; _i <= _len_arr_re; ++_i) {
		
			_num_re = _arr_re[_i]
			if (2 == split(_num_re, _arr_num_re, nsep) && \
				_arr_num_re[1] && _arr_num_re[2]) {
				
				_num = _arr_num_re[1]
				_re = _arr_num_re[2]
				if ("*" == _num) {
				
					for (_j = 1; _j <= fnum; ++_j)
						sc_re_map_out[_j] = _re
				} else if (match(_num, "^[[:digit:]]+-[[:digit:]]+$")) {
					
					split(_num, _arr_range, "-")
					_l = _arr_range[1]+0
					_h = _arr_range[2]+0
					
					if (_l < _h) {
						
						for (_j = _l; _j <= _h; ++_j) {
							
							if (_j < 1 || _j > fnum)
								return _sc_eor(_num_re, _j)
								
							sc_re_map_out[_j] = _re
						}
					} else {
					
						return sprintf("'%s': bad range '%s'; "\
							"first should be < second", _num_re, _num)
					}
				} else if (match(_num, "^([[:digit:]]+,)+[[:digit:]]+$")) {
					
					_h = split(_num, _arr_range, ",")
					for (_j = 1; _j <= _h; ++_j) {
						
						_l = _arr_range[_j]
						if (_l < 1 || _l > fnum)
							return _sc_eor(_num_re, _l)
						
							sc_re_map_out[_l] = _re
					}
					
				} else if (match(_num, "^[[:digit:]]+$")) {
					
					_num += 0
					if (_num >= 1 && _num <= fnum) {
					
						sc_re_map_out[_num] = _re
					} else {
					
						return _sc_eor(_num_re, _num)
					}
				} else {
				
					return \
					sprintf(\
					"'%s' must be '*', a number > 0, csv, or a range",
					_num)
				}
				
			} else {
			
				return sprintf("'%s': "\
				 "syntax should be '<*|num|csv|range><nsep><regex>'", _num_re)
			}
		}
	}
	
	return ""
}

#
#@ Description: Provides a help message.
#@ Returns: A string describing the filed-to-regex mapping syntax.
#
function SC_SYNTAX() {
	return \
"<*|num|csv|range><nsep><regex>[<rsep><*|num|csv|range><nsep><regex>...]\n"\
"'*' means 'all fields'. By default, 'nsep' is '=', and 'rsep' is ';'.\n"\
"Latter expressions overwrite earlier ones. E.g. given 7 fields and:\n"\
"'*=[0-9];1=[a-z];2,6=[A-Z];3-5=[.]', field 1 will be matched to '[a-z]',\n"\
"fields 2 and 6 to '[A-Z]', fields 3, 4, and 5 to '[.]', field 7 to '[0-9]'"
}

function _sc_eor(nr, n) {
	return sprintf("'%s': field id '%s' out of range", nr, n)
}
function _SC_MATCH() {return "match"}
#@ </awklib_str_check>
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
