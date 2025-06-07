# <generate>
# <data>
function _set(k, v) {_B_structs[k] = v}
function _get(k) {return _B_structs[k]}
function _has(k) {return (k in _B_structs)}

function prefix_save(str) {_set("prefix", str)}
function prefix_get() {return _get("prefix")}

function type_save(str,    _n) {
	_set("type.count", (_n = _get("type.count")+1))
	_set(sprintf("type=%d", _n), str)
	_set(sprintf("type.set=%s", str))
}
function type_count() {return _get("type.count")}
function type_get(n) {return _get(sprintf("type=%d", n))}
function type_last() {return type_get(type_count())}
function type_is(str) {return _has(sprintf("type.set=%s", str))}

function has_save(memb, mtype,    _type, _n, _x) {
	_type = type_last()
	_x = sprintf("has.count=%s", _type)
	_set(_x, (_n = _get(_x)+1))
	_x = sprintf("has.memb.%d=%s", _n, _type)
	_set(_x, memb)
	_x = sprintf("has.mtype.%d=%s", _n, _type)
	_set(_x, mtype)
}
function has_count(type) {return _get(sprintf("has.count=%s", type))}
function has_get_memb(type, n) {return _get(sprintf("has.memb.%d=%s", n, type))}
function has_get_mtype(type, n) {
	return _get(sprintf("has.mtype.%d=%s", n, type))
}
# </data>

function tag_structs() {return ("structs-" prefix_get())}
function tag_open(tag) {print sprintf("# <%s>", tag)}
function tag_close(tag) {print sprintf("# <\\%s>", tag)}
function make_fnm(str,    _pref) {return (prefix_get() "_" str)}
function make_dbnm() {return sprintf("_STRUCTS_%s_db", prefix_get())}

function emit(str) {tabs_print(str)}

function gen_base(    _fname, _db_nm) {
	tag_open("private")
	_db_nm = make_dbnm()

	_fname = ("_" make_fnm("set"))
	emit(sprintf("function %s(k, v) {%s[k] = v}", _fname, _db_nm))

	_fname = ("_" make_fnm("get"))
	emit(sprintf("function %s(k) {return %s[k]}", _fname, _db_nm))

	_fname = ("_" make_fnm("type_chk"))
	emit(sprintf("function %s(ent, texp) {", _fname))
	tabs_inc()
		emit(sprintf("if (%s(ent) == texp)", make_fnm("type_of")))
			tabs_inc()
			emit("return")
			tabs_dec()
		emit(sprintf("%s_errq(sprintf(\"entity '%%s' expected type '%%s', " \
			"actual type '%%s'\", \\\n\t\t ent, texp, %s(ent)))", \
			prefix_get(), make_fnm("type_of")))
	tabs_dec()
	emit("}")
	tag_close("private")

	emit("")

	_fname = make_fnm("clear")
	emit(sprintf("function %s() {", _fname))
	tabs_inc()
		emit(sprintf("delete %s", _db_nm))
		emit(sprintf("_%s(\"gen\", _%s(\"gen\")+1)", \
            make_fnm("set"), make_fnm("get")))
	tabs_dec()
	emit("}")

	_fname = make_fnm("is")
	emit(sprintf("function %s(ent) {return (ent in %s)}", _fname, _db_nm))

	_fname = make_fnm("type_of")
	emit(sprintf("function %s(ent) {", _fname))
	tabs_inc()
		emit(sprintf("if (ent in %s)", _db_nm))
		tabs_inc()
			emit(sprintf("return %s[ent]", _db_nm, _db_nm))
		tabs_dec()
		emit(sprintf("%s_errq(sprintf(\"'%%s' not an entity\", ent))", \
			prefix_get()))
	tabs_dec()
	emit("}")

	_fname = make_fnm("new")
	emit(sprintf("function %s(type,    _ent) {", _fname))
	tabs_inc()
		emit(sprintf("_%s(\"ents\", (_ent = _%s(\"ents\")+1))", \
			make_fnm("set"), make_fnm("get")))
		emit(sprintf("_ent = (\"_%s-\" _%s(\"gen\")+0 \"-\" _ent)", \
			prefix_get(), make_fnm("get")))
		emit(sprintf("_%s(_ent, type)", make_fnm("set")))
		emit("return _ent")
	tabs_dec()
	emit("}")
}

