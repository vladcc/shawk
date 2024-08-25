#!/usr/bin/awk -f

# repli.awk -- replays doti output back into its original info structure
# Vladimir Dinev
# vld.dinev@gmail.com
# 2021-11-03

# <misc>
function SCRIPT_NAME() {return "repli.awk"}
function SCRIPT_VERSION() {return "1.0"}

function input_save(line) {vect_push(_B_input, line)}
function input_get(n) {return _B_input[n]}
function input_len() {return vect_len(_B_input)}
# </misc>

# <messages>
function USE_STR() {return sprintf("Use: %s <dot-file(s)>", SCRIPT_NAME())}

function print_use() {
	pstderr(USE_STR())
	pstderr(sprintf("Try: %s -v Help=1", SCRIPT_NAME()))
	exit_failure()
}

function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}

function print_help() {
print SCRIPT_NAME() " -- replays doti output back into its original info structure"
print USE_STR()
print ""
print "Options:"
print "-v Version=1 - version info"
print "-v Help=1    - this screen"
	exit_success()
}
# </messages>

# <replay>
function FILE_BEGIN() {return ";FILE_BEGIN"}
function FILE_END() {return ";FILE_END"}
function AN_ERROR() {return ";ERROR"}
function FILE_RE() {return "^[[:space:]]*;FILE_(BEGIN|END)[[:space:]]*"}

function get_fname(line) {
	sub(FILE_RE(), "", line)
	
	if (!line)
		error_quit(sprintf("line %d: empty file name", FNR))
	
	return line
}

function UNBAL() {return "unbalanced file begin/end"}
function err_fq(str, n) {
	
	if (n)
		str = sprintf("line %d: %s: '%s'", n, UNBAL(), str)
	else
		str = sprintf("%s: '%s'", UNBAL(), str)
			
	error_quit(str) 
}



function checks() {
	check_input_fstructure()
	check_fdexist()
}

function check_input_fstructure(    _i, _end, _line, _fname, _pushed, _stack,
_err_vect, _line_num_stack) {
	
	# see if file begin/end are properly nested
	
	vect_init(_stack)
	vect_init(_err_vect)
	vect_init(_line_num_stack)
	
	_pushed = 0
	_end = input_len()
	for (_i = 1; _i <= _end; ++_i) {
		
		_line = input_get(_i)
		if (match(_line, AN_ERROR()))
			vect_push(_err_vect, sprintf("line %d: %s", _i, _line))
		
		if (match(_line, FILE_BEGIN())) {
			_pushed = 1
			_fname = get_fname(_line)
			vect_push(_stack, _fname)
			vect_push(_line_num_stack, _i)
		} else if (match(_line, FILE_END())) {
		
			_fname = get_fname(_line)
			if (_fname != vect_peek(_stack)) {
				
				err_fq(_line, _i)
			} else {
			
				if (!vect_is_empty(_stack)) { 
					vect_pop(_stack)
					vect_pop(_line_num_stack)
				} else
					err_fq("attempt to pop an empty stack")
			}
		}
	}
	
	if (!_pushed)
		err_fq("no files in input")
	
	if (!vect_is_empty(_stack))
		err_fq(vect_peek(_stack), vect_peek(_line_num_stack))
		
	if (!vect_is_empty(_err_vect)) {
		
		_end = vect_len(_err_vect)
		for (_i = 1; _i <= _end; ++_i) {
			if (_i < _end)
				error_print(_err_vect[_i])
			else
				error_quit(_err_vect[_i])
		}
	}
}

