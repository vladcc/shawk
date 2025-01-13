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
# <rdpg_ir>
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2024-06-24

# version 2.0
# A generic intermediate representation. If optimization is performed, it's
# performed on this. Then it's fed into a back-end for translation to the target
# language.
function IR_COMMENT() {return "#"}

function IR_SETS() {return "sets"}

function IR_ALIAS() {return "alias"}
function IR_PREDICT() {return "predict"}
function IR_EXPECT() {return "expect"}
function IR_SYNC() {return "sync"}

function IR_ESC() {return "\\"}
function IR_FUNC() {return "func"}
function IR_CALL() {return "call"}
function IR_RETURN() {return "return"}

function IR_TOKENS() {return "tokens"}

function IR_TRUE() {return "true"}
function IR_FALSE() {return "false"}

function IR_RDPG_PARSE() {return "rdpg_parse"}
function IR_AND() {return "&&"}

function IR_BLOCK_OPEN() {return "{"}
function IR_BLOCK_CLOSE() {return "}"}

function IR_IF() {return "if"}
function IR_ELSE_IF() {return "else_if"}
function IR_ELSE() {return "else"}

function IR_LOOP() {return "loop"}
function IR_CONTINUE() {return "continue"}

function IR_TOK_MATCH() {return "tok_match"}
function IR_TOK_IS() {return "tok_is"}
function IR_TOK_NEXT() {return "tok_next"}
function IR_TOK_CURR() {return "tok_curr"}
function IR_TOK_EOI() {return "tok_eoi"}
function IR_TOK_ERR() {return "tok_err"}
function IR_WAS_NO_ERR() {return "was_no_err"}
# </rdpg_ir>
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
# <parser>
# <lexer>
# <lex_awk>
# generated by lex-awk.awk 1.7.3

# <lex_usr_defined>
# The user implements the following:
# lex_usr_get_line()
# lex_usr_on_unknown_ch()
# lex_usr_get_word()
# lex_usr_on_comment()
# </lex_usr_defined>

# <lex_public>
# <lex_constants>

# the only way to have immutable values; use as constants
function COLON() {return ":"}
function BAR() {return "|"}
function SEMI() {return ";"}
function QMARK() {return "?"}
function STAR() {return "*"}
function PLUS() {return "+"}
function ESC() {return "\\"}
function TOK_EOI() {return "EOI"}
function START_SYM() {return "start"}
function TERM() {return "terminal"}
function NONT() {return "non-terminal"}
function TOK_ERROR() {return "error"}

function CH_CLS_SPACE() {return 1}
function CH_CLS_WORD() {return 2}
function CH_CLS_NUMBER() {return 3}
function CH_CLS_CMNT() {return 4}
function CH_CLS_NEW_LINE() {return 5}
function CH_CLS_EOI() {return 6}
function CH_CLS_AUTO_1_() {return 7}
function CH_CLS_AUTO_2_() {return 8}
function CH_CLS_AUTO_3_() {return 9}
function CH_CLS_AUTO_4_() {return 10}
function CH_CLS_AUTO_5_() {return 11}
function CH_CLS_AUTO_6_() {return 12}
function CH_CLS_AUTO_7_() {return 13}
# </lex_constants>

# read the next character; advance the input
function lex_read_line(    _ln) {
	# Note: the user defines lex_usr_get_line()
	if (_ln = lex_usr_get_line()) {
		_B_lex_line_str = _ln
		split(_B_lex_line_str, _B_lex_input_line, "")
		++_B_lex_line_no
		_B_lex_line_pos = 1
		return 1
	}
	_B_lex_line_pos = length(_B_lex_line_str)+2
	return 0
}

# read the next character and advance the input
function lex_read_ch() {
	_B_lex_curr_ch = _B_lex_input_line[_B_lex_line_pos++]
	_B_lex_peek_ch = _B_lex_input_line[_B_lex_line_pos]
	if (_B_lex_peek_ch != "" || lex_read_line())
		return _B_lex_curr_ch
	else if ("" == _B_lex_curr_ch)
		--_B_lex_line_pos
	return _B_lex_curr_ch
}

# return the last read character
function lex_curr_ch()
{return _B_lex_curr_ch}

# return the next character, but do not advance the input
function lex_peek_ch()
{return _B_lex_peek_ch}

# return the position in the current line of input
function lex_get_pos()
{return (_B_lex_line_pos-1)}

# return the current line number
function lex_get_line_no()
{return _B_lex_line_no}

# return the last read token
function lex_curr_tok()
{return _B_lex_curr_tok}

# see if your token is the same as the one in the lexer
function lex_match_tok(str)
{return (str == _B_lex_curr_tok)}

# clear the lexer write space
function lex_save_init()
{_B_lex_saved = ""}

# save the last read character
function lex_save_curr_ch()
{_B_lex_saved = (_B_lex_saved _B_lex_curr_ch)}

# return the saved string
function lex_get_saved()
{return _B_lex_saved}

# character classes
function lex_is_ch_cls(ch, cls)
{return (cls == _B_lex_ch_tbl[ch])}

function lex_is_curr_ch_cls(cls)
{return (cls == _B_lex_ch_tbl[_B_lex_curr_ch])}

function lex_is_next_ch_cls(cls)
{return (cls == _B_lex_ch_tbl[_B_lex_peek_ch])}

function lex_get_ch_cls(ch)
{return _B_lex_ch_tbl[ch]}

# see if what's in the lexer's write space is a keyword
function lex_is_saved_a_keyword()
{return (_B_lex_saved in _B_lex_keywords_tbl)}

# generate position string
function lex_get_pos_str(last_tok_txt,    _str, _offs) {
	return lex_pos_str_build(_B_lex_line_str, lex_get_pos(), last_tok_txt)
}
function lex_pos_str_build(line_str, pos, last_tok_txt,    _str, _offs) {
	_offs = (last_tok_txt) ? length(last_tok_txt) : 1
	_str = substr(line_str, 1, pos-_offs)
	gsub("[^[:space:]]|\\n", " ", _str)
	return (line_str (_str "^"))
}

# call this first
function lex_init() {
	# '_B' variables are 'bound' to the lexer, i.e. 'private'
	if (!_B_lex_are_tables_init) {
		_lex_init_ch_tbl()
		_lex_init_keywords()
		_B_lex_are_tables_init = 1
	}
	_B_lex_curr_ch = ""
	_B_lex_curr_ch_cls_cache = ""
	_B_lex_curr_tok = "error"
	_B_lex_line_no = 0
	_B_lex_line_pos = 0
	_B_lex_peek_ch = ""
	_B_lex_peeked_ch_cache = ""
	_B_lex_saved = ""
	lex_read_line()
}

# return the next token; constants are inlined for performance
function lex_next() {
	_B_lex_curr_tok = "error"
	while (1) {
		_B_lex_curr_ch_cls_cache = _B_lex_ch_tbl[lex_read_ch()]
		if (1 == _B_lex_curr_ch_cls_cache) { # CH_CLS_SPACE()
			continue
		} else if (2 == _B_lex_curr_ch_cls_cache) { # CH_CLS_WORD()
			_B_lex_curr_tok = lex_usr_get_word()
		} else if (4 == _B_lex_curr_ch_cls_cache) { # CH_CLS_CMNT()
			_B_lex_curr_tok = lex_usr_on_comment()
		} else if (5 == _B_lex_curr_ch_cls_cache) { # CH_CLS_NEW_LINE()
			continue
		} else if (6 == _B_lex_curr_ch_cls_cache) { # CH_CLS_EOI()
			_B_lex_curr_tok = TOK_EOI()
		} else if (7 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_1_()
			_B_lex_curr_tok = ":"
		} else if (8 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_2_()
			_B_lex_curr_tok = "|"
		} else if (9 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_3_()
			_B_lex_curr_tok = ";"
		} else if (10 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_4_()
			_B_lex_curr_tok = "?"
		} else if (11 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_5_()
			_B_lex_curr_tok = "*"
		} else if (12 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_6_()
			_B_lex_curr_tok = "+"
		} else if (13 == _B_lex_curr_ch_cls_cache) { # CH_CLS_AUTO_7_()
			_B_lex_curr_tok = "\\"
		} else {
			_B_lex_curr_tok = lex_usr_on_unknown_ch()
		}
		break
	}
	return _B_lex_curr_tok
}
# </lex_public>

