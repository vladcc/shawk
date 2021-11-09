#!/bin/bash

G_AWK="${G_AWK:-awk}"

readonly G_TEST_GEN="./test_generate.rdpg"
readonly G_RDPG="../rdpg.awk"
readonly G_TEST_RES="./test_results.txt"
readonly G_RDPG_OPT="../rdpg-opt.awk"
readonly G_EXAMPLE="../examples/infix_calc_grammar.rdpg"

function run
{
	for fun in $@; do
		bt_eval $fun
	done
}

function test_all
{
	run "test_version_checks
	test_misc
	test_bug_fixes
	test_rdpg
	test_rdpg_opt"
	
	bt_eval test_end_to_end	"$@"
}

# <test_version_checks>
function test_version_checks
{
	local L_TO_C="../rdpg-to-c.awk"
	local L_TO_AWK="../rdpg-to-awk.awk"
	
	bt_diff_ok "<($G_AWK -f $G_RDPG -vVersion=1)" "<(echo 'rdpg.awk 1.31')"
	bt_diff_ok "<($G_AWK -f $G_RDPG_OPT -vVersion=1)" "<(echo 'rdpg-opt.awk 1.2')"
	bt_diff_ok "<($G_AWK -f $L_TO_C -vVersion=1)" "<(echo 'rdpg-to-c.awk 1.1')"
	bt_diff_ok "<($G_AWK -f $L_TO_AWK -vVersion=1)" "<(echo 'rdpg-to-awk.awk 1.1')"
}
# </test_version_checks>

# <test_misc>
function test_misc
{
	run "test_rdpg_awk_tok_call_prefix"
}

function test_rdpg_awk_tok_call_prefix
{
	run_rdpg \
	"$G_TEST_GEN"\
	"| $G_AWK -f ../rdpg-to-awk.awk"\
	"> $G_TEST_RES"
	bt_assert_success
	
	bt_diff_ok "<(echo 0)"\
	"<(cat $G_TEST_RES | grep -Eo '\<foo_tok_[[:alpha:]_]+' | wc -l)"

	bt_diff_ok \
	"<(printf '%s\n%s\n%s\n' 'tok_err_exp' 'tok_match' 'tok_next')"\
	"<(cat $G_TEST_RES | grep -Eo '\<tok_[[:alpha:]_]+' | sort -u)"

	bt_diff_ok "<(echo 0)" "<(grep -c '\<foo_tok_err_exp(_arr, 2)' $G_TEST_RES)"
	bt_diff_ok "<(echo 1)" "<(grep -c '\<tok_err_exp(_arr, 2)' $G_TEST_RES)"
	
	run_rdpg \
	"$G_TEST_GEN"\
	"| $G_AWK -f ../rdpg-to-awk.awk -vTokCallPrefix='foo_'"\
	"> $G_TEST_RES"
	bt_assert_success
	
	bt_diff_ok "<(echo 0)"\
	"<(cat $G_TEST_RES | grep -Eo '\<tok_[[:alpha:]_]+' | wc -l)"

	bt_diff_ok \
	"<(printf '%s\n%s\n%s\n' 'foo_tok_err_exp' 'foo_tok_match' 'foo_tok_next')"\
	"<(cat $G_TEST_RES | grep -Eo '\<foo_tok_[[:alpha:]_]+' | sort -u)"

	bt_diff_ok "<(echo 1)" "<(grep -c '\<foo_tok_err_exp(_arr, 2)' $G_TEST_RES)"
	bt_diff_ok "<(echo 0)" "<(grep -c '\<tok_err_exp(_arr, 2)' $G_TEST_RES)"
}
# </test_misc>

# <test_bug_fixes>
function test_bug_fixes
{
	run "spaces_after_defn
	opt_olvl_3_inf_loop_fix
	pft_add_bug_fix"
}
function opt_olvl_3_inf_loop_fix
{
	local L_RUN=\
"$G_AWK -f $G_RDPG ./test_rdpg/test_rdpg_opt_olvl3_inf_loop.rdpg"\
" | $G_AWK -f $G_RDPG_OPT -vOlvl=3"

	bt_diff_ok "<($L_RUN)" "./test_rdpg/accept_rdpg_opt_olvl3_inf_loop.txt"
}
function pft_add_bug_fix
{
	local L_RUN="$G_AWK -f $G_RDPG"
	
	bt_diff_ok "<($L_RUN ./test_rdpg/test_pft_add_bug_fix.rdpg)" \
		"./test_rdpg/accept_pft_add_bug_fix.txt"
}

