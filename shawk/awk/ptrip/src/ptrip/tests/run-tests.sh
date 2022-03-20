#!/bin/bash

G_AWK="${G_AWK:-awk}"
readonly G_TEST_RES="./test_result.txt"

function main
{
	local L_BT_DIR="$(dirname $(realpath $0))/../../../../../bash/bashtest"
	source "$L_BT_DIR/bashtest.sh"
	
	if [ "$#" -gt 0 ]; then
		bt_set_verbose
	fi
	
	bt_enter
	bt_eval test_all
	bt_exit_success
}

# <misc>
function run
{
	local L_PTRIP="awk -f ../../../ptrip.awk "
	eval "$L_PTRIP $@"
}
function diff_ok_rm
{
	bt_diff_ok "$@" && rm "$G_TEST_RES"
}
# </misc>

# <test_versions>
function test_versions
{
	local L_RES=""
	
	L_RES="$(run -vVersion=1)"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo 'ptrip.awk 1.1')"
}
# </test_versions>


# <test_ptrip_parser>
function test_parser_errors_fatal
{
	local L_RES=""
	local L_DIR="../data/error/fatal"
	local L_FILES=(
		"$L_DIR/inc_not_inc_1.info"
		"$L_DIR/inc_not_inc_2.info"
		"$L_DIR/inc_not_inc_3.info"
		"$L_DIR/inc_not_inc_4.info"
		"$L_DIR/inc_not_str.info"
		"$L_DIR/inc_not_complete.info"
		"$L_DIR/inc_extra.info"
		"$L_DIR/not_curly_1.info"
		"$L_DIR/not_curly_2.info"
		"$L_DIR/bad_block_1.info"
		"$L_DIR/bad_block_2.info"
	)
	local L_EXP=(
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_inc_1.info', line 2, pos 7: '#include' expected, got 'error'
#includ \"should quit before parsing this\"
      ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_inc_2.info', line 2, pos 8: '#include' expected, got 'error'
	#includ \"should quit before parsing this\"
	      ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_inc_3.info', line 2, pos 10: '#include' expected, got 'error'
   #includ \"should quit before parsing this\"
         ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_inc_4.info', line 2, pos 11: '#include' expected, got 'error'
	   #includ \"should quit before parsing this\"
	         ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_str.info', line 3, pos 21: 'string' expected, got 'word'
#include not-a-string
                    ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_not_complete.info', line 4, pos 0: 'string' expected, got 'new line'
\"file-here\"
^"
"ptrip.awk: error: fatal: file '../data/error/fatal/inc_extra.info', line 3, pos 21: bad include line
#include \"file\" extra
                    ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/not_curly_1.info', line 1, pos 4: 'not-a-curly' expected, got 'error'
key{
   ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/not_curly_2.info', line 4, pos 4: 'not-a-curly' expected, got 'error'
	k3}y
	  ^"
"ptrip.awk: error: fatal: file '../data/error/fatal/bad_block_1.info', line 5, pos 1: '}' expected, got 'end of input'
}
^"
"ptrip.awk: error: fatal: file '../data/error/fatal/bad_block_2.info', line 8, pos 2: '}' expected, got '{'
 {
 ^"
	)
	
	local len="${#L_FILES[@]}"
	for ((i = 0; i < ${len}; ++i));
	do
		L_RES="$(run "${L_FILES[$i]} 2>&1 1>/dev/null")"
		bt_assert_failure
		bt_diff_ok "<(echo '$L_RES') <(echo '${L_EXP[$i]}')"
	done
}
function test_parser_errors_non_fatal
{
	local L_RES=""
	local L_DIR="../data/error/non-fatal"
	local L_FILES=(
		"$L_DIR/bad_file.info"
		"$L_DIR/recursive/a.info"
		"doesnt-exist.info"
	)
	local L_EXP=(
"ptrip.awk: error: -|../data/error/non-fatal/bad_file.info:4:;ERROR = \"file 'i-dont-exist': No such file or directory\"
-|../data/error/non-fatal/bad_file.info
-|../data/error/non-fatal/bad_file.info:-:;FILE_BEGIN = ../data/error/non-fatal/bad_file.info
-|../data/error/non-fatal/bad_file.info:1:key = {null}
-|../data/error/non-fatal/bad_file.info:2:key.key1 = foo
-|../data/error/non-fatal/bad_file.info:4:key.#include = \"i-dont-exist\"
-|../data/error/non-fatal/bad_file.info:4:;ERROR = \"file 'i-dont-exist': No such file or directory\"
-|../data/error/non-fatal/bad_file.info:5:key.key2 = val
-|../data/error/non-fatal/bad_file.info:-:;FILE_END = ../data/error/non-fatal/bad_file.info"

"ptrip.awk: error: ----|../data/error/non-fatal/recursive/d.info:2:;ERROR = \"recursive include of file '../data/error/non-fatal/recursive/d.info'\"
ptrip.awk: error: ---|../data/error/non-fatal/recursive/c.info:3:;ERROR = \"recursive include of file '../data/error/non-fatal/recursive/a.info'\"
-|../data/error/non-fatal/recursive/a.info
-|../data/error/non-fatal/recursive/a.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/a.info
-|../data/error/non-fatal/recursive/a.info:1:#include = \"../data/error/non-fatal/recursive/b.info\"
--|../data/error/non-fatal/recursive/b.info
--|../data/error/non-fatal/recursive/b.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/b.info
--|../data/error/non-fatal/recursive/b.info:1:#include = \"../data/error/non-fatal/recursive/c.info\"
---|../data/error/non-fatal/recursive/c.info
---|../data/error/non-fatal/recursive/c.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/c.info
---|../data/error/non-fatal/recursive/c.info:1:keyc = {null}
---|../data/error/non-fatal/recursive/c.info:2:#include = \"../data/error/non-fatal/recursive/d.info\"
----|../data/error/non-fatal/recursive/d.info
----|../data/error/non-fatal/recursive/d.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/d.info
----|../data/error/non-fatal/recursive/d.info:1:keyd = rec
----|../data/error/non-fatal/recursive/d.info:2:#include = \"../data/error/non-fatal/recursive/d.info\"
----|../data/error/non-fatal/recursive/d.info:2:;ERROR = \"recursive include of file '../data/error/non-fatal/recursive/d.info'\"
----|../data/error/non-fatal/recursive/d.info:-:;FILE_END = ../data/error/non-fatal/recursive/d.info
---|../data/error/non-fatal/recursive/c.info:3:#include = \"../data/error/non-fatal/recursive/a.info\"
---|../data/error/non-fatal/recursive/c.info:3:;ERROR = \"recursive include of file '../data/error/non-fatal/recursive/a.info'\"
---|../data/error/non-fatal/recursive/c.info:4:#include = \"../data/error/non-fatal/recursive/e.info\"
----|../data/error/non-fatal/recursive/e.info
----|../data/error/non-fatal/recursive/e.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/e.info
----|../data/error/non-fatal/recursive/e.info:1:endOfLine = {null}
----|../data/error/non-fatal/recursive/e.info:-:;FILE_END = ../data/error/non-fatal/recursive/e.info
---|../data/error/non-fatal/recursive/c.info:5:#include = \"../data/error/non-fatal/recursive/e.info\"
----|../data/error/non-fatal/recursive/e.info
----|../data/error/non-fatal/recursive/e.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/e.info
----|../data/error/non-fatal/recursive/e.info:1:endOfLine = {null}
----|../data/error/non-fatal/recursive/e.info:-:;FILE_END = ../data/error/non-fatal/recursive/e.info
---|../data/error/non-fatal/recursive/c.info:-:;FILE_END = ../data/error/non-fatal/recursive/c.info
--|../data/error/non-fatal/recursive/b.info:2:keyb = {null}
--|../data/error/non-fatal/recursive/b.info:-:;FILE_END = ../data/error/non-fatal/recursive/b.info
-|../data/error/non-fatal/recursive/a.info:2:keya = {null}
-|../data/error/non-fatal/recursive/a.info:4:#include = \"../data/error/non-fatal/recursive/e.info\"
--|../data/error/non-fatal/recursive/e.info
--|../data/error/non-fatal/recursive/e.info:-:;FILE_BEGIN = ../data/error/non-fatal/recursive/e.info
--|../data/error/non-fatal/recursive/e.info:1:endOfLine = {null}
--|../data/error/non-fatal/recursive/e.info:-:;FILE_END = ../data/error/non-fatal/recursive/e.info
-|../data/error/non-fatal/recursive/a.info:-:;FILE_END = ../data/error/non-fatal/recursive/a.info"
"ptrip.awk: error: file 'doesnt-exist.info': No such file or directory"
	)
	
	
	local len="${#L_FILES[@]}"
	for ((i = 0; i < ${len}; ++i));
	do
		L_RES="$(run "${L_FILES[$i]} 2>&1")"
		bt_assert_failure
		bt_diff_ok "<(echo '$L_RES') <(echo '${L_EXP[$i]}')"
	done
}
function test_parser_errors
{
	bt_eval test_parser_errors_fatal
	bt_eval test_parser_errors_non_fatal
}

