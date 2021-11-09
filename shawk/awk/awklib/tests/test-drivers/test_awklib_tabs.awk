#!/usr/bin/awk -f

function test_tabs() {
	at_test_begin("tabs()")

	at_true(0 == tabs_num())
	at_true("" == tabs_get())
	at_true("foo" == tabs_indent("foo"))
	
	tabs_inc()
	at_true(1 == tabs_num())
	at_true("\t" == tabs_get())
	at_true("\tfoo" == tabs_indent("foo"))
	
	tabs_inc()
	at_true(2 == tabs_num())
	at_true("\t\t" == tabs_get())
	at_true("\t\tfoo" == tabs_indent("foo"))
	
	tabs_dec()
	at_true(1 == tabs_num())
	at_true("\t" == tabs_get())
	at_true("\tfoo" == tabs_indent("foo"))
	
	tabs_dec()
	at_true(0 == tabs_num())
	at_true("" == tabs_get())
	at_true("foo" == tabs_indent("foo"))
	
	tabs_dec()
	at_true(0 == tabs_num())
	tabs_dec()
	at_true(0 == tabs_num())
	tabs_dec()
	at_true(0 == tabs_num())
	
	tabs_inc()
	at_true(1 == tabs_num())
	at_true("\t" == tabs_get())
	at_true("\tfoo" == tabs_indent("foo"))
}

function main() {
	at_awklib_awktest_required()
	test_tabs()

	if (Report)
		at_report()
}

BEGIN {
	main()
}
