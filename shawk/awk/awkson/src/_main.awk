#!/usr/bin/awk -f


# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2022-01-14

# <main>
function SCRIPT_NAME() {return "awkson.awk"}
function SCRIPT_VERSION() {return "1.11"}

function _state_clear() {
	map_init(_G_json_type_tbl)
	map_init(_G_json_values_tbl)
	map_init(_G_json_removed_set)
	vect_init(_G_synchronization_stack)
	vect_init(_G_nest_type_stack)
	vect_init(_G_array_index_stack)
	vect_init(_G_input_order_keeper)
	vect_init(_G_position_stack)
	pft_init(_G_the_pft)
}
function _pre_parse_init() {
	_state_clear()
	_prs_init_pos()
	_lex_init()
}

function _run_once() {
	_prs_usr_init_type_set()
	_lex_usr_init_hex_digit()
	_lex_usr_init_esc_chars()
}

function _process_file(fname,    _len, _i) {
	_set_file_name(fname)
	_pre_parse_init()
	
	_prs_json()
	_len = vect_len(_G_input_order_keeper)
	for (_i = 1; _i <= _len; ++_i)
		pft_insert(_G_the_pft, _G_input_order_keeper[_i])
	on_json()
	
	close(fname)
}
function main(    _i) {
	set_program_name(SCRIPT_NAME())
	
	if (ARGC < 2)
		print_use()
	
	for (_i = 1; _i < ARGC; ++_i) {
		_process_file(ARGV[_i])
		ARGV[_i] = ""
	}
	_set_file_name("")
	_state_clear()
}

# <messages>
function print_help() {
print SCRIPT_NAME() " -- json parser and editor"
print ""
print USE_STR()
print ""
print "awkson parses json into memory and calls the user defined function 'on_json()'"
print "if parsing is successful. awkson also provides a number of APIs the user can"
print "use from 'on_json()' in order to query and edit the json object. There are three"
print "types of APIs:"
print "1. json - query, change values and types, add to, remove from the json object"
print "2. data structures - operations on arrays, vectors, maps, etc."
print "3. utility - easy file io, error reporting, exit codes, etc."
print ""
print "Along with the APIs the user can, of course, use the whole awk language as well,"
print "since 'on_json()' is an awk user defined function in the awk language."
print ""
print "By default, awkson tries to report all json errors limited to one error per"
print "value (value as defined by the json grammar). This can be overridden."
print ""
print "The API documentation can be overwhelming if printed in its entirety. However,"
print "it is tagged, so it is easy to lookup e.g.:"
print ""
print "See all available APIs:"
print "awk -f awkson.awk -vDoc=1 | grep '^<[^/]'"
print ""
print "See a specific API:"
print "awk -f awkson.awk -vDoc=1 | awk '/<awkson_json_api>/, /<\\/awkson_json_api>/'"
print ""
print "Options:"
print "-v FatalError=1 - quit on the first json error"
print "-v Doc=1        - print API documentation"
print "-v Help=1       - this screen"
print "-v Version=1    - version info"
print ""
print "Examples:"
print "If 'myfile.json' contains '{\"foo\" : \"bar\", \"baz\" : [\"zig\", \"zag\"]}'"
print ""
print "Parse the json file:"
print "awk -f awkson.awk -f <(echo 'function on_json() {}') myfile.json"
print ""
print "Note that 'on_json()' has to be defined by the user on each awkson run."
print "In this case the bash process substitution is used, but it may be provided"
print "in a separate awk source file, or by a shell wrapper in a similar manner."
print ""
print "Print the whole json object:"
print "awk -f awkson.awk -f <(echo 'function on_json() {json_print(\"r\")}') myfile.json"
print ""
print "\"r\" stands for 'root' and represents the top-level json object."
print ""
print "Print the second element of the 'baz' array:"
print "awk -f awkson.awk -f <(echo 'function on_json() {json_print(\"r.baz.2\")}') myfile.json"
print ""
print "Elements in json arrays are addressed by integers starting from 1. I.e. 'zig' is"
print "'r.baz.1', 'zag' is 'r.baz.2'."
print ""
print "Serialize the json whole object as dot notation:"
print "awk -f awkson.awk -f <(echo 'function on_json() {json_print_dot(\"r\")}') myfile.json"
print ""
print "Retrieve and print all json paths as dot notation:"
print "awk -f awkson.awk -f <(echo 'function on_json() {len=json_get_paths(arr); arr_print(arr, len, \"\\n\")}') myfile.json"
print ""
print "Note the use of a function from the array library."
print ""
print "Add a bool type member and print:"
print "awk -f awkson.awk -f <(echo 'function on_json() {json_add(\"r.added\", JT_BOOL(), \"true\"); json_print(\"r\")}') myfile.json"
print ""
print "New members get appended to the end of the json object."
print ""
print "Remove the 'baz' array and print:"
print "awk -f awkson.awk -f <(echo 'function on_json() {json_rm(\"r.baz\"); json_print(\"r\")}') myfile.json"
print ""
exit_success()
}

function USE_STR() {
	return sprintf("Use: awk -f %s [-v OPTION] [-f user_file.awk] file.json",
		SCRIPT_NAME())
}

function print_use() {
	pstderr(USE_STR())
	pstderr(sprintf("Try: awk -f %s -v Help=1", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function print_doc() {
	print_api_doc()
	exit_success()
}
# </messages>

function init() {
	if (Help)
		print_help()
	if (Version)
		print_version()
	if (Doc)
		print_doc()
	if (FatalError)
		_set_fatal_error()
		
	_run_once()
}

BEGIN {
	init()
	main()
}
# </main>