# <lex_private>
# initialize the lexer tables
function _lex_init_keywords() {
	_B_lex_keywords_tbl["start"] = 1
}
function _lex_init_ch_tbl() {
	_B_lex_ch_tbl[" "] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\t"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["a"] = CH_CLS_WORD()
	_B_lex_ch_tbl["b"] = CH_CLS_WORD()
	_B_lex_ch_tbl["c"] = CH_CLS_WORD()
	_B_lex_ch_tbl["d"] = CH_CLS_WORD()
	_B_lex_ch_tbl["e"] = CH_CLS_WORD()
	_B_lex_ch_tbl["f"] = CH_CLS_WORD()
	_B_lex_ch_tbl["g"] = CH_CLS_WORD()
	_B_lex_ch_tbl["h"] = CH_CLS_WORD()
	_B_lex_ch_tbl["i"] = CH_CLS_WORD()
	_B_lex_ch_tbl["j"] = CH_CLS_WORD()
	_B_lex_ch_tbl["k"] = CH_CLS_WORD()
	_B_lex_ch_tbl["l"] = CH_CLS_WORD()
	_B_lex_ch_tbl["m"] = CH_CLS_WORD()
	_B_lex_ch_tbl["n"] = CH_CLS_WORD()
	_B_lex_ch_tbl["o"] = CH_CLS_WORD()
	_B_lex_ch_tbl["p"] = CH_CLS_WORD()
	_B_lex_ch_tbl["q"] = CH_CLS_WORD()
	_B_lex_ch_tbl["r"] = CH_CLS_WORD()
	_B_lex_ch_tbl["s"] = CH_CLS_WORD()
	_B_lex_ch_tbl["t"] = CH_CLS_WORD()
	_B_lex_ch_tbl["u"] = CH_CLS_WORD()
	_B_lex_ch_tbl["v"] = CH_CLS_WORD()
	_B_lex_ch_tbl["w"] = CH_CLS_WORD()
	_B_lex_ch_tbl["x"] = CH_CLS_WORD()
	_B_lex_ch_tbl["y"] = CH_CLS_WORD()
	_B_lex_ch_tbl["z"] = CH_CLS_WORD()
	_B_lex_ch_tbl["A"] = CH_CLS_WORD()
	_B_lex_ch_tbl["B"] = CH_CLS_WORD()
	_B_lex_ch_tbl["C"] = CH_CLS_WORD()
	_B_lex_ch_tbl["D"] = CH_CLS_WORD()
	_B_lex_ch_tbl["E"] = CH_CLS_WORD()
	_B_lex_ch_tbl["F"] = CH_CLS_WORD()
	_B_lex_ch_tbl["G"] = CH_CLS_WORD()
	_B_lex_ch_tbl["H"] = CH_CLS_WORD()
	_B_lex_ch_tbl["I"] = CH_CLS_WORD()
	_B_lex_ch_tbl["J"] = CH_CLS_WORD()
	_B_lex_ch_tbl["K"] = CH_CLS_WORD()
	_B_lex_ch_tbl["L"] = CH_CLS_WORD()
	_B_lex_ch_tbl["M"] = CH_CLS_WORD()
	_B_lex_ch_tbl["N"] = CH_CLS_WORD()
	_B_lex_ch_tbl["O"] = CH_CLS_WORD()
	_B_lex_ch_tbl["P"] = CH_CLS_WORD()
	_B_lex_ch_tbl["Q"] = CH_CLS_WORD()
	_B_lex_ch_tbl["R"] = CH_CLS_WORD()
	_B_lex_ch_tbl["S"] = CH_CLS_WORD()
	_B_lex_ch_tbl["T"] = CH_CLS_WORD()
	_B_lex_ch_tbl["U"] = CH_CLS_WORD()
	_B_lex_ch_tbl["V"] = CH_CLS_WORD()
	_B_lex_ch_tbl["W"] = CH_CLS_WORD()
	_B_lex_ch_tbl["X"] = CH_CLS_WORD()
	_B_lex_ch_tbl["Y"] = CH_CLS_WORD()
	_B_lex_ch_tbl["Z"] = CH_CLS_WORD()
	_B_lex_ch_tbl["_"] = CH_CLS_WORD()
	_B_lex_ch_tbl["0"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["1"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["2"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["3"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["4"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["5"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["6"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["7"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["8"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["9"] = CH_CLS_NUMBER()
	_B_lex_ch_tbl["#"] = CH_CLS_CMNT()
	_B_lex_ch_tbl["\n"] = CH_CLS_NEW_LINE()
	_B_lex_ch_tbl[""] = CH_CLS_EOI()
	_B_lex_ch_tbl[":"] = CH_CLS_AUTO_1_()
	_B_lex_ch_tbl["|"] = CH_CLS_AUTO_2_()
	_B_lex_ch_tbl[";"] = CH_CLS_AUTO_3_()
	_B_lex_ch_tbl["?"] = CH_CLS_AUTO_4_()
	_B_lex_ch_tbl["*"] = CH_CLS_AUTO_5_()
	_B_lex_ch_tbl["+"] = CH_CLS_AUTO_6_()
	_B_lex_ch_tbl["\\"] = CH_CLS_AUTO_7_()
}
# </lex_private>
# </lex_awk>
# <lex_usr>
function parsing_error_happened() {return _B_parsing_error_flag}
function parsing_error_set() {_B_parsing_error_flag = 1}

function _tok_prev_set(tok) {_B_lex_tok_prev = tok}
function _tok_prev()        {return _B_lex_tok_prev}

function tok_next() {
	_tok_prev_set(lex_curr_tok())
	return lex_next()
}
function tok_curr() {return lex_curr_tok()}
function tok_err(    _str, _i, _end, _arr, _exp, _prev) {
	parsing_error_set()

	_str = sprintf("file %s, line %d, pos %d: unexpected '%s'", \
		fname(), lex_get_line_no(), lex_get_pos(), lex_curr_tok())

	if (_prev = _tok_prev())
		_str = (_str sprintf(" after '%s'", _prev))
	_str = (_str "\n")
	_str = (_str sprintf("%s\n", lex_get_pos_str()))

	_end = rdpg_expect(_arr)
	for (_i = 1; _i <= _end; ++_i)
		_exp = (_exp sprintf("'%s' ", _arr[_i]))

	if (1 == _end)
		_str = (_str sprintf("expected: %s", _exp))
	else if (_end > 1)
		_str = (_str sprintf("expected one of: %s", _exp))

	error_print((_str "\n"))

	if_fatal_exit()
}

function lex_usr_get_line(    _res) {
	if ((_res = getline) > 0)
		return ($0 "\n")
	else if (0 == _res)
		return ""

	error_quit(sprintf("getline io with code %s", _res))
}
function lex_usr_on_unknown_ch() {
	_lu_errq_pos(sprintf("unknown character '%s'", lex_curr_ch()))
}
function lex_usr_on_comment() {
	if (lex_read_line())
		return lex_next()
	else
		return TOK_EOI()
}

function _lu_is_upped(ch) {return (ch >= "A" && ch <= "Z")}
function _lu_is_lower(ch) {return (ch >= "a" && ch <= "z")}
function _lu_is_digit(ch) {return (ch >= "0" && ch <= "9")}
function _lu_is_name_part(ch) {return "_" == ch || _lu_is_digit(ch)}
function _lu_is_term_rest(ch) {return _lu_is_upped(ch) || _lu_is_name_part(ch)}
function _lu_is_nont_rest(ch) {return _lu_is_lower(ch) || _lu_is_name_part(ch)}

function _lu_errq_pos(msg) {
	error_quit(sprintf("%s: %s\n%s", _lu_pos(), msg, lex_get_pos_str()))
}
function _lu_pos() {
	return sprintf("file %s, line %d, pos %d", \
		fname(), lex_get_line_no(), lex_get_pos())
}

function lex_usr_get_word(    _ch) {
	lex_save_init()

	if (_lu_is_name_part(_ch = lex_curr_ch())) {
		lex_save_curr_ch()
		while (_lu_is_name_part(_ch = lex_peek_ch())) {
			lex_read_ch()
			lex_save_curr_ch()
		}

		if (!_lu_is_upped(_ch) && !_lu_is_lower(_ch))
			_lu_errq_pos(sprintf("name must contain at least one letter"))
		else
			lex_read_ch()
	}

	if (_lu_is_upped(_ch))
		return _get_term()
	else if (_lu_is_lower(_ch))
		return _get_nont()
	else
		return TOK_ERROR()
}

function _get_term(    _ch) {
	while (1) {
		lex_save_curr_ch()
		_ch = lex_peek_ch()
		if (_lu_is_term_rest(_ch))
			lex_read_ch()
		else
			break
	}

	if (lex_is_next_ch_cls(CH_CLS_WORD())) {
		lex_read_ch()
		_lu_errq_pos("non-upper case in a terminal symbol")
	}

	return TERM()
}

function _get_nont(    _ch) {
	while (1) {
		lex_save_curr_ch()
		_ch = lex_peek_ch()
		if (_lu_is_nont_rest(_ch))
			lex_read_ch()
		else
			break
	}

	if (lex_is_next_ch_cls(CH_CLS_WORD())) {
		lex_read_ch()
		_lu_errq_pos("non-lower case in a non-terminal symbol")
	}

	return (!lex_is_saved_a_keyword() ? NONT() : lex_get_saved())
}
# </lex_usr>
# </lexer>
# <prs>
# <parse>
#
# translated by rdpg-to-awk.awk 2.0.2
# generated by rdpg-comp.awk 2.1.0
# 
# Immediate error detection: 1
# 
# Grammar:
# 
# 1. start : grmr_defn_opt TOK_EOI
# 
# 2. grmr_defn : start_defn lhs_defn_plus
# 
# 3. grmr_defn_opt : grmr_defn
# 4. grmr_defn_opt : 0
# 
# 5. start_defn : START_SYM COLON NONT \on_top_sym nont_mod_opt TERM \on_eoi_term SEMI
# 
# 6. lhs_defn : NONT \on_lhs_start COLON rule bar_rule_star SEMI
# 
# 7. lhs_defn_plus : lhs_defn lhs_defn_star
# 
# 8. lhs_defn_star : lhs_defn lhs_defn_star
# 9. lhs_defn_star : 0
# 
# 10. rule : \on_rule_start esc_star sym_plus
# 
# 11. bar_rule : BAR rule
# 
# 12. bar_rule_star : bar_rule bar_rule_star
# 13. bar_rule_star : 0
# 
# 14. sym : grmr_sym esc_star
# 
# 15. sym_plus : sym sym_star
# 
# 16. sym_star : sym sym_star
# 17. sym_star : 0
# 
# 18. esc : ESC NONT \on_esc
# 
# 19. esc_star : esc esc_star
# 20. esc_star : 0
# 
# 21. grmr_sym : TERM \on_term
# 22. grmr_sym : NONT \on_nont nont_mod_opt
# 
# 23. nont_mod : QMARK \on_qmark
# 24. nont_mod : STAR \on_star
# 25. nont_mod : PLUS \on_plus
# 
# 26. nont_mod_opt : nont_mod
# 27. nont_mod_opt : 0
# 

# <public>
function rdpg_parse()
{
	_rdpg_init_sets()
	return _rdpg_start() && !_RDPG_had_error
}
function rdpg_expect(arr_out,    _len) {
	delete arr_out
	if ("tok" == _RDPG_expect_type)
		arr_out[(_len = 1)] = _RDPG_expect_what
	else if ("set" == _RDPG_expect_type)
		_len = split(_RDPG_expect_sets[_RDPG_expect_what], arr_out, _RDPG_SEP())
	return _len
}
# </public>
# <internal>
function _RDPG_SEP() {return "\034"}
function _rdpg_tok_next() {
	_RDPG_curr_tok = tok_next()
}
function _rdpg_tok_is(tok) {
	return (tok == _RDPG_curr_tok)
}
function _rdpg_tok_match(tok,    _ret) {
	if (_ret = _rdpg_tok_is(tok))
		_rdpg_tok_next()
	return _ret
}
function _rdpg_init_sets(    _i, _len, _arr) {
	# alias
	_RDPG_B_str_sym_set_1 = (TOK_EOI() _RDPG_SEP() START_SYM())
	_RDPG_B_str_sym_set_2 = (ESC() _RDPG_SEP() TERM() _RDPG_SEP() NONT())
	_RDPG_B_str_sym_set_3 = (TERM() _RDPG_SEP() NONT())
	_RDPG_B_str_sym_set_4 = (BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_5 = (TERM() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_6 = (QMARK() _RDPG_SEP() STAR() _RDPG_SEP() PLUS())
	_RDPG_B_str_sym_set_7 = (TERM() _RDPG_SEP() ESC() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_8 = (START_SYM() _RDPG_SEP() TOK_EOI())
	_RDPG_B_str_sym_set_9 = (NONT() _RDPG_SEP() TOK_EOI())
	_RDPG_B_str_sym_set_10 = (ESC() _RDPG_SEP() TERM() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_11 = (QMARK() _RDPG_SEP() STAR() _RDPG_SEP() PLUS() _RDPG_SEP() TERM() _RDPG_SEP() ESC() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_12 = (TOK_EOI())
	_RDPG_B_str_sym_set_13 = (NONT())
	_RDPG_B_str_sym_set_14 = (SEMI())

	_len = split(_RDPG_B_str_sym_set_1, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_1[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_2, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_2[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_3, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_3[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_4, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_4[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_5, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_5[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_6, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_6[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_7, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_7[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_8, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_8[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_9, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_9[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_10, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_10[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_11, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_11[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_12, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_12[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_13, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_13[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_14, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_14[_arr[_i]]

	# expect
	_RDPG_expect_sets["start"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["grmr_defn_opt"] = _RDPG_B_str_sym_set_8
	_RDPG_expect_sets["lhs_defn_star"] = _RDPG_B_str_sym_set_9
	_RDPG_expect_sets["rule"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["bar_rule_star"] = _RDPG_B_str_sym_set_4
	_RDPG_expect_sets["sym"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["sym_plus"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["sym_star"] = _RDPG_B_str_sym_set_5
	_RDPG_expect_sets["esc_star"] = _RDPG_B_str_sym_set_10
	_RDPG_expect_sets["grmr_sym"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["nont_mod"] = _RDPG_B_str_sym_set_6
	_RDPG_expect_sets["nont_mod_opt"] = _RDPG_B_str_sym_set_11
}
function _rdpg_predict(set) {
	return (_RDPG_curr_tok in set)
}
function _rdpg_sync(set) {
	while (_RDPG_curr_tok) {
		if (_RDPG_curr_tok in set)
			return 1
		if (_rdpg_tok_is(TOK_EOI()))
			break
		_rdpg_tok_next()
	}
	return 0
}
function _rdpg_expect(type, what) {
	_RDPG_expect_type = type
	_RDPG_expect_what = what
	_RDPG_had_error = 1
	tok_err()
}
# </internal>
# <rd>
function _rdpg_start()
{
	# 1. start : grmr_defn_opt TOK_EOI

	_rdpg_tok_next()
	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_grmr_defn_opt())
		{
			if (_rdpg_tok_match(TOK_EOI()))
			{
				return 1
			}
			else
			{
				_rdpg_expect("tok", TOK_EOI())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "start")
	}
	return 0
}
function _rdpg_grmr_defn()
{
	# 2. grmr_defn : start_defn lhs_defn_plus

	if (_rdpg_tok_is(START_SYM()))
	{
		if (_rdpg_start_defn())
		{
			if (_rdpg_lhs_defn_plus())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", START_SYM())
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_grmr_defn_opt()
{
	# 3. grmr_defn_opt : grmr_defn
	# 4. grmr_defn_opt : 0

	if (_rdpg_tok_is(START_SYM()))
	{
		if (_rdpg_grmr_defn())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(TOK_EOI()))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "grmr_defn_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_start_defn()
{
	# 5. start_defn : START_SYM COLON NONT \on_top_sym nont_mod_opt TERM \on_eoi_term SEMI

	if (_rdpg_tok_match(START_SYM()))
	{
		if (_rdpg_tok_match(COLON()))
		{
			if (_rdpg_tok_is(NONT()))
			{
				on_top_sym()
				_rdpg_tok_next()
				if (_rdpg_nont_mod_opt())
				{
					if (_rdpg_tok_is(TERM()))
					{
						on_eoi_term()
						_rdpg_tok_next()
						if (_rdpg_tok_match(SEMI()))
						{
							return 1
						}
						else
						{
							_rdpg_expect("tok", SEMI())
						}
					}
					else
					{
						_rdpg_expect("tok", TERM())
					}
				}
			}
			else
			{
				_rdpg_expect("tok", NONT())
			}
		}
		else
		{
			_rdpg_expect("tok", COLON())
		}
	}
	else
	{
		_rdpg_expect("tok", START_SYM())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_lhs_defn()
{
	# 6. lhs_defn : NONT \on_lhs_start COLON rule bar_rule_star SEMI

	if (_rdpg_tok_is(NONT()))
	{
		on_lhs_start()
		_rdpg_tok_next()
		if (_rdpg_tok_match(COLON()))
		{
			if (_rdpg_rule())
			{
				if (_rdpg_bar_rule_star())
				{
					if (_rdpg_tok_match(SEMI()))
					{
						return 1
					}
					else
					{
						_rdpg_expect("tok", SEMI())
					}
				}
			}
		}
		else
		{
			_rdpg_expect("tok", COLON())
		}
	}
	else
	{
		_rdpg_expect("tok", NONT())
	}
	return _rdpg_sync(_RDPG_sym_set_9)
}
function _rdpg_lhs_defn_plus()
{
	# 7. lhs_defn_plus : lhs_defn lhs_defn_star

	if (_rdpg_tok_is(NONT()))
	{
		if (_rdpg_lhs_defn())
		{
			if (_rdpg_lhs_defn_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NONT())
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_lhs_defn_star()
{
	# 8. lhs_defn_star : lhs_defn lhs_defn_star
	# 9. lhs_defn_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NONT()))
		{
			if (_rdpg_lhs_defn())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(TOK_EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "lhs_defn_star")
		}
		return _rdpg_sync(_RDPG_sym_set_12)
	}
}
function _rdpg_rule()
{
	# 10. rule : \on_rule_start esc_star sym_plus

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		on_rule_start()
		if (_rdpg_esc_star())
		{
			if (_rdpg_sym_plus())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "rule")
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_bar_rule()
{
	# 11. bar_rule : BAR rule

	if (_rdpg_tok_match(BAR()))
	{
		if (_rdpg_rule())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", BAR())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_bar_rule_star()
{
	# 12. bar_rule_star : bar_rule bar_rule_star
	# 13. bar_rule_star : 0

	while (1)
	{
		if (_rdpg_tok_is(BAR()))
		{
			if (_rdpg_bar_rule())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(SEMI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "bar_rule_star")
		}
		return _rdpg_sync(_RDPG_sym_set_14)
	}
}
function _rdpg_sym()
{
	# 14. sym : grmr_sym esc_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_grmr_sym())
		{
			if (_rdpg_esc_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "sym")
	}
	return _rdpg_sync(_RDPG_sym_set_5)
}
function _rdpg_sym_plus()
{
	# 15. sym_plus : sym sym_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_sym())
		{
			if (_rdpg_sym_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "sym_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_sym_star()
{
	# 16. sym_star : sym sym_star
	# 17. sym_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_3))
		{
			if (_rdpg_sym())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_4))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "sym_star")
		}
		return _rdpg_sync(_RDPG_sym_set_4)
	}
}
function _rdpg_esc()
{
	# 18. esc : ESC NONT \on_esc

	if (_rdpg_tok_match(ESC()))
	{
		if (_rdpg_tok_is(NONT()))
		{
			on_esc()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NONT())
		}
	}
	else
	{
		_rdpg_expect("tok", ESC())
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_esc_star()
{
	# 19. esc_star : esc esc_star
	# 20. esc_star : 0

	while (1)
	{
		if (_rdpg_tok_is(ESC()))
		{
			if (_rdpg_esc())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_5))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "esc_star")
		}
		return _rdpg_sync(_RDPG_sym_set_5)
	}
}
function _rdpg_grmr_sym()
{
	# 21. grmr_sym : TERM \on_term
	# 22. grmr_sym : NONT \on_nont nont_mod_opt

	if (_rdpg_tok_is(TERM()))
	{
		on_term()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(NONT()))
	{
		on_nont()
		_rdpg_tok_next()
		if (_rdpg_nont_mod_opt())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "grmr_sym")
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_nont_mod()
{
	# 23. nont_mod : QMARK \on_qmark
	# 24. nont_mod : STAR \on_star
	# 25. nont_mod : PLUS \on_plus

	if (_rdpg_tok_is(QMARK()))
	{
		on_qmark()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(STAR()))
	{
		on_star()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(PLUS()))
	{
		on_plus()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "nont_mod")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_nont_mod_opt()
{
	# 26. nont_mod_opt : nont_mod
	# 27. nont_mod_opt : 0

	if (_rdpg_predict(_RDPG_sym_set_6))
	{
		if (_rdpg_nont_mod())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_7))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "nont_mod_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
# </rd>
# </parse>
# <dispatch>
function on_top_sym()    {_prs_do("on_top_sym")}
function on_eoi_term()   {_prs_do("on_eoi_term")}
function on_lhs_start()  {_prs_do("on_lhs_start")}
function on_rule_start() {_prs_do("on_rule_start")}
function on_esc()        {_prs_do("on_esc")}
function on_term()       {_prs_do("on_term")}
function on_nont()       {_prs_do("on_nont")}
function on_qmark()      {_prs_do("on_qmark")}
function on_star()       {_prs_do("on_star")}
function on_plus()       {_prs_do("on_plus")}

function _prs_do(what) {
	if (parsing_error_happened())     return
	else if ("on_top_sym"    == what) _prs_on_start(lex_get_saved())
	else if ("on_eoi_term"   == what) _prs_start_set_eoi_term(lex_get_saved())
	else if ("on_lhs_start"  == what) _prs_on_lhs(lex_get_saved())
	else if ("on_rule_start" == what) _prs_on_rule()
	else if ("on_esc"        == what) _prs_on_esc(lex_get_saved())
	else if ("on_term"       == what) _prs_on_sym(TERM(), lex_get_saved())
	else if ("on_nont"       == what) _prs_on_sym(NONT(), lex_get_saved())
	else if ("on_qmark"      == what) _prs_on_mod(QMARK())
	else if ("on_star"       == what) _prs_on_mod(STAR())
	else if ("on_plus"       == what) _prs_on_mod(PLUS())
	else error_quit(sprintf("parser: unknown actions '%s'", what))
}
# </dispatch>

# <process>
function _prs_esc_type_set(type) {_B_prs_esc_type = type}
function _prs_esc_type()         {return _B_prs_esc_type}
function _prs_mod_type_set(type) {_B_prs_mod_type = type}
function _prs_mod_type()         {return _B_prs_mod_type}
# <ast-wrapper>
function _prs_set_start(ent) {ast_root_set(ent)}
function _prs_get_start() {return ast_root()}

function _prs_set_top_lhs(ent) {ast_start_push_lhs(_prs_get_start(), ent)}
function _prs_get_top_lhs() {return ast_start_last_lhs(_prs_get_start())}

function _prs_set_top_rule(ent) {ast_lhs_push_rule(_prs_get_top_lhs(), ent)}
function _prs_get_top_rule() {return ast_lhs_last_rule(_prs_get_top_lhs())}

function _prs_set_top_sym(ent) {ast_rule_push_sym(_prs_get_top_rule(), ent)}
function _prs_get_top_sym() {return ast_rule_last_sym(_prs_get_top_rule())}

function _prs_set_rule_top_esc(ent) {
	ast_rule_push_esc(_prs_get_top_rule(), ent)
}
function _prs_get_rule_top_esc() {return ast_rule_last_esc(_prs_get_top_rule())}

function _prs_set_sym_top_esc(ent) {ast_sym_push_esc(_prs_get_top_sym(), ent)}
function _prs_get_sym_top_esc() {return ast_sym_last_esc(_prs_get_top_sym())}

function _prs_on_start(nont) {
	_prs_set_start(ast_start_create(nont))
	_prs_mod_type_set(AST_START())
}
function _prs_start_set_eoi_term(term) {
	ast_start_set_eoi_term(_prs_get_start(), term)
}
function _prs_on_lhs(name) {
	_prs_set_top_lhs(ast_lhs_create(name))
}
function _prs_on_rule() {
	_prs_set_top_rule(ast_rule_create())
	_prs_esc_type_set(AST_RULE())
}
function _prs_on_sym(type, name) {
	_prs_set_top_sym(ast_sym_create(type, name))
	_prs_esc_type_set(AST_SYM())
	_prs_mod_type_set(AST_SYM())
}
function _prs_on_esc(name,    _esc, _type) {
	_esc = ast_esc_create(name)
	_type = _prs_esc_type()
	if (AST_RULE() == _type)
		_prs_set_rule_top_esc(_esc)
	else if (AST_SYM() == _type)
		_prs_set_sym_top_esc(_esc)
}
function _prs_on_mod(mod,    _type) {
	_type = _prs_mod_type()
	if (AST_START() == _type)
		ast_start_set_mod(_prs_get_start(), mod)
	else if (AST_SYM() == _type)
		ast_sym_set_mod(_prs_get_top_sym(), mod)
}
# </ast-wrapper>
# </process>
# </prs>
# <ast>
# <structs-ast>
# structs:
#
# prefix ast
#
# type start
# has  top_nont 
# has  mod 
# has  eoi_term 
# has  line_num 
# has  lhs_lst lhs_lst
#
# type lhs_lst
# has  head lhs
# has  tail lhs
#
# type lhs
# has  name 
# has  line_num 
# has  rule_lst rule_lst
# has  next_ lhs
#
# type rule_lst
# has  head rule
# has  tail rule
#
# type rule
# has  esc_lst esc_lst
# has  sym_lst sym_lst
# has  next_ rule
#
# type sym_lst
# has  head sym
# has  tail sym
#
# type sym
# has  type 
# has  name 
# has  mod 
# has  esc_lst esc_lst
# has  next_ sym
#
# type esc_lst
# has  head esc
# has  tail esc
#
# type esc
# has  name 
# has  next_ esc
#
# <private>
function _ast_set(k, v) {_STRUCTS_ast_db[k] = v}
function _ast_get(k) {return _STRUCTS_ast_db[k]}
function _ast_type_chk(ent, texp) {
	if (ast_type_of(ent) == texp)
		return
	ast_errq(sprintf("entity '%s' expected type '%s', actual type '%s'", \
		 ent, texp, ast_type_of(ent)))
}
# <\private>

function ast_clear() {
	delete _STRUCTS_ast_db
	_ent_set("gen", _ent_get("gen")+1)
}
function ast_is(ent) {return (ent in _STRUCTS_ast_db)}
function ast_type_of(ent) {
	if (ent in _STRUCTS_ast_db)
		return _STRUCTS_ast_db[ent]
	ast_errq(sprintf("'%s' not an entity", ent))
}
function ast_new(type,    _ent) {
	_ast_set("ents", (_ent = _ast_get("ents")+1))
	_ent = ("_ast-" _ast_get("gen")+0 "-" _ent)
	_ast_set(_ent, type)
	return _ent
}
# <types>
# <type-start>
function AST_START() {return "start"}

function ast_start_make(top_nont, mod, eoi_term, line_num, lhs_lst,     _ent) {
	_ent = ast_new("start")
	ast_start_set_top_nont(_ent, top_nont)
	ast_start_set_mod(_ent, mod)
	ast_start_set_eoi_term(_ent, eoi_term)
	ast_start_set_line_num(_ent, line_num)
	ast_start_set_lhs_lst(_ent, lhs_lst)
	return _ent
}

function ast_start_set_top_nont(ent, top_nont) {
	_ast_type_chk(ent, "start")
	_ast_set(("top_nont=" ent), top_nont)
}
function ast_start_get_top_nont(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("top_nont=" ent))
}

function ast_start_set_mod(ent, mod) {
	_ast_type_chk(ent, "start")
	_ast_set(("mod=" ent), mod)
}
function ast_start_get_mod(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("mod=" ent))
}

function ast_start_set_eoi_term(ent, eoi_term) {
	_ast_type_chk(ent, "start")
	_ast_set(("eoi_term=" ent), eoi_term)
}
function ast_start_get_eoi_term(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("eoi_term=" ent))
}

function ast_start_set_line_num(ent, line_num) {
	_ast_type_chk(ent, "start")
	_ast_set(("line_num=" ent), line_num)
}
function ast_start_get_line_num(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("line_num=" ent))
}

function ast_start_set_lhs_lst(ent, lhs_lst) {
	_ast_type_chk(ent, "start")
	if (lhs_lst)
		_ast_type_chk(lhs_lst, "lhs_lst")
	_ast_set(("lhs_lst=" ent), lhs_lst)
}
function ast_start_get_lhs_lst(ent) {
	_ast_type_chk(ent, "start")
	return _ast_get(("lhs_lst=" ent))
}

# <\type-start>
# <type-lhs_lst>
function AST_LHS_LST() {return "lhs_lst"}

function ast_lhs_lst_make(head, tail,     _ent) {
	_ent = ast_new("lhs_lst")
	ast_lhs_lst_set_head(_ent, head)
	ast_lhs_lst_set_tail(_ent, tail)
	return _ent
}

function ast_lhs_lst_set_head(ent, head) {
	_ast_type_chk(ent, "lhs_lst")
	if (head)
		_ast_type_chk(head, "lhs")
	_ast_set(("head=" ent), head)
}
function ast_lhs_lst_get_head(ent) {
	_ast_type_chk(ent, "lhs_lst")
	return _ast_get(("head=" ent))
}

function ast_lhs_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "lhs_lst")
	if (tail)
		_ast_type_chk(tail, "lhs")
	_ast_set(("tail=" ent), tail)
}
function ast_lhs_lst_get_tail(ent) {
	_ast_type_chk(ent, "lhs_lst")
	return _ast_get(("tail=" ent))
}

# <\type-lhs_lst>
# <type-lhs>
function AST_LHS() {return "lhs"}

function ast_lhs_make(name, line_num, rule_lst, next_,     _ent) {
	_ent = ast_new("lhs")
	ast_lhs_set_name(_ent, name)
	ast_lhs_set_line_num(_ent, line_num)
	ast_lhs_set_rule_lst(_ent, rule_lst)
	ast_lhs_set_next_(_ent, next_)
	return _ent
}

function ast_lhs_set_name(ent, name) {
	_ast_type_chk(ent, "lhs")
	_ast_set(("name=" ent), name)
}
function ast_lhs_get_name(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("name=" ent))
}

function ast_lhs_set_line_num(ent, line_num) {
	_ast_type_chk(ent, "lhs")
	_ast_set(("line_num=" ent), line_num)
}
function ast_lhs_get_line_num(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("line_num=" ent))
}

function ast_lhs_set_rule_lst(ent, rule_lst) {
	_ast_type_chk(ent, "lhs")
	if (rule_lst)
		_ast_type_chk(rule_lst, "rule_lst")
	_ast_set(("rule_lst=" ent), rule_lst)
}
function ast_lhs_get_rule_lst(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("rule_lst=" ent))
}

function ast_lhs_set_next_(ent, next_) {
	_ast_type_chk(ent, "lhs")
	if (next_)
		_ast_type_chk(next_, "lhs")
	_ast_set(("next_=" ent), next_)
}
function ast_lhs_get_next_(ent) {
	_ast_type_chk(ent, "lhs")
	return _ast_get(("next_=" ent))
}

# <\type-lhs>
# <type-rule_lst>
function AST_RULE_LST() {return "rule_lst"}

function ast_rule_lst_make(head, tail,     _ent) {
	_ent = ast_new("rule_lst")
	ast_rule_lst_set_head(_ent, head)
	ast_rule_lst_set_tail(_ent, tail)
	return _ent
}

function ast_rule_lst_set_head(ent, head) {
	_ast_type_chk(ent, "rule_lst")
	if (head)
		_ast_type_chk(head, "rule")
	_ast_set(("head=" ent), head)
}
function ast_rule_lst_get_head(ent) {
	_ast_type_chk(ent, "rule_lst")
	return _ast_get(("head=" ent))
}

function ast_rule_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "rule_lst")
	if (tail)
		_ast_type_chk(tail, "rule")
	_ast_set(("tail=" ent), tail)
}
function ast_rule_lst_get_tail(ent) {
	_ast_type_chk(ent, "rule_lst")
	return _ast_get(("tail=" ent))
}

# <\type-rule_lst>
# <type-rule>
function AST_RULE() {return "rule"}

function ast_rule_make(esc_lst, sym_lst, next_,     _ent) {
	_ent = ast_new("rule")
	ast_rule_set_esc_lst(_ent, esc_lst)
	ast_rule_set_sym_lst(_ent, sym_lst)
	ast_rule_set_next_(_ent, next_)
	return _ent
}

function ast_rule_set_esc_lst(ent, esc_lst) {
	_ast_type_chk(ent, "rule")
	if (esc_lst)
		_ast_type_chk(esc_lst, "esc_lst")
	_ast_set(("esc_lst=" ent), esc_lst)
}
function ast_rule_get_esc_lst(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("esc_lst=" ent))
}

function ast_rule_set_sym_lst(ent, sym_lst) {
	_ast_type_chk(ent, "rule")
	if (sym_lst)
		_ast_type_chk(sym_lst, "sym_lst")
	_ast_set(("sym_lst=" ent), sym_lst)
}
function ast_rule_get_sym_lst(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("sym_lst=" ent))
}

function ast_rule_set_next_(ent, next_) {
	_ast_type_chk(ent, "rule")
	if (next_)
		_ast_type_chk(next_, "rule")
	_ast_set(("next_=" ent), next_)
}
function ast_rule_get_next_(ent) {
	_ast_type_chk(ent, "rule")
	return _ast_get(("next_=" ent))
}

# <\type-rule>
# <type-sym_lst>
function AST_SYM_LST() {return "sym_lst"}

function ast_sym_lst_make(head, tail,     _ent) {
	_ent = ast_new("sym_lst")
	ast_sym_lst_set_head(_ent, head)
	ast_sym_lst_set_tail(_ent, tail)
	return _ent
}

function ast_sym_lst_set_head(ent, head) {
	_ast_type_chk(ent, "sym_lst")
	if (head)
		_ast_type_chk(head, "sym")
	_ast_set(("head=" ent), head)
}
function ast_sym_lst_get_head(ent) {
	_ast_type_chk(ent, "sym_lst")
	return _ast_get(("head=" ent))
}

function ast_sym_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "sym_lst")
	if (tail)
		_ast_type_chk(tail, "sym")
	_ast_set(("tail=" ent), tail)
}
function ast_sym_lst_get_tail(ent) {
	_ast_type_chk(ent, "sym_lst")
	return _ast_get(("tail=" ent))
}

# <\type-sym_lst>
# <type-sym>
function AST_SYM() {return "sym"}

function ast_sym_make(type, name, mod, esc_lst, next_,     _ent) {
	_ent = ast_new("sym")
	ast_sym_set_type(_ent, type)
	ast_sym_set_name(_ent, name)
	ast_sym_set_mod(_ent, mod)
	ast_sym_set_esc_lst(_ent, esc_lst)
	ast_sym_set_next_(_ent, next_)
	return _ent
}

function ast_sym_set_type(ent, type) {
	_ast_type_chk(ent, "sym")
	_ast_set(("type=" ent), type)
}
function ast_sym_get_type(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("type=" ent))
}

function ast_sym_set_name(ent, name) {
	_ast_type_chk(ent, "sym")
	_ast_set(("name=" ent), name)
}
function ast_sym_get_name(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("name=" ent))
}

function ast_sym_set_mod(ent, mod) {
	_ast_type_chk(ent, "sym")
	_ast_set(("mod=" ent), mod)
}
function ast_sym_get_mod(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("mod=" ent))
}

function ast_sym_set_esc_lst(ent, esc_lst) {
	_ast_type_chk(ent, "sym")
	if (esc_lst)
		_ast_type_chk(esc_lst, "esc_lst")
	_ast_set(("esc_lst=" ent), esc_lst)
}
function ast_sym_get_esc_lst(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("esc_lst=" ent))
}

function ast_sym_set_next_(ent, next_) {
	_ast_type_chk(ent, "sym")
	if (next_)
		_ast_type_chk(next_, "sym")
	_ast_set(("next_=" ent), next_)
}
function ast_sym_get_next_(ent) {
	_ast_type_chk(ent, "sym")
	return _ast_get(("next_=" ent))
}

# <\type-sym>
# <type-esc_lst>
function AST_ESC_LST() {return "esc_lst"}

function ast_esc_lst_make(head, tail,     _ent) {
	_ent = ast_new("esc_lst")
	ast_esc_lst_set_head(_ent, head)
	ast_esc_lst_set_tail(_ent, tail)
	return _ent
}

function ast_esc_lst_set_head(ent, head) {
	_ast_type_chk(ent, "esc_lst")
	if (head)
		_ast_type_chk(head, "esc")
	_ast_set(("head=" ent), head)
}
function ast_esc_lst_get_head(ent) {
	_ast_type_chk(ent, "esc_lst")
	return _ast_get(("head=" ent))
}

function ast_esc_lst_set_tail(ent, tail) {
	_ast_type_chk(ent, "esc_lst")
	if (tail)
		_ast_type_chk(tail, "esc")
	_ast_set(("tail=" ent), tail)
}
function ast_esc_lst_get_tail(ent) {
	_ast_type_chk(ent, "esc_lst")
	return _ast_get(("tail=" ent))
}

# <\type-esc_lst>
# <type-esc>
function AST_ESC() {return "esc"}

function ast_esc_make(name, next_,     _ent) {
	_ent = ast_new("esc")
	ast_esc_set_name(_ent, name)
	ast_esc_set_next_(_ent, next_)
	return _ent
}

function ast_esc_set_name(ent, name) {
	_ast_type_chk(ent, "esc")
	_ast_set(("name=" ent), name)
}
function ast_esc_get_name(ent) {
	_ast_type_chk(ent, "esc")
	return _ast_get(("name=" ent))
}

function ast_esc_set_next_(ent, next_) {
	_ast_type_chk(ent, "esc")
	if (next_)
		_ast_type_chk(next_, "esc")
	_ast_set(("next_=" ent), next_)
}
function ast_esc_get_next_(ent) {
	_ast_type_chk(ent, "esc")
	return _ast_get(("next_=" ent))
}

# <\type-esc>
# <\types>
# <\structs-ast>
# <error>
function ast_errq(msg) {error_quit(sprintf("ast: %s", msg))}
# </error>

# <tree>
function ast_root_set(root) {_B_ast_root = root}
function ast_root() {return _B_ast_root}

function ast_start_create(nont) {
	return ast_start_make(nont, "", "", lex_get_line_no(), ast_lhs_lst_make())
}
function ast_start_push_lhs(start, lhs,    _lst) {
	_lst = ast_start_get_lhs_lst(start)
	if (!ast_lhs_lst_get_head(_lst)) {
		ast_lhs_lst_set_head(_lst, lhs)
		ast_lhs_lst_set_tail(_lst, lhs)
	} else {
		ast_lhs_set_next_(ast_lhs_lst_get_tail(_lst), lhs)
		ast_lhs_lst_set_tail(_lst, lhs)
	}
}
function ast_start_first_lhs(start) {
	return ast_lhs_lst_get_head(ast_start_get_lhs_lst(start))
}
function ast_start_last_lhs(start) {
	return ast_lhs_lst_get_tail(ast_start_get_lhs_lst(start))
}

function ast_lhs_create(name, line_num) {
	if (!line_num)
		line_num = lex_get_line_no()
	return ast_lhs_make(name, line_num, ast_rule_lst_make())
}
function ast_lhs_push_rule(lhs, rule,    _lst) {
	_lst = ast_lhs_get_rule_lst(lhs)
	if (!ast_rule_lst_get_head(_lst)) {
		ast_rule_lst_set_head(_lst, rule)
		ast_rule_lst_set_tail(_lst, rule)
	} else {
		ast_rule_set_next_(ast_rule_lst_get_tail(_lst), rule)
		ast_rule_lst_set_tail(_lst, rule)
	}
}
function ast_lhs_first_rule(lhs) {
	return ast_rule_lst_get_head(ast_lhs_get_rule_lst(lhs))
}
function ast_lhs_last_rule(lhs) {
	return ast_rule_lst_get_tail(ast_lhs_get_rule_lst(lhs))
}

function ast_rule_create() {
	return ast_rule_make(ast_esc_lst_make(), ast_sym_lst_make())
}
function ast_rule_push_sym(rule, sym,    _lst) {
	_lst = ast_rule_get_sym_lst(rule)
	if (!ast_sym_lst_get_head(_lst)) {
		ast_sym_lst_set_head(_lst, sym)
		ast_sym_lst_set_tail(_lst, sym)
	} else {
		ast_sym_set_next_(ast_sym_lst_get_tail(_lst), sym)
		ast_sym_lst_set_tail(_lst, sym)
	}
}
function ast_rule_first_sym(rule) {
	return ast_sym_lst_get_head(ast_rule_get_sym_lst(rule))
}
function ast_rule_last_sym(rule) {
	return ast_sym_lst_get_tail(ast_rule_get_sym_lst(rule))
}
function ast_rule_push_esc(rule, esc,    _lst) {
	_lst = ast_rule_get_esc_lst(rule)
	if (!ast_esc_lst_get_head(_lst)) {
		ast_esc_lst_set_head(_lst, esc)
		ast_esc_lst_set_tail(_lst, esc)
	} else {
		ast_esc_set_next_(ast_esc_lst_get_tail(_lst), esc)
		ast_esc_lst_set_tail(_lst, esc)
	}
}
function ast_rule_first_esc(rule) {
	return ast_esc_lst_get_head(ast_rule_get_esc_lst(rule))
}
function ast_rule_last_esc(rule) {
	return ast_esc_lst_get_tail(ast_rule_get_esc_lst(rule))
}

function ast_sym_create(type, name) {
	return ast_sym_make(type, name, "", ast_esc_lst_make())
}
function ast_sym_push_esc(sym, esc,    _lst) {
	_lst = ast_sym_get_esc_lst(sym)
	if (!ast_esc_lst_get_head(_lst)) {
		ast_esc_lst_set_head(_lst, esc)
		ast_esc_lst_set_tail(_lst, esc)
	} else {
		ast_esc_set_next_(ast_esc_lst_get_tail(_lst), esc)
		ast_esc_lst_set_tail(_lst, esc)
	}
}
function ast_sym_first_esc(sym) {
	return ast_esc_lst_get_head(ast_sym_get_esc_lst(sym))
}
function ast_sym_last_esc(sym) {
	return ast_esc_lst_get_tail(ast_sym_get_esc_lst(sym))
}

function ast_esc_create(name) {return ast_esc_make(name)}
# </tree>

# <modifiers>
function ast_mod_mark(name, mod,    _curr) {
	if (!index((_curr = _B_ast_mod_db[name]), mod)) {
		_B_ast_mod_db[name] = (_curr mod)
		if (PLUS() == mod)
			ast_mod_mark(name, STAR())
	}
}
function ast_mod_has(name, mod) {
	return ((name in _B_ast_mod_db) && index(_B_ast_mod_db[name], mod))
}

function _ast_mod_rename(name, mod) {
	if (QMARK() == mod)
		mod = "_opt"
	else if (STAR() == mod)
		mod = "_star"
	else if (PLUS() == mod)
		mod = "_plus"
	return (name mod)
}
function _ast_mod_discover(ent,    _type, _name, _mod, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_name = ast_start_get_top_nont(ent)
		if (_mod = ast_start_get_mod(ent)) {
			ast_mod_mark(_name, _mod)
			_name = _ast_mod_rename(_name, _mod)
			ast_start_set_top_nont(ent, _name)
			ast_start_set_mod(ent, "")
		}
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		_ast_mod_discover(ast_lhs_first_rule(ent))
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_mod_discover(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
	} else if (AST_SYM() == _type) {
		_name = ast_sym_get_name(ent)
		if (_mod = ast_sym_get_mod(ent)) {
			ast_mod_mark(_name, _mod)
			_name = _ast_mod_rename(_name, _mod)
			ast_sym_set_name(ent, _name)
			ast_sym_set_mod(ent, "")
		}
		_next = ast_sym_get_next_(ent)
	}

	_ast_mod_discover(_next)
}

# <rewrite>
function ZERO() {return "0"}
function NO_LINE() {return "-"}
function _ast_lhs_create_nl(name) {return ast_lhs_create(name, NO_LINE())}

function _ast_mod_defn_star(lhs,    _name, _mod_name, _rule, _ropt, _next) {
	# foo* becomes
	# foo_star : foo foo_star | 0

	_name = ast_lhs_get_name(lhs)
	_mod_name = _ast_mod_rename(_name, STAR())

	_ropt = ast_rule_create()
	ast_rule_push_sym(_ropt, ast_sym_create(ZERO(), ZERO()))

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _mod_name))

	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)
	ast_lhs_push_rule(_next, _ropt)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn_plus(lhs,    _name, _mod_name, _next, _rule) {
	# foo+ becomes
	# foo_plus : foo foo_star

	_name = ast_lhs_get_name(lhs)

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))
	_mod_name = _ast_mod_rename(_name, STAR())
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _mod_name))

	_mod_name = _ast_mod_rename(_name, PLUS())
	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn_opt(lhs,    _name, _mod_name, _next, _rule, _ropt) {
	# foo? becomes
	# foo_opt : foo | 0

	_name = ast_lhs_get_name(lhs)
	_mod_name = _ast_mod_rename(_name, QMARK())

	_rule = ast_rule_create()
	ast_rule_push_sym(_rule, ast_sym_create(NONT(), _name))

	_ropt = ast_rule_create()
	ast_rule_push_sym(_ropt, ast_sym_create(ZERO(), ZERO()))

	_next = _ast_lhs_create_nl(_mod_name)
	ast_lhs_push_rule(_next, _rule)
	ast_lhs_push_rule(_next, _ropt)

	ast_lhs_set_next_(_next, ast_lhs_get_next_(lhs))
	ast_lhs_set_next_(lhs, _next)
}
function _ast_mod_defn(lhs,    _name) {
	_name = ast_lhs_get_name(lhs)
	if (ast_mod_has(_name, STAR()))
		_ast_mod_defn_star(lhs)
	if (ast_mod_has(_name, PLUS()))
		_ast_mod_defn_plus(lhs)
	if (ast_mod_has(_name, QMARK()))
		_ast_mod_defn_opt(lhs)
}
function _ast_mod_resolve(ent,    _type, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		_ast_mod_defn(ent)
		_next = ast_lhs_get_next_(ent)
	}

	_ast_mod_resolve(_next)
}
function ast_mod_rewrite(    _root) {
	_root = ast_root()
	_ast_mod_discover(_root)
	_ast_mod_resolve(_root)
}
# </rewrite>
# </modifiers>

# <to-sym-tbl>
function _ast_tst_add_lhs(lhs) {st_lhs_add(lhs)}
function _ast_tst_add_sym_term(term) {
	st_name_term_add(term)
	st_rule_pos_add(term)
}
function _ast_tst_add_sym_nont(nont) {
	st_name_nont_add(nont)
	st_rule_pos_add(nont)
}

function _ast_tst_place_rule(arr_names, arr_types, len,    _i, _rs, _nm, _tp) {
	for (_i = 1; _i <= len; ++_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (ESC() == _tp)
			_nm = ("\\" _nm)

		_rs = (_rs _nm)
		if (_i < len)
			_rs = (_rs " ")
	}

	st_lhs_rule_add(_rs)

	for (_i = 1; _i <= len; ++_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (TERM() == _tp) {
			st_name_term_add(_nm)
			st_rule_pos_add(_nm)
		} else if (NONT() == _tp) {
			st_name_nont_add(_nm)
			st_rule_pos_add(_nm)
		} else if (ZERO() == _tp) {
			st_name_mark_can_null(st_lhs_last())
			st_name_mark_can_null(st_rule_name_last())
			st_rule_pos_add(ZERO())
		} else if (ESC() == _tp) {
			st_rule_pos_esc_add(_nm)
		}
	}

	for (_i = len; _i > 0; --_i) {
		_nm = arr_names[_i]
		_tp = arr_types[_i]

		if (ESC() != _tp) {
			if (NONT() == _tp && st_lhs_last() == _nm) {
				st_name_mark_tail_rec(st_lhs_last())
				st_name_mark_tail_rec(st_rule_name_last())
			}

			break
		}
	}
}

function _ast_tst_add_rule(ent,    _arr_nm, _arr_tp, _len, _n) {
	_n = ast_rule_first_esc(ent)
	while (_n) {
		++_len
		_arr_nm[_len] = ast_esc_get_name(_n)
		_arr_tp[_len] = ESC()
		_n = ast_esc_get_next_(_n)
	}

	_n = ast_rule_first_sym(ent)
	_len = _ast_tst_get_rule_syms(_n, _arr_nm, _arr_tp, _len)
	_ast_tst_place_rule(_arr_nm, _arr_tp, _len)
}
function _ast_tst_get_rule_syms(ent, arr_out_names, arr_out_types, len,    _n) {
	if (!ent)
		return len

	++len
	arr_out_names[len] = ast_sym_get_name(ent)
	arr_out_types[len] = ast_sym_get_type(ent)

	_n = ast_sym_first_esc(ent)
	while (_n) {
		++len
		arr_out_names[len] = ast_esc_get_name(_n)
		arr_out_types[len] = ESC()
		_n = ast_esc_get_next_(_n)
	}

	_n = ast_sym_get_next_(ent)
	return _ast_tst_get_rule_syms(_n, arr_out_names, arr_out_types, len)
}

function _ast_tst_add_start(ent,    _term, _nont, _rstr) {
	_nont = ast_start_get_top_nont(ent)
	_term = ast_start_get_eoi_term(ent)
	_rstr = sprintf("%s %s", _nont, _term)

	st_lhs_add(START_SYM(), ast_start_get_line_num(ent))
	st_lhs_rule_add(_rstr)
	st_name_nont_add(_nont)
	st_rule_pos_add(_nont)
	st_name_term_add(_term)
	st_rule_pos_add(_term)
	st_eoi_set(_term)
}
function ast_to_sym_tbl() {_ast_to_sym_tbl(ast_root())}
function _ast_to_sym_tbl(ent,    _type, _next) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		_ast_tst_add_start(ent)
		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		st_lhs_add(ast_lhs_get_name(ent), ast_lhs_get_line_num(ent))
		_ast_to_sym_tbl(ast_lhs_first_rule(ent))
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_tst_add_rule(ent)
		_next = ast_rule_get_next_(ent)
	}

	_ast_to_sym_tbl(_next)
}
# </to-sym-tbl>

# <print>
# <dbg>
function ast_print_grammar() {_ast_print_grammar(ast_root())}
function _ast_print_grammar(ent,    _type, _next, _tmp) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		printf("start : %s", ast_start_get_top_nont(ent))

		if (_tmp = ast_start_get_mod(ent))
			printf("%s", _tmp)
		printf(" ")
		print ast_start_get_eoi_term(ent)
		print ""

		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		printf("%s : ", ast_lhs_get_name(ent))

		_ast_print_grammar(ast_lhs_first_rule(ent))
		print ""
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		_ast_print_grammar(ast_rule_first_esc(ent))
		_ast_print_grammar(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
		if (_next && AST_RULE() == ast_type_of(_next))
			printf("\n\t| ")
		else
			print ""
	} else if (AST_SYM() == _type) {
		if (_tmp = ast_sym_get_name(ent))
			printf("%s", _tmp)
		if (_tmp = ast_sym_get_mod(ent))
			printf("%s", _tmp)

		printf(" ")
		_ast_print_grammar(ast_sym_first_esc(ent))

		_next = ast_sym_get_next_(ent)
	} else if (AST_ESC() == _type) {
		if (_tmp = ast_esc_get_name(ent))
			printf("\\%s ", _tmp)

		_next = ast_esc_get_next_(ent)
	}

	_ast_print_grammar(_next)
}

# <dbg>
function ast_dbg_print(ent,    _type, _next, _tmp) {
	if (!ent)
		return

	_type = ast_type_of(ent)
	if (AST_START() == _type) {
		printf("start (line %s) : %s", ast_start_get_line_num(ent), \
			ast_start_get_top_nont(ent))

		if (_tmp = ast_start_get_mod(ent))
			printf("%s", _tmp)
		printf(" ")
		print ast_start_get_eoi_term(ent)
		print ""

		_next = ast_start_first_lhs(ent)
	} else if (AST_LHS() == _type) {
		printf("%s (line %s) : ", ast_lhs_get_name(ent), \
			ast_lhs_get_line_num(ent))

		ast_dbg_print(ast_lhs_first_rule(ent))
		print ""
		_next = ast_lhs_get_next_(ent)
	} else if (AST_RULE() == _type) {
		ast_dbg_print(ast_rule_first_esc(ent))
		ast_dbg_print(ast_rule_first_sym(ent))
		_next = ast_rule_get_next_(ent)
		if (_next && AST_RULE() == ast_type_of(_next))
			printf("\n\t| ")
		else
			print ""
	} else if (AST_SYM() == _type) {
		if (_tmp = ast_sym_get_name(ent))
			printf("%s", _tmp)
		if (_tmp = ast_sym_get_mod(ent))
			printf("%s", _tmp)

		printf(" ")
		ast_dbg_print(ast_sym_first_esc(ent))

		_next = ast_sym_get_next_(ent)
	} else if (AST_ESC() == _type) {
		if (_tmp = ast_esc_get_name(ent))
			printf("\\%s ", _tmp)

		_next = ast_esc_get_next_(ent)
	}

	ast_dbg_print(_next)
}
# </dbg>
# </print>
# </ast>
# <sym-tbl>
# <private>
function _st_has(n) {return map_has(_B_st_data, n)}
function _st_get(n) {return map_get(_B_st_data, n)}
function _st_set(n, v) {_B_st_data[n] = v}
# </private>

# <print>
function st_print_rules(    _i, _ei, _j, _ej, _nm) {
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		printf("rule %d %s %s : ", _i, st_rule_name(_i), st_rule_lhs(_i))
		_ej = st_rule_pos_count(_i)
		for (_j = 1; _j <= _ej; ++_j)
			printf("%s ", st_rule_pos_name(_i, _j))
		print ""
	}
}
# </print>

# <name>
function st_name_count() {return _st_name_set_len(_ST_SNAME())}
function st_name(n)      {return _st_name_set_at(_ST_SNAME(), n)}
function st_name_type(name) {return _st_get(sprintf("name.type=%s", name))}

function st_name_term_count() {return _st_name_set_len(_ST_STERM())}
function st_name_term(n)      {return _st_name_set_at(_ST_STERM(), n)}
function st_name_nont_count() {return _st_name_set_len(_ST_SNONT())}
function st_name_nont(n)      {return _st_name_set_at(_ST_SNONT(), n)}
function st_name_lhs_count()  {return _st_name_set_len(_ST_SLHS())}
function st_name_lhs(n)       {return _st_name_set_at(_ST_SLHS(), n)}
function st_name_rule_count() {return _st_name_set_len(_ST_SRULE())}
function st_name_rule(n)      {return _st_name_set_at(_ST_SRULE(), n)}

function st_name_can_null(name) {
	return _st_has(sprintf("name.null.set=%s", name))
}
function st_name_is_tail_rec(name) {
	return _st_has(sprintf("name.trec.set=%s", name))
}
function st_name_is_term(name) {return _st_name_set_has(_ST_STERM(), name)}
function st_name_is_nont(name) {return _st_name_set_has(_ST_SNONT(), name)}
function st_name_is_lhs(name)  {return _st_name_set_has(_ST_SLHS(), name)}
function st_name_is_rule(name) {return _st_name_set_has(_ST_SRULE(), name)}
function st_name_is_zero(name) {return ("0" == name)}

function st_name_term_add(name) {_st_name_add(name, _ST_TTERM())}
function st_name_nont_add(name) {_st_name_add(name, _ST_TNONT())}
function st_name_lhs_add(name)  {_st_name_add(name, _ST_TLHS())}
function st_name_rule_add(name) {_st_name_add(name, _ST_TRULE())}

function st_name_mark_can_null(name) {
	_st_set(sprintf("name.null.set=%s", name))
}
function st_name_mark_tail_rec(name) {
	_st_set(sprintf("name.trec.set=%s", name))
}

# <private>
function _ST_TTERM() {return "t"}
function _ST_TNONT() {return "n"}
function _ST_TLHS()  {return "nl"}
function _ST_TRULE() {return "nr"}

function _ST_STERM() {return "term"}
function _ST_SNONT() {return "nont"}
function _ST_SLHS()  {return "lhs"}
function _ST_SRULE() {return "rule"}
function _ST_SNAME() {return "name"}

function _st_name_add(name, type,    _chg) {
	_chg = 0
	_chg = keep(_st_name_name_add(name), _chg)
	if (index(type, "t")) _chg = keep(_st_name_term_add(name), _chg)
	if (index(type, "n")) _chg = keep(_st_name_nont_add(name), _chg)
	if (index(type, "l")) _chg = keep(_st_name_lhs_add(name), _chg)
	if (index(type, "r")) _chg = keep(_st_name_rule_add(name), _chg)
	if (_chg) _st_set(sprintf("name.type=%s", name), type)
}

function _st_name_name_add(name) {return _st_name_set_add(_ST_SNAME(), name)}
function _st_name_term_add(name) {return _st_name_set_add(_ST_STERM(), name)}
function _st_name_nont_add(name) {return _st_name_set_add(_ST_SNONT(), name)}
function _st_name_lhs_add(name)  {return _st_name_set_add(_ST_SLHS(), name)}
function _st_name_rule_add(name) {return _st_name_set_add(_ST_SRULE(), name)}

function _st_name_set_len(set_name) {
	return _st_get(sprintf("name.%s.set.len", set_name))+0
}
function _st_name_set_at(set_name, pos) {
	return _st_get(sprintf("name.%s.set.str=%d", set_name, pos))
}
function _st_name_set_has(set_name, name) {
	return _st_has(sprintf("name.%s.set.num=%s", set_name, name))
}
function _st_name_set_add(set_name, name) {
	if (_st_name_set_has(set_name, name))
		return 0

	_n = sprintf("name.%s.set.len", set_name)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("name.%s.set.str=%d", set_name, _c)
	_st_set(_n, name)
	_n = sprintf("name.%s.set.num=%s", set_name, name)
	_st_set(_n, _c)
	return 1
}
# </private>
# </name>

# <eoi>
function st_eoi_set(nm) {_st_set("eoi", nm)}
function st_eoi()       {return _st_get("eoi")}
# </eoi>

# <lsh>
function st_lhs_count() {return st_name_lhs_count()}
function st_lhs(n)      {return st_name_lhs(n)}
function st_lhs_is_tail_rec(lhs) {return st_name_is_tail_rec(lhs)}
function st_lhs_line_num(name)   {return _st_get(sprintf("lhs.lnum=%s", name))}
function st_lhs_rule_count(name) {return _st_get(sprintf("lhs.rules=%s", name))}
function st_lhs_rule_id(lhs, n) {
	return _st_get(sprintf("lhs.rule=%s.%d", lhs, n))
}

function st_lhs_add(name, lnum,    _n) {
	if (st_name_is_lhs(name))
		err_quit_fpos(sprintf("non-terminal '%s' redefined", name), lnum)
	st_name_lhs_add(name)
	_n = sprintf("lhs.lnum=%s", name)
	_st_set(_n, lnum)
}
function st_lhs_rule_add(rstr,    _c, _n, _lhs, _rname) {
	_lhs = st_lhs_last()
	_n = sprintf("lhs.rules=%s", _lhs)
	_st_set(_n, (_c = _st_get(_n)+1))
	_rname = sprintf("%s_%d", _lhs, _c)
	_st_rule_add(_lhs, _rname, rstr)
	_n = sprintf("lhs.rule=%s.%d", _lhs, _c)
	_st_set(_n, st_rule_count())
}
function st_lhs_last() {return st_lhs(st_lhs_count())}
# </lsh>

# <rule>
function st_rule_count() {return st_name_rule_count()}
function st_rule_name(n) {return st_name_rule(n)}
function st_rule_lhs(n) {return _st_get(sprintf("rule.lhs=%d", n))}
function st_rule_is_zero(n) {return st_name_is_zero(st_rule_pos_name(n, 1))}
function st_rule_str(n) {return _st_get(sprintf("rule.str=%d", n))}

function st_rule_pos_count(n) {return _st_get(sprintf("rule.pos.len=%d", n))}
function st_rule_pos_name(r, n) {
	return _st_get(sprintf("rule.pos.name=%d.%d", r, n))

}
function st_rule_pos_esc_count(r, n) {
	return _st_get(sprintf("rule.pos.esc.len=%d.%d", r, n))
}
function st_rule_pos_esc(r, p, n) {
	return _st_get(sprintf("rule.pos.esc=%d.%d.%d", r, p, n))
}

function st_rule_is_tail_rec(n) {return st_name_is_tail_rec(st_rule_name(n))}

function st_rule_pos_esc_add(esc,    _c, _n, _r, _p) {
	_r = st_rule_count()
	_p = _st_rule_pos_last()
	_n = sprintf("rule.pos.esc.len=%d.%d", _r, _p)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("rule.pos.esc=%d.%d.%d", _r, _p, _c)
	_st_set(_n, esc)
}

function st_rule_pos_add(name,    _c, _n, _r) {
	_r = st_rule_count()
	_n = sprintf("rule.pos.len=%d", _r)
	_st_set(_n, (_c = _st_get(_n)+1))
	_n = sprintf("rule.pos.name=%d.%d", _r, _c)
	_st_set(_n, name)
}

function st_rule_name_last() {return st_rule_name(st_rule_count())}

# <private>
function _st_rule_add(lhs, name, rstr,    _c, _n) {
	st_name_rule_add(name)
	_c = st_rule_count()
	_n = sprintf("rule.lhs=%d", _c)
	_st_set(_n, lhs)
	_n = sprintf("rule.str=%d", _c)
	_st_set(_n, rstr)
	_n = sprintf("rule.pos.len=%d", _c)
	_st_set(_n, -1)
	st_rule_pos_add(name)
}
function _st_rule_pos_last() {return st_rule_pos_count(st_rule_count())}
# </private>
# </rule>

# <dbg>
function st_dbg_print_esc(rid, n,    _i, _end) {
	_end = st_rule_pos_esc_count(rid, n)
	for (_i = 1; _i <= _end; ++_i)
		printf("\\%s ", st_rule_pos_esc(rid, n, _i))
}
function st_dbg_print_rule(rid,    _i, _end, _str) {
	printf("%s : ", st_rule_lhs(rid))
	_end = st_rule_pos_count(rid)
	for (_i = 0; _i <= _end; ++_i) {
		_str = st_rule_pos_name(rid, _i)

		if (0 == _i) {
			printf("(%s) ", _str)

			if (st_name_is_tail_rec(_str))
				printf("(tr) ")

			if (st_name_can_null(_str))
				printf("(0) ")
		} else {
			printf("%s ", _str)
		}

		st_dbg_print_esc(rid, _i)
	}
	print ""
}
function st_dbg_print_lhs(name,    _i, _end, _lhs) {
	_lhs = sprintf("%s (line %s)", name, st_lhs_line_num(name))

	if (st_name_can_null(name))
		_lhs = (_lhs " (0)")

	if (st_name_is_tail_rec(name))
		_lhs = (_lhs " (tr)")

	print sprintf("%s", _lhs)

	_end = st_lhs_rule_count(name)
	for (_i = 1; _i <= _end; ++_i)
		st_dbg_print_rule(st_lhs_rule_id(name, _i))
}
function st_dbg_print(    _i, _end) {
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		st_dbg_print_lhs(st_lhs(_i))
		print ""
	}
}
function st_dbg_dump(    _n) {
	for (_n in _B_st_data)
		print sprintf("st[\"%s\"] = %s", _n, _B_st_data[_n])
}
# </dbg>
# </sym-tbl>
# <misc>
function keep(a, b) {return a || b}
function map_has(map, n) {return (n in map)}
function map_get(map, n) {return map_has(map, n) ? map[n] : ""}
# </misc>
# </parser>
# <check>
function check_warn_esc_tail_rec() {return _check_esc_tail_rec()}
function check_warn_reachability(    _set_reach) {
	_check_reach(_set_reach, st_lhs(1))
	return _check_reach_report(_set_reach)
}

function check_err_undefined() {return _check_undef()}
function check_err_left_factor() {return _check_lfact()}
function check_err_left_recursion() {return _check_lrec_all()}
function check_err_conflicts(    _err) {
	_err = 0
	_err = keep(sets_first_first_conflicts(),  _err)
	_err = keep(sets_first_follow_conflicts(), _err)
	return _err
}

# <private>
# <errors>
# <left-factor>
function _check_lfact_defn_err(lhs, defns) {
	err_fpos(lhs, sprintf("rules start with same symbol\n%s", defns))
}
function _check_lfact(    _i, _end, _lhs, _first, _key, _defn, _map, _ret) {
	_ret = 0
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_rule_lhs(_i)
		_first = st_rule_pos_name(_i, 1)
		_defn = sprintf("%s : %s", _lhs, st_rule_str(_i))
		_key = (_lhs "," _first)
		if (_key in _map)
			_map[_key] = (_map[_key] "\n" _defn)
		else
			_map[_key] = _defn
	}
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_rule_lhs(_i)
		_first = st_rule_pos_name(_i, 1)
		_key = (_lhs "," _first)
		if (index(_map[_key], "\n")) {
			_lhs = substr(_key, 1, index(_key, ",")-1)
			_check_lfact_defn_err(_lhs, _map[_key])
			_map[_key] = ""
			_ret = 1
		}
	}
	return _ret
}
# </left-factor>
# <left-recursion>
function _check_lrec_err(rule, path) {
	path = _check_lrec_path_pretty(path)
	err_fpos(rule, sprintf("left recursion\n%s", path))
}
# <data>
function _check_lrec_path_start() {return str_list_init()}
function _check_lrec_path_has(path, what) {return str_list_find(path, what)}
function _check_lrec_path_add(path, what) {return str_list_add(path, what)}
function _check_lrec_path_pretty(path) {return str_list_pretty(path, " -> ")}
# </data>
function _check_lrec_first(lhs_top, first, path) {
	if (st_name_is_nont(first)) {
		if (lhs_top == first) {
			_check_lrec_err(lhs_top, _check_lrec_path_add(path, first))
			return 1
		}
		if (!_check_lrec_path_has(path, first))
			return _check_lrec_next(lhs_top, first, path)
	}
	return 0
}
function _check_lrec_next(lhs_top, lhs_next, path,    _i, _end, _first, _ret) {
	_ret = 0
	path = _check_lrec_path_add(path, lhs_next)
	_end = st_lhs_rule_count(lhs_next)
	for (_i = 1; _i <= _end; ++_i) {
		_first = st_rule_pos_name(st_lhs_rule_id(lhs_next, _i), 1)
		_ret = keep(_check_lrec_first(lhs_top, _first, path), _ret)
	}
	return _ret
}
function _check_lrec_rule(lhs) {
	return _check_lrec_next(lhs, lhs, _check_lrec_path_start())
}
function _check_lrec_all(    _i, _end, _err) {
	_err = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_err = keep(_check_lrec_rule(st_lhs(_i)), _err)
	return _err
}
# </left-recursion>
# <undefined-rules>
function _check_undef_err(lhs, undef, defn) {
	err_fpos(lhs, sprintf("'%s' is undefined\n%s : %s", undef, lhs, defn))
}
function _check_undef(    _i, _ei, _j, _ej, _nm, _ret) {
	_ret = 0
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_ej = st_rule_pos_count(_i)
		for (_j = 1; _j <= _ej; ++_j) {
			_nm = st_rule_pos_name(_i, _j)
			if (st_name_is_nont(_nm) && !st_name_is_lhs(_nm)) {
				_check_undef_err(st_rule_lhs(_i), _nm, st_rule_str(_i))
				_ret = 1
			}
		}
	}
	return _ret
}
# </undefined-rules>
# </errors>

# <warnings>
# <reachability>
function _check_reach_warn(lhs) {warn_fpos(lhs, "unreachable")}
function _check_reach(set_out, lhs,    _i, _ei, _j, _ej, _rid) {
	if (!st_name_is_nont(lhs) || (lhs in set_out))
		return

	set_out[lhs]

	_ei = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _ei; ++_i) {
		_rid = st_lhs_rule_id(lhs, _i)
		_ej = st_rule_pos_count(_rid)
		for (_j = 1; _j <= _ej; ++_j)
			_check_reach(set_out, st_rule_pos_name(_rid, _j))
	}
}
function _check_reach_report(set_reach,    _i, _end, _lhs, _ret) {
	_ret = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		if (!(_lhs in set_reach)) {
			_check_reach_warn(_lhs)
			_ret = 1
		}
	}
	return _ret
}
# </reachability>
# <esc-after-tail-rec>
function _check_esc_tail_rec_warn(lhs, rstr,    _msg) {
	rstr = sprintf("%s : %s", lhs, rstr)
	_msg = sprintf("escapes after tail recursion are unreachable\n%s", rstr)
	warn_fpos(lhs, _msg)
}

function _check_esc_tail_rec(    _i, _end, _has_esc, _ret) {
	_ret = 0
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		_has_esc = !!st_rule_pos_esc_count(_i, st_rule_pos_count(_i))
		if (st_rule_is_tail_rec(_i) && _has_esc) {
			_check_esc_tail_rec_warn(st_rule_lhs(_i), st_rule_str(_i))
			_ret = 1
		}
	}
	return _ret
}
# </esc-after-tail-rec>
# </warnings>
# </private>
# </check>
# <code-gen>
function cg_generate() {_cg_gen()}

# <private>
# <emit>
function _emit_block_open() {
	emit(IR_BLOCK_OPEN())
	tinc()
}
function _emit_block_close() {
	tdec()
	emit(IR_BLOCK_CLOSE())
}
function _emit_else_expect(sym) {
	emit(IR_ELSE())
	_emit_block_open()
	emit(_make_call(_make_expect(sym)))
	_emit_block_close()
}
function _emit_else_true() {
	emit(IR_ELSE())
	_emit_block_open()
	emit(_make_ret(IR_TRUE()))
	_emit_block_close()
}
# </emit>

# <make>
function _make_fn(nm) {return sprintf("%s %s", IR_FUNC(), nm)}
function _make_ret(v) {return sprintf("%s %s", IR_RETURN(), v)}
function _make_call(fn, args) {
	fn = sprintf("%s %s", IR_CALL(), fn)
	return args ? (fn " " args) : fn
}
function _make_cond(expr, c) {return sprintf("%s %s", c ? c : _cg_cond(), expr)}
function _make_predict(nm) {
	return sprintf("%s %s", _cg_pred_type(nm), _cg_pred_what(nm))
}
function _make_expect(nm,    _exp) {
	if (!(_exp = _cg_exp_set(nm)))
		_exp = nm
	return sprintf("%s %s", IR_EXPECT(), _exp)
}
function _make_alias(nm) {return sprintf("%s %s", IR_ALIAS(), nm)}
function _make_sync(nm) {return sprintf("%s %s", IR_SYNC(), nm)}
function _make_set(which, set) {return sprintf("%s %s", which, set)}
function _make_esc(nm) {return sprintf("%s %s", IR_ESC(), nm)}
function _make_comnt(str) {return sprintf("%s %s", IR_COMMENT(), str)}
function _make_and(a, b) {return sprintf("%s %s %s", a, IR_AND(), b)}
# </make>

# <pred>
function _cg_pred_place(rnm, type, what,    _n) {
	_n = sprintf("pred.type=%s", rnm)
	_B_cd_pred[_n] = type
	_n = sprintf("pred.what=%s", rnm)
	_B_cd_pred[_n] = what
}
function _cg_pred_type(rnm) {return _B_cd_pred[sprintf("pred.type=%s", rnm)]}
function _cg_pred_what(rnm) {return _B_cd_pred[sprintf("pred.what=%s", rnm)]}
# </pred>

# <expect>
function _cg_exp_place(nm, what) {_B_cd_exp[nm] = what}
function _cg_exp_set(nm)         {return (nm in _B_cd_exp) ? _B_cd_exp[nm] : ""}
# </expect>

# <alias>
function __cg_alias_gen_nm() {return sprintf("set_%d", ++_B_cg_alias_num)}
function __cg_alias_place(set,    _nm) {
	if (!(set in _B_cg_alias_name_by_set)) {
		_nm = __cg_alias_gen_nm()
		_B_cg_alias_name_by_set[set] = _nm
		_B_cg_alias_set_by_name[_nm] = set
		_B_cg_alias_name_by_num[_cg_alias_count()] = _nm
	}
}

function _cg_alias_count() {return _B_cg_alias_num}
function _cg_alias_name_by_set(set) {
	if (!(set in _B_cg_alias_name_by_set))
		error_quit(sprintf("no name for set '%s'", set))
	return _B_cg_alias_name_by_set[set]
}
function _cg_alias_set_by_name(nm) {
	if (!(nm in _B_cg_alias_set_by_name))
		error_quit(sprintf("no set for name '%s'", nm))
	return _B_cg_alias_set_by_name[nm]
}
function _cg_alias_name_by_num(n) {return _B_cg_alias_name_by_num[n]}

function _cg_alias_gen(    _i, _end, _nm, _set, _sz) {
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		if (_cg_lhs_is_no_imm_err(st_rule_lhs(_i)) && st_rule_is_zero(_i))
			continue
		_nm = st_rule_name(_i)
		_sz = sets_pred_size(_nm)
		if (_sz > 1) {
			_set = sets_pred_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}

	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = st_lhs(_i)
		if (_cg_lhs_is_no_imm_err(_nm))
			continue
		_sz = sets_exp_size(_nm)
		if (_sz > 1) {
			_set = sets_exp_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}

	_end = st_lhs_count()
	for (_i = 2; _i <= _end; ++_i) {
		_nm = st_lhs(_i)
		if (_cg_lhs_is_no_imm_err(_nm))
			continue
		_sz = sets_flw_size(_nm)
		if (_sz > 0) {
			_set = sets_flw_pretty(_nm)
			__cg_alias_place(_set, _sz)
		}
	}
}
# </alias>

# <gen>
function _cg_gen_sets_alias(    _i, _end, _nm) {
	_cg_alias_gen()
	_end = _cg_alias_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = _cg_alias_name_by_num(_i)
		emit(_make_set(_make_alias(_nm), _cg_alias_set_by_name(_nm)))
	}
}
function _cg_gen_sets_predict(    _i, _end, _rnm, _set, _sz) {
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i) {
		if (_cg_lhs_is_no_imm_err(st_rule_lhs(_i)) && st_rule_is_zero(_i))
			continue
		_rnm = st_rule_name(_i)
		_set = sets_pred_pretty(_rnm)
		_sz = sets_pred_size(_rnm)
		if (1 == _sz) {
			# Rules which can be predicted by only one token do not need their
			# predict set emitted because tok_is() is sufficient.
			_cg_pred_place(_rnm, IR_TOK_IS(), _set)
		} else if (_sz > 1) {
			_cg_pred_place(_rnm, IR_PREDICT(), _rnm)
			emit(_make_set(_make_predict(_rnm), _cg_alias_name_by_set(_set)))
		}
	}
}
function _cg_gen_sets_expect(    _i, _end, _lhs, _set, _sz) {
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		if (_cg_lhs_is_no_imm_err(_lhs))
			continue
		_sz = sets_exp_size(_lhs)
		_set = sets_exp_pretty(_lhs)
		if (1 == _sz) {
			_cg_exp_place(_lhs, _set)
		} else if (_sz > 1) {
			_cg_exp_place(_lhs, _lhs)
			emit(_make_set(_make_expect(_lhs), _cg_alias_name_by_set(_set)))
		}
	}
}
function _cg_gen_sets_follow(    _i, _end, _lhs, _set) {
	_end = st_lhs_count()
	for (_i = 2; _i <= _end; ++_i) {
		_lhs = st_lhs(_i)
		if (_cg_lhs_is_no_imm_err(_lhs))
			continue
		if (_set = sets_flw_pretty(_lhs))
			emit(_make_set(_make_sync(_lhs), _cg_alias_name_by_set(_set)))
	}
}
function _cg_gen_tokens(    _i, _end, _nm, _toks) {
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_nm = st_name(_i)
		if (st_name_is_term(_nm)) {
			_tok = (_tok _nm)
			if (_i < _end)
				_tok = (_tok " ")
		}
	}
	emit(sprintf("%s %s", IR_TOKENS(), _tok))
	emit(sprintf("%s %s", IR_TOK_EOI(), st_eoi()))
}
function _cg_gen_sets() {
	emit(IR_SETS())
	_emit_block_open()
	_cg_gen_sets_alias()
	_cg_gen_sets_predict()
	_cg_gen_sets_expect()
	_cg_gen_sets_follow()
	_emit_block_close()
}

function _cg_gen_esc(pos,    _i, _end) {
	_end = _cg_esc_count(pos)
	for (_i = 1; _i <= _end; ++_i)
		emit(_make_call(_make_esc(_cg_esc(pos, _i))))
}

function _cg_gen_rule_pos(n,    _sym, _is_term, _has_esc, _is_pred) {
	_sym = _cg_pos_name(n)
	_is_term = _cg_pos_is_term(n)
	_has_esc = _cg_pos_has_esc(n)
	_is_pred = (1 == n && 2 == _cg_depth())

	if (_is_term) {
		if (_is_pred) {
			emit(_make_comnt(sprintf("%s predicted", _sym)))
		} else {
			if (_has_esc)
				emit(_make_cond(_make_call(IR_TOK_IS(), _sym)))
			else
				emit(_make_cond(_make_call(IR_TOK_MATCH(), _sym)))
		}
	} else {
		emit(_make_cond(_make_call(_sym)))
	}

	if (!(_is_term && _is_pred))
		_emit_block_open()

	_cg_gen_esc(n)
	if (_is_term && (_is_pred || _has_esc))
		emit(_make_call(IR_TOK_NEXT()))

	if (_cg_pos_count() == n) {
		if (_cg_rule_is_trec())
			emit(IR_CONTINUE())
		else
			emit(_make_ret(IR_TRUE()))
	} else {
		_cg_gen_rule_pos(n+1)
	}

	if (!(_is_term && _is_pred))
		_emit_block_close()

	if (_is_term && (_cg_depth() - _is_pred) > 1)
		_emit_else_expect(_sym)
}

function _cg_gen_rule_predict() {
	emit(_make_cond(_make_call(_make_predict(_cg_rule_name()))))
}
function _cg_gen_rule_apply() {
	_cg_gen_esc(0)
	# The epsilon production.
	if (_cg_rule_is_zero())
		emit(_make_ret(IR_TRUE()))
	else
		_cg_gen_rule_pos(1)
}
function _cg_gen_lhs_rule(n,    _shd_predict) {
	_cg_rule_init(n)

	if (!_cg_rule_should_generate())
		return

	_shd_predict = _cg_rule_should_predict()

	if (_shd_predict) {
		_cg_gen_rule_predict()
		_emit_block_open()
	}

	_cg_gen_rule_apply()

	if (_shd_predict)
		_emit_block_close()
}
function _cg_gen_lhs(n,    _lhs, _i, _end, _is_tail_rec, _is_start, _tsync,
_is_no_imm_err) {
	_cg_lhs_init(n)
	_lhs = _cg_lhs()
	_is_tail_rec = _cg_lhs_is_trec()
	_is_start = _cg_lhs_is_first()
	_is_no_imm_err = _cg_lhs_is_no_imm_err()

	emit(_make_fn(_lhs))
	_emit_block_open()
	_cg_gen_grammar_lhs(_lhs)
	nl()

	if (_is_start)
		emit(_make_call(IR_TOK_NEXT()))

	if (_is_tail_rec) {
		emit(IR_LOOP())
		_emit_block_open()
	}

	_end = _cg_lhs_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_cg_gen_lhs_rule(_i)

	if (_is_no_imm_err)
		_emit_else_true()
	else
		_emit_else_expect(_lhs)

	_tsync = sync_type()
	if (_is_no_imm_err) {
		emit(_make_ret(IR_FALSE()))
	} else if (SYNC_DEFAULT() == _tsync) {
		# Nothing to sync on in the start lhs.
		if (_is_start)
			emit(_make_ret(IR_FALSE()))
		else
			emit(_make_ret(_make_call(_make_sync(_lhs))))
	} else if (_tsync == SYNC_NONE()) {
		emit(_make_ret(IR_FALSE()))
	} else if (SYNC_CUSTOM() == _tsync) {
		if (_is_start || !sync_has_nont(_lhs))
			emit(_make_ret(IR_FALSE()))
		else
			emit(_make_ret(_make_call(_make_sync(_lhs))))
	}

	_emit_block_close()

	if (_is_tail_rec)
		_emit_block_close()
}
function _cg_gen_start() {
	# Generate the official entry point of the parser.
	emit(_make_fn(IR_RDPG_PARSE()))
	_emit_block_open()
	emit(_make_and(_make_ret(_make_call(st_lhs(1))), IR_WAS_NO_ERR()))
	_emit_block_close()
}
function _cg_gen_parser(    _i, _end) {
	_cg_gen_start()
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_cg_gen_lhs(_i)
}
function _cg_gen_grammar_lhs(lhs,    _i, _ei, _j, _ej, _k, _ek, _rid, _ln) {
	# Print the grammar for a specific lhs as comments.
	_ei = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _ei; ++_i) {
		_rid = st_lhs_rule_id(lhs, _i)
		_ln = sprintf("%s. %s : ", _rid, lhs)
		_ej = st_rule_pos_count(_rid)
		for (_j = 0; _j <= _ej; ++_j) {
			if (_j)
				_ln = (_ln sprintf("%s ", st_rule_pos_name(_rid, _j)))
			_ek = st_rule_pos_esc_count(_rid, _j)
			for (_k = 1; _k <= _ek; ++_k)
				_ln = (_ln sprintf("\\%s ", st_rule_pos_esc(_rid, _j, _k)))
		}
		sub("[[:space:]]+$", "", _ln)
		emit(_make_comnt(_ln))
	}
}
function _cg_gen_grammar(    _i, _end) {
	# Print the whole grammar as comments.
	emit(_make_comnt("Grammar:"))
	emit(IR_COMMENT())
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i) {
		_cg_gen_grammar_lhs(st_lhs(_i))
		emit(IR_COMMENT())
	}
	nl()
}
function _cg_gen_header() {
	emit(_make_comnt(sprintf("generated by %s %s", \
		SCRIPT_NAME(), SCRIPT_VERSION())))
	emit(IR_COMMENT())
	emit(_make_comnt(sprintf("Immediate error detection: %d", !!opt_imm())))
	emit(IR_COMMENT())
}
function _cg_gen() {
	_cg_gen_header()
	_cg_gen_grammar()
	_cg_gen_tokens()
	_cg_gen_sets()
	_cg_gen_parser()
}
# </gen>

