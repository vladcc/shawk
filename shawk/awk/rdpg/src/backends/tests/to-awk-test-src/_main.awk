BEGIN {
	if (rdpg_parse())
		exprs_process()
	else
		exit(1)
}
