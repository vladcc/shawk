#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../../../bash/bashtest/bashtest.sh"
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
	run "data/use_case.txt"
	bt_assert_success
	diff_stdout "use_case_stdout.txt"
	diff_stderr "empty"
	cleanup
}
function test_err_case
{
	run "data/err_case.txt"
	bt_assert_failure
	diff_stdout "err_case_stdout.txt"
	diff_stderr "err_case_stderr.txt"
	cleanup
}
function test_tok_err
{
	run "-vTokErr=1 data/tok_err.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "tok_err_stderr.txt"
	cleanup
}
function test_bug_fixes
{
	run "data/last_line_comment_bug.txt"
	bt_assert_success
	diff_stdout "last_line_comment_bug.txt"
	diff_stderr "empty"
	cleanup
}
function test_all
{
	bt_eval test_use_case
	bt_eval test_err_case
	bt_eval test_tok_err
	bt_eval test_bug_fixes
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
