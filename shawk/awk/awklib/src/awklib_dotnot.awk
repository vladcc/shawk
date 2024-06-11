#@ <awklib_dotnot>
#@ Library: dotnot
#@ Description: Dot notation parser. E.g. parses "foo.bar"."baz zig".zag into
#@ the three pieces "foo.bar" "baz zig" and zag. Quotes inside quoted strings
#@ can be escaped.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-10-24
#@

# <public>
#
#@ Description: Parses 'str', which is assumed to be a dot separated string,
#@ into an unambiguously representation, which can then be split into an array.
#@ E.g. "foo \" bar.baz".zig first parsed will then be split into
#@ "foo \" bar.baz" and zig.
#@ Returns: An unambiguous representation of its dot separated argument, ""
#@ if an error has occurred.
#
function dotnot_parse(str) {
	return _dotnot_parse(str)
}

#
#@ Description: Provides the error string if an error has happened during
#@ dotnot_parse().
#@ Returns: The error string, or "" if no error occurred.
#
function dotnot_get_error_str() {
	return _AWKLIB_dotnot__error_str
}

#
#@ Description: Provides the last error position.
#@ Returns: The position of the offending character in the string passed to
#@ dotnot_parse().
#
function dotnot_get_error_pos() {
	return _AWKLIB_dotnot__error_pos
}

#
#@ Description: Splits 'dotnot_parsed_str' into 'arr_out'.
#@ Returns: The length of 'arr_out'.
#
function dotnot_split(arr_out, dotnot_parsed_str) {
	return split(dotnot_parsed_str, arr_out, _DOTNOT_SEP())
}

#
#@ Description: Replaces the special separator in a parsed string with 'sep'. If
#@ 'sep' is not given, "." is used.
#@ Returns: A printable version of 'dotnot_parsed_str', give 'sep' is a
#@ printable character.
#
function dotnot_pretty(dotnot_parsed_str, sep) {
	if (!sep) sep = "."
	gsub(_DOTNOT_SEP(), sep, dotnot_parsed_str)
	return dotnot_parsed_str
}
# </public>

# <private>
function _DOTNOT_BEGIN() {return "begin"}
function _DOTNOT_STRING() {return "string"}
function _DOTNOT_PLAIN() {return "plain"}
function _DOTNOT_NEXT() {return "next"}
function _DOTNOT_SUCCESS() {return "success"}
function __DOTNOT_STATE() {return "state"}

function _DOTNOT_SEP() {return "\034"}
function _DOTNOT_EOS() {return "eos"}

function _DOTNOT_ERR_UNQ() {return "character should be quoted"}
function _DOTNOT_ERR_NOTSTR() {return "string or word expected"}
function _DOTNOT_ERR_NOCQ() {return "no closing quote"}
function _DOTNOT_ERR_BADSEP() {return "bad separator"}
function _DOTNOT_ERR_BUG() {return "unknown error; probably a bug"}

function _dotnot_get_state(_dotnot) {return _dotnot[__DOTNOT_STATE()]}
function _dotnot_set_state(_dotnot, next_st) {
	_dotnot[__DOTNOT_STATE()] = next_st
}

function _dotnot_cache_has(key) {return (key in _AWKLIB_dotnot__cache)}
function _dotnot_cache_get(key) {return _AWKLIB_dotnot__cache[key]}
function _dotnot_cache_place(key, val) {_AWKLIB_dotnot__cache[key] = val}

function _dotnot_set_error(str, pos) {
	_AWKLIB_dotnot__error_str = str
	_AWKLIB_dotnot__error_pos = pos
	return ""
}

function _dotnot_parse(str,    _dotnot, _st, _i, _end, _ch, _arr, _path, _seg) {

	if (_dotnot_cache_has(str))
		return _dotnot_cache_get(str)

	_dotnot_set_error("", 0)
	_dotnot_set_state(_dotnot, _DOTNOT_BEGIN())

	_end = split(str, _arr, "")
	_arr[++_end] = _DOTNOT_EOS()
	_path = ""

	for (_i = 1; _i <= _end; ++_i) {

		_ch = _arr[_i]
		_st = _dotnot_get_state(_dotnot)
		if (_DOTNOT_BEGIN() == _st) {
			_seg = ""

			if ("\"" == _ch) {

				# opening quote
				_seg = (_seg _ch)
				_dotnot_set_state(_dotnot, _DOTNOT_STRING())
			} else if ("." != _ch && _DOTNOT_EOS() != _ch) {

				# read a word; i.e. not a quoted string
				--_i
				_dotnot_set_state(_dotnot, _DOTNOT_PLAIN())
			} else {

				return _dotnot_set_error(_DOTNOT_ERR_NOTSTR(), _i)
			}
		}
		else if (_DOTNOT_STRING() == _st) {

			if ("\"" == _ch) {

				# a quote is read while inside a string
				if ("\\" != _arr[_i-1]) {

					# if it wasn't an escape, it closes the string
					_dotnot_set_state(_dotnot, _DOTNOT_NEXT())
				}
			} else if (_DOTNOT_EOS() == _ch) {

				# cannot end the input inside a quoted string
				return _dotnot_set_error(_DOTNOT_ERR_NOCQ(), _i)
			}

			_seg = (_seg _ch)
		}
		else if (_DOTNOT_PLAIN() == _st) {

			if (" " == _ch || "\t" == _ch || "\"" == _ch) {

				# cannot have spaces and quotes
				return _dotnot_set_error(_DOTNOT_ERR_UNQ(), _i)
			} else if ("." == _ch || _DOTNOT_EOS() == _ch) {

				--_i
				_dotnot_set_state(_dotnot, _DOTNOT_NEXT())
			} else {

				_seg = (_seg _ch)
			}
		}
		else if (_DOTNOT_NEXT() == _st) {

			# a path segment has been read successfully
			_path = (_path) ? (_path _DOTNOT_SEP() _seg) : _seg

			if (_DOTNOT_EOS() == _ch) {

				# success; here must be the only break statement
				_dotnot_set_state(_dotnot, _DOTNOT_SUCCESS())
				break
			} else if ("." == _ch) {

				# read another path segment
				_dotnot_set_state(_dotnot, _DOTNOT_BEGIN())
			} else {

				return _dotnot_set_error(_DOTNOT_ERR_BADSEP(), _i)
			}
		}
	}

	if (_dotnot_get_state(_dotnot) != _DOTNOT_SUCCESS())
		return _dotnot_set_error(_DOTNOT_ERR_BUG(), _i)

	_dotnot_cache_place(str, _path)
	return _path
}
# </private>
#@ </awklib_dotnot>
