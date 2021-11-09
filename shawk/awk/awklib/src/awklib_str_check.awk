#@ <awklib_str_check>
#@ Library: sc
#@ Description: Check the number and content of fields in a string.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-10-02
#@

#
#@ Description: Splits 'str' using 'fsep' as a field separator, checks if the
#@ split string has exactly 'fnum' number of fields. If 'sc_re_map' is given,
#@ each field mapped in 'sc_re_map' is checked against the regex in the map for
#@ that field. If 'strict' is != 0, each field from 'str' must have a
#@ corresponding regex in 'sc_re_map'. 'fnum' defaults to 2 if not given, or <
#@ 1. If 'fsep' is not given, it defaults to FS. 'sc_re_map' must be first
#@ compiled by calling 'sc_re_prepare()'.
#@ Returns: "" on success, a string containing an error message otherwise.
#
function sc_check_str(str, fnum, fsep, sc_re_map, strict,    _arr, _len, _i) {
	
	if ((fnum+0) < 1)
		fnum = 2
	
	if (!fsep)
		fsep = FS
		
	_len = split(str, _arr, fsep)
	
	if (_len != fnum)
		return sprintf("%d fields expected, got %d", fnum, _len)

	if (_SC_MATCH() in sc_re_map) {

		for (_i = 1; _i <= _len; ++_i) {
			
			if (_i in sc_re_map) {
				
				if (!match(_arr[_i], sc_re_map[_i])) {
				
					return sprintf("field %d '%s' did not match '%s'",
						_i, _arr[_i], sc_re_map[_i])
				}
			} else if (strict) {
				
				return sprintf("strict: no regex for field %d", _i)
			}
		}
	}

	return ""
}

#
#@ Description: Clears 'sc_re_map_out', compiles a field number to regex map in
#@ 'sc_re_map_out' according to 'fnum' and 're_str'. 'fnum' is the max number of
#@ fields; defaults to 2 if not given, or < 1. 'rsep' separates the field-regex
#@ pairs; default is ';'. 'nsep' separates the field and its regex; defaults is
#@ '='. The syntax of 're_str' is as described by SC_SYNTAX(). For a short
#@ example: given 're_str' is '1=[0-9];2=[a-z]', upon return 'sc_re_map_out'
#@ will contain:
#@ 'sc_re_map_out[1] = "[0-9]"'
#@ 'sc_re_map_out[2] = "[a-z]"'
#@ Later, assuming 'sc_re_map_out' is passed to 'sc_check_str()', the 1 and 2
#@ field of the 'str' argument of 'sc_check_str()' will be matched against
#@ '[0-9]' and '[a-z]', respectively.
#@ Returns: "" on success, a string containing an error message otherwise.
#
function sc_re_prepare(sc_re_map_out, fnum, re_str, rsep, nsep,    _arr_re,
_len_arr_re, _i, _arr_num_re, _arr_range, _num_re, _num, _re, _j,
_l, _h) {
	
	delete sc_re_map_out
	
	if (re_str) {

		if ((fnum+0) < 1)
			fnum = 2

		if (!nsep)
			nsep = "="
			
		if (!rsep)
			rsep = ";"
		
		sc_re_map_out[_SC_MATCH()] = 1

		_len_arr_re = split(re_str, _arr_re, rsep)
		for (_i = 1; _i <= _len_arr_re; ++_i) {
		
			_num_re = _arr_re[_i]
			if (2 == split(_num_re, _arr_num_re, nsep) && \
				_arr_num_re[1] && _arr_num_re[2]) {
				
				_num = _arr_num_re[1]
				_re = _arr_num_re[2]
				if ("*" == _num) {
				
					for (_j = 1; _j <= fnum; ++_j)
						sc_re_map_out[_j] = _re
				} else if (match(_num, "^[[:digit:]]+-[[:digit:]]+$")) {
					
					split(_num, _arr_range, "-")
					_l = _arr_range[1]+0
					_h = _arr_range[2]+0
					
					if (_l < _h) {
						
						for (_j = _l; _j <= _h; ++_j) {
							
							if (_j < 1 || _j > fnum)
								return _sc_eor(_num_re, _j)
								
							sc_re_map_out[_j] = _re
						}
					} else {
					
						return sprintf("'%s': bad range '%s'; "\
							"first should be < second", _num_re, _num)
					}
				} else if (match(_num, "^([[:digit:]]+,)+[[:digit:]]+$")) {
					
					_h = split(_num, _arr_range, ",")
					for (_j = 1; _j <= _h; ++_j) {
						
						_l = _arr_range[_j]
						if (_l < 1 || _l > fnum)
							return _sc_eor(_num_re, _l)
						
							sc_re_map_out[_l] = _re
					}
					
				} else if (match(_num, "^[[:digit:]]+$")) {
					
					_num += 0
					if (_num >= 1 && _num <= fnum) {
					
						sc_re_map_out[_num] = _re
					} else {
					
						return _sc_eor(_num_re, _num)
					}
				} else {
				
					return \
					sprintf(\
					"'%s' must be '*', a number > 0, csv, or a range",
					_num)
				}
				
			} else {
			
				return sprintf("'%s': "\
				 "syntax should be '<*|num|csv|range><nsep><regex>'", _num_re)
			}
		}
	}
	
	return ""
}

#
#@ Description: Provides a help message.
#@ Returns: A string describing the filed-to-regex mapping syntax.
#
function SC_SYNTAX() {
	return \
"<*|num|csv|range><nsep><regex>[<rsep><*|num|csv|range><nsep><regex>...]\n"\
"'*' means 'all fields'. By default, 'nsep' is '=', and 'rsep' is ';'.\n"\
"Latter expressions overwrite earlier ones. E.g. given 7 fields and:\n"\
"'*=[0-9];1=[a-z];2,6=[A-Z];3-5=[.]', field 1 will be matched to '[a-z]',\n"\
"fields 2 and 6 to '[A-Z]', fields 3, 4, and 5 to '[.]', field 7 to '[0-9]'"
}

function _sc_eor(nr, n) {
	return sprintf("'%s': field id '%s' out of range", nr, n)
}
function _SC_MATCH() {return "match"}
#@ </awklib_str_check>
