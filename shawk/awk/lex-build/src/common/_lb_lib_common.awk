# <lb_common>
# Common lex-build functionality
# v1.2

# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2022-03-20

# <misc>
function join(a, b) {return (a SUBSEP b)}
function unjoin(arr_out, str) {return split(str, arr_out, SUBSEP)}
function save_to(vect,    _first, _last) {
	# Usually called from user handlers. Makes sure you don't save delimiters.
	if (!is_range_word($0)) {

		# Separate the input into the last field and everything else.
		_last = $NF
		$NF = ""

		_first = $0
		gsub("^[[:space:]]+|[[:space:]]+$", "", _first)

		# Pretend there always have been two fields.
		NF = 2
		$1 = _first
		$2 = _last

		vect_push(vect, join($1, $2))
	}
}
function out_line(str) {if (str) tabs_print_str(str); print ""}
function out_str(str) {tabs_print_str(str)}
function out_tabs() {printf("%s", tabs_get())}

function str_up_to(str, pos) {return substr(str, 1, pos)}
function str_ch_at(str, pos) {return substr(str, pos, 1)}
function str_has_ch(str, ch) {return index(str, substr(ch, 1, 1))}
# </misc>

# <lb_vect>
function lb_vect_copy(vect_dest, vect_src) {
	vect_init_arr(vect_dest, vect_src, vect_len(vect_src))
}
function lb_vect_append(vect_dest, vect_src) {
	vect_push_arr(vect_dest, vect_src, vect_len(vect_src))
}
function lb_vect_to_array(arr_dest, vect_src) {
	return arr_copy(arr_dest, vect_src, vect_len(vect_src))
}
function lb_vect_make_set(set_out, vect_in, fld,    _i, _end, _split) {
	if (!fld)
		fld = 1
	
	eos_init(set_out)
	_end = vect_len(vect_in)
	for (_i = 1; _i <= _end; ++_i) {
		unjoin(_split, vect_in[_i])
		eos_add(set_out, _split[fld])
	}
}
function lb_vect_to_map(map_out, vect_in, field_ind, field_val,
    _i, _end, _arr) {
	# Turn vect[1] = ("foo" SUBSEP "bar") into vect["foo"] = "bar", or
	# vect["bar"] = "foo". Repeat for all items of vect.

	delete map_out
	if (!field_ind) {
		field_ind = 1
		field_val = 2
	}
	
	_end = vect_len(vect_in)
	for (_i = 1; _i <= _end; ++_i) {
		unjoin(_arr, vect_in[_i])
		map_out[_arr[field_ind]] = _arr[field_val] 
	}
}
# <lb_vect>

# <ch_pref_tree>
# This is a prefix tree. Turns e.g. "this", "that" into
# tree["t"] = "h"
# tree["th"] = "ia"
# tree["thi"] = "s"
# tree["tha"] = "t"
# Used to generate the if trees for multi character tokens and for keyword
# recognition.

function ch_ptree_init(tree) {pft_init(tree)}
function _ch_ptree_mark_word(tree, str) {pft_mark(tree, str)}
function _ch_ptree_insert(tree, str,    _arr, _len) {
	_len = split(str, _arr, "")
	pft_insert(tree, pft_arr_to_pft_str(_arr, _len))
}
function ch_ptree_has(tree, str,    _arr, _len) {
	_len = split(str, _arr, "")
	return pft_has(tree, pft_arr_to_pft_str(_arr, _len))
}
function ch_ptree_is_word(tree, str) {
	return pft_is_marked(tree, str)
}
function ch_ptree_insert(tree, str) {
	if (!ch_ptree_is_word(tree, str)) {
		_ch_ptree_mark_word(tree, str)
		_ch_ptree_insert(tree, str)
	}
}
function ch_ptree_get(tree, ind,    _arr, _len, _str) {
	_len = split(ind, _arr, "")
	_str = pft_get(tree, pft_arr_to_pft_str(_arr, _len))
	gsub(PFT_SEP(), "", _str)
	return _str
}
# </ch_pref_tree>