# <data>
# <lhs>
function _cg_lhs_init(n,    _lhs) {
	_lhs = st_lhs(n)
	_B_cg_lhs["name"] = _lhs
	_B_cg_lhs["is_first"] = (1 == n)
	_B_cg_lhs["is_trec"] = st_lhs_is_tail_rec(_lhs)
	_B_cg_lhs["rcount"] = st_lhs_rule_count(_lhs)
}
function _cg_lhs() {return _B_cg_lhs["name"]}
function _cg_lhs_is_first() {return _B_cg_lhs["is_first"]}
function _cg_lhs_is_trec() {return _B_cg_lhs["is_trec"]}
function _cg_lhs_rule_count() {return _B_cg_lhs["rcount"]}
function _cg_lhs_is_no_imm_err(lhs) {
	if (!lhs)
		lhs = _cg_lhs()
	return (!opt_imm() && st_name_can_null(lhs))
}
# </lhs>
# <rule>
function _cg_rule_init(lhs_num,    _lhs, _rid, _pred) {
	_lhs = _cg_lhs()
	_rid = st_lhs_rule_id(_lhs, lhs_num)
	_B_cg_rule["lhs"] = _lhs
	_B_cg_rule["id"] = _rid
	_B_cg_rule["name"] = st_rule_name(_rid)
	_B_cg_rule["is_first"] = (1 == lhs_num)
	_B_cg_rule["is_trec"] = st_rule_is_tail_rec(_rid)
	_cg_pos_init(_rid)
	_B_cg_rule["is_zero"] = st_name_is_zero(_cg_pos_name(1))
	_B_cg_rule["shd_pred"] = !_cg_pos_is_term(1) || _cg_pos_has_esc(0)
	_B_cg_rule["shd_gen"] = !(!opt_imm() && _cg_rule_is_zero())
}
function _cg_rule_id() {return _B_cg_rule["id"]}
function _cg_rule_name() {return _B_cg_rule["name"]}
function _cg_rule_lhs() {return _B_cg_rule["lhs"]}
function _cg_rule_is_first() {return _B_cg_rule["is_first"]}
function _cg_rule_is_trec() {return _B_cg_rule["is_trec"]}
function _cg_rule_is_zero() {return _B_cg_rule["is_zero"]}
function _cg_rule_should_predict() {return _B_cg_rule["shd_pred"]}
function _cg_rule_should_generate() {return _B_cg_rule["shd_gen"]}
# </rule>
# <pos>
function _cg_pos_init(rid,    _i, _end, _n, _pnm) {
	_end = st_rule_pos_count(rid) - _cg_rule_is_trec()
	_B_cg_pos["count"] = _end
	for (_i = 0; _i <= _end; ++_i) {
		_n = sprintf("pos=%d", _i)
		_pnm = st_rule_pos_name(rid, _i)
		_B_cg_pos[_n] = _pnm
		_n = sprintf("pos.has_esc=%d", _i)
		_B_cg_pos[_n] = !!st_rule_pos_esc_count(rid, _i)
		_n = sprintf("pos.is_term=%d", _i)
		_B_cg_pos[_n] = st_name_is_term(_pnm)
	}
	_cg_esc_init(rid)
}
function _cg_pos_count() {return _B_cg_pos["count"]}
function _cg_pos_name(n) {return _B_cg_pos[sprintf("pos=%d", n)]}
function _cg_pos_has_esc(n) {return _B_cg_pos[sprintf("pos.has_esc=%d", n)]}
function _cg_pos_is_term(n) {return _B_cg_pos[sprintf("pos.is_term=%d", n)]}
# </pos>
# <esc>
function _cg_esc_init(rid,    _i, _ei, _j, _ej, _n, _c) {
	_ei = _cg_pos_count()
	for (_i = 0; _i <= _ei; ++_i) {
		_ej = st_rule_pos_esc_count(rid, _i)
		_n = sprintf("esc.count=%d", _i)
		_B_cg_esc[_n] = _ej
		for (_j = 1; _j <= _ej; ++_j) {
			_n = sprintf("esc.name=%d.%d", _i, _j)
			_B_cg_esc[_n] = st_rule_pos_esc(rid, _i, _j)
		}
	}
}
function _cg_esc_count(p) {return _B_cg_esc[sprintf("esc.count=%d", p)]}
function _cg_esc(p, n) {return _B_cg_esc[sprintf("esc.name=%d.%d", p, n)]}
# </esc>
# <cond>
function _cg_depth() {return tnum() - _cg_lhs_is_trec()}
function _cg_cond() {
	return (_cg_depth() > 1 || _cg_rule_is_first()) ? IR_IF() : IR_ELSE_IF()
}
# </cond>
# </data>
# </private>
# </code-gen>
# <user_messages>
function use_str() {
	return sprintf("Use: %s [options] <grammar-file>", SCRIPT_NAME())
}

