# <check>
function perform_input_checks(tree) {
	if (opt_strict_get())
		check_undefined_rules(tree)
	check_reachability(tree)
	check_left_recursion(tree)
}
# <check_left_recursion>
function left_rec_seen_reset() {_B_left_rec_set[""]; delete _B_left_rec_set}
function left_rec_was_seen(symb) {return (symb in _B_left_rec_set)}
function left_rec_mark(symb) {_B_left_rec_set[symb]}
function check_left_rec_rule(tree, rule,    _next, _path, _val, _arr, _len, _i,
_trace) {

	if (!_next) {
		# first time; reset symbols, start from rule
		left_rec_seen_reset()
		_next = rule
	}

	if (!rdpg_pft_has(tree, _next)) {
		# guard against non-existent rule
		return ""
	}

	if (left_rec_was_seen(_next)) {
		# _next has already been considered and did not result in an error
		return ""
	} else {
		# _next has not been considered, needs a check
		left_rec_mark(_next)
	}

	if (!_path) {
		# first time; begin the trace path with the top rule
		_path = _next
	} else {
		# not first time; add _next to the trace path
		_path = sprintf("%s -> %s", _path, _next)
	}

	_val = rdpg_pft_get(tree, _next)
	_len = rdpg_pft_split(_val, _arr)

	if (rdpg_pft_arr_has(_arr, _len, rule)) {
		# if the top rule exists in any of its own leftmost derivations, or
		# in any of the leftmost derivations of its leftmost derivations
		# return the trace
		return sprintf("%s -> %s", _path, rule)
	}

	for (_i = 1; _i <= _len; ++_i) {
		if (_trace = check_left_rec_rule(tree, rule, _arr[_i], _path)) {
			# if a non-empty trace has occurred, we have leftmost recursion
			return _trace
		}
	}
}
function print_left_rec(rule, trace) {
	chk_err_fpos(rule_line_map_get(rule), rule,
		sprintf("left recursion: %s", trace))
}
function check_left_recursion(tree,    _rule, _i, _end, _trace, _err) {
	_err = 0
	_end = rule_get_count()

	for (_i = 1; _i <= _end; ++_i) {
		_rule = rule_get(_i)

		if (_trace = check_left_rec_rule(tree, _rule)) {
			_err = 1
			print_left_rec(_rule, _trace)
		}
	}

	if (_err)
		exit_failure()
}
# </check_left_recursion>

# <check_reachability>
function reachability_error(rule, root, path,    _line) {
	_line = rule_line_map_get(rule)

	chk_err_fpos(_line, rule, "ambiguity detected; cannot factor out")

	gsub(("\\" RDPG_PFT_SEP()), " -> ", root)
	pstderr(sprintf("'%s'", root))
	gsub(("\\" RDPG_PFT_SEP()), " -> ", path)
	pstderr(sprintf("'%s'", path))
}

function check_reachability_rule(tree, rule, _root,    _val, _path, _err, _i,
_len, _arr) {

	#
	# Endpoints must have no further productions; e.g. in grammar
	# rule a
	# defn b
	# defn b c
	# end
	#
	# the prefix tree is:
	#
	# pft["a.b"] = "c"
	# pft["a.b.c"] = ""
	# pft[".a.b.c"] = ""
	# pft["a"] = "b"
	# pft[".a.b"] = ""
	#
	# a -> b is an endpoint as indicated by
	# pft[".a.b"] = ""
	# but
	# pft["a.b"] = "c"
	#

	if (!_root)
		_root = rule

	if (!_err)
		_err = 0

	if (!rdpg_pft_has(tree, _root))
		return

	_val = rdpg_pft_get(tree, _root)
	_len = rdpg_pft_split(_val, _arr)

	for (_i = 1; _i <= _len; ++_i) {
		_path = rdpg_pft_cat(_root, _arr[_i])

		if (_val && rdpg_pft_is_endpoint(tree, _root)) {
			reachability_error(rule, _root, _path)
			++_err
		}

		_err += check_reachability_rule(tree, rule, _path)
	}

	return _err
}

function check_reachability(tree,    _rule, _i, _end, _err) {
	_err = 0
	_end = rule_get_count()

	for (_i = 1; _i <= _end; ++_i) {
		_rule = rule_get(_i)
		_err = check_reachability_rule(tree, _rule)
	}

	if (_err)
		exit_failure()
}
# </check_reachability>

# <check_undefined_rules>
function check_undefined_rule(tree, rule,    _root, _i, _val, _arr_val,
_len_val, _symb, _err) {

	if (!_err)
		_err = 0

	if (!_root)
		_root = rule

	if (!rdpg_pft_has(tree, _root))
		return 0

	_val = rdpg_pft_get(tree, _root)
	_len_val = rdpg_pft_split(_val, _arr_val)

	for (_i = 1; _i <= _len_val; ++_i) {
		_symb = _arr_val[_i]

		if (!is_terminal(_symb) && !is_a_rule(_symb)) {
			chk_err_fpos(rule_line_map_get(rule), rule,
				sprintf("call to an undefined rule '%s'", _symb))
			_err = 1
		}

		_err += check_undefined_rule(tree, rule, rdpg_pft_cat(_root, _symb))
	}

	return _err
}

function chk_err_fpos(line, rule, msg) {
	error_print(sprintf("file '%s', line %d, rule '%s': %s",
		FILENAME, line, rule, msg))
}

function check_undefined_rules(tree,    _rule, _i, _end, _err) {
	_err = 0
	_end = rule_get_count()

	for (_i = 1; _i <= _end; ++_i) {
		_rule = rule_get(_i)
		_err += check_undefined_rule(tree, _rule)
	}

	if (_err)
		exit_failure()
}
# </check_undefined_rules>
# </check>
