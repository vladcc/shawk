#!/bin/bash

G_AWK="${G_AWK:-awk}"

readonly G_AWK_TEST='../src/awklib_awktest.awk'

function diff_ok
{
	bt_diff "$@"
	bt_assert_success
}

function test_awklib_awkdoc
{
	local L_SRC=\
'function main(    _arr_src, _src_len, _arr_doc, _doc_len) {
	
	_arr_doc[1] = "should be cleared"
	_src_len = read_file("./data/awklib_awkdoc_data.txt", _arr_src)
	_doc_len = awd_make_doc(_arr_doc, _arr_src, _src_len)
	arr_print(_arr_doc, _doc_len, "\n")
}
BEGIN {
	main()
}'
	local L_ACCEPT=\
'<test>
This is the awkdoc test.

Start with local arguments.
function foo()

One public arg, others are local.
function bar(arg1)

Two arguments on the first line, others on the next.
function baz(arg1, arg2)

</test>'

	local L_RES=""
	
	L_RES="$(eval "$G_AWK"\
		"-f '$(get_src awkdoc)'"\
		"-f '$(get_src array)'"\
		"-f '$(get_src read)'"\
		"-f <(echo '$L_SRC')")"
	bt_assert_success
	
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
}

function test_awklib_test
{
	
	local L_TEST_SRC_OK=\
'function test_1() {
	at_test_begin("test_1()")
	at_true(1)
	at_true(!0)
	at_true(1)
}
function test_2() {
	at_test_begin("test_2()")
	at_true(1)
	at_true(!0)
}
BEGIN {
	at_awklib_awktest_required()
	test_1()
	test_2()
}'

	local L_TEST_SRC_LOG=\
'function test_1() {
	at_test_begin("test_1()")
	at_true(1)
	at_true(!0)
	at_true(1)
	at_dump_log()
}
function test_2() {
	at_test_begin("test_2()")
	at_true(1)
	at_true(!0)
	at_dump_log()
}
BEGIN {
	at_awklib_awktest_required()
	test_1()
	test_2()
	at_report()
}'
	local L_ACCEPT_OK_LOG=\
'###### test_1() ######
1 true test_1()
2 true test_1()
3 true test_1()
###### test_2() ######
1 true test_2()
2 true test_2()
test_1()
test_2()'

	local L_TEST_SRC_FAIL=\
'function test_1() {
	at_test_begin("test_1()")
	at_true(1)
	at_true(!0)
	at_true(1)
}
function test_2() {
	at_test_begin("test_2()")
	at_true(1)
	at_true(0)
	at_true(1)
}
BEGIN {
	at_awklib_awktest_required()
	test_1()
	test_2()
}'
	local L_ACCEPT_FAIL=\
'###### test_2() ######
1 true test_2()
error: 2 false test_2()'
	
	bt_eval "$G_AWK -f $G_AWK_TEST -f <(echo '$L_TEST_SRC_OK')"
	bt_assert_success
	
	L_RES="$(eval $G_AWK -f $G_AWK_TEST -f <(echo $L_TEST_SRC_LOG))"
	bt_assert_success
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT_OK_LOG')"

	L_RES="$(eval $G_AWK -f $G_AWK_TEST -f <(echo $L_TEST_SRC_FAIL))"
	bt_assert_failure
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT_FAIL')"
}

