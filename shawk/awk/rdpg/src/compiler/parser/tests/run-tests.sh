#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

function run
{
	bt_eval "$G_AWK -f ../_parser.awk -f ./_main.awk $* 1>$G_STDOUT 2>$G_STDERR"
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
function test_ok
{
	local L_ALL="basic opt star plus all missing esc esc-tr"
	for gr in $L_ALL; do
		run "grammars/${gr}.rdpg"
		bt_assert_success
		diff_stdout "${gr}.txt"
		diff_stderr "empty"
		cleanup
	done
}
function test_err
{
	run "grammars/bad_first.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad_first.txt"
	cleanup

	run "grammars/bad.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "bad.txt"
	cleanup
}
function test_grammars
{
	bt_eval test_ok
	bt_eval test_err
}
function test_all
{
	bt_eval test_grammars
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
