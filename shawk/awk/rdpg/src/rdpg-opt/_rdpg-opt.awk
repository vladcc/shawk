#!/usr/bin/awk -f

# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2021-06-05

# <script>
function SCRIPT_NAME() {return "rdpg-opt.awk"}
function SCRIPT_VERSION() {return "1.2"}
# </script>

# <input>
function INPUT_SEP() {return "\n"}
function func_new(fname) {_B_fnames[++_B_fnames_count] = fname}
function func_get_count() {return _B_fnames_count}
function func_get_name(n) {return _B_fnames[n]}
function func_get_code(fname) {return _B_functions[fname]}
function func_split(fcode, arr_out) {return split(fcode, arr_out, INPUT_SEP())}
function func_rewrite_full(fname, code) {_B_functions[fname] = code}
function func_remove(fname) {delete _B_functions[fname]}
function func_write_line(fname, str) {
	sub("^[[:space:]]+", "", str)
	str = (str INPUT_SEP())
	_B_functions[fname] = (_B_functions[fname] str)
}
function arr_to_str(arr, len, sep,    _i, _ret, _str) {
	
	if (!sep)
		sep = INPUT_SEP()
	
	for (_i = 1; _i <= len; ++_i) {
		_str = arr[_i]
		
		if (_str)
			_ret = (_ret _str sep)
	}
	
	return _ret
}
# </input>

# <output>
function tabs_inc() {++_B_tabs}
function tabs_dec() {--_B_tabs}
function tabs_out(    _i) {
	for (_i = 1; _i <= _B_tabs; ++_i)
		printf("\t")
}

function emit_comment(str) {print sprintf("%s %s", IR_COMMENT(), str)}
function print_out(    _i, _end, _arr, _len, _j) {
	
	emit_comment(sprintf("optimized by %s %s %s=%d",
		SCRIPT_NAME(), SCRIPT_VERSION(), "Olvl", Olvl))
	
	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
	
		_len = split(func_get_code(func_get_name(_i)), _arr, INPUT_SEP())		
		for (_j = 1; _j <= _len; ++_j)
			line_out(_arr[_j])
	}
}
function line_out(str) {
	
	if (!str)
		return
		
	if (match(str, IR_COMMENT())) {
		print str
		return
	}
	
	if (match(str, IR_BLOCK_CLOSE()))
		tabs_dec()
		
	tabs_out()
	print str
	
	if (match(str, IR_BLOCK_OPEN()))
		tabs_inc()
}
function print_stderr(msg) {print msg > "/dev/stderr"}
function error_raise() {_B_error = 1}
function error_happened() {return _B_error}
function error(msg) {
	print_stderr(sprintf("%s: error: %s", SCRIPT_NAME(), msg))
	error_raise()
	exit(1)
}

function skip_end_set() {_B_dont_end = 1}
function skip_end_get() {return _B_dont_end}
function exit_skip_end() {
	skip_end_set()
	exit(0)
}

# <user_messages>
function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_skip_end()
}

function RDPG() {return "rdpg"}
function print_help() {
print sprintf("--- %s %s ---", SCRIPT_NAME(), SCRIPT_VERSION())
print sprintf("The %s optimizer.", RDPG())
print ""
print "Use:"
print sprintf("... | awk -f %s [opts...]", SCRIPT_NAME())
print ""
print "Options:"
print sprintf("-vOlvl=<num> - optimization level; range is %d - %d",
	olvl_min(), olvl_max())
print "-vInlineLength=<num> - functions with > <num> number of lines won't inline"  
print "-vHelp=1    - print this screen"
print "-vVersion=1 - print version"
print ""
print "Five levels of optimization are supported, excluding level 0:"
print "0 - no optimization. Prints a warning to stderr."
print "1 - if-else return optimization. Translates"
print "'if (foo()) {return true} else {return false}' to 'return foo()',"
print "'if (foo()) {return true} else {return true}' to 'foo(); return true'"
print "2 - redundant else removal. Translates"
print "'if (foo()) {if (bar()) {...} else {return false}} else {return false}' to"
print "'if (foo()) {if (bar()) {...}}; return false'"
print "3 - remove unreachable code. Translates"
print "'if (foo()) {... return <value> ...}' to"
print "'if (foo()) {... return <value>}'"
print "4 - tail call optimization. Translates"
print "'foo() {... {return foo()} ... {return foo()}}' to"
print "'foo() {while (1) {... continue ... continue}}'"
print "5 - inline functions no longer than InlineLength number of lines. " _INLINE_DEFAULT_FLENGTH()
print "by default. Translates"
print "'bar() {<bar-code>} foo() {... {return bar()} ...}' to"
print "'foo() {... {<bar-code>} ...}'"
	exit_skip_end()
}
# </user_messages>
# </output>

