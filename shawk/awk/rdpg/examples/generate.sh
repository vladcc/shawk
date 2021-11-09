#!/bin/bash

G_AWK="${G_AWK:-awk}"

readonly G_SRC="infix_calc_grammar.rdpg"
G_VERBOSE=""

function main
{
	if [ "$#" -gt 0 ]; then
		G_VERBOSE="yes"
	fi
	
	pushd "$(dirname $(realpath $0))" > /dev/null
	
	echo_eval generate_all
	
	popd > /dev/null
}

function generate_all
{
	echo_eval generate_c
	echo_eval generate_awk
}

function rdpg { $G_AWK -f ../rdpg.awk $G_SRC; }
function rdpg_opt { $G_AWK -f ../rdpg-opt.awk "-vOlvl=$1"; }

function rdpg_to_c { $G_AWK -f ../rdpg-to-c.awk; }
function add_c_src
{
awk 'FNR == 1 {
	print "#include \"lex.c\""
	print "typedef struct usr_state usr_state;"
	print "typedef struct prs_state prs_state;"
}

{print $0}

$2 ~ /<\/declarations>/ {
	print ""; print "#include \"main.c\""
}'
}

function generate_c
{
	local L_FBASE="./c/parse_olvl"
	for i in {0..5}; do
		echo_eval \
		"rdpg | rdpg_opt $i | rdpg_to_c | add_c_src > ${L_FBASE}_${i}.c"
	done
}

function rdpg_to_awk { $G_AWK -f ../rdpg-to-awk.awk; }
function generate_awk
{
	local L_FBASE="./awk/parse_olvl"
	for i in {0..5}; do
		echo_eval \
		"rdpg | rdpg_opt $i | rdpg_to_awk > ${L_FBASE}_${i}.awk"
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
