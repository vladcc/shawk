_G_AWK="${_G_AWK:-awk}"

readonly _G_AWK_TDIR="to-awk-test-src"
readonly _G_AWK_SRCD="to-awk"
readonly _G_RDPG_PARSER="_rdpg_parser"

function _generate_parser
{
	local L_COMP="../../../rdpg-comp.awk"
	local L_TO_AWK="../${_G_AWK_SRCD}/rdpg-to-awk.awk"
	local L_EXPR="../../common/expr.rdpg"

	bt_eval "$_G_AWK -f $L_COMP $* $L_EXPR | $_G_AWK -f $L_TO_AWK > ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk"
	bt_assert_success
	bt_eval "$_G_AWK -f $L_COMP $* $L_EXPR | $_G_AWK -f $L_TO_AWK -vOut='${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out'"
	bt_assert_success
	bt_diff_ok "${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk" "${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out.awk"
	bt_eval "rm -f ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out.awk"
}

function on_start
{
	bt_eval _generate_parser "$@"
}

function run_prog
{
	bt_eval "$_G_AWK -f ${_G_AWK_TDIR}/_main.awk -f ${_G_AWK_TDIR}/_lex.awk -f ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk -f ${_G_AWK_TDIR}/_btree.awk -f ${_G_AWK_TDIR}/_eval.awk $* 1>$G_STDOUT 2>$G_STDERR"
}

function on_finish
{
	bt_eval true
}

readonly _G_RESULT="../${_G_AWK_SRCD}/test-base/test_result.txt"
readonly _G_TO_AWK="../${_G_AWK_SRCD}/rdpg-to-awk.awk"
function _run_to_awk
{
	bt_eval "$_G_AWK -f $_G_TO_AWK $* > $_G_RESULT"
}
function _cleanup
{
	bt_eval "rm -f $_G_RESULT"
}
function test_custom
{
	_run_to_awk "-vHelp=1"
	bt_assert_success
	bt_diff_ok "$_G_RESULT" "../${_G_AWK_SRCD}/test-base/accept/help.txt"
	_cleanup

	_run_to_awk "-vVersion=1"
	bt_assert_success
	bt_diff_ok "$_G_RESULT" "../${_G_AWK_SRCD}/test-base/accept/version.txt"
	_cleanup

	bt_eval "echo foo | $_G_AWK -f $_G_TO_AWK > $_G_RESULT 2>&1"
	bt_assert_failure
	bt_diff_ok "$_G_RESULT" "../${_G_AWK_SRCD}/test-base/accept/err.txt"
	_cleanup
}
