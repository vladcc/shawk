# <doc>
function print_help() {
print sprintf("%s - type compiler", SCRIPT_NAME())
print ""
print use_str()
print ""
print "Compiles table descriptions into a type system in awk. 'Compiles in awk'"
print "means it generates awk source code for setters/getters for each table's"
print "fields, along with functions to create a variable of a certain type of,"
print "table, check its type, and a db to remember the values of all fields."
print ""
print "The user must define an error function which the generated code can call."
print "With the default prefix the function looks like: tables_errq(msg)"
print ""
print "Options:"
print "-vFsm=1     - print the fsm grammar"
print "-vVersion=1 - version information"
print "-vHelp=1    - this screen"
exit_success()
}
function print_fsm() {
	print DESCRIPT_FSM()
	exit_success()
}
function print_version() {
	print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
	exit_success()
}
function use_str() {
	return sprintf("Use: %s <tables-file>", SCRIPT_NAME())
}
function print_use_try() {
	pstderr(use_str())
	pstderr(sprintf("Try: %s -vHelp=1", SCRIPT_NAME()))
	exit_failure()
}
# </doc>
