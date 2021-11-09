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
