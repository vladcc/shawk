#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

function run
{
	bt_eval "$G_AWK -f ../_parser.awk -f ./_main.awk -f ./_bd_test.awk $* 1>$G_STDOUT 2>$G_STDERR"
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
function test_bd
{
	run "data/expr.ir"
	bt_assert_success
	diff_stdout "accept_default.ir"
	diff_stderr "empty"
	cleanup
}

function test_all
{
	bt_eval test_bd
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
