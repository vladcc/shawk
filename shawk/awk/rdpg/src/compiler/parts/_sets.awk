# <first-follow-predict>

function sets_init() {
	_sets_first()
	_sets_follow()
	_sets_predict()
	_sets_expect()
}

function sets_print() {
	_sets_print_first()
	_sets_print_follow()
	_sets_print_predict()
	_sets_print_expect()
}

function sets_first(name, out_set_len,    _sset) {
	delete out_set_len
	_sset = _sets_fst_get(name)
	out_set_len[1] = _sets_set_pretty(_sset)
	out_set_len[2] = str_set_count(_sset)
}

function sets_follow(name, out_set_len,    _sset) {
	delete out_set_len
	_sset = _sets_flw_get(name)
	out_set_len[1] = _sets_set_pretty(_sset)
	out_set_len[2] = str_set_count(_sset)
}

function sets_first_first_conflicts() {return _sets_fsfs_conf_all()}
function sets_first_follow_conflicts() {return _sets_fsfwl_conf_all()}

function sets_pred_size(name)    {return _sets_pred_size(name)}
function sets_pred_at(name, pos) {return _sets_pred_at(name, pos)}
function sets_pred_pretty(name)  {return _sets_pred_get_pretty(name)}

function sets_exp_size(name)   {return _sets_exp_size(name)}
function sets_exp_pretty(name) {return _sets_exp_get_pretty(name)}

function sets_flw_customize() {
	# Mutate the sets according to the sync option.
	_sets_flw_customize()
}
function sets_flw_size(name)   {return _sets_flw_size(name)}
function sets_flw_pretty(name) {return _sets_flw_get_pretty(name)}

# <private>
function _sets_print_first()   {_sets_fst_print()}
function _sets_print_follow()  {_sets_flw_print()}
function _sets_print_predict() {_sets_pred_print()}
function _sets_print_expect()  {_sets_exp_print()}

function _sets_dbg_print() {
	print "Firt sets:"
	_sets_fst_dbg_print()
	print ""
	print "Follow sets:"
	_sets_flw_dbg_print()
	print ""
	print "Predict:"
	_sets_pred_dbg_print()
}

function _SETS_EPS() {return "0"}
function _SETS_EOI() {return "$"}

# <sets>
# <data>
function _sets_set_init(set_tbl,    _i, _end) {
	set_tbl[""]
	delete set_tbl
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i)
		set_tbl[st_name(_i)] = str_set_init()
}
function _sets_set_size(set_tbl, name) {
	return str_set_count(_sets_set_get(set_tbl, name))
}
function _sets_set_at(set_tbl, name, pos) {
	return str_set_get(_sets_set_get(set_tbl, name), pos)
}
function _sets_set_has(set_tbl, name, sym) {
	return !!str_set_find(_sets_set_get(set_tbl, name), sym)
}
function _sets_set_add(set_tbl, name, sym,    _sset, _ret) {
	_ret = 0
	if (_sset = _sets_set_get(set_tbl, name)) {
		if (!str_set_find(_sset, sym)) {
			set_tbl[name] = str_set_add(_sset, sym)
			_ret = 1
		}
	}
	return _ret
}
function _sets_set_rm_name(set_tbl, n) {delete set_tbl[n]}
function _sets_set_make_empty(set_tbl, n) {set_tbl[n] = str_set_init()}
function _sets_set_union_no_eps(set_tbl, name, sset) {
	sset = str_set_del(sset, _SETS_EPS())
	return _sets_set_union(set_tbl, name, sset)
}
function _sets_set_union(set_tbl, name, sset,    _ssnm, _ssun, _ret) {
	_ret = 0
	if (_ssnm = _sets_set_get(set_tbl, name)) {
		_ssun = str_set_union(_ssnm, sset)
		if (!str_set_is_eq(_ssnm, _ssun)) {
			set_tbl[name] = _ssun
			_ret = 1
		}
	}
	return _ret
}
function _sets_set_get(set_tbl, n) {
	return (n in set_tbl) ? set_tbl[n] : str_set_init()
}
function _sets_set_has_name(set_tbl, n) {
	return (n in set_tbl)
}
function _sets_set_get_pretty(set_tbl, n,    _sset) {
	return _sets_set_pretty(_sets_set_get(set_tbl, n))
}
function _sets_set_dbg_print(set_tbl,    _n) {
	for (_n in set_tbl) {
		print sprintf("%s = %s", _n, \
			str_set_make_printable(_sets_set_get(set_tbl, _n)))
	}
}
function _sets_set_pretty(sset) {return str_list_pretty(sset)}
function _sets_set_print(set_tbl, pref,    _i, _ei, _j, _ej, _nm, _rid, _lhs) {
	pref = ("set " pref)
	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		_sets_nont_print(set_tbl, _lhs, pref)
		_rid = st_lhs_rule_id(_lhs, _i)

		_ej = st_lhs_rule_count(_lhs)
		for (_j = 1; _j <= _ej; ++_j) {
			_nm = st_rule_name(st_lhs_rule_id(_lhs, _j))
			_sets_nont_print(set_tbl, _nm, pref)
		}
	}
}
function _sets_nont_print(set_tbl, name, pref,    _sset, _str) {
	if (name in set_tbl) {
		_sset = _sets_set_get(set_tbl, name)
		if (!str_set_is_empty(_sset)) {
			_str = _sets_set_pretty(_sset)
			print sprintf("%s %s %s", pref, name, _str)
		}
	}
}
# </data>
# </sets>

