#!/bin/bash

G_AWK="${G_AWK:-awk}"

# the lexer is tested separately
readonly G_AWKSON_LIB="../src/_lib.awk"
readonly G_AWKSON_LEXER="../src/_lexer.awk"
readonly G_TEST_RESULT="./test_result.txt"


# parser tests test the whole awkson
readonly G_AWKSON="../awkson.awk"

readonly G_RUN_TESTS="test_version test_parser test_lexer"

# <test_parser>
function test_parser
{
	local L_PARSER_TESTS=\
"test_parser_api_err
test_parser_multi_file
test_parser_base
test_parser_api_ok"

	run_from_str $L_PARSER_TESTS
}

function test_parser_api_err
{
	local L_SRC=\
'function on_json() {
	json_print("r")
	json_set_type("r.foo", "bar")
	json_print("r")
}'

	local L_RES=""
	L_RES="$(eval $G_AWK -f $G_AWKSON -f <(echo "$L_SRC") <(echo {\"foo\":5}) 2>&1 1>/dev/null)"
	bt_assert_failure
	bt_diff_ok "<(echo \"awkson.awk: error: tried to set invalid type 'bar'\") <(echo \"$L_RES\")"

	L_SRC=\
'function on_json() {
	json_add("r.bar", "bar")
}'
	L_RES="$(eval $G_AWK -f $G_AWKSON -f <(echo "$L_SRC") <(echo {\"foo\":5}) 2>&1 1>/dev/null)"
	bt_assert_failure
	bt_diff_ok "<(echo \"awkson.awk: error: tried to set invalid type 'bar'\") <(echo \"$L_RES\")"
	
}

function test_parser_multi_file
{
	local L_JSON="./test-inputs/parser-tests/api_test.json"
	local L_ACCEPT="./test-accept/parser-accept/parser_accept_multi.txt"
	local L_IN_OK="./test-inputs/parser-tests/parser_test_ok.json"
	
	local L_SRC=\
'function on_json() {
	print get_file_name()
	json_print("r")
	json_rm("r")
	json_print("r")
}'
	
	bt_eval "$G_AWK -f $G_AWKSON -f <(echo '$L_SRC') $L_JSON $L_IN_OK "\
"> $G_TEST_RESULT"

	bt_diff_ok "$G_TEST_RESULT $L_ACCEPT"
	bt_eval "rm -f $G_TEST_RESULT"
}

