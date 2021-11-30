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
	for (_n in _G_json_removed_set) {
		if (!_re)
			_re = "^("
		_re = (_re _n "|")
	}
	
	if (_re)
		sub("\\|$", ")", _re)
		
	return _re
}
# <program_flags>
function _set_fatal_error() {_B_fatal_error = 1}
function _get_fatal_error() {return _B_fatal_error}
function _set_file_name(fname) {_B_fname = fname}
function _get_file_name() {return _B_fname}
# </program_flags>
# </misc>
# <_json_to_str>
function _json_quote_str(str) {return ("\"" str "\"")}
function _json_print_string(str) {_json_obj_str_add(_json_quote_str(str))}
function _json_print_literal(val) {_json_obj_str_add(val)}
function _json_print_members(path, pftree, order, types, values,
    _i, _len, _arr, _members, _m) {

	_members = pft_get(pftree, path)
	if (_members) {
		_len = pft_split(_arr, _members)
		for (_i = 1; _i <= _len; ++_i) {
			_m = _arr[_i]

			_json_obj_str_add_tabs()
			_json_print_string(_m)
			_json_obj_str_add(" : ")
			
			_json_print_value(pft_cat(path, _m), pftree, order, types, values)
			if (_i != _len) {
				_json_obj_str_add(",")
				_json_obj_str_add_nl()
			}
		}
	}
}
function _json_print_object(path, pftree, order, types, values) {
	
	_json_obj_str_add("{")
	if (pft_get(pftree, path)) { # object has members?
		_json_obj_str_add_nl()
		_json_obj_str_inc_tabs()

		_json_print_members(path, pftree, order, types, values)

		_json_obj_str_dec_tabs()
		_json_obj_str_add_nl()
		_json_obj_str_add_tabs()
	}
	_json_obj_str_add("}")
}
function _json_print_values(path, pftree, order, types, values,
    _i, _len, _arr, _values, _v) {

	_values = pft_get(pftree, path)
	if (_values) {
		_len = pft_split(_arr, _values)
		for (_i = 1; _i <= _len; ++_i) {
			_v = _arr[_i]

			_json_obj_str_add_tabs()
			_json_print_value(pft_cat(path, _v), pftree, order, types, values)
				
			if (_i != _len) {
				_json_obj_str_add(",")
				_json_obj_str_add_nl()
			}
		}
	}
}
function _json_print_array(path, pftree, order, types, values) {
	_json_obj_str_add("[")

	if (pft_get(pftree, path)) { # array has values?
		_json_obj_str_add_nl()
		_json_obj_str_inc_tabs()

		_json_print_values(path, pftree, order, types, values)

		_json_obj_str_dec_tabs()
		_json_obj_str_add_nl()
		_json_obj_str_add_tabs()
	}
	_json_obj_str_add("]")
}
function _json_print_value(path, pftree, order, types, values) {

	_type = types[path]
	if (JT_OBJECT() == _type) {
		_json_print_object(path, pftree, order, types, values)
	} else if (JT_ARRAY() == _type) {
		_json_print_array(path, pftree, order, types, values)
	} else if (JT_STRING() == _type) {
		_json_print_string(values[path])
	} else if (JT_NUMBER() == _type || JT_BOOL() == _type) {
		_json_print_literal(values[path])
	} else if (JT_NULL() == _type) {
		# the actual internal value is JV_NULL() but add JT_NULL() in the string
		# so 'null' gets printed
		_json_print_literal(JT_NULL())
	} else {
		error_quit(sprintf("fatal: unknown type '%s'; probably a bug", _type))
	}
}
# <_json_obj_str>
function _json_obj_str_init() {_B_json_obj_str = ""}
function _json_obj_str_get() {return _B_json_obj_str}
function _json_obj_str_add(str) {_B_json_obj_str = (_B_json_obj_str str)}
function _json_obj_str_add_nl() {_json_obj_str_add("\n")}
function _json_obj_str_add_tabs() {_json_obj_str_add(_json_obj_str_get_tabs())}
function _json_obj_str_inc_tabs() {
	++_B_json_obj_str_tabs_num
	_B_json_obj_str_tabs = (_B_json_obj_str_tabs "\t")
}
function _json_obj_str_dec_tabs() {
	--_B_json_obj_str_tabs_num
	_B_json_obj_str_tabs = substr(_B_json_obj_str_tabs,
		1, _B_json_obj_str_tabs_num)
}
function _json_obj_str_get_tabs() {return _B_json_obj_str_tabs}
# </_json_obj_str>

