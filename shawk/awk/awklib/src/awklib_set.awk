#@ <awklib_set>
#@ Library: set
#@ Description: A set implementation. Lookups are O(1), getting the size
#@ is O(n). Makes no guarantees about order.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Clears the variable pointed to by 'set'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function set_init(set) {
	
	set[""]
	delete set
}

#
#@ Description: Initializes 'set' to a set of the elements in 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_init_arr(set, arr, len,    _i) {
	
	set_init(set)
	for (_i = 1; _i <= len; ++_i)
		set[arr[_i]]
}

#
#@ Description: Initializes 'set' to a set of the elements in 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_copy(set_dest, set_src,    _n, _i) {
	
	delete set_dest
	_i = 0
	for (_n in set_src) {
		set_dest[_n]
		++_i
	}
	return _i
}

#
#@ Description: Places 'val' in 'set'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function set_place(set, val) {

	set[val]
}

#
#@ Description: Removes 'val' from 'set'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function set_del(set, val) {

	if (set_has(set, val))
		delete set[val]
}

#
#@ Description: Indicates if 'val' exists in 'set'.
#@ Returns: 1 if 'val' is in 'set', 0 otherwise.
#@ Complexity: O(1)
#
function set_has(set, val) {
	
	return (val in set)
}

#
#@ Description: Indicates if 'set' is empty.
#@ Returns: 1 if 'set' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function set_is_empty(set,    _n) {
	
	for (_n in set)
		return 0
	return 1
}

#
#@ Description: Clears 'set_out', creates the union of 'set_a' and
#@ 'set_b' into 'set_out'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_union(set_out, set_a, set_b,    _n) {

	delete set_out
	for (_n in set_a)
		set_out[_n]
	for (_n in set_b)
		set_out[_n]
}

#
#@ Description: Clears 'set_out', creates the intersection of 'set_a'
#@ and 'set_b' into 'set_out'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_intersect(set_out, set_a, set_b,    _n) {
	
	delete set_out
	for (_n in set_a) {
		if (_n in set_b)
			set_out[_n]
	}
}

#
#@ Description: Clears 'set_out', subtracts 'set_b' from 'set_a' into
#@ 'set_out'. That is, 'set_out' = 'set_a' - 'set_b'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_subtract(set_out, set_a, set_b,    _n) {
	
	delete set_out
	for (_n in set_a) {
		if (!(_n in set_b))
			set_out[_n]
	}
}

#
#@ Description: Indicates if 'set_a' and 'set_b' are disjoint, i.e. if
#@ their intersection is empty.
#@ Returns: 1 if 'set_a' and 'set_b' are disjoint, 0 otherwise.
#@ Complexity: O(n)
#
function set_are_disjoint(set_a, set_b,    _set_out) {
	
	set_intersect(_set_out, set_a, set_b)
	return set_is_empty(_set_out)
}


#
#@ Description: Indicates whether 'set_a' and 'set_b' have the same
#@ elements.
#@ Returns: 1 if the sets are equal, 0 otherwise.
#@ Complexity: O(n)
#
function set_is_eq(set_a, set_b,    _n) {
	
	for (_n in set_a) {
		if (!(_n in set_b))
			return 0
	}
	for (_n in set_b) {
		if (!(_n in set_a))
			return 0
	}
	return 1
}

#
#@ Description: Indicates whether 'set_a' is a subset of 'set_b'.
#@ Returns: 1 if 'set_a' is a subset of 'set_b', 0 otherwise.
#@ Complexity: O(n)
#
function set_is_subset(set_a, set_b,    _n) {
	
	for (_n in set_a) {
		if (!(_n in set_b))
			return 0
	}
	return 1
}

#
#@ Description: Counts the number of elements in 'set'.
#@ Returns: The size of 'set'.
#@ Complexity: O(n)
#
function set_size(set,    _n, _i) {
	
	_i = 0
	for (_n in set)
		++_i
	return _i
}

#
#@ Description: Concatenates the elements of 'set' into a string in no
#@ particular order. The elements are separated by 'sep'. If 'sep' is
#@ not given, " " is used. 'sep' does not appear after the last
#@ element.
#@ Returns: The string representation of 'set'.
#@ Complexity: O(n)
#
function set_to_str(set, sep,    _n, _str) {
	
	if (!sep)
		sep = " "
		
	_str = ""
	for (_n in set) {
		
		if (_str)
			_str = (_str sep _n)
		else
			_str = _n
	}
	return _str
}

#
#@ Description: Prints the string representation of 'set' to stdout as
#@ returned by set_to_str().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function set_print(set, sep) {

	print set_to_str(set, sep)
}
#@ </awklib_set>
