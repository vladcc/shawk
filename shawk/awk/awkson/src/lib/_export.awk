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
	return map_get(_G_json_type_tbl, _xdotnot_parse(path))
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
	return map_get(_G_json_values_tbl, _xdotnot_parse(path))
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
		map_set(_G_json_values_tbl, path,
			_json_type_val_check(map_get(_G_json_type_tbl, path), val))
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
		map_set(_G_json_type_tbl, path, type)
		map_set(_G_json_values_tbl, path, val)
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
		map_set(_G_json_type_tbl, path, type)
		map_set(_G_json_values_tbl, path, val)
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
		map_set(_G_json_removed_set, path, 1)
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
