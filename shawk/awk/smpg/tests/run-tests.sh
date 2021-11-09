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

	L_RUN="$(run2 <(echo '%foo'))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 1: expected 'begin', got 'foo' instead$\" <(echo \"$L_RUN\")) <(echo 1)"

	L_RUN="$(run2 <(echo '%begin'))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line end-of-file: expected 'generate', got 'begin' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	local L_SRC=\
'%begin
%include
%end
foo'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: line not source or a comment$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end
%foo'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: expected 'fsm', got 'foo' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%foo'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line end-of-file: expected 'generate', got 'include' instead$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end
%fsm
%end'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 4: syntax should be '%fsm <fsm-name>'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end

%fsm fsm_name
%end
%handler
%end'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 6: 'fsm' block empty$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end

%fsm fsm_name
foo
%end
%handler
%end'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 8: syntax should be '%handler <regex> \[args\]'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end
%fsm fsm_name
foo
%end
%handler foo
%end
;
%template
%end'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 10: syntax should be '%template <regex>'$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
%end
%fsm fsm_name
foo
%end
%handler foo
;
%end
%template foo
%end
%other
%end
%generate'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 5: fsm: bad separator$\" <(echo \"$L_RUN\")) <(echo 1)"
	
	L_SRC=\
'%begin
%include
empty
%end
%fsm fsm_name
foo -> bar
bar -> foo
%end
%handler foo
;
%end
%template foo
%end
%other
%end
%generate'
	L_RUN="$(run2 <(echo "$L_SRC"))"
	bt_assert_failure
	bt_diff_ok "<(grep -c \"smpg.awk: error: file .* line 3: reading 'empty': .*$\" <(echo \"$L_RUN\")) <(echo 1)"
}

function test_version
{
	bt_diff_ok "<(echo '$(run -vVersion=1)') <(echo 'smpg.awk 1.0')"
}

function test_all
{
	bt_eval test_version
	bt_eval test_errors
	bt_eval test_self_gen
}

main "$@"
