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
#@ <awklib_ch_num>
#@ Library: ch_num
#@ Description: Translates character to numbers and numbers to characters in the
#@ range 0 to 127 inclusive.
#@ Version: 1.1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-11
#@

#
#@ Description: Initializes the char/num tables.
#@ Returns: Nothing.
#
function ch_num_init(    _i, _ch) {

	for (_i = 0; _i <= 127; ++_i) {

		_ch = sprintf("%c", _i)

		if (0 == _i) {_ch = "\\0"}           # 0x00
		else if (7 == _i) { _ch = "\\a"}     # 0x07
		else if (8 == _i) { _ch = "\\b"}     # 0x08
		else if (9 == _i) { _ch = "\\t"}     # 0x09
		else if (10 == _i) { _ch = "\\n"}    # 0x0A
		else if (11 == _i) { _ch = "\\v"}    # 0x0B
		else if (12 == _i) { _ch = "\\f"}    # 0x0C
		else if (13 == _i) { _ch = "\\r"}    # 0x0D
		else if (27 == _i) { _ch = "\\e"}    # 0x1B

		_AWKLIB_ch_num__ch_to_num[_ch] = _i
		_AWKLIB_ch_num__num_to_ch[_i] = _ch
	}
}

#
#@ Description: Maps the character 'ch' to a number.
#@ Returns: The number representation of 'ch' if 'ch' is in range, -1 if not.
#
function ch_to_num(ch) {
	return (ch in _AWKLIB_ch_num__ch_to_num) ? \
		(_AWKLIB_ch_num__ch_to_num[ch]+0) : -1
}

#
#@ Description: Maps the number 'num' to a character.
#@ Returns: The character representation of 'num' if num is in range, "" if not.
#
function num_to_ch(num) {
	return (num in _AWKLIB_ch_num__num_to_ch) ? \
		(_AWKLIB_ch_num__num_to_ch[num] "") : ""
}
#@ </awklib_ch_num>
#@ <awklib_array>
#@ Library: arr
#@ Description: Array functionality.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function arr_init(arr) {

	arr[""]
	delete arr
}

#
#@ Description: Clears 'arr_dest', puts all keys of 'map' in 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_keys(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = _n
	return _i
}

#
#@ Description: Clears 'arr_dest', puts all values of 'map' in
#@ 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_vals(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = map[_n]
	return _i
}

#
#@ Description: Clears 'arr_dest' and copies the range defined by
#@ 'src_begin' and 'src_end' from 'arr_src' to 'arr_dest'. The range is
#@ inclusive. If 'src_begin' is larger than 'src_end', nothing is
#@ copied.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_range(arr_dest, arr_src, src_begin, src_end,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = src_begin; _i <= src_end; ++_i)
		arr_dest[++_n] = arr_src[_i]
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies 'arr_src' into 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_copy(arr_dest, arr_src, src_len) {

	return arr_range(arr_dest, arr_src, 1, src_len)
}

#
#@ Description: Appends 'arr_src' to the end of 'arr_dest'.
#@ Returns: The length of 'arr_dest' after appending.
#@ Complexity: O(n)
#
function arr_append(arr_dest, dest_len, arr_src, src_len,    _i) {

	for (_i = 1; _i <= src_len; ++_i)
		arr_dest[++dest_len] = arr_src[_i]
	return dest_len
}

#
#@ Description: Clears 'arr_dest', places all elements from 'arr_src'
#@ which are at indexes contained in 'arr_ind' in 'arr_dest'. E.g. given
#@ 'arr_ind[1] = 5; arr_ind[2] = 6', 'arr_dest' will get
#@ 'arr_dest[1] = arr_src[5]; arr_dest[2] = arr_src[6]'
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_gather(arr_dest, arr_src, arr_ind, ind_len,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= ind_len; ++_i)
		arr_dest[++_n] = arr_src[arr_ind[_i]]
	return _n
}

