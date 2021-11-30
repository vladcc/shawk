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