function _json_to_str(path, pftree, order, types, values,    _type) {
	if (!pft_has(pftree, path))
		return ""
		
	_json_obj_str_init()
	_json_print_value(path, pftree, order, types, values)
	return _json_obj_str_get()
}
# </_json_to_str>
#@ <awklib_prefix_tree>
#@ Library: pft
#@ Description: A prefix tree implementation. E.g. conceptually, if you
#@ insert "this" and "that", you'd get:
#@ pft["t"] = "h"
#@ pft["th"] = "ia"
#@ pft["thi"] = "s"
#@ pft["this"] = ""
#@ pft["tha"] = "t"
#@ pft["that"] = ""
#@ However, all units must be separated by PFT_SEP(), so in this case
#@ "this" should be ("t" PFT_SEP() "h" PFT_SEP() "i" PFT_SEP() "s").
#@ Similar for "that". PFT_SEP() is a non-printable character. To make
#@ any key or value from a pft printable, use pft_pretty().
#@ Version: 1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-11-20
#@

# <public>
#@ Description: The prefix tree path delimiter.
#@ Returns: Some non-printable character.
#
function PFT_SEP() {

	return "\034"
}

#
#@ Description: Clears 'pft'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function pft_init(pft) {
	
	pft[""]
	delete pft
}

#
#@ Description: Inserts 'path' in 'pft'. 'path' has to be a PFT_SEP() delimited
#@ string.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_insert(pft, path,    _val, _len, _arr) {
# inserts "a.b.c", "a.x.y" backwards, so you get
# pft["a.b.c"] = ""
# pft["a.b"] = "c"
# pft["a"] = "b"
# pft["a.x.y"] = ""
# pft["a.x"] = "y"
# pft["a"] = "b.x"

	if (!path)
		return

	_pft_add(pft, path, _val)
	_len = pft_split(_arr, path)
	pft_insert(pft, pft_arr_to_pft_str(_arr, _len-1), _arr[_len])
}

#
#@ Description: If 'path' exists in 'pft', makes 'path' and all paths stemming
#@ from 'path' unreachable. 'path' has to be a PFT_SEP() delimited string.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_rm(pft, path,    _arr, _arr2, _i, _len, _last, _no_tail, _tmp) {
	
	if (pft_has(pft, path)) {
		
		delete pft[path]
		
		if ((_len = pft_split(_arr, path)) > 1) {
			
			_last = _arr[_len]
			_no_tail = pft_arr_to_pft_str(_arr, _len-1)
			
			_len = pft_split(_arr, pft[_no_tail])
			
			_tmp = 0
			for (_i = 1; _i <= _len; ++_i) {
				
				if (_arr[_i] != _last)
					_arr2[++_tmp] = _arr[_i]
			}
			
			pft[_no_tail] = pft_arr_to_pft_str(_arr2, _tmp)
		}
	}
}

#
#@ Description: Marks 'path' in 'pft', so pft_is_marked() will return
#@ 1 when asked about 'path'. The purpose of this is so also
#@ intermediate paths, and not only leaf nodes, can be considered during
#@ traversal. E.g. if you insert "this", "than", and "thank" in 'pft'
#@ and want to get these words out again, when you traverse only "this"
#@ and "thank" will be leaf nodes in the pft. Unless "than" is somehow
#@ marked, you will have no way to know "than" is actually a word, and
#@ not only an intermediate path to "thank", like "tha" would be.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function pft_mark(pft, path) {
	
	pft[(_PFT_MARK_SEP() path)]
}

#
#@ Description: Indicates if 'path' is marked in 'pft'.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(1)
#
function pft_is_marked(pft, path) {

	return ((_PFT_MARK_SEP() path) in pft)
}

#
#@ Description: Retrieves 'key' from 'pft'.
#@ Returns: pft[key] if 'key' exists in 'pft', the empty string
#@ otherwise. Use only if pft_has() has returned 1.
#@ Complexity: O(1)
#
function pft_get(pft, key) {

	return pft_has(pft, key) ? pft[key] : ""
}

#
#@ Description: Indicates whether 'key' exists in 'pft'.
#@ Returns: 1 if 'key' is found in 'pft', 0 otherwise.
#@ Complexity: O(1)
#
function pft_has(pft, key) {

	return (key in pft)
}

#
#@ Description: Splits 'pft_str' in 'arr' using PFT_SEP() as a
#@ separator. I.e. Splits what pft_get() returns.
#@ Returns: The length of 'arr'.
#@ Complexity: O(n)
#
function pft_split(arr, pft_str) {

	return split(pft_str, arr, PFT_SEP())
}


#
#@ Description: Splits 'pft_str', finds out if 'node' exists in 
#@ the array created by the split.
#@ Returns: 1 if 'node' is a path in 'pft_str', 0 otherwise.
#@ Complexity: O(n)
#
function pft_path_has(pft_str, node,    _i, _len, _arr) {

	_len = pft_split(_arr, pft_str)
	for (_i = 1; _i <= _len; ++_i) {
		if (_arr[_i] == node)
			return 1
	}
	return 0
}

