#!/bin/bash

# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2021-09-29

# Version 1.11

set -u

readonly G_BT_SCRIPT_NAME="$(basename $0)"
readonly G_BT_BASE_DIR="$(dirname $(realpath $0))"
readonly G_BT_DEV_NULL="/dev/null"
G_BT_VERBOSE=0

function bt_enter { pushd "$G_BT_BASE_DIR" > "$G_BT_DEV_NULL"; }
function bt_leave { popd > "$G_BT_DEV_NULL"; exit "$1"; }

function bt_exit_success { bt_leave 0; }
function bt_exit_failure { bt_leave 1; }
function bt_exit_failure_strace { bt_stack_trace; bt_exit_failure; }

function bt_assert { bt_eval "$@" || bt_error_exit_st "'$@' failed"; }
function bt_assert_success { bt_assert "[ $? -eq 0 ]"; }
function bt_assert_failure { bt_assert "[ $? -ne 0 ]"; }

function bt_diff { bt_eval "diff $@"; }
function bt_diff_ok { bt_diff "$@"; bt_assert_success; }
function bt_diff_nok { bt_diff "$@"; bt_assert_failure; }
function bt_error_print { echo "$G_BT_SCRIPT_NAME: error: $@" >&2; }
function bt_error_exit { bt_error_print "$@"; bt_exit_failure; }
function bt_error_exit_st { bt_error_print "$@"; bt_exit_failure_strace; }

function bt_set_verbose { G_BT_VERBOSE=1; }
function bt_eval { [ "$G_BT_VERBOSE" -ne 1 ] || echo "$@"; eval "$@"; }
function bt_eval_ok { bt_eval "$@"; bt_assert_success; }
function bt_eval_nok { bt_eval "$@"; bt_assert_failure; }
function bt_stack_trace
{
	local L_FRAME=0;
	while caller $L_FRAME; do
		((++L_FRAME))
	done
}
