#!/bin/bash

readonly G_SCR_NAME="$(basename $0)"
readonly G_BASE_DIR="$(dirname $(realpath $0))"
readonly G_TEST_RES="$G_BASE_DIR/test_result.txt"
readonly G_ACCPT_DIR="$G_BASE_DIR/accept"
readonly G_ACCPT_BT_ASF="$G_ACCPT_DIR/assert_s_fail_accept.txt"
readonly G_ACCPT_BT_AFF="$G_ACCPT_DIR/assert_f_fail_accept.txt"
readonly G_ACCPT_VERB="$G_ACCPT_DIR/verbose_accept.txt"
readonly G_SUCCESS='[ $? -eq 0 ]'
readonly G_FAILURE='[ $? -ne 0 ]'

function main
{
	source "$(dirname $(realpath $0))/../bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	run_tests
	run_test_verbose
	bt_exit_success
}

function err_quit
{
	echo "$G_SCR_NAME: error: $@" > /dev/stderr
	caller 1
	exit 1
}

function assert
{
	eval "$@" || err_quit "'$@' failed"
}

function diff_
{
	diff -u "$G_TEST_RES" "$@" && rm "$G_TEST_RES"
	assert "$G_SUCCESS"
}

function run_test_verbose
{
	> "$G_TEST_RES"
	
	bash ./assert_ok.sh "x" > "$G_TEST_RES"
	assert "$G_SUCCESS"
	diff_ "$G_ACCPT_VERB"
}

function test_bt_diffs
{
	local L_OUT=""
	
	bt_set_verbose
	
	local L_DIFF_OK=\
'diff <(echo 1) <(echo 1)
[ 0 -eq 0 ]'
	local L_DIFF_NOK=\
'diff <(echo 1) <(echo 2)
1c1
< 1
---
> 2
[ 1 -ne 0 ]'
	
	L_OUT="$(bt_diff_ok '<(echo 1) <(echo 1)')"
	diff <(echo "$L_DIFF_OK") <(echo "$L_OUT")
	assert "$G_SUCCESS"
	
	L_OUT="$(bt_diff_nok '<(echo 1) <(echo 2)')"
	diff <(echo "$L_DIFF_NOK") <(echo "$L_OUT")
	assert "$G_SUCCESS"
}

function run_tests
{	
	> "$G_TEST_RES"
		
	bash ./pushd.sh
	assert "$G_SUCCESS"
	
	bash ./assert_ok.sh
	assert "$G_SUCCESS"
	
	bash ./assert_s_fail.sh > "$G_TEST_RES" 2>&1
	assert "$G_FAILURE"
	diff_ "$G_ACCPT_BT_ASF"
	
	bash ./assert_f_fail.sh > "$G_TEST_RES" 2>&1
	assert "$G_FAILURE"
	diff_ "$G_ACCPT_BT_AFF"
	
	local L_ERRTXT="$(bt_error_print foo 2>&1 > /dev/null)"
	diff <(echo $L_ERRTXT) <(echo run-tests.sh: error: foo)
	assert "$G_SUCCESS"
	
	test_bt_diffs
}

main "$@"