#
#@ Description: Turns 'arr' into a PFT_SEP() delimited string.
#@ Returns: The pft string representation of 'arr'.
#@ Complexity: O(n)
#
function pft_arr_to_pft_str(arr, len,    _i, _str) {

	_str = ""
	for (_i = 1; _i < len; ++_i)
		_str = (_str arr[_i] PFT_SEP())
	if (_i == len)
		_str = (_str arr[_i])
	return _str
}

#
#@ Description: Delimits the strings 'a' and 'b' with PFT_SEP(). 
#@ Returns: If only b is empty, returns a. If only a is empty, returns
#@ b. If both are empty, returns the empty string. Returns
#@ (a PFT_SEP() b) otherwise.
#@ Complexity: O(awk-concatenation)
#
function pft_cat(a, b) {
	
	if (a && b) return (a PFT_SEP() b)
	if (!b) return a
	if (!a) return b
	return ""
}

#
#@ Description: Replaces all internal separators in 'pft_str' with
#@ 'sep'. If 'sep' is not given, "." is used.
#@ Returns: A printable representation of 'pft_str'.
#@ Complexity: O(n)
#
function pft_pretty(pft_str, sep) {

	gsub((PFT_SEP() "|" _PFT_MARK_SEP()), ((!sep) ? "." : sep), pft_str)
	return pft_str
}

#
#@ Description: Builds a string by performing a depth first search
#@ traversal of 'pft' starting from 'root'. The end result is all marked
#@ and leaf nodes subseparated by 'subsep' in their order of insertion
#@ separated by 'sep'. If 'sep' is not given, " " is used. If 'subsep'
#@ is not given, PFT_SEP() is removed from the node strings. E.g. for
#@ the words "this" and "that", if 'sep' is " -> "
#@ If 'subsep' is blank, the result shall be
#@ "this -> that"
#@ If 'subsep' is '-', the result shall be
#@ "t-h-i-s -> t-h-a-t" 
#@ 'sep' does not appear after the last element.
#@ Returns: A string representation 'pft'.
#@ Complexity: O(n)
#
function pft_to_str_dfs(pft, root, sep, subsep,    _arr, _i, _len, _str,
_tmp) {

	if (!pft_has(pft, root))
		return ""
	
	if (!(_get = pft_get(pft, root)))
		return root
		
	if (pft_is_marked(pft, root))
		_str = root
	
	if (!sep)
		sep = " "
	
	_tmp = ""
	_len = pft_split(_arr, _get)
	for (_i = 1; _i <= _len; ++_i) {
		
		if (_tmp = pft_to_str_dfs(pft, pft_cat(root, _arr[_i]),
			sep, subsep)) {
			_str = (_str) ? (_str sep _tmp) : _tmp
		}
	}

	gsub(PFT_SEP(), subsep, _str)
	return _str
}

#
#@ Description: Prints the string representation of 'pft' to stdout as
#@ returned by pft_to_str_dfs().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_print_dfs(pft, root, sep, subsep) {
	
	print pft_to_str_dfs(pft, root, sep, subsep)
}

#
#@ Description: Returns the dump of 'pft' as a single multi line string
#@ in the format "pft[<key>] = <val>" in no particular order. Marked
#@ nodes always begin with 'sep'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_str_dump(pft, sep,    _n, _str, _ret) {
		
	for (_n in pft) {
		_str = sprintf("pft[\"%s\"] = \"%s\"",
				pft_pretty(_n, sep), pft_pretty(pft[_n], sep))
		_ret = (_ret) ? (_ret "\n" _str) : _str
	}
	return _ret
}

#
#@ Description: Prints the dump of 'pft to stdout as returned by
#@ pft_str_dump().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function pft_print_dump(pft, sep) {
	
	print pft_str_dump(pft, sep)
}
# </public>

function _pft_add(pft, key, val,    _get) {

	if ((_get = pft_get(pft, key))) {
		if (val && !pft_path_has(_get, val)) {
			pft[key] = pft_cat(_get, val)
		}
	} else {
		pft[key] = val
	}
}

function _PFT_MARK_SEP() {return "mark\006"}
#@ </awklib_prefix_tree>
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
	return _B_dotnot_error_str
}

