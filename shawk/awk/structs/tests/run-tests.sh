#!/bin/bash


G_AWK="${G_AWK:-awk}"
readonly G_STRUCTS="../structs.awk"
readonly G_MAIN="-f ./test.awk -f ./main.awk"
readonly G_STDOUT="./test_stdout.txt"
readonly G_STDERR="./test_stderr.txt"

function run
{
	bt_eval "$G_AWK $* 1>$G_STDOUT 2>$G_STDERR"
}
function run_structs
{
	bt_eval run "-f $G_STRUCTS $*"
}
function run_main
{
	bt_eval run "$G_MAIN $*"
}
function cleanup
{
	bt_eval "rm -f $G_STDOUT $G_STDERR $*"
}
function diff_clean
{
	bt_diff_ok "$*"
	bt_eval cleanup
}
function diff_stdout
{
	diff_clean "$G_STDOUT accept/$1"
}
function diff_stderr
{
	diff_clean "$G_STDERR accept/$1"
}

# <tests>
# <options>
function test_ver
{
	run_structs "-vVersion=1"
	bt_assert_success
	diff_stdout "version.txt"
	run_structs "-vVersion=1 foo"
	bt_assert_success
	diff_stdout "version.txt"
}
function test_help
{
	run_structs "-vHelp=1"
	bt_assert_success
	diff_stdout "help.txt"
}
function test_fsm
{
	run_structs "-vFsm=1"
	bt_assert_success
	diff_stdout "fsm.txt"
}
function test_err_files
{
	run_structs ""
	bt_assert_failure
	diff_stderr "err_files.txt"

	run_structs "foo bar"
	bt_assert_failure
	diff_stderr "err_files.txt"
}
function test_opts
{
	bt_eval test_ver
	bt_eval test_help
	bt_eval test_fsm
	bt_eval test_err_files
}
# </options>

# <runs>
function test_runs
{
	run_structs "./test.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT test.awk"

	run_main "-vOk=1"
	bt_assert_success
	diff_stdout "main_ok.txt"

	run_main "-vBadType=1"
	bt_assert_failure
	diff_stderr "main_err_bad_type.txt"

	run_main "-vNoEnt=1"
	bt_assert_failure
	diff_stderr "main_err_no_ent.txt"

	run_main "-vClear=1"
	bt_assert_failure
	diff_stderr "main_clear.txt"

	bt_eval "rm -f ./test.awk"
}
# </runs>

function test_all
{
	bt_eval test_opts
	bt_eval test_runs
}
# </tests>

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

main "$@"
