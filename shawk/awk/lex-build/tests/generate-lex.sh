#!/bin/bash

readonly G_AWK="awk"

function main
{
	pushd $(dirname $(realpath $0))

	generate_c bsearch
	generate_c ifs
	generate_awk
	
	popd
}

function generate_c
{
	$G_AWK -f ../lex-first.awk input.lb |
	$G_AWK -f ../lex-c.awk -vKeywords="$1" |
	$G_AWK -vType="$1" '/<lex_header>/, /<\/lex_header>/ {print $0 > "./c/lex.h"}
	/<lex_source>/, /<\/lex_source>/ {print $0 > sprintf("./c/lex_%s.c", Type)}'

	$G_AWK -f ../lex-first.awk input.lb |
	$G_AWK -f ../lex-c.awk -vKeywords="$1" -vNamePrefix="foo_" |
	$G_AWK -vType="$1" \
'/<lex_header>/, /<\/lex_header>/ {print $0 > "./c/foo_lex.h"}
/<lex_source>/, /<\/lex_source>/ {print $0 > sprintf("./c/foo_lex_%s.c", Type)}'
}

function generate_awk
{
	$G_AWK -f ../lex-first.awk input.lb |
	$G_AWK -f ../lex-awk.awk > ./awk/inc_lex.awk

	$G_AWK -f ../lex-first.awk input.lb |
	$G_AWK -f ../lex-awk.awk -vNamePrefix="foo_" > ./awk/foo_inc_lex.awk
}

main "$@"