function check_fdexist(    _i, _end, _arr, _len, _cmd, _fset, _dset, _fname,
_err_set, _err) {
	
	# collect all file and directory names
	_err = 0
	eos_init(_fset)
	eos_init(_dset)
	_end = input_len()
	for (_i = 1; _i <= _end; ++_i) {
	
		_line = input_get(_i)
		if (match(_line, FILE_BEGIN())) {
			
			_fname = get_fname(_line)
			eos_add(_fset, _fname)
			
			if (match(_fname, "^.*/"))
				eos_add(_dset, substr(_fname, RSTART, RLENGTH))
		}
	}

	# check if any of the files already exists
	vect_init(_err_set)
	_end = eos_size(_fset)
	for (_i = 1; _i <= _end; ++_i) {
		
		_fname = _fset[_i]
		_cmd = ("test -f '" _fname "'")
		_len = exec_cmd_sh(_cmd, _arr)
	
		if (0 == _arr[_len]) {
			vect_push(_err_set, _fname)
			error_print(sprintf("%s: file exists", _cmd))
			_err = 1
		}
	}
	
	# one or more of the files exist; list and propose a fix
	if (!vect_is_empty(_err_set)) {
		pstderr("")
		pstderr("Proposed fix:")
		arr_sub(_fset, eos_size(_fset), ".*", "'&'")
		pstderr(sprintf("rm %s", arr_to_str(_fset, eos_size(_fset))))
		pstderr("")
	}
	
	# check if any of the directories does not exist
	vect_init(_err_set)
	_end = eos_size(_dset)
	for (_i = 1; _i <= _end; ++_i) {
		
		_fname = _dset[_i]
		_cmd = ("test -d '" _fname "'")
		_len = exec_cmd_sh(_cmd, _arr)
	
		if (1 == _arr[_len]) {
			vect_push(_err_set, _fname)
			error_print(sprintf("%s: directory doesn't exists", _cmd))
			_err = 1
		}
	}
	
	# one or more of the directories exist; propose a fix
	if (!vect_is_empty(_err_set)) {
		pstderr("")
		pstderr("Proposed fix:")
		arr_sub(_dset, eos_size(_dset), ".*", "'&'")
		pstderr(sprintf("mkdir -p %s", arr_to_str(_dset, eos_size(_dset))))
		pstderr("")
	}
	
	# quit if either of the above errors happened
	if (_err) {
		pstderr(sprintf("%s: quitting due to errors", SCRIPT_NAME()))
		exit_failure()
	}
}

function pinfo(str) {print sprintf("%s: info: %s", SCRIPT_NAME(), str)}

function ACT_NONE() {return 0}
function ACT_PUSH() {return 1}
function ACT_POP() {return 2}

function _replay(    _i, _end, _fname, _line, _stack_files, _action, _file_set,
_sub, _sub_stack) {

	vect_init(_stack_files)
	vect_push(_stack_files, "")
	
	_sub = ""
	vect_init(_sub_stack)
	
	_action = ACT_NONE()
	_fname = vect_peek()
	_end = input_len()
	for (_i = 1; _i <= _end; ++_i) {
		
		_line = input_get(_i)
		if (match(_line, FILE_BEGIN()))
			_action = ACT_PUSH()
		else if (match(_line, FILE_END()))
			_action = ACT_POP()
		else
			_action = ACT_NONE()
			
		if (ACT_PUSH() == _action) {
			_fname = get_fname(_line)
			
			if (!(_fname in _file_set)) {
				_file_set[_fname]
			} else {
			
				# skip the file if it has already been written
				_fname = (FILE_END() ".*" _fname)
				while (++_i <= _end) {
					if (match(input_get(_i), _fname))
						break
				}
				_fname = vect_peek(_stack_files)
				continue
			}
			
			# figure out how many white space characters to remove
			match(_line, "^[[:space:]]+")
			
			# the substring without the leading indentations begins 1 after
			# RLENGTH; if no match was found RLENGTH will be -1 and _sub 0
			_sub = RLENGTH+1
			
			# save the number so we can come back to it
			vect_push(_sub_stack, _sub)
			
			vect_push(_stack_files, _fname)
			pinfo(sprintf("writing file '%s'", _fname))
		}
		
		if (_fname) {
			# remove all leading indentations, if any
			if (_sub)
				_line = substr(_line, _sub)
				
			# write
			print _line > _fname
		} else {
			error_quit(sprintf("line %d: no file to write to", _i))
		}
		
		if (ACT_POP() == _action) {
			close(_fname)
			vect_pop(_stack_files)
			_fname = vect_peek(_stack_files)
			vect_pop(_sub_stack)
			_sub = vect_peek(_sub_stack)
		}
	}
}

function replay() {
	checks()
	_replay()
}

# </replay>

# <main>
function init() {
	set_program_name(SCRIPT_NAME())
	if (Help)
		print_help()
	if (Version)
		print_version()
}

BEGIN {
	init()
}

{input_save($0)}