function print_use_try() {
	pstderr(use_str())
	pstderr(sprintf("Try '%s -vHelp=1' for more info", SCRIPT_NAME()))
}

function print_version() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
}

function print_example() {
print "#"
print "# The venerable infix calculator example. Includes the most important aspects of"
print "# rdpg grammar: left + right associativity, alternation, modifiers, and actions."
print "#"
print "# Non-terminals are lowercase, terminals are upper case. Both can begin with a"
print "# letter or _ and be followed by more letters _ and digits."
print "#"
print "# Actions are called 'escapes' because they have the form:"
print "# \\<fname>"
print "# <fname> has the same lexical rules as non-terminals and is a user defined"
print "# function the parser will call while parsing."
print "#"
print "# Modifiers apply to the previous non-terminal like so:"
print "# <nont>? - zero or one times <nont>"
print "# <nont>* - zero or more times <nont>"
print "# <nont>+ - one or more times <nont>"
print "#"
print "# A grammar file has to begin with:"
print "# start : <top-sym>[mod] <eoi-token>"
print "#"
print ""
print "start : expr+ EOI ;"
print ""
print "expr : \\on_expr_start expr_add_sub? SEMI \\on_expr_end ;"
print ""
print "expr_add_sub : expr_mul_div add_sub* ;"
print ""
print "add_sub : PLUS  expr_mul_div \\on_add"
print "        | MINUS expr_mul_div \\on_sub ;"
print ""
print "expr_mul_div : expr_expon mul_div* ;"
print ""
print "mul_div : MUL expr_expon \\on_mul"
print "        | DIV expr_expon \\on_div ;"
print ""
print "expr_expon : expr_base expon? ;"
print ""
print "expon : POW expr_expon \\on_pow ;"
print ""
print "expr_base : MINUS base \\on_neg"
print "          | base ;"
print ""
print "base : NUMBER \\on_number"
print "     | L_PAR expr_add_sub R_PAR ;"
}

