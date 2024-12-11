# <sym-tbl>
# <private>
function _st_has(n) {return map_has(_B_st_data, n)}
function _st_get(n) {return map_get(_B_st_data, n)}
function _st_set(n, v) {_B_st_data[n] = v}
# </private>

# <print>
function st_print_rules(    _i, _ei, _j, _ej, _nm) {
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		printf("rule %d %s %s : ", _i, st_rule_name(_i), st_rule_lhs(_i))
		_ej = st_rule_pos_count(_i)
		for (_j = 1; _j <= _ej; ++_j)
			printf("%s ", st_rule_pos_name(_i, _j))
		print ""
	}
}
# </print>

# <name>
function st_name_count() {return _st_name_set_len(_ST_SNAME())}
function st_name(n)      {return _st_name_set_at(_ST_SNAME(), n)}
function st_name_type(name) {return _st_get(sprintf("name.type=%s", name))}

function st_name_term_count() {return _st_name_set_len(_ST_STERM())}
function st_name_term(n)      {return _st_name_set_at(_ST_STERM(), n)}
function st_name_nont_count() {return _st_name_set_len(_ST_SNONT())}
function st_name_nont(n)      {return _st_name_set_at(_ST_SNONT(), n)}
function st_name_lhs_count()  {return _st_name_set_len(_ST_SLHS())}
function st_name_lhs(n)       {return _st_name_set_at(_ST_SLHS(), n)}
function st_name_rule_count() {return _st_name_set_len(_ST_SRULE())}
function st_name_rule(n)      {return _st_name_set_at(_ST_SRULE(), n)}

function st_name_can_null(name) {
	return _st_has(sprintf("name.null.set=%s", name))
}
function st_name_is_tail_rec(name) {
	return _st_has(sprintf("name.trec.set=%s", name))
}
function st_name_is_term(name) {return _st_name_set_has(_ST_STERM(), name)}
function st_name_is_nont(name) {return _st_name_set_has(_ST_SNONT(), name)}
function st_name_is_lhs(name)  {return _st_name_set_has(_ST_SLHS(), name)}
function st_name_is_rule(name) {return _st_name_set_has(_ST_SRULE(), name)}
function st_name_is_zero(name) {return ("0" == name)}

function st_name_term_add(name) {_st_name_add(name, _ST_TTERM())}
function st_name_nont_add(name) {_st_name_add(name, _ST_TNONT())}
function st_name_lhs_add(name)  {_st_name_add(name, _ST_TLHS())}
function st_name_rule_add(name) {_st_name_add(name, _ST_TRULE())}

function st_name_mark_can_null(name) {
	_st_set(sprintf("name.null.set=%s", name))
}
function st_name_mark_tail_rec(name) {
	_st_set(sprintf("name.trec.set=%s", name))
}

# <private>
function _ST_TTERM() {return "t"}
function _ST_TNONT() {return "n"}
function _ST_TLHS()  {return "nl"}
function _ST_TRULE() {return "nr"}

function _ST_STERM() {return "term"}
function _ST_SNONT() {return "nont"}
function _ST_SLHS()  {return "lhs"}
function _ST_SRULE() {return "rule"}
function _ST_SNAME() {return "name"}

function _st_name_add(name, type,    _chg) {
	_chg = 0
	_chg = keep(_st_name_name_add(name), _chg)
	if (index(type, "t")) _chg = keep(_st_name_term_add(name), _chg)
	if (index(type, "n")) _chg = keep(_st_name_nont_add(name), _chg)
	if (index(type, "l")) _chg = keep(_st_name_lhs_add(name), _chg)
	if (index(type, "r")) _chg = keep(_st_name_rule_add(name), _chg)
	if (_chg) _st_set(sprintf("name.type=%s", name), type)
}

function _st_name_name_add(name) {return _st_name_set_add(_ST_SNAME(), name)}
function _st_name_term_add(name) {return _st_name_set_add(_ST_STERM(), name)}
function _st_name_nont_add(name) {return _st_name_set_add(_ST_SNONT(), name)}
function _st_name_lhs_add(name)  {return _st_name_set_add(_ST_SLHS(), name)}
function _st_name_rule_add(name) {return _st_name_set_add(_ST_SRULE(), name)}

function _st_name_set_len(set_name) {
	return _st_get(sprintf("name.%s.set.len", set_name))+0
}
function _st_name_set_at(set_name, pos) {
	return _st_get(sprintf("name.%s.set.str=%d", set_name, pos))
}
function _st_name_set_has(set_name, name) {
	return _st_has(sprintf("name.%s.set.num=%s", set_name, name))
}
function _st_name_set_add(set_name, name) {
	if (_st_name_set_has(set_name, name))
		return 0

	_n = sprintf("name.%s.set.len", set_name)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("name.%s.set.str=%d", set_name, _c)
	_st_set(_n, name)
	_n = sprintf("name.%s.set.num=%s", set_name, name)
	_st_set(_n, _c)
	return 1
}
# </private>
# </name>

# <eoi>
function st_eoi_set(nm) {_st_set("eoi", nm)}
function st_eoi()       {return _st_get("eoi")}
# </eoi>

