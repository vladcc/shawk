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