function print_help() {
print sprintf("--- %s ---", SCRIPT_NAME())
print ""
print "LL(1) recursive descent parser generator"
print ""
print use_str()
print ""
print "Options:"
printf("-v %s=<n> - quit after <n> number of errors; <n> is positive", OPT_FATAL_ERR())
print ""
printf("-v %s=1    - treat warnings as errors", OPT_WARN_ERR())
print ""
printf("-v %s=1    - turn on all warnings", OPT_WARN_ALL())
print ""
printf("-v %s=1  - warn about unreachable non-terminals", OPT_WARN_REACH())
print ""
printf("-v %s=1    - warn about unreachable escapes", OPT_WARN_ESC())
print ""
printf("-v %s=1      - quit after all grammar checks; don't generate code", OPT_CHECK())
print ""
printf("-v %s=1    - print the expanded grammar and quit", OPT_GRAMMAR())
print ""
printf("-v %s=1      - print the list of rules and quit", OPT_RULES())
print ""
printf("-v %s=1       - print the grammar sets and quit", OPT_SETS())
print ""
printf("-v %s=1      - print the parse table and quit", OPT_TABLE())
print ""
print "-v Example=1    - print example"
print "-v Help=1       - print this screen"
print "-v Version=1    - print version"
print ""
printf("-v %s=<1|0> - turn on/off immediate error detection in epsilon productions.", OPT_IMM())
print ""
print "When off, less sets and predictions are generated, which makes certain hacks"
print "possible (e.g. inserting tokens into the input stream). Errors get detected next"
print "time the input is advanced rather than immediately when the wrong token is seen."
print "Where in the grammar an error is detected, therefore, becomes less precise."
print "On by default."
print ""
printf("-v %s=1 - default syncing. Same if no sync option is used. Every non-terminal\n", OPT_SYNC())
print "function syncs to the the first token found in the follow set of any of its"
print "rules and returns true. Returns false otherwise. Could lead to an error cascade."
print ""
printf("-v %s=0 - no syncing. All non-terminal functions return false. I.e. the parser\n", OPT_SYNC())
print "stops after a single error is encountered."
print ""
printf("-v %s=\"<nont>=<tok-csv>[;<nont>=<tok-csv>]\" - sync only non-terminals\n", OPT_SYNC())
print "<nont> on tokens in <tok-csv>. <nont> must exist and all tokens in <tok-csv>"
print "must be in its follow set. E.g. \"foo=TOK_A,TOK_B;bar=TOK_C;baz=EOI\" will sync"
print "non-terminal foo only on tokens TOK_A and TOK_B, bar on TOK_C, and baz on EOI."
}