function test_parser_api_ok
{
	local L_JSON="./test-inputs/parser-tests/api_test.json"
	local L_ACCEPT="./test-accept/parser-accept/parser_accept_api.txt"
	
	local L_SRC=\
'function on_json() {
	print "# <get_file_name>"
	print get_file_name()
	print "# </get_file_name>"
	print ""
	print "# <json_has>"
	print json_has("r")
	print json_has("r.age")
	print json_has("r.phoneNumbers.2")
	print json_has("r.added")
	print json_has("foo")
	print "# </json_has>"
	print ""
	print "# <json_get_paths>"
	len = json_get_paths(arr)
	arr_print(arr, len, "\n")
	print "# </json_get_paths>"
	print ""
	print "# <json_get_children>"
	len = json_get_children(arr, "r")
	arr_print(arr, len, "\n")
	print "# </json_get_children>"
	print ""
	print "# <json_print_dot>"
	json_print_dot("r")
	json_print_dot("r.phoneNumbers")
	print "# </json_print_dot>"
	print ""
	print "# <json_print>"
	json_print(JSON_ROOT())
	json_print("r.address")
	json_print("r.age")
	json_print("r.phoneNumbers.2")
	json_print("r.firstName")
	json_print("r.isAlive")
	json_print("r.other")
	json_print("r.children")
	json_print("r.spouse")
	print "# </json_print>"
	print ""
	print "# <json_get_type>"
	print json_get_type("r")
	print json_get_type("r.lastName")
	print json_get_type("r.isAlive")
	print json_get_type("r.age")
	print json_get_type("r.phoneNumbers")
	print json_get_type("r.phoneNumbers.1")
	print json_get_type("r.phoneNumbers.1.number")
	print json_get_type("r.spouse")
	print json_get_type("foo")
	print "# </json_get_type>"
	print ""
	print "# <json_get_val>"
	print json_get_val("r")
	print json_get_val("r.lastName")
	print json_get_val("r.isAlive")
	print json_get_val("r.age")
	print json_get_val("r.phoneNumbers")
	print json_get_val("r.phoneNumbers.1")
	print json_get_val("r.phoneNumbers.1.number")
	print json_get_val("r.spouse")
	print json_get_val("foo")
	print "# </json_get_val>"
	print ""
	print "# <json_set_val>"
	json_set_val("r.address.streetAddress", "Foo Street")
	json_set_val("r.address.city", "Boston")
	json_set_val("r.address.state", "MA")
	json_set_val("r.address.postalCode", 7777)
	json_print("r.address")
	print "# </json_set_val>"
	print ""
	print "# <json_set_type>"
	json_set_type("r.address.streetAddress", JT_NULL())
	val = json_get_val("r.address.postalCode")
	json_set_type("r.address.postalCode", JT_NUMBER(), val)
	json_set_type("r.address.city", JT_OBJECT())
	json_set_type("r.address.state", JT_BOOL())
	json_print("r.address")
	json_set_type("r.address.streetAddress", JT_STRING())
	json_set_type("r.address.postalCode", JT_NUMBER())
	json_set_type("r.address.city", JT_ARRAY())
	json_set_type("r.address.state", JT_BOOL(), "true")
	json_print("r.address")
	json_set_type("r.address.streetAddress", JT_STRING(), "foo")
	json_set_type("r.address.postalCode", JT_NUMBER(), 1000)
	json_set_type("r.address.state", JT_BOOL(), "true")
	json_print("r.address")
	print "# </json_set_type>"
	print ""
	print "# <json_add_rm>"
	json_add("r.added", JT_STRING())
	json_rm("r.address")
	json_rm("r.phoneNumbers.1")
	json_add("r.phoneNumbers.3", JT_OBJECT())
	json_add("r.phoneNumbers.3.added", JT_STRING(), "this is added")
	json_rm("r.other")
	json_print("r")
	print "# </json_add_rm>"
	print ""
	print "# <json_get_children>"
	len = json_get_children(arr, "r")
	arr_print(arr, len, "\n")
	print "# </json_get_children>"
	print ""
	print "# <json_get_paths>"
	len = json_get_paths(arr)
	arr_print(arr, len, "\n")
	print "# </json_get_paths>"
	print ""
	print "# <json_print_dot>"
	json_print_dot("r")
	print ""
	json_print_dot("r.phoneNumbers")
	print "# </json_print_dot>"
	print ""
	print "# <json_has>"
	print json_has("r")
	print json_has("r.age")
	print json_has("r.phoneNumbers.1")
	print json_has("r.added")
	print json_has("foo")
	print "# </json_has>"
	print ""
	print "# <json_get_children>"
	len = json_get_children(arr, "r.phoneNumbers")
	arr_print(arr, len, "\n")
	print "# </json_get_children>"
}'
	
	bt_eval "$G_AWK -f $G_AWKSON -f <(echo '$L_SRC') $L_JSON > $G_TEST_RESULT"
	bt_diff_ok "$G_TEST_RESULT $L_ACCEPT"
	bt_eval "rm -f $G_TEST_RESULT"
}