END {
	if (!should_skip_end())
		replay()
}
# </main>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	_AWKLIB_prog__program_name = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return _AWKLIB_prog__program_name
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	_AWKLIB_prog__skip_end_flag = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	_AWKLIB_prog__skip_end_flag = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (_AWKLIB_prog__skip_end_flag+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	_AWKLIB_prog__error_flag = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	_AWKLIB_prog__error_flag = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (_AWKLIB_prog__error_flag+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {

	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
#@ <exec_cmd>
#@ Library: exec_cmd
#@ Description: Provides the means to execute shell commands from an awk
#@ script and receive the command's output. Optionally, the user can get
#@ the stderr and the exit code of the command as well.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Executes 'cmd' in the shell and reads its output in
#@ 'arr_out'.
#@ Returns: The number of lines read.
#
function exec_cmd_base(cmd, arr_out,    _line, _i) {

	delete arr_out
	_i = 0
	while ((cmd | getline _line) > 0)
		arr_out[++_i] = _line
	close(cmd)
	return _i
}

#
#@ Description: Like exec_cmd_base() but redirects stderr of 'cmd' into
#@ stdout and fetches the exit code of 'cmd'. This is achieved by
#@ appending the redirection and the echo commands for the exit code to
#@ 'cmd' before exec_cmd_base() is called. A bash-like shell is assumed.
#@ Returns: The number of lines read. The exit code is always the last
#@ line and hence the last element of 'arr_out'.
#
function exec_cmd_sh(cmd, arr_out,    _len) {

	cmd = (cmd " 2>&1; printf \"\n$?\n\"")
	_len = exec_cmd_base(cmd, arr_out)
	
	if (!arr_out[_len-1]) {
		arr_out[_len-1] = arr_out[_len]
		--_len
	}
	
	return _len
}
#@ </exec_cmd>
#@ <awklib_array>
#@ Library: arr
#@ Description: Array functionality.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function arr_init(arr) {

	arr[""]
	delete arr
}

#
#@ Description: Clears 'arr_dest', puts all keys of 'map' in 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_keys(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = _n
	return _i
}

#
#@ Description: Clears 'arr_dest', puts all values of 'map' in
#@ 'arr_dest'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_from_map_vals(arr_dest, map,    _i, _n) {
	
	delete arr_dest
	_i = 0
	for (_n in map)
		arr_dest[++_i] = map[_n]
	return _i
}

#
#@ Description: Clears 'arr_dest' and copies the range defined by
#@ 'src_begin' and 'src_end' from 'arr_src' to 'arr_dest'. The range is
#@ inclusive. If 'src_begin' is larger than 'src_end', nothing is
#@ copied.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_range(arr_dest, arr_src, src_begin, src_end,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = src_begin; _i <= src_end; ++_i)
		arr_dest[++_n] = arr_src[_i]
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies 'arr_src' into 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_copy(arr_dest, arr_src, src_len) {

	return arr_range(arr_dest, arr_src, 1, src_len)
}

#
#@ Description: Appends 'arr_src' to the end of 'arr_dest'.
#@ Returns: The length of 'arr_dest' after appending.
#@ Complexity: O(n)
#
function arr_append(arr_dest, dest_len, arr_src, src_len,    _i) {

	for (_i = 1; _i <= src_len; ++_i)
		arr_dest[++dest_len] = arr_src[_i]
	return dest_len
}

#
#@ Description: Clears 'arr_dest', places all elements from 'arr_src'
#@ which are at indexes contained in 'arr_ind' in 'arr_dest'. E.g. given
#@ 'arr_ind[1] = 5; arr_ind[2] = 6', 'arr_dest' will get
#@ 'arr_dest[1] = arr_src[5]; arr_dest[2] = arr_src[6]'
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_gather(arr_dest, arr_src, arr_ind, ind_len,    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= ind_len; ++_i)
		arr_dest[++_n] = arr_src[arr_ind[_i]]
	return _n
}

#
#@ Description: Finds the index of the first match for 'regex' in 'arr'.
#@ Returns: The index of the first match, 0 if not match is found.
#@ Complexity: O(n)
#
function arr_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all matches
#@ for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match_ind_all(arr_dest, arr_src, src_len, regex,    _i,
_n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which match
#@ 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Finds the index of the first non-match for 'regex' in
#@ 'arr'.
#@ Returns: The index of the first non-match, 0 if all match.
#@ Complexity: O(n)
#
function arr_dont_match_ind_first(arr, len, regex,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (!match(arr[_i], regex))
			return _i
	}
	return 0
}

#
#@ Description: Clears 'arr_dest', places the indexes for all
#@ non-matches for 'regex' in 'arr_src' in 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match_ind_all(arr_dest, arr_src, src_len, regex,
    _i, _n) {
	
	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = _i
	}
	return _n
}