# </user_messages>
# <parse-table>
function pt_print() {_pt_print()}

# <private>
function __pt_set(k, v) {_B_pt_data[k] = v}
function __pt_has(k)    {return map_has(_B_pt_data, k)}
function __pt_get(k)    {return map_get(_B_pt_data, k)}

function _pt_add(lhs, term, rule,    _k, _v) {
	_k = (lhs "," term)
	_v = (__pt_has(_k)) ? (__pt_get(_k) "," rule) : rule
	__pt_set(_k, _v)
}
function _pt_get(lhs, term)       {return __pt_get((lhs "," term))}
# </private>
function _pt_err(lhs, term, rstr,    _str) {
	# Given rdpg makes sure the grammar is LL(1) we should never end up here. If
	# it happens, there must be a bug in the some previous grammar check step.
	_str = sprintf("terminal '%s' in lhs '%s' can predict more than one rule", \
		term, lhs)
	_str = (_str sprintf(": %s", rstr))
	error_print(_str)
}

function _pt_init(    _i, _ei, _j, _ej, _lhs, _term, _rnm) {
	# Precondition: predict sets have been calculated.
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_rule_lhs(_i)
		_rnm = st_rule_name(_i)

		_ej = sets_pred_size(_rnm)
		for (_j = 1; _j <= _ej; ++_j) {
			_term = sets_pred_at(_rnm, _j)
			_pt_add(_lhs, _term, _rnm)
		}
	}
}

function _pt_check(    _i, _ei, _j, _ej, _lhs, _term, _rstr) {
	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		_ej = st_name_term_count()
		for (_j = 1; _j <= _ej; ++_j) {
			_term = st_name_term(_j)
			_rstr = _pt_get(_lhs, _term)
			if (index(_rstr, ","))
				_pt_err(_lhs, _term, _rstr)
		}
	}
}

function _PT_SEP() {return ";"}
function _pt_print(    _i, _ei, _j, _ej, _lhs) {
	_pt_init()
	_pt_check()

	printf("table %s%s", _PT_SEP(), _PT_SEP())
	_ei = st_name_term_count()
	for (_i = 1; _i <= _ei; ++_i)
		printf("%s%s", st_name_term(_i), _PT_SEP())
	print ""

	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		printf("table %s%s%s", _PT_SEP(), _lhs, _PT_SEP())
		_ej = st_name_term_count()
		for (_j = 1; _j <= _ej; ++_j)
			printf("%s%s", _pt_get(_lhs, st_name_term(_j)), _PT_SEP())
		print ""
	}
}
# </parse-table>
# <first-follow-predict>

function sets_init() {
	_sets_first()
	_sets_follow()
	_sets_predict()
	_sets_expect()

	# It is important to do this step after all set types have been generated
	# because it will mutate the follow sets.
	_sets_follow_customize()
}

function sets_print() {
	_sets_print_first()
	_sets_print_follow()
	_sets_print_predict()
	_sets_print_expect()
}

function sets_first(name, out_set_len,    _sset) {
	delete out_set_len
	_sset = _sets_fst_get(name)
	out_set_len[1] = _sets_set_pretty(_sset)
	out_set_len[2] = str_set_count(_sset)
}

function sets_follow(name, out_set_len,    _sset) {
	delete out_set_len
	_sset = _sets_flw_get(name)
	out_set_len[1] = _sets_set_pretty(_sset)
	out_set_len[2] = str_set_count(_sset)
}

function sets_first_first_conflicts() {return _sets_fsfs_conf_all()}
function sets_first_follow_conflicts() {return _sets_fsfwl_conf_all()}

function sets_pred_size(name)    {return _sets_pred_size(name)}
function sets_pred_at(name, pos) {return _sets_pred_at(name, pos)}
function sets_pred_pretty(name)  {return _sets_pred_get_pretty(name)}

function sets_exp_size(name)   {return _sets_exp_size(name)}
function sets_exp_pretty(name) {return _sets_exp_get_pretty(name)}

function sets_flw_size(name)   {return _sets_flw_size(name)}
function sets_flw_pretty(name) {return _sets_flw_get_pretty(name)}

# <private>
function _sets_print_first()   {_sets_fst_print()}
function _sets_print_follow()  {_sets_flw_print()}
function _sets_print_predict() {_sets_pred_print()}
function _sets_print_expect()  {_sets_exp_print()}

function _sets_dbg_print() {
	print "Firt sets:"
	_sets_fst_dbg_print()
	print ""
	print "Follow sets:"
	_sets_flw_dbg_print()
	print ""
	print "Predict:"
	_sets_pred_dbg_print()
}

function _SETS_EPS() {return "0"}
function _SETS_EOI() {return "$"}

# <sets>
# <data>
function _sets_set_init(set_tbl,    _i, _end) {
	set_tbl[""]
	delete set_tbl
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i)
		set_tbl[st_name(_i)] = str_set_init()
}
function _sets_set_size(set_tbl, name) {
	return str_set_count(_sets_set_get(set_tbl, name))
}
function _sets_set_at(set_tbl, name, pos) {
	return str_set_get(_sets_set_get(set_tbl, name), pos)
}
function _sets_set_has(set_tbl, name, sym) {
	return !!str_set_find(_sets_set_get(set_tbl, name), sym)
}
function _sets_set_add(set_tbl, name, sym,    _sset, _ret) {
	_ret = 0
	if (_sset = _sets_set_get(set_tbl, name)) {
		if (!str_set_find(_sset, sym)) {
			set_tbl[name] = str_set_add(_sset, sym)
			_ret = 1
		}
	}
	return _ret
}
function _sets_set_rm_name(set_tbl, n) {delete set_tbl[n]}
function _sets_set_make_empty(set_tbl, n) {set_tbl[n] = str_set_init()}
function _sets_set_union_no_eps(set_tbl, name, sset) {
	sset = str_set_del(sset, _SETS_EPS())
	return _sets_set_union(set_tbl, name, sset)
}
function _sets_set_union(set_tbl, name, sset,    _ssnm, _ssun, _ret) {
	_ret = 0
	if (_ssnm = _sets_set_get(set_tbl, name)) {
		_ssun = str_set_union(_ssnm, sset)
		if (!str_set_is_eq(_ssnm, _ssun)) {
			set_tbl[name] = _ssun
			_ret = 1
		}
	}
	return _ret
}
function _sets_set_get(set_tbl, n) {
	return (n in set_tbl) ? set_tbl[n] : str_set_init()
}
function _sets_set_has_name(set_tbl, n) {
	return (n in set_tbl)
}
function _sets_set_get_pretty(set_tbl, n,    _sset) {
	return _sets_set_pretty(_sets_set_get(set_tbl, n))
}
function _sets_set_dbg_print(set_tbl,    _n) {
	for (_n in set_tbl) {
		print sprintf("%s = %s", _n, \
			str_set_make_printable(_sets_set_get(set_tbl, _n)))
	}
}
function _sets_set_pretty(sset) {return str_list_pretty(sset)}
function _sets_set_print(set_tbl, pref,    _i, _ei, _j, _ej, _nm, _rid, _lhs) {
	pref = ("set " pref)
	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		_sets_nont_print(set_tbl, _lhs, pref)
		_rid = st_lhs_rule_id(_lhs, _i)

		_ej = st_lhs_rule_count(_lhs)
		for (_j = 1; _j <= _ej; ++_j) {
			_nm = st_rule_name(st_lhs_rule_id(_lhs, _j))
			_sets_nont_print(set_tbl, _nm, pref)
		}
	}
}
function _sets_nont_print(set_tbl, name, pref,    _sset, _str) {
	if (name in set_tbl) {
		_sset = _sets_set_get(set_tbl, name)
		if (!str_set_is_empty(_sset)) {
			_str = _sets_set_pretty(_sset)
			print sprintf("%s %s %s", pref, name, _str)
		}
	}
}
# </data>
# </sets>

# <first-sets>
# <data>
function _sets_fst_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_fst_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		if (st_name_is_term(_sym))
			_sets_set_add(_B_sets_fst_tbl, _sym, _sym)
		else if (st_name_can_null(_sym))
			_sets_set_add(_B_sets_fst_tbl, _sym, _SETS_EPS())
	}
}
function _sets_fst_has(name, sym) {
	return _sets_set_has(_B_sets_fst_tbl, name, sym)
}
function _sets_fst_add(name, sym) {
	return _sets_set_add(_B_sets_fst_tbl, name, sym)
}
function _sets_fst_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_fst_tbl, name, _sets_fst_get(sym))
}
function _sets_fst_get(name) {return _sets_set_get(_B_sets_fst_tbl, name)}
function _sets_fst_print() {_sets_set_print(_B_sets_fst_tbl, "first")}
function _sets_fst_dbg_print() {_sets_set_dbg_print(_B_sets_fst_tbl)}
# </data>

