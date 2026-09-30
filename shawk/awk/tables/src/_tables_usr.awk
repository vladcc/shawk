# <misc>
function is_name_arr(nm) {return (nm ~ /\[\]$/)}
function unarray(nm) {
	sub(/\[\]$/, "", nm)
	return nm
}
function nl() {print ""}

function tables_errq(msg) {
	error_quit(msg)
}
# </misc>

# <input>
function prefix_save(name,    _prefix_id) {
	_prefix_id = prefix_new()
	prefix_set_name(_prefix_id, name)
}

function prefix_name() {
	return prefix_get_name(prefix_last())
}

function defn_save(name,    _defn_id) {
	_defn_id = defn_new()
	defn_set_name(_defn_id, name)
}

function field_save(name,    _is_arr, _field_id) {
	if (_is_arr = is_name_arr(name))
		name = unarray(name)
	_field_id = field_new(name, _is_arr)
	field_set_name(_field_id, name)
	field_set_is_arr(_field_id, _is_arr)
	defn_add_field(defn_last(), _field_id)
}
# </input>

# <generate>
function tag_tables()   {return ("tables-" prefix_name())}
function tag_open(tag)  {print sprintf("# <%s>", tag)}
function tag_close(tag) {print sprintf("# <\\%s>", tag)}
function make_fnm(str)  {return (prefix_name() "_" str)}
function make_dbnm()    {return sprintf("__TABLES_%s_db__", prefix_name())}
function emit(str)      {tabs_print(str)}

function gen_base(    _fname, _db_nm) {
	tag_open("private")
	_db_nm = make_dbnm()

	_fname = ("_" make_fnm("set"))
	emit(sprintf("function %s(k, v) {%s[k] = v}", _fname, _db_nm))

	_fname = ("_" make_fnm("get"))
	emit(sprintf("function %s(k) {return %s[k]}", _fname, _db_nm))

	_fname = ("_" make_fnm("set_count"))
	emit(sprintf("function %s(k, c) {%s[(k \".count\")] = c}", _fname, _db_nm))

	_fname = ("_" make_fnm("get_count"))
	emit(sprintf("function %s(k) {return %s[(k \".count\")]}", _fname, _db_nm))

	_fname = ("_" make_fnm("set_idx"))
	emit(sprintf("function %s(k, i, v) {%s[(k \".\" i)] = v}", _fname, _db_nm))

	_fname = ("_" make_fnm("get_idx"))
	emit(sprintf("function %s(k, i,    _x) {", _fname))
	tabs_inc()
		emit("_x = (k \".\" i)")
		emit(sprintf("if (_x in %s)", _db_nm))
		tabs_inc()
			emit(sprintf("return %s[_x]", _db_nm))
		tabs_dec()
		emit(sprintf("%s_errq(sprintf(\"entity '%%s': not an index\", _x))",
				prefix_name()))
	tabs_dec()
	emit("}")

	#emit(sprintf("function %s(k, i) {return %s[(k \".\" i)]}", _fname, _db_nm))

	_fname = ("_" make_fnm("type_chk"))
	emit(sprintf("function %s(ent, texp) {", _fname))
	tabs_inc()
		emit(sprintf("if (%s(ent) == texp)", make_fnm("type_of")))
			tabs_inc()
			emit("return")
			tabs_dec()
		emit(                                                                 \
			sprintf(                                                          \
				(                                                             \
				"%s_errq(sprintf(\"entity '%%s': expected type match '%%s', " \
				"entity type '%%s'\",\n\t\tent, texp, %s(ent)))"              \
				),                                                            \
				prefix_name(),                                                 \
				make_fnm("type_of")                                           \
			)                                                                 \
		)
	tabs_dec()
	emit("}")
	_fname = ("_" make_fnm("new"))
	emit(sprintf("function %s(type,    _ent) {", _fname))
	tabs_inc()
		emit(sprintf("_ent = _%s(\"ents\")+1", make_fnm("get")))
		emit(sprintf("_%s(\"ents\", _ent)", make_fnm("set")))
		emit(                                                  \
			sprintf(                                           \
				"_ent = (\"_%s-\" _%s(\"gen\")+0 \"-\" _ent)", \
				prefix_name(),                                  \
				make_fnm("get")                                \
			)                                                  \
		)
		emit(sprintf("_%s(_ent, type)", make_fnm("set")))
		emit("return _ent")
	tabs_dec()
	emit("}")
	tag_close("private")

	nl()

	_fname = make_fnm("clear")
	emit(sprintf("function %s(    _gen) {", _fname))
	tabs_inc()
		emit(sprintf("_gen = _%s(\"gen\")", make_fnm("get")))
		emit(sprintf("delete %s", _db_nm))
		emit(sprintf("_%s(\"gen\", _gen+1)", make_fnm("set")))
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
				prefix_name()                                      \
			)                                                     \
		)
	tabs_dec()
	emit("}")
}

# <header>
function gen_defn_cmnts(    _i, _end, _defn_id) {
	_end = defn_count()
	for (_i = 1; _i <= _end; ++_i) {
		_defn_id = defn_get(_i)
		emit("#")
		emit(sprintf("# defn %s", defn_get_name(_defn_id)))
		gen_defn_field_cmnts(_defn_id)
	}
}
function gen_defn_field_cmnts(defn_id,    _i, _end, _str, _field_id) {
	_end = defn_count_field(defn_id)
	for (_i = 1; _i <= _end; ++_i) {
		_field_id = defn_get_field(defn_id, _i)
		_str = sprintf("# field %s", field_get_name(_field_id))
		if (field_get_is_arr(_field_id))
			_str = (_str "[]")
		emit(_str)
	}
}

