#!/bin/bash

function main
{
	pushd "$(dirname $(realpath $0))" > /dev/null
	source "../bashtest.sh"
	popd > /dev/null
	 
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	 
	bt_enter
	test_assert
	bt_exit_success
}

function test_assert
{
	bt_eval true
	bt_assert_success

	bt_eval false
	bt_assert_failure

	bt_eval_ok true
	bt_eval_nok false
}

main "$@"