# <process>
function _sets_first_rule(rid,    _i, _end, _rnm, _lhs, _sym, _chg) {
	# Preconditions:
	# 1. Any rule x : 0 has been marked as can_null.
	# 2. The lhs for that rule has also been marked as can_null.
	# 3. eps has already been added to the first sets for the rule and the lhs.
	#
	# 'Any rule' from pt. 1 refers to the rule name; e.g.
	#
	# x : foo ; has the name of x_1 (first rule for lhs x)
	# x : 0   ; has the name of x_2 (second rule for lhs x)
	#
	# 'lhs' from pt. 2 refers to the left hand side of the rule; e.g.
	#
	# x : foo ; lhs is x
	#
	# After parsing the above two rules, st_name_can_null(x) and
	# st_name_can_null(x_1) must both return true. After the first sets init
	# procedure first(x) and first(x_1) must be {eps}, first(T) must be {T} for
	# any terminal T.
	#
	# Rule names are treated as non-terminals; we need sets per rule to detect
	# conflicts and generate each rule's predict set.

	_chg = 0
	if (!st_rule_is_zero(rid)) {
		# Only consider rules *not* of the form x : 0
		_rnm = st_rule_name(rid)
		_end = st_rule_pos_count(rid)
		for (_i = 1; _i <= _end; ++_i) {
			_sym = st_rule_pos_name(rid, _i)

			# Union the rule's first set with the current symbol's first set
			# excluding eps.
			_chg = keep(_sets_fst_union_no_eps(_rnm, _sym), _chg)

			# If the current symbol's first set has no eps, it's either a
			# terminal or a non-nullable non-terminal. We have found the rule's
			# first set.
			if (!_sets_fst_has(_sym, _SETS_EPS()))
				break
		}
		_lhs = st_rule_lhs(rid)

		# The first set for an lhs is the union of the first sets of all its
		# rules; e.g. first(x) = first(x_1) U first(x_2)
		_chg = keep(_sets_fst_union_no_eps(_lhs, _rnm), _chg)
		if (_i > _end) {
			# (_i > _end) means we did not encounter a symbol which was not
			# nullable, therefore we did not break out of the loop but exited
			# out of the loop when (_i <= _end) failed. I.e. the whole right
			# hand side for the rule can derive eps, which means we need to
			# add eps to the first(rule) and the firs(its lhs) by extension.
			_chg = keep(_sets_fst_add(_rnm, _SETS_EPS()), _chg)
			st_name_mark_can_null(_rnm)
			_chg = keep(_sets_fst_add(_lhs, _SETS_EPS()), _chg)
			st_name_mark_can_null(_lhs)
		}
	}

	# If at any point any set operation changed the target set, _chg will be 1.
	return _chg
}
function _sets_first(    _i, _end, _chg) {
	_sets_fst_init()
	_end = st_rule_count()
	do {
		_chg = 0
		for (_i = 1; _i <= _end; ++_i)
			_chg = keep(_sets_first_rule(_i), _chg)
	} while (_chg)
}
# </process>
# </first-sets>

# <follow-sets>
# <data>
function _sets_flw_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_flw_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Terminals have no follow sets, rule names never appear on the right.
		if (st_name_is_term(_sym) || st_name_is_rule(_sym))
			_sets_set_rm_name(_B_sets_flw_tbl, _sym)
	}
	_sets_set_add(_B_sets_flw_tbl, st_lhs(1), _SETS_EOI())
}
function _sets_flw_add(name, sym) {
	return _sets_set_add(_B_sets_flw_tbl, name, sym)
}
function _sets_flw_has(name, sym) {
	return _sets_set_has(_B_sets_flw_tbl, name, sym)
}
function _sets_flw_has_name(name) {
	return _sets_set_has_name(_B_sets_flw_tbl, name)
}
function _sets_flw_make_empty(name) {
	_sets_set_make_empty(_B_sets_flw_tbl, name)
}
function _sets_flw_first_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_flw_tbl, name, _sets_fst_get(sym))
}
function _sets_flw_follow_union(name, sym) {
	return _sets_set_union(_B_sets_flw_tbl, name, _sets_flw_get(sym))
}
function _sets_flw_get(name) {return _sets_set_get(_B_sets_flw_tbl, name)}
function _sets_flw_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_flw_tbl, name)
}
function _sets_flw_size(name) {
	return _sets_set_size(_B_sets_flw_tbl, name)
}
function _sets_flw_print() {_sets_set_print(_B_sets_flw_tbl, "follow")}
function _sets_flw_dbg_print() {_sets_set_dbg_print(_B_sets_flw_tbl)}
# </data>

# <process>
function _sets_follow_rule(rid,    _i, _j, _end, _lhs, _sym, _next, _chg) {
	# Preconditions:
	# 1. The first sets have been calculated.
	# 2. The follow set of the start symbol is {eoi}.
	# Follow sets are calculated only for actual non-terminals, i.e. rule names
	# are not considered since they never appear on the right.

	_chg = 0
	_lhs = st_rule_lhs(rid)
	_end = st_rule_pos_count(rid)
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_rule_pos_name(rid, _i)

		# No follow set for terminals.
		if (st_name_is_term(_sym))
			continue

		# If the current non-terminal is the last symbol on the right hand side
		# of the rule, it can be followed by whatever the left hand side can be
		# followed by.
		if (_i == _end) {
			_chg = keep(_sets_flw_follow_union(_sym, _lhs), _chg)
			break
		}

		# For all symbols to the right of the current symbol in the current rule
		for (_j = _i+1; _j <= _end; ++_j) {
			_next = st_rule_pos_name(rid, _j)

			# follow(current) = follow(current) U first(next) ...
			_chg = keep(_sets_flw_first_union_no_eps(_sym, _next), _chg)

			# If the next symbol is a terminal, or a non-nullable non-terminal,
			# we are done with follow(current).
			if (st_name_is_term(_next) || !_sets_fst_has(_next, _SETS_EPS()))
				break
		}
		if (_j > _end) {
			# (_j > _end) is true if we did not see a terminal, nor a
			# non-nullable non-terminal, i.e. all symbols on the right of the
			# current one can derive eps. In that case whatever can follow the
			# lhs can follow the current symbol.
			_chg = keep(_sets_flw_follow_union(_sym, _lhs), _chg)
		}
	}

	# If at any point any set operation changed the target set, _chg will be 1.
	return _chg
}
function _sets_follow(    _i, _end, _chg) {
	_sets_flw_init()
	_end = st_rule_count()
	do {
		_chg = 0
		for (_i = 1; _i <= _end; ++_i)
			_chg = keep(_sets_follow_rule(_i), _chg)
	} while (_chg)
}

# <customize>
function _sets_flw_cst_errq(msg) {
	error_quit(sprintf("sync: %s", msg))
}
function _sets_flw_cst_nont(nont,    _i, _end, _term) {
	_end = sync_term_count(nont)
	for (_i = 1; _i <= _end; ++_i) {
		_term = sync_term(nont, _i)
		if (!st_name_is_term(_term))
			_sets_flw_cst_errq(sprintf("'%s' not a terminal", _term))
		if (!_sets_flw_has(nont, _term)) {
			_sets_flw_cst_errq(sprintf("'%s' not in the follow set for '%s'", \
				_term, nont))
		}
	}

	# Rebuild set with only the specified tokens
	_sets_flw_make_empty(nont)
	for (_i = 1; _i <= _end; ++_i)
		_sets_flw_add(nont, sync_term(nont, _i))
}
function _sets_follow_customize(    _i, _end, _nont) {
	if (sync_type() == SYNC_DEFAULT()) {
		# Do nothing.
		return
	} else if (sync_type() == SYNC_CUSTOM()) {
		_end = sync_nont_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = sync_nont(_i)
			if (!st_name_is_lhs(_nont)) {
				_sets_flw_cst_errq(sprintf("'%s' not a lhs to be synced", \
					_nont))
			}
			if (!_sets_flw_has_name(_nont)) {
				_sets_flw_cst_errq(sprintf("'%s' cannot be synced", _nont))
			}
			_sets_flw_cst_nont(_nont)
		}

		# Empty all follow sets except the ones specified.
		_end = st_lhs_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = st_lhs(_i)
			if (_sets_flw_has_name(_nont) && !sync_has_nont(_nont))
				_sets_flw_make_empty(_nont)
		}
	} else if (sync_type() == SYNC_NONE()) {
		# Empty all follow sets.
		_end = st_lhs_count()
		for (_i = 1; _i <= _end; ++_i) {
			_nont = st_lhs(_i)
			if (_sets_flw_has_name(_nont))
				_sets_flw_make_empty(_nont)
		}
	}
}
# </customize>
# </process>
# </follow-sets>

# <predict-sets>
# <data>
function _sets_pred_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_predict_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Leave only rule names.
		if (!st_name_is_rule(_sym))
			_sets_set_rm_name(_B_sets_predict_tbl, _sym)
	}
}
function _sets_pred_size(name) {
	return _sets_set_size(_B_sets_predict_tbl, name)
}
function _sets_pred_at(name, pos) {
	return _sets_set_at(_B_sets_predict_tbl, name, pos)
}
function _sets_pred_first_union_no_eps(name, sym) {
	return _sets_set_union_no_eps(_B_sets_predict_tbl, name, _sets_fst_get(sym))
}
function _sets_pred_follow_union(name, sym) {
	return _sets_set_union(_B_sets_predict_tbl, name, _sets_flw_get(sym))
}
function _sets_pred_get(name) {return _sets_set_get(_B_sets_predict_tbl, name)}
function _sets_pred_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_predict_tbl, name)
}
function _sets_pred_print() {_sets_set_print(_B_sets_predict_tbl, "predict")}
function _sets_pred_dbg_print() {_sets_set_dbg_print(_B_sets_predict_tbl)}
# </data>

# <process>
function _sets_predict_rule(rid,    _rnm) {
	# Preconditions:
	# 1. The follow sets have been calculated.

	_rnm = st_rule_name(rid)
	# The predict set for the rule is first(rule). If the rule can derive eps,
	# then follow(lhs) is also in predict(rule) because anything in follow(lhs)
	# may appear if the rule "produces" the empty string.
	_sets_pred_first_union_no_eps(_rnm, _rnm)
	if (_sets_fst_has(_rnm, _SETS_EPS()))
		_sets_pred_follow_union(_rnm, st_rule_lhs(rid))
}
function _sets_predict(    _i, _end) {
	_sets_pred_init()
	_end = st_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_sets_predict_rule(_i)
}
# </process>
# </predict-sets>

# <expect-sets>
# <data>
function _sets_exp_init(    _i, _end, _sym) {
	_sets_set_init(_B_sets_expect_tbl)
	_end = st_name_count()
	for (_i = 1; _i <= _end; ++_i) {
		_sym = st_name(_i)
		# Leave only lhs.
		if (!st_name_is_lhs(_sym))
			_sets_set_rm_name(_B_sets_expect_tbl, _sym)
	}
}
function _sets_exp_predict_union(name, sym) {
	return _sets_set_union(_B_sets_expect_tbl, name, _sets_pred_get(sym))
}
function _sets_exp_get_pretty(name) {
	return _sets_set_get_pretty(_B_sets_expect_tbl, name)
}
function _sets_exp_size(name) {
	return _sets_set_size(_B_sets_expect_tbl, name)
}
function _sets_exp_print() {_sets_set_print(_B_sets_expect_tbl, "expect")}
function _sets_exp_dbg_print() {_sets_set_dbg_print(_B_sets_expect_tbl)}
# </data>

# <process>
function _sets_expect_rule(rid,    _rnm, _lhs) {
	# Preconditions:
	# 1. The predict sets have been calculated.
	#
	# The expect set for non-terminal x is the set of terminals which can start
	# x. I.e. the union of the predict sets for all rules for which x is the
	# left hand side.
	_rnm = st_rule_name(rid)
	_lhs = st_rule_lhs(rid)
	_sets_exp_predict_union(_lhs, _rnm)
}
function _sets_expect(    _i, _end, _rnm, _lhs) {
	_sets_exp_init()
	_end = st_name_rule_count()
	for (_i = 1; _i <= _end; ++_i)
		_sets_expect_rule(_i)
}
# </process>
# </expect-sets>

# <conflicts>
# <first-first>
function _sets_fsfs_conf_err(lhs, da, db, ssx,    _err) {
	_err = sprintf("first/first conflict\n%s : %s\n%s : %s", lhs, da, lhs, db)
	_err = sprintf("%s\ncan both begin with\n%s", _err, ssx)
	err_fpos(lhs, _err)
}
function _sets_fsfs_conf_rule(lhs, rn, end,    _i, _a, _sx, _rid, _nrid, _ret) {
	_ret = 0
	_rid = st_lhs_rule_id(lhs, rn)
	_a = _sets_fst_get(st_rule_name(_rid))
	for (_i = rn+1; _i <= end; ++_i) {
		_nrid = st_lhs_rule_id(lhs, _i)
		_sx = str_set_intersect(_a, _sets_fst_get(st_rule_name(_nrid)))
		if (!str_set_is_empty(_sx)) {
			_sets_fsfs_conf_err(lhs, \
				st_rule_str(_rid),
				st_rule_str(_nrid),
				_sets_set_pretty(_sx))
			_ret = 1
		}
	}
	return _ret
}
function _sets_fsfs_conf_rules_lhs(lhs,    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_rule_count(lhs)
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfs_conf_rule(lhs, _i, _end), _conf)
	return _conf
}
function _sets_fsfs_conf_all(    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfs_conf_rules_lhs(st_lhs(_i)), _conf)
	return _conf
}
# </first-first>
# <first-follow>
function _sets_fsfwl_conf_err(lhs, ssx,    _err) {
	_err = "first/follow conflict; can both begin with and be followed by"
	err_fpos(lhs, sprintf("%s\n%s", _err, ssx))
}
function _sets_fsfwl_conf_rule(lhs,    _si, _sx, _ret) {
	_ret = 0
	_si = _sets_fst_get(lhs)
	if (str_set_find(_si, _SETS_EPS())) {
		_sx = str_set_intersect(_si, _sets_flw_get(lhs))
		if (!str_set_is_empty(_sx)) {
			_sets_fsfwl_conf_err(lhs, _sets_set_pretty(_sx))
			_ret = 1
		}
	}
	return _ret
}
function _sets_fsfwl_conf_all(    _i, _end, _conf) {
	_conf = 0
	_end = st_lhs_count()
	for (_i = 1; _i <= _end; ++_i)
		_conf = keep(_sets_fsfwl_conf_rule(st_lhs(_i)), _conf)
	return _conf
}
# </first-follow>
# </conflicts>
# </private>
# </first-follow-predict>
# <sync>
function SYNC_NONE()    {return "snone"}
function SYNC_DEFAULT() {return "sdef"}
function SYNC_CUSTOM()  {return "scustom"}

function sync_init(str) {
	if ("" == str)
		str = "1"

	if ("0" == str) {
		_sync_set_type(SYNC_NONE())
	} else if ("1" == str) {
		_sync_set_type(SYNC_DEFAULT())
	} else if (index(str, "=")) {
		_sync_set_type(SYNC_CUSTOM())
		_sync_set_str(str)
		_sync_process(str)
	} else {
		_sync_errq("unknown type", str)
	}
}

function sync_type() {return _B_sync_table["type"]}
function sync_nont_count() {return _B_sync_table["nont.count"]+0}
function sync_nont(n) {return _B_sync_table[sprintf("nont=%s", n)]}
function sync_has_nont(n) {return (sprintf("nont.set=%s", n) in _B_sync_table)}
function sync_term_count(nont) {
	return _B_sync_table[sprintf("term.count=%s", nont)]+0
}
function sync_term(nont, n) {
	return _B_sync_table[sprintf("term=%s.%s", nont, n)]
}

# <private>
function _sync_process(str) {
	# expected str: "<nont>=TERM[,TERM][;<nont>=TERM[,TERM]]"
	gsub("[[:space:]]", "", str)
	_sync_split_semi(str)
}
function _sync_split_semi(str,    _arr, _len, _i, _str) {
	_len = split(str, _arr, ";")
	for (_i = 1; _i <= _len; ++_i) {
		_str = _arr[_i]

		if (!_str) {
			_sync_errq(sprintf("field %d empty after split on ';'", _i), \
				_sync_str())
		}

		_sync_split_equals(_str)
	}
}
function _sync_split_equals(str,    _arr, _len, _i, _head, _tail) {
	# expected str: "<nont>=TERM[,TERM]"
	_len = split(str, _arr, "=")
	if (_len != 2)
		_sync_errq("string does not split in two fields at '='", str)

	_head = _arr[1]
	_tail = _arr[2]

	if (!_head)
		_sync_errq("nothing before '='", str)

	if (!_tail)
		_sync_errq("nothing after '='", str)

	if (!is_non_term(_head))
		_sync_errq(sprintf("'%s' not a non-terminal", _head), str)

	_sync_save_nont(_head)
	_sync_split_comma(_tail)
}
function _sync_split_comma(str,    _arr, _len, _i, _nm) {
	# expected str: TERM[,TERM]
	_len = split(str, _arr, ",")
	for (_i = 1; _i <= _len; ++_i) {
		_nm = _arr[_i]

		if (!_nm)
			_sync_errq(sprintf("field %d empty after split on ','", _i), str)

		if (!is_terminal(_nm))
			_sync_errq(sprintf("'%s' not a terminal", _nm), str)

		_sync_save_term(_nm)
	}
}

function _sync_errq(msg, str) {
	msg = sprintf("sync: %s", msg)
	if (str)
		msg = (msg sprintf(":\n%s", str))
	error_quit(msg)
}

