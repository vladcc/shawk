# <generate>
# <data>
function __set(k, v) {_B_structs[k] = v}
function __get(k) {return _B_structs[k]}
function __has(k) {return (k in _B_structs)}

function prefix_save(str) {__set("prefix", str)}
function prefix_get() {return __get("prefix")}

function type_save(str,    _count) {
	_count = __get("type.count") + 1
	__set("type.count", _count)
	__set(sprintf("type.%d", _count), str)
	__set(sprintf("type.set=%s", str))
}
function type_count() {return __get("type.count")}
function type_get(n)  {return __get(sprintf("type.%d", n))}
function type_last()  {return type_get(type_count())}
function type_is(str) {return __has(sprintf("type.set=%s", str))}

function has_save(memb, mtype,    _type, _count, _key) {
	_type = type_last()

	_key = sprintf("has.count.%s", _type)
	_count = __get(_key) + 1
	__set(_key, _count)

	__set(sprintf("has.memb.%d.%s", _count, _type), memb)
	has_set_mtype(_type, _count, mtype)
}
function has_count(type) {
	return __get(sprintf("has.count.%s", type))
}
function has_set_mtype(type, n, mtype) {
	__set(sprintf("has.mtype.%d.%s", n, type), mtype)
}
function has_get_memb(type, n) {
	return __get(sprintf("has.memb.%d.%s", n, type))
}
function has_get_mtype(type, n) {
	return __get(sprintf("has.mtype.%d.%s", n, type))
}

function union_save(str,    _count) {
	_count = __get("union.count") + 1
	__set("union.count", _count)
	__set(sprintf("union.%d", _count), str)
	__set(sprintf("union.set=%s", str))
}
function union_count() {return __get("union.count")}
function union_get(n)  {return __get(sprintf("union.%d", n))}
function union_last()  {return union_get(union_count())}
function union_is(str) {return __has(sprintf("union.set=%s", str))}

function name_save(str,    _union, _count, _key) {
	_union = union_last()

	_key = sprintf("name.count.%s", _union)
	_count = __get(_key) + 1
	__set(_key, _count)

	__set(sprintf("name.%d.%s", _count, _union), str)
}
function name_count(union)  {return __get(sprintf("name.count.%s", union))}
function name_get(union, n) {return __get(sprintf("name.%d.%s", n, union))}
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
		emit(sprintf("if (%s(ent) ~ texp)", make_fnm("type_of")))
			tabs_inc()
			emit("return")
			tabs_dec()
		emit(                                                                 \
			sprintf(                                                          \
				(                                                             \
				"%s_errq(sprintf(\"entity '%%s': expected type match '%%s', " \
				"entity type '%%s'\", \n\t\t ent, texp, %s(ent)))"            \
				),                                                            \
				prefix_get(),                                                 \
				make_fnm("type_of")                                           \
			)                                                                 \
		)
	tabs_dec()
	emit("}")
	tag_close("private")

	emit("")

	_fname = make_fnm("clear")
	emit(sprintf("function %s() {", _fname))
	tabs_inc()
		emit(sprintf("delete %s", _db_nm))
		emit(                                   \
			sprintf(                            \
				"_%s(\"gen\", _%s(\"gen\")+1)", \
				make_fnm("set"),                \
				make_fnm("get")                 \
			)                                   \
		)
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
		emit(                                                     \
			sprintf(                                              \
				"%s_errq(sprintf(\"'%%s' not an entity\", ent))", \
				prefix_get()                                      \
			)                                                     \
		)
	tabs_dec()
	emit("}")

	_fname = make_fnm("new")
	emit(sprintf("function %s(type,    _ent) {", _fname))
	tabs_inc()
		emit(                                              \
			sprintf(                                       \
				"_%s(\"ents\", (_ent = _%s(\"ents\")+1))", \
				make_fnm("set"),                           \
				make_fnm("get")                            \
			)                                              \
		)
		emit(                                                  \
			sprintf(                                           \
				"_ent = (\"_%s-\" _%s(\"gen\")+0 \"-\" _ent)", \
				prefix_get(),                                  \
				make_fnm("get")                                \
			)                                                  \
		)
		emit(sprintf("_%s(_ent, type)", make_fnm("set")))
		emit("return _ent")
	tabs_dec()
	emit("}")
}

