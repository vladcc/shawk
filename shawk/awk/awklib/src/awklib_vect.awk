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