#
#@ Description: Clears 'arr_dest' and copies all elements which do not
#@ match 'regex' from 'arr_src' to 'arr_dest'.
#@ Returns: The length of 'arr_dest'.
#@ Complexity: O(n)
#
function arr_dont_match(arr_dest, arr_src, src_len, regex,    _i, _n) {

	delete arr_dest
	_n = 0
	for (_i = 1; _i <= src_len; ++_i) {
		if (!match(arr_src[_i], regex))
			arr_dest[++_n] = arr_src[_i]
	}
	return _n
}

#
#@ Description: Calls 'sub()' for every element of 'arr' like
#@ 'sub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_sub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += sub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Calls gsub() for every element of 'arr' like
#@ 'gsub(regex, subst, arr[i])'
#@ Returns: The number of substitutions made.
#@ Complexity: O(n)
#
function arr_gsub(arr, len, regex, subst,    _i, _n) {

	_n = 0
	for (_i = 1; _i <= len; ++_i)
		_n += gsub(regex, subst, arr[_i])
	return _n
}

#
#@ Description: Checks if 'arr_a' and 'arr_b' have the same elements.
#@ Returns: 1 if the arrays are equal, 0 otherwise.
#@ Complexity: O(n)
#
function arr_is_eq(arr_a, len_a, arr_b, len_b,    _i) {

	if (len_a != len_b)
		return 0
	for (_i = 1; _i <= len_a; ++_i) {
		if (arr_a[_i] != arr_b[_i])
			return 0
	}
	return 1
}

#
#@ Description: Finds 'val' in 'arr'.
#@ Returns: The index of 'val' if it's found, 0 otherwise.
#@ Complexity: O(n)
#
function arr_find(arr, len, val,    _i) {
	
	for (_i = 1; _i <= len; ++_i) {
		if (arr[_i] == val)
			return _i
	}
	return 0
}

#
#@ Description: Concatenates all elements of 'arr' into a single string.
#@ The elements are separated by 'sep'. It 'sep' is not given, " " is
#@ used. 'sep' does not appear after the last element.
#@ Returns: The string representation of 'arr'.
#@ Complexity: O(n)
#
function arr_to_str(arr, len, sep,    _i, _str) {
	
	if (len < 1)
		return ""
	
	if (!sep)
		sep = " "
		
	_str = arr[1]
	for (_i = 2; _i <= len; ++_i)
		_str = (_str sep arr[_i])
	
	return _str
}

#
#@ Description: Prints 'arr' to stdout.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function arr_print(arr, len, sep) {

	print arr_to_str(arr, len, sep)
}
#@ </awklib_array>
#@ <awklib_vect>
#@ Library: vect
#@ Description: Vector functionality. A vector is as array which is
#@ aware of its own size.
#@ Dependencies: awklib_array.awk
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-20
#@

#
#@ Description: Clears 'vect', initializes it with length 0.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_init(vect) {

	vect[""]
	delete vect
	vect[_VECT_LEN()] = 0
}

#
#@ Description: Initializes 'vect' to a copy of 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_init_arr(vect, arr, len,    _i) {
	
	vect_init(vect)
	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Appends 'val' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_push(vect, val) {

	vect[++vect[_VECT_LEN()]] = val
}

#
#@ Description: Appends 'arr' to 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_push_arr(vect, arr, len,    _i) {

	for (_i = 1; _i <= len; ++_i)
		vect[++vect[_VECT_LEN()]] = arr[_i]
}

#
#@ Description: Retrieves the last value from 'vect'.
#@ Returns: The last element.
#@ Complexity: O(1)
#
function vect_peek(vect) {

	return vect[vect[_VECT_LEN()]]
}

#
#@ Description: Removes the last element of 'vect'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_pop(vect) {

	vect[--vect[_VECT_LEN()]]
}

#
#@ Description: Provides the length.
#@ Returns: The length of 'vect'.
#@ Complexity: O(1)
#
function vect_len(vect) {
	
	return vect[_VECT_LEN()]
}

#
#@ Description: Indicates if 'vect' is empty or not.
#@ Returns: 1 if 'vect' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function vect_is_empty(vect) {

	return (!vect[_VECT_LEN()])
}

#
#@ Description: Removes the element in 'vect' at index 'ind' by moving
#@ all further elements one to the left.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_ind(vect, ind,    _i, _len) {
	
	_len = vect[_VECT_LEN()]
	for (_i = ind; _i < _len; ++_i)
		vect[_i] = vect[_i+1]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes 'val' from 'vect' by  if (arr_find())
