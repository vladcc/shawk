BEGIN {
	set_program_name(SCRIPT_NAME())
	init()
	lex_init()
	if (!rdpg_parse())
		error_quit("parsing failed")
	ast_traverse_for_backed()
}