function gen_type(type,    _i, _end, _memb, _mtype, _pref, _fname, _type_rx) {
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

	_type_rx = sprintf("^(%s)$", type)
	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get_memb(type, _i)
		_mtype = has_get_mtype(type, _i)

		_fname = sprintf("%s_%s_set_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent, %s) {", _fname, _memb))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), _type_rx))
			if (_mtype) {
				emit(sprintf("if (%s)", _memb))
				tabs_inc()
					emit(                             \
						sprintf(                      \
							"_%s(%s, \"%s\")",        \
							make_fnm("type_chk"),     \
							_memb,                    \
							sprintf("^(%s)$", _mtype) \
						)                             \
					)
				tabs_dec()
			}
			emit(                             \
				sprintf(                      \
					"_%s((ent \".%s\"), %s)", \
					make_fnm("set"),          \
					_memb,                    \
					_memb                     \
				)                             \
			)
		tabs_dec()
		emit("}")

		_fname = sprintf("%s_%s_get_%s", _pref, type, _memb)
		emit(sprintf("function %s(ent) {", _fname))
		tabs_inc()
			emit(sprintf("_%s(ent, \"%s\")", make_fnm("type_chk"), _type_rx))
			emit(sprintf("return _%s((ent \".%s\"))", make_fnm("get"), _memb))
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

# <checks>
function errq_does_not_name(msg) {
	error_quit(sprintf("%s does not name a type nor an union", msg))
}
function errq_redefined(msg) {
	error_quit(sprintf("%s defined more than once", msg))
}
# <types>
function check_types(    _i, _end, _type, _set) {
	_end = type_count()

	if (!_end)
		check_types_no_types_fail()

	for (_i = 1; _i <= _end; ++_i) {
		_type = type_get(_i)

		if (!(_type in _set))
			_set[_type]
		else
			check_types_redefined_fail(_type)

		if (union_is(_type))
			check_types_both_fail(_type)

		check_types_type_of_members(_type)
		check_types_unique_members(_type)
	}
}
function check_types_no_types_fail() {
	error_quit("no defined types")
}
function check_types_redefined_fail(type) {
	errq_redefined(sprintf("type '%s'", type))
}
function check_types_both_fail(type) {
	error_quit(sprintf("name '%s' defined as both an union and a type", type))
}

function check_types_type_of_members(type,    _i, _end, _mtype) {
	_end = has_count(type)
	for (_i = 1; _i <= _end; ++_i) {
		_mtype = has_get_mtype(type, _i)
		if (_mtype && !type_is(_mtype) && !union_is(_mtype)) {
			check_types_type_of_members_fail( \
				type,                         \
				has_get_memb(type, _i),       \
				_mtype                        \
			)
		}
	}
}
function check_types_type_of_members_fail(type, memb, mtype) {
	errq_does_not_name(                     \
		sprintf(                            \
			"type '%s', member '%s': '%s'", \
			type,                           \
			memb,                           \
			mtype                           \
		)                                   \
	)
}

function check_types_unique_members(type,    _i, _end, _memb, _set) {
	_end = has_count(type)
	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get_memb(type, _i)
		if (!(_memb in _set))
			_set[_memb]
		else
			check_types_unique_members_fail(type, _memb)
	}
}
function check_types_unique_members_fail(type, memb) {
	errq_redefined(sprintf("type '%s': member '%s'", type, memb))
}
# </types>

# <unions>
function check_unions(    _i, _end, _union, _set) {
	_end = union_count()
	for (_i = 1; _i <= _end; ++_i) {
		_union = union_get(_i)

		if (!(_union in _set))
			_set[_union]
		else
			check_unions_redefined_fail(_union)

		check_unions_type_of_names(_union)
		check_unions_unique_names(_union)
	}
}
function check_unions_redefined_fail(union) {
	errq_redefined(sprintf("union '%s'", union))
}

function check_unions_type_of_names(union,    _i, _end, _name) {
	_end = name_count(union)
	for (_i = 1; _i <= _end; ++_i) {
		_name = name_get(union, _i)
		if (!type_is(_name) && !union_is(_name))
			check_unions_type_of_names_fail(union, _name)
	}
}
function check_unions_type_of_names_fail(union, name) {
	errq_does_not_name(sprintf("union '%s': name '%s'", union, name))
}

