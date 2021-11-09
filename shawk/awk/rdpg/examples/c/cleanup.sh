#!/bin/bash


function main
{
	if [ "$#" -gt 0 ]; then
		G_VERBOSE="yes"
	fi
	
	pushd "$(dirname $(realpath $0))" > /dev/null
	
	echo_eval cleanup
	
	popd > /dev/null
}

function cleanup
{
	echo_eval 'find . -name "parse_olvl_*.bin" -delete'
}

function echo_eval
{
	if [ ! -z "$G_VERBOSE" ]; then
		echo "$@"
	fi
	
	eval "$@"
}

main "$@"
