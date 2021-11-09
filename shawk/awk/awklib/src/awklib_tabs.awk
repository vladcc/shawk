#@ <awklib_tabs>
#@ Library: tabs
#@ Description: String indentation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Adds a tab to the indentation string.
#@ Returns: Nothing.
#
function tabs_inc() {

	++__LB_tabs_tabs_num__
	__LB_tabs_tabs_str__ = (__LB_tabs_tabs_str__ "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (__LB_tabs_tabs_num__) {
		--__LB_tabs_tabs_num__
		__LB_tabs_tabs_str__ = substr(__LB_tabs_tabs_str__, 1,
			__LB_tabs_tabs_num__)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return __LB_tabs_tabs_num__
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (__LB_tabs_tabs_str__ "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (__LB_tabs_tabs_str__ str)
}

#
#@ Description: Prints the indented 'str' to stdout without a new line
#@ at the end.
#@ Returns: Nothing.
#
function tabs_print_str(str) {

	printf("%s", tabs_indent(str))
}

#
#@ Description: Prints the indented 'str' to stdout with a new line at
#@ the end.
#@ Returns: Nothing.
#
function tabs_print(str) {

	print tabs_indent(str)
}
#@ </awklib_tabs>
