# <check>
function check_warn_esc_tail_rec() {return _check_esc_tail_rec()}
function check_warn_reachability(    _set_reach) {
	_check_reach(_set_reach, st_lhs(1))
	return _check_reach_report(_set_reach)
}

function check_err_undefined() {return _check_undef()}
function check_err_left_factor() {return _check_lfact()}
function check_err_left_recursion() {return _check_lrec_all()}
function check_err_conflicts(    _err) {
	_err = 0
	_err = keep(sets_first_first_conflicts(),  _err)
	_err = keep(sets_first_follow_conflicts(), _err)
	return _err
}

# <private>
# <errors>
# <left-factor>
function _check_lfact_defn_err(lhs, defns) {
	err_fpos(lhs, sprintf("rules start with same symbol\n%s", defns))
}
function _check_lfact(    _i, _end, _lhs, _first, _key, _defn, _map, _ret) {
	_ret = 0
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_rule_lhs(_i)
		_first = st_rule_pos_name(_i, 1)
		_defn = sprintf("%s : %s", _lhs, st_rule_str(_i))
		_key = (_lhs "," _first)
		if (_key in _map)
			_map[_key] = (_map[_key] "\n" _defn)
		else
			_map[_key] = _defn
	}
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_rule_lhs(_i)
		_first = st_rule_pos_name(_i, 1)
		_key = (_lhs "," _first)
		if (index(_map[_key], "\n")) {
			_lhs = substr(_key, 1, index(_key, ",")-1)
			_check_lfact_defn_err(_lhs, _map[_key])
			_map[_key] = ""
			_ret = 1
		}
	}
	return _ret
}
# </left-factor>
# <left-recursion>
function _check_lrec_err(rule, path) {
	path = _check_lrec_path_pretty(path)
	err_fpos(rule, sprintf("left recursion\n%s", path))
}
# <data>
function _check_lrec_path_start() {return str_list_init()}
function _check_lrec_path_has(path, what) {return str_list_find(path, what)}
function _check_lrec_path_add(path, what) {return str_list_add(path, what)}
function _check_lrec_path_pretty(path) {return str_list_pretty(path, " -> ")}
# </data>
function _check_lrec_first(lhs_top, first, path) {
	if (st_name_is_nont(first)) {
		if (lhs_top == first) {
			_check_lrec_err(lhs_top, _check_lrec_path_add(path, first))
			return 1
		}
		if (!_check_lrec_path_has(path, first))
			return _check_lrec_next(lhs_top, first, path)
	}
	return 0
}
function _check_lrec_next(lhs_top, lhs_next, path,    _i, _end, _first, _ret) {
	_ret = 0
	path = _check_lrec_path_add(path, lhs_next)
	_end = st_lhs_rule_count(lhs_next)
	for (_i = 1; _i <= _end; ++_i) {
		_first = st_rule_pos_name(st_lhs_rule_id(lhs_next, _i), 1)
		_ret = keep(_check_lrec_first(lhs_top, _first, path), _ret)
	}
	return _ret
}
function _check_lrec_rule(lhs) {
	return _check_lrec_next(lhs, lhs, _check_lrec_path_start())
}
function _check_lrec_all(    _i, _end, _err) {
	_err = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_err = keep(_check_lrec_rule(st_lhs(_i)), _err)
	return _err
}
# </left-recursion>
# <undefined-rules>
function _check_undef_err(lhs, undef, defn) {
	err_fpos(lhs, sprintf("'%s' is undefined\n%s : %s", undef, lhs, defn))
}
function _check_undef(    _i, _ei, _j, _ej, _nm, _ret) {
	_ret = 0
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_ej = st_rule_pos_count(_i)
		for (_j = 1; _j <= _ej; ++_j) {
			_nm = st_rule_pos_name(_i, _j)
			if (st_name_is_nont(_nm) && !st_name_is_lhs(_nm)) {
				_check_undef_err(st_rule_lhs(_i), _nm, st_rule_str(_i))
				_ret = 1
			}
		}
	}
	return _ret
}
# </undefined-rules>
# </errors>

# <warnings>
# <reachability>
function _check_reach_warn(lhs) {warn_fpos(lhs, "unreachable")}
function _check_reach(set_out, lhs,    _i, _ei, _j, _ej, _rid) {
	if (!st_name_is_nont(lhs) || (lhs in set_out))
		return

	set_out[lhs]

	_ei = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _ei; ++_i) {
		_rid = st_lhs_rule_id(lhs, _i)
		_ej = st_rule_pos_count(_rid)
		for (_j = 1; _j <= _ej; ++_j)
			_check_reach(set_out, st_rule_pos_name(_rid, _j))
	}
}
function _check_reach_report(set_reach,    _i, _end, _lhs, _ret) {
	_ret = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		if (!(_lhs in set_reach)) {
			_check_reach_warn(_lhs)
			_ret = 1
		}
	}
	return _ret
}
# </reachability>
# <esc-after-tail-rec>
function _check_esc_tail_rec_warn(lhs, rstr,    _msg) {
	rstr = sprintf("%s : %s", lhs, rstr)
	_msg = sprintf("escapes after tail recursion are unreachable\n%s", rstr)
	warn_fpos(lhs, _msg)
}

function _check_esc_tail_rec(    _i, _end, _has_esc, _ret) {
	_ret = 0
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_has_esc = !!st_rule_pos_esc_count(_i, st_rule_pos_count(_i))
		if (st_rule_is_tail_rec(_i) && _has_esc) {
			_check_esc_tail_rec_warn(st_rule_lhs(_i), st_rule_str(_i))
			_ret = 1
		}
	}
	return _ret
}
# </esc-after-tail-rec>
# </warnings>
# </private>
# </check>
