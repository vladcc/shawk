#!/usr/bin/awk -f

function test_exec_cmd_base(    _cmd, _arr) {
	at_test_begin("exec_cmd_base()")

	_cmd = "printf 'line 1\nline 2\nline 3\n'"
	at_true(3 == exec_cmd_base(_cmd, _arr))
	
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
}

function test_exec_cmd_sh(    _cmd, _arr) {
	at_test_begin("exec_cmd_sh()")
	
	# No new line after output
	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\"); exit(0)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("0" == _arr[4])

	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\"); exit(1)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("1" == _arr[4])

	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\") > \"/dev/stderr\";"\
"exit(0)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("0" == _arr[4])
	
	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\") > \"/dev/stderr\";"\
"exit(1)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("1" == _arr[4])
	
	
	# New line after output
	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\\n\"); exit(0)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("0" == _arr[4])

	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\\n\"); exit(1)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("1" == _arr[4])

	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\\n\") > "\
"\"/dev/stderr\"; exit(0)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("0" == _arr[4])
	
	_cmd = \
"awk 'BEGIN {printf(\"line 1\\nline 2\\nline 3\\n\") > "\
"\"/dev/stderr\";exit(1)}'"
	at_true(4 == exec_cmd_sh(_cmd, _arr))
	at_true("line 1" == _arr[1])
	at_true("line 2" == _arr[2])
	at_true("line 3" == _arr[3])
	at_true("1" == _arr[4])
}

function main() {
	at_awklib_awktest_required()
	test_exec_cmd_base()
	test_exec_cmd_sh()
	
	if (Report)
		at_report()
}

BEGIN {
	main()
}
