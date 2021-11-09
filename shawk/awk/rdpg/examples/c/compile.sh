#!/bin/bash

G_VERBOSE=""

function main
{
	if [ "$#" -gt 0 ]; then
		G_VERBOSE="yes"
	fi
	
	pushd "$(dirname $(realpath $0))" > /dev/null
	
	echo_eval compile_c
	
	popd > /dev/null
}

function compile_c
{
	local L_FBASE="parse_olvl"
	for i in {0..5}
	do
		echo_eval gcc "./${L_FBASE}_${i}.c" -o "./${L_FBASE}_${i}.bin" -Wall -lm
	done
}

function echo_eval
{
	if [ ! -z "$G_VERBOSE" ]; then
		echo "$@"
	fi
	
	eval "$@"
}

main "$@"