function spaces_after_defn
{
	local L_INPUT="$(printf "rule foo\ndefn bar\nend\n")"
	local L_RUN="$G_AWK -f $G_RDPG"
	
	local L_EXPECT=\
'func foo
block_open foo_1
	call tok_next
	if call bar
	block_open foo_2
		return true
	block_close foo_2
	else
	block_open foo_2
		return false
	block_close foo_2
block_close foo_1
func_end'

	bt_diff_ok "<($L_RUN <(echo '$L_INPUT') | fgrep -v 'comment') <(echo '$L_EXPECT')"
}
# </test_bug_fixes>

# <test_end_to_end>
function test_end_to_end
{
	bt_eval "G_AWK=${G_AWK} bash ../examples/run.sh $@"
	bt_assert_success
}
# </test_end_to_end>

# <test_rdpg_opt>
function run_rdpg_opt
{
	local L_FILE="$1"
	shift
	
	local L_AUX="$@"
	local L_RUN="$G_AWK -f $G_RDPG_OPT $L_AUX"
	run_rdpg "$L_FILE" | bt_eval "$L_RUN"
}

function test_rdpg_opt
{
	run "test_rdpg_opt_olvl_0
	test_rdpg_opt_olvl_1
	test_rdpg_opt_olvl_2
	test_rdpg_opt_olvl_3
	test_rdpg_opt_olvl_4
	test_rdpg_opt_olvl_5"
}

function test_rdpg_opt_olvl_5
{
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=5 -vInlineLength=1" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_5.txt"
	
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=5" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_5_default_inline_len.txt"
	
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=5 -vInlineLength=29" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_5_inline_len_29.txt"
}

function test_rdpg_opt_olvl_4
{
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=4" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_4.txt"
}

function test_rdpg_opt_olvl_3
{
	# Remove unreachable code is probably not necessary because of redundant
	# else removal, so no positive test, unfortunately.
	# This test confirms it doesn't break olvl 2.
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=3" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_3.txt"
}

function test_rdpg_opt_olvl_2
{
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=2" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_2.txt"
}

function test_rdpg_opt_olvl_1
{
	run_rdpg_opt "$G_TEST_GEN" "-vOlvl=1" " > $G_TEST_RES"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_1.txt"
}

function test_rdpg_opt_olvl_0
{
	run_rdpg_opt "$G_TEST_GEN" " > $G_TEST_RES" "2>&1"
	bt_assert_success
	diff_result "./test_rdpg_opt/accept_olvl_0.txt"
}
# </test_rdpg_opt>

# <test_rdpg>
function run_rdpg
{
	local L_AUX="$@"
	local L_RUN="$G_AWK -f $G_RDPG $L_AUX"
	eval "$L_RUN"
}

function test_rdpg
{
	run "test_rdpg_bad_input
	test_rdpg_example
	test_rdpg_generate"
}

function test_rdpg_bad_input
{
	run "test_rdpg_bad_input_misc
	test_rdpg_strict_undefn_rule
	test_rdpg_left_recursion_direct
	test_rdpg_left_recursion_indirect"
}

function test_rdpg_bad_input_misc
{
	> "$G_TEST_RES"
	
	# trivial fsm error
	run_rdpg '<(echo foo) 2>>"$G_TEST_RES"'
	bt_assert_failure
	
	local L_INPUT=\
'rule zig
defn zag
end

rule foo
defn bar
defn bar foo
end'
	
	# CFG obvious ambiguity
	run_rdpg "<(echo \"$L_INPUT\") 2>>$G_TEST_RES"
	bt_assert_failure
	
	# no data after rule
	run_rdpg "<(echo rule) 2>>$G_TEST_RES"
	bt_assert_failure
	
	
	# bad rule syntax
	run_rdpg "<(echo rule 00f) 2>>$G_TEST_RES"
	bt_assert_failure
	
	L_INPUT=\
'rule zig
defn 00f2
end'

	# bad defn syntax
	run_rdpg "<(echo \"$L_INPUT\") 2>>$G_TEST_RES"
	bt_assert_failure
	
	L_INPUT=\
'rule zig
defn zag
end

rule zig
defn zag
end'

	# redefined rule
	run_rdpg "<(echo \"$L_INPUT\") 2>>$G_TEST_RES"
	bt_assert_failure
	
	local L_RES="$(cat $G_TEST_RES | sed -E "s/file '[^']+'/file 'myfile'/")"
	
	local L_EXPT="rdpg.awk: error: file 'myfile' line 1: 'rule' expected, but got 'foo' instead
