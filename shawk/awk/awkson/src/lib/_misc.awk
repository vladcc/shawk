# <misc>
function _pretty_pos(str, stop,    _ptr, _arr, _ch, _i) {
	
	split(str, _arr, "")
	
	for (_i = 1; _i < stop; ++_i) {
		_ch = _arr[_i]
		_ptr = (_ptr (_ch != "\t" ? " " : "\t"))
	}
		
	return (_ptr "^")
}
function _xdotnot_parse(str,    _ret) {
	_ret = dotnot_parse(str)
	if ("" == _ret) {
		error_quit(sprintf("fatal: dot notation: pos %d: %s\n%s\n%s",
			dotnot_get_error_pos(),
			dotnot_get_error_str(),
			str,
			_pretty_pos(str, dotnot_get_error_pos())))
	}
	return _ret
}
function _get_removed_re(    _n, _re) {

	_re = ""
	if (!map_is_empty(_G_json_removed_set)) {
		
		_re = "^("
		for (_n in _G_json_removed_set)
			_re = (_re _n "|")

		sub("\\|$", ")", _re)
	}
	return _re
}
# <program_flags>
function _set_fatal_error() {_B_fatal_error = 1}
function _get_fatal_error() {return _B_fatal_error}
function _set_file_name(fname) {_B_fname = fname}
function _get_file_name() {return _B_fname}
# </program_flags>
# </misc>
