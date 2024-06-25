#@ <awklib_str_set>
#@ Library: str_set
#@ Description: Treats a string as a set of values.
#@ Version: 1.2
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-25
#@

# <public>
#
#@ Description: The set item delimiter.
#@ Returns: Some non-printable character.
#
function STR_SET_SEP() {

	return "\034"
}

#
#@ Description: The printable set item delimiter.
#@ Returns: The default printable delimiter character.
#
function STR_SET_PRINT_SEP() {

	return "|"
}

#
#@ Description: Initializes a string to the empty set.
#@ Returns: The string set initialization value.
#
function str_set_init() {

	return STR_SET_SEP()
}

#
#@ Description: Makes a set from an array.
#@ Returns: A string set from the elements of 'arr'.
#@ Complexity: O(add*len)
#
function str_set_init_arr(arr, len) {

	return str_set_add_arr(str_set_init(), arr, len)
}

#
#@ Description: Looks for 'val' in 'sset'.
#@ Returns: Non-zero if 'val' is in 'sset', 0 otherwise.
#@ Complexity: O(n)
#
function str_set_find(sset, val) {

	return index(sset, (STR_SET_SEP() val STR_SET_SEP()))
}

#
#@ Description: Adds 'val' to 'sset' if 'val' is not in 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(n)
#
function str_set_add(sset, val) {

	if (!str_set_find(sset, val))
		sset = (sset val STR_SET_SEP())
	return sset
}

#
#@ Description: Adds 'arr' to 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(add*len)
#
function str_set_add_arr(sset, arr, len) {

	while (len)
		sset = str_set_add(sset, arr[len--])
	return sset
}

#
#@ Description: Removes 'val' from 'sset' if 'val' is in 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(n)
#
function str_set_del(sset, val,    _start) {

	return (_start = str_set_find(sset, val)) ? \
		(substr(sset, 1, _start) substr(sset, _start+length(val)+2)) : sset
}

#
#@ Description: Removes 'arr' from 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(del*len)
#
function str_set_del_arr(sset, arr, len) {

	while (len)
		sset = str_set_del(sset, arr[len--])
	return sset
}


#
#@ Description: Gets the size of 'sset'.
#@ Returns: The number of elements in 'sset'.
#@ Complexity: O(n)
#
function str_set_count(sset) {

	return gsub(STR_SET_SEP(), STR_SET_SEP(), sset)-1
}

#
#@ Description: Tells you whether 'sset' is empty.
#@ Returns: 1 if 'sset' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function str_set_is_empty(sset) {

	return (STR_SET_SEP() == sset)
}

#
#@ Description: Extracts the 'n'-th element from 'sset'. 'n' is assumed to be in
#@ the bounds of 'sset'. A check whether or not it is should be performed before
#@ the call.
#@ Returns: The element at position 'n' in 'sset'. The empty string if 'n' is
#@ out of bounds. NOTE: The element at position 'n' could also be the empty
#@ string.
#@ Complexity: O(n)
#
function str_set_get(sset, n,    _pos) {

	if (!str_set_is_empty(sset)) {
		while (_pos = index(sset, STR_SET_SEP())) {
			if ((sset = substr(sset, _pos+1)) && !(--n))
				return substr(sset, 1, index(sset, STR_SET_SEP())-1)
		}
	}
	return ""
}

#
#@ Description: Splits 'sset' into 'arr'.
#@ Returns: The number of elements in 'arr'.
#@ Complexity: O(n)
#
function str_set_split(sset, arr) {

	return (str_set_is_empty(sset)) ? 0 : \
		split(substr(sset, 2), arr,  STR_SET_SEP())-1
}

#
#@ Description: Indicates if 'sset_a' and 'sset_b' contain the same items.
#@ Returns: 1 if they do, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_is_eq(sset_a, sset_b,    _i, _end, _arr, _is_eq) {

	_is_eq = 1
	if (str_set_count(sset_a) != str_set_count(sset_b)) {
		_is_eq = 0
	} else {
		_end = str_set_split(sset_b, _arr)
		for (_i = 1; _i <= _end; ++_i) {
			if (!str_set_find(sset_a, _arr[_i])) {
				_is_eq = 0
				break
			}
		}
	}
	return _is_eq
}

#
#@ Description: Gets all elements from 'sset_a' and 'sset_b'.
#@ Returns: The union set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_union(sset_a, sset_b,     _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i)
		sset_a = str_set_add(sset_a, _arr[_i])
	return sset_a
}

#
#@ Description: Gets all elements from 'sset_a' which are also in 'sset_b'.
#@ Returns: The intersection set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_intersect(sset_a, sset_b,    _i, _end, _arr, _sset_ret) {

	_sset_ret = str_set_init()
	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (str_set_find(sset_a, _arr[_i]))
			_sset_ret = (_sset_ret _arr[_i] STR_SET_SEP())
	}
	return _sset_ret
}

#
#@ Description: Gets all elements of 'sset_a' which are not in 'sset_b'.
#@ Returns: The difference set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_subtract(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i)
		sset_a = str_set_del(sset_a, _arr[_i])
	return sset_a
}

#
#@ Description: Indicates if 'sset_a' and 'sset_b' have no elements in common.
#@ Returns: 1 if they don't, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_are_disjoint(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (str_set_find(sset_a, _arr[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Indicates if 'sset_a' is a subset of 'sset_b'
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_is_subset(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_a, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (!str_set_find(sset_b, _arr[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to STR_SET_PRINT_SEP().
#@ Returns: A printable representation of 'sset'.
#@ Complexity: O(n)
#
function str_set_make_printable(sset, delim) {

	if (!delim)
		delim = STR_SET_PRINT_SEP()

	gsub(STR_SET_SEP(), delim, sset)
	return sset
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not give, it defaults to a single space.
#@ Returns: A printable representation of 'sset'.
#@ Complexity: O(n)
#
function str_set_pretty(sset, delim) {

	if (!delim)
		delim = " "

	sset = substr(sset, 2, length(sset)-2)
	gsub(STR_SET_SEP(), delim, sset)
	return sset
}

#
#@ Description: str_set_make_printable() + print.
#@ Returns: Nothing.
#
function str_set_print(sset, delim) {

	print str_set_make_printable(sset, delim)
}

#
#@ Description: str_set_pretty() + print.
#@ Returns: Nothing.
#
function str_set_pretty_print(sset, delim) {

	print str_set_pretty(sset, delim)
}

# </public>
#@ </awklib_str_set>