#
#@ Description: Finds the index of the first match for 'regex' in 'arr'.
#@ Returns: The index of the first match, 0 if not match is found.
#@ Complexity: O(n)
#
function arr_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all matches
#@ for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match_ind_all(arr_dest, arr_src, src_len, regex,    _i,
_n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which match
#@ 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Finds the index of the first non-match for 'regex' in
#@ 'arr'.
#@ Returns: The index of the first non-match, 0 if all match.
#@ Complexity: O(n)
#
function arr_dont_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (!match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all
#@ non-matches for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match_ind_all(arr_dest, arr_src, src_len, regex,
    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which do not
#@ match 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Calls 'sub()' for every element of 'arr' like
#@ 'sub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_sub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += sub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Calls gsub() for every element of 'arr' like
#@ 'gsub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_gsub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += gsub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Checks if 'arr_a' and 'arr_b' have the same elements.
#@ Returns: 1 if the arrays are equal, 0 otherwise.
#@ Complexity: O(n)
#
function arr_is_eq(arr_a, len_a, arr_b, len_b,    _i) {

	if (len_a != len_b)
		return 0
	for (_i = 1; _i <= len_a; ++_i) {
		if (arr_a[_i] != arr_b[_i])
			return 0
	}
	return 1
}

#
#@ Description: Finds 'val' in 'arr'.
#@ Returns: The index of 'val' if it's found, 0 otherwise.
#@ Complexity: O(n)
#
function arr_find(arr, len, val,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (arr[_i] == val)
			return _i
	}
	return 0
}

#
#@ Description: Concatenates all elements of 'arr' into a single string.
#@ The elements are separated by 'sep'. It 'sep' is not given, " " is
#@ used. 'sep' does not appear after the last element.
#@ Returns: The string representation of 'arr'.
#@ Complexity: O(n)
#
function arr_to_str(arr, len, sep,    _i, _str) {
	
	if (len < 1)
		return ""
	
	if (!sep)
		sep = " "
		
	_str = arr[1]
	for (_i = 2; _i <= len; ++_i)
		_str = (_str sep arr[_i])
	
	return _str
}

#
#@ Description: Prints 'arr' to stdout.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_print(arr, len, sep) {

	print arr_to_str(arr, len, sep)
}
#@ </awklib_array>
#@ <awklib_vect>
#@ Library: vect
#@ Description: Vector functionality. A vector is as array which is
#@ aware of its own size.
#@ Dependencies: awklib_array.awk
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'vect', initializes it with length 0.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_init(vect) {

	vect[""]
	delete vect
	vect[_VECT_LEN()] = 0
}

#
#@ Description: Initializes 'vect' to a copy of 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_init_arr(vect, arr, len,    _i) {
	
	vect_init(vect)
	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Appends 'val' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_push(vect, val) {

	vect[++vect[_VECT_LEN()]] = val
}

#
#@ Description: Appends 'arr' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_push_arr(vect, arr, len,    _i) {

	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Retrieves the last value from 'vect'.
#@ Returns: The last element.
#@ Complexity: O(1)
#
function vect_peek(vect) {

	return vect[vect[_VECT_LEN()]]
}

#
#@ Description: Removes the last element of 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_pop(vect) {

	vect[--vect[_VECT_LEN()]]
}

#
#@ Description: Provides the length.
#@ Returns: The length of 'vect'.
#@ Complexity: O(1)
#
function vect_len(vect) {
	
	return vect[_VECT_LEN()]
}

#
#@ Description: Indicates if 'vect' is empty or not.
#@ Returns: 1 if 'vect' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function vect_is_empty(vect) {

	return (!vect[_VECT_LEN()])
}

#
#@ Description: Removes the element in 'vect' at index 'ind' by moving
#@ all further elements one to the left.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_ind(vect, ind,    _i, _len) {
	
	_len = vect[_VECT_LEN()]
	for (_i = ind; _i < _len; ++_i)
		vect[_i] = vect[_i+1]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes 'val' from 'vect' by  if (arr_find())
#@ vect_del_ind().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_val(vect, val,    _ind) {
	
	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_del_ind(vect, _ind)
}

#
#@ Description: Removes the element at 'ind' from 'vect' by replacing it
#@ with the last element.
#@ Returns: Nothing
#@ Complexity: O(1)
#
function vect_swap_pop_ind(vect, ind) {
	
	vect[ind] = vect[vect[_VECT_LEN()]]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes the first instance of 'val' from 'vect' by
#@ if (arr_find()) vect_swap_pop_ind().
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_swap_pop_val(vect, val, _ind) {

	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_swap_pop_ind(vect, _ind)
}

function _VECT_LEN() {return "len"}
#@ </awklib_vect>
#@ <awklib_eos>
#@ Library: eos
#@ Description: An entry order set. Implemented in terms of a vector.
#@ The elements appear in the order they were entered.
#@ Dependencies: awklib_vect.awk
#@ Version: 1.0.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-10
#@

#
#@ Description: Clears 'eos'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function eos_init(eos) {

	vect_init(eos)
}

