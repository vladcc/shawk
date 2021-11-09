#@ <awklib_read>
#@ Library: read
#@ Description: Read lines or a file into an array.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Clears 'arr_out', reads 'fname' and saves the content in 
#@ 'arr_our'. 
#@ Returns: The number of lines read, which is also the length of
#@ 'arr_out', or less than 0 if an error has occurred.
#
function read_file(fname, arr_out,    _line, _i, _code) {

	delete arr_out
	_i = 0
	
	while ((_code = (getline _line < fname)) > 0)
		arr_out[++_i] = _line
	
	if (_code < 0)
		return _code
	
	close(fname)
	return _i
}

#
#@ Description: Clears 'arr_out', calls 'getline' and saves the lines
#@ read in 'arr_out'. If 'rx_until' is given, reading stops when a line
#@ matches 'rx_until'. The matched line is not saved. If 'rx_ignore' is
#@ given, only lines which do not match 'rx_ignore' are saved. If
#@ 'rx_until' and 'rx_ignore' are the same, only 'rx_until' is
#@ considered.
#@ Returns: The length of 'arr_out', or < 0 on error.
#
function read_lines(arr_out, rx_until, rx_ignore,    _line, _i,
_code) {

	delete arr_out
	_i = 0
	
	while ((_code = (getline _line)) > 0) {
		
		if (rx_until && match(_line, rx_until))
			break
		
		if (rx_ignore && match(_line, rx_ignore))
			continue
			
		arr_out[++_i] = _line
	}
	
	if (_code < 0)
		return _code
		
	return _i
}
#@ </awklib_read>