#
#@ Description: Provides the last error position.
#@ Returns: The position of the offending character in the string passed to
#@ dotnot_parse().
#
function dotnot_get_error_pos() {
	return _B_dotnot_error_pos
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

function _dotnot_cache_has(key) {return (key in _B_dotnot_cache)}
function _dotnot_cache_get(key) {return _B_dotnot_cache[key]}
function _dotnot_cache_place(key, val) {_B_dotnot_cache[key] = val}

function _dotnot_set_error(str, pos) {
	_B_dotnot_error_str = str
	_B_dotnot_error_pos = pos
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
#@ <awkson_json_api>
#@ Library: awkson json api
#@ Description: awkson user api
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-11-30
#@

# <public>
#
#@ Description: Represents the JSON root object.
#@ Returns: The string "r" used to address the top level JSON object.
#
function JSON_ROOT() {return "r"}

#
#@ Description: JL_*() represent the JSON types.
#@ Returns: String constants representing each type of object, e.g. "array"
#
function JT_OBJECT() {return "object"}
function JT_ARRAY() {return "array"}
function JT_STRING() {return "string"}
function JT_BOOL() {return "bool"}
function JT_NUMBER() {return "number"}
function JT_NULL() {return "null"}

#
#@ Description: JV_*() represent special values for objects which do not have a
#@ a scalar representation. E.g. an object will have the value "\{", an array
#@ the value "\[", and null "\0". These will be returned from json_get_val().
#@ None of them is a valid JSON string. They, in effect, encode the type of the
#@ object and can be used when serializing JSON to dot notation.
#@ Returns: String constants of placeholder values for non-single value objects.
#
function JV_OBJECT() {return "\\{"}
function JV_ARRAY() {return "\\["}
function JV_NULL() {return "\\0"}
# </json_constants>

#
#@ Description: Provides the current json file name.
#@ Returns: The current json file name.
#
function get_file_name() {return _get_file_name()}

#
#@ Description: Indicates whether the object specified by 'path' exists in the
#@ current JSON object. 'path' is a dot notation string.
#@ Returns: 1 if 'path' exists, 0 otherwise.
#
function json_has(path) {
	return pft_has(_G_the_pft, _xdotnot_parse(path))
}

#
#@ Description: Retrieves all paths from the parsed JSON in dot notation.
#@ Returns: The length of arr_out.
#
function json_get_paths(arr_out,    _i, _len, _ret, _re, _str) {
	
	_re = _get_removed_re()
	_ret = 0
	_len = vect_len(_G_input_order_keeper)
	
	if (_re) {

		for (_i = 1; _i <= _len; ++_i) {
			_str = _G_input_order_keeper[_i]
			if (!match(_str, _re))
				arr_out[++_ret] = dotnot_pretty(_str)
		}
	} else {

		for (_i = 1; _i <= _len; ++_i)
			arr_out[++_ret] = dotnot_pretty(_G_input_order_keeper[_i])
	}
	return _ret
}

#
#@ Description: Creates single line dot notation in the format "a.b.c = val" for
#@ 'path' and all reachable paths from 'path' within the JSON object. 'path' is
#@ a dot notation string.
#@ Returns: A complete dot representation of 'path', "" if 'path' does not
#@ exist.
#
function json_to_dot(path,    _arr_paths, _arr_match, _len, _i, _path, _val) {
	
	if (!json_has(path))
		return ""
	
	_len = json_get_paths(_arr_paths)
	_len = arr_match(_arr_match, _arr_paths, _len, ("^" path))
	
	for (_i = 1; _i <= _len; ++_i) {
		
		_path = _arr_match[_i]
		_val = json_get_val(_path)
		if (json_get_type(_path) == JT_STRING())
			_val = ("\"" _val "\"")
		
		_arr_match[_i] = (_path " = " _val)
	}
	
	return arr_to_str(_arr_match, _len, "\n")
}

#
#@ Description: Prints the complete dot representation of 'path'. 'path' is a
#@ dot notation string.
#@ Returns: Nothing.
#
function json_print_dot(path) {
	print json_to_dot(path)
}

#
#@ Description: Provides the text JSON representation of the object pointed to
#@ by 'path'. 'path' is a dot notation string.
#@ Returns: A string representing the object specified by 'path'.
#
function json_to_str(path) {
	return _json_to_str(_xdotnot_parse(path), _G_the_pft, _G_input_order_keeper,
		_G_json_type_tbl, _G_json_values_tbl)
}

#
#@ Description: Prints the objects pointed to by 'path'. 'path' is a dot
#@ notation string.
#@ Returns: Nothing.
#
function json_print(path) {
	print json_to_str(path)
}

#
#@ Description: Provides the type of the object specified by 'path', which is
#@ is one of the JT_*() constants. 'path' is a dot notation string.
#@ Returns: The type of 'path'.
#
function json_get_type(path) {
	return map_get_val(_G_json_type_tbl, _xdotnot_parse(path))
}

#
#@ Description: Provides the value of the object specified by 'path', which is
#@ the value itself for scalar types, and one of the JV_*() constants for
#@ compound types and for null. Note that if the value is a string, it appears
#@ without any surrounding quotes. json_get_val() provides better performance
#@ than json_to_str(), but it is also more rudimentary in that that it does not
#@ recurse on compound types.
#@ Returns: The value of 'path'.
#
function json_get_val(path) {
	return map_get_val(_G_json_values_tbl, _xdotnot_parse(path))
}

#
#@ Description: Sets the value of the object specified by 'path' to 'val' if the
#@ objects exists. A type/value check is performed for arrays, objects, bools,
#@ and null. If the type of 'path' is numeric, 'val' is interpreted as a number,
#@ i.e. 'val = (val+0)'. If the type of 'path' is none of the above, then it has
#@ to be of type string and 'val' is treated as a string literal. 'path' is a
#@ dot notation string.
#@ Returns: Nothing.
#
function json_set_val(path, val) {
	path = _xdotnot_parse(path)
	if (pft_has(_G_the_pft, path)) {
		map_add(_G_json_values_tbl, path,
			_json_type_val_check(map_get_val(_G_json_type_tbl, path), val))
	}
}

#
#@ Description: Sets the type of 'path' to 'type' and assigns 'val' as its
#@ value. If 'val' is not given, a default value is assigned like so:
#@ numbers get 0, strings get the empty string, bools get false, null gets null,
#@ all other get JV_*(). If 'val' is given, the same type/value check is
#@ performed as in json_set_val(). 'path' is a dot notation string.
#@ Returns: Nothing.
#
function json_set_type(path, type, val) {
	path = _xdotnot_parse(path)
	if (pft_has(_G_the_pft, path)) {
		_json_type_check(type)
		val = _json_type_val_get(type, val)
		map_add(_G_json_type_tbl, path, type)
		map_add(_G_json_values_tbl, path, val)
	}
}

#
#@ Description: Appends an object specified by 'path' of type 'type' to the
#@ parsed JSON if 'path' does not exist. The type/value rules are the same as in
#@ json_set_type(). 'path' is a dot notation string.
#@ Returns: Nothing.
#
function json_add(path, type, val) {
	path = _xdotnot_parse(path)
	if (!pft_has(_G_the_pft, path)) {
		_json_type_check(type)
		val = _json_type_val_get(type, val)
		pft_insert(_G_the_pft, path)
		map_add(_G_json_type_tbl, path, type)
		map_add(_G_json_values_tbl, path, val)
		vect_push(_G_input_order_keeper, path)
	}
}

#
#@ Description: Removes the object pointed to by 'path' from the parsed JSON.
#@ 'path' is a dot notation string.
#@ Returns: Nothing.
#
function json_rm(path) {
	path = _xdotnot_parse(path)
	if (pft_has(_G_the_pft, path)) {
		pft_rm(_G_the_pft, path)
		map_add(_G_json_removed_set, path, 1)
	}
}

#
#@ Description: Gets all immediate children of 'path'. 'path' is a dot notation
#@ string.
#@ Returns: The returned value is the number of children. Their names are in
#@ 'arr_out' starting from 1 if any children are found. If 'path' does not
#@ exist, 'arr_out' is unchanged.
#
function json_get_children(arr_out, path,    _len, _path) {
	_path = _xdotnot_parse(path)
	if (pft_has(_G_the_pft, _path)) {
		_len = pft_split(arr_out, pft_get(_G_the_pft, _path))
		arr_sub(arr_out, _len, "^", (path "."))
		return _len
	}
	return 0
}
# </public>

# <private>
function _json_type_check(type) {
	if (!_prs_usr_type_set_has(type))
		error_quit(sprintf("tried to set invalid type '%s'", type))
}
function _json_type_val_get(type, val) {
	return val = (val) ? \
			_json_type_val_check(type, val) : \
				_prs_usr_type_get_default_val(type)
}
function _json_type_val_check(type, val) {
	
	if ((JT_OBJECT() == type && JV_OBJECT() != val) || \
		(JT_ARRAY() == type && JV_ARRAY() != val) || \
		(JT_BOOL() == type && _TOK_FALSE() != val && _TOK_TRUE() != val) || \
		(JT_NULL() == type && _TOK_NULL() != val)) {
		
			error_quit(sprintf(\
				"tried to set value '%s' to an object of type '%s'", val, type))
	} else if (JT_NUMBER() == type) {
	
		return (val+0)
	}
	return val
}
# </private>
#@ </awkson_json_api>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling. Unlike
#@ other libraries, the function names for this library are not
#@ prepended.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	__LB_prog_program_name__ = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return __LB_prog_program_name__
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	__LB_prog_skip_end_flag__ = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	__LB_prog_skip_end_flag__ = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (__LB_prog_skip_end_flag__+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	__LB_prog_error_flag__ = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	__LB_prog_error_flag__ = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (__LB_prog_error_flag__+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {
	
	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
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
#@ <awklib_array>
#@ Library: arr
#@ Description: Array functionality.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function arr_init(arr) {

	arr[""]
	delete arr
}

#
#@ Description: Clears 'arr_dest', puts all keys of 'map' in 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_keys(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = _n
	return _i
}

#
#@ Description: Clears 'arr_dest', puts all values of 'map' in
#@ 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_vals(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = map[_n]
	return _i
}

#
#@ Description: Clears 'arr_dest' and copies the range defined by
#@ 'src_begin' and 'src_end' from 'arr_src' to 'arr_dest'. The range is
#@ inclusive. If 'src_begin' is larger than 'src_end', nothing is
#@ copied.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_range(arr_dest, arr_src, src_begin, src_end,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = src_begin; _i <= src_end; ++_i)
		arr_dest[++_n] = arr_src[_i]
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies 'arr_src' into 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_copy(arr_dest, arr_src, src_len) {

	return arr_range(arr_dest, arr_src, 1, src_len)
}

#
#@ Description: Appends 'arr_src' to the end of 'arr_dest'.
#@ Returns: The length of 'arr_dest' after appending.
#@ Complexity: O(n)
#
function arr_append(arr_dest, dest_len, arr_src, src_len,    _i) {

	for (_i = 1; _i <= src_len; ++_i)
		arr_dest[++dest_len] = arr_src[_i]
	return dest_len
}

#
#@ Description: Clears 'arr_dest', places all elements from 'arr_src'
#@ which are at indexes contained in 'arr_ind' in 'arr_dest'. E.g. given
#@ 'arr_ind[1] = 5; arr_ind[2] = 6', 'arr_dest' will get
#@ 'arr_dest[1] = arr_src[5]; arr_dest[2] = arr_src[6]'
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_gather(arr_dest, arr_src, arr_ind, ind_len,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= ind_len; ++_i)
		arr_dest[++_n] = arr_src[arr_ind[_i]]
	return _n
}

#
#@ Description: Finds the index of the first match for 'regex' in 'arr'.
#@ Returns: The index of the first match, 0 if not match is found.
#@ Complexity: O(n)
#
function arr_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all matches
#@ for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match_ind_all(arr_dest, arr_src, src_len, regex,    _i,
_n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which match
#@ 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Finds the index of the first non-match for 'regex' in
#@ 'arr'.
#@ Returns: The index of the first non-match, 0 if all match.
#@ Complexity: O(n)
#
function arr_dont_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (!match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all
#@ non-matches for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match_ind_all(arr_dest, arr_src, src_len, regex,
    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which do not
#@ match 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Calls 'sub()' for every element of 'arr' like
#@ 'sub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_sub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += sub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Calls gsub() for every element of 'arr' like
#@ 'gsub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_gsub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += gsub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Checks if 'arr_a' and 'arr_b' have the same elements.
#@ Returns: 1 if the arrays are equal, 0 otherwise.
#@ Complexity: O(n)
#
function arr_is_eq(arr_a, len_a, arr_b, len_b,    _i) {

	if (len_a != len_b)
		return 0
	for (_i = 1; _i <= len_a; ++_i) {
		if (arr_a[_i] != arr_b[_i])
			return 0
	}
	return 1
}

#
#@ Description: Finds 'val' in 'arr'.
#@ Returns: The index of 'val' if it's found, 0 otherwise.
#@ Complexity: O(n)
#
function arr_find(arr, len, val,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (arr[_i] == val)
			return _i
	}
	return 0
}

#
#@ Description: Concatenates all elements of 'arr' into a single string.
#@ The elements are separated by 'sep'. It 'sep' is not given, " " is
#@ used. 'sep' does not appear after the last element.
#@ Returns: The string representation of 'arr'.
#@ Complexity: O(n)
#
function arr_to_str(arr, len, sep,    _i, _str) {
	
	if (len < 1)
		return ""
	
	if (!sep)
		sep = " "
		
	_str = arr[1]
	for (_i = 2; _i <= len; ++_i)
		_str = (_str sep arr[_i])
	
	return _str
}

#
#@ Description: Prints 'arr' to stdout.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_print(arr, len, sep) {

	print arr_to_str(arr, len, sep)
}
#@ </awklib_array>
#@ <awklib_vect>
#@ Library: vect
#@ Description: Vector functionality. A vector is as array which is
#@ aware of its own size.
#@ Dependencies: awklib_array.awk
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'vect', initializes it with length 0.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_init(vect) {

	vect[""]
	delete vect
	vect[_VECT_LEN()] = 0
}

