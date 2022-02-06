#!/bin/bash

G_AWK="${G_AWK:-awk}"

function main
{
	pushd "$(dirname $(realpath $0))"

	echo "$0 generating with $G_AWK"
	
	if [ "$1" = "awk" ]; then
		generate_awk
    else
		generate_c "$1"
	fi
	
	popd
}

function generate_awk
{
	$G_AWK -f../lex-first.awk lex.lb |
	$G_AWK -f../lex-awk.awk > ./awk/inc_lex.awk
}

function generate_c
{
	$G_AWK -f../lex-first.awk lex.lb |
	$G_AWK -f../lex-c.awk -vKeywords="$1" |
	$G_AWK -vType="$1" '/<lex_header>/, /<\/lex_header>/ {print $0 > "./lex.h"}
	/<lex_source>/, /<\/lex_source>/ {print $0 > sprintf("./lex_%s.c", Type)}'
}

main "$@"
