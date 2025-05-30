# <private>
_G_AWK="${_G_AWK:-awk}"
_G_CMP="gcc"

readonly _G_C_TDIR="to-c-test-src"
readonly _G_C_SRCD="to-c"

readonly _G_C_BIN="${_G_C_TDIR}/main.bin"
readonly _G_C_MAIN_SRC="${_G_C_TDIR}/main.c"
readonly _G_C_PSR_SRC="${_G_C_TDIR}/rdpg_parser.c"
readonly _G_C_PSR_FOO_SRC="${_G_C_TDIR}/rdpg_parser_foo.c"

readonly _G_STDOUT="../${_G_C_SRCD}/test-base/test_result_stdout.txt"
readonly _G_STDERR="../${_G_C_SRCD}/test-base/test_result_stderr.txt"
readonly _G_TO_C="../${_G_C_SRCD}/rdpg-to-c.awk"

function _run_to_c
{
	bt_eval "$_G_AWK -f $_G_TO_C $* 1>$_G_STDOUT 2>$_G_STDERR"
}
function _c_cleanup
{
	bt_eval "rm -f $_G_C_BIN $*"
}

function _cleanup
{
	bt_eval "rm -f $_G_STDOUT $_G_STDERR $*"
}

function _diff_stdout
{
	bt_diff_ok "$_G_STDOUT ../${_G_C_SRCD}/test-base/accept/$1"
}
function _diff_stderr
{
	bt_diff_ok "$_G_STDERR ../${_G_C_SRCD}/test-base/accept/$1"
}

function _compile_parser
{
    bt_eval "command -v ${_G_CMP} > /dev/null"
	bt_assert_success

	local L_CMP_FLAGS="-Wall -Werror -Wfatal-errors"

	# compile with *_foo; tests more than one parser in a binary
	bt_eval "${_G_CMP} ${_G_C_MAIN_SRC} ${_G_C_PSR_SRC} ${_G_C_PSR_FOO_SRC} -DCOMPILE_FOO -o ${_G_C_BIN} ${L_CMP_FLAGS}"
	bt_assert_success

	bt_eval "${_G_CMP} ${_G_C_MAIN_SRC} ${_G_C_PSR_SRC} -o ${_G_C_BIN} ${L_CMP_FLAGS}"
	bt_assert_success
}

function _generate_parser_src
{
	local L_COMP="../../../rdpg-comp.awk"
	local L_TO_C="../${_G_C_SRCD}/rdpg-to-c.awk"
	local L_EXPR="../../common/expr.rdpg"

    local L_HOW="$1"
    local L_COMP_FLAGS="$2"
    local L_TO_C_FLAGS="$3"
    local L_TAG=""

    if [ "$L_HOW" = "normal" ]; then
        bt_eval "$_G_AWK -f $L_COMP $L_COMP_FLAGS $L_EXPR | $_G_AWK -f $L_TO_C $L_TO_C_FLAGS -vDir=./${_G_C_TDIR}"
    elif [ "$L_HOW" = "tag" ]; then
        L_TAG="$4"
        bt_eval "$_G_AWK -f $L_COMP $L_COMP_FLAGS $L_EXPR | sed -E 's/[A-Z][A-Z_]+/&_${L_TAG}/g' | $_G_AWK -f $L_TO_C $L_TO_C_FLAGS -vDir=./${_G_C_TDIR}"
    elif [ "$L_HOW" = "bad-enum-state" ]; then
        bt_eval "$_G_AWK -f $L_COMP $L_COMP_FLAGS $L_EXPR | $_G_AWK -f ./${_G_C_TDIR}/enum_bad_state_begin.awk -f $L_TO_C $L_TO_C_FLAGS -vDir=./${_G_C_TDIR}"
    else
        echo "error: _generate_parser_src: unknown action $L_HOW" 1>&2 2>&1
        false
    fi
}

function _generate_parser
{

    local L_COMP_FLAGS=""
    local L_TO_C_FLAGS=""

    [ "$1" != "-v_Dummy_=0" ] && L_COMP_FLAGS="$1"
    [ "$2" != "-v_Dummy_=0" ] && L_TO_C_FLAGS="$2"

    [ "$2" == "-vTokEnum" ] && L_TO_C_FLAGS="-vTokEnum=./${_G_C_TDIR}/rdpg_usr.h"
	_generate_parser_src "normal" "$L_COMP_FLAGS" "$L_TO_C_FLAGS"
	bt_assert_success

    [ "$2" == "-vTokEnum" ] && L_TO_C_FLAGS="-vTokEnum=./${_G_C_TDIR}/rdpg_usr_foo.h"
	_generate_parser_src "tag" "$L_COMP_FLAGS" "$L_TO_C_FLAGS -vTag=foo" "FOO"
	bt_assert_success

    _compile_parser
}

# <custom-test-cases>
function _test_custom_to_c_base
{
	_run_to_c "-vHelp=1"
	bt_assert_success
    _diff_stdout "help.txt"
    _diff_stderr "empty"
	_cleanup

	_run_to_c "-vVersion=1"
	bt_assert_success
    _diff_stdout "version.txt"
    _diff_stderr "empty"
	_cleanup

	_run_to_c "-vEnumParserHelp=1"
	bt_assert_success
    _diff_stdout "enum_parser_help.txt"
    _diff_stderr "empty"
	_cleanup

    local L_OLD_G_AWK="$_G_AWK"
    _G_AWK="echo foo | $L_OLD_G_AWK"
    _run_to_c
    bt_assert_failure
    _G_AWK="$L_OLD_G_AWK"

    _diff_stdout "empty"
    _diff_stderr "err.txt"
	_cleanup
}
function _test_custom_to_c_tok_enum_err
{
    _generate_parser_src "bad-enum-state" "" "-vTokEnum=./${_G_C_TDIR}/rdpg_usr.h" 2>$_G_STDERR
    bt_assert_failure
    _diff_stderr "err_enum_state.txt"

    _generate_parser_src "normal" "" "-vTokEnum=none" 2>$_G_STDERR
    bt_assert_failure
    _diff_stderr "err_enum_fail_read.txt"

    _generate_parser_src "normal" "" "-vTokEnum=./${_G_C_TDIR}/rdpg_usr_not_full.h" 2>$_G_STDERR
    bt_assert_failure
    _diff_stderr "err_enum_not_full.txt"

    _generate_parser_src "normal" "" "-vTokEnum=./${_G_C_TDIR}/rdpg_usr_no_end.h" 2>$_G_STDERR
    bt_assert_failure
    _diff_stderr "err_enum_no_end.txt"

    _cleanup
}
function _test_custom_to_c_tok_enum_ok
{
    # "-vTokEnum" is replaced with the proper value on runtime
	pretest "-v_Dummy_=0" "-vTokEnum"
	bt_eval test_use_cases
	bt_eval test_err_cases
	postest
}
function _test_custom_to_c_tok_enum
{
    bt_eval _test_custom_to_c_tok_enum_ok
    bt_eval _test_custom_to_c_tok_enum_err
}
# </custom-test-cases>
# </private>

# <public>
function on_pretest
{
	bt_eval _c_cleanup
	bt_eval _generate_parser "$@"
}
function on_postest
{
	bt_eval _c_cleanup
	bt_eval true
}

function run_parser
{
	bt_eval "${_G_C_BIN} $* 1>$G_STDOUT 2>$G_STDERR"
}

function test_backend_specific
{
    bt_eval _test_custom_to_c_tok_enum
    bt_eval _test_custom_to_c_base
}
# </public>
