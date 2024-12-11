BEGIN {
	set_program_name("backend_parser.awk")
	lex_init()
	if (rdpg_parse())
		ast_traverse_for_backed()
}
