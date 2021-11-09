#!/bin/bash

function main
{
	pushd "$(dirname $(realpath $0))" > /dev/null
	source "../bashtest.sh"
	popd > /dev/null
	
	local L_STACK1="$(dirs | awk '{print NF}')"
	
	bt_enter
	local L_STACK2="$(dirs | awk '{print NF}')"
	
	if [ ! "$L_STACK2" -gt "$L_STACK1" ]; then
		err_exit "pushd didn't push"
	fi
	
	if [ "$(basename $(dirs +0))" != "tests" ]; then
		err_exit "pushd pushed the wrong directory"
	fi
	
	bt_exit_success
}

function err_exit
{
	local L_NSCR="$(basename $0)"
	echo "$L_NSCR: error: bt_enter: $@" >&2
	exit 1
}

main "$@"