#
#@ Description: Initializes 'vect' to a copy of 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_init_arr(vect, arr, len,    _i) {
	
	vect_init(vect)
	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Appends 'val' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_push(vect, val) {

	vect[++vect[_VECT_LEN()]] = val
}

#
#@ Description: Appends 'arr' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_push_arr(vect, arr, len,    _i) {

	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Retrieves the last value from 'vect'.
#@ Returns: The last element.
#@ Complexity: O(1)
#
function vect_peek(vect) {

	return vect[vect[_VECT_LEN()]]
}

#
#@ Description: Removes the last element of 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_pop(vect) {

	vect[--vect[_VECT_LEN()]]
}

#
#@ Description: Provides the length.
#@ Returns: The length of 'vect'.
#@ Complexity: O(1)
#
function vect_len(vect) {
	
	return vect[_VECT_LEN()]
}

#
#@ Description: Indicates if 'vect' is empty or not.
#@ Returns: 1 if 'vect' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function vect_is_empty(vect) {

	return (!vect[_VECT_LEN()])
}

#
#@ Description: Removes the element in 'vect' at index 'ind' by moving
#@ all further elements one to the left.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_ind(vect, ind,    _i, _len) {
	
	_len = vect[_VECT_LEN()]
	for (_i = ind; _i < _len; ++_i)
		vect[_i] = vect[_i+1]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes 'val' from 'vect' by  if (arr_find())