# <first-sets>
# <data>
function _sets_fst_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_fst_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		if (st_name_is_term(_sym))
			_sets_set_add(_B_sets_fst_tbl, _sym, _sym)
		else if (st_name_can_null(_sym))
			_sets_set_add(_B_sets_fst_tbl, _sym, _SETS_EPS())
	}
}
function _sets_fst_has(name, sym) {
	return _sets_set_has(_B_sets_fst_tbl, name, sym)
}
function _sets_fst_add(name, sym) {
	return _sets_set_add(_B_sets_fst_tbl, name, sym)
}
function _sets_fst_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_fst_tbl, name, _sets_fst_get(sym))
}
function _sets_fst_get(name) {return _sets_set_get(_B_sets_fst_tbl, name)}
function _sets_fst_print() {_sets_set_print(_B_sets_fst_tbl, "first")}
function _sets_fst_dbg_print() {_sets_set_dbg_print(_B_sets_fst_tbl)}
# </data>

# <process>
function _sets_first_rule(rid,    _i, _end, _rnm, _lhs, _sym, _chg) {
	# Preconditions:
	# 1. Any rule x : 0 has been marked as can_null.
	# 2. The lhs for that rule has also been marked as can_null.
	# 3. eps has already been added to the first sets for the rule and the lhs.
	#
	# 'Any rule' from pt. 1 refers to the rule name; e.g.
	#
	# x : foo ; has the name of x_1 (first rule for lhs x)
	# x : 0   ; has the name of x_2 (second rule for lhs x)
	#
	# 'lhs' from pt. 2 refers to the left hand side of the rule; e.g.
	#
	# x : foo ; lhs is x
	#
	# After parsing the above two rules, st_name_can_null(x) and
	# st_name_can_null(x_1) must both return true. After the first sets init
	# procedure first(x) and first(x_1) must be {eps}, first(T) must be {T} for
	# any terminal T.
	#
	# Rule names are treated as non-terminals; we need sets per rule to detect
	# conflicts and generate each rule's predict set.

	_chg = 0
	if (!st_rule_is_zero(rid)) {
		# Only consider rules *not* of the form x : 0
		_rnm = st_rule_name(rid)
		_end = st_rule_pos_count(rid)
		for (_i = 1; _i <= _end; ++_i) {
			_sym = st_rule_pos_name(rid, _i)

			# Union the rule's first set with the current symbol's first set
			# excluding eps.
			_chg = keep(_sets_fst_union_no_eps(_rnm, _sym), _chg)

			# If the current symbol's first set has no eps, it's either a
			# terminal or a non-nullable non-terminal. We have found the rule's
			# first set.
			if (!_sets_fst_has(_sym, _SETS_EPS()))
				break
		}
		_lhs = st_rule_lhs(rid)

		# The first set for an lhs is the union of the first sets of all its
		# rules; e.g. first(x) = first(x_1) U first(x_2)
		_chg = keep(_sets_fst_union_no_eps(_lhs, _rnm), _chg)
		if (_i > _end) {
			# (_i > _end) means we did not encounter a symbol which was not
			# nullable, therefore we did not break out of the loop but exited
			# out of the loop when (_i <= _end) failed. I.e. the whole right
			# hand side for the rule can derive eps, which means we need to
			# add eps to the first(rule) and the firs(its lhs) by extension.
			_chg = keep(_sets_fst_add(_rnm, _SETS_EPS()), _chg)
			st_name_mark_can_null(_rnm)
			_chg = keep(_sets_fst_add(_lhs, _SETS_EPS()), _chg)
			st_name_mark_can_null(_lhs)
		}
	}

	# If at any point any set operation changed the target set, _chg will be 1.
	return _chg
}
function _sets_first(    _i, _end, _chg) {
	_sets_fst_init()
	_end = st_rule_count()
	do {
		_chg = 0
		for (_i = 1; _i <= _end; ++_i)
			_chg = keep(_sets_first_rule(_i), _chg)
	} while (_chg)
}
# </process>
# </first-sets>