function check_unions_unique_names(union, _path, _set,    _i, _end, _name,
_guard) {
	_guard = (" " union " ")
	if (index(_path, _guard))
		check_unions_unique_names_recurse_fail(_path, _guard)

	_path = !(_path) ? (" " union) : (_path " -> " union)

	_end = name_count(union)
	for (_i = 1; _i <= _end; ++_i) {
		_name = name_get(union, _i)

		if (!(_name in _set)) {
			_set[_name] = union
		} else {
			check_unions_unique_names_repeat_fail( \
				_name,                             \
				_set[_name],                       \
				union,                             \
				_path                              \
			)
		}

		if (union_is(_name))
			check_unions_unique_names(_name, _path, _set)
	}
}
function check_unions_unique_names_recurse_fail(path, guard) {
	error_quit(sprintf("recursive reference of unions:%s->%s", path, guard))
}
function check_unions_unique_names_repeat_fail(name, union_start, union_end,
path) {
	error_print(sprintf("multiple occurrences of name '%s'", name))
	pstderr(sprintf("first union: %s", union_start))
	pstderr(sprintf("last  union: %s", union_end))
	pstderr(sprintf("path:%s", path))
	exit_failure()
}
# </unions>

function do_checks() {
	check_types()
	check_unions()
}
# </checks>

# <resolve>
function resolved_union_save(union, types) {
	_B_resolved_union_tbl[union] = types
	_B_resolved_union_rev_tbl[types] = union
}
function resolved_union_is(union) {
	return (union in _B_resolved_union_tbl)
}
function resolved_union_get(union) {
	return (union in _B_resolved_union_tbl) ? _B_resolved_union_tbl[union] : ""
}
function resolved_union_get_rev(types) {
	return (types in _B_resolved_union_rev_tbl) \
			? _B_resolved_union_rev_tbl[types] : ""
}

function resolve_unions_of_types(    _i, _end) {
	_end = type_count()
	for (_i = 1; _i <= _end; ++_i)
		resolve_unions_of_type_members(type_get(_i))
}

function resolve_unions_of_type_members(type,    _i, _end, _mtype) {
	_end = has_count(type)
	for (_i = 1; _i <= _end; ++_i) {
		_mtype = has_get_mtype(type, _i)
		if (union_is(_mtype)) {
			if (!resolved_union_is(_mtype))
				resolved_union_save(_mtype, resolve_union(_mtype))
			has_set_mtype(type, _i, resolved_union_get(_mtype))
		}
	}
}

function resolve_union(union, _types,    _i, _end, _name, _next) {
	_end = name_count(union)
	for (_i = 1; _i <= _end; ++_i) {
		_name = name_get(union, _i)

		if (type_is(_name))
			_next = _name
		else if (union_is(_name))
			_next = resolve_union(_name)
		else
			error_quit("if you see this there's a bug")

		_types = !(_types) ? _next : (_types "|" _next)
	}
	return _types
}

function resolve_unions_to_types() {
	resolve_unions_of_types()
}
# </resolve>

# <header>
function gen_union_cmnts(    _i, _end, _union) {
	_end = union_count()
	for (_i = 1; _i <= _end; ++_i) {
		_union = union_get(_i)
		emit("#")
		emit(sprintf("# union %s", _union))
		gen_union_name_cmnts(_union)
	}
}
function gen_union_name_cmnts(union,    _i, _end) {
	_end = name_count(union)
	for (_i = 1; _i <= _end; ++_i)
		emit(sprintf("# name %s", name_get(union, _i)))
}

function gen_type_cmnts(    _i, _end, _type) {
	_end = type_count()
	for (_i = 1; _i <= _end; ++_i) {
		_type = type_get(_i)
		emit("#")
		emit(sprintf("# type %s", _type))
		gen_type_memb_cmnts(_type)
	}
}
function gen_type_memb_cmnts(type,    _i, _end, _memb, _mtype, _rev_union) {
	_end = has_count(type)
	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get_memb(type, _i)
		_mtype = has_get_mtype(type, _i)
		if ((_rev_union = resolved_union_get_rev(_mtype))) {
			emit(sprintf("# # %s is %s", _rev_union, _mtype))
			emit(sprintf("# has %s %s", _memb, _rev_union))
		} else {
			emit(sprintf("# has %s %s", _memb, _mtype))
		}
	}
}

function gen_struct_cmnts() {
	emit("# structs:")
	emit("#")
	emit(sprintf("# prefix %s", prefix_get()))
	gen_union_cmnts()
	gen_type_cmnts()
	emit("#")
}
# </header>

function generate() {
	do_checks()
	resolve_unions_to_types()
	tag_open(tag_structs())
	gen_struct_cmnts()
	gen_base()
	tag_open("types")
	gen_types()
	tag_close("types")
	tag_close(tag_structs())
}
# </generate>
