#@ <awklib_psplit>
#@ Library: psplit
#@ Description: Splits an input string into patterns.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-09-06
#@

#
#@ Description: Clears 'arr_out', matches 'str' against 'pat' and places
#@ all matches in 'arr_out' such as arr_out[1] is the first match,
#@ arr_out[2] is the second and so on.
#@ Returns: The number of times 'pat' was matched in 'str', i.e. the
#@ length of 'arr_out'.
#
function psplit(arr_out, str, pat,    _i) {
	
	delete arr_out
	_i = 0
	if (pat) {
		
		while (match(str, pat)) {
			
			arr_out[++_i] = substr(str, RSTART, RLENGTH)
			str = substr(str, RSTART + RLENGTH)
		}
	}
	return _i
}
#@ </awklib_psplit>
