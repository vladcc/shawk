#@ <awklib_sort>
#@ Library: sort
#@ Description: Sorting procedures in case your awk doesn't have one, or
#@ you're looking for a specific property. The input arrays are assumed
#@ to be number indexed starting from one. Sorting is done in
#@ non-decreasing order.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-30
#@

#
#@ Description: Checks if 'arr' is sorted in non-decreasing order.
#@ Returns: 1 if it is, 0 otherwise. 1 if 'len' < 2 as well.
#@ Complexity: O(n)
#
function is_sorted(arr, len,    _i) {

	if (len > 1) {

		for (_i = 2; _i <= len; ++_i) {
		
			if (arr[_i-1] > arr[_i])
				return 0
		}
	}
	return 1
}

#
#@ Description: A quick sort implementation. If 'arr' is already sorted,
#@ the procedure takes O(n) time. When the sub-arrays become small,
#@ insertion sort is used for optimization.
#@ Returns: Nothing.
#@ Complexity: O(n log n)
#
function qsort(arr, len) {
	
	if (!is_sorted(arr, len))
		_qsort(arr, 1, len)
}
function _qsort(arr, start, end,    _up, _down, _piv, _tmp,
_size_minus_one) {
	
	_size_minus_one = end-start
	if (_size_minus_one < 5) {
	
		_snsort(arr, start, end)
		return
	}
	
	_piv = arr[start+int(_size_minus_one/2)]
	_up = start-1
	_down = end+1
	
	while (1) {
		
		do {
			# _piv = arr[start+int(_size_minus_one/2)] guarantees _piv
			# is never the last element of any array with size >= 2 and
			# it guarantees _up will stop at least once before it
			# reaches _down. This guarantees that to break out of the
			# loop _down would either reach _up before _up reaches _down
			# on the first iteration, or the loop will execute at least
			# twice, therefore _down will be decremented at least twice.
			# Hence (_down < end) will always hold true, so 
			# qsort(start, _down) will always terminate because the
			# range will have at least one element less than the
			# previous call.
		
			++_up
		} while (arr[_up] < _piv)
		
		
		do {
			--_down
		} while (arr[_down] > _piv)
		
		if (_up < _down) {
		
			# arr[_up] must be >= _piv
			# arr[_down] must be <= _piv
			# hence the swap ensures no value left of _down is > _piv
			# and no value right of _down is < _piv
			#
			# i.e. if arr[_down] is <= _piv, it will be swapped with
			# something which cannot be < _piv because all < _piv were
			# skipped
			# if arr[_up] is >= _piv, it will be swapped with something
			# which cannot be > _piv because all > _piv were skipped
		
			_tmp = arr[_up]
			arr[_up] = arr[_down]
			arr[_down] = _tmp
		} else {
		
			break
		}
	}
	
	_qsort(arr, start, _down)
	_qsort(arr, _down+1, end)
}

#
#@ Description: A merge sort implementation. Generally slower than quick
#@ sort, but still the quickest stable sort around for large inputs.
#@ Already sorted input takes O(n) time.
#@ Returns: Nothing.
#@ Complexity: O(n log n)
#
function msort(arr, len) {
	
	if (!is_sorted(arr, len))
		_msort(arr, 1, len)
}
function _msort(arr, start, end,    _i, _cpy) {
		
		# copy the array
		for (_i = start; _i <= end; ++_i)
			_cpy[_i] = arr[_i]
			
		# sort the copy into the array ...
		_merge_sort(arr, start, end, _cpy)
}
function _merge_sort(arr, start, end, cpy,    _mid, _size_minus_one,
_left, _right) {

	_size_minus_one = (end-start)
	if (_size_minus_one < 5) {
	
		_snsort(arr, start, end)
		return
	}

	_mid = start + int(_size_minus_one/2)
	
	# ... by sorting the first half of the array into the copy
	_merge_sort(cpy, start, _mid, arr)
	
	# then the second half
	_merge_sort(cpy, _mid+1, end, arr)
	
	
	# then merge the two sorted halves of the copy back into the array
	_left = start
	_right = _mid+1
	
	while (_left <= _mid && _right <= end) {
		
		if (cpy[_left] < cpy[_right])
			arr[start++] = cpy[_left++]
		else
			arr[start++] = cpy[_right++]
	}
	
	while (_left <= _mid)
		arr[start++] = cpy[_left++]
	
	while (_right <= end)
		arr[start++] = cpy[_right++]
}

#
# Simple insertion sort - faster for very small arrays since it has less
# overhead than the binary search version.
#
function _snsort(arr, start, end,    _i, _j, _tmp) {

	for (_i = start+1; _i <= end; ++_i) {
		
		_tmp = arr[_i]
		for (_j = _i-1; _j >= start && arr[_j] > _tmp; --_j)
			arr[_j+1] = arr[_j]
		arr[_j+1] = _tmp
	} 
}

#
#@ Description: An binary insertion sort implementation. Stable, online,
#@ adaptive, in-place, quick for small arrays. Don't sort more than a
#@ few thousand things unless you're not in a hurry.
#@ Returns: Nothing.
#@ Complexity: O(n*n)
#
function nsort(arr, len) {_nsort(arr, 1, len)}
function _nsort(arr, start, end,    _i, _j, _s, _e, _m, _k, _key) {
	
	for (_i = start; _i < end; ++_i) {
		
		_s = start
		_e = _i
		_k = _i+1
		_key = arr[_k]
		
		while (_s <= _e) {
		
			_m = _s + int((_e-_s)/2)	
			if (_key < arr[_m])
				_e = _m - 1
			else
				_s = _m + 1
		}
		
		for (_j = _k; _j > _s; --_j)
			arr[_j] = arr[_j-1]
		arr[_j] = _key
	}
}
#@ </awklib_sort>
