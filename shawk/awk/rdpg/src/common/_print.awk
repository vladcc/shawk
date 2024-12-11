# <print>
function tinc() {tabs_inc()}
function tdec() {tabs_dec()}
function tget() {return tabs_get()}
function tnum() {return tabs_num()}

function stdout_set(fnm) {_B_print_stdout = fnm}
function stdout_get() {
	if (!_B_print_stdout)
		_B_print_stdout = "/dev/stdout"
	return _B_print_stdout
}
function emit(str) {print (tget() str) > stdout_get()}
function nl()      {print "" > stdout_get()}
# </print>
