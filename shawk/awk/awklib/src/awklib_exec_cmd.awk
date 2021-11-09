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