function test_parser_complex
{
	local L_DIR="../data/complex"
	local L_RES=""
	local L_EXP=""
	
	L_EXP=\
'-|../data/complex/entry.info
-|../data/complex/entry.info:-:;FILE_BEGIN = ../data/complex/entry.info
-|../data/complex/entry.info:1:#include = "../data/complex/inc_leaf.info"
--|../data/complex/inc_leaf.info
--|../data/complex/inc_leaf.info:-:;FILE_BEGIN = ../data/complex/inc_leaf.info
--|../data/complex/inc_leaf.info:1:leaf_key1 = {null}
--|../data/complex/inc_leaf.info:3:leaf_key1.leaf_key2 = leaf_val
--|../data/complex/inc_leaf.info:-:;FILE_END = ../data/complex/inc_leaf.info
-|../data/complex/entry.info:2:e_key1 = val
-|../data/complex/entry.info:4:e_key1.e_key2 = {null}
-|../data/complex/entry.info:6:e_key1.e_key2.#include = "../data/complex/inc_inc.info"
--|../data/complex/inc_inc.info
--|../data/complex/inc_inc.info:-:e_key1.e_key2.;FILE_BEGIN = ../data/complex/inc_inc.info
--|../data/complex/inc_inc.info:2:e_key1.e_key2.ii_key = {null}
--|../data/complex/inc_inc.info:4:e_key1.e_key2.ii_key.ii_skey = val
--|../data/complex/inc_inc.info:5:e_key1.e_key2.ii_key.#include = "../data/complex/inc_leaf.info"
---|../data/complex/inc_leaf.info
---|../data/complex/inc_leaf.info:-:e_key1.e_key2.ii_key.;FILE_BEGIN = ../data/complex/inc_leaf.info
---|../data/complex/inc_leaf.info:1:e_key1.e_key2.ii_key.leaf_key1 = {null}
---|../data/complex/inc_leaf.info:3:e_key1.e_key2.ii_key.leaf_key1.leaf_key2 = leaf_val
---|../data/complex/inc_leaf.info:-:e_key1.e_key2.ii_key.;FILE_END = ../data/complex/inc_leaf.info
--|../data/complex/inc_inc.info:6:e_key1.e_key2.ii_key.ii_skey2 = val
--|../data/complex/inc_inc.info:8:e_key1.e_key2.ii_key.ii_skey2.#include = "../data/complex/inc_leaf.info"
---|../data/complex/inc_leaf.info
---|../data/complex/inc_leaf.info:-:e_key1.e_key2.ii_key.ii_skey2.;FILE_BEGIN = ../data/complex/inc_leaf.info
---|../data/complex/inc_leaf.info:1:e_key1.e_key2.ii_key.ii_skey2.leaf_key1 = {null}
---|../data/complex/inc_leaf.info:3:e_key1.e_key2.ii_key.ii_skey2.leaf_key1.leaf_key2 = leaf_val
---|../data/complex/inc_leaf.info:-:e_key1.e_key2.ii_key.ii_skey2.;FILE_END = ../data/complex/inc_leaf.info
--|../data/complex/inc_inc.info:-:e_key1.e_key2.;FILE_END = ../data/complex/inc_inc.info
-|../data/complex/entry.info:12:e_key1.e_key3 = {null}
-|../data/complex/entry.info:15:e_key5 = {null}
-|../data/complex/entry.info:15:e_key5.skey = val
-|../data/complex/entry.info:17:e_key4 = {null}
-|../data/complex/entry.info:18:e_key4.#include = "../data/complex/inc_leaf.info"
--|../data/complex/inc_leaf.info
--|../data/complex/inc_leaf.info:-:e_key4.;FILE_BEGIN = ../data/complex/inc_leaf.info
--|../data/complex/inc_leaf.info:1:e_key4.leaf_key1 = {null}
--|../data/complex/inc_leaf.info:3:e_key4.leaf_key1.leaf_key2 = leaf_val
--|../data/complex/inc_leaf.info:-:e_key4.;FILE_END = ../data/complex/inc_leaf.info
-|../data/complex/entry.info:23:more = val
-|../data/complex/entry.info:26:more = val
-|../data/complex/entry.info:28:more = val
-|../data/complex/entry.info:30:more = val
-|../data/complex/entry.info:34:more_val = {null}
-|../data/complex/entry.info:37:e_key_last = val_last
-|../data/complex/entry.info:-:;FILE_END = ../data/complex/entry.info'

	L_RES="$(run "$L_DIR/entry.info")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_RES="$(run "$L_DIR/entry.info" "$L_DIR/entry.info")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(printf '%s\n%s\n' '$L_EXP' '$L_EXP')"
}

