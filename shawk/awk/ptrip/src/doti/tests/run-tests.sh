#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_TEST_RES="./test_result.txt"

function main
{
	local L_BT_DIR="$(dirname $(realpath $0))/../../../../../bash/bashtest"
	source "$L_BT_DIR/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

function run
{
	local L_DOTI="../../../doti.awk"
	eval "$G_AWK -f $L_DOTI $@"
}

function test_versions
{
	local L_RES=""
	
	L_RES="$(run -vVersion=1)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo 'doti.awk 1.0')"
}

function test_data
{
	local L_TEST_1="./data/test1.dot"
	local L_TEST_1_ACC="./data/test1.dot.accept.txt"
	local L_RES=""
	
	L_RES="$(run "$L_TEST_1")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') $L_TEST_1_ACC"
	
	local L_EXP=\
'foo 
{
	bar 1
	bar
	bar ""
	{
		baz zig
	}
	bar zig
}'

	local L_TEST_2="./data/test2.dot"
	L_RES="$(run "$L_TEST_2" 2>/dev/null)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_EXP=\
"doti.awk: error: file './data/test2.dot', line 5: ignoring bad line; syntax should be '<dot-path> = <value>'"

	L_RES="$(run "$L_TEST_2" 2>&1 1>/dev/null)"
	bt_assert_success
	bt_diff_ok "<(echo \"$L_RES\") <(echo \"$L_EXP\")"
}

function test_all
{
	bt_eval test_versions
	bt_eval test_data
}

main "$@"