# <awk_rules>
FNR == 1 && $1 == IR_COMMENT() {print $0}
$1 == IR_FUNC() {func_new($2)}

function current_func() {return func_get_name(func_get_count())}
{func_write_line(current_func(), $0)}

function init() {
	if (Help)
		print_help()
	if (Version)
		print_version()
	if (InlineLength)
		inline_set_limit(InlineLength)
	Olvl = (Olvl) ? Olvl : ""
}

BEGIN {
	init()
}

function olvl_min() {return 0}
function olvl_max() {return 5}
END {
	if (!skip_end_get()) {	
		if (!Olvl)
			print_stderr(sprintf("%s: warning: no Olvl", SCRIPT_NAME()))
		else if (Olvl < olvl_min() || Olvl > olvl_max()) {
			error(sprintf("bad Olvl value '%d'; range is %d to %d",
				Olvl, olvl_min(), olvl_max()))
		}
		
		if (!error_happened()) {
			optimize(Olvl)
			print_out()
		}
	}
}
# </awk_rules>

# <misc>
function is(a, b) {return (a == b)}

function get_field(str, n,    _arr) {
	split(str, _arr)
	return _arr[n]
}
function get_first_field(str) {
	return get_field(str, 1)
}

function is_if(str) {return is(IR_IF(), get_first_field(str))}
function is_else(str) {return is(IR_ELSE(), get_first_field(str))}
function is_else_if(str) {return is(IR_ELSE_IF(), get_first_field(str))}
function is_return(str) {return is(IR_RETURN(), get_first_field(str))}
function is_return_const(str,    _rval) {
	if (is_return(str)) {
		_rval = get_field(str, 2)
		return (IR_TRUE() == _rval || IR_FALSE() == _rval)
	}
	return 0
}
function is_block_open(str) {return is(IR_BLOCK_OPEN(), get_first_field(str))}
function is_block_close(str) {return is(IR_BLOCK_CLOSE(), get_first_field(str))}
function is_func_end(str) {return is(IR_FUNC_END(), get_first_field(str))}
function is_func(str) {return is(IR_FUNC(), get_first_field(str))}
function is_comment(str) {return is(IR_COMMENT(), get_first_field(str))}
# </misc>

# <code_search>
function get_func_end(arr, len,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (is_func_end(arr[_i]))
			return _i
	}
	return 0
}

function get_prev_f1(arr, len, start, what,    _i) {
	
	for (_i = start; _i >= 1; --_i) {
		if (is(what, get_first_field(arr[_i])))
			return _i
	}
	return 0
}

function get_next(arr, len, start, what,    _i) {
	
	for (_i = start; _i <= len; ++_i) {
		if (is(what, arr[_i]))
			return _i
	}
	return 0
}

function get_last_return(arr, len,    _i) {
	
	_i = get_func_end(arr, len)
	return get_prev_f1(arr, len, _i, IR_RETURN())
}

function get_block_open_up(arr, len, start,    _i) {
	return get_prev_f1(arr, len, start, IR_BLOCK_OPEN())
}
# </code_search>