# <lex_constants>
# The constants used to generate and recognize automatically generated character
# classes.
function CH_CLS_AUTO_GEN() {return "CH_CLS_AUTO_%d_"}
function CH_CLS_AUTO_RE() {return "CH_CLS_AUTO_[0-9]+_"}

# Special actions. They can be values in the 'actions' table and their meaning
# is determined by the writer of the lex-*.awk in accordance with its target
# language.
function NEXT_CH() {return "next_ch"}
function NEXT_LINE() {return "next_line"}

# Since a space character cannot exist literally in the input, it has to be
# represented by an escape sequence.
function CH_ESC_SPACE() {return "\\s"}

# Use to check if an actions looks like a function call.
function FCALL() {return "\\(\\)$"}
# </lex_constants>

# <base>
# This is where the actual awk loop comes from for all lex-*.awk

function is_constant(str) {
	# Checks for the usual C I_AM_C0NST4NT syntax. Constants are intended to be
	# ignored by the general generation process, e.g. they do not get inserted
	# into prefix trees, and are left for the lex-*.awk writer to handle. E.g.
	# you may want to have a token symbol for EOI (end of input), which would
	# probably be the empty string and not the character sequence E O I. So you
	# can have EOI as a symbol and pick it out form the rest with this function.
	return match(str, "^[[:upper:]_[:digit:]]+$")
}

function is_range_word(str) {
	# Used to separate the input delimiters from the actual input.	
	return (END_() == str || CHAR_TBL() == str || SYMBOLS() == str ||
	KEYWORDS() == str || PATTERNS() == str || ACTIONS() == str) 
}

function npref_constants(vect, ind, pref,    _i, _end, _arr, _str) {
# Call this to prefix all constants saved in vect. Note that 'ind' is the index
# in the sub array, as per the usual save_to(), join(), unjoin() structure.

	if (ind != 1 && ind != 2)
		return

	pref = toupper(pref)

	_end = vect_len(vect)
	for (_i = 1; _i <= _end; ++_i) {
		_str = vect[_i]

		unjoin(_arr, _str)
		if (is_constant(_arr[ind]))
			_arr[ind] = (pref _arr[ind])

		vect[_i] = join(_arr[1], _arr[2])
	}
}

# The input delimiters.
function END_()     {return "end"}
function CHAR_TBL() {return "char_tbl"}
function SYMBOLS()  {return "symbols"}
function KEYWORDS() {return "keywords"}
function PATTERNS() {return "patterns"}
function ACTIONS()  {return "actions"}

# Main awk loop. on_*() are defined by the user. From the user's standpoint
# parsing is event driven.

function quit_ok() {
	skip_end_set()
	exit_success()
}

function lib_init() {
	ch_num_init()
	set_program_name(SCRIPT_NAME())
	if (Help) {
		on_help()
		print_help_common()
		quit_ok()
	}
	if (Version) {
		on_version()
		quit_ok()
	}
}

function print_help_common() {
print "-vVersion=1 - print version info"
print "-vHelp=1    - print this screen"
}

function on_else() {err_quit(sprintf("'%s' unknown", $0))}

# Call this in on_begin(); produces an error if lex_lib.awk is not included.
function lex_lib_is_included() {}

BEGIN {lib_init(); on_begin()}
$0 == CHAR_TBL(), $0 == END_() {on_char_tbl(); next}
$0 == SYMBOLS(), $0 == END_()  {on_symbols(); next}
$0 == KEYWORDS(), $0 == END_() {on_keywords(); next}
$0 == PATTERNS(), $0 == END_() {on_patterns(); next}
$0 == ACTIONS(), $0 == END_()  {on_actions(); next}
$0 ~ /^[[:space:]]*$/ {next} # ignore empty lines
$0 ~ /^[[:space:]]*#/ {next} # ignore comments
{on_else()}

END {
	if (!should_skip_end())
		on_end()
}
# </base>
# </lb_common>
