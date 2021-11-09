#!/bin/bash

set -u

readonly G_SCRIPT_NAME="$(basename $0)"
readonly G_SCRPIT_DIR="$(dirname $(realpath $0))"
readonly G_SCRIPT_VER="1.0"
function print_version { echo "$G_SCRIPT_NAME $G_SCRIPT_VER"; }

function print_fd2    { echo "$@" >&2; }
function error_print  { print_fd2 "$0: error: $@"; }
function error_exit   { error_print "$@"; exit_failure; }
function exit_success { exit 0; }
function exit_failure { exit 1; }

readonly G_OPT_FOO_S="-f"
readonly G_OPT_FOO_L="--foo"
readonly G_MATCH_FOO="@($G_OPT_FOO_S|$G_OPT_FOO_L)"
G_FOO=""

readonly G_OPT_BAR_S="-b"
readonly G_OPT_BAR_L="--bar"
readonly G_MATCH_BAR="@($G_OPT_BAR_S|$G_OPT_BAR_L)"
G_BAR=""

readonly G_OPT_BAZ_S="-x"
readonly G_MATCH_BAZ="@($G_OPT_BAZ_S)"
G_BAZ=""

readonly G_OPT_ZIG_L="--zig"
readonly G_MATCH_ZIG="@($G_OPT_ZIG_L)"
G_ZIG=""

G_CMD_LINE_OTHER=""

function set_foo { G_FOO="$2"; }
function set_bar { G_BAR="yes"; }
function set_baz { G_BAZ="yes"; }
function set_zig { G_ZIG="$2"; }

function get_args
{
	shopt -s extglob
	local L_UNBOUND_ARG="-*"

	while [ "$#" -gt 0 ]; do
		local L_OPT_ARG=""
		local L_OPT_NO_ARG=""

		case "$1" in
			$G_MATCH_FOO)
				L_OPT_ARG="set_foo"
			;;
			$G_MATCH_BAR)
				L_OPT_NO_ARG="set_bar"
			;;
			$G_MATCH_BAZ)
				L_OPT_NO_ARG="set_baz"
			;;
			$G_MATCH_ZIG)
				L_OPT_ARG="set_zig"
			;;
			$L_UNBOUND_ARG)
				error_exit "'$1' unknown option"
			;;
			*)
				G_CMD_LINE_OTHER="${G_CMD_LINE_OTHER}'$1' "
			;;
		esac

		if [ ! -z "$L_OPT_ARG" ]; then
			if [ "$#" -lt 2 ] || [ "${2:0:1}" == "-" ]; then
				error_exit "'$1' missing argument"
			fi
			eval "$L_OPT_ARG '$1' '$2'"
			shift 2
		elif [ ! -z "$L_OPT_NO_ARG" ]; then
			eval "$L_OPT_NO_ARG '$1'"
			shift
		else
			shift
		fi
	done
}

function print_help
{
echo "$G_OPT_FOO_S, $G_OPT_FOO_L"
echo ""
echo "$G_OPT_BAR_S, $G_OPT_BAR_L"
echo ""
echo "$G_OPT_BAZ_S"
echo ""
echo "$G_OPT_ZIG_L"
echo ""
}

function print_args
{
	echo "@$G_FOO $G_BAR $G_BAZ $G_ZIG@$G_CMD_LINE_OTHER@"
}

function main
{
	get_args "$@"
	
	if [ "$#" -eq 0 ]; then
		print_version
		print_help
	fi
	
	print_args
}

main "$@"