#@ vect_del_ind().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_val(vect, val,    _ind) {
	
	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_del_ind(vect, _ind)
}

#
#@ Description: Removes the element at 'ind' from 'vect' by replacing it
#@ with the last element.
#@ Returns: Nothing
#@ Complexity: O(1)
#
function vect_swap_pop_ind(vect, ind) {
	
	vect[ind] = vect[vect[_VECT_LEN()]]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes the first instance of 'val' from 'vect' by
#@ if (arr_find()) vect_swap_pop_ind().
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_swap_pop_val(vect, val, _ind) {

	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_swap_pop_ind(vect, _ind)
}

function _VECT_LEN() {return "len"}
#@ </awklib_vect>
#@ <awklib_map>
#@ Library: map
#@ Description: Encapsulates map operations.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Clears 'map'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function map_init(map) {

	map[""]
	delete map
}

#
#@ Description: Does "map[key] = val". Overwrites existing values.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function map_add(map, key, val) {

	map[key] = val
}

#
#@ Description: Does "delete map[key]" if 'key' exists in 'map'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function map_del(map, key) {

	if (map_has_key(map, key))
		delete map[key]
}

#
#@ Description: Retrieves the value at index 'key' from 'map'.
#@ Returns: map[key] if 'key' exists in main, the empty string
#@ otherwise. Use map_has_key() first.
#@ Complexity: O(1)
#
function map_get_val(map, key) {

	return map_has_key(map, key) ? map[key] : ""
}