# <follow-sets>
# <data>
function _sets_flw_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_flw_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Terminals have no follow sets, rule names never appear on the right.
		if (st_name_is_term(_sym) || st_name_is_rule(_sym))
			_sets_set_rm_name(_B_sets_flw_tbl, _sym)
	}
	_sets_set_add(_B_sets_flw_tbl, st_lhs(1), _SETS_EOI())
}
function _sets_flw_add(name, sym) {
	return _sets_set_add(_B_sets_flw_tbl, name, sym)
}
function _sets_flw_has(name, sym) {
	return _sets_set_has(_B_sets_flw_tbl, name, sym)
}
function _sets_flw_has_name(name) {
	return _sets_set_has_name(_B_sets_flw_tbl, name)
}
function _sets_flw_make_empty(name) {
	_sets_set_make_empty(_B_sets_flw_tbl, name)
}
function _sets_flw_first_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_flw_tbl, name, _sets_fst_get(sym))
}
function _sets_flw_follow_union(name, sym) {
	return _sets_set_union(_B_sets_flw_tbl, name, _sets_flw_get(sym))
}
function _sets_flw_get(name) {return _sets_set_get(_B_sets_flw_tbl, name)}
function _sets_flw_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_flw_tbl, name)
}
function _sets_flw_size(name) {
	return _sets_set_size(_B_sets_flw_tbl, name)
}
function _sets_flw_print() {_sets_set_print(_B_sets_flw_tbl, "follow")}
function _sets_flw_dbg_print() {_sets_set_dbg_print(_B_sets_flw_tbl)}
# </data>

# <process>
function _sets_follow_rule(rid,    _i, _j, _end, _lhs, _sym, _next, _chg) {
	# Preconditions:
	# 1. The first sets have been calculated.
	# 2. The follow set of the start symbol is {eoi}.
	# Follow sets are calculated only for actual non-terminals, i.e. rule names
	# are not considered since they never appear on the right.

	_chg = 0
	_lhs = st_rule_lhs(rid)
	_end = st_rule_pos_count(rid)
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_rule_pos_name(rid, _i)

		# No follow set for terminals.
		if (st_name_is_term(_sym))
			continue

		# If the current non-terminal is the last symbol on the right hand side
		# of the rule, it can be followed by whatever the left hand side can be
		# followed by.
		if (_i == _end) {
			_chg = keep(_sets_flw_follow_union(_sym, _lhs), _chg)
			break
		}

		# For all symbols to the right of the current symbol in the current rule
		for (_j = _i+1; _j <= _end; ++_j) {
			_next = st_rule_pos_name(rid, _j)

			# follow(current) = follow(current) U first(next) ...
			_chg = keep(_sets_flw_first_union_no_eps(_sym, _next), _chg)

			# If the next symbol is a terminal, or a non-nullable non-terminal,
			# we are done with follow(current).
			if (st_name_is_term(_next) || !_sets_fst_has(_next, _SETS_EPS()))
				break
		}
		if (_j > _end) {
			# (_j > _end) is true if we did not see a terminal, nor a
			# non-nullable non-terminal, i.e. all symbols on the right of the
			# current one can derive eps. In that case whatever can follow the
			# lhs can follow the current symbol.
			_chg = keep(_sets_flw_follow_union(_sym, _lhs), _chg)
		}
	}

	# If at any point any set operation changed the target set, _chg will be 1.
	return _chg
}
function _sets_follow(    _i, _end, _chg) {
	_sets_flw_init()
	_end = st_rule_count()
	do {
		_chg = 0
		for (_i = 1; _i <= _end; ++_i)
			_chg = keep(_sets_follow_rule(_i), _chg)
	} while (_chg)
}