#@ vect_del_ind().
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function vect_del_val(vect, val,    _ind) {
	
	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_del_ind(vect, _ind)
}

#
#@ Description: Removes the element at 'ind' from 'vect' by replacing it
#@ with the last element.
#@ Returns: Nothing
#@ Complexity: O(1)
#
function vect_swap_pop_ind(vect, ind) {
	
	vect[ind] = vect[vect[_VECT_LEN()]]
	--vect[_VECT_LEN()]
}

#
#@ Description: Removes the first instance of 'val' from 'vect' by
#@ if (arr_find()) vect_swap_pop_ind().
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function vect_swap_pop_val(vect, val, _ind) {

	if (_ind = arr_find(vect, vect[_VECT_LEN()], val))
		vect_swap_pop_ind(vect, _ind)
}

function _VECT_LEN() {return "len"}
#@ </awklib_vect>
#@ <awklib_eos>
#@ Library: eos
#@ Description: An entry order set. Implemented in terms of a vector.
#@ The elements appear in the order they were entered.
#@ Dependencies: awklib_vect.awk
#@ Version: 1.0.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-10
#@

#
#@ Description: Clears 'eos'.
#@ Returns: Nothing.
#@ Complexity: O(1)
#
function eos_init(eos) {

	vect_init(eos)
}

#
#@ Description: 'eos' is initialized to a set created from 'arr'.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_init_arr(eos, arr, len,    _i) {

	vect_init(eos)
	for (_i = 1; _i <= len; ++_i)
		eos_add(eos, arr[_i])
}

#
#@ Description: Adds 'val' to 'eos' only if 'val' is not already there.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_add(eos, val) {

	if (!arr_find(eos, vect_len(eos), val))
		vect_push(eos, val)
}

#
#@ Description: If found, removes 'val' from 'eos'. Keeps the relative
#@ order.
#@ Returns: Nothing.
#@ Complexity: O(n)
#
function eos_del(eos, val) {

	vect_del_val(eos, val)
}

#
#@ Description: Indicates if 'val' exists in 'eos'.
#@ Returns: 0 if 'val' is not found, the index of 'val' in 'eos'
#@ otherwise.
#@ Complexity: O(n)
#
function eos_has(eos, val) {

	return arr_find(eos, vect_len(eos), val)
}

#
#@ Description: Indicates the size of 'eos'.
#@ Returns: The number of elements.
#@ Complexity: O(1)
#
function eos_size(eos) {

	return vect_len(eos)
}

#
#@ Description: Indicates if 'eos' is empty.
#@ Returns: 1 if 'eos' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function eos_is_empty(eos) {

	return vect_is_empty(eos)
}

#
#@ Description: 'eos_dest' gets all elements from both 'eos_a' and
#@ 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_union(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init_arr(eos_dest, eos_a, vect_len(eos_a))

	_len = vect_len(eos_b)
	for (_i = 1; _i <= _len; ++_i)
		eos_add(eos_dest, eos_b[_i])
}

#
#@ Description: 'eos_dest' gets all elements from 'eos_a' which are also
#@ in 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_intersect(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init(eos_dest)

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (eos_has(eos_b, eos_a[_i]))
			vect_push(eos_dest, eos_a[_i])
	}
}

#
#@ Description: 'eos_dest' gets all elements from 'eos_a' which are not
#@ in 'eos_b'.
#@ Returns: Nothing.
#@ Complexity: O(n*m)
#
function eos_subtract(eos_dest, eos_a, eos_b,    _i, _len) {

	vect_init(eos_dest)

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (!eos_has(eos_b, eos_a[_i]))
			vect_push(eos_dest, eos_a[_i])
	}
}

#
#@ Description: Indicates if 'eos_a' and 'eos_b' have no elements in common.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function eos_are_disjoint(eos_a, eos_b,    _eos_tmp) {

	_len = vect_len(eos_b)
	for (_i = 1; _i <= _len; ++_i) {
		if (eos_has(eos_a, eos_b[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Indicates if 'eos_a' is a subset of 'eos_b'.
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function eos_is_subset(eos_a, eos_b,    _i, _len) {

	_len = vect_len(eos_a)
	for (_i = 1; _i <= _len; ++_i) {
		if (!eos_has(eos_b, eos_a[_i]))
			return 0
	}
	return 1
}
#@ </awklib_eos>
