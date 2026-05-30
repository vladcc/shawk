# <doc>
function print_help() {
print sprintf("%s - type compiler", SCRIPT_NAME())
print ""
print use_str()
print ""
print "Compiles type descriptions into a type system in awk. 'Compiles in awk'"
print "means it generates awk source code for setters/getters for each type's"
print "members, along with functions to create a variable of a certain type,"
print "check its type, and a table to remember what values all its members"
print "have. For a starter example use the following as an input file:"
print ""
print "start"
print "type btree"
print "has  data"
print "has  left  btree"
print "has  right btree"
print "end"
print ""
print "Unions of type names and prefixing are supported. Unions can refer to"
print "other unions. E.g. in"
print ""
print "start"
print ""
print "prefix ast"
print ""
print "type uint"
print "has  val"
print ""
print "type int"
print "has  val"
print ""
print "type double"
print "has  val"
print ""
print "union u_signed"
print "name  int"
print "name  double"
print ""
print "union u_number"
print "name  uint"
print "name  u_signed"
print ""
print "type number"
print "has node u_number"
print ""
print "end"
print ""
print "member 'node' in a variable of type 'number' can be of either type uint,"
print "int, or double. To set 'node' to a variable of any other type will be an"
print "error. Because of the prefix option, all generated function names will"
print "be prefixed by 'ast_', e.g."
print "ast_number_make(), ast_number_set_node(), ast_number_get_node() etc."
print "The default prefix is 'ent_'"
print ""
print "The user must define an error function which the generated code can call."
print "In the prefixed example the function looks like: ast_errq(msg)"
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
function use_str() {return sprintf("Use: %s <structs-file>", SCRIPT_NAME())}
function print_use_try() {
pstderr(use_str())
pstderr(sprintf("Try: %s -vHelp=1", SCRIPT_NAME()))
exit_failure()
}
# </doc>
