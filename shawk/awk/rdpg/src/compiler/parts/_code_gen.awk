# <code-gen>
function cg_generate() {_cg_gen()}

# <private>
# <emit>
function _emit_block_open() {
	emit(IR_BLOCK_OPEN())
	tinc()
}
function _emit_block_close() {
	tdec()
	emit(IR_BLOCK_CLOSE())
}
function _emit_else_expect(sym) {
	emit(IR_ELSE())
	_emit_block_open()
	emit(_make_call(_make_expect(sym)))
	_emit_block_close()
}
# </emit>

# <make>
function _make_fn(nm) {return sprintf("%s %s", IR_FUNC(), nm)}
function _make_ret(v) {return sprintf("%s %s", IR_RETURN(), v)}
function _make_call(fn, args) {
	fn = sprintf("%s %s", IR_CALL(), fn)
	return args ? (fn " " args) : fn
}
function _make_cond(expr, c) {return sprintf("%s %s", c ? c : _cg_cond(), expr)}
function _make_predict(nm) {
	return sprintf("%s %s", _cg_pred_type(nm), _cg_pred_what(nm))
}
function _make_expect(nm,    _exp) {
	if (!(_exp = _cg_exp_set(nm)))
		_exp = nm
	return sprintf("%s %s", IR_EXPECT(), _exp)
}
function _make_alias(nm) {return sprintf("%s %s", IR_ALIAS(), nm)}
function _make_sync(nm) {return sprintf("%s %s", IR_SYNC(), nm)}
function _make_set(which, set) {return sprintf("%s %s", which, set)}
function _make_esc(nm) {return sprintf("%s %s", IR_ESC(), nm)}
function _make_comnt(str) {return sprintf("%s %s", IR_COMMENT(), str)}
function _make_and(a, b) {return sprintf("%s %s %s", a, IR_AND(), b)}
# </make>

# <pred>
function _cg_pred_place(rnm, type, what,    _n) {
	_n = sprintf("pred.type=%s", rnm)
	_B_cd_pred[_n] = type
	_n = sprintf("pred.what=%s", rnm)
	_B_cd_pred[_n] = what
}
function _cg_pred_type(rnm) {return _B_cd_pred[sprintf("pred.type=%s", rnm)]}
function _cg_pred_what(rnm) {return _B_cd_pred[sprintf("pred.what=%s", rnm)]}
# </pred>

# <expect>
function _cg_exp_place(nm, what) {_B_cd_exp[nm] = what}
function _cg_exp_set(nm)         {return (nm in _B_cd_exp) ? _B_cd_exp[nm] : ""}
# </expect>

# <alias>
function __cg_alias_gen_nm() {return sprintf("set_%d", ++_B_cg_alias_num)}
function __cg_alias_place(set,    _nm) {
	if (!(set in _B_cg_alias_name_by_set)) {
		_nm = __cg_alias_gen_nm()
		_B_cg_alias_name_by_set[set] = _nm
		_B_cg_alias_set_by_name[_nm] = set
		_B_cg_alias_name_by_num[_cg_alias_count()] = _nm
	}
}

function _cg_alias_count() {return _B_cg_alias_num}
function _cg_alias_name_by_set(set) {
	if (!(set in _B_cg_alias_name_by_set))
		error_quit(sprintf("no name for set '%s'", set))
	return _B_cg_alias_name_by_set[set]
}
function _cg_alias_set_by_name(nm) {
	if (!(nm in _B_cg_alias_set_by_name))
		error_quit(sprintf("no set for name '%s'", nm))
	return _B_cg_alias_set_by_name[nm]
}
function _cg_alias_name_by_num(n) {return _B_cg_alias_name_by_num[n]}

