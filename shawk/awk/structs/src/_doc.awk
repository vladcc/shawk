# <doc>
function print_help() {
print sprintf("%s - type compiler", SCRIPT_NAME())
print ""
print use_str()
print ""
print "Compiles type descriptions into a type system in awk. 'Compiles in awk'"
print "means it generates awk source code for setters/getters for each type's"
print "members, along with facilities to create an entity of a certain type, check"
print "its type, and a table to remember what values all type variables have. For"
print "an example use the following as an input file:"
print ""
print "start"
print "type btree"
print "has  data"
print "has  left  btree"
print "has  right btree"
print "end"
print ""
print "Options:"
print "-vFsm=1     - print the fsm 'grammar'"
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
function use_str() {return sprintf("Use: %s <structs-file>", SCRIPT_NAME())}
function print_use_try() {
pstderr(use_str())
pstderr(sprintf("Try: %s -vHelp=1", SCRIPT_NAME()))
exit_failure()
}
# </doc>
