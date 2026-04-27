function errq(msg) {
	print msg > "/dev/stderr"
	exit(1)
}
function assert(expr, str) {
	if (!str)
		errq("asser() called without str")
	if (!expr)
		errq(sprintf("%s is false", str))
}

function _state_make(_1, _2, _3, _4) {
	return ( \
	_1 _RDPG_SEP() \
	_2 _RDPG_SEP() \
	_3 _RDPG_SEP() \
	_4 _RDPG_SEP() \
	)
}
function _state_implamnt(_1, _2, _3, _4) {
	_RDPG_curr_tok    = _1
	_RDPG_had_error   = _2
	_RDPG_expect_type = _3
	_RDPG_expect_what = _4
}

function test_state(    _st_a, _st_rdpg) {
	_st_rdpg = rdpg_state_get()
	_st_a = _state_make("foo", 777, "bar", "baz")
	_state_implamnt("foo", 777, "bar", "baz")

	assert(_st_rdpg != _st_a, "expr 1")
	_st_rdpg = rdpg_state_get()
	assert(_st_rdpg == _st_a, "expr 2")

	_st_b = _state_make("FOO", 7777, "BAR", "BAZ")
	assert(_st_b != _st_a, "expr 3")

	rdpg_state_set(_st_b)
	_st_rdpg = rdpg_state_get()
	assert(_st_rdpg == _st_b, "expr 4")

	rdpg_state_set(_st_a)
	_st_rdpg = rdpg_state_get()
	assert(_st_rdpg == _st_a, "expr 5")
}

function main() {
	test_state()
}

BEGIN {
	main()
}