function test_prints
{
	local L_RES=""
	local L_ACCEPT=\
'arr_foo arr_bar arr_baz
arr_foo-arr_bar-arr_baz
map_bar 2
map_baz 3
map_foo 1
pft["t"] = "h"
pft["t"] = "h"
pft["t"] = "h"
pft["t"] = "h"
pft["-t-h-a-n"] = ""
pft[".t.h.a.n"] = ""
pft["t-h-a-n"] = "k"
pft["t-h-a-n"] = "k"
pft["t-h-a-n-k"] = ""
pft["t-h-a-n-k"] = ""
pft["t.h.a.n"] = "k"
pft["t.h.a.n"] = "k"
pft["t.h.a.n.k"] = ""
pft["t.h.a.n.k"] = ""
pft["t-h-a-t"] = ""
pft["t-h-a-t"] = ""
pft["t.h.a.t"] = ""
pft["t.h.a.t"] = ""
pft["t-h-a"] = "t-n"
pft["t-h-a"] = "t-n"
pft["t.h.a"] = "t.n"
pft["t.h.a"] = "t.n"
pft["t-h"] = "i-a"
pft["t-h"] = "i-a"
pft["t.h"] = "i.a"
pft["t.h"] = "i.a"
pft["t-h-i"] = "s"
pft["t-h-i"] = "s"
pft["t-h-i-s"] = ""
pft["t-h-i-s"] = ""
pft["t.h.i"] = "s"
pft["t.h.i"] = "s"
pft["t.h.i.s"] = ""
pft["t.h.i.s"] = ""
set_bar
set_baz
set_foo
	tabs_foo
	tabs_foo
t-h-i-s -> t-h-a-t -> t-h-a-n-k
this that thank
t-h-i-s -> t-h-a-t -> t-h-a-n -> t-h-a-n-k
this that than thank'

	L_RES="$(eval $G_AWK"\
		"-f '$(get_src array)'"\
		"-f '$(get_src vect)'"\
		"-f '$(get_src eos)'"\
		"-f '$(get_src map)'"\
		"-f '$(get_src set)'"\
		"-f '$(get_src prefix_tree)'"\
		"-f '$(get_src tabs)'"\
		"-f '$(get_driver prints)')"
	bt_assert_success
	L_RES="$(echo "$L_RES" | sort)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
	
	L_ACCEPT=\
'map_bar 2
map_baz 3
map_foo 1
set_bar
set_baz
set_foo'
	
	L_RES="$(eval $G_AWK"\
		"-f '$(get_src array)'"\
		"-f '$(get_src vect)'"\
		"-f '$(get_src eos)'"\
		"-f '$(get_src map)'"\
		"-f '$(get_src set)'"\
		"-f '$(get_src prefix_tree)'"\
		"-f '$(get_src tabs)'"\
		"-f '$(get_driver prints) -vUnpredictable=1')"
	bt_assert_success
	
	L_RES="$(echo "$L_RES" | tr '|-' '\n' | sort)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
}

function test_awklib_prog
{
	local L_PROG="../src/awklib_prog.awk"
	
	local L_SRC=""
	local L_RES=""
	local L_ACCEPT=""
	
	L_SRC=\
'BEGIN {
	print "\"" get_program_name() "\""
	set_program_name("myprog")
	print get_program_name()
	
	print did_error_happen()
	error_flag_set()
	print did_error_happen()
	
	print should_skip_end()
	skip_end_set()
	print should_skip_end()
	
	error_flag_clear()
	print did_error_happen()
	
	skip_end_clear()
	print did_error_happen()
	
	pstderr("stderr")
	error_print("my error msg")
	print did_error_happen()
	print should_skip_end()
	exit_success()
}

END {
	if (!should_skip_end())
		print "this should not print"
}'
	L_ACCEPT=\
'""
0
0
0
0
1
1
1
1
myprog
myprog: error: my error msg
stderr'
	
	L_RES="$(eval $G_AWK -f $L_PROG -f <(echo "$L_SRC") 2>&1)"
	bt_assert_success
	L_RES="$(echo "$L_RES" | sort)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
	
	L_SRC=\
'BEGIN {
	print did_error_happen()
	error_print("my error msg")
	print did_error_happen()
	exit_failure()
}

END {
	if (!should_skip_end())
		print "this should not print"
}'	
	L_ACCEPT=\
'0
1
: error: my error msg'

	L_RES="$(eval $G_AWK -f $L_PROG -f <(echo "$L_SRC") 2>&1)"
	diff_ok "<(echo 1) <(echo $?)"
	L_RES="$(echo "$L_RES" | sort)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
	
	L_SRC=\
