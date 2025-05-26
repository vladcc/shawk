#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

function run
{
	local L_FLG=""
	if [ "$#" -gt 1 ]; then
		L_FLG="$2"
	fi

	bt_eval "$G_AWK -f ../_sync.awk -vSync='$1' -f _main.awk $L_FLG 1>$G_STDOUT 2>$G_STDERR"
}
function cleanup
{
	bt_eval "rm -f $G_STDOUT $G_STDERR $*"
}
function diff_stdout
{
	bt_diff_ok "$G_STDOUT accept/$1"
}
function diff_stderr
{
	bt_diff_ok "$G_STDERR accept/$1"
}

# <tests>
function test_types
{
	run "0" "-vType=1"
	bt_assert_success
	diff_stdout "type_1.txt"
	diff_stderr "empty"
	cleanup

	run "" "-vType=1"
	bt_assert_success
	diff_stdout "type_2.txt"
	diff_stderr "empty"
	cleanup

	run "1" "-vType=1"
	bt_assert_success
	diff_stdout "type_2.txt"
	diff_stderr "empty"
	cleanup

	run "foo" "-vType=1"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "type_err.txt"
	cleanup

	run "foo=BAR" "-vType=1"
	bt_assert_success
	diff_stdout "type_3.txt"
	diff_stderr "empty"
	cleanup
}
function test_use_case
{
	run "foo=BAR"
	bt_assert_success
	diff_stdout "use_1.txt"
	diff_stderr "empty"
	cleanup

	run "foo=BAR,BAZ"
	bt_assert_success
	diff_stdout "use_2.txt"
	diff_stderr "empty"
	cleanup

	run "foo = BAR  ,BAZ"
	bt_assert_success
	diff_stdout "use_2.txt"
	diff_stderr "empty"
	cleanup

	run "foo=BAR;zig=ZAG"
	bt_assert_success
	diff_stdout "use_3.txt"
	diff_stderr "empty"
	cleanup

	run "foo=BAR,BAZ;zig=ZAG,ZOG,ZEG"
	bt_assert_success
	diff_stdout "use_4.txt"
	diff_stderr "empty"
	cleanup

	run "foo=BAR,BAZ;zig=ZAG,ZOG, ZEG; one=TWO,THREE "
	bt_assert_success
	diff_stdout "use_5.txt"
	diff_stderr "empty"
	cleanup
}
function test_err_case
{
	run "foo"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_1.txt"
	cleanup

	run "foo=BAR="
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_2.txt"
	cleanup

	run "foo="
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_3.txt"
	cleanup

	run "foo=BAR;foo=BAZ"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_4.txt"
	cleanup

	run "foo=BAR,BAZ,BAR;zig=ZAG"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_5.txt"
	cleanup

	run "foo=BAZ,BAR;"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_6.txt"
	cleanup

	run "foo=BAZ,,"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_7.txt"
	cleanup

	run "foo=BAR, bAZ, ZIG"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_7.txt"
	cleanup

	run "=BAZ,,"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_8.txt"
	cleanup

	run "Foo=BAR"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_9.txt"
	cleanup
}
function test_all
{
	bt_eval test_types
	bt_eval test_use_case
	bt_eval test_err_case
}
# </tests>

function main
{
	source "$G_BASHTEST"

	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi

	bt_enter
	bt_eval test_all
	bt_exit_success
}

main "$@"