function gen_type(type,    _i, _end, _memb, _mtype, _pref, _fname) {
	_pref = prefix_get()
	_end = has_count(type)
	_fname = sprintf("function %s_make(", make_fnm(type))
	for (_i = 1; _i <= _end; ++_i)
		_fname = (_fname sprintf("%s, ", has_get_memb(type, _i)))
	emit(sprintf("%s    _ent) {", _fname))
	tabs_inc()
		emit(sprintf("_ent = %s(\"%s\")", make_fnm("new"), type))
		for (_i = 1; _i <= _end; ++_i) {
			_memb = has_get_memb(type, _i)
			_fname = sprintf("%s_%s_set_%s", _pref, type, _memb)
			emit(sprintf("%s(_ent, %s)", _fname, _memb))
		}
		emit("return _ent")
	tabs_dec()
	emit("}")
	emit("")

	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get_memb(type, _i)
		_mtype = has_get_mtype(type, _i)

		_fname = sprintf("%s_%s_set_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent, %s) {", _fname, _memb))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), type))
			if (_mtype) {
				emit(sprintf("if (%s)", _memb))
				tabs_inc()
					emit(sprintf("_%s(%s, \"%s\")", \
						make_fnm("type_chk"), _memb, _mtype))
				tabs_dec()
			}
			emit(sprintf("_%s((\"%s=\" ent), %s)", \
				make_fnm("set"), _memb, _memb))
		tabs_dec()
		emit("}")

		_fname = sprintf("%s_%s_get_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent) {", _fname))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), type))
			emit(sprintf("return _%s((\"%s=\" ent))", make_fnm("get"), _memb))
		tabs_dec()
		emit("}")
		emit("")
	}
}

function gen_types(    _i, _end, _type, _fname) {
	_end = type_count()
	for (_i = 1; _i <= _end; ++_i) {
		_type = type_get(_i)
		_fname = toupper(make_fnm(_type))
		tag_open(sprintf("type-%s", _type))
		emit(sprintf("function %s() {return \"%s\"}", _fname, _type))
		emit("")
		gen_type(_type)
		tag_close(sprintf("type-%s", _type))
	}
}

function check_mtypes(    _i, _ie, _j, _je, _type, _mtype, _err) {
	_ie = type_count()
	for (_i = 1; _i <= _ie; ++_i) {
		_type = type_get(_i)
		_je = has_count(_type)
		for (_j = 1; _j <= _je; ++_j) {
			_mtype = has_get_mtype(_type, _j)
			if (_mtype && !type_is(_mtype)) {
				_err = sprintf("struct '%s', member '%s' '%s' is not a type", \
					_type, has_get_memb(_type, _j), _mtype)
				error_quit(_err)
			}
		}
	}
}
function checks() {check_mtypes()}

function gen_struct_cmnts(    _i, _ie, _j, _je, _type, _memb, _mtype) {
	emit("# structs:")
	emit("#")
	emit(sprintf("# prefix %s", prefix_get()))
	_ie = type_count()
	for (_i = 1; _i <= _ie; ++_i) {
		_type = type_get(_i)
		emit("#")
		emit(sprintf("# type %s", _type))
		_je = has_count(_type)
		for (_j = 1; _j <= _je; ++_j) {
			_memb = has_get_memb(_type, _j)
			_mtype = has_get_mtype(_type, _j)
			emit(sprintf("# has  %s %s", _memb, _mtype))
		}
	}
	emit("#")
}

function generate() {
	checks()
	tag_open(tag_structs())
	gen_struct_cmnts()
	gen_base()
	tag_open("types")
	gen_types()
	tag_close("types")
	tag_close(tag_structs())
}
# </generate>
