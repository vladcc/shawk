#!/bin/bash

G_AWK="${G_AWK:-awk}"

function main
{
	local L_BT_DIR="$(dirname $(realpath $0))/../../../../../bash/bashtest"
	source "$L_BT_DIR/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

function run
{
	local L_REPLI="../../../repli.awk"
	eval "$G_AWK -f $L_REPLI $@"
}

function test_versions
{
	local L_RES=""
	
	L_RES="$(run -vVersion=1)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo 'repli.awk 1.0')"
}

function test_parse_errors
{
local L_EXP=(
"repli.awk: error: unbalanced file begin/end: 'no files in input'"
"repli.awk: error: line 1: empty file name"
"repli.awk: error: line 1: unbalanced file begin/end: 'foo'"
"repli.awk: error: line 2: empty file name"
"repli.awk: error: line 3: unbalanced file begin/end: ';FILE_END foo'"
"repli.awk: error: line 1: unbalanced file begin/end: 'foo'"
"repli.awk: error: line 3: ;ERROR I am error"

"repli.awk: error: line 3: ;ERROR I am error
repli.awk: error: line 5: ;ERROR I am error 2"
)
	
local L_TEXT=(
""
";FILE_BEGIN"
";FILE_BEGIN foo"

";FILE_BEGIN foo
;FILE_END"

";FILE_BEGIN foo
;FILE_BEGIN bar
;FILE_END foo"

";FILE_BEGIN foo
;FILE_BEGIN bar
;FILE_END bar"

";FILE_BEGIN foo
a
;ERROR I am error

;FILE_END foo"


";FILE_BEGIN foo
a
;ERROR I am error
b
;ERROR I am error 2
;FILE_END foo"
)
	
	local L_RES=""
	local len="${#L_TEXT[@]}"
	for ((i = 0; i < ${len}; ++i));
	do
		L_RES="$(run "<(echo \"${L_TEXT[$i]}\") 2>&1 1>/dev/null")"
		bt_assert_failure
		bt_diff_ok "<(echo \"$L_RES\") <(echo \"${L_EXP[$i]}\")"
	done
}

function test_replay
{
	local L_DATA="./data.doti"
	
	local L_RES=""
	local L_EXP=""
	
	L_EXP=\
"repli.awk: error: test -d './data/': directory doesn't exists
repli.awk: error: test -d './data/leaf/': directory doesn't exists

Proposed fix:
mkdir -p './data/' './data/leaf/'

repli.awk: quitting due to errors"
	L_RES="$(run $L_DATA 2>&1 1>/dev/null)"
	bt_assert_failure
	bt_diff_ok "<(echo \"$L_RES\") <(echo \"$L_EXP\")"
	
	bt_eval "mkdir -p './data/' './data/leaf/'"
	bt_assert_success
	
	L_EXP=\
"repli.awk: info: writing file './data/entry.info'
repli.awk: info: writing file './data/leaf/inc_leaf.info'
repli.awk: info: writing file './data/inc_inc.info'"
	L_RES="$(run $L_DATA)"
	bt_assert_success
	bt_diff_ok "<(echo \"$L_RES\") <(echo \"$L_EXP\")"
	
	L_EXP=\
"repli.awk: error: test -f './data/entry.info': file exists
repli.awk: error: test -f './data/leaf/inc_leaf.info': file exists
repli.awk: error: test -f './data/inc_inc.info': file exists

Proposed fix:
rm './data/entry.info' './data/leaf/inc_leaf.info' './data/inc_inc.info'

repli.awk: quitting due to errors"
	L_RES="$(run $L_DATA 2>&1 1>/dev/null)"
	bt_assert_failure
	bt_diff_ok "<(echo \"$L_RES\") <(echo \"$L_EXP\")"
	
	# clean up
	bt_eval "rm './data/entry.info' './data/leaf/inc_leaf.info' "\
	"'./data/inc_inc.info'"
	bt_assert_success
	
	bt_eval "rmdir './data/leaf' './data'"
	bt_assert_success
}

function test_all
{
	bt_eval test_versions
	bt_eval test_parse_errors
	bt_eval test_replay
}

main "$@"
