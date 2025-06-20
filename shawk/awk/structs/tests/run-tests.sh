#!/bin/bash


G_AWK="${G_AWK:-awk}"
readonly G_STRUCTS="../structs.awk"
readonly G_STDOUT="./test_stdout.txt"
readonly G_STDERR="./test_stderr.txt"

# <run>
function run
{
	bt_eval "$G_AWK $* 1>$G_STDOUT 2>$G_STDERR"
}
function run_structs
{
	bt_eval cleanup
	bt_eval run "-f $G_STRUCTS $*"
}
function run_main
{
	bt_eval cleanup
	bt_eval run "-f ./test.awk -f ./main.awk $*"
}
function run_main_pref
{
	bt_eval cleanup
	bt_eval run "-f ./test-pref.awk -f ./main-pref.awk $*"
}
# </run>

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
function test_err_structs
{
	run_structs "./test.err.structs"
	bt_assert_failure
	diff_stderr "err_structs.txt"
}
function test_opts
{
	bt_eval test_ver
	bt_eval test_help
	bt_eval test_fsm
	bt_eval test_err_files
	bt_eval test_err_structs
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

	run_main "-vUseBadType=1"
	bt_assert_failure
	diff_stderr "main_err_bad_type.txt"

	run_main "-vAssignBadType=1"
	bt_assert_failure
	diff_stderr "main_err_assign_bad_type.txt"

	run_main "-vNoEnt=1"
	bt_assert_failure
	diff_stderr "main_err_no_ent.txt"

	run_main "-vClear=1"
	bt_assert_failure
	diff_stderr "main_clear.txt"

	run_main "-vGenInd=1"
	bt_assert_failure
	diff_stdout "main_gen_ind_stdout.txt"
	diff_stderr "main_gen_ind_stderr.txt"
}
function test_runs_prefix
{
	run_structs "./test.pref.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT test-pref.awk"

	run_main_pref "-vOk=1"
	bt_assert_success
	diff_stdout "main_ok_pref.txt"

	run_main_pref "-vUseBadType=1"
	bt_assert_failure
	diff_stderr "main_err_bad_type_pref.txt"

	run_main_pref "-vAssignBadType=1"
	bt_assert_failure
	diff_stderr "main_err_assign_bad_type_pref.txt"

	run_main_pref "-vNoEnt=1"
	bt_assert_failure
	diff_stderr "main_err_no_ent_pref.txt"

	run_main_pref "-vClear=1"
	bt_assert_failure
	diff_stderr "main_clear_pref.txt"

	run_main_pref "-vGenInd=1"
	bt_assert_failure
	diff_stdout "main_gen_ind_stdout_pref.txt"
	diff_stderr "main_gen_ind_stderr_pref.txt"
}
# </runs>

function test_all
{
	bt_eval test_opts
	bt_eval test_runs
    bt_eval test_runs_prefix
	bt_eval cleanup
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