# <if_call_returns_only>
function if_call_ret_call(fname) {
	return sprintf("%s %s %s", IR_RETURN(), IR_CALL(), fname)
}
function if_call_call(fname) {
	return sprintf("%s %s", IR_CALL(), fname)
}

function if_call_ret(ret_val) {
	return sprintf("%s %s", IR_RETURN(), ret_val)
}

function if_call_return_only_do_else_if(arr, len, where,
    _step, _r1, _r2, _called, _str) {
	
	if (!_step)
		_step = 1
	
	_str = arr[where]
	
	if (is(1, _step) && is_else_if(_str)) {
		_step = 2
		_called = get_field(_str, 3)
	} else if (is(2, _step) && is_block_open(_str)) {
		_step = 3
	} else if (is(3, _step) && is_return_const(_str)) {
		_step = 4
		_r1 = get_field(_str, 2)
	} else if (is(4, _step) && is_block_close(_str)) {
		_step = 5
	} else if (is(5, _step) && is_else(_str)) {
		_step = 6
	} else if (is(6, _step) && is_block_open(_str)) {
		_step = 7
	} else if (is(7, _step) && is_return_const(_str)) {
		_step = 8
		_r2 = get_field(_str, 2)
	} else if (is(8, _step) && is_block_close(_str)) {
		
		arr[where-7] = IR_ELSE()
		#arr[where-6] = ""          # block_open
		arr[where-5] = ""
		arr[where-3] = arr[where-4] # block_close
		
		arr[where-4] = ""
		arr[where-2] = ""
		arr[where-1] = ""
		arr[where] = ""
		
		if (is(IR_TRUE(), _r1) && is(IR_FALSE(), _r2)) {
			arr[where-5] = if_call_ret_call(_called)
		} else {
			arr[where-5] = if_call_call(_called)
			arr[where-4] = if_call_ret(_r1)
		}
		
		return
	} else {
		return
	}
	
	if_call_return_only_do_else_if(arr, len, where+1, _step, _r1, _r2, _called)
}

function if_call_return_only_do_if(arr, len, where,
    _step, _r1, _r2, _called, _str) {
	
	if (!_step)
		_step = 1
	
	_str = arr[where]
	
	if (is(1, _step) && is_if(_str)) {
		_step = 2
		_called = get_field(_str, 3)
	} else if (is(2, _step) && is_block_open(_str)) {
		_step = 3
	} else if (is(3, _step) && is_return_const(_str)) {
		_step = 4
		_r1 = get_field(_str, 2)
	} else if (is(4, _step) && is_block_close(_str)) {
		_step = 5
	} else if (is(5, _step) && is_else(_str)) {
		_step = 6
	} else if (is(6, _step) && is_block_open(_str)) {
		_step = 7
	} else if (is(7, _step) && is_return_const(_str)) {
		_step = 8
		_r2 = get_field(_str, 2)
	} else if (is(8, _step) && is_block_close(_str)) {
		_step = 0
		
		arr[where-7] = ""
		arr[where-6] = ""
		arr[where-5] = ""
		arr[where-4] = ""
		arr[where-3] = ""
		arr[where-2] = ""
		arr[where-1] = ""
		arr[where] = ""
		
		if (is(IR_TRUE(), _r1) && is(IR_FALSE(), _r2)) {
			arr[where-7] = if_call_ret_call(_called)
		} else {
			arr[where-7] = if_call_call(_called)
			arr[where-6] = if_call_ret(_r1)
		}
		
		return
	} else {
		return
	}
	
	if_call_return_only_do_if(arr, len, where+1, _step, _r1, _r2, _called)	
}

function if_call_returns_only(arr, len,    _i) {
# if (foo()) {return true} else {return false}
# becomes
# return foo()
#
# if (foo()) {return true} else {return true}
# becomes
# foo()
# return true
#
# else if (foo()) {return true} else {return false}
# becomes
# else { return foo() }
# etc.

	for (_i = 1; _i <= len; ++_i) {
		if_call_return_only_do_if(arr, len, _i)
		if_call_return_only_do_else_if(arr, len, _i)
	}		
}
# </if_call_returns_only>

