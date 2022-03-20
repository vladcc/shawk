#!/usr/bin/awk -f

# ptrip.awk -- parses boost ptree info syntax and outputs detailed dot notation
# Vladimir Dinev
# vld.dinev@gmail.com
# 2022-03-20

# <main>
function SCRIPT_NAME() {return "ptrip.awk"}
function SCRIPT_VERSION() {return "1.1"}

function set_file_name(str) {_B_file_name = str}
function get_file_name() {return _B_file_name}

function USE_STR() {return sprintf("Use: %s <info-file(s)>", SCRIPT_NAME())}

function print_use() {
	pstderr(USE_STR())
	pstderr(sprintf("Try: %s -v Help=1", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function print_help() {
print SCRIPT_NAME() " -- parses boost ptree info syntax and outputs detailed dot notation"
print USE_STR()
print ""
print "The syntax of the output is:"
print "'<include-lvl>|<file>' when a new file is opened."
print "'<include-lvl>|<file>:<line-num>:<item|annotation> = <value>' otherwise."
print sprintf("'<value>' is either the value, or '%s' if there was no value. Note",
	AN_NULL())
print "that no value is different than the empty value '\"\"'."
print "'<include-lvl>' is represented by a number of dashes starting from one."
print "'<file>' is the file being parsed at that particular point."
print "'<line-num>' is the line number of the item, or '-' for annotations, except"
print sprintf("the '%s' annotation.", AN_ERROR())
print "'<item>' is a dot notated path such as 'foo.bar.baz',  or '#include'."
print sprintf("'<annotation>' is one of '%s', '%s', '%s'.", AN_FILE_BEGIN(),
	AN_FILE_END(), AN_ERROR())
print ""
print sprintf("Note that '%s' annotates only file errors, e.g. recursive includes, or",
	AN_ERROR())
print "unavailable files. The parser can recover from these errors by simply ignoring"
print "the file. Syntax errors, on the other hand, are fatal. The output is printed"
print "only after parsing and if no syntax errors were encountered."
print ""
print "Options:"
print "-v Version=1 - version info"
print "-v Help=1    - this screen"
	exit_success()
}

function init() {
	set_program_name(SCRIPT_NAME())
	
	if (Help)
		print_help()
	if (Version)
		print_version()
}

function main(    _i) {
	init()
	
	if (ARGC < 2)
		print_use()
	
	for (_i = 1; _i < ARGC; ++_i) {
		parse_ptree_info(ARGV[_i])
		ARGV[_i] = ""
	}
	
	if (did_error_happen())
		exit_failure()
	else
		exit_success()
}

function error_fatal(msg) {
	error_print(sprintf("fatal: %s", msg))
	exit_failure()
}

BEGIN {
	main()
}
# </main>