rdpg.awk: error: file 'myfile', line 5, rule 'foo': ambiguity detected
'foo -> bar -> foo'
'foo -> bar'
rdpg.awk: error: file 'myfile' line 1: no data after 'rule'
rdpg.awk: error: file 'myfile' line 1: bad rule syntax '00f'; has to match '^[_[:lower:]][[:lower:][:digit:]_]*\??$'
rdpg.awk: error: file 'myfile' line 2: bad syntax: '00f2' not a terminal or a non-terminal
rdpg.awk: error: file 'myfile' line 5: rule 'zig' redefined"
	
	bt_diff_ok "<(echo \"$L_RES\") <(echo \"$L_EXPT\")"
	rm "$G_TEST_RES"
}

function test_rdpg_left_recursion_indirect
{
	local L_FILE="./test_rdpg/test_left_recursion_indirect.rdpg"
	local L_OUT=""
	
	L_OUT="$(run_rdpg "$L_FILE" 2>&1)"
	bt_assert_failure
	
	local L_MSG="rdpg.awk: error: file './test_rdpg/test_left_recursion_indirect.rdpg', line 5, rule 'foo': left recursion: foo -> bar -> baz -> foo
rdpg.awk: error: file './test_rdpg/test_left_recursion_indirect.rdpg', line 9, rule 'bar': left recursion: bar -> baz -> foo -> bar
rdpg.awk: error: file './test_rdpg/test_left_recursion_indirect.rdpg', line 13, rule 'baz': left recursion: baz -> foo -> bar -> baz"
	
	bt_diff_ok "<(echo \"$L_OUT\")" "<(echo \"$L_MSG\")"
}

function test_rdpg_left_recursion_direct
{
	local L_FILE="./test_rdpg/test_left_recursion_direct.rdpg"
	local L_OUT=""
	
	L_OUT="$(run_rdpg "$L_FILE" 2>&1)"
	bt_assert_failure
	
	local L_MSG="rdpg.awk: error: file './test_rdpg/test_left_recursion_direct.rdpg', line 1, rule 'foo': left recursion: foo -> foo"
	
	bt_diff_ok "<(echo \"$L_OUT\")" "<(echo \"$L_MSG\")"
}

function test_rdpg_strict_undefn_rule
{
	local L_FILE="./test_rdpg/test_strict_undefn_rule.rdpg"
	local L_OUT=""
	
	L_OUT="$(run_rdpg "-vStrict=1 $L_FILE" 2>&1)"
	bt_assert_failure
	
	local L_MSG="rdpg.awk: error: file './test_rdpg/test_strict_undefn_rule.rdpg', line 5, rule 'bar': call to an undefined rule 'baz'"
	
	bt_diff_ok "<(echo \"$L_OUT\")" "<(echo \"$L_MSG\")"
}

function test_rdpg_example
{
	bt_diff_ok <(run_rdpg "-vExample=1") "$G_EXAMPLE"
}

function test_rdpg_generate
{
	local L_ACCEPT_GEN="./test_rdpg/accept_generate.txt"
	
	run_rdpg "$G_TEST_GEN > $G_TEST_RES"
	bt_assert_success
	diff_result "$L_ACCEPT_GEN"
}
# </test_rdpg>

function diff_result
{
	bt_diff_ok "$G_TEST_RES" "$@" && rm "$G_TEST_RES"
}

function main
{
	source "$(dirname $(realpath $0))/../../../bash/bashtest/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	
	bt_eval "test_all \"$@\""
	
	bt_exit_success
}

main "$@"
