#!/bin/bash

G_AWK="${G_AWK:-awk}"

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

function run_prep { eval "$G_AWK -f ../prep.awk $@"; }

function test_version
{
	local L_RES=""
	L_RES="$(run_prep -vVersion=1)"
	bt_assert_success
	
	bt_diff_ok "<(echo '$L_RES') <(echo 'prep.awk 1.0')"
}

function test_help
{
	run_prep "-vHelp=1" > /dev/null
	bt_assert_success
}

function test_runs
{
	local L_DATA=\
'1 2
3 b'
	
	local L_RES=""
	
	L_RES="$(run_prep "<(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(echo '$L_RES') <(echo 'prep.awk: error: -v Str=<str> must be given; try -v Help=1')"
	
	local L_EXP=\
'foo 1 2
foo 3 b'
	
	L_RES="$(run_prep "-vStr='foo {1} {2}' <(echo '$L_DATA')")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run_prep "-vStr='foo {0}' <(echo '$L_DATA')")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vFields=1 <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec 'prep.awk: error: file .+, line 1: 1 fields expected, got 2' <(echo '$L_RES')) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vFields=3 <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec 'prep.awk: error: file .+, line 1: 3 fields expected, got 2' <(echo '$L_RES')) <(echo 1)"

	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9]' <(echo '$L_DATA')" 2>&1)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9]' -vStrict=1 <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec \"prep.awk: error: file .+, line 1: strict: no regex for field 2\" <(echo \"$L_RES\")) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9];2=' -vStrict=1 <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec \"prep.awk: error: '2=': syntax should be '<\*|num|csv|range><nsep><regex>'\" <(echo \"$L_RES\")) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9];2=.' -vStrict=1 <(echo '$L_DATA')")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run_prep "-vStr='foo {0}' -v ReCheck='1=[0-9];2=[a-z]' <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec \"prep.awk: error: file .+, line 1: field 2 '2' did not match '\[a-z\]'\" <(echo \"$L_RES\")) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9];2=[0-9]|[a-z]' <(echo '$L_DATA')")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1=[0-9];2=[0-9]|[a-z]' -vRsep='#' -vNsep='@' <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec \"prep.awk: error: '1=[0-9];2=[0-9]|[a-z]': syntax should be '<*|num|csv|range><nsep><regex>'\" <(echo \"$L_RES\")) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='foo {0}' -vReCheck='1@[0-9]#2@[0-9]|[a-z]' -vRsep='#' -vNsep='@' <(echo '$L_DATA')")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_DATA=\
'1 2 3
a b c'

	L_EXP=\
'1 2 foo 3
a b foo c'
	
	L_RES="$(run_prep "-vStr='foo {0}' <(echo '$L_DATA')" 2>&1)"
	bt_assert_failure
	bt_diff_ok "<(grep -Ec 'prep.awk: error: file .+, line 1: 2 fields expected, got 3' <(echo '$L_RES')) <(echo 1)"
	
	L_RES="$(run_prep "-vStr='{1} {2} foo {3}' -vFields=3 <(echo '$L_DATA')" 2>&1)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
}

function test_all
{
	bt_eval test_version
	bt_eval test_help
	bt_eval test_runs
}

main "$@"
