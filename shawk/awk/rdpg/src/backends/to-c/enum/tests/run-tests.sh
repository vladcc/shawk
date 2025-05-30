#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

function run
{
	bt_eval "$G_AWK -f ../_enum.awk -f _main.awk $* 1>$G_STDOUT 2>$G_STDERR"
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
function test_help
{
	run "-vTestHelp=1"
	bt_assert_success
	diff_stdout "help_msg.txt"
	diff_stderr "empty"
	cleanup
}
function test_parse_err
{
    run "-vTestParseErr=1 data/enum_base.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "parse_err.txt"
	cleanup
}
function test_no_enum
{
    run "data/no_enum.txt"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "parse_not_done.txt"
	cleanup
}

function test_enum
{
    run "data/enum_base.txt"
	bt_assert_success
	diff_stdout "enum_base.txt"
	diff_stderr "empty"
	cleanup

    run "data/enum_two.txt"
	bt_assert_success
	diff_stdout "enum_base.txt"
	diff_stderr "empty"
	cleanup

    run "data/enum_extra.txt"
	bt_assert_success
	diff_stdout "enum_base.txt"
	diff_stderr "empty"
	cleanup

    run "data/enum_space.txt"
	bt_assert_success
	diff_stdout "enum_base.txt"
	diff_stderr "empty"
	cleanup

    run "data/enum_one_line.txt"
	bt_assert_success
	diff_stdout "enum_base.txt"
	diff_stderr "empty"
	cleanup
}

function test_all
{
    bt_eval test_help
    bt_eval test_parse_err
    bt_eval test_no_enum
    bt_eval test_enum
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
