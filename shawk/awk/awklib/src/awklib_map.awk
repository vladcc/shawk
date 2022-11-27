#@ <awklib_map>
#@ Library: map
#@ Description: Encapsulates map operations.
#@ Version: 2.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2022-11-27
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
function map_set(map, key, val) {

	map[key] = val
}

#
#@ Description: Sets the values for all keys in 'map' to 'val'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function map_set_vals_to(map, val,    _n) {

	for (_n in map)
		map[_n] = val
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
function map_get(map, key) {

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
#@ Description: Indicates if 'map' has any members.
#@ Returns: 1 if 'map' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function map_is_empty(map,    _n) {

	for (_n in map)
		return 0
	return 1
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
