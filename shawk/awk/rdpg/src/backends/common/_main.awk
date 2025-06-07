BEGIN {
	set_program_name(SCRIPT_NAME())
	init()
	lex_init()
	if (!rdpg_parse())
		exit_failure()
	ast_traverse_for_backed()
}