function _cg_alias_gen(    _i, _end, _nm, _set, _sz) {
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = st_rule_name(_i)
		_sz = sets_pred_size(_nm)
		if (_sz > 1) {
			_set = sets_pred_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}

	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = st_lhs(_i)
		_sz = sets_exp_size(_nm)
		if (_sz > 1) {
			_set = sets_exp_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}

	_end = st_lhs_count()
	for (_i = 2; _i <= _end; ++_i) {
		_nm = st_lhs(_i)
		_sz = sets_flw_size(_nm)
		if (_sz > 0) {
			_set = sets_flw_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}
}
# </alias>

# <gen>
function _cg_gen_sets_alias(    _i, _end, _nm) {
	_cg_alias_gen()
	_end = _cg_alias_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = _cg_alias_name_by_num(_i)
		emit(_make_set(_make_alias(_nm), _cg_alias_set_by_name(_nm)))
	}
}
function _cg_gen_sets_predict(    _i, _end, _rnm, _set, _sz) {
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_rnm = st_rule_name(_i)
		_set = sets_pred_pretty(_rnm)
		_sz = sets_pred_size(_rnm)
		if (1 == _sz) {
			# Rules which can be predicted by only one token do not need their
			# predict set emitted because tok_is() is sufficient.
			_cg_pred_place(_rnm, IR_TOK_IS(), _set)
		} else if (_sz > 1) {
			_cg_pred_place(_rnm, IR_PREDICT(), _rnm)
			emit(_make_set(_make_predict(_rnm), _cg_alias_name_by_set(_set)))
		}
	}
}
function _cg_gen_sets_expect(    _i, _end, _lhs, _set, _sz) {
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		_sz = sets_exp_size(_lhs)
		_set = sets_exp_pretty(_lhs)
		if (1 == _sz) {
			_cg_exp_place(_lhs, _set)
		} else if (_sz > 1) {
			_cg_exp_place(_lhs, _lhs)
			emit(_make_set(_make_expect(_lhs), _cg_alias_name_by_set(_set)))
		}
	}
}
function _cg_gen_sets_follow(    _i, _end, _lhs, _set) {
	_end = st_lhs_count()
	for (_i = 2; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		if (_set = sets_flw_pretty(_lhs))
			emit(_make_set(_make_sync(_lhs), _cg_alias_name_by_set(_set)))
	}
}
function _cg_gen_tokens(    _i, _end, _nm, _toks) {
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = st_name(_i)
		if (st_name_is_term(_nm)) {
			_tok = (_tok _nm)
			if (_i < _end)
				_tok = (_tok " ")
		}
	}
	emit(sprintf("%s %s", IR_TOKENS(), _tok))
	emit(sprintf("%s %s", IR_TOK_EOI(), st_eoi()))
}
function _cg_gen_sets() {
	emit(IR_SETS())
	_emit_block_open()
	_cg_gen_sets_alias()
	_cg_gen_sets_predict()
	_cg_gen_sets_expect()
	_cg_gen_sets_follow()
	_emit_block_close()
}

function _cg_gen_esc(pos,    _i, _end) {
	_end = _cg_esc_count(pos)
	for (_i = 1; _i <= _end; ++_i)
		emit(_make_call(_make_esc(_cg_esc(pos, _i))))
}

function _cg_gen_rule_pos(n,    _sym, _is_term, _has_esc, _is_pred) {
	_sym = _cg_pos_name(n)
	_is_term = _cg_pos_is_term(n)
	_has_esc = _cg_pos_has_esc(n)
	_is_pred = (1 == n && 2 == _cg_depth())

	if (_is_term) {
		if (_is_pred) {
			emit(_make_comnt(sprintf("%s predicted", _sym)))
		} else {
			if (_has_esc)
				emit(_make_cond(_make_call(IR_TOK_IS(), _sym)))
			else
				emit(_make_cond(_make_call(IR_TOK_MATCH(), _sym)))
		}
	} else {
		emit(_make_cond(_make_call(_sym)))
	}

	if (!(_is_term && _is_pred))
		_emit_block_open()

	_cg_gen_esc(n)
	if (_is_term && (_is_pred || _has_esc))
		emit(_make_call(IR_TOK_NEXT()))

	if (_cg_pos_count() == n) {
		if (_cg_rule_is_trec())
			emit(IR_CONTINUE())
		else
			emit(_make_ret(IR_TRUE()))
	} else {
		_cg_gen_rule_pos(n+1)
	}

	if (!(_is_term && _is_pred))
		_emit_block_close()

	if (_is_term && (_cg_depth() - _is_pred) > 1)
		_emit_else_expect(_sym)
}