function test_parser_base
{
	local L_ACC_FATAL=\
"./test-accept/parser-accept/parser_accept_fatal_err.txt"
	local L_ACC_ERR=\
"./test-accept/parser-accept/parser_accept_err.txt"
	local L_IN_ERR="./test-inputs/parser-tests/parser_test_err.json"
	local L_ACC_OK="./test-accept/parser-accept/parser_accept_ok.txt"
	local L_IN_OK="./test-inputs/parser-tests/parser_test_ok.json"
	local L_RUN="$G_AWK -f $G_AWKSON -f <(echo \"function on_json() {}\")"
	
	# test single elements
	bt_eval "$L_RUN <(echo '\"a string\"')"
	bt_assert_success
	bt_eval "$L_RUN <(echo '\"\"')"
	bt_assert_success
	bt_eval "$L_RUN <(echo '{}')"
	bt_assert_success
	bt_eval "$L_RUN <(echo '[]')"
	bt_assert_success
	bt_eval "$L_RUN <(echo 'true')"
	bt_assert_success
	bt_eval "$L_RUN <(echo 'false')"
	bt_assert_success
	bt_eval "$L_RUN <(echo 'null')"
	bt_assert_success
	bt_eval "$L_RUN <(echo '3.14')"
	bt_assert_success
	
	# add the code to dump the tables here; must know internal var names
	local L_RUN_NO_JSON="$G_AWK -f $G_AWKSON"

	local L_RES=""
	L_RES="$(eval "$L_RUN_NO_JSON "\
"-f <(echo 'function _dbg_replace_subsep(str, what) {
	if (!what) what = \"->\"
		gsub(SUBSEP, what, str)
	return str
}
function _dump_json_tbl_ord(tbl, msg,    _n, _i, _end) {	
	print msg
	_end = vect_len(_G_input_order_keeper)
	for (_i = 1; _i <= _end; ++_i) {
		_n = _G_input_order_keeper[_i] 
		print sprintf(\"%s = %s\", _dbg_replace_subsep(_n), tbl[_n])
	}
}
function on_json() {
	_dump_json_tbl_ord(_G_json_type_tbl, \"@@@ types @@@\")
	_dump_json_tbl_ord(_G_json_values_tbl, \"@@@ values @@@\")
}')" $L_IN_OK)"
	bt_assert_success
	
	bt_diff_ok "<(echo \"$L_RES\") $L_ACC_OK"
	
	# fatal error; quit on the first sign of trouble
	local L_OPT_FATAL="-vFatalError=1"
	bt_eval "$L_RUN $L_OPT_FATAL $L_IN_ERR 2>/dev/null"
	bt_assert_failure
	
	bt_eval "diff <($L_RUN $L_OPT_FATAL $L_IN_ERR 2>&1) $L_ACC_FATAL"
	bt_assert_success
	
	# show all errors
	bt_eval "$L_RUN $L_IN_ERR 2>/dev/null"
	bt_assert_failure
	
	bt_diff_ok "<($L_RUN $L_IN_ERR 2>&1 1>/dev/null) $L_ACC_ERR"
	
	# test multiple jsons in a file; must be an error
	# 2>&1 | awk ... appended removes the automatic fd name
	local L_RM_FNAME="2>&1 | awk '\$3==\"file\" {\$4=\"\"} {print}'"
	local L_EOI_RUN=(
"$L_RUN <(echo '{} {}')"
"$L_RUN <(echo '[] []')"
"$L_RUN <(echo '1234 false')"
"$L_RUN <(echo 'null \"foo\"')"
)	
	local L_EOI_ERR=(
"awkson.awk: error: file  line 1, pos 4
awkson.awk: error: expected 'EOI', got '{' instead
{} {}
   ^"
"awkson.awk: error: file  line 1, pos 4
awkson.awk: error: expected 'EOI', got '[' instead
[] []
   ^"
"awkson.awk: error: file  line 1, pos 10
awkson.awk: error: expected 'EOI', got 'false' instead
1234 false
         ^"
"awkson.awk: error: file  line 1, pos 10
awkson.awk: error: expected 'EOI', got 'string' instead
null \"foo\"
         ^"
)

	local len="${#L_EOI_RUN[@]}"
	for (( i=0; i<$len; ++i ));
	do
		L_RES="$(eval ${L_EOI_RUN[$i]} $L_RM_FNAME)"
		bt_diff_ok "<(echo \"$L_RES\") <(echo \"${L_EOI_ERR[$i]}\")"
	done
}
# </test_parser>

# <test_lexer>
function test_lexer
{
	local L_LEX_TEST_MAIN="./awkson-lex-test-main.awk"
	local L_AWK_ARGS="-f $G_AWKSON_LIB -f $G_AWKSON_LEXER "\
"-f $L_LEX_TEST_MAIN ./test-inputs/lex_tests.txt"

	bt_eval "$G_AWK $L_AWK_ARGS > $G_TEST_RESULT"
	bt_diff_ok "$G_TEST_RESULT ./test-accept/lex_test_accept.txt"
	bt_eval "rm $G_TEST_RESULT"
}
# </test_lexer>

# <test_version>
function test_version
{
	bt_diff_ok "<($G_AWK -f $G_AWKSON -f <(echo 'function on_json(){}') -vVersion=1) <(echo 'awkson.awk 1.11')"
}
# </test_version>

function test_all
{
	run_from_str $G_RUN_TESTS
}

function run_from_str
{
	for test in $@; do
		bt_eval $test
	done
}

function main
{
	source "$(dirname $(realpath $0))/../../../bash/bashtest/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

main "$@"