# <customize>
function _sets_flw_cst_errq(msg) {
	error_quit(sprintf("sync: %s", msg))
}
function _sets_flw_cst_nont(nont,    _i, _end, _term) {
	_end = sync_term_count(nont)
	for (_i = 1; _i <= _end; ++_i) {
		_term = sync_term(nont, _i)
		if (!st_name_is_term(_term))
			_sets_flw_cst_errq(sprintf("'%s' not a terminal", _term))
		if (!_sets_flw_has(nont, _term)) {
			_sets_flw_cst_errq(sprintf("'%s' not in the follow set for '%s'", \
				_term, nont))
		}
	}

	# Rebuild set with only the specified tokens
	_sets_flw_make_empty(nont)
	for (_i = 1; _i <= _end; ++_i)
		_sets_flw_add(nont, sync_term(nont, _i))
}
function _sets_flw_customize(    _i, _end, _nont) {
	if (sync_type() == SYNC_DEFAULT()) {
		# Do nothing.
		return
	} else if (sync_type() == SYNC_CUSTOM()) {
		_end = sync_nont_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = sync_nont(_i)
			if (!st_name_is_lhs(_nont)) {
				_sets_flw_cst_errq(sprintf("'%s' not a lhs to be synced", \
					_nont))
			}
			if (!_sets_flw_has_name(_nont)) {
				_sets_flw_cst_errq(sprintf("'%s' cannot be synced", _nont))
			}
			_sets_flw_cst_nont(_nont)
		}

		# Empty all follow sets except the ones specified.
		_end = st_lhs_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = st_lhs(_i)
			if (_sets_flw_has_name(_nont) && !sync_has_nont(_nont))
				_sets_flw_make_empty(_nont)
		}
	} else if (sync_type() == SYNC_NONE()) {
		# Empty all follow sets.
		_end = st_lhs_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = st_lhs(_i)
			if (_sets_flw_has_name(_nont))
				_sets_flw_make_empty(_nont)
		}
	}
}
# </customize>
# </process>
# </follow-sets>

# <predict-sets>
# <data>
function _sets_pred_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_predict_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Leave only rule names.
		if (!st_name_is_rule(_sym))
			_sets_set_rm_name(_B_sets_predict_tbl, _sym)
	}
}
function _sets_pred_size(name) {
	return _sets_set_size(_B_sets_predict_tbl, name)
}
function _sets_pred_at(name, pos) {
	return _sets_set_at(_B_sets_predict_tbl, name, pos)
}
function _sets_pred_first_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_predict_tbl, name, _sets_fst_get(sym))
}
function _sets_pred_follow_union(name, sym) {
	return _sets_set_union(_B_sets_predict_tbl, name, _sets_flw_get(sym))
}
function _sets_pred_get(name) {return _sets_set_get(_B_sets_predict_tbl, name)}
function _sets_pred_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_predict_tbl, name)
}
function _sets_pred_print() {_sets_set_print(_B_sets_predict_tbl, "predict")}
function _sets_pred_dbg_print() {_sets_set_dbg_print(_B_sets_predict_tbl)}
# </data>

