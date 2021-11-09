#!/bin/bash

G_AWK="${G_AWK:-awk}"

function main
{
	local L_BT_DIR="$(dirname $(realpath $0))/../../../bash/bashtest"
	source "$L_BT_DIR/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

function test_end_to_end
{
	local L_PTRIP="../ptrip.awk"
	local L_DOTI="../doti.awk"
	local L_REPLI="../repli.awk"
	local L_DATA="./data/entry.info"
	
	bt_eval "mkdir -p './data2/' './data2/leaf/'"
	bt_assert_success
	
	bt_eval "$G_AWK -f $L_PTRIP $L_DATA" \
	"| $G_AWK -f $L_DOTI" \
	"| sed 's_./data_./data2_g'" \
	"| $G_AWK -f $L_REPLI 1>/dev/null"
	bt_assert_success
	
	bt_diff_ok "<(find ./data -type f -print -exec cat {} \;) " \
	"<(find ./data2 -type f -print -exec cat {} \; | sed 's_./data2_./data_')"

	bt_eval "rm './data2/entry.info' './data2/inc_inc.info' \
	'./data2/leaf/inc_leaf.info'"
	bt_assert_success
	
	bt_eval "rmdir './data2/leaf' './data2'"
	bt_assert_success
}

function test_all
{
	bt_eval test_end_to_end
}

main "$@"

# for easy manual clean up
# rm './data2/entry.info' './data2/inc_inc.info' './data2/leaf/inc_leaf.info' && rmdir './data2/leaf' './data2'
