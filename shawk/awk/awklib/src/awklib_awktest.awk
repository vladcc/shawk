#@ <awklib_awktest>
#@ Library: at
#@ Description: A test library. The general idea is to call
#@ at_awklib_awktest_required() at the start of your test script to make
#@ sure the library is present, then call at_test_begin() with the name
#@ of your test. After at_test_begin(), call at_true() with your test
#@ conditions. at_true() logs when its argument is true and does nothing
#@ else. If its argument is false, however, it dumps the logs with an
#@ error and quits with an error code. This way you'll always get a dump
#@ of only the test which failed and will know exactly which call to
#@ at_true() in that test experienced the failure.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

# <public>
#@ Description: Produces an error if the library is not available.
#@ Should be called before any testing occurs.
#@ Returns: Nothing.
#
function at_awklib_awktest_required() {}

#
#@ Description: Clears the log, initializes internal states, sets the
#@ test name to the current test.
#@ Returns: Nothing.
#
function at_test_begin(test_name) {

	_at_init_test(test_name)
}

#
#@ Description: Logs success if 'val' is true, logs and error, dumps
#@ the log to stdout, and exits with an error code otherwise.
#@ Returns: Nothing.
#
function at_true(val) {

	_at_inc_calls()

	if (val) {
		_at_log(sprintf("%d true %s",
			_at_get_calls(), _at_get_test_name()))
	} else {
		_at_log(sprintf("error: %d false %s",
			_at_get_calls(), _at_get_test_name()))
		_at_dump_log()
		exit(1)
	}
}

#
#@ Description: Dumps the log.
#@ Returns: Nothing.
#
function at_dump_log() {

	_at_dump_log()
}

#
#@ Description: Prints the test names for the tests executed so for.
#@ Returns: Nothing.
#
function at_report(    _i) {

	for (_i = 1; _i <= _AWKLIB_at__test_num; ++_i)
		print _AWKLIB_at__test_name[_i]
}
# </public>

function _at_init_test(name) {

	_at_clear_calls()
	_at_clear_log()
	_at_set_test_name(name)
	_at_log(sprintf("###### %s ######", _at_get_test_name()))
}
function _at_set_test_name(name) {

	_AWKLIB_at__test_name[++_AWKLIB_at__test_num] = name
}
function _at_get_test_name() {

	return _AWKLIB_at__test_name[_AWKLIB_at__test_num]
}

function _at_inc_calls() {++_AWKLIB_at__at_true_num_calls}
function _at_get_calls() {return _AWKLIB_at__at_true_num_calls}
function _at_clear_calls() {_AWKLIB_at__at_true_num_calls = 0}

function _at_clear_log() {

	_AWKLIB_at__result_log_len = 0
	delete _AWKLIB_at__result_log
}
function _at_log(str) {

	_AWKLIB_at__result_log[++_AWKLIB_at__result_log_len] = str
}
function _at_dump_log(    _i) {

	for (_i = 1; _i <= _AWKLIB_at__result_log_len; ++_i)
		print _AWKLIB_at__result_log[_i]
}
#@ </awklib_awktest>
