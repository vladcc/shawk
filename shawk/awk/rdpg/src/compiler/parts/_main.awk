#!/usr/bin/awk -f

# <rdpg-main>
function SCRIPT_NAME() {return "rdpg-comp.awk"}
function SCRIPT_VERSION() {return "2.1.0"}

# <opts>
function OPT_IMM()         {return "Imm"}
function OPT_SYNC()        {return "Sync"}
function OPT_WARN_ALL()    {return "WarnAll"}
function OPT_WARN_REACH()  {return "WarnReach"}
function OPT_WARN_ESC()    {return "WarnEsc"}
function OPT_WARN_ERR()    {return "WarnErr"}
function OPT_FATAL_ERR()   {return "FatalErr"}
function OPT_GRAMMAR()     {return "Grammar"}
function OPT_RULES()       {return "Rules"}
function OPT_SETS()        {return "Sets"}
function OPT_TABLE()       {return "Table"}
function OPT_CHECK()       {return "Check"}

function opt_imm_set(str)      {_B_rdpg_opt_tbl[OPT_IMM()] = str}
function opt_imm()             {return _B_rdpg_opt_tbl[OPT_IMM()]}

function opt_sync_set(str)      {_B_rdpg_opt_tbl[OPT_SYNC()] = str}
function opt_sync()             {return _B_rdpg_opt_tbl[OPT_SYNC()]}

function opt_warn_all_set(val)  {_B_rdpg_opt_tbl[OPT_WARN_ALL()] = val}
function opt_warn_all()         {return _B_rdpg_opt_tbl[OPT_WARN_ALL()]}
function opt_warn_reach_set(val) {_B_rdpg_opt_tbl[OPT_WARN_REACH()] = val}
function opt_warn_reach() {
	return (opt_warn_all() || _B_rdpg_opt_tbl[OPT_WARN_REACH()])
}
function opt_warn_esc_set(val) {_B_rdpg_opt_tbl[OPT_WARN_ESC()] = val}
function opt_warn_esc() {
	return (opt_warn_all() || _B_rdpg_opt_tbl[OPT_WARN_ESC()])
}

function opt_warn_is_err_set(val) {_B_rdpg_opt_tbl[OPT_WARN_ERR()] = val}
function opt_warn_is_err()        {return _B_rdpg_opt_tbl[OPT_WARN_ERR()]}

function opt_fatal_err_set(val) {_B_rdpg_opt_tbl[OPT_FATAL_ERR()] = val}
function opt_fatal_err()        {return _B_rdpg_opt_tbl[OPT_FATAL_ERR()]}

function opt_grammar_set(val) {_B_rdpg_opt_tbl[OPT_GRAMMAR()] = val}
function opt_grammar() {return _B_rdpg_opt_tbl[OPT_GRAMMAR()]}

function opt_rules_set(val) {_B_rdpg_opt_tbl[OPT_RULES()] = val}
function opt_rules() {return _B_rdpg_opt_tbl[OPT_RULES()]}

function opt_sets_set(val) {_B_rdpg_opt_tbl[OPT_SETS()] = val}
function opt_sets() {return _B_rdpg_opt_tbl[OPT_SETS()]}

function opt_tbl_set(val) {_B_rdpg_opt_tbl[OPT_TABLE()] = val}
function opt_tbl() {return _B_rdpg_opt_tbl[OPT_TABLE()]}

function opt_check_set(val) {_B_rdpg_opt_tbl[OPT_CHECK()] = val}
function opt_check() {return _B_rdpg_opt_tbl[OPT_CHECK()]}
# </opts>

# <warning>
function warn_checks(    _warn) {
	_warn = 0
	if (opt_warn_reach())
		_warn = keep(check_warn_reachability(), _warn)
	if (opt_warn_esc())
		_warn = keep(check_warn_esc_tail_rec(), _warn)
	return _warn
}
function warn_happened() {return _B_warn_happened}
function warn_fpos(lhs, msg) {
	_B_warn_happened = 1

	msg_stderr(sprintf("warning: file '%s', line %s, non-terminal '%s': %s\n", \
		fname(), st_lhs_line_num(lhs), lhs, msg))

	if (opt_warn_is_err())
		if_fatal_exit()
}
# </warning>

