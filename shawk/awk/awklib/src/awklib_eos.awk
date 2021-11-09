#@ <awklib_eos>
#@ Library: eos
#@ Description: An entry order set. Implemented in terms of a vector.
#@ The elements appear in the order they were entered.
#@ Dependencies: awklib_vect.awk
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
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
#@ Complexity: O(n)
#
function eos_union(eos_dest, eos_a, eos_b,    _i, _len) {
	
	vect_init(eos_dest)
	
	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i)
		eos_add(eos_dest, eos_a[_i])
	
	_len = vect_len(eos_b)
	for (_i = 1; _i <= _len; ++_i)
		eos_add(eos_dest, eos_b[_i])
}

#
#@ Description: 'eos_dest' gets all elements from 'eos_a' which are also
#@ in 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n)
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
#@ Complexity: O(n)
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
#@ Description: Indicates if the intersection of 'eos_a' and 'eos_b' is
#@ empty.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n)
#
function eos_are_disjoint(eos_a, eos_b,    _eos_tmp) {
	
	eos_intersect(_eos_tmp, eos_a, eos_b)
	return eos_is_empty(_eos_tmp)
}

#
#@ Description: Indicates if 'eos_a' is a subset of 'eos_b'.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n)
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
