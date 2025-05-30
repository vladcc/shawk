# <private>
_G_AWK="${_G_AWK:-awk}"

readonly _G_AWK_TDIR="to-awk-test-src"
readonly _G_AWK_SRCD="to-awk"
readonly _G_RDPG_PARSER="_rdpg_parser"

readonly _G_STDOUT="../${_G_AWK_SRCD}/test-base/test_result_stdout.txt"
readonly _G_STDERR="../${_G_AWK_SRCD}/test-base/test_result_stderr.txt"
readonly _G_TO_AWK="../${_G_AWK_SRCD}/rdpg-to-awk.awk"

function _run_to_awk
{
	bt_eval "$_G_AWK -f $_G_TO_AWK $* 1>$_G_STDOUT 2>$_G_STDERR"
}
function _cleanup
{
	bt_eval "rm -f $_G_STDOUT $_G_STDERR"
}

function _diff_stdout
{
	bt_diff_ok "$_G_STDOUT ../${_G_AWK_SRCD}/test-base/accept/$1"
}
function _diff_stderr
{
	bt_diff_ok "$_G_STDERR ../${_G_AWK_SRCD}/test-base/accept/$1"
}

function _generate_parser
{
	local L_COMP="../../../rdpg-comp.awk"
	local L_TO_AWK="../${_G_AWK_SRCD}/rdpg-to-awk.awk"
	local L_EXPR="../../common/expr.rdpg"
    local L_COMP_FLAGS=""
    local L_TO_AWK_FLAGS=""

    [ "$1" != "-v_Dummy_=0" ] && L_COMP_FLAGS="$1"
    [ "$2" != "-v_Dummy_=0" ] && L_TO_AWK_FLAGS="$2"

	bt_eval "$_G_AWK -f $L_COMP $L_COMP_FLAGS $L_EXPR | $_G_AWK -f $L_TO_AWK $L_TO_AWK_FLAGS > ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk"
	bt_assert_success

	bt_eval "$_G_AWK -f $L_COMP $L_COMP_FLAGS $L_EXPR | $_G_AWK -f $L_TO_AWK $L_TO_AWK_FLAGS -vOut='${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out'"
	bt_assert_success

    bt_diff_ok "${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk" "${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out.awk"
	bt_eval "rm -f ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.out.awk"
}

# <custom-test-cases>
function _test_custom_to_awk_base
{
	_run_to_awk "-vHelp=1"
	bt_assert_success
    _diff_stdout "help.txt"
    _diff_stderr "empty"
	_cleanup

	_run_to_awk "-vVersion=1"
	bt_assert_success
    _diff_stdout "version.txt"
    _diff_stderr "empty"
	_cleanup

    local L_OLD_G_AWK="$_G_AWK"
    _G_AWK="echo foo | $L_OLD_G_AWK"
    _run_to_awk
    bt_assert_failure
    _G_AWK="$L_OLD_G_AWK"

    _diff_stdout "empty"
    _diff_stderr "err.txt"
	_cleanup
}
# </custom-test-cases>
# </private>

# <public>
function on_pretest
{
	bt_eval _generate_parser "$@"
}
function on_postest
{
	bt_eval true
}

function run_parser
{
	bt_eval "$_G_AWK -f ${_G_AWK_TDIR}/_main.awk -f ${_G_AWK_TDIR}/_lex.awk -f ${_G_AWK_TDIR}/${_G_RDPG_PARSER}.awk -f ${_G_AWK_TDIR}/_btree.awk -f ${_G_AWK_TDIR}/_eval.awk $* 1>$G_STDOUT 2>$G_STDERR"
}

function test_backend_specific
{
    bt_eval _test_custom_to_awk_base
}
# </public>