# <drop_redundant_else>
function drop_redundant_else_remove_empty_elses(arr, where,    _step, _str) {
	
	if (!_step)
		_step = 1
		
	_str = arr[where]
	if (is(1, _step) && is_else(_str)) {
		_step = 2
	} else if (is(2, _step) && is_block_open(_str)) {
		_step = 3
	} else if (is(3, _step) && is_block_close(_str)) {
		arr[where] = arr[where-1] = arr[where-2] = ""
		return
	} else {
		return
	}
	
	drop_redundant_else_remove_empty_elses(arr, where+1, _step)
}

function drop_redundant_else_swap_remove_returns(arr, len, where, ret,
    _step, _str, _i) {
	
	if (!_step)
		_step = 1
		
	_str = arr[where]
	
	if (is(1, _step) && is_else(_str)) {
		_step = 2
	} else if (is(2, _step) && is_block_open(_str)) {
		_i = get_next(arr, len, where,
			sprintf("%s %s", IR_BLOCK_CLOSE(), get_field(_str, 2)))
		
		_str = arr[_i-1]
		if (is_return_const(_str) && is(ret, get_field(_str, 2))) {
			arr[_i-1] = arr[_i]
			arr[_i] = ""
		}
		return
	} else {
		return
	}
	
	drop_redundant_else_swap_remove_returns(arr, len, where+1, ret, _step)
}

function drop_redundant_else_swap_out_last_ret(arr, ret_pos,    _str) {

	if (is_block_close(arr[ret_pos+1])) {
		_str = arr[ret_pos]
		arr[ret_pos] = arr[ret_pos+1]
		arr[ret_pos+1] = _str
	}
}

function drop_redundant_else(arr, len,    _i, _ret, _has_else) {
# if (foo())
# 	if (bar())
# 		return true
# 	else
# 		return false
# else
# 	return false
# becomes
# if (foo())
# 	if(bar())
# 		return true
# return false

	# there actually needs to be an else
	for (_i = 1; _i <= len; ++_i) {
		if (is_else(arr[_i])) {
			_has_else = 1
			break
		}
	}

	if (!_has_else)
		return
		
	_i = get_last_return(arr, len)
	
	if (is_return_const(arr[_i])) {
		_ret = get_field(arr[_i], 2)
		
		drop_redundant_else_swap_out_last_ret(arr, _i)
		
		for (_i = 1; _i <= len; ++_i)
			drop_redundant_else_swap_remove_returns(arr, len, _i, _ret)
			
		for (_i = 1; _i <= len; ++_i)
			drop_redundant_else_remove_empty_elses(arr, _i)
	}
}
# </drop_redundant_else>

# <opt_tail_calls>
function opt_tail_calls_find_call(fname, arr, where,
    _step, _str) {
	
	if (!_step)
		_step = 1
		
	_str = arr[where]
	
	if (is(1, _step) &&
		is_return(_str) &&
		is("call", get_field(_str, 2)) &&
			is(fname, get_field(_str, 3))) {
			_step = 2
	} else if (is(2, _step) && is_block_close(_str)) {
		return where-1
	} else {
		return 0
	}
	
	return opt_tail_calls_find_call(fname, arr, where+1, _step)
}

function opt_tail_calls_check_call_returns(fname, arr, len,    _i, _where) {
	for (_i = 1; _i <= len; ++_i) {
		if (_where = opt_tail_calls_find_call(fname, arr, _i))
			return _where
	}
	return 0
}

function opt_tail_calls_is_tail_rec(fname, arr, len) {
	return opt_tail_calls_check_call_returns(fname, arr, len)
}

