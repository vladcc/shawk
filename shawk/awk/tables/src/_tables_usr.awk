# <misc>
function new(name) {return ("_n-" ++_B_new_id)}
function is_name_arr(nm) {return (nm ~ /\[\]$/)}
function unarray(nm) {
	sub(/\[\]$/, "", nm)
	return nm
}
# </misc>

# <input>
function defn_save(name) {
	defn_new(name)
}

function field_save(name,    _is_arr, _field_id) {
	if (_is_arr = is_name_arr(name))
		name = unarray(name)
	_field_id = field_new(name, _is_arr)
	defn_add_field(defn_last(), _field_id)
}
# </input>

# <generate>
# <data>
function __set(k, v) {_B_tables[k] = v}
function __get(k) {return _B_tables[k]}
function __has(k) {return (k in _B_tables)}

function _set_count(name, count) {__set((name ".count"), count)}
function _get_count(name)        {return __get((name ".count"))}

function _set_idx(name, idx, val) {__set((name "." idx), val)}
function _get_idx(name, idx)      {return __get((name "." idx))}

function prefix_save(str) {__set("prefix", str)}
function prefix_get()     {return __get("prefix")}

# <defn>
function defn_new(name,    _count, _id) {
	_id = new()
	_count = _get_count("defn")+1
	_set_count("defn", _count)
	_set_idx("defn", _count, _id)
	defn_set_name(_id, name)
	return _id
}
function defn_get(n)  {return _get_idx("defn", n)}
function defn_count() {return _get_count("defn")}
function defn_last()  {return defn_get(defn_count())}

function defn_set_name(defn_id, name) {
	__set(sprintf("defn.%s.name", defn_id), name)
}
function defn_get_name(defn_id) {
	return __get(sprintf("defn.%s.name", defn_id))
}

function defn_add_field(defn_id, field_id,    _count, _n) {
	_n = sprintf("defn.%s.field", defn_id)
	_count = _get_count(_n)+1
	_set_count(_n, _count)
	_set_idx(_n, _count, field_id)
}
function defn_get_field(defn_id, n) {
	return _get_idx(sprintf("defn.%s.field", defn_id), n)
}
function defn_set_field(defn_id, n, field_id) {
	_set_idx(sprintf("defn.%s.field", defn_id), n, field_id)
}
function defn_count_field(defn_id) {
	return _get_count(sprintf("defn.%s.field", defn_id))
}
function defn_last_field(defn_id) {
	return defn_get_field(defn_id, defn_count_field(defn_id))
}
# </defn>

# <field>
function field_new(name, is_arr,    _count, _id) {
	_id = new()
	_count = _get_count("field")+1
	_set_count("field", _count)
	_set_idx("field", _count, _id)
	field_set_name(_id, name)
	field_set_is_arr(_id, is_arr)
	return _id
}
function field_count() {return _get_count("field")}
function field_get(n)  {return _get_idx("field", n)}
function field_last()  {return field_get(field_count())}

function field_set_name(field_id, name) {
	__set(sprintf("field.%s.name", field_id), name)
}
function field_get_name(field_id) {
	return __get(sprintf("field.%s.name", field_id))
}
function field_set_is_arr(field_id, is_arr) {
	__set(sprintf("field.%s.is_arr", field_id), is_arr)
}
function field_get_is_arr(field_id) {
	return __get(sprintf("field.%s.is_arr", field_id))
}
# </field>
# </data>

function tag_tables()   {return ("tables-" prefix_get())}
function tag_open(tag)  {print sprintf("# <%s>", tag)}
function tag_close(tag) {print sprintf("# <\\%s>", tag)}
function make_fnm(str)  {return (prefix_get() "_" str)}
function make_dbnm()    {return sprintf("__TABLES_%s_db__", prefix_get())}
function emit(str)      {tabs_print(str)}

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
				"entity type '%%s'\",\n\t\tent, texp, %s(ent)))"              \
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
	emit(sprintf("# prefix %s", prefix_get()))
	gen_defn_cmnts()
	emit("#")
}
# </header>

function generate() {
	gen_header_cmnt()
	tag_open(tag_tables())
	gen_struct_cmnts()
	gen_base()
	tag_open("defns")
	tag_close("defns")
	tag_close(tag_tables())
}
# </generate>
