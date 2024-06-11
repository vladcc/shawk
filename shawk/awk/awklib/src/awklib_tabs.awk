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

	++_AWKLIB_tabs__tabs_num
	_AWKLIB_tabs__tabs_str = (_AWKLIB_tabs__tabs_str "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (_AWKLIB_tabs__tabs_num) {
		--_AWKLIB_tabs__tabs_num
		_AWKLIB_tabs__tabs_str = substr(_AWKLIB_tabs__tabs_str, 1,
			_AWKLIB_tabs__tabs_num)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return _AWKLIB_tabs__tabs_num
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (_AWKLIB_tabs__tabs_str "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (_AWKLIB_tabs__tabs_str str)
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
