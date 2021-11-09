#!/usr/bin/awk -f

function make_arr(arr_out, csv_in) {return split(csv_in, arr_out, ",")}

function test_heap_init(    _heap, _arr, _len) {
	at_test_begin("heap_init()")

	_heap["foo"] = "bar"
	at_true("foo" in _heap)

	heap_init(_heap)
	at_true(!("foo" in _heap))
}

function test_heap_init_arr(    _heap, _arr, _len) {
	at_test_begin("heap_init_arr()")

	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9,10")
	heap_init_arr(_heap, _arr, _len)
	at_true("10 9 7 8 5 6 3 1 4 2" == \
		arr_to_str(_heap, heap_size(_heap)))

	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9")
	heap_init_arr(_heap, _arr, _len)
	at_true("9 8 7 4 5 6 3 2 1" == \
		arr_to_str(_heap, heap_size(_heap)))
		
	# repeating
	_len = make_arr(_arr, "1,2,3,3,4,4,4,5,6,6")
	heap_init_arr(_heap, _arr, _len)
	at_true("6 6 4 5 4 3 4 2 3 1" == \
		arr_to_str(_heap, heap_size(_heap)))
}

function test_heap_peek_max(    _heap, _arr, _len) {
	at_test_begin("heap_peek_max()")

	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9,10")
	heap_init_arr(_heap, _arr, _len)
	at_true(10 == heap_peek_max(_heap))
	
	
	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9")
	heap_init_arr(_heap, _arr, _len)
	at_true(9 == heap_peek_max(_heap))
	
	# repeating
	_len = make_arr(_arr, "1,2,3,3,4,4,4,5,6,6")
	heap_init_arr(_heap, _arr, _len)
	at_true(6 == heap_peek_max(_heap))
}

function test_heap_pop(    _heap, _arr, _len) {
	at_test_begin("heap_pop()")

	_len = make_arr(_arr, "6,7,8,9,10,1,2,3,4,5")
	heap_init_arr(_heap, _arr, _len)
	at_true(10 == heap_peek_max(_heap))
	at_true("10 9 8 6 7 1 2 3 4 5" == \
		arr_to_str(_heap, heap_size(_heap)))
		
	heap_pop(_heap)
	at_true(9 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(8 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(7 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(6 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(5 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(4 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(3 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(2 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(1 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true("" == heap_peek_max(_heap))

	_len = make_arr(_arr, "5,6,7,1,3,4,2")
	heap_init_arr(_heap, _arr, _len)
	at_true(7 == heap_peek_max(_heap))
	at_true("7 6 5 1 3 4 2" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_pop(_heap)
	at_true(6 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(5 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(4 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(3 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(2 == heap_peek_max(_heap))

	heap_pop(_heap)
	at_true(1 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true("" == heap_peek_max(_heap))
	
	# repeating
	_len = make_arr(_arr, "1,2,3,3,4,4,4,5,6,6")
	heap_init_arr(_heap, _arr, _len)
	at_true(6 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(6 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(5 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(4 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	heap_pop(_heap)
	heap_pop(_heap)
	at_true(3 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	heap_pop(_heap)
	at_true(2 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(1 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true("" == heap_peek_max(_heap))
	
	# repeating by push
	heap_init(_heap)

	heap_push(_heap, 1)
	heap_push(_heap, 2)
	heap_push(_heap, 2)
	heap_push(_heap, 1)
	heap_push(_heap, 3)
	at_true(3 == heap_peek_max(_heap))
	at_true("3 2 2 1 1" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_pop(_heap)
	at_true(2 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	heap_pop(_heap)
	at_true(1 == heap_peek_max(_heap))
	
	heap_pop(_heap)
	at_true(1 == heap_peek_max(_heap))
	heap_pop(_heap)
	at_true("" == heap_peek_max(_heap))
	
	# pop empty
	heap_pop(_heap)
	heap_pop(_heap)
	heap_pop(_heap)
	
	heap_push(_heap, 3)
	at_true(3 == heap_peek_max(_heap))	
}

function test_heap_push(    _heap, _arr, _len) {
	at_test_begin("heap_push()")

	heap_init(_heap)
	heap_push(_heap, 10)
	at_true(10 == heap_peek_max(_heap))
	at_true("10" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 5)
	at_true(10 == heap_peek_max(_heap))
	at_true("10 5" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 3)
	at_true(10 == heap_peek_max(_heap))
	at_true("10 5 3" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 20)
	at_true(20 == heap_peek_max(_heap))
	at_true("20 10 3 5" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 14)
	at_true(20 == heap_peek_max(_heap))
	at_true("20 14 3 5 10" == arr_to_str(_heap, heap_size(_heap)))
	
	_len = make_arr(_arr, "5,6,7,1,3,4,2")
	heap_init_arr(_heap, _arr, _len)
	at_true(7 == heap_peek_max(_heap))
	at_true("7 6 5 1 3 4 2" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 0)
	at_true(7 == heap_peek_max(_heap))
	at_true("7 6 5 1 3 4 2 0" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 20)
	at_true(20 == heap_peek_max(_heap))
	at_true("20 7 5 6 3 4 2 0 1" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 12)
	at_true(20 == heap_peek_max(_heap))
	at_true("20 12 5 6 7 4 2 0 1 3" == \
		arr_to_str(_heap, heap_size(_heap)))
		
	# repeating
	heap_init(_heap)

	heap_push(_heap, 1)
	at_true(1 == heap_peek_max(_heap))
	at_true("1" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 2)
	at_true(2 == heap_peek_max(_heap))
	at_true("2 1" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 2)
	at_true(2 == heap_peek_max(_heap))
	at_true("2 1 2" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 1)
	at_true(2 == heap_peek_max(_heap))
	at_true("2 1 2 1" == arr_to_str(_heap, heap_size(_heap)))
	
	heap_push(_heap, 3)
	at_true(3 == heap_peek_max(_heap))
	at_true("3 2 2 1 1" == arr_to_str(_heap, heap_size(_heap)))
}

function test_heap_size(    _heap, _arr, _len) {
	at_test_begin("heap_size()")

	heap_init(_heap)
	at_true(0 == heap_size(_heap))
	
	heap_push(_heap, 10)
	at_true(1 == heap_size(_heap))

	heap_push(_heap, 20)
	at_true(2 == heap_size(_heap))

	heap_pop(_heap)
	at_true(1 == heap_size(_heap))
	
	heap_pop(_heap)
	at_true(0 == heap_size(_heap))
	
	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9,10")
	heap_init_arr(_heap, _arr, _len)
	at_true(10 == heap_size(_heap))
}

function test_heap_is_empty(    _heap, _arr, _len) {
	at_test_begin("heap_is_empty()")

	heap_init(_heap)
	at_true(1 == heap_is_empty(_heap))
	
	heap_push(_heap, 10)
	at_true(0 == heap_is_empty(_heap))
	
	heap_push(_heap, 20)
	at_true(0 == heap_is_empty(_heap))
	
	heap_pop(_heap)
	at_true(0 == heap_is_empty(_heap))

	heap_pop(_heap)
	at_true(1 == heap_is_empty(_heap))

	_len = make_arr(_arr, "1,2,3,4,5,6,7,8,9,10")
	heap_init_arr(_heap, _arr, _len)
	at_true(0 == heap_is_empty(_heap))
}

function main() {
	at_awklib_awktest_required()
	test_heap_init()
	test_heap_init_arr()
	test_heap_peek_max()
	test_heap_pop()
	test_heap_push()
	test_heap_size()
	test_heap_is_empty()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