#
#@ Description: 'eos' is initialized to a set created from 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_init_arr(eos, arr, len,    _i) {

	vect_init(eos)
	for (_i = 1; _i <= len; ++_i)
		eos_add(eos, arr[_i])
}

#
#@ Description: Adds 'val' to 'eos' only if 'val' is not already there.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_add(eos, val) {

	if (!arr_find(eos, vect_len(eos), val))
		vect_push(eos, val)
}

#
#@ Description: If found, removes 'val' from 'eos'. Keeps the relative
#@ order.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_del(eos, val) {

	vect_del_val(eos, val)
}

#
#@ Description: Indicates if 'val' exists in 'eos'.
#@ Returns: 0 if 'val' is not found, the index of 'val' in 'eos'
#@ otherwise.
#@ Complexity: O(n)
#
function eos_has(eos, val) {

	return arr_find(eos, vect_len(eos), val)
}

#
#@ Description: Indicates the size of 'eos'.
#@ Returns: The number of elements.
#@ Complexity: O(1)
#
function eos_size(eos) {

	return vect_len(eos)
}

#
#@ Description: Indicates if 'eos' is empty.
#@ Returns: 1 if 'eos' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function eos_is_empty(eos) {

	return vect_is_empty(eos)
}

#
#@ Description: 'eos_dest' gets all elements from both 'eos_a' and
#@ 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_union(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init_arr(eos_dest, eos_a, vect_len(eos_a))

	_len = vect_len(eos_b)
	for (_i = 1; _i <= _len; ++_i)
		eos_add(eos_dest, eos_b[_i])
}

#
#@ Description: 'eos_dest' gets all elements from 'eos_a' which are also
#@ in 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_intersect(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init(eos_dest)

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (eos_has(eos_b, eos_a[_i]))
			vect_push(eos_dest, eos_a[_i])
	}
}

#
#@ Description: 'eos_dest' gets all elements from 'eos_a' which are not
#@ in 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_subtract(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init(eos_dest)

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (!eos_has(eos_b, eos_a[_i]))
			vect_push(eos_dest, eos_a[_i])
	}
}

