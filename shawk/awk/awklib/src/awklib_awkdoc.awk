#@ <awklib_awkdoc>
#@ Library: awd
#@ Description: Generates documentation from awk scripts.
#@ Convention: If a line begins with '#@', it's a documentation string,
#@ the '#@' is removed and everything after is the final result for that
#@ line. When parsing a line with a function declaration, any arguments
#@ that appear on the line following the declaration are ignored. So are
#@ arguments which are preceded by four spaces, as they are considered
#@ local to the function.
#@
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-25
#@

#
#@ Description: Clears 'arr_out', goes through the input text in
#@ 'arr_in' and generates documentation in 'arr_out'. 
#@ Returns: The length of 'arr_out'.
#
function awd_make_doc(arr_out, arr_in, len,    _i, _n, _str) {
	
	delete arr_out
	_n = 0
	for (_i = 1; _i <= len; ++_i) {
		
		_str = arr_in[_i]
		if (match(_str, _AWD_DOC()))
			arr_out[++_n] = _awd_on_doc_str(_str)
		else if (match(_str, _AWD_FUNC()))
			arr_out[++_n] = _awd_on_function(_str)
	}
	return _n
}

function _awd_on_function(str) {

	# eat leading spaces
	sub("^[[:space:]]+", "", str)
	
	# replace local arguments with a ')' 
	sub(",?    .*$", ")", str)
	
	# place a ')' in case there are arguments on the next line
	sub(",[[:space:]]*$", ")", str)
	
	# replace ') {' with a ')'
	sub("\\).*$", ")", str)
	
	# always place an extra new line after a function
	return (str "\n")
}

function _awd_on_doc_str(str) {
	
	# strip the tag off the doc string
	sub("^[[:space:]]*#@[[:space:]]*", "", str)
	return str
}

function _AWD_DOC() {return "^#@"}
function _AWD_FUNC() {return "^[[:space:]]*function[[:space:]]+[^_]"}
#@ </awklib_awkdoc>
