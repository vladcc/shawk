#@ <awklib_str_list>
#@ Library: str_list
#@ Description: Treats a string as a list of elements.
#@ Version: 1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-25
#@

# <public>
#
#@ Description: The item separator.
#@ Returns: Some non-printable character.
#
function STR_LIST_SEP() {

	return "\034"
}

#
#@ Description: The printable item separator.
#@ Returns: The default printable delimiter.
#
function STR_LIST_PRINT_SEP() {

	return "@"
}

#
#@ Description: Initializes a string to the empty list.
#@ Returns: The string list initialization value.
#
function str_list_init() {

	return STR_LIST_SEP()
}

#
#@ Description: Makes a list from an array.
#@ Returns: A string list with the elements of 'arr'.
#@ Complexity: O(add*len)
#
function str_list_init_arr(arr, len) {

	return str_list_add_arr(str_list_init(), arr, len)
}

#
#@ Description: Gets the size of 'slist'.
#@ Returns: The number of elements in 'slist'.
#@ Complexity: O(n)
#
function str_list_size(slist) {

	return gsub(STR_LIST_SEP(), STR_LIST_SEP(), slist)-1
}

#
#@ Description: Tells you whether 'slist' is empty.
#@ Returns: 1 if 'slist' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function str_list_is_empty(slist) {

	return (STR_LIST_SEP() == slist)
}

#
#@ Description: Looks for the first 'val' in 'slist'.
#@ Returns: Non-zero if 'val' is found, 0 otherwise.
#@ Complexity: O(n)
#
function str_list_find(slist, val) {

	return index(slist, (STR_LIST_SEP() val STR_LIST_SEP()))
}

#
#@ Description: Finds out how many instances of 'val' are in 'slist'
#@ Returns: The number of times 'val' occurs in 'slist'.
#@ Complexity: O(n)
#
function str_list_how_many(slist, val,    _start, _ret) {

	_ret = 0
	val = (STR_LIST_SEP() val STR_LIST_SEP())
	while (_start = index(slist, val)) {
		++_ret
		slist = substr(slist, _start+1)
	}
	return _ret
}

#
#@ Description: Appends 'val' to 'slist'.
#@ Returns: A new list to replace 'slist'.
#@ Complexity: O(str-append)
#
function str_list_add(slist, val) {

	return (slist val STR_LIST_SEP())
}

#
#@ Description: Adds 'arr' to 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(add*len)
#
function str_list_add_arr(slist, arr, len,    _i) {

	for (_i = 1; _i <= len; ++_i)
		slist = str_list_add(slist, arr[_i])
	return slist
}

#
#@ Description: Appends 'slist_b' to 'slist_a'.
#@ Returns: A new list to replace 'slist_a'.
#@ Complexity: O(str-append)
#
function str_list_append_list(slist_a, slist_b) {

	return (slist_a substr(slist_b, 2))
}

#
#@ Description: Removes the first 'val' from 'slist'.
#@ Returns: A new list to replace 'slist'.
#@ Complexity: O(n)
#
function str_list_del(slist, val,    _start) {

	return (_start = str_list_find(slist, val)) ? \
		(substr(slist, 1, _start) substr(slist, _start+length(val)+2)) : slist
}

#
#@ Description: Removes every occurrence of 'val' from 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(n)
#
function str_list_del_all(slist, val,    _start, _vlen) {

	val = (STR_LIST_SEP() val STR_LIST_SEP())
	_vlen = length(val)
	while (_start = index(slist, val))
		slist = (substr(slist, 1, _start) substr(slist, _start+_vlen))
	return slist
}

#
#@ Description: Removes the first occurrence of every 'arr' item from 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(del*len)
#
function str_list_del_arr(slist, arr, len) {

	while (len)
		slist = str_list_del(slist, arr[len--])
	return slist
}

#
#@ Description: Removes every occurrence of every item in 'arr' from 'slist'.
#@ Returns: A new sting list to replace 'slist'.
#@ Complexity: O(del_all*len)
#
function str_list_del_arr_all(slist, arr, len) {

	while (len)
		slist = str_list_del_all(slist, arr[len--])
	return slist
}

#
#@ Description: Extracts the 'n'-th element from 'slist'. 'n' is assumed to be
#@ in the bounds of 'slist'. A check whether or not it is should be performed
#@ before the call.
#@ Returns: The element at position 'n' in 'slist'. The empty string if 'n' is
#@ out of bounds. NOTE: The element at position 'n' could also be the empty
#@ string.
#@ Complexity: O(n)
#
function str_list_get(slist, n) {

	if (!str_list_is_empty(slist)) {
		while (_pos = index(slist, STR_LIST_SEP())) {
			if ((slist = substr(slist, _pos+1)) && !(--n))
				return substr(slist, 1, index(slist, STR_LIST_SEP())-1)
		}
	}
	return ""
}

#
#@ Description: Splits 'slist' in 'arr'.
#@ Returns: The size of 'arr'.
#@ Complexity: O(n)
#
function str_list_split(slist, arr) {

	return split(substr(slist, 2), arr,  STR_LIST_SEP())-1
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to STR_LIST_PRINT_SEP().
#@ Returns: A printable representation of 'slist'.
#@ Complexity: O(n)
#
function str_list_make_printable(slist, delim) {

	if (!delim)
		delim = STR_LIST_PRINT_SEP()

	gsub(STR_LIST_SEP(), delim, slist)
	return slist
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to a single space.
#@ Returns: A printable representation of 'slist'.
#@ Complexity: O(n)
#
function str_list_pretty(slist, delim) {

	if (!delim)
		delim = " "

	slist = substr(slist, 2, length(slist)-2)
	gsub(STR_LIST_SEP(), delim, slist)
	return slist
}

#
#@ Description: str_list_make_printable() + print.
#@ Returns: Nothing.
#
function str_list_print(slist, delim) {

	print str_list_make_printable(slist, delim)
}

#
#@ Description: str_list_pretty() + print.
#@ Returns: Nothing.
#
function str_list_pretty_print(slist, delim) {

	print str_list_pretty(slist, delim)
}

# </public>
#@ </awklib_str_list>