# <process>
function _sets_predict_rule(rid,    _rnm) {
	# Preconditions:
	# 1. The follow sets have been calculated.

	_rnm = st_rule_name(rid)
	# The predict set for the rule is first(rule). If the rule can derive eps,
	# then follow(lhs) is also in predict(rule) because anything in follow(lhs)
	# may appear if the rule "produces" the empty string.
	_sets_pred_first_union_no_eps(_rnm, _rnm)
	if (_sets_fst_has(_rnm, _SETS_EPS()))
		_sets_pred_follow_union(_rnm, st_rule_lhs(rid))
}
function _sets_predict(    _i, _end) {
	_sets_pred_init()
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_sets_predict_rule(_i)
}
# </process>
# </predict-sets>

# <expect-sets>
# <data>
function _sets_exp_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_expect_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Leave only lhs.
		if (!st_name_is_lhs(_sym))
			_sets_set_rm_name(_B_sets_expect_tbl, _sym)
	}
}
function _sets_exp_predict_union(name, sym) {
	return _sets_set_union(_B_sets_expect_tbl, name, _sets_pred_get(sym))
}
function _sets_exp_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_expect_tbl, name)
}
function _sets_exp_size(name) {
	return _sets_set_size(_B_sets_expect_tbl, name)
}
function _sets_exp_print() {_sets_set_print(_B_sets_expect_tbl, "expect")}
function _sets_exp_dbg_print() {_sets_set_dbg_print(_B_sets_expect_tbl)}
# </data>

# <process>
function _sets_expect_rule(rid,    _rnm, _lhs) {
	# Preconditions:
	# 1. The predict sets have been calculated.
	#
	# The expect set for non-terminal x is the set of terminals which can start
	# x. I.e. the union of the predict sets for all rules for which x is the
	# left hand side.
	_rnm = st_rule_name(rid)
	_lhs = st_rule_lhs(rid)
	_sets_exp_predict_union(_lhs, _rnm)
}
function _sets_expect(    _i, _end, _rnm, _lhs) {
	_sets_exp_init()
	_end = st_name_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_sets_expect_rule(_i)
}
# </process>
# </expect-sets>

# <conflicts>
# <first-first>
function _sets_fsfs_conf_err(lhs, da, db, ssx,    _err) {
	_err = sprintf("first/first conflict\n%s : %s\n%s : %s", lhs, da, lhs, db)
	_err = sprintf("%s\ncan both begin with\n%s", _err, ssx)
	err_fpos(lhs, _err)
}
function _sets_fsfs_conf_rule(lhs, rn, end,    _i, _a, _sx, _rid, _nrid, _ret) {
	_ret = 0
	_rid = st_lhs_rule_id(lhs, rn)
	_a = _sets_fst_get(st_rule_name(_rid))
	for (_i = rn+1; _i <= end; ++_i) {
		_nrid = st_lhs_rule_id(lhs, _i)
		_sx = str_set_intersect(_a, _sets_fst_get(st_rule_name(_nrid)))
		if (!str_set_is_empty(_sx)) {
			_sets_fsfs_conf_err(lhs, \
				st_rule_str(_rid),
				st_rule_str(_nrid),
				_sets_set_pretty(_sx))
			_ret = 1
		}
	}
	return _ret
}
function _sets_fsfs_conf_rules_lhs(lhs,    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfs_conf_rule(lhs, _i, _end), _conf)
	return _conf
}
function _sets_fsfs_conf_all(    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfs_conf_rules_lhs(st_lhs(_i)), _conf)
	return _conf
}
# </first-first>
# <first-follow>
function _sets_fsfwl_conf_err(lhs, ssx,    _err) {
	_err = "first/follow conflict; can both begin with and be followed by"
	err_fpos(lhs, sprintf("%s\n%s", _err, ssx))
}
function _sets_fsfwl_conf_rule(lhs,    _si, _sx, _ret) {
	_ret = 0
	_si = _sets_fst_get(lhs)
	if (str_set_find(_si, _SETS_EPS())) {
		_sx = str_set_intersect(_si, _sets_flw_get(lhs))
		if (!str_set_is_empty(_sx)) {
			_sets_fsfwl_conf_err(lhs, _sets_set_pretty(_sx))
			_ret = 1
		}
	}
	return _ret
}
function _sets_fsfwl_conf_all(    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfwl_conf_rule(st_lhs(_i)), _conf)
	return _conf
}
# </first-follow>
# </conflicts>
# </private>
# </first-follow-predict>
