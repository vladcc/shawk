#!/usr/bin/awk -f

# Use: make-awktest.awk <awk-source-file>
# Generates template code for awklib_awktest.awk - one test per function
# in the source file.

function make_fname(str) {sub("\\(.*$", "", str); return str}
function save_fname(str) {_B_fnames[++_B_fname_count] = str}
function get_fname_count() {return _B_fname_count}
function get_fname(n) {return _B_fnames[n]}
function set_args(str) {_B_args = str}
function get_args() {return _B_args}

function gen_tests(    _i, _end, _fname, _fargs) {
	print "#!/usr/bin/awk -f"
	print ""
	
	_end = get_fname_count()
	for (_i = 1; _i <= _end; ++_i) {
		_fname = get_fname(_i)
		_fargs = get_args()
		
		print sprintf("function test_%s(%s) {",
			_fname, _fargs ? _fargs : "")
		print sprintf("\tat_test_begin(\"%s()\")",  _fname)
		print ""
		print ""
		print ""
		print "\tat_true()"
		print "}"
		print ""
	}
	
	print "function main() {"
	print "\tat_awklib_awktest_required()"
	for (_i = 1; _i <= _end; ++_i) {
		_fname = get_fname(_i)
		print sprintf("\ttest_%s()", _fname)
	}
	print ""
	print "\tif (Report)"
	print "\t\tat_report()"
	print "}"
	print ""
	
	print "BEGIN {"
	print "\tmain()"
	print "}"
}

BEGIN {
	set_args(Args)
}

$1 ~ /function/ {
	save_fname(make_fname($2))
}

END {
	gen_tests()
}