function opt_tail_calls_opt_calls(fname, arr, len,
    _i, _where, _is_looped, _tmp) {
	
	_is_looped = 0
	for (_i = 1; _i <= len; ++_i) {
		if (_where = opt_tail_calls_find_call(fname, arr, _i)) {
			arr[_where] = IR_CONTINUE()
			
			if (!_is_looped) {
				_tmp = get_prev_f1(arr, len, _where, IR_COMMENT())
				
				arr[_tmp] = sprintf("%s\n%s\n%s %s_0",
					arr[_tmp], IR_LOOP_START(), IR_BLOCK_OPEN(), fname)
				
				_tmp = get_func_end(arr, len)
				_tmp -= 2
				
				arr[_tmp] = sprintf("%s\n%s %s_0\n%s",
					arr[_tmp], IR_BLOCK_CLOSE(), fname, IR_LOOP_END())
				
				_is_looped = 1
			}
		}
	}
}

function opt_tail_calls(fname, arr, len,    _i) {
# foo()
# {
# 	...
# 	{
# 	...
# 		return foo()
# 	}
# 	...
# }
# becomes
# foo()
# {
# 	while (1)
# 	{
# 		...
# 		{
# 		...
# 			continue // where return foo() was
# 		}
# 		...
# 	}
# }

	if (opt_tail_calls_is_tail_rec(fname, arr, len)) 
		opt_tail_calls_opt_calls(fname, arr, len)
}
# </opt_tail_calls>

# <remove_unreachable_code>
function remove_unreachable_delete_past_return(arr, len, where,
    _step, _str) {
	
	if (!_step)
		_step = 1
		
	_str = arr[where]

	if (is(1, _step) && is_return(_str)) {
		_step = 2
	} else if (is(2, _step) && !is_block_close(_str)) {
		arr[where] = ""
	} else {
		return
	}

	remove_unreachable_delete_past_return(arr, len, where+1, _step)
}

function remove_unreachable_code(arr, len,    _i) {
# {
# ...
# return foo()
# ...
# }
# becomes
# {
# ...
# return foo()
# }

	for (_i = 1; _i <= len; ++_i)
		remove_unreachable_delete_past_return(arr, len, _i)
}

# </remove_unreachable_code>

# <inline>
function _INLINE_DEFAULT_FLENGTH() {return 25}
function inline_set_limit(nlines) {_B_inline_limit = nlines}
function inline_get_limit() {
	return ((_B_inline_limit) ? _B_inline_limit : _INLINE_DEFAULT_FLENGTH())
}

function inline_has_any_ref(fname, arr,    _n, _str) {
	
	_str = sprintf("%s %s[[:space:]]", IR_CALL(), fname)
	for (_n in arr) {
		if (match(arr[_n], _str))
			return 1
	}
	return 0
}

function inline_arr_remove(arr, len, rexp,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (match(arr[_i], rexp))
			arr[_i] = ""
	}
} 

function inline_sanitize_for_inline(fname, fcode,    _arr, _len, _tmp) {
	
	_len = func_split(fcode, _arr)
	
	inline_arr_remove(_arr, _len, sprintf("^%s ",IR_FUNC()))
	inline_arr_remove(_arr, _len, sprintf("%s %s_1", IR_BLOCK_OPEN(), fname))
	inline_arr_remove(_arr, _len, sprintf("^%s", IR_COMMENT()))
	inline_arr_remove(_arr, _len, sprintf("%s %s_1", IR_BLOCK_CLOSE(), fname))
	inline_arr_remove(_arr, _len, sprintf("^%s", IR_FUNC_END()))
	
	return arr_to_str(_arr, _len)
}

function inline_f_in_f(fname, arr_allf, arr_fcode, fc_len,
    _i, _str, _inlined) {
	
	_inlined = 0
	for (_i = 1; _i <= fc_len; ++_i) {
		_str = arr_fcode[_i]
		
		if (is(IR_RETURN(), get_field(_str, 1)) &&
			is(IR_CALL(), get_field(_str, 2)) &&
			is(fname, get_field(_str, 3))) {
		
			arr_fcode[_i] = inline_sanitize_for_inline(fname, arr_allf[fname])		
			_inlined = 1
		}
	}
	return _inlined
}