function gen_header_cmnt() {
	emit(sprintf("# generated by %s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
	emit("#")
}

function gen_struct_cmnts() {
	emit("#")
	emit(sprintf("# prefix %s", prefix_name()))
	gen_defn_cmnts()
	emit("#")
}
# </header>

function generate_field(defn_id, field_id,    _defn_nm, _field_nm) {
	_defn_nm  = defn_get_name(defn_id)
	_field_nm = field_get_name(field_id)

	if (field_get_is_arr(field_id)) {
		nl()
		emit(sprintf("function %s_add_%s(%s_id, %s,    _count, _n) {", _defn_nm,
			_field_nm, _defn_nm, _field_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("_n = (\"%s.\" %s_id \".%s\")", _defn_nm, _defn_nm,
				_field_nm))
			emit(sprintf("_count = _%s(_n)+1", make_fnm("get_count")))
			emit(sprintf("_%s(_n, _count)", make_fnm("set_count")))
			emit(sprintf("_%s(_n, _count, %s)", make_fnm("set_idx"), _field_nm))
		tabs_dec()
		emit("}")

		emit(sprintf("function %s_get_%s(%s_id, n) {", _defn_nm, _field_nm,
			_defn_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("return _%s((\"%s.\" %s_id \".%s\"), n)",
				make_fnm("get_idx"), _defn_nm, _defn_nm, _field_nm))
		tabs_dec()
		emit("}")

		emit(sprintf("function %s_set_%s(%s_id, n, %s) {", _defn_nm, _field_nm,
			_defn_nm, _field_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("return _%s((\"%s.\" %s_id \".%s\"), n, %s)",
				make_fnm("set_idx"), _defn_nm, _defn_nm, _field_nm, _field_nm))
		tabs_dec()
		emit("}")

		emit(sprintf("function %s_count_%s(%s_id) {", _defn_nm, _field_nm,
			_defn_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("return _%s((\"%s.\" %s_id \".%s\"))",
				make_fnm("get_count"), _defn_nm, _defn_nm, _field_nm))
		tabs_dec()
		emit("}")

		emit(sprintf("function %s_last_%s(%s_id) {", _defn_nm, _field_nm,
			_defn_nm))
		tabs_inc()
			emit(sprintf("return %s_get_%s(%s_id, %s_count_%s(%s_id))",
				_defn_nm, _field_nm, _defn_nm, _defn_nm, _field_nm, _defn_nm))
		tabs_dec()
		emit("}")
	} else {
		nl()
		emit(sprintf("function %s_set_%s(%s_id, %s) {", _defn_nm, _field_nm,
			_defn_nm, _field_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("_%s((\"%s.\" %s_id \".%s\"), %s)", make_fnm("set"),
				_defn_nm, _defn_nm, _field_nm, _field_nm))
		tabs_dec()
		emit("}")

		emit(sprintf("function %s_get_%s(%s_id) {", _defn_nm, _field_nm,
			_defn_nm))
		tabs_inc()
			emit(sprintf("_%s(%s_id, \"%s\")", make_fnm("type_chk"), _defn_nm,
				_defn_nm))
			emit(sprintf("return _%s((\"%s.\" %s_id \".%s\"))", make_fnm("get"),
				_defn_nm, _defn_nm, _field_nm))
		tabs_dec()
		emit("}")
	}
}

function generate_fields(defn_id,    _i, _end) {
	_end = defn_count_field(defn_id)
	for (_i = 1; _i <= _end; ++_i)
		generate_field(defn_id, defn_get_field(defn_id, _i))
}

function generate_defn(defn_id,    _name) {
	_name = defn_get_name(defn_id)

	tag_open(sprintf("type-%s", _name))
	emit(sprintf("function %s() {return \"%s\"}", toupper(make_fnm(_name)),
		_name))
	nl()

	emit(sprintf("function %s_new(    _count, _id, _type) {", _name))
	tabs_inc()
		emit(sprintf("_type = \"%s\"", _name))
		emit(sprintf("_id = _%s(_type)", make_fnm("new")))
		emit(sprintf("_count = _%s(_type)+1", make_fnm("get_count")))
		emit(sprintf("_%s(_type, _count)", make_fnm("set_count")))
		emit(sprintf("_%s(_type, _count, _id)", make_fnm("set_idx")))
		emit("return _id")
	tabs_dec()
	emit("}")

	emit(sprintf("function %s_get(n) {return _%s(\"%s\", n)}", _name,
		make_fnm("get_idx"), _name))

	emit(sprintf("function %s_count() {return _%s(\"%s\")}", _name,
		make_fnm("get_count"), _name))

	emit(sprintf("function %s_last() {return %s_get(%s_count())}", _name,
		_name, _name))

	generate_fields(defn_id)
	tag_close(sprintf("type-%s", _name))
}

function generate_defns(    _i, _end, _defn_id) {
	_end = defn_count()
	for (_i = 1; _i <= _end; ++_i)
		generate_defn(defn_get(_i))
}

function generate() {
	gen_header_cmnt()
	tag_open(tag_tables())
	gen_struct_cmnts()
	gen_base()
	tag_open("defns")
	generate_defns()
	tag_close("defns")
	tag_close(tag_tables())
}
# </generate>