'BEGIN {exit_failure(5)}'
	L_RES="$(eval $G_AWK -f $L_PROG -f <(echo "$L_SRC") 2>&1)"
	diff_ok "<(echo 5) <(echo $?)"
	
	L_SRC=\
'BEGIN {error_quit("fatal")}'	
	L_ACCEPT=\
': error: fatal'
	
	L_RES="$(eval $G_AWK -f $L_PROG -f <(echo "$L_SRC") 2>&1)"
	diff_ok "<(echo 1) <(echo $?)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
	
	L_SRC=\
'BEGIN {
	set_program_name("myprog")
	error_quit("fatal", 5)
}'
	L_ACCEPT=\
'myprog: error: fatal'
	
	L_RES="$(eval $G_AWK -f $L_PROG -f <(echo "$L_SRC") 2>&1)"
	diff_ok "<(echo 5) <(echo $?)"
	diff_ok "<(echo '$L_RES') <(echo '$L_ACCEPT')"
}

function get_src { echo "../src/awklib_${1}.awk"; }
function get_driver { echo "./test-drivers/test_awklib_${1}.awk"; }
function test_functional
{
	local L_LIBS=(
		'array'   'vect'  'eos'          'heap'
		'map'     'set'   'prefix_tree'  'exec_cmd'
		'read'    'tabs'  'fsm'          'prep'
		'ch_num'  'sort'  'psplit'       'str_check'
		'gtree'   'dotnot'
	)
	local L_DEPENDS=(
		""
		"-f '$(get_src array)'"
		"-f '$(get_src array)' -f '$(get_src vect)'"
		"-f '$(get_src array)' -f '$(get_src vect)'"
		"" "" "" ""
		"-f '$(get_src array)'"
		"" "" ""
		"" "" "" ""
		"" ""
	)
	local L_NUM_UNIQ_TESTS=(
		18 12 12 7
		19 15 14 2
		1  1  5  1
		3  6  1  3
		8  2
	)
	local L_THIS_LIB=""
	local L_RES=""
	local L_DEP=""
	
	local len="${#L_LIBS[@]}"
	for ((i = 0; i < ${len}; ++i));
	do
		L_DEP="${L_DEPENDS[$i]}"
		L_THIS_LIB="${L_LIBS[$i]}"
		
		bt_eval "$G_AWK"\
		"-f '$G_AWK_TEST' -vReport=0"\
		"-f '$(get_src $L_THIS_LIB)'"\
		"-f '$(get_driver $L_THIS_LIB)' $L_DEP"
		bt_assert_success
		
		# make sure the number of unique tests is as expected
		bt_eval "# eval again with -vReport=1"
		L_RES="$(eval $G_AWK"\
		"-f '$G_AWK_TEST' -vReport=1"\
		"-f '$(get_src $L_THIS_LIB)'"\
		"-f '$(get_driver $L_THIS_LIB)' $L_DEP | sort -u | wc -l)"
		bt_assert_success
		diff_ok "<(echo $L_RES) <(echo ${L_NUM_UNIQ_TESTS[$i]})"
	done
}

function test_read_lines
{
		local L_READ_STR=\
'begin line
foo

bar
# comment
	baz
  # another comment
end line
another line'
	
	for ((i = 1; i <= 5; ++i));
	do
		bt_eval "$G_AWK"\
		"-f '$G_AWK_TEST' -vReport=0 -vReadLines=${i}"\
		"-f '$(get_src read)'"\
		"-f '$(get_driver read)'"\
		"-f '$(get_src array)' <(echo '$L_READ_STR')"
		bt_assert_success
	done
}

function test_all
{
	local L_TESTS=\
"awklib_test "\
"prints "\
"awklib_prog "\
"awklib_awkdoc "\
"functional "\
"read_lines "
	
	for test in $L_TESTS; do
		bt_eval "test_${test}"
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
