#!/usr/bin/awk -f

function arr_to_str(arr, len,    _i, _str) {
	_str = ""
	for (_i = 1; _i <= len; ++_i)
		_str = (_str) ? (_str "\n" arr[_i]) : arr[_i]
	return _str
}

# test syntax and logical errors
function test_make_fsm_err(    _arr_in, _ilen, _arr_out, _olen) {
	at_test_begin("make_fsm_err()")
	
	_arr_out[1] = "should be gone"
	
	_ilen = 0
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(0 == _arr_out[1])
	at_true("no input" == _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> begin"
	_olen = fsm_make(_arr_out, _arr_in, _ilen, "#foo")
	at_true(0 == _olen)
	at_true(0 == _arr_out[1])
	at_true("'#foo' does not match '^[_[:alpha:]][_[:alnum:]]*$'" \
		== _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin state_1"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(1 == _arr_out[1])
	at_true("bad separator" == _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "@begin -> state_1"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(1 == _arr_out[1])
	at_true("'@begin' does not match '^[_[:alpha:]][_[:alnum:]]*$'" \
		== _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(1 == _arr_out[1])
	at_true("state 'state_1' not defined" == _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> begin |"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(2 == _arr_out[1])
	at_true("bad separator" == _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> begin"
	_arr_in[++_ilen] = "begin -> state_2"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(3 == _arr_out[1])
	at_true("state 'begin' redefined" == _arr_out[2])
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> begin"
	_arr_in[++_ilen] = "state_2 -> state_1"
	_olen = fsm_make(_arr_out, _arr_in, _ilen)
	at_true(0 == _olen)
	at_true(3 == _arr_out[1])
	at_true("state 'state_2' unreachable" == _arr_out[2])
}

# <EVENT_TEST>

# NOTE: The source output is compared as a string, then the same output
# is edited and tested as an implementation. If the source output
# becomes different than FSM_EVENT_SOURCE(), then stm has to be
# re-implemented.

function FSM_EVENT_SOURCE() {
	return \
"# <stm>\n"\
"# <handlers>\n"\
"function stm_on_begin() {\n"\
"\n"\
"}\n"\
"function stm_on_state_1() {\n"\
"\n"\
"}\n"\
"function stm_on_state_2() {\n"\
"\n"\
"}\n"\
"function stm_on_end() {\n"\
"\n"\
"}\n"\
"function stm_on_error(curr_st, expected, got) {\n"\
"\n"\
"}\n"\
"# </handlers>\n"\
"\n"\
"# <constants>\n"\
"function STM_BEGIN() {return \"begin\"}\n"\
"function STM_STATE_1() {return \"state_1\"}\n"\
"function STM_STATE_2() {return \"state_2\"}\n"\
"function STM_END() {return \"end\"}\n"\
"function _STM_STATE() {return \"state\"}\n"\
"# </constants>\n"\
"\n"\
"# <functions>\n"\
"function stm_get_state(stm) {return stm[_STM_STATE()]}\n"\
"function _stm_set_state(stm, next_st) {stm[_STM_STATE()] = next_st}\n"\
"function stm_next(stm, next_st,    _st) {\n"\
"\n"\
"	_st = stm_get_state(stm)\n"\
"	if (\"\" == _st) {\n"\
"		if (STM_BEGIN() == next_st)\n"\
"		{stm_on_begin(); _stm_set_state(stm, next_st)}\n"\
"		else\n"\
"		{stm_on_error(_st, STM_BEGIN(), next_st)}\n"\
"	}\n"\
"	else if (STM_BEGIN() == _st) {\n"\
"		if (STM_STATE_1() == next_st)\n"\
"		{stm_on_state_1(); _stm_set_state(stm, next_st)}\n"\
"		else\n"\
"		{stm_on_error(_st, STM_STATE_1(), next_st)}\n"\
"	}\n"\
"	else if (STM_STATE_1() == _st) {\n"\
"		if (STM_STATE_1() == next_st)\n"\
"		{stm_on_state_1(); _stm_set_state(stm, next_st)}\n"\
"		else if (STM_STATE_2() == next_st)\n"\
"		{stm_on_state_2(); _stm_set_state(stm, next_st)}\n"\
"		else if (STM_END() == next_st)\n"\
"		{stm_on_end(); _stm_set_state(stm, next_st)}\n"\
"		else\n"\
"		{stm_on_error(_st, STM_STATE_1()\"|\"STM_STATE_2()\"|\"STM_END(), next_st)}\n"\
"	}\n"\
"	else if (STM_STATE_2() == _st) {\n"\
"		if (STM_END() == next_st)\n"\
"		{stm_on_end(); _stm_set_state(stm, next_st)}\n"\
"		else\n"\
"		{stm_on_error(_st, STM_END(), next_st)}\n"\
"	}\n"\
"	else if (STM_END() == _st) {\n"\
"		if (STM_BEGIN() == next_st)\n"\
"		{stm_on_begin(); _stm_set_state(stm, next_st)}\n"\
"		else\n"\
"		{stm_on_error(_st, STM_BEGIN(), next_st)}\n"\
"	}\n"\
"}\n"\
"# </functions>\n"\
"# </stm>"
}

function test_make_fsm_event(    _arr_in, _ilen, _arr_out, _olen, _stm,
_foo) {
	at_test_begin("make_fsm_event()")
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> state_1 | state_2 | end"
	_arr_in[++_ilen] = "state_2 -> end"
	_arr_in[++_ilen] = "end -> begin"
	
	_olen = fsm_make(_arr_out, _arr_in, _ilen, "stm")
	at_true(_olen > 0)
	
	# this is how the source for the _arr_in fsm is supposed to look
	# like; if it changes, this test will fail
	
	#print arr_to_str(_arr_out, _olen)
	#at_true()
	
	at_true(FSM_EVENT_SOURCE() == arr_to_str(_arr_out, _olen))
	
	_olen = fsm_make(_arr_out, _arr_in, _ilen, "stm", FSM_EVENT())
	at_true(_olen > 0)
	at_true(FSM_EVENT_SOURCE() == arr_to_str(_arr_out, _olen))
}

# <stm>
# <handlers>
function stm_on_begin() {
	_B_event_test_out = STM_BEGIN()
}
function stm_on_state_1() {
	_B_event_test_out = STM_STATE_1()
}
function stm_on_state_2() {
	_B_event_test_out = STM_STATE_2()
}
function stm_on_end() {
	_B_event_test_out = STM_END()
}
function stm_on_error(curr_st, expected, got) {
	_B_event_test_out = \
		sprintf("in state '%s': expected '%s', got '%s'",
			curr_st, expected, got)
}
# </handlers>

# <constants>
function STM_BEGIN() {return "begin"}
function STM_STATE_1() {return "state_1"}
function STM_STATE_2() {return "state_2"}
function STM_END() {return "end"}
function _STM_STATE() {return "state"}
# </constants>

# <functions>
function stm_get_state(stm) {return stm[_STM_STATE()]}
function _stm_set_state(stm, next_st) {stm[_STM_STATE()] = next_st}
function stm_next(stm, next_st,    _st) {

	_st = stm_get_state(stm)
	if ("" == _st) {
		if (STM_BEGIN() == next_st)
		{stm_on_begin(); _stm_set_state(stm, next_st)}
		else
		{stm_on_error(_st, STM_BEGIN(), next_st)}
	}
	else if (STM_BEGIN() == _st) {
		if (STM_STATE_1() == next_st)
		{stm_on_state_1(); _stm_set_state(stm, next_st)}
		else
		{stm_on_error(_st, STM_STATE_1(), next_st)}
	}
	else if (STM_STATE_1() == _st) {
		if (STM_STATE_1() == next_st)
		{stm_on_state_1(); _stm_set_state(stm, next_st)}
		else if (STM_STATE_2() == next_st)
		{stm_on_state_2(); _stm_set_state(stm, next_st)}
		else if (STM_END() == next_st)
		{stm_on_end(); _stm_set_state(stm, next_st)}
		else
		{stm_on_error(_st, STM_STATE_1()"|"STM_STATE_2()"|"STM_END(), next_st)}
	}
	else if (STM_STATE_2() == _st) {
		if (STM_END() == next_st)
		{stm_on_end(); _stm_set_state(stm, next_st)}
		else
		{stm_on_error(_st, STM_END(), next_st)}
	}
	else if (STM_END() == _st) {
		if (STM_BEGIN() == next_st)
		{stm_on_begin(); _stm_set_state(stm, next_st)}
		else
		{stm_on_error(_st, STM_BEGIN(), next_st)}
	}
}
# </functions>
# </stm>

function test_event_impl(    _arr_in, _ilen, _arr_out, _olen, _stm,
_foo) {
	at_test_begin("event_impl()")

	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> state_1 | state_2 | end"
	_arr_in[++_ilen] = "state_2 -> end"
	_arr_in[++_ilen] = "end -> begin"
	
	# use case
	at_true("" == stm_get_state(_stm))
	
	stm_next(_stm, STM_BEGIN())
	at_true(STM_BEGIN() == stm_get_state(_stm))
	at_true(STM_BEGIN() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_1())
	at_true(STM_STATE_1() == stm_get_state(_stm))
	at_true(STM_STATE_1() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_2())
	at_true(STM_STATE_2() == stm_get_state(_stm))
	at_true(STM_STATE_2() == _B_event_test_out)
	
	stm_next(_stm, STM_END())
	at_true(STM_END() == stm_get_state(_stm))
	at_true(STM_END() == _B_event_test_out)
	
	# repeat state
	_stm_set_state(_stm, "")
	at_true("" == stm_get_state(_stm))
	
	stm_next(_stm, STM_BEGIN())
	at_true(STM_BEGIN() == stm_get_state(_stm))
	at_true(STM_BEGIN() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_1())
	at_true(STM_STATE_1() == stm_get_state(_stm))
	at_true(STM_STATE_1() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_1())
	at_true(STM_STATE_1() == stm_get_state(_stm))
	at_true(STM_STATE_1() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_2())
	at_true(STM_STATE_2() == stm_get_state(_stm))
	at_true(STM_STATE_2() == _B_event_test_out)
	
	stm_next(_stm, STM_END())
	at_true(STM_END() == stm_get_state(_stm))
	at_true(STM_END() == _B_event_test_out)
	
	# skip state
	_stm_set_state(_stm, "")
	at_true("" == stm_get_state(_stm))
	
	stm_next(_stm, STM_BEGIN())
	at_true(STM_BEGIN() == stm_get_state(_stm))
	at_true(STM_BEGIN() == _B_event_test_out)
	
	stm_next(_stm, STM_STATE_1())
	at_true(STM_STATE_1() == stm_get_state(_stm))
	at_true(STM_STATE_1() == _B_event_test_out)

	stm_next(_stm, STM_END())
	at_true(STM_END() == stm_get_state(_stm))
	at_true(STM_END() == _B_event_test_out)
	
	# reset and test errors
	_stm_set_state(_stm, "")
	_foo = "foo"
	
	stm_next(_stm, _foo)
	
	at_true("" == stm_get_state(_stm))
	at_true("in state '': expected 'begin', got 'foo'" ==\
		_B_event_test_out)
	at_true("" == stm_get_state(_stm))
	
	stm_next(_stm, STM_BEGIN())
	at_true(STM_BEGIN() == stm_get_state(_stm))
	stm_next(_stm, _foo)
	at_true("in state 'begin': expected 'state_1', got 'foo'" ==\
		_B_event_test_out)
	at_true(STM_BEGIN() == stm_get_state(_stm))
	
	stm_next(_stm, STM_STATE_1())
	at_true(STM_STATE_1() == stm_get_state(_stm))
	stm_next(_stm, _foo)
	at_true(\
	"in state 'state_1': expected 'state_1|state_2|end', got 'foo'" ==\
		_B_event_test_out)
	at_true(STM_STATE_1() == stm_get_state(_stm))
	
	stm_next(_stm, STM_STATE_2())
	at_true(STM_STATE_2() == stm_get_state(_stm))
	stm_next(_stm, _foo)
	at_true("in state 'state_2': expected 'end', got 'foo'" ==\
		_B_event_test_out)
	at_true(STM_STATE_2() == stm_get_state(_stm))
	
	stm_next(_stm, STM_END())
	at_true(STM_END() == stm_get_state(_stm))
	stm_next(_stm, _foo)
	at_true("in state 'end': expected 'begin', got 'foo'" ==\
		_B_event_test_out)
	at_true(STM_END() == stm_get_state(_stm))
}
# </EVENT_TEST>

# <LOOP_TEST>

# NOTE: The source output is compared as a string, then the same output
# is edited and tested as an implementation. If the source output
# becomes different than FSM_LOOP_SOURCE(), then lstm has to be
# re-implemented.

function FSM_LOOP_SOURCE() {
	return \
"# <lstm>\n"\
"# <constants>\n"\
"function LSTM_BEGIN() {return \"begin\"}\n"\
"function LSTM_STATE_1() {return \"state_1\"}\n"\
"function LSTM_STATE_2() {return \"state_2\"}\n"\
"function LSTM_END() {return \"end\"}\n"\
"function _LSTM_STATE() {return \"state\"}\n"\
"# </constants>\n"\
"\n"\
"# <functions>\n"\
"function lstm_get_state(lstm) {return lstm[_LSTM_STATE()]}\n"\
"function lstm_set_state(lstm, next_st) {lstm[_LSTM_STATE()] = next_st}\n"\
"\n"\
"function lstm_loop(    _st, _i, _end) {\n"\
"\n"\
"	for (_i = 1; _i <= _end; ++_i) {\n"\
"\n"\
"		_st = lstm_get_state(lstm)\n"\
"		if (\"\" == _st) {\n"\
"			if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_BEGIN())\n"\
"			}\n"\
"		}\n"\
"		else if (LSTM_BEGIN() == _st) {\n"\
"			if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_STATE_1())\n"\
"			}\n"\
"		}\n"\
"		else if (LSTM_STATE_1() == _st) {\n"\
"			if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_STATE_1())\n"\
"			}\n"\
"			else if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_STATE_2())\n"\
"			}\n"\
"			else if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_END())\n"\
"			}\n"\
"		}\n"\
"		else if (LSTM_STATE_2() == _st) {\n"\
"			if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_END())\n"\
"			}\n"\
"		}\n"\
"		else if (LSTM_END() == _st) {\n"\
"			if (1) {\n"\
"\n"\
"				lstm_set_state(lstm, LSTM_BEGIN())\n"\
"			}\n"\
"		}\n"\
"	}\n"\
"}\n"\
"# </functions>\n"\
"# </lstm>"
}

function test_make_fsm_loop(    _arr_in, _ilen, _arr_out, _olen, _stm,
_foo) {
	at_test_begin("make_fsm_loop()")
	
	_ilen = 0
	_arr_in[++_ilen] = "begin -> state_1"
	_arr_in[++_ilen] = "state_1 -> state_1 | state_2 | end"
	_arr_in[++_ilen] = "state_2 -> end"
	_arr_in[++_ilen] = "end -> begin"
	
	_olen = fsm_make(_arr_out, _arr_in, _ilen, "lstm", FSM_LOOP())
	at_true(_olen > 0)
	
	at_true(FSM_LOOP_SOURCE() == arr_to_str(_arr_out, _olen))	
}

# <lstm>
# <constants>
function LSTM_BEGIN() {return "begin"}
function LSTM_STATE_1() {return "state_1"}
function LSTM_STATE_2() {return "state_2"}
function LSTM_END() {return "end"}
function _LSTM_STATE() {return "state"}
# </constants>

# <functions>
function lstm_get_state(lstm) {return lstm[_LSTM_STATE()]}
function lstm_set_state(lstm, next_st) {lstm[_LSTM_STATE()] = next_st}

function test_loop_impl(    _st, _i, _end) {
	at_test_begin("loop_impl()")
	
	_end = 8
	for (_i = 1; _i <= _end; ++_i) {
		
		_st = lstm_get_state(lstm)
		if (1 == _i) at_true("" == _st)
		else if (2 == _i) at_true(LSTM_BEGIN() == _st)
		else if (3 == _i) at_true(LSTM_STATE_1() == _st)
		else if (4 == _i) at_true(LSTM_STATE_1() == _st)
		else if (5 == _i) at_true(LSTM_STATE_2() == _st)
		else if (6 == _i) at_true(LSTM_END() == _st)
		else if (7 == _i) at_true(LSTM_BEGIN() == _st)
		else if (8 == _i) at_true(LSTM_STATE_1() == _st)
	
		if ("" == _st) {
			if (1 == _i) {

				lstm_set_state(lstm, LSTM_BEGIN())
			}
		}
		else if (LSTM_BEGIN() == _st) {
			if (2 == _i || 7 == _i) {

				lstm_set_state(lstm, LSTM_STATE_1())
			}
		}
		else if (LSTM_STATE_1() == _st) {
			if (3 == _i) {

				lstm_set_state(lstm, LSTM_STATE_1())
			}
			else if (4 == _i) {

				lstm_set_state(lstm, LSTM_STATE_2())
			}
			else if (8 == _i) {

				lstm_set_state(lstm, LSTM_END())
			}
		}
		else if (LSTM_STATE_2() == _st) {
			if (5 == _i) {

				lstm_set_state(lstm, LSTM_END())
			}
		}
		else if (LSTM_END() == _st) {
			if (6 == _i) {

				lstm_set_state(lstm, LSTM_BEGIN())
			}
		}
		
		_st = lstm_get_state(lstm)
		if (1 == _i) at_true(LSTM_BEGIN() == _st)
		else if (2 == _i) at_true(LSTM_STATE_1() == _st)
		else if (3 == _i) at_true(LSTM_STATE_1() == _st)
		else if (4 == _i) at_true(LSTM_STATE_2() == _st)
		else if (5 == _i) at_true(LSTM_END() == _st)
		else if (6 == _i) at_true(LSTM_BEGIN() == _st)
		else if (7 == _i) at_true(LSTM_STATE_1() == _st)
		else if (8 == _i) at_true(LSTM_END() == _st)
	}
}
# </functions>
# </lstm>
# </LOOP_TEST>

function main() {
	at_awklib_awktest_required()
	test_make_fsm_err()
	test_make_fsm_event()
	test_event_impl()
	test_make_fsm_loop()
	test_loop_impl()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
