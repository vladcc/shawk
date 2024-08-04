# <generate>
# <data>
function _set(k, v) {_B_structs[k] = v}
function _get(k) {return _B_structs[k]}

function prefix_save(str) {_set("prefix", str)}
function prefix_get() {return _get("prefix")}

function type_save(str,    _n) {
	_set("type.count", (_n = _get("type.count")+1))
	_set(sprintf("type=%d", _n), str)
}
function type_count() {return _get("type.count")}
function type_get(n) {return _get(sprintf("type=%d", n))}
function type_last() {return type_get(type_count())}

function has_save(str,    _type, _n, _x) {
	_type = type_last()
	_x = sprintf("has.count=%s", _type)
	_set(_x, (_n = _get(_x)+1))
	_x = sprintf("has.%d=%s", _n, _type)
	_set(_x, str)
}
function has_count(type) {return _get(sprintf("has.count=%s", type))}
function has_get(type, n) {return _get(sprintf("has.%d=%s", n, type))}
# </data>

function tag_structs() {return ("structs-" prefix_get())}
function tag_open(tag) {print sprintf("# <%s>", tag)}
function tag_close(tag) {print sprintf("# <\\%s>", tag)}
function make_fnm(str,    _pref) {return (prefix_get() "_" str)}
function make_dbnm() {return sprintf("_STRUCTS_%s_db", prefix_get())}

function gen_base(    _fname, _db_nm) {
	tag_open("private")
	_db_nm = make_dbnm()

	_fname = ("_" make_fnm("set"))
	print sprintf("function %s(k, v) {%s[k] = v}", _fname, _db_nm)

	_fname = ("_" make_fnm("get"))
	print sprintf("function %s(k) {return %s[k]}", _fname, _db_nm)

	_fname = ("_" make_fnm("type_chk"))
	print sprintf("function %s(ent, texp) {", _fname)
	print sprintf("\tif (%s(ent) == texp)\n\t\treturn", make_fnm("type_of"))
	print sprintf("\t%s_errq(sprintf(\"entity '%%s' expected type '%%s', actual type '%%s'\", ent, texp, %s(ent)))", prefix_get(), make_fnm("type_of"))
	print "}"
	tag_close("private")

	print ""

	_fname = make_fnm("clear")
	print sprintf("function %s() {delete %s}", _fname, _db_nm)

	_fname = make_fnm("is")
	print sprintf("function %s(ent) {return (ent in %s)}", _fname, _db_nm)

	_fname = make_fnm("type_of")
	print sprintf("function %s(ent) {", _fname)
	print sprintf("\tif (ent in %s)\n\t\treturn %s[ent]", _db_nm, _db_nm)
	print sprintf("\t%s_errq(sprintf(\"'%%s' not an entity\", ent))", prefix_get())
	print "}"

	_fname = make_fnm("new")
	print sprintf("function %s(type,    _ent) {", _fname)
	print sprintf("\t_%s(\"ents\", (_ent = _%s(\"ents\")+1))", make_fnm("set"), make_fnm("get"))
	print "\t_ent = (\"_n\" _ent)"
	print sprintf("\t_%s(_ent, type)", make_fnm("set"))
	print "\treturn _ent"
	print "}"
}

function gen_type(type,    _i, _end, _memb, _pref) {
	_pref = prefix_get()
	_end = has_count(type)
	printf("function %s_make(", make_fnm(type))
	for (_i = 1; _i <= _end; ++_i)
		printf("%s, ", has_get(type, _i))
	print "   _ent) {"
	print sprintf("\t_ent = %s(\"%s\")", make_fnm("new"), type)
	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get(type, _i)
		print sprintf("\t%s_%s_set_%s(_ent, %s)", _pref, type, _memb, _memb)
	}
	print "\treturn _ent"
	print "}"
	print ""

	for (_i = 1; _i <= _end; ++_i) {
		_memb = has_get(type, _i)
		print sprintf("function %s_%s_set_%s(ent, %s) {", _pref, type, _memb, _memb)
		print sprintf("\t_%s(ent, \"%s\")", make_fnm("type_chk"), type)
		print sprintf("\t_%s((\"%s=\" ent), %s)", make_fnm("set"), _memb, _memb)
		print "}"
		print sprintf("function %s_%s_get_%s(ent) {", _pref, type, _memb)
		print sprintf("\t_%s(ent, \"%s\")", make_fnm("type_chk"), type)
		print sprintf("\treturn _%s((\"%s=\" ent))", make_fnm("get"), _memb)
		print "}"
		print ""
	}
}

function gen_types(    _i, _end, _type) {
	_end = type_count()
	for (_i = 1; _i <= _end; ++_i) {
		_type = type_get(_i)
		tag_open(sprintf("type-%s", _type))
		print sprintf("function %s() {return \"%s\"}", toupper(make_fnm(_type)), _type)
		print ""
		gen_type(_type)
		tag_close(sprintf("type-%s", _type))
	}
}

function generate() {
	gen_base()
	tag_open("types")
	gen_types()
	tag_close("types")
}
# </generate>
