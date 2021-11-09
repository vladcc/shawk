#!/bin/bash

G_AWK="${G_AWK:-awk}"
G_VERBOSE=""

function main
{
	if [ "$#" -gt 0 ]; then
		G_VERBOSE="yes"
	fi
	
	pushd "$(dirname $(realpath $0))" > /dev/null
	
	echo_eval "G_AWK=${G_AWK} bash generate.sh $@ 2>/dev/null"
	echo_eval run_parsers "$@"
	echo_eval bash ./c/cleanup.sh "$@"
	
	popd > /dev/null
}

function run_parsers
{
	echo_eval run_c "$@"
	echo_eval run_awk
}

function run_c
{
	local L_FBASE="parse_olvl"
	find ./c -name "${L_FBASE}_?.bin" | grep -q .
	if [ "$?" -ne 0 ]; then
		echo_eval bash ./c/compile.sh "$@"
	fi
	
	local L_RUN=""
	for i in {0..5}; do
		L_RUN=\
"diff <(./c/${L_FBASE}_${i}.bin test_input.txt) accept_result.txt"
		echo_eval "$L_RUN"
	done
}

function run_awk
{
	local L_FBASE="parse_olvl"
	local L_MAIN="./awk/main.awk"
	local L_PARSER=""
	
	local L_RUN=""
	for i in {0..5}; do
		L_PARSER="./awk/${L_FBASE}_${i}.awk"
		L_RUN=\
"diff <($G_AWK -f $L_MAIN -f $L_PARSER  test_input.txt) accept_result.txt"
		echo_eval "$L_RUN"
	done
}

function echo_eval
{
	if [ ! -z "$G_VERBOSE" ]; then
		echo "$@"
	fi
	
	eval "$@"
	
	if [ "$?" -ne 0 ]; then
		echo "$0: error: '$@' failed" >&2
		exit 1
	fi
}

main "$@"
