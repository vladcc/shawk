#@ <awklib_heap>
#@ Library: heap
#@ Description: A max heap functionality. Implemented in terms of a
#@ vector.
#@ Dependencies: awklib_vect.awk
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-09-05
#@

#
#@ Description: Initializes 'heap' to empty.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function heap_init(heap) {
	
	vect_init(heap)
}

#
#@ Description: Creates a max heap in 'heap' from the elements of 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function heap_init_arr(heap, arr, len,    _i, _end) {
	
	vect_init_arr(heap, arr, len)
	_end = vect_len(heap)
	for (_i = int(_end/2); _i >= 1; --_i)
		_heap_sift_down(heap, _i, _end)
}

#
#@ Description: Looks at the top of 'heap'.
#@ Returns: The value of the largest element in the heap, "" if 'heap'
#@ is empty.
#@ Complexity: O(1)
#
function heap_peek_max(heap) {

	return vect_len(heap) ? heap[1] : ""
}

#
#@ Description: Removes the top of 'heap'.
#@ Returns: Nothing.
#@ Complexity: O(log n)
#
function heap_pop(heap) {
	
	if (vect_len(heap)) {
		vect_swap_pop_ind(heap, 1)
		_heap_sift_down(heap, 1, vect_len(heap))
	}
}

#
#@ Description: Adds 'val' to 'heap'.
#@ Returns: Nothing.
#@ Complexity: O(log n)
#
function heap_push(heap, val,    _len) {

	vect_push(heap, val)
	_len = vect_len(heap)
	_heap_sift_up(heap, _len, _len) 
}

#
#@ Description: Indicates the size of 'heap'.
#@ Returns: The size of 'heap'.
#@ Complexity: O(1)
#
function heap_size(heap) {
	
	return vect_len(heap)
}

#
#@ Description: Indicates if 'heap' is empty.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(1)
#
function heap_is_empty(heap) {

	return vect_is_empty(heap)
}

function _heap_sift_down(heap, parent, end,    _child, _tmp) {

	if ((_child = parent*2) <= end) {

		if (_child < end && heap[_child+1] > heap[_child])
			++_child
		
		if (heap[_child] > heap[parent]) {
			
			_tmp = heap[_child]
			heap[_child] = heap[parent]
			heap[parent] = _tmp
			_heap_sift_down(heap, _child, end)
		}
	}
}

function _heap_sift_up(heap, child, end,    _parent, _tmp) {
	
	if (child <= end && (_parent = int(child/2)) > 0) {
	
		if (heap[child] > heap[_parent]) {
			
			_tmp = heap[child]
			heap[child] = heap[_parent]
			heap[_parent] = _tmp
			_heap_sift_up(heap, _parent, end)
		}
	}
}
#@ </awklib_heap>