#
#@ Description: Retrieves the key for 'val' from 'map'.
#@ Returns: The string representing the key for 'val' in 'map', the
#@ empty string if 'val' is not found in 'map'. Use map_has_val() first.
#@ Complexity: O(n)
#
function map_get_key(map, val,    _n) {

	for (_n in map) {
		if (map[_n] == val)
			return _n
	}
	return ""
}

#
#@ Description: Indicates if 'key' exists in 'map'.
#@ Returns: 1 if 'key' exists in 'map', 0 otherwise.
#@ Complexity: O(1)
#
function map_has_key(map, key) {

	return (key in map)
}

#
#@ Description: Indicates whether 'val' exists in map.
#@ Returns: 1 if 'val' is a value in 'map', 0 otherwise.
#@ Complexity: O(n)
#
function map_has_val(map, val,    _n) {

	for (_n in map) {
		if (map[_n] == val)
			return 1
	}
	return 0
}

#
#@ Description: Counts the elements in 'map'.
#@ Returns: The number of elements in 'map'.
#@ Complexity: O(n)
#
function map_size(map,    _n, _i) {
	
	_i = 0
	for (_n in map)
		++_i
	return _i
}

#
#@ Description: Clears 'map_dest', copies 'map_src' into 'map_dest'.
#@ Returns: The number of elements copied.
#@ Complexity: O(n)
#
function map_copy(map_dest, map_src,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		map_dest[_n] = map_src[_n]
		++_i
	}
	return _i
}

#
#@ Description: Checks whether or not 'map_a' and 'map_b' have the same
#@ elements.
#@ Returns: 1 if 'map_a' is equal to 'map_b', 0 otherwise.
#@ Complexity: O(n)
#
function map_is_eq(map_a, map_b,    _n) {

	for (_n in map_a) {
		if (!(_n in map_b) || (map_a[_n] != map_b[_n]))
			return 0
	}
	for (_n in map_b) {
		if (!(_n in map_a))
			return 0
	}
	return 1
}

