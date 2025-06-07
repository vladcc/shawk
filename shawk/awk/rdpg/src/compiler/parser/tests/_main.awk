# Test definitions
function if_fatal_exit() {}
function err_quit_fpos(msg, line_num) {
	error_quit(sprintf("%s:%d: %s", fname(), line_num, msg))
}
function error_print(msg) {
	print sprintf("error: %s", msg) > "/dev/stderr"
}
function error_quit(msg) {
	error_print(msg)
	exit(1)
}

function fname() {return FILENAME}

BEGIN {
	lex_init()
	if (rdpg_parse()) {
		print ""
		print "#### TREE ORIGINAL ####"
		print ""
		ast_dbg_print(ast_root())
		print ""
		print "#### TREE REWRITTEN ####"
		print ""
		ast_mod_rewrite()
		ast_dbg_print(ast_root())
		print ""
		print "#### SYM TBL ####"
		print ""
		ast_to_sym_tbl()
		st_dbg_print()
	}

	exit(parsing_error_happened())
}
