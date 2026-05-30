BEGIN {
	main()
}

function ent_errq(msg) {
	print sprintf("error: %s", msg) > "/dev/stderr"
	exit(1)
}

function assert(x, a) {
	if (x)
		return
	print sprintf("error: assertion %s failed", a) > "/dev/stderr"
	exit(1)
}

function test_ok(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)
	assert(!ent_testu_get_x(_ent), ++_a)

	_type = ent_type_a_make()
	ent_testu_set_x(_ent, _type)
	assert(ent_type_of(ent_testu_get_x(_ent)) == ENT_TYPE_A(), ++_a)
	assert(ent_testu_get_x(_ent) == _type, ++_a)

	_type = ent_type_b_make()
	ent_testu_set_x(_ent, _type)
	assert(ent_type_of(ent_testu_get_x(_ent)) == ENT_TYPE_B(), ++_a)
	assert(ent_testu_get_x(_ent) == _type, ++_a)

	_type = ent_type_c_make()
	ent_testu_set_x(_ent, _type)
	assert(ent_type_of(ent_testu_get_x(_ent)) == ENT_TYPE_C(), ++_a)
	assert(ent_testu_get_x(_ent) == _type, ++_a)

	_type = ent_type_d_make()
	ent_testu_set_x(_ent, _type)
	assert(ent_type_of(ent_testu_get_x(_ent)) == ENT_TYPE_D(), ++_a)
	assert(ent_testu_get_x(_ent) == _type, ++_a)
}

function test_no_ent_1(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	ent_testu_get_x(_type)
}

function test_no_ent_2(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	ent_testu_set_x(_type, "foo")
}

function test_no_ent_3(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	ent_testu_set_x(_ent, "foo")
}

function test_bad_ent_1(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	_type = ent_type_no_make()
	ent_testu_get_x(_type)
}

function test_bad_ent_2(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	_type = ent_type_no_make()
	ent_testu_set_x(_type, _ent)
}

function test_bad_type(    _ent, _type, _a) {
	_ent = ent_testu_make()
	assert(ent_type_of(_ent) == ENT_TESTU(), ++_a)

	_type = ent_type_no_make()
	ent_testu_set_x(_ent, _type)
}

function main() {
	if (Ok)
		test_ok()
	if (1 == NoEnt)
		test_no_ent_1()
	if (2 == NoEnt)
		test_no_ent_2()
	if (3 == NoEnt)
		test_no_ent_3()
	if (1 == BadEnt)
		test_bad_ent_1()
	if (2 == BadEnt)
		test_bad_ent_1()
	if (BadType)
		test_bad_type()
}
