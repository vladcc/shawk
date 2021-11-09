#!/usr/bin/awk -f

function make_arr(arr_out, csv_in) {return split(csv_in, arr_out, ",")}

function test_vect_init(    _vect, _arr, _len) {
	at_test_begin("vect_init()")

	_vect[1] = "foo"
	at_true(1 in _vect)
	vect_init(_vect)
	at_true(!(1 in _vect))
}

function test_vect_init_arr(    _vect, _arr, _len) {
	at_test_begin("vect_init_arr()")

	_len = make_arr(_arr, "0,1,2,4,8,16,32")
	vect_init_arr(_vect, _arr, _len)
	at_true("0 1 2 4 8 16 32" == arr_to_str(_vect, vect_len(_vect)))
	at_true("0-1-2-4-8-16-32" == \
		arr_to_str(_vect, vect_len(_vect), "-"))
}

function test_vect_push(    _vect, _arr, _len) {
	at_test_begin("vect_push()")

	vect_init(_vect)
	vect_push(_vect, 1)
	vect_push(_vect, 2)
	vect_push(_vect, 4)
	
	at_true(3 == vect_len(_vect))
	at_true("1 2 4" == arr_to_str(_vect, vect_len(_vect)))
	at_true("1-2-4" == arr_to_str(_vect, vect_len(_vect), "-"))
}

function test_vect_push_arr(    _vect, _arr, _len) {
	at_test_begin("vect_push_arr()")

	vect_init(_vect)
	_len = make_arr(_arr, "1,2,3,4")
	vect_push_arr(_vect, _arr, _len)
	
	at_true(4 == vect_len(_vect))
	at_true("1 2 3 4" == arr_to_str(_vect, vect_len(_vect)))
	at_true("1-2-3-4" == arr_to_str(_vect, vect_len(_vect), "-"))
	
	vect_push_arr(_vect, _arr, _len)
	at_true(8 == vect_len(_vect))
	at_true("1 2 3 4 1 2 3 4" == arr_to_str(_vect, vect_len(_vect)))
}

function test_vect_peek(    _vect, _arr, _len) {
	at_test_begin("vect_peek()")

	vect_init(_vect)
	
	vect_push(_vect, 1)
	at_true(1 == vect_peek(_vect))
	
	vect_push(_vect, 2)
	at_true(2 == vect_peek(_vect))
	
	vect_push(_vect, 4)
	at_true(4 == vect_peek(_vect))
}

function test_vect_pop(    _vect, _arr, _len) {
	at_test_begin("vect_pop()")

	vect_init(_vect)
	
	vect_push(_vect, 1)
	vect_push(_vect, 2)
	vect_push(_vect, 4)
	at_true(3 == vect_len(_vect))

	at_true(4 == vect_peek(_vect))
	vect_pop(_vect)
	at_true(2 == vect_len(_vect))
	
	at_true(2 == vect_peek(_vect))
	vect_pop(_vect)
	at_true(1 == vect_len(_vect))
	
	at_true(1 == vect_peek(_vect))
	vect_pop(_vect)
	at_true(0 == vect_len(_vect))
}

function test_vect_len(    _vect, _arr, _len) {
	at_test_begin("vect_len()")

	vect_init(_vect)
	at_true(0 == vect_len(_vect))
	
	vect_push(_vect, 1)
	at_true(1 == vect_len(_vect))
	
	vect_push(_vect, 2)
	at_true(2 == vect_len(_vect))

	vect_push(_vect, 4)
	at_true(3 == vect_len(_vect))
}

function test_vect_is_empty(    _vect, _arr, _len) {
	at_test_begin("vect_is_empty()")

	vect_init(_vect)
	at_true(1 == vect_is_empty(_vect))
	
	vect_push(_vect, 1)
	at_true(0 == vect_is_empty(_vect))

	vect_pop(_vect)
	at_true(1 == vect_is_empty(_vect))
}

