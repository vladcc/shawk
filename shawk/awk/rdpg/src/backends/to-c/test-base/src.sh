_G_AWK="${_G_AWK:-awk}"
_G_CMP="gcc"

readonly _G_C_TDIR="to-c-test-src"
readonly _G_C_SRCD="to-c"

readonly _G_C_BIN="${_G_C_TDIR}/main.bin"
readonly _G_C_MAIN_SRC="${_G_C_TDIR}/main.c"
readonly _G_C_PSR_SRC="${_G_C_TDIR}/rdpg_parser.c"
readonly _G_C_PSR_FOO_SRC="${_G_C_TDIR}/rdpg_parser_foo.c"

function _c_cleanup
{
	local L_C_PSR_H="${_G_C_TDIR}/rdpg_parser.h"
	local L_C_PSR_FOO_H="${_G_C_TDIR}/rdpg_parser_foo.h"

	bt_eval "rm -f ${_G_C_BIN}"
}

function _generate_parser
{
	bt_eval "command -v ${_G_CMP} > /dev/null"
	bt_assert_success

	local L_COMP="../../../rdpg-comp.awk"
	local L_TO_C="../${_G_C_SRCD}/rdpg-to-c.awk"
	local L_EXPR="../../common/expr.rdpg"

	bt_eval "$_G_AWK -f $L_COMP $* $L_EXPR | $_G_AWK -f $L_TO_C -vDir=./${_G_C_TDIR}"
	bt_assert_success

	bt_eval "$_G_AWK -f $L_COMP $* $L_EXPR | sed -E 's/[A-Z][A-Z_]+/&_FOO/g' | $_G_AWK -f $L_TO_C -vTag=foo -vDir=./${_G_C_TDIR}"
	bt_assert_success

	local L_CMP_FLAGS="-Wall -Werror -Wfatal-errors"

	# compile with *_foo; tests more than one parser in a binary
	bt_eval "${_G_CMP} ${_G_C_MAIN_SRC} ${_G_C_PSR_SRC} ${_G_C_PSR_FOO_SRC} -DCOMPILE_FOO -o ${_G_C_BIN} ${L_CMP_FLAGS}"
	bt_assert_success

	bt_eval "${_G_CMP} ${_G_C_MAIN_SRC} ${_G_C_PSR_SRC} -o ${_G_C_BIN} ${L_CMP_FLAGS}"
	bt_assert_success
}

function on_start
{
	bt_eval _c_cleanup
	bt_eval _generate_parser "$@"
}

function run_prog
{
	bt_eval "${_G_C_BIN} $* 1>$G_STDOUT 2>$G_STDERR"
}

function on_finish
{
	bt_eval _c_cleanup
	bt_eval true
}

readonly _G_RESULT="../${_G_C_SRCD}/test-base/test_result.txt"
readonly _G_TO_C="../${_G_C_SRCD}/rdpg-to-c.awk"
function _run_to_c
{
	bt_eval "$_G_AWK -f $_G_TO_C $* > $_G_RESULT"
}
function _cleanup
{
	bt_eval "rm -f $_G_RESULT"
}
function test_custom
{
	_run_to_c "-vHelp=1"
	bt_assert_success
	bt_diff_ok "$_G_RESULT" "../${_G_C_SRCD}/test-base/accept/help.txt"
	_cleanup

	_run_to_c "-vVersion=1"
	bt_assert_success
	bt_diff_ok "$_G_RESULT" "../${_G_C_SRCD}/test-base/accept/version.txt"
	_cleanup

	bt_eval "echo foo | $_G_AWK -f $_G_TO_C > $_G_RESULT 2>&1"
	bt_assert_failure
	bt_diff_ok "$_G_RESULT" "../${_G_C_SRCD}/test-base/accept/err.txt"
	_cleanup
}