# <error>
function if_fatal_exit(    _str) {
	if (opt_fatal_err()) {
		opt_fatal_err_set(opt_fatal_err()-1)

		if (0 == opt_fatal_err()) {
			if (opt_warn_is_err() && warn_happened())
				_str = sprintf("%s && %s", OPT_WARN_ERR(), OPT_FATAL_ERR())

			if (!_str)
				_str = OPT_FATAL_ERR()

			msg_stderr(sprintf("exiting due to %s", _str))
			exit_failure()
		}
	}
}

function err_checks(    _err) {
	_err = 0
	_err = keep(check_err_undefined(),      _err)
	_err = keep(check_err_left_factor(),    _err)
	_err = keep(check_err_left_recursion(), _err)
	_err = keep(check_err_conflicts(),      _err)
	return _err
}

function err_quit_fpos(msg, line_num) {
	error_quit(sprintf("file '%s' line %s: %s", fname(), line_num, msg))
}
function err_fpos(lhs, msg) {
	error_print(sprintf("file '%s', line %s, non-terminal '%s': %s\n", \
		fname(), st_lhs_line_num(lhs), lhs, msg))

	if_fatal_exit()
}

function msg_stderr(msg) {
	pstderr(sprintf("%s: %s", get_program_name(), msg))
}
# </error>

# <misc>
function fname() {return FILENAME}

function print_grammar() {ast_print_grammar()}
function print_rules()   {st_print_rules()}
function print_sets()    {sets_print()}
function print_tbl()     {pt_print()}

function parse_grammar() {
	lex_init()
	if (!rdpg_parse())
		error_quit("parsing failed")
	ast_mod_rewrite()
	ast_to_sym_tbl()
}
function process_grammar() {
	sets_init()
}
function check_grammar(    _warn, _err) {
	_warn = warn_checks()
	_err = err_checks()
	if ((opt_warn_is_err() && _warn) && !_err) {
		msg_stderr(sprintf("exiting due to %s", OPT_WARN_ERR()))
		exit_failure()
	}
	if (_err)
		exit_failure()
}
function generate_code() {cg_generate()}
# </misc>

# <main>
function init() {
	RS = "\n"
	FS = " "

	set_program_name(SCRIPT_NAME())

	if (Example) {
		print_example()
		exit_success()
	}

	if (Help) {
		print_help()
		exit_success()
	}

	if (Version) {
		print_version()
		exit_success()
	}

	if (ARGC != 2) {
		print_use_try()
		exit_failure()
	}

	opt_imm_set(("0" == Imm) ? 0 : 1)

	opt_sync_set(Sync)
	sync_init(opt_sync())

	opt_warn_all_set(WarnAll)
	opt_warn_reach_set(WarnReach)
	opt_warn_esc_set(WarnEsc)
	opt_warn_is_err_set(WarnErr)
	opt_fatal_err_set(FatalErr)
	opt_grammar_set(Grammar)
	opt_rules_set(Rules)
	opt_sets_set(Sets)
	opt_tbl_set(Table)
	opt_check_set(Check)
}

function main() {
	init()

	parse_grammar()

	if (opt_grammar()) {
		 print_grammar()
		 exit_success()
	}

	if (opt_rules()) {
		print_rules()
		exit_success()
	}

	process_grammar()

	if (opt_sets()) {
		print_sets()
		exit_success()
	}

	check_grammar()

	if (opt_check())
		exit_success()

	if (opt_tbl()) {
		print_tbl()
		exit_success()
	}

	generate_code()
}
# </main>

# <awk_rules>
BEGIN {
	main()
}
# </awk_rules>
# </rdpg-main>
