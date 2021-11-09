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
