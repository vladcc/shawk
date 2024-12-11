#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASE_DIR="$(dirname $(realpath "$0"))"
readonly G_BASHTEST="${G_BASE_DIR}/../../../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"


function run
{
	bt_eval "$G_AWK -f ../_lexer.awk -f ./_main.awk $* 1>$G_STDOUT 2>$G_STDERR"
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
function test_use_case
{
	run "data/tok.txt"
	bt_assert_success
	diff_stdout "use_case.txt"
	diff_stderr "empty"
	cleanup
}
function test_err_case
{
	run "-vTestErrFirst=1 data/tok.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_case_first.txt"
	cleanup

	run "-vTestErr=1 data/tok.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "err_case.txt"
	cleanup
}
function test_tok_err
{
	run "data/tok_err.txt"
	bt_assert_failure
	diff_stdout "tok_err_stdout.txt"
	diff_stderr "tok_err_stderr.txt"
	cleanup
}
function test_all
{
	bt_eval test_use_case
	bt_eval test_err_case
	bt_eval test_tok_err
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