function test_parser_base
{
	local L_DIR="../data/base"
	local L_RES=""
	local L_EXP=""
	
	L_RES="$(run "$L_DIR/empty")"
	bt_assert_success
	
	L_EXP=\
'-|../data/base/base_flat.info
-|../data/base/base_flat.info:-:;FILE_BEGIN = ../data/base/base_flat.info
-|../data/base/base_flat.info:2:key1 = {null}
-|../data/base/base_flat.info:3:key2 = ""
-|../data/base/base_flat.info:4:"key 3" = val_key3
-|../data/base/base_flat.info:5:key4 = {null}
-|../data/base/base_flat.info:6:key5 = {null}
-|../data/base/base_flat.info:8:#include = "../data/base/base_flat_inc.info"
--|../data/base/base_flat_inc.info
--|../data/base/base_flat_inc.info:-:;FILE_BEGIN = ../data/base/base_flat_inc.info
--|../data/base/base_flat_inc.info:1:key_incl = val_incl
--|../data/base/base_flat_inc.info:-:;FILE_END = ../data/base/base_flat_inc.info
-|../data/base/base_flat.info:9:foo = "bar baz"
-|../data/base/base_flat.info:11:zig = ""
-|../data/base/base_flat.info:12:zag = "one two three lines"
-|../data/base/base_flat.info:15:final = {null}
-|../data/base/base_flat.info:-:;FILE_END = ../data/base/base_flat.info'

	L_RES="$(run "$L_DIR/base_flat.info")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
	
	L_EXP=\
'-|../data/base/base_tree.info
-|../data/base/base_tree.info:-:;FILE_BEGIN = ../data/base/base_tree.info
-|../data/base/base_tree.info:1:key1 = {null}
-|../data/base/base_tree.info:2:key1.key2 = {null}
-|../data/base/base_tree.info:3:key1.key3 = {null}
-|../data/base/base_tree.info:5:key1.key3.key4 = "val4"
-|../data/base/base_tree.info:6:key1.key3.key4.foo = bar
-|../data/base/base_tree.info:8:key1.key3.key5 = "val 5"
-|../data/base/base_tree.info:10:key1.key3.key5.foo = ""
-|../data/base/base_tree.info:12:key1.key3.key6 = "one two"
-|../data/base/base_tree.info:14:key1.key3.key6."foo bar" = {null}
-|../data/base/base_tree.info:16:key1.key3.key7 = "one two"
-|../data/base/base_tree.info:20:key1.key3.key7."foo bar" = {null}
-|../data/base/base_tree.info:20:key1.key3.key7."foo bar".zig = zag
-|../data/base/base_tree.info:-:;FILE_END = ../data/base/base_tree.info'

	L_RES="$(run "$L_DIR/base_tree.info")"
	bt_assert_success
	bt_diff_ok "<(echo '$L_RES') <(echo '$L_EXP')"
}

function test_parser
{
	bt_eval test_parser_errors
	bt_eval test_parser_complex
	bt_eval test_parser_base
}
# </test_ptrip_parser>

# <test_ptrip_lexer>
function test_lexer
{
	local L_DIR="../lexer"
	local L_RUN_LEX=\
"$G_AWK -f $L_DIR/ptrip_lexer.awk -f $L_DIR/ptrip_lexer_usr.awk -f $L_DIR/ptrip_lexer_state_hack.awk -f $L_DIR/ptrip-lex-test-main.awk"
	local L_DATA=\
"../data/tree_simple.info ../data/tree_more.info ../data/tree_tok_with_err.txt"

	local L_RESULT=\
	
	bt_eval "$L_RUN_LEX $L_DATA > $G_TEST_RES 2>&1"
	diff_ok_rm "$G_TEST_RES ./accept/test_accept_lexer.txt"
}
# </test_ptrip_lexer>

function test_all
{
	bt_eval test_versions
	bt_eval test_parser
	bt_eval test_lexer
}

main "$@"
