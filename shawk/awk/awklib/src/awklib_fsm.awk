#@ <awklib_fsm>
#@ Library: fsm
#@ Description: Generates awk source code for finite state machines.
#@ Takes input in the form of:
#@ 'x -> y' or 'x -> y | z | ...'
#@ where 'x', 'y', and 'z' are states. '->' is read as 'is followed by'.
#@ '|' is read as 'or'. A state must be followed by one or more states.
#@
#@ Two kinds of state machines can be generated - an event fsm and a
#@ loop fsm. The event fsm generates events on each state transition.
#@ E.g. given
#@
#@ a -> b | c
#@ b -> c
#@ c -> a
#@
#@ an event fsm will start in the implicit empty state. From there the
#@ user requests state changes by calling the 'next()' function with the
#@ desired next state as an argument. From the empty state, the fsm will
#@ be able to go only to state 'a' and the 'on_a()' handler will be
#@ called before the state switch. From state 'a', the fsm will be able
#@ to go only to state 'b', or 'c', calling 'on_b()', or 'on_c()',
#@ respectively, etc. If an invalid state is requested, e.g. trying to
#@ switch to any other state than 'c' while in state 'b', the error
#@ handler will be called. All handlers are user defined. Note that
#@ there cannot be a state which does not lead to another state. The
#@ pattern for an event machine is usually circular, i.e. the last state
#@ goes to the first. This is awkward when not needed but keeps the
#@ implementation simple. Usually initialization is done in the first
#@ state and all processing in the last. There is an advantage - the
#@ user can check if the final state was reached in the END {} awk rule.
#@
#@ The loop fsm is different. No internal logic for state switching
#@ is provided. Instead, the states are displayed as a series of ifs
#@ inside a loop. The conditions on which the states change, i.e. the if
#@ conditions, are left to the user to define.
#@
#@ While the event fsm is more convenient when you can use the state
#@ names directly, e.g. to recognize some declarative, line oriented
#@ syntax in a file by looking at the first field, the loop fsm is more
#@ convenient when some arbitrary, unrelated to the state names logic is
#@ required, e.g. to recognize valid quote enclosed strings character by
#@ character, like "ab\"c".
#@
#@ Note that the user is expected and encouraged to edit the generated
#@ fsm code to fit their specific needs. The purpose of this library is
#@ to spare most of the tedium.
#@
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-27
#@

# <public>
#@ Description: When passed to 'fsm_make()' as the 'type' argument,
#@ an event fsm is generated.
#@ Returns: A string constant for the event type of fsm.
#
function FSM_EVENT() {return "event"}

#
#@ Description: When passed to 'fsm_make()' as the 'type' argument,
#@ a loop fsm is generated.
#@ Returns: A string constant for the loop type of fsm.
#
function FSM_LOOP() {return "loop"}

