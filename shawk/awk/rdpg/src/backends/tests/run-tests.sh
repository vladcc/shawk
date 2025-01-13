#!/bin/bash

readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

function errq
{
	echo "$0: $*" >&2
	exit 1
}

function pretest
{
	bt_eval on_start "$@" || errq "function 'on_start' failed"
}
function run
{
	bt_eval "run_prog $*"
}
function postest
{
	bt_eval on_finish
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
function test_default
{
	pretest
	bt_eval test_use_cases
	bt_eval test_err_cases
	postest
}
function test_use_cases
{
	run "inputs/use_cases.txt"
	bt_assert_success
	diff_stdout "use_cases.txt"
	diff_stderr "empty"
	cleanup
}
function test_err_cases
{
	run "inputs/bad_many.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_many.txt"
	cleanup

	run "inputs/bad_start.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_start.txt"
	cleanup
}
# <imm>
function test_imm
{
	bt_eval test_imm_1
	bt_eval test_imm_0
}
function test_imm_1
{
	pretest "-vImm=1"
	bt_eval test_use_cases
	bt_eval test_err_cases
	postest
}
function test_imm_0
{
	pretest "-vImm=0"
	bt_eval test_use_cases
	bt_eval test_imm_0_err
	postest
}
function test_imm_0_err
{
	run "inputs/bad_many.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_many_imm_0.txt"
	cleanup

	run "inputs/bad_start.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_start.txt"
	cleanup
}
# </imm>
# <sync>
function test_sync_default
{
	pretest "-vSync=1"
	bt_eval test_use_cases
	bt_eval test_err_cases
	postest
}

function test_sync_none_err
{
	run "inputs/bad_many.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_sync_none.txt"
	cleanup

	run "inputs/bad_start.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_start.txt"
	cleanup
}
function test_sync_none
{
	pretest "-vSync=0"
	bt_eval test_use_cases
	bt_eval test_sync_none_err
	postest
}

function test_sync_custom_err
{
	local L_ACCEPT="$1"

	run "inputs/bad_many.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "$L_ACCEPT"
	cleanup

	run "inputs/bad_start.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_start.txt"
	cleanup
}
function test_sync_custom
{
	pretest "-vSync=expr=SEMI"
	bt_eval test_use_cases
	bt_eval test_sync_custom_err "bad_sync_custom_1.txt"
	postest

	pretest "-vSync=expr=MINUS"
	bt_eval test_use_cases
	bt_eval test_sync_custom_err "bad_sync_custom_2.txt"
	postest

	pretest "-vSync=expr=MINUS,L_PAR"
	bt_eval test_use_cases
	bt_eval test_sync_custom_err "bad_sync_custom_3.txt"
	postest
}
function test_sync
{
	bt_eval test_sync_default
	bt_eval test_sync_none
	bt_eval test_sync_custom
}
# </sync>
function test_custom_cases
{
	pretest
	bt_eval test_custom
	postest
}
function test
{
	bt_eval test_default
	bt_eval test_imm
	bt_eval test_sync
	bt_eval test_custom_cases
}
# </tests>

function main
{
	if [ "$#" -lt 1 ]; then
		echo "Use: $0 <test-base-src> [make-verbose]"
		exit 1
	fi

	local L_TEST_BASE="$1"
	shift

	source "$G_BASHTEST"

	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi

	source "$L_TEST_BASE"

	bt_enter
	bt_eval test
	bt_exit_success
}

main "$@"
