#!/bin/bash


G_AWK="${G_AWK:-awk}"
readonly G_TABLES="../tables.awk"
readonly G_STDOUT="./test_stdout.txt"
readonly G_STDERR="./test_stderr.txt"

# <run>
function run
{
	bt_eval "$G_AWK $* 1>$G_STDOUT 2>$G_STDERR"
}
function run_tables
{
	bt_eval cleanup
	bt_eval run "-f $G_TABLES $*"
}
function run_main
{
	bt_eval cleanup
	bt_eval run "-f ./compiled/test.awk -f ./compiled/main.awk $*"
}
function run_main_pref
{
	bt_eval cleanup
	bt_eval run "-f ./compiled/test-pref.awk -f ./compiled/main-pref.awk $*"
}
function run_main_unions
{
	bt_eval cleanup
	bt_eval run "-f ./compiled/test-unions.awk -f ./compiled/main-unions.awk $*"
}
function run_main_unions_pref
{
	bt_eval cleanup
	bt_eval run \
	"-f ./compiled/test-unions-pref.awk -f ./compiled/main-unions-pref.awk $*"
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
	run_tables "-vVersion=1"
	bt_assert_success
	diff_stdout "version.txt"
	run_tables "-vVersion=1 foo"
	bt_assert_success
	diff_stdout "version.txt"
}
function test_help
{
	run_tables "-vHelp=1"
	bt_assert_success
	diff_stdout "help.txt"
}
function test_fsm
{
	run_tables "-vFsm=1"
	bt_assert_success
	diff_stdout "fsm.txt"
}
function test_opts
{
	bt_eval test_ver
	bt_eval test_help
	bt_eval test_fsm
}
# </options>

# <err_input>
function test_err_input
{
	run_tables ""
	bt_assert_failure
	diff_stderr "err_files.txt"

	run_tables "foo bar"
	bt_assert_failure
	diff_stderr "err_files.txt"

	run_tables "./input/test_err_no_end.tables"
	bt_assert_failure
	diff_stderr "err_tables_no_end.txt"

	run_tables "./input/test_err_no_types.tables"
	bt_assert_failure
	diff_stderr "err_tables_no_defn.txt"

	run_tables "./input/test_err_redef_defn.tables"
	bt_assert_failure
	diff_stderr "err_tables_redef_defn.txt"

	run_tables "./input/test_err_redef_defn_field.tables"
	bt_assert_failure
	diff_stderr "err_tables_redef_defn_field.txt"

	run_tables "./input/test_err_prefix_nodata.tables"
	bt_assert_failure
	diff_stderr "err_tables_prefix_noname.txt"

	run_tables "./input/test_err_defn_nodata.tables"
	bt_assert_failure
	diff_stderr "err_tables_defn_noname.txt"

	run_tables "./input/test_err_defn_field_nodata.tables"
	bt_assert_failure
	diff_stderr "err_tables_defn_field_noname.txt"
}
# </err_input>

# <runs>
function test_runs
{
	run_tables "./input/test.tables"
	bt_assert_success
	bt_eval "cp $G_STDOUT compiled/test.awk"

	run_main
	bt_assert_success
	diff_stdout "main_ok.txt"

	run_tables "./input/test_cmnt.tables"
	bt_assert_success
	bt_eval "cp $G_STDOUT compiled/test.awk"

	run_main
	bt_assert_success
	diff_stdout "main_ok.txt"
}
function test_runs_prefix
{
	run_tables "./input/test_pref.tables"
	bt_assert_success
	bt_eval "cp $G_STDOUT ./compiled/test-pref.awk"

	run_main_pref
	bt_assert_success
	diff_stdout "main_ok_pref.txt"

	run_tables "./input/test_cmnt_pref.tables"
	bt_assert_success
	bt_eval "cp $G_STDOUT ./compiled/test-pref.awk"

	run_main_pref
	bt_assert_success
	diff_stdout "main_ok_pref.txt"
}
# </runs>

function test_all
{
	bt_eval test_opts
	bt_eval test_err_input
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
