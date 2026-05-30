BEGIN {
	main()
}

function ast_errq(msg) {
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
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)
	assert(!ast_testu_get_x(_ent), ++_a)

	_type = ast_type_a_make()
	ast_testu_set_x(_ent, _type)
	assert(ast_type_of(ast_testu_get_x(_ent)) == AST_TYPE_A(), ++_a)
	assert(ast_testu_get_x(_ent) == _type, ++_a)

	_type = ast_type_b_make()
	ast_testu_set_x(_ent, _type)
	assert(ast_type_of(ast_testu_get_x(_ent)) == AST_TYPE_B(), ++_a)
	assert(ast_testu_get_x(_ent) == _type, ++_a)

	_type = ast_type_c_make()
	ast_testu_set_x(_ent, _type)
	assert(ast_type_of(ast_testu_get_x(_ent)) == AST_TYPE_C(), ++_a)
	assert(ast_testu_get_x(_ent) == _type, ++_a)

	_type = ast_type_d_make()
	ast_testu_set_x(_ent, _type)
	assert(ast_type_of(ast_testu_get_x(_ent)) == AST_TYPE_D(), ++_a)
	assert(ast_testu_get_x(_ent) == _type, ++_a)
}

function test_no_ast_1(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	ast_testu_get_x(_type)
}

function test_no_ast_2(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	ast_testu_set_x(_type, "foo")
}

function test_no_ast_3(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	ast_testu_set_x(_ent, "foo")
}

function test_bad_ast_1(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	_type = ast_type_no_make()
	ast_testu_get_x(_type)
}

function test_bad_ast_2(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	_type = ast_type_no_make()
	ast_testu_set_x(_type, _ent)
}

function test_bad_type(    _ent, _type, _a) {
	_ent = ast_testu_make()
	assert(ast_type_of(_ent) == AST_TESTU(), ++_a)

	_type = ast_type_no_make()
	ast_testu_set_x(_ent, _type)
}

function main() {
	if (Ok)
		test_ok()
	if (1 == NoEnt)
		test_no_ast_1()
	if (2 == NoEnt)
		test_no_ast_2()
	if (3 == NoEnt)
		test_no_ast_3()
	if (1 == BadEnt)
		test_bad_ast_1()
	if (2 == BadEnt)
		test_bad_ast_1()
	if (BadType)
		test_bad_type()
}