#
#@ Description: Clears 'arr_out', generates a fsm with a name 'name' of
#@ type 'type'. 'type' can be either FSM_EVENT(), or FSM_LOOP(). If
#@ neither, FSM_EVENT() is used. 'name' is used in the fsm function's
#@ names. If not given, "_" is used. 'arr_in' is an array of strings
#@ which describe a fsm as per this library documentation. 'len' is the
#@ length of 'arr_in'.
#@ Returns: The length of 'arr_out' on success. If a syntax, or a
#@ logical error in the input is encountered, 0 is returned. In the
#@ event of such an error, 'arr_out[1]' will contain the index of the
#@ offending line in 'arr_in' and 'arr_out[2]' will contain an error
#@ message string.
#
function fsm_make(arr_out, arr_in, len, name, type,    _arr_set, _str,
_fget_st, _fset_st, _st_static, _tabs, _i, _j, _arr_splt, _tmp,
_head, _tail, _bk0, _has0, _err_exp) {

	delete arr_out

	if ((FSM_EVENT() != type) && (FSM_LOOP() != type))
		type = FSM_EVENT()
	
	if (!name)
		name = "_"
	
	_tmp = _fsm_check_syntax(arr_out, arr_in, len, name, _arr_set)
	if (!_tmp)
		return 0
	
	_fsm_add_line(arr_out, sprintf("# <%s>", name))
	
	if (FSM_EVENT() == type) {
		_fsm_add_line(arr_out, "# <handlers>")
		_fsm_gen_handlers(arr_out, _arr_set, _tmp, name)
		_fsm_add_line(arr_out, "# </handlers>")
		_fsm_add_line(arr_out, "")
	}
	
	_fsm_add_line(arr_out, "# <constants>")
	_fsm_gen_const(arr_out, _arr_set, _tmp, name)
	
	_st_static = sprintf("_%s_STATE", toupper(name))
	_fsm_add_line(arr_out, sprintf("function %s() {return \"state\"}",
		_st_static))
	_fsm_add_line(arr_out, "# </constants>")
	
	_fsm_add_line(arr_out, "")
	
	_fget_st = (name "_get_state")
	_fset_st = (name "_set_state")
	
	_fsm_add_line(arr_out, "# <functions>")
	_fsm_add_line(arr_out, sprintf("function %s(%s) {return %s[%s()]}",
		_fget_st, name, name, _st_static))
		
	if (_has0 = (0 in arr_in))
		_bk0 = arr_in[0]
		
	if (FSM_LOOP() == type) {
	
		_fsm_add_line(arr_out,
			sprintf("function %s(%s, next_st) {%s[%s()] = next_st}",
			_fset_st, name, name, _st_static))
		
		_fsm_add_line(arr_out, "")
		
		_fsm_add_line(arr_out,
			sprintf("function %s_loop(    _st, _i, _end) {", name))
		_fsm_add_line(arr_out, "")
		
		_tabs = "\t"
		_fsm_add_line(arr_out,
			sprintf("%sfor (_i = 1; _i <= _end; ++_i) {", _tabs))
		_fsm_add_line(arr_out, "")
		
		_tabs = "\t\t"
		_fsm_add_line(arr_out, sprintf("%s_st = %s(%s)",
			_tabs, _fget_st, name))
		
		split(arr_in[1], _arr_splt, _FSM_HEAD())
		_head = _arr_splt[1]
			
		arr_in[0] = (_FSM_HEAD() _head)
		
		for (_i = 0; _i <= len; ++_i) {
			
			split(arr_in[_i], _arr_splt, _FSM_HEAD())
			_head = _arr_splt[1]
			_tail = _arr_splt[2]
			
			_fsm_add_line(arr_out, sprintf("%s%s (%s == _st) {",
				_tabs, (0 == _i) ? "if" : "else if",
				(0 == _i) ? "\"\"" : (_fsm_to_const(name, _head) "()")))
			
			_tabs = "\t\t\t"
			_tmp = split(_tail, _arr_splt, _FSM_TAIL())
			for (_j = 1; _j <= _tmp; ++_j) {
				
				_str = _arr_splt[_j]
				_fsm_add_line(arr_out, sprintf("%s%s (1) {",
					_tabs, (1 == _j) ? "if" : "else if",
					_fsm_to_const(name, _str)))
				
				_fsm_add_line(arr_out, "")
				
				_tabs = "\t\t\t\t"
				_fsm_add_line(arr_out,
					sprintf("%s%s(%s, %s())",
					_tabs, _fset_st, name, _fsm_to_const(name, _str)))
				
				_tabs = "\t\t\t"
				_fsm_add_line(arr_out, sprintf("%s}", _tabs))
			}
			
			_tabs = "\t\t"
			_fsm_add_line(arr_out, sprintf("%s}", _tabs))
		}
		_tabs = "\t"
		_fsm_add_line(arr_out, sprintf("%s}", _tabs))
		_fsm_add_line(arr_out, "}")
		
	} else if (FSM_EVENT() == type) {
		
		_tabs = "\t"
		
		_fsm_add_line(arr_out,
			sprintf("function _%s(%s, next_st) {%s[%s()] = next_st}",
			_fset_st, name, name, _st_static))
		
		_fsm_add_line(arr_out,
			sprintf("function %s_next(%s, next_st,    _st) {",
			name, name))
	
		_fsm_add_line(arr_out, "")
		_fsm_add_line(arr_out, sprintf("%s_st = %s(%s)",
			_tabs, _fget_st, name))
		
		split(arr_in[1], _arr_splt, _FSM_HEAD())
		_head = _arr_splt[1]
		
		arr_in[0] = (_FSM_HEAD() _head)
		
		for (_i = 0; _i <= len; ++_i) {
			
			split(arr_in[_i], _arr_splt, _FSM_HEAD())
			_head = _arr_splt[1]
			_tail = _arr_splt[2]
			
			_fsm_add_line(arr_out, sprintf("%s%s (%s == _st) {",
				_tabs, (0 == _i) ? "if" : "else if",
				(0 == _i) ? "\"\"" : (_fsm_to_const(name, _head) "()")))
			
			_tabs = "\t\t"
			_tmp = split(_tail, _arr_splt, _FSM_TAIL())
			for (_j = 1; _j <= _tmp; ++_j) {
				
				_str = _arr_splt[_j]
				_fsm_add_line(arr_out, sprintf("%s%s (%s() == next_st)",
					_tabs, (1 == _j) ? "if" : "else if",
					_fsm_to_const(name, _str)))
				
				_fsm_add_line(arr_out,
					sprintf("%s{%s_on_%s(); _%s(%s, next_st)}",
					_tabs, name, _str, _fset_st, name))
				
				if (1 == _j) {
					_err_exp = sprintf("%s()",
						_fsm_to_const(name, _str))
				} else {
					_err_exp = (_err_exp sprintf("\"|\"%s()",
						_fsm_to_const(name, _str)))
				}
				_tabs = "\t\t"
			}
			
			_fsm_add_line(arr_out, sprintf("%selse", _tabs))
			_fsm_add_line(arr_out,
				sprintf("%s{%s_on_error(_st, %s, next_st)}",
				_tabs, name, _err_exp))
			
			_tabs = "\t"
			_fsm_add_line(arr_out, sprintf("%s}", _tabs))
		}
		_fsm_add_line(arr_out, "}")
	}
	_fsm_add_line(arr_out, "# </functions>")	
	_fsm_add_line(arr_out, sprintf("# </%s>", name))
	
	if (_has0)
		arr_in[0] = _bk0
	else
		delete arr_in[0]
	
	_tmp = _fsm_get_num_lines(arr_out)
	_fsm_clean_arr(arr_out)
	return _tmp
}
# </public>