# <lsh>
function st_lhs_count() {return st_name_lhs_count()}
function st_lhs(n)      {return st_name_lhs(n)}
function st_lhs_is_tail_rec(lhs) {return st_name_is_tail_rec(lhs)}
function st_lhs_line_num(name)   {return _st_get(sprintf("lhs.lnum=%s", name))}
function st_lhs_rule_count(name) {return _st_get(sprintf("lhs.rules=%s", name))}
function st_lhs_rule_id(lhs, n) {
	return _st_get(sprintf("lhs.rule=%s.%d", lhs, n))
}

function st_lhs_add(name, lnum,    _n) {
	if (st_name_is_lhs(name))
		err_quit_fpos(sprintf("non-terminal '%s' redefined", name), lnum)
	st_name_lhs_add(name)
	_n = sprintf("lhs.lnum=%s", name)
	_st_set(_n, lnum)
}
function st_lhs_rule_add(rstr,    _c, _n, _lhs, _rname) {
	_lhs = st_lhs_last()
	_n = sprintf("lhs.rules=%s", _lhs)
	_st_set(_n, (_c = _st_get(_n)+1))
	_rname = sprintf("%s_%d", _lhs, _c)
	_st_rule_add(_lhs, _rname, rstr)
	_n = sprintf("lhs.rule=%s.%d", _lhs, _c)
	_st_set(_n, st_rule_count())
}
function st_lhs_last() {return st_lhs(st_lhs_count())}
# </lsh>

# <rule>
function st_rule_count() {return st_name_rule_count()}
function st_rule_name(n) {return st_name_rule(n)}
function st_rule_lhs(n) {return _st_get(sprintf("rule.lhs=%d", n))}
function st_rule_is_zero(n) {return st_name_is_zero(st_rule_pos_name(n, 1))}
function st_rule_str(n) {return _st_get(sprintf("rule.str=%d", n))}

function st_rule_pos_count(n) {return _st_get(sprintf("rule.pos.len=%d", n))}
function st_rule_pos_name(r, n) {
	return _st_get(sprintf("rule.pos.name=%d.%d", r, n))

}
function st_rule_pos_esc_count(r, n) {
	return _st_get(sprintf("rule.pos.esc.len=%d.%d", r, n))
}
function st_rule_pos_esc(r, p, n) {
	return _st_get(sprintf("rule.pos.esc=%d.%d.%d", r, p, n))
}

function st_rule_is_tail_rec(n) {return st_name_is_tail_rec(st_rule_name(n))}

function st_rule_pos_esc_add(esc,    _c, _n, _r, _p) {
	_r = st_rule_count()
	_p = _st_rule_pos_last()
	_n = sprintf("rule.pos.esc.len=%d.%d", _r, _p)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("rule.pos.esc=%d.%d.%d", _r, _p, _c)
	_st_set(_n, esc)
}

function st_rule_pos_add(name,    _c, _n, _r) {
	_r = st_rule_count()
	_n = sprintf("rule.pos.len=%d", _r)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("rule.pos.name=%d.%d", _r, _c)
	_st_set(_n, name)
}

function st_rule_name_last() {return st_rule_name(st_rule_count())}

# <private>
function _st_rule_add(lhs, name, rstr,    _c, _n) {
	st_name_rule_add(name)
	_c = st_rule_count()
	_n = sprintf("rule.lhs=%d", _c)
	_st_set(_n, lhs)
	_n = sprintf("rule.str=%d", _c)
	_st_set(_n, rstr)
	_n = sprintf("rule.pos.len=%d", _c)
	_st_set(_n, -1)
	st_rule_pos_add(name)
}
function _st_rule_pos_last() {return st_rule_pos_count(st_rule_count())}
# </private>
# </rule>

# <dbg>
function st_dbg_print_esc(rid, n,    _i, _end) {
	_end = st_rule_pos_esc_count(rid, n)
	for (_i = 1; _i <= _end; ++_i)
		printf("\\%s ", st_rule_pos_esc(rid, n, _i))
}
function st_dbg_print_rule(rid,    _i, _end, _str) {
	printf("%s : ", st_rule_lhs(rid))
	_end = st_rule_pos_count(rid)
	for (_i = 0; _i <= _end; ++_i) {
		_str = st_rule_pos_name(rid, _i)

		if (0 == _i) {
			printf("(%s) ", _str)

			if (st_name_is_tail_rec(_str))
				printf("(tr) ")

			if (st_name_can_null(_str))
				printf("(0) ")
		} else {
			printf("%s ", _str)
		}

		st_dbg_print_esc(rid, _i)
	}
	print ""
}
function st_dbg_print_lhs(name,    _i, _end, _lhs) {
	_lhs = sprintf("%s (line %s)", name, st_lhs_line_num(name))

	if (st_name_can_null(name))
		_lhs = (_lhs " (0)")

	if (st_name_is_tail_rec(name))
		_lhs = (_lhs " (tr)")

	print sprintf("%s", _lhs)

	_end = st_lhs_rule_count(name)
	for (_i = 1; _i <= _end; ++_i)
		st_dbg_print_rule(st_lhs_rule_id(name, _i))
}
function st_dbg_print(    _i, _end) {
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		st_dbg_print_lhs(st_lhs(_i))
		print ""
	}
}
function st_dbg_dump(    _n) {
	for (_n in _B_st_data)
		print sprintf("st[\"%s\"] = %s", _n, _B_st_data[_n])
}
# </dbg>
# </sym-tbl>