#
#@ Description: Inserts all elements from 'map_src' which do not exist
#@ in 'map_dest' (which are "new" to 'map_dest') into 'map_dest'.
#@ Returns: The number of elements inserted.
#@ Complexity: O(n)
#
function map_overlay_new(map_dest, map_src,    _n, _i) {

	_i = 0
	for (_n in map_src) {
		if (!(_n in map_dest)) {
			map_dest[_n] = map_src[_n]
			++_i;
		}
	}
	return _i
}

#
#@ Description: Inserts all elements from 'map_src' into 'map_dest'.
#@ Existing elements in 'map_dest' are overwritten.
#@ Returns: The number of elements inserted.
#@ Complexity: O(n)
#
function map_overlay_all(map_dest, map_src,    _n, _i) {

	_i = 0
	for (_n in map_src) {
		map_dest[_n] = map_src[_n]
		++_i
	}
	return _i
}

#
#@ Description: Clears 'map_dest', fills 'map_dest' with all elements
#@ from 'map_src' whose keys match 'regex'.
#@ Returns: The number of matches.
#@ Complexity: O(n)
#
function map_match_key(map_dest, map_src, regex,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		if (match(_n, regex)) {
			map_dest[_n] = map_src[_n]
			++_i
		}
	}
	return _i
}

#
#@ Description: Clears 'map_dest', fills 'map_dest' with all elements
#@ from 'map_src' whose keys do not match 'regex'.
#@ Returns: The number of non-matches.
#@ Complexity: O(n)
#
function map_dont_match_key(map_dest, map_src, regex,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		if (!match(_n, regex)) {
			map_dest[_n] = map_src[_n]
			++_i
		}
	}
	return _i
}

#
#@ Description: Clears 'map_dest', fills 'map_dest' with all elements
#@ from 'map_src' whose values match 'regex'.
#@ Returns: The number of matches.
#@ Complexity: O(n)
#
function map_match_val(map_dest, map_src, regex,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		if (match(map_src[_n], regex)) {
			map_dest[_n] = map_src[_n]
			++_i
		}
	}
	return _i
}

#
#@ Description: Clears 'map_dest', fills 'map_dest' with all elements
#@ from 'map_src' whose values do not match 'regex'.
#@ Returns: The number of non-matches.
#@ Complexity: O(n)
#
function map_dont_match_val(map_dest, map_src, regex,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		if (!match(map_src[_n], regex)) {
			map_dest[_n] = map_src[_n]
			++_i
		}
	}
	return _i
}

#
#@ Description: Clears 'map_dest', all values in 'map_src' become keys
#@ in 'map_dest', all keys in 'map_src' become values in 'map_dest'.
#@ If a value in 'map_src' repeats, its key does not overwrite the value
#@ in 'map_dest'. E.g.
#@ map_src["foo"] = "bar"
#@ map_src["baz"] = "bar"
#@ will result in
#@ map_dest["bar"] = "foo" 
#@ Returns: The number of elements inserted.
#@ Complexity: O(n)
#
function map_reverse_once(map_dest, map_src,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		if (!(map_src[_n] in map_dest)) {
			map_dest[map_src[_n]] = _n
			++_i
		}
	}
	return _i
}

#
#@ Description: Clears 'map_dest', all values in 'map_src' become keys
#@ in 'map_dest', all keys in 'map_src' become values in 'map_dest'.
#@ If a value in 'map_src' repeats, its key overwrites the value in
#@ 'map_dest'. E.g.
#@ map_src["foo"] = "bar"
#@ map_src["baz"] = "bar"
#@ will result in
#@ map_dest["bar"] = "baz" 
#@ Returns: The number of elements inserted.
#@ Complexity: O(n)
#
function map_reverse(map_dest, map_src,    _n, _i) {

	delete map_dest
	_i = 0
	for (_n in map_src) {
		map_dest[map_src[_n]] = _n
		++_i
	}
	return _i
}

#
#@ Description: Provides a multi line string representation of 'map'
#@ specified by 'fmt'. 'fmt' has include two '%s' - first for the key
#@ of the map, the second one for the corresponding value. All
#@ key-value pairs are concatenated together. If 'fmt' is not given,
#@ "%s %s\n" is used.
#@ Returns: The string representation of 'map'.
#@ Complexity: O(n)
#
function map_to_str(map, fmt,    _n, _str) {
	
	if (!fmt)
		fmt = "%s %s\n"
	
	_str = ""
	for (_n in map) {
		
		if (_str)
			_str = sprintf(("%s" fmt), _str, _n, map[_n])
		else
			_str = sprintf(fmt, _n, map[_n])
	}
	return _str
}

#
#@ Description: Prints the string representation of 'map' to stdout as
#@ returned by map_to_str(). Does not print a trailing new line.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function map_print(map, fmt) {

	printf("%s", map_to_str(map, fmt))
}
#@ </awklib_map>