function _fsm_gen_handlers(arr_out, arr_in, len, name,    _i,
_str) {

	for (_i = 1; _i <= len; ++_i) {
		_str = arr_in[_i]
		_fsm_add_line(arr_out, sprintf("function %s_on_%s() {", name,
			_str))
		_fsm_add_line(arr_out, "")
		_fsm_add_line(arr_out, "}")
	}
	_fsm_add_line(arr_out,
		sprintf("function %s_on_error(curr_st, expected, got) {", name))
	_fsm_add_line(arr_out, "")
	_fsm_add_line(arr_out, "}")
}

function _fsm_gen_const(arr_out, arr_in, len, name,    _i, _str) {
	
	for (_i = 1; _i <= len; ++_i) {
		_str = arr_in[_i]
		_fsm_add_line(arr_out, sprintf("function %s() {return \"%s\"}",
			_fsm_to_const(name, _str), _str))
	}
}

function _fsm_clean_arr(arr) {

	if (_FSM_HEAD() in arr)
		delete arr[_FSM_HEAD()]
}
function _fsm_get_num_lines(arr) {return arr[_FSM_HEAD()]}
function _fsm_add_line(arr, str) {

	# reuse some constant for the line count
	arr[++arr[_FSM_HEAD()]] = str
}
function _fsm_to_const(name, str) {

	return sprintf("%s_%s", toupper(name), toupper(str))
}

function _fsm_check_syntax(arr_out, arr_in, len, name, arr_set,    _i,
_set, _arr_splt, _str, _tmp, _head, _tail, _j, _nout) {

	if (!len)
		return _fsm_noin(arr_out, 0)

	if (!match(name, _FSM_ID()))
		return _fsm_enoid(arr_out, 0, name)
	
	_nout = 0
	for (_i = 1; _i <= len; ++_i) {
		
		_str = arr_in[_i]
		gsub("[[:space:]]+", "", _str)
		arr_in[_i] = _str
		
		_tmp = split(_str, _arr_splt, _FSM_HEAD())
		if (_tmp != 2 || !_arr_splt[_tmp])
			return _fsm_ebad_sep(arr_out, _i)
		
		_head = _arr_splt[1]
		_tail = _arr_splt[2]
		
		if (!match(_head, _FSM_ID()))
			return _fsm_enoid(arr_out, _i, _head)
			
		if (_head in _set)
			return _fsm_eredfn(arr_out, _i, _head)	
		++_set[_head]
		arr_set[++_nout] = _head
		
		_tmp = split(_tail, _arr_splt, _FSM_TAIL())
		if (!_arr_splt[_tmp])
			return _fsm_ebad_sep(arr_out, _i)
	}
	
	for (_i = 1; _i <= len; ++_i) {
		
		split(arr_in[_i], _arr_splt, _FSM_HEAD())
		_tail = _arr_splt[2]
		_tmp = split(_tail, _arr_splt, _FSM_TAIL())
		for (_j = 1; _j <= _tmp; ++_j) {
			
			_str = _arr_splt[_j]
			if (!(_str in _set))
				return _fsm_enodfn(arr_out, _i, _str)
			else
				++_set[_str]
		}
	}
	
	for (_i = 1; _i <= len; ++_i) {
		
		split(arr_in[_i], _arr_splt, _FSM_HEAD())
		_head = _arr_splt[1]
		
		if (1 == _set[_head])
			return _fsm_enoreach(arr_out, _i, _head)
	}
	
	return _nout
}

function _fsm_enoreach(arr_out, ind, str) {
	return _fsm_err(arr_out, ind,
		sprintf("state '%s' unreachable", str))
}
function _fsm_enoid(arr_out, ind, str) {
	return _fsm_err(arr_out, ind,
		sprintf("'%s' does not match '%s'", str, _FSM_ID()))
}
function _fsm_enodfn(arr_out, ind, str) {
	return _fsm_err(arr_out, ind,
		sprintf("state '%s' not defined", str))
}
function _fsm_eredfn(arr_out, ind, str) {
	return _fsm_err(arr_out, ind,
		sprintf("state '%s' redefined", str))
}
function _fsm_ebad_sep(arr_out, ind) {
	return _fsm_err(arr_out, ind, "bad separator")
}
function _fsm_noin(arr_out, ind) {
	return _fsm_err(arr_out, ind, "no input")
}
function _fsm_err(arr_out, ind, str) {
	arr_out[1] = ind
	arr_out[2] = str
	return 0
}

function _FSM_ID() {return "^[_[:alpha:]][_[:alnum:]]*$"}
function _FSM_HEAD() {return "->"}
function _FSM_TAIL() {return "\\|"}
#@ </awklib_fsm>
