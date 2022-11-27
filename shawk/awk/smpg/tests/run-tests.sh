#!/bin/bash

G_AWK="${G_AWK:-awk}"

function main
{
	source "$(dirname $(realpath $0))/../../../bash/bashtest/bashtest.sh"
	
	if [ "$#" -gt -0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

function test_self_gen
{
	# have to change dir to parent so the includes can be found
	pushd ../ > "/dev/null"
	bt_diff_ok "<($G_AWK -f smpg.awk self.smpg) smpg.awk"
	popd > "/dev/null"
}

function run { eval "$G_AWK -f ../smpg.awk $@"; }
function run2 { run "$@ 2>&1 1>/dev/null"; }

function test_errors
{
	local L_RUN=""
	
	L_RUN="$(run2)"
	bt_assert_failure
	
	local L_RES=\
'Use: smpg.awk [options] <input-file>
Try: smpg.awk -vHelp=1'
	
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_RUN')"
	
	L_RUN="$(run2 <(echo 'foo'))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 1: line not source or a comment$\" <(echo \"$L_RUN\")) <(echo 1)"

	L_RUN="$(run2 <(echo '@foo'))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 1: expected 'BEGIN', got 'foo' instead$\" <(echo \"$L_RUN\")) <(echo 1)"

	L_RUN="$(run2 <(echo '@BEGIN'))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line end-of-file: expected 'GENERATE', got 'BEGIN' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	local L_SRC=\
'@BEGIN
@INCLUDE
@END
foo'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: line not source or a comment$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END
@FOO'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: expected 'FSM', got 'FOO' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@FOO'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line end-of-file: expected 'GENERATE', got 'INCLUDE' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END
@FSM
@END'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: syntax should be '@FSM <fsm-name>'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END

@FSM fsm_name
@END
@HANDLER
@END'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 6: 'FSM' block empty$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END

@FSM fsm_name
foo
@END
@HANDLER
@END'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 8: syntax should be '@HANDLER <regex> \[args\]'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END
@FSM fsm_name
foo
@END
@HANDLER foo
@END
;
@TEMPLATE
@END'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 10: syntax should be '@TEMPLATE <regex>'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
@END
@FSM fsm_name
foo
@END
@HANDLER foo
;
@END
@TEMPLATE foo
@END
@OTHER
@END
@GENERATE'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 5: fsm: bad separator$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'@BEGIN
@INCLUDE
empty
@END
@FSM fsm_name
foo -> bar
bar -> foo
@END
@HANDLER foo
;
@END
@TEMPLATE foo
@END
@OTHER
@END
@GENERATE'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 3: reading 'empty': .*$\" <(echo \"$L_RUN\")) <(echo 1)"
}

function test_version
{
	bt_diff_ok "<(echo '$(run -vVersion=1)') <(echo 'smpg.awk 2.0')"
}

function test_all
{
	bt_eval test_version
	bt_eval test_errors
	bt_eval test_self_gen
}

main "$@"
