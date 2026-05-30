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
function test_opts
{
	bt_eval test_ver
	bt_eval test_help
	bt_eval test_fsm
}
# </options>

# <bad_input>
function test_bad_input
{
	run_structs ""
	bt_assert_failure
	diff_stderr "err_files.txt"

	run_structs "foo bar"
	bt_assert_failure
	diff_stderr "err_files.txt"

	run_structs "./input/test_err_no_types.structs"
	bt_assert_failure
	diff_stderr "err_structs_no_types.txt"

	run_structs "./input/test_err_undef_in_type.structs"
	bt_assert_failure
	diff_stderr "err_structs_undef_in_type.txt"

	run_structs "./input/test_err_undef_in_union.structs"
	bt_assert_failure
	diff_stderr "err_structs_undef_in_union.txt"

	run_structs "./input/test_err_redef_type.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_type.txt"

	run_structs "./input/test_err_redef_type_memb.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_type_memb.txt"

	run_structs "./input/test_err_redef_union_type.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_type.txt"

	run_structs "./input/test_err_redef_union.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union.txt"

	run_structs "./input/test_err_redef_union_name_1.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_name_1.txt"

	run_structs "./input/test_err_redef_union_name_2.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_name_2.txt"

	run_structs "./input/test_err_redef_union_name_3.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_name_3.txt"

	run_structs "./input/test_err_redef_union_name_4.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_name_4.txt"

	run_structs "./input/test_err_redef_union_name_5.structs"
	bt_assert_failure
	diff_stderr "err_structs_redef_union_name_5.txt"

	run_structs "./input/test_err_prefix_nodata.structs"
	bt_assert_failure
	diff_stderr "err_structs_prefix_noname.txt"

	run_structs "./input/test_err_type_nodata.structs"
	bt_assert_failure
	diff_stderr "err_structs_type_noname.txt"

	run_structs "./input/test_err_union_nodata.structs"
	bt_assert_failure
	diff_stderr "err_structs_union_noname.txt"

	run_structs "./input/test_err_union_rec_ref_1.structs"
	bt_assert_failure
	diff_stderr "err_structs_union_rec_ref_1.txt"

	run_structs "./input/test_err_union_rec_ref_2.structs"
	bt_assert_failure
	diff_stderr "err_structs_union_rec_ref_2.txt"
}
# </bad_input>

# <runs>
function test_runs
{
	run_structs "./input/test.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT compiled/test.awk"

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
	run_structs "./input/test_pref.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT ./compiled/test-pref.awk"

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
function test_runs_unions
{
	run_structs "./input/test_unions.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT ./compiled/test-unions.awk"

	run_main_unions "-vOk=1"
	bt_assert_success

	run_main_unions "-vNoEnt=1"
	bt_assert_failure
	diff_stderr "main_union_no_ent_1.txt"

	run_main_unions "-vNoEnt=2"
	bt_assert_failure
	diff_stderr "main_union_no_ent_2.txt"

	run_main_unions "-vNoEnt=3"
	bt_assert_failure
	diff_stderr "main_union_no_ent_3.txt"

	run_main_unions "-vBadEnt=1"
	bt_assert_failure
	diff_stderr "main_union_bad_ent_1.txt"

	run_main_unions "-vBadEnt=2"
	bt_assert_failure
	diff_stderr "main_union_bad_ent_2.txt"

	run_main_unions "-vBadType=1"
	bt_assert_failure
	diff_stderr "main_union_bad_type.txt"
}
function test_runs_unions_pref
{
	run_structs "./input/test_unions_pref.structs"
	bt_assert_success
	bt_eval "cp $G_STDOUT ./compiled/test-unions-pref.awk"

	run_main_unions_pref "-vOk=1"
	bt_assert_success

	run_main_unions_pref "-vNoEnt=1"
	bt_assert_failure
	diff_stderr "main_union_pref_no_ent_1.txt"

	run_main_unions_pref "-vNoEnt=2"
	bt_assert_failure
	diff_stderr "main_union_pref_no_ent_2.txt"

	run_main_unions_pref "-vNoEnt=3"
	bt_assert_failure
	diff_stderr "main_union_pref_no_ent_3.txt"

	run_main_unions_pref "-vBadEnt=1"
	bt_assert_failure
	diff_stderr "main_union_pref_bad_ent_1.txt"

	run_main_unions_pref "-vBadEnt=2"
	bt_assert_failure
	diff_stderr "main_union_pref_bad_ent_2.txt"

	run_main_unions_pref "-vBadType=1"
	bt_assert_failure
	diff_stderr "main_union_pref_bad_type.txt"
}
# </runs>

function test_all
{
	bt_eval test_opts
	bt_eval test_bad_input
	bt_eval test_runs
    bt_eval test_runs_prefix
	bt_eval test_runs_unions
	bt_eval test_runs_unions_pref
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