function _cg_gen_rule_predict() {
	emit(_make_cond(_make_call(_make_predict(_cg_rule_name()))))
}
function _cg_gen_rule_apply() {
	_cg_gen_esc(0)
	# The epsilon production.
	if (_cg_rule_is_zero())
		emit(_make_ret(IR_TRUE()))
	else
		_cg_gen_rule_pos(1)
}
function _cg_gen_lhs_rule(n,    _shd_predict) {
	_cg_rule_init(n)
	_shd_predict = _cg_rule_should_predict()

	if (_shd_predict) {
		_cg_gen_rule_predict()
		_emit_block_open()
	}

	_cg_gen_rule_apply()

	if (_shd_predict)
		_emit_block_close()
}
function _cg_gen_lhs(n,    _lhs, _i, _end, _is_tail_rec, _is_start, _tsync) {
	_cg_lhs_init(n)
	_lhs = _cg_lhs()
	_is_tail_rec = _cg_lhs_is_trec()
	_is_start = _cg_lhs_is_first()

	emit(_make_fn(_lhs))
	_emit_block_open()
	_cg_gen_grammar_lhs(_lhs)
	nl()

	if (_is_start)
		emit(_make_call(IR_TOK_NEXT()))

	if (_is_tail_rec) {
		emit(IR_LOOP())
		_emit_block_open()
	}

	_end = _cg_lhs_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_cg_gen_lhs_rule(_i)

	_emit_else_expect(_lhs)

	_tsync = sync_type()
	if (SYNC_DEFAULT() == _tsync) {
		# Nothing to sync on in the start lhs.
		if (_is_start)
			emit(_make_ret(IR_FALSE()))
		else
			emit(_make_ret(_make_call(_make_sync(_lhs))))
	} else if (_tsync == SYNC_NONE()) {
		emit(_make_ret(IR_FALSE()))
	} else if (SYNC_CUSTOM() == _tsync) {
		if (_is_start || !sync_has_nont(_lhs))
			emit(_make_ret(IR_FALSE()))
		else
			emit(_make_ret(_make_call(_make_sync(_lhs))))
	}

	_emit_block_close()

	if (_is_tail_rec)
		_emit_block_close()
}
function _cg_gen_start() {
	# Generate the official entry point of the parser.
	emit(_make_fn(IR_RDPG_PARSE()))
	_emit_block_open()
	emit(_make_and(_make_ret(_make_call(st_lhs(1))), IR_WAS_NO_ERR()))
	_emit_block_close()
}
function _cg_gen_parser(    _i, _end) {
	_cg_gen_start()
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_cg_gen_lhs(_i)
}
function _cg_gen_grammar_lhs(lhs,    _i, _ei, _j, _ej, _k, _ek, _rid, _ln) {
	# Print the grammar for a specific lhs as comments.
	_ei = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _ei; ++_i) {
		_rid = st_lhs_rule_id(lhs, _i)
		_ln = sprintf("%s. %s : ", _rid, lhs)
		_ej = st_rule_pos_count(_rid)
		for (_j = 0; _j <= _ej; ++_j) {
			if (_j)
				_ln = (_ln sprintf("%s ", st_rule_pos_name(_rid, _j)))
			_ek = st_rule_pos_esc_count(_rid, _j)
			for (_k = 1; _k <= _ek; ++_k)
				_ln = (_ln sprintf("\\%s ", st_rule_pos_esc(_rid, _j, _k)))
		}
		sub("[[:space:]]+$", "", _ln)
		emit(_make_comnt(_ln))
	}
}
function _cg_gen_grammar(    _i, _end) {
	# Print the whole grammar as comments.
	emit(_make_comnt("Grammar:"))
	emit(IR_COMMENT())
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_cg_gen_grammar_lhs(st_lhs(_i))
		emit(IR_COMMENT())
	}
	nl()
}
function _cg_gen_header() {
	emit(_make_comnt(sprintf("generated by %s %s", \
		SCRIPT_NAME(), SCRIPT_VERSION())))
	emit(IR_COMMENT())
}
function _cg_gen() {
	_cg_gen_header()
	_cg_gen_grammar()
	_cg_gen_tokens()
	_cg_gen_sets()
	_cg_gen_parser()
}
# </gen>