#
#@ Description: Indicates if 'eos_a' and 'eos_b' have no elements in common.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function eos_are_disjoint(eos_a, eos_b,    _eos_tmp) {

	_len = vect_len(eos_b)
	for (_i = 1; _i <= _len; ++_i) {
		if (eos_has(eos_a, eos_b[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Indicates if 'eos_a' is a subset of 'eos_b'.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function eos_is_subset(eos_a, eos_b,    _i, _len) {

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (!eos_has(eos_b, eos_a[_i]))
			return 0
	}
	return 1
}
#@ </awklib_eos>
#@ <awklib_tabs>
#@ Library: tabs
#@ Description: String indentation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Adds a tab to the indentation string.
#@ Returns: Nothing.
#
function tabs_inc() {

	++_AWKLIB_tabs__tabs_num
	_AWKLIB_tabs__tabs_str = (_AWKLIB_tabs__tabs_str "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (_AWKLIB_tabs__tabs_num) {
		--_AWKLIB_tabs__tabs_num
		_AWKLIB_tabs__tabs_str = substr(_AWKLIB_tabs__tabs_str, 1,
			_AWKLIB_tabs__tabs_num)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return _AWKLIB_tabs__tabs_num
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (_AWKLIB_tabs__tabs_str "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (_AWKLIB_tabs__tabs_str str)
}

#
#@ Description: Prints the indented 'str' to stdout without a new line
#@ at the end.
#@ Returns: Nothing.
#
function tabs_print_str(str) {

	printf("%s", tabs_indent(str))
}

#
#@ Description: Prints the indented 'str' to stdout with a new line at
#@ the end.
#@ Returns: Nothing.
#
function tabs_print(str) {

	print tabs_indent(str)
}
#@ </awklib_tabs>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	_AWKLIB_prog__program_name = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return _AWKLIB_prog__program_name
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	_AWKLIB_prog__skip_end_flag = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	_AWKLIB_prog__skip_end_flag = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (_AWKLIB_prog__skip_end_flag+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	_AWKLIB_prog__error_flag = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	_AWKLIB_prog__error_flag = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (_AWKLIB_prog__error_flag+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {

	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
#@ <awklib_prefix_tree>
#@ Library: pft
#@ Description: A prefix tree implementation. E.g. conceptually, if you
#@ insert "this" and "that", you'd get:
#@ pft["t"] = "h"
#@ pft["th"] = "ia"
#@ pft["thi"] = "s"
#@ pft["this"] = ""
#@ pft["tha"] = "t"
#@ pft["that"] = ""
#@ However, all units must be separated by PFT_SEP(), so in this case
#@ "this" should be ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s").
#@ Similar for "that". PFT_SEP() is a non-printable character. To make
#@ any key or value from a pft printable, use pft_pretty().
#@ Version: 1.3
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2022-01-18
#@

# "\034" is inlined as a constant; make sure it's in sync with PFT_SEP()
function _PFT_LAST_NODE() {

	return "\034[^\034]+$"
}

# <public>
#
#@ Description: The prefix tree path delimiter.
#@ Returns: Some non-printable character.
#
function PFT_SEP() {

	return "\034"
}

#
#@ Description: Clears 'pft'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function pft_init(pft) {

	pft[""]
	delete pft
}

#
#@ Description: Inserts 'path' in 'pft'. 'path' has to be a PFT_SEP() delimited
#@ string.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_insert(pft, path,    _val) {
# inserts "a.b.c", "a.x.y" backwards, so you get
# pft["a.b.c"] = ""
# pft["a.b"] = "c"
# pft["a"] = "b"
# pft["a.x.y"] = ""
# pft["a.x"] = "y"
# pft["a"] = "b.x"

	if (!path)
		return

	if (!_pft_add(pft, path, _val))
		return

	if (!match(path, _PFT_LAST_NODE()))
		return

	_val = substr(path, RSTART+1)
	path = substr(path, 1, RSTART-1)

	pft_insert(pft, path, _val)
}

#
#@ Description: If 'path' exists in 'pft', makes 'path' and all paths stemming
#@ from 'path' unreachable. 'path' has to be a PFT_SEP() delimited string.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_rm(pft, path,    _last, _start_last, _no_tail, _no_tail_val) {

	if (pft_has(pft, path)) {

		delete pft[path]

		if (match(path, _PFT_LAST_NODE())) {

			_last = substr(path, RSTART+1)
			_no_tail = substr(path, 1, RSTART-1)

			_no_tail_val = (PFT_SEP() pft[_no_tail] PFT_SEP())

			_start_last = index(_no_tail_val, (PFT_SEP() _last PFT_SEP()))

			_no_tail_val = ( \
				substr(_no_tail_val, 1, _start_last-1) \
				PFT_SEP() \
				substr(_no_tail_val, _start_last + length(_last) + 2) \
			)
			gsub(("^" PFT_SEP() "|" PFT_SEP() "$"), "", _no_tail_val)

			pft[_no_tail] = _no_tail_val
		}
	}
}

#
#@ Description: Marks 'path' in 'pft', so pft_is_marked() will return
#@ 1 when asked about 'path'. The purpose of this is so also
#@ intermediate paths, and not only leaf nodes, can be considered during
#@ traversal. E.g. if you insert "this", "than", and "thank" in 'pft'
#@ and want to get these words out again, when you traverse only "this"
#@ and "thank" will be leaf nodes in the pft. Unless "than" is somehow
#@ marked, you will have no way to know "than" is actually a word, and
#@ not only an intermediate path to "thank", like "tha" would be.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function pft_mark(pft, path) {

	pft[(_PFT_MARK_SEP() path)]
}

#
#@ Description: Indicates if 'path' is marked in 'pft'.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(1)
#
function pft_is_marked(pft, path) {

	return ((_PFT_MARK_SEP() path) in pft)
}

#
#@ Description: Unmarks 'path' from 'pft' if it was previously marked.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function pft_unmark(pft, path) {

	if (pft_is_marked(pft, path))
		delete pft[(_PFT_MARK_SEP() path)]
}

#
#@ Description: Retrieves 'key' from 'pft'.
#@ Returns: pft[key] if 'key' exists in 'pft', the empty string
#@ otherwise. Use only if pft_has() has returned 1.
#@ Complexity: O(1)
#
function pft_get(pft, key) {

	return pft_has(pft, key) ? pft[key] : ""
}

#
#@ Description: Indicates whether 'key' exists in 'pft'.
#@ Returns: 1 if 'key' is found in 'pft', 0 otherwise.
#@ Complexity: O(1)
#
function pft_has(pft, key) {

	return (key in pft)
}

#
#@ Description: Splits 'pft_str' in 'arr' using PFT_SEP() as a
#@ separator. I.e. Splits what pft_get() returns.
#@ Returns: The length of 'arr'.
#@ Complexity: O(n)
#
function pft_split(arr, pft_str) {

	return split(pft_str, arr, PFT_SEP())
}


#
#@ Description: Splits 'pft_str', finds out if 'node' exists in
#@ the array created by the split.
#@ Returns: 1 if 'node' is a path in 'pft_str', 0 otherwise.
#@ Complexity: O(n)
#
function pft_path_has(pft_str, node) {

	return (!!index((PFT_SEP() pft_str PFT_SEP()), (PFT_SEP() node PFT_SEP())))
}

#
#@ Description: Turns 'arr' into a PFT_SEP() delimited string.
#@ Returns: The pft string representation of 'arr'.
#@ Complexity: O(n)
#
function pft_arr_to_pft_str(arr, len,    _i, _str) {

	_str = ""
	for (_i = 1; _i < len; ++_i)
		_str = (_str arr[_i] PFT_SEP())
	if (_i == len)
		_str = (_str arr[_i])
	return _str
}

#
#@ Description: Delimits the strings 'a' and 'b' with PFT_SEP().
#@ Returns: If only b is empty, returns a. If only a is empty, returns
#@ b. If both are empty, returns the empty string. Returns
#@ (a PFT_SEP() b) otherwise.
#@ Complexity: O(awk-concatenation)
#
function pft_cat(a, b) {

	if (("" != a) && ("" != b)) return (a PFT_SEP() b)
	if ("" == b) return a
	if ("" == a) return b
	return ""
}

#
#@ Description: Replaces all internal separators in 'pft_str' with
#@ 'sep'. If 'sep' is not given, "." is used.
#@ Returns: A printable representation of 'pft_str'.
#@ Complexity: O(n)
#
function pft_pretty(pft_str, sep) {

	gsub((PFT_SEP() "|" _PFT_MARK_SEP()), ((!sep) ? "." : sep), pft_str)
	return pft_str
}

#
#@ Description: Builds a string by performing a depth first search
#@ traversal of 'pft' starting from 'root'. The end result is all marked
#@ and leaf nodes subseparated by 'subsep' in their order of insertion
#@ separated by 'sep'. If 'sep' is not given, " " is used. If 'subsep'
#@ is not given, PFT_SEP() is removed from the node strings. E.g. for
#@ the words "this" and "that", if 'sep' is " -> "
#@ If 'subsep' is blank, the result shall be
#@ "this -> that"
#@ If 'subsep' is '-', the result shall be
#@ "t-h-i-s -> t-h-a-t"
#@ 'sep' does not appear after the last element.
#@ Returns: A string representation 'pft'.
#@ Complexity: O(n)
#
function pft_to_str_dfs(pft, root, sep, subsep,    _arr, _i, _len, _str,
_tmp, _get) {

	if (!pft_has(pft, root))
		return ""

	if (!(_get = pft_get(pft, root)))
		return root

	if (pft_is_marked(pft, root))
		_str = root

	if (!sep)
		sep = " "

	_tmp = ""
	_len = pft_split(_arr, _get)
	for (_i = 1; _i <= _len; ++_i) {

		if (_tmp = pft_to_str_dfs(pft, pft_cat(root, _arr[_i]),
			sep, subsep)) {
			_str = (_str) ? (_str sep _tmp) : _tmp
		}
	}

	gsub(PFT_SEP(), subsep, _str)
	return _str
}

#
#@ Description: Prints the string representation of 'pft' to stdout as
#@ returned by pft_to_str_dfs().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_print_dfs(pft, root, sep, subsep) {

	print pft_to_str_dfs(pft, root, sep, subsep)
}

#
#@ Description: Returns the dump of 'pft' as a single multi line string
#@ in the format "pft[<key>] = <val>" in no particular order. Marked
#@ nodes always begin with 'sep'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_str_dump(pft, sep,    _n, _str, _ret) {

	for (_n in pft) {
		_str = sprintf("pft[\"%s\"] = \"%s\"",
				pft_pretty(_n, sep), pft_pretty(pft[_n], sep))
		_ret = (_ret) ? (_ret "\n" _str) : _str
	}
	return _ret
}

#
#@ Description: Prints the dump of 'pft to stdout as returned by
#@ pft_str_dump().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_print_dump(pft, sep) {

	print pft_str_dump(pft, sep)
}
# </public>

function _pft_add(pft, key, val,    _path) {

	if ((_path = pft_get(pft, key))) {

		if (val && !pft_path_has(_path, val))
			val = pft_cat(_path, val)
		else
			return 0
	}

	pft[key] = val
	return 1
}

function _PFT_MARK_SEP() {return "mark\006"}
#@ </awklib_prefix_tree>