function _sync_set_str(str) {_B_sync_table["str"] = str}
function _sync_str()        {return _B_sync_table["str"]}
function _sync_set_type(type) {_B_sync_table["type"] = type}
function _sync_save_nont(nont,    _c, _n, _s) {
	_s = sprintf("nont.set=%s", nont)
	if (!(_s in _B_sync_table))
		_B_sync_table[_s]
	else
		_sync_errq(sprintf("'%s' redefined", nont), _sync_str())

	_c = ++_B_sync_table["nont.count"]
	_n = sprintf("nont=%s", _c)
	_B_sync_table[_n] = nont
}
function _sync_nont_last(    _c, _n) {
	_c = _B_sync_table["nont.count"]
	_n = sprintf("nont=%s", _c)
	return _B_sync_table[_n]
}
function _sync_save_term(term,    _nont, _c, _n, _s) {
	_nont = _sync_nont_last()

	_s = sprintf("term.set.%s=%s", _nont, term)
	if (!(_s in _B_sync_table)) {
		_B_sync_table[_s]
	} else {
		_sync_errq(sprintf("'%s' multiple times in '%s'", term, _nont), \
			_sync_str())
	}

	_n = sprintf("term.count=%s", _nont)
	_c = ++_B_sync_table[_n]
	_n = sprintf("term=%s.%s", _nont, _c)
	_B_sync_table[_n] = term
}
# </private>
# </sync>
# <names>
function is_terminal(nm) {
	return match(nm, "^[_[:upper:]][[:upper:][:digit:]_]*$")
}
function is_non_term(nm) {
	return match(nm, "^[_[:lower:]][[:lower:][:digit:]_]*$")
}
# </names>
#@ <awklib_prog>
#@ Library: prog
#@ Description: Provides program name, error, and exit handling.
#@ Version 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-15
#@

#
#@ Description: Sets the program name to 'str'. This name can later be
#@ retrieved by get_program_name().
#@ Returns: Nothing.
#
function set_program_name(str) {

	_AWKLIB_prog__program_name = str
}

#
#@ Description: Provides the program name.
#@ Returns: The name as set by set_program_name().
#
function get_program_name() {

	return _AWKLIB_prog__program_name
}

#
#@ Description: Prints 'msg' to stderr.
#@ Returns: Nothing.
#
function pstderr(msg) {

	print msg > "/dev/stderr"
}

#
#@ Description: Sets a static flag which can later be checked by
#@ should_skip_end().
#@ Returns: Nothing.
#
function skip_end_set() {

	_AWKLIB_prog__skip_end_flag = 1
}

#
#@ Description: Clears the flag set by skip_end_set().
#@ Returns: Nothing.
#
function skip_end_clear() {

	_AWKLIB_prog__skip_end_flag = 0
}

#
#@ Description: Checks the static flag set by skip_end_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function should_skip_end() {

	return (_AWKLIB_prog__skip_end_flag+0)
}

#
#@ Description: Sets a static flag which can later be checked by
#@ did_error_happen().
#@ Returns: Nothing
#
function error_flag_set() {

	_AWKLIB_prog__error_flag = 1
}

#
#@ Description: Clears the flag set by error_flag_set().
#@ Returns: Nothing
#
function error_flag_clear() {

	_AWKLIB_prog__error_flag = 0
}

#
#@ Description: Checks the static flag set by error_flag_set().
#@ Returns: 1 if the flag is set, 0 otherwise.
#
function did_error_happen() {

	return (_AWKLIB_prog__error_flag+0)
}

#
#@ Description: Sets the skip end flag, exits with error code 0.
#@ Returns: Nothing.
#
function exit_success() {

	skip_end_set()
	exit(0)
}

#
#@ Description: Sets the skip end flag, exits with 'code', or 1 if 'code' is 0
#@ or not given.
#@ Returns: Nothing.
#
function exit_failure(code) {

	skip_end_set()
	exit((code+0) ? code : 1)
}

#
#@ Description: Prints '<program-name>: error: msg' to stderr. Sets the
#@ error and skip end flags.
#@ Returns: Nothing.
#
function error_print(msg) {

	pstderr(sprintf("%s: error: %s", get_program_name(), msg))
	error_flag_set()
	skip_end_set()
}

#
#@ Description: Calls error_print() and quits with failure.
#@ Returns: Nothing.
#
function error_quit(msg, code) {

	error_print(msg)
	exit_failure(code)
}
#@ </awklib_prog>
#@ <awklib_tabs>
#@ Library: tabs
#@ Description: String indentation.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-16
#@

#
#@ Description: Adds a tab to the indentation string.
#@ Returns: Nothing.
#
function tabs_inc() {

	++_AWKLIB_tabs__tabs_num
	_AWKLIB_tabs__tabs_str = (_AWKLIB_tabs__tabs_str "\t")
}

#
#@ Description: Removes a tab from the indentation string.
#@ Returns: Nothing.
#
function tabs_dec() {

	if (_AWKLIB_tabs__tabs_num) {
		--_AWKLIB_tabs__tabs_num
		_AWKLIB_tabs__tabs_str = substr(_AWKLIB_tabs__tabs_str, 1,
			_AWKLIB_tabs__tabs_num)
	}
}

#
#@ Description: Indicates the tab level.
#@ Returns: The number of tabs used for indentation.
#
function tabs_num() {

	return _AWKLIB_tabs__tabs_num
}

#
#@ Description: Provides all indentation tabs as a string.
#@ Returns: The indentation string.
#
function tabs_get() {

	return (_AWKLIB_tabs__tabs_str "")
}

#
#@ Description: Adds indentation to 'str'.
#@ Returns: 'str' prepended with the current number of tabs.
#
function tabs_indent(str) {

	return (_AWKLIB_tabs__tabs_str str)
}

#
#@ Description: Prints the indented 'str' to stdout without a new line
#@ at the end.
#@ Returns: Nothing.
#
function tabs_print_str(str) {

	printf("%s", tabs_indent(str))
}

#
#@ Description: Prints the indented 'str' to stdout with a new line at
#@ the end.
#@ Returns: Nothing.
#
function tabs_print(str) {

	print tabs_indent(str)
}
#@ </awklib_tabs>
#@ <awklib_str_list>
#@ Library: str_list
#@ Description: Treats a string as a list of elements.
#@ Version: 1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-25
#@

# <public>
#
#@ Description: The item separator.
#@ Returns: Some non-printable character.
#
function STR_LIST_SEP() {

	return "\034"
}

#
#@ Description: The printable item separator.
#@ Returns: The default printable delimiter.
#
function STR_LIST_PRINT_SEP() {

	return "@"
}

#
#@ Description: Initializes a string to the empty list.
#@ Returns: The string list initialization value.
#
function str_list_init() {

	return STR_LIST_SEP()
}

#
#@ Description: Makes a list from an array.
#@ Returns: A string list with the elements of 'arr'.
#@ Complexity: O(add*len)
#
function str_list_init_arr(arr, len) {

	return str_list_add_arr(str_list_init(), arr, len)
}

#
#@ Description: Gets the size of 'slist'.
#@ Returns: The number of elements in 'slist'.
#@ Complexity: O(n)
#
function str_list_size(slist) {

	return gsub(STR_LIST_SEP(), STR_LIST_SEP(), slist)-1
}

#
#@ Description: Tells you whether 'slist' is empty.
#@ Returns: 1 if 'slist' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function str_list_is_empty(slist) {

	return (STR_LIST_SEP() == slist)
}

#
#@ Description: Looks for the first 'val' in 'slist'.
#@ Returns: Non-zero if 'val' is found, 0 otherwise.
#@ Complexity: O(n)
#
function str_list_find(slist, val) {

	return index(slist, (STR_LIST_SEP() val STR_LIST_SEP()))
}

#
#@ Description: Finds out how many instances of 'val' are in 'slist'
#@ Returns: The number of times 'val' occurs in 'slist'.
#@ Complexity: O(n)
#
function str_list_how_many(slist, val,    _start, _ret) {

	_ret = 0
	val = (STR_LIST_SEP() val STR_LIST_SEP())
	while (_start = index(slist, val)) {
		++_ret
		slist = substr(slist, _start+1)
	}
	return _ret
}

#
#@ Description: Appends 'val' to 'slist'.
#@ Returns: A new list to replace 'slist'.
#@ Complexity: O(str-append)
#
function str_list_add(slist, val) {

	return (slist val STR_LIST_SEP())
}

#
#@ Description: Adds 'arr' to 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(add*len)
#
function str_list_add_arr(slist, arr, len,    _i) {

	for (_i = 1; _i <= len; ++_i)
		slist = str_list_add(slist, arr[_i])
	return slist
}

#
#@ Description: Appends 'slist_b' to 'slist_a'.
#@ Returns: A new list to replace 'slist_a'.
#@ Complexity: O(str-append)
#
function str_list_append_list(slist_a, slist_b) {

	return (slist_a substr(slist_b, 2))
}

#
#@ Description: Removes the first 'val' from 'slist'.
#@ Returns: A new list to replace 'slist'.
#@ Complexity: O(n)
#
function str_list_del(slist, val,    _start) {

	return (_start = str_list_find(slist, val)) ? \
		(substr(slist, 1, _start) substr(slist, _start+length(val)+2)) : slist
}

#
#@ Description: Removes every occurrence of 'val' from 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(n)
#
function str_list_del_all(slist, val,    _start, _vlen) {

	val = (STR_LIST_SEP() val STR_LIST_SEP())
	_vlen = length(val)
	while (_start = index(slist, val))
		slist = (substr(slist, 1, _start) substr(slist, _start+_vlen))
	return slist
}

#
#@ Description: Removes the first occurrence of every 'arr' item from 'slist'.
#@ Returns: A new string list to replace 'slist'.
#@ Complexity: O(del*len)
#
function str_list_del_arr(slist, arr, len) {

	while (len)
		slist = str_list_del(slist, arr[len--])
	return slist
}

#
#@ Description: Removes every occurrence of every item in 'arr' from 'slist'.
#@ Returns: A new sting list to replace 'slist'.
#@ Complexity: O(del_all*len)
#
function str_list_del_arr_all(slist, arr, len) {

	while (len)
		slist = str_list_del_all(slist, arr[len--])
	return slist
}

#
#@ Description: Extracts the 'n'-th element from 'slist'. 'n' is assumed to be
#@ in the bounds of 'slist'. A check whether or not it is should be performed
#@ before the call.
#@ Returns: The element at position 'n' in 'slist'. The empty string if 'n' is
#@ out of bounds. NOTE: The element at position 'n' could also be the empty
#@ string.
#@ Complexity: O(n)
#
function str_list_get(slist, n) {

	if (!str_list_is_empty(slist)) {
		while (_pos = index(slist, STR_LIST_SEP())) {
			if ((slist = substr(slist, _pos+1)) && !(--n))
				return substr(slist, 1, index(slist, STR_LIST_SEP())-1)
		}
	}
	return ""
}

#
#@ Description: Splits 'slist' in 'arr'.
#@ Returns: The size of 'arr'.
#@ Complexity: O(n)
#
function str_list_split(slist, arr) {

	return split(substr(slist, 2), arr,  STR_LIST_SEP())-1
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to STR_LIST_PRINT_SEP().
#@ Returns: A printable representation of 'slist'.
#@ Complexity: O(n)
#
function str_list_make_printable(slist, delim) {

	if (!delim)
		delim = STR_LIST_PRINT_SEP()

	gsub(STR_LIST_SEP(), delim, slist)
	return slist
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to a single space.
#@ Returns: A printable representation of 'slist'.
#@ Complexity: O(n)
#
function str_list_pretty(slist, delim) {

	if (!delim)
		delim = " "

	slist = substr(slist, 2, length(slist)-2)
	gsub(STR_LIST_SEP(), delim, slist)
	return slist
}

#
#@ Description: str_list_make_printable() + print.
#@ Returns: Nothing.
#
function str_list_print(slist, delim) {

	print str_list_make_printable(slist, delim)
}

#
#@ Description: str_list_pretty() + print.
#@ Returns: Nothing.
#
function str_list_pretty_print(slist, delim) {

	print str_list_pretty(slist, delim)
}

# </public>
#@ </awklib_str_list>
#@ <awklib_str_set>
#@ Library: str_set
#@ Description: Treats a string as a set of values.
#@ Version: 1.2
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-25
#@

# <public>
#
#@ Description: The set item delimiter.
#@ Returns: Some non-printable character.
#
function STR_SET_SEP() {

	return "\034"
}

#
#@ Description: The printable set item delimiter.
#@ Returns: The default printable delimiter character.
#
function STR_SET_PRINT_SEP() {

	return "|"
}

#
#@ Description: Initializes a string to the empty set.
#@ Returns: The string set initialization value.
#
function str_set_init() {

	return STR_SET_SEP()
}

#
#@ Description: Makes a set from an array.
#@ Returns: A string set from the elements of 'arr'.
#@ Complexity: O(add*len)
#
function str_set_init_arr(arr, len) {

	return str_set_add_arr(str_set_init(), arr, len)
}

#
#@ Description: Looks for 'val' in 'sset'.
#@ Returns: Non-zero if 'val' is in 'sset', 0 otherwise.
#@ Complexity: O(n)
#
function str_set_find(sset, val) {

	return index(sset, (STR_SET_SEP() val STR_SET_SEP()))
}

#
#@ Description: Adds 'val' to 'sset' if 'val' is not in 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(n)
#
function str_set_add(sset, val) {

	if (!str_set_find(sset, val))
		sset = (sset val STR_SET_SEP())
	return sset
}

#
#@ Description: Adds 'arr' to 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(add*len)
#
function str_set_add_arr(sset, arr, len) {

	while (len)
		sset = str_set_add(sset, arr[len--])
	return sset
}

#
#@ Description: Removes 'val' from 'sset' if 'val' is in 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(n)
#
function str_set_del(sset, val,    _start) {

	return (_start = str_set_find(sset, val)) ? \
		(substr(sset, 1, _start) substr(sset, _start+length(val)+2)) : sset
}

#
#@ Description: Removes 'arr' from 'sset'.
#@ Returns: A new string set to replace 'sset'.
#@ Complexity: O(del*len)
#
function str_set_del_arr(sset, arr, len) {

	while (len)
		sset = str_set_del(sset, arr[len--])
	return sset
}


#
#@ Description: Gets the size of 'sset'.
#@ Returns: The number of elements in 'sset'.
#@ Complexity: O(n)
#
function str_set_count(sset) {

	return gsub(STR_SET_SEP(), STR_SET_SEP(), sset)-1
}

#
#@ Description: Tells you whether 'sset' is empty.
#@ Returns: 1 if 'sset' is empty, 0 otherwise.
#@ Complexity: O(1)
#
function str_set_is_empty(sset) {

	return (STR_SET_SEP() == sset)
}

#
#@ Description: Extracts the 'n'-th element from 'sset'. 'n' is assumed to be in
#@ the bounds of 'sset'. A check whether or not it is should be performed before
#@ the call.
#@ Returns: The element at position 'n' in 'sset'. The empty string if 'n' is
#@ out of bounds. NOTE: The element at position 'n' could also be the empty
#@ string.
#@ Complexity: O(n)
#
function str_set_get(sset, n,    _pos) {

	if (!str_set_is_empty(sset)) {
		while (_pos = index(sset, STR_SET_SEP())) {
			if ((sset = substr(sset, _pos+1)) && !(--n))
				return substr(sset, 1, index(sset, STR_SET_SEP())-1)
		}
	}
	return ""
}

#
#@ Description: Splits 'sset' into 'arr'.
#@ Returns: The number of elements in 'arr'.
#@ Complexity: O(n)
#
function str_set_split(sset, arr) {

	return (str_set_is_empty(sset)) ? 0 : \
		split(substr(sset, 2), arr,  STR_SET_SEP())-1
}

#
#@ Description: Indicates if 'sset_a' and 'sset_b' contain the same items.
#@ Returns: 1 if they do, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_is_eq(sset_a, sset_b,    _i, _end, _arr, _is_eq) {

	_is_eq = 1
	if (str_set_count(sset_a) != str_set_count(sset_b)) {
		_is_eq = 0
	} else {
		_end = str_set_split(sset_b, _arr)
		for (_i = 1; _i <= _end; ++_i) {
			if (!str_set_find(sset_a, _arr[_i])) {
				_is_eq = 0
				break
			}
		}
	}
	return _is_eq
}

#
#@ Description: Gets all elements from 'sset_a' and 'sset_b'.
#@ Returns: The union set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_union(sset_a, sset_b,     _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i)
		sset_a = str_set_add(sset_a, _arr[_i])
	return sset_a
}

#
#@ Description: Gets all elements from 'sset_a' which are also in 'sset_b'.
#@ Returns: The intersection set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_intersect(sset_a, sset_b,    _i, _end, _arr, _sset_ret) {

	_sset_ret = str_set_init()
	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (str_set_find(sset_a, _arr[_i]))
			_sset_ret = (_sset_ret _arr[_i] STR_SET_SEP())
	}
	return _sset_ret
}

#
#@ Description: Gets all elements of 'sset_a' which are not in 'sset_b'.
#@ Returns: The difference set of 'sset_a' and 'sset_b'.
#@ Complexity: O(n*m)
#
function str_set_subtract(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i)
		sset_a = str_set_del(sset_a, _arr[_i])
	return sset_a
}

#
#@ Description: Indicates if 'sset_a' and 'sset_b' have no elements in common.
#@ Returns: 1 if they don't, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_are_disjoint(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_b, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (str_set_find(sset_a, _arr[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Indicates if 'sset_a' is a subset of 'sset_b'
#@ Returns: 1 if it is, 0 otherwise.
#@ Complexity: O(n*m)
#
function str_set_is_subset(sset_a, sset_b,    _i, _end, _arr) {

	_end = str_set_split(sset_a, _arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (!str_set_find(sset_b, _arr[_i]))
			return 0
	}
	return 1
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not given, it defaults to STR_SET_PRINT_SEP().
#@ Returns: A printable representation of 'sset'.
#@ Complexity: O(n)
#
function str_set_make_printable(sset, delim) {

	if (!delim)
		delim = STR_SET_PRINT_SEP()

	gsub(STR_SET_SEP(), delim, sset)
	return sset
}

#
#@ Description: Replaces the default non-printable delimiter character with
#@ 'delim'. If 'delim' is not give, it defaults to a single space.
#@ Returns: A printable representation of 'sset'.
#@ Complexity: O(n)
#
function str_set_pretty(sset, delim) {

	if (!delim)
		delim = " "

	sset = substr(sset, 2, length(sset)-2)
	gsub(STR_SET_SEP(), delim, sset)
	return sset
}

#
#@ Description: str_set_make_printable() + print.
#@ Returns: Nothing.
#
function str_set_print(sset, delim) {

	print str_set_make_printable(sset, delim)
}

#
#@ Description: str_set_pretty() + print.
#@ Returns: Nothing.
#
function str_set_pretty_print(sset, delim) {

	print str_set_pretty(sset, delim)
}

# </public>
#@ </awklib_str_set>