function inline_rewrite_func(fname, arr,    _farr, _n, _len, _inlined) {
	
	_inlined = 0
	for (_n in arr) {
		_len = func_split(arr[_n], _farr)	
		if (inline_f_in_f(fname , arr, _farr, _len)) {
			func_rewrite_full(_n, arr_to_str(_farr, _len))
			_inlined = 1
		}
	}
	return _inlined
}

function inline_get_next_smallest(arr, arr_seen,
    _arr_tmp, _fname, _biggest, _flen, _ret) {
	
	_ret = ""
	_biggest = 0
	
	for (_fname in arr) {
		
		if (!(_fname in arr_seen)) {

			_flen = func_split(arr[_fname], _arr_tmp)
			if (_flen <= inline_get_limit()) {
				
				if (!_biggest || (_biggest > _flen)) {
					_biggest = _flen
					_ret = _fname
				}
			}
		}
	}
	
	if (_ret)
		arr_seen[_ret] = 1
	
	return _ret
}

function inline_copy_allf(arr_out,    _fname, _i, _end) {
	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
		_fname = func_get_name(_i)
		arr_out[_fname] = func_get_code(_fname)
	}
}

function inline(    _arr_allf, _fnext, _arr_seen, _n, _arr_inlined) {
# {
# ...
# return foo()
# }
# becomes
# {
# ...
# <actual-code-of-foo>
# }
# only if the code of foo() is <= inline_get_limit()

	inline_copy_allf(_arr_allf)
	
	while (_fnext = inline_get_next_smallest(_arr_allf, _arr_seen)) {
	
		if (inline_rewrite_func(_fnext, _arr_allf)) {
		
			inline_copy_allf(_arr_allf)
			if (!inline_has_any_ref(_fnext, _arr_allf))
				func_remove(_fnext)
			
			inline_copy_allf(_arr_allf)
		}
	}
}
# </inline>

# <opt_lvls>
function optimize_lvl1(    _i, _end, _arr, _len, _fname) {

	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
	
		_fname = func_get_name(_i)
		_len = func_split(func_get_code(_fname), _arr)
		
		remove_unreachable_code(_arr, _len)
		
		func_rewrite_full(_fname, arr_to_str(_arr, _len))
	}
}

function optimize_lvl2(    _i, _end, _arr, _len, _fname) {

	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
	
		_fname = func_get_name(_i)
		_len = func_split(func_get_code(_fname), _arr)
		
		if_call_returns_only(_arr, _len)
		
		func_rewrite_full(_fname, arr_to_str(_arr, _len))
	}
}

function optimize_lvl3(    _i, _end, _arr, _len, _fname) {

	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
	
		_fname = func_get_name(_i)
		_len = func_split(func_get_code(_fname), _arr)
		
		drop_redundant_else(_arr, _len)
		
		func_rewrite_full(_fname, arr_to_str(_arr, _len))
	}
}

function optimize_lvl4(    _i, _end, _arr, _len, _fname) {

	_end = func_get_count()
	for (_i = 1; _i <= _end; ++_i) {
	
		_fname = func_get_name(_i)
		_len = func_split(func_get_code(_fname), _arr)
		
		opt_tail_calls(_fname, _arr, _len)
		
		func_rewrite_full(_fname, arr_to_str(_arr, _len))
	}
}

function optimize_lvl5() {
	inline()
}

function optimize(lvl) {
	
	if (lvl >= 1) 
		optimize_lvl1()
	
	if (lvl >= 2)
		optimize_lvl2()
	
	if (lvl >= 3)
		optimize_lvl3()
	
	if (lvl >= 4)
		optimize_lvl4()
		
	if (lvl >= 5)
		optimize_lvl5()
}
# </opt_lvls>
