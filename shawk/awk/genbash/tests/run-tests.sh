#!/bin/bash

function main
{
	source "$(dirname $(realpath $0))/../../../bash/bashtest/bashtest.sh"
	
	if [ "$#" -gt -0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	
	test_no_args
	test_err
	test_args
	
	bt_exit_success
}

function test_no_args
{
	local L_EXP='generated.sh 1.0
-f, --foo

-b, --bar

-x

--zig

@   @@'

	local L_GOT=""
	L_GOT="$(run_test)"
	bt_assert_success
	
	bt_diff "<(echo \"$L_GOT\")" "<(echo \"$L_EXP\")"
	bt_assert_success
	
}

function test_err
{
	local L_EXP=""
	
	local L_GOT=""
	L_GOT="$(run_test '-f' 2> /dev/null)"
	bt_assert_failure
	
	bt_diff "<(echo \"$L_EXP\")" "<(echo \"$L_GOT\")"
	bt_assert_success
	
L_GOT=\
"$(run_test '-f' 2>&1 || run_test '--foo' 2>&1 || run_test '--zig' 2>&1 || \
run_test '--unknown' 2>&1 || run_test '-u' 2>&1)"
	bt_assert_failure

	L_EXP="./generated.sh: error: '-f' missing argument
./generated.sh: error: '--foo' missing argument
./generated.sh: error: '--zig' missing argument
./generated.sh: error: '--unknown' unknown option
./generated.sh: error: '-u' unknown option"

	bt_diff "<(echo \"$L_GOT\")" "<(echo \"$L_EXP\")"
	bt_assert_success
}

function test_args
{
	local L_EXP="@x   @@
@x   @@
@ yes  @@
@ yes  @@
@  yes @@
@   y@@
@   @'a' 'b' 'c' @
@x yes yes y@'a' 'b' 'c' @
@x yes yes y@'a' 'b' 'c' @"

	local L_GOT=""
	
L_GOT=\
"$(run_test -f x && run_test --foo x && \
run_test -b && run_test --bar && \
run_test -x && \
run_test --zig y && \
run_test a b c && \
run_test -f x -b -x --zig y a b c && \
run_test a --foo x b --bar -x --zig y c)"
	bt_assert_success
	
	bt_diff "<(echo \"$L_GOT\")" "<(echo \"$L_EXP\")"
	bt_assert_success
}

function run_test
{ bash ./generated.sh "$@"; }

main "$@"
