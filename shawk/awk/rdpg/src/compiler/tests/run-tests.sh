#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_BASHTEST="$(dirname $(realpath $0))/../../../../../bash/bashtest/bashtest.sh"
readonly G_STDOUT="./test_result_stdout.txt"
readonly G_STDERR="./test_result_stderr.txt"

readonly G_EXPR_GRMR="../../common/expr.rdpg"

function run
{
	bt_eval "$G_AWK -f ../rdpg-comp.awk $* 1>$G_STDOUT 2>$G_STDERR"
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
function cond_print
{
	[ "$G_BT_VERBOSE" -ne 0 ] && echo "$*"
}

# <tests>
# <grammar-checks>
# <errors>
function test_checks_errs
{
	local L_TESTS="undefined redefined left_fact"
	L_TESTS="${L_TESTS} left_rec first_first first_follow"

	for test in $L_TESTS; do
		cond_print "test_${test}"
		run "data/checks/err/${test}.rdpg"
		bt_assert_failure
		diff_stdout "empty"
		diff_stderr "checks/err/${test}.txt"
		cleanup
	done
}
# </errors>

# <warnings>
function test_checks_warns
{
	run "-vWarnAll=1 -vWarnErr=1 data/checks/warn/all.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "checks/warn/all.txt"
	cleanup

	run "-vWarnReach=1 -vWarnErr=1 data/checks/warn/all.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "checks/warn/noreach.txt"
	cleanup

	run "-vWarnEsc=1 -vWarnErr=1 data/checks/warn/all.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "checks/warn/esc_tr.txt"
	cleanup
}
# </warnings>

function test_checks
{
	bt_eval test_checks_errs
	bt_eval test_checks_warns
}
# </grammar-checks>

# <fatal-err>
function test_fatal_warn_err
{
	run "data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/no_fatal.txt"
	cleanup

	run "-vFatalErr=1 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_err_1.txt"
	cleanup

	run "-vFatalErr=2 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_err_2.txt"
	cleanup

	run "-vFatalErr=3 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/no_fatal.txt"
	cleanup

	run "-vWarnAll=1 -vWarnErr=1 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/no_fatal_warn.txt"
	cleanup

	run "-vWarnAll=1 -vWarnErr=1 -vFatalErr=1 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_err_warn_1.txt"
	cleanup

	run "-vWarnAll=1 -vWarnErr=1 -vFatalErr=2 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_err_warn_2.txt"
	cleanup

	run "-vWarnAll=1 -vWarnErr=1 -vFatalErr=3 data/fatal_err/fatal_err.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_err_warn_3.txt"
	cleanup
}
function test_fatal_parse
{
	run "data/fatal_err/fatal_parse.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_parse.txt"
	cleanup

	run "-vFatalErr=1 data/fatal_err/fatal_parse.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_parse_1.txt"
	cleanup

	run "-vFatalErr=2 data/fatal_err/fatal_parse.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_parse_2.txt"
	cleanup

	run "-vFatalErr=3 data/fatal_err/fatal_parse.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_parse_3.txt"
	cleanup

	run "-vFatalErr=4 data/fatal_err/fatal_parse.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "fatal_err/fatal_parse.txt"
	cleanup
}
function test_fatal_err
{
	bt_eval test_fatal_warn_err
	bt_eval test_fatal_parse
}
# </fatal-err>

# <flags>
function test_flag_grammar
{
	run "-vGrammar=1 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "flags/grammar/grammar_ll1.txt"
	diff_stderr "empty"
	cleanup

	run "-vGrammar=1 data/checks/err/first_first.rdpg"
	bt_assert_success
	diff_stdout "flags/grammar/grammar_no_ll1.txt"
	diff_stderr "empty"
	cleanup
}
function test_flag_rules
{
	run "-vRules=1 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "flags/rules/rules_ll1.txt"
	diff_stderr "empty"
	cleanup

	run "-vRules=1 data/checks/err/first_first.rdpg"
	bt_assert_success
	diff_stdout "flags/rules/rules_no_ll1.txt"
	diff_stderr "empty"
	cleanup
}
function test_flag_sets
{
	run "-vSets=1 data/sets/sets.rdpg"
	bt_assert_success
	diff_stdout "sets/sets.txt"
	diff_stderr "empty"
	cleanup

	run "-vSets=1 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "flags/sets/sets_ll1.txt"
	diff_stderr "empty"
	cleanup

	run "-vSets=1 data/checks/err/first_first.rdpg"
	bt_assert_success
	diff_stdout "flags/sets/sets_no_ll1.txt"
	diff_stderr "empty"
	cleanup
}
function test_flag_tbl
{
	run "-vTable=1 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "flags/tbl/tbl_ll1.txt"
	diff_stderr "empty"
	cleanup

	run "-vTable=1 data/checks/err/first_first.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "checks/err/first_first.txt"
	cleanup
}
function test_flag_check
{
	run "-vCheck=1 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "empty"
	diff_stderr "empty"
	cleanup

	run "-vCheck=1 data/checks/err/first_first.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "checks/err/first_first.txt"
	cleanup
}

function test_flag_imm
{
	run "-vImm=0 $G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "expr-no-imm.ir"
	diff_stderr "empty"
	cleanup
}

function test_flags
{
	bt_eval test_flag_imm
	bt_eval test_flag_grammar
	bt_eval test_flag_rules
	bt_eval test_flag_sets
	bt_eval test_flag_tbl
	bt_eval test_flag_check
}
# </flags>

# <messages>
function test_example
{
	run "-vExample=1"
	bt_assert_success
	diff_stdout "messages/example.txt"
	diff_stderr "empty"
	cleanup
}
function test_version
{
	run "-vVersion=1"
	bt_assert_success
	diff_stdout "messages/version.txt"
	diff_stderr "empty"
	cleanup
}
function test_help
{
	run "-vHelp=1"
	bt_assert_success
	diff_stdout "messages/help.txt"
	diff_stderr "empty"
	cleanup
}
function test_try_use
{
	run
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "messages/try_use.txt"
	cleanup

	run "foo bar"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "messages/try_use.txt"
	cleanup
}
function test_messages
{
	bt_eval test_example
	bt_eval test_version
	bt_eval test_help
	bt_eval test_try_use
}
# </messages>

# <misc>
function test_lex_eol
{
	run "data/misc/err_eol.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "misc/err_eol.txt"
	cleanup
}
function test_misc
{
	bt_eval test_lex_eol
}
# </misc>

# <sync>
function test_sync_use_case
{
	run "data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_default.ir"
	diff_stderr "empty"
	cleanup

	run "-vSync=1 data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_default.ir"
	diff_stderr "empty"
	cleanup

	run "-vSync=0 data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_none.ir"
	diff_stderr "empty"
	cleanup

	run "-vSync='bar=ZIG' data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_custom_1.ir"
	diff_stderr "empty"
	cleanup

	run "-vSync='bar=ZIG,ZEG' data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_custom_2.ir"
	diff_stderr "empty"
	cleanup

	run "-vSync='bar=ZIG,ZAG,ZEG' data/sync/sync_test.rdpg"
	bt_assert_success
	diff_stdout "sync/sync_custom_3.ir"
	diff_stderr "empty"
	cleanup
}
function test_sync_err_case
{
	run "-vSync='biz=ZIG' data/sync/sync_test.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "sync/sync_err_not_an_lhs.txt"
	cleanup

	run "-vSync='baz=ZAG' data/sync/sync_test.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "sync/sync_err_not_in_follow.txt"
	cleanup

	run "-vSync='baz=ZYG' data/sync/sync_test.rdpg"
	bt_assert_failure
	diff_stdout "empty"
	diff_stderr "sync/sync_err_not_a_terminal.txt"
	cleanup
}
function test_sync
{
	bt_eval test_sync_use_case
	bt_eval test_sync_err_case
}
# </sync>

function test_use_case
{
	run "$G_EXPR_GRMR"
	bt_assert_success
	diff_stdout "expr.ir"
	diff_stderr "empty"
	cleanup
}

function test_all
{
	bt_eval test_messages
	bt_eval test_checks
	bt_eval test_fatal_err
	bt_eval test_flags
	bt_eval test_misc
	bt_eval test_use_case
	bt_eval test_sync
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