# <data>
# <lhs>
function _cg_lhs_init(n,    _lhs) {
	_lhs = st_lhs(n)
	_B_cg_lhs["name"] = _lhs
	_B_cg_lhs["is_first"] = (1 == n)
	_B_cg_lhs["is_trec"] = st_lhs_is_tail_rec(_lhs)
	_B_cg_lhs["rcount"] = st_lhs_rule_count(_lhs)
}
function _cg_lhs() {return _B_cg_lhs["name"]}
function _cg_lhs_is_first() {return _B_cg_lhs["is_first"]}
function _cg_lhs_is_trec() {return _B_cg_lhs["is_trec"]}
function _cg_lhs_rule_count() {return _B_cg_lhs["rcount"]}
# </lhs>
# <rule>
function _cg_rule_init(lhs_num,    _lhs, _rid, _pred) {
	_lhs = _cg_lhs()
	_rid = st_lhs_rule_id(_lhs, lhs_num)
	_B_cg_rule["lhs"] = _lhs
	_B_cg_rule["id"] = _rid
	_B_cg_rule["name"] = st_rule_name(_rid)
	_B_cg_rule["is_first"] = (1 == lhs_num)
	_B_cg_rule["is_trec"] = st_rule_is_tail_rec(_rid)
	_cg_pos_init(_rid)
	_B_cg_rule["is_zero"] = st_name_is_zero(_cg_pos_name(1))
	_B_cg_rule["shd_pred"] = !_cg_pos_is_term(1) || _cg_pos_has_esc(0)
}
function _cg_rule_id() {return _B_cg_rule["id"]}
function _cg_rule_name() {return _B_cg_rule["name"]}
function _cg_rule_lhs() {return _B_cg_rule["lhs"]}
function _cg_rule_is_first() {return _B_cg_rule["is_first"]}
function _cg_rule_is_trec() {return _B_cg_rule["is_trec"]}
function _cg_rule_is_zero() {return _B_cg_rule["is_zero"]}
function _cg_rule_should_predict() {return _B_cg_rule["shd_pred"]}
# </rule>
# <pos>
function _cg_pos_init(rid,    _i, _end, _n, _pnm) {
	_end = st_rule_pos_count(rid) - _cg_rule_is_trec()
	_B_cg_pos["count"] = _end
	for (_i = 0; _i <= _end; ++_i) {
		_n = sprintf("pos=%d", _i)
		_pnm = st_rule_pos_name(rid, _i)
		_B_cg_pos[_n] = _pnm
		_n = sprintf("pos.has_esc=%d", _i)
		_B_cg_pos[_n] = !!st_rule_pos_esc_count(rid, _i)
		_n = sprintf("pos.is_term=%d", _i)
		_B_cg_pos[_n] = st_name_is_term(_pnm)
	}
	_cg_esc_init(rid)
}
function _cg_pos_count() {return _B_cg_pos["count"]}
function _cg_pos_name(n) {return _B_cg_pos[sprintf("pos=%d", n)]}
function _cg_pos_has_esc(n) {return _B_cg_pos[sprintf("pos.has_esc=%d", n)]}
function _cg_pos_is_term(n) {return _B_cg_pos[sprintf("pos.is_term=%d", n)]}
# </pos>
# <esc>
function _cg_esc_init(rid,    _i, _ei, _j, _ej, _n, _c) {
	_ei = _cg_pos_count()
	for (_i = 0; _i <= _ei; ++_i) {
		_ej = st_rule_pos_esc_count(rid, _i)
		_n = sprintf("esc.count=%d", _i)
		_B_cg_esc[_n] = _ej
		for (_j = 1; _j <= _ej; ++_j) {
			_n = sprintf("esc.name=%d.%d", _i, _j)
			_B_cg_esc[_n] = st_rule_pos_esc(rid, _i, _j)
		}
	}
}
function _cg_esc_count(p) {return _B_cg_esc[sprintf("esc.count=%d", p)]}
function _cg_esc(p, n) {return _B_cg_esc[sprintf("esc.name=%d.%d", p, n)]}
# </esc>
# <cond>
function _cg_depth() {return tnum() - _cg_lhs_is_trec()}
function _cg_cond() {
	return (_cg_depth() > 1 || _cg_rule_is_first()) ? IR_IF() : IR_ELSE_IF()
}
# </cond>
# </data>
# </private>
# </code-gen>