function test_vect_del_ind(    _vect, _arr, _len) {
	at_test_begin("vect_del_ind()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	vect_init_arr(_vect, _arr, _len)
	
	at_true(5 == vect_len(_vect))
	at_true("2 3 4 5 6" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_ind(_vect, 1)
	at_true(4 == vect_len(_vect))
	at_true("3 4 5 6" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_ind(_vect, vect_len(_vect))
	at_true(3 == vect_len(_vect))
	at_true("3 4 5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_ind(_vect, 2)
	at_true(2 == vect_len(_vect))
	at_true("3 5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_ind(_vect, 1)
	at_true(1 == vect_len(_vect))
	at_true("5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_ind(_vect, 1)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))
}

function test_vect_del_val(    _vect, _arr, _len) {
	at_test_begin("vect_del_val()")

	str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	vect_init_arr(_vect, _arr, _len)
	
	vect_del_val(_vect, "foo")
	at_true(5 == vect_len(_vect))
	at_true("2 3 4 5 6" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_val(_vect, 2)
	at_true(4 == vect_len(_vect))
	at_true("3 4 5 6" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_val(_vect, 4)
	at_true(3 == vect_len(_vect))
	at_true("3 5 6" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_val(_vect, 6)
	at_true(2 == vect_len(_vect))
	at_true("3 5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_del_val(_vect, 3)
	at_true(1 == vect_len(_vect))
	at_true("5" == arr_to_str(_vect, vect_len(_vect)))	
	
	vect_del_val(_vect, 5)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))

	vect_del_val(_vect, 5)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))
}

function test_vect_swap_pop_ind(    _vect, _arr, _len) {
	at_test_begin("vect_swap_pop_ind()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	vect_init_arr(_vect, _arr, _len)
	at_true(5 == vect_len(_vect))
	at_true(_str == arr_to_str(_vect, vect_len(_vect), ","))
	
	vect_swap_pop_ind(_vect, 1)
	at_true(4 == vect_len(_vect))
	at_true("6 3 4 5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_ind(_vect, 4)
	at_true(3 == vect_len(_vect))
	at_true("6 3 4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_ind(_vect, 2)
	at_true(2 == vect_len(_vect))
	at_true("6 4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_ind(_vect, 1)
	at_true(1 == vect_len(_vect))
	at_true("4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_ind(_vect, 1)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))
}

function test_vect_swap_pop_val(    _vect, _arr, _len) {
	at_test_begin("vect_swap_pop_val()")

	_str = "2,3,4,5,6"
	_len = make_arr(_arr, _str)
	vect_init_arr(_vect, _arr, _len)
	at_true(5 == vect_len(_vect))
	at_true(_str == arr_to_str(_vect, vect_len(_vect), ","))
	
	vect_swap_pop_val(_vect, "foo")
	at_true(5 == vect_len(_vect))
	at_true(_str == arr_to_str(_vect, vect_len(_vect), ","))
	
	vect_swap_pop_val(_vect, 2)
	at_true(4 == vect_len(_vect))
	at_true("6 3 4 5" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_val(_vect, 5)
	at_true(3 == vect_len(_vect))
	at_true("6 3 4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_val(_vect, 3)
	at_true(2 == vect_len(_vect))
	at_true("6 4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_val(_vect, 6)
	at_true(1 == vect_len(_vect))
	at_true("4" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_val(_vect, 4)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))
	
	vect_swap_pop_val(_vect, 4)
	at_true(0 == vect_len(_vect))
	at_true("" == arr_to_str(_vect, vect_len(_vect)))
}

function main() {
	at_awklib_awktest_required()
	test_vect_init()
	test_vect_init_arr()
	test_vect_push()
	test_vect_push_arr()
	test_vect_peek()
	test_vect_pop()
	test_vect_len()
	test_vect_is_empty()
	test_vect_del_ind()
	test_vect_del_val()
	test_vect_swap_pop_ind()
	test_vect_swap_pop_val()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
