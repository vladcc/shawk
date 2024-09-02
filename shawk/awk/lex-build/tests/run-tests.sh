#!/bin/bash

readonly G_TEST_CASES="base_case shuffled error"
G_AWK="${G_AWK:-awk}"

# <misc>
function make_input_name { echo "./test-data/${1}.txt"; }
function make_accept_name { echo "./test-accept/${1}_accept.txt"; }

function run_tests_on_single_file
{
	local L_EXEC="$@"
	local L_INPUT=""
	local L_ACCEPT=""

	for test in $G_TEST_CASES; do
		L_INPUT="$(make_input_name $test)"
		L_ACCEPT="$(make_accept_name $test)"
		eval_success "diff <($L_EXEC $L_INPUT) $L_ACCEPT"
	done
}

function run_tests_str_pos
{
	local L_EXEC="$@"
	local L_INPUT="$(make_input_name str_pos)"
	local L_ACCEPT="$(make_accept_name str_pos)"
	eval_success "diff <($L_EXEC $L_INPUT) $L_ACCEPT"
}

function run_tests_on_multiple_files
{
	local L_EXEC="$@"
	local L_INPUT=""
	local L_ACCEPT=""

	for test in $G_TEST_CASES; do
		L_INPUT="$(make_input_name $test)"
		L_ACCEPT="$(make_accept_name $test)"
		eval_success "diff <($L_EXEC $L_INPUT $L_INPUT) "\
		"<(cat $L_ACCEPT $L_ACCEPT)"
	done
}

function run_test_version_info
{
	local L_LEX="../$1"
	local L_VER="$2"
	eval_success "diff <($G_AWK -f $L_LEX -vVersion=1) "\
	"<(echo \"$L_VER\")"
}
function gen_lex
{
	local L_REDIRECT=""

	if [ ! "$G_IS_VERBOSE" ]; then
		L_REDIRECT=" > /dev/null"
	fi

	bt_eval "bash ./generate-lex.sh $L_REDIRECT"
}

function eval_success
{
	bt_eval "$@"
	bt_assert_success
}
# </misc>

# <awk>
function test_awk_ver
{
	run_test_version_info "lex-awk.awk" "lex-awk.awk 1.7.1"
}
function test_awk_run_test
{
	local L_LEX="$G_AWK -f ./awk/lex.awk -f ./awk/inc_lex.awk"
	local L_LEX_PREF="$G_AWK -f ./awk/foo-lex.awk -f ./awk/foo_inc_lex.awk"

	bt_eval run_tests_on_single_file "$L_LEX"
	bt_eval run_tests_on_multiple_files "$L_LEX"
	bt_eval run_tests_on_single_file "$L_LEX_PREF"
	bt_eval run_tests_on_multiple_files "$L_LEX_PREF"

	local L_LEX="$G_AWK -f ./awk/lex.awk -vStrPos=1 -f ./awk/inc_lex.awk"
	local L_LEX_PREF="$G_AWK -f ./awk/foo-lex.awk -vStrPos=1 -f ./awk/foo_inc_lex.awk"
	bt_eval run_tests_str_pos "$L_LEX"
	bt_eval run_tests_str_pos "$L_LEX_PREF"
}
function test_awk
{
	runf "test_awk_run_test"
}
# </awk>

# <C>
function test_c_clean { bt_eval "rm *lex_*.bin"; }

readonly G_C_LEXERS="lex_bsearch lex_ifs foo_lex_bsearch foo_lex_ifs"
function test_c_compile_lex
{
	local L_LEX_NO_FOO="lex_bsearch lex_ifs"
	local L_LEX_FOO="foo_lex_bsearch foo_lex_ifs"

	for lexer in $L_LEX_NO_FOO; do
		eval_success "gcc ./c/${lexer}.c ./c/lex_main.c -o ${lexer}0.bin -Wall"
		eval_success \
			"gcc ./c/${lexer}.c ./c/lex_main.c -o ${lexer}3.bin -Wall -O3"
		eval_success \
			"gcc ./c/${lexer}.c ./c/unit_test.c -o ${lexer}_unit_test.bin -Wall"
	done

	for lexer in $L_LEX_FOO; do
		eval_success \
			"gcc ./c/${lexer}.c ./c/foo_lex_main.c -o ${lexer}0.bin -Wall"
		eval_success \
			"gcc ./c/${lexer}.c ./c/foo_lex_main.c -o ${lexer}3.bin -Wall -O3"
		eval_success \
		"gcc ./c/${lexer}.c ./c/foo_unit_test.c -o ${lexer}_unit_test.bin -Wall"
	done
}
function test_c_run_tests
{
	for lexer in $G_C_LEXERS; do
		bt_eval run_tests_on_single_file "./${lexer}0.bin"
		bt_eval run_tests_on_multiple_files "./${lexer}0.bin"
		bt_eval run_tests_on_single_file "./${lexer}3.bin"
		bt_eval run_tests_on_multiple_files "./${lexer}3.bin"
		eval_success "./${lexer}_unit_test.bin"
	done
}
function test_c_ver
{
	run_test_version_info "lex-c.awk" "lex-c.awk 1.93"
}
function test_c_kw_len
{
	local L_MSG=""
	local L_EXPECT="lex-c.awk: error: keyword 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa': length cannot be greater than 31"

	L_MSG="$($G_AWK -f ../lex-first.awk input-err-lex-c-kw-len.lb | $G_AWK -f ../lex-c.awk 2>&1)"
	bt_assert_failure

	bt_diff "<(echo \"$L_MSG\")" "<(echo \"$L_EXPECT\")"
	bt_assert_success
}
function test_c
{
	runf "test_c_kw_len
	test_c_compile_lex
	test_c_run_tests
	test_c_clean"
}
# </C>

# <first>
function test_lex_first_ver
{
	run_test_version_info "lex-first.awk" "lex-first.awk 1.41"
}
# </first>

function test_versions
{
	runf "test_lex_first_ver
	test_c_ver
	test_awk_ver"
}

function test_all
{
	runf "test_versions
	gen_lex
	test_c
	test_awk"
}

function runf
{
	for fun in $@; do
		bt_eval "$fun #fcall"
	done
}

G_IS_VERBOSE=""
function main
{
	source "$(dirname $(realpath $0))/../../../bash/bashtest/bashtest.sh"

	if [ "$#" -gt 0 ]; then
		G_IS_VERBOSE="x"
		bt_set_verbose
	fi

	bt_enter
	runf "test_all"
	bt_exit_success
}

main "$@"
