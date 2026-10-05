BEGIN {
	main()
}

function tables_errq(msg) {
	print sprintf("test error: %s", msg)
}

function test_err() {
	print "# <errors>"
	defn_get("foo")
	defn_get_name("foo")
	defn_set_name("foo")

	defn_add_field("foo")
	defn_count_field("foo")
	defn_get_field("foo")
	defn_set_field("foo")

	print ""

	field_get("bar")
	field_get_name("bar")
	field_set_name("bar")
	field_get_is_arr("bar")
	field_set_is_arr("bar")
	print "# </errors>"
}

function test_gen(    _defn_id, _fld_id) {
	print "# <gen>"
	print "1"
	_defn_id = defn_new()
	defn_set_name(_defn_id, "test-defn")
	print _defn_id
	defn_get_name(_defn_id)
	print defn_new()
	print defn_new()
	print ""
	_fld_id = field_new()
	field_set_name(_fld_id, "test-field")
	print _fld_id
	field_get_name(_fld_id)
	print field_new()
	print field_new()
	tables_clear()
	print "2"
	print defn_new()
	defn_get_name(_defn_id)
	print defn_new()
	print defn_new()
	print ""
	print field_new()
	field_get_name(_fld_id)
	print field_new()
	print field_new()
	tables_clear()
	print "3"
	print defn_new()
	defn_get_name(_defn_id)
	print defn_new()
	print defn_new()
	print ""
	print field_new()
	field_get_name(_fld_id)
	print field_new()
	print field_new()
	print "# </gen>"
}

function main() {
	test_err()
	test_gen()
}
