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
# <public>
function lex_usr_err_print(msg)  {_lu_err_print(msg)}
function lex_usr_err_quit(msg)   {_lu_err_quit(msg)}

function lex_usr_get_line(    _res) {
	if ((_res = getline) > 0)
		return ($0 "\n")
	else if (0 == _res)
		return ""

	error_quit(sprintf("getline io with code %s", _res))
}
function lex_usr_on_unknown_ch() {
	_lu_err_quit(sprintf("unknown character '%s'", lex_curr_ch()))
}
function lex_usr_on_comment() {
	if (lex_read_line())
		return lex_next()
	else
		return TOK_EOI()
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
			_lu_err_quit(sprintf("name must contain at least one letter"))
		else
			lex_read_ch()
	}

	if (_lu_is_upped(_ch))
		return _lu_get_term()
	else if (_lu_is_lower(_ch))
		return _lu_get_nont()
	else
		return TOK_ERROR()
}
# </public>

# <private>
function _lu_is_upped(ch) {return (ch >= "A" && ch <= "Z")}
function _lu_is_lower(ch) {return (ch >= "a" && ch <= "z")}
function _lu_is_digit(ch) {return (ch >= "0" && ch <= "9")}
function _lu_is_name_part(ch) {return "_" == ch || _lu_is_digit(ch)}
function _lu_is_term_rest(ch) {return _lu_is_upped(ch) || _lu_is_name_part(ch)}
function _lu_is_nont_rest(ch) {return _lu_is_lower(ch) || _lu_is_name_part(ch)}

function _lu_pos_str_pretty(    _pref, _pos_str) {
    _pref = sprintf("    %d | ", lex_get_line_no())
    _pos_str = (_pref lex_get_pos_str(tok_get_text(tok_curr())))
    gsub("[^[:space:]|]", " ", _pref)
    sub("\n", ("\n" _pref), _pos_str)
    return _pos_str
}
function _lu_msg_pos_pretty(msg) {
    return sprintf("%s\n%s", msg, _lu_pos_str_pretty())
}

function _lu_err_print(msg) {
	parsing_error_set()
    error_print(sprintf("%s:%d:%d\n%s", fname(), lex_get_line_no(), \
        lex_get_pos(), _lu_msg_pos_pretty(msg)))
}
function _lu_err_quit(msg) {
    _lu_err_print(msg)
    exit_failure()
}

function _lu_get_term(    _ch) {
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
		_lu_err_quit("non-upper case in a terminal symbol")
	}

	return TERM()
}

function _lu_get_nont(    _ch) {
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
		_lu_err_quit("non-lower case in a non-terminal symbol")
	}

	return (!lex_is_saved_a_keyword() ? NONT() : lex_get_saved())
}
# </private>
# </lex_usr>
# <tok>
# <public>
function tok_get_text(tok) {
	if (_tok_is_saved(tok))
		return lex_get_saved()
	if (TOK_ERROR() == tok || TOK_EOI() == tok)
		return ""
	return tok
}

function tok_next() {
    _tok_prev_set(lex_curr_tok())
    return lex_next()
}
function tok_curr() {return lex_curr_tok()}
function tok_err(    _tok, _str, _i, _end, _arr, _exp, _prev) {

    _tok = lex_curr_tok()
	_str = sprintf("unexpected: '%s'", _tok)

    if (_tok_is_saved(_tok))
        _str = (_str sprintf(" with value '%s'", tok_get_text(_tok)))

	if ((_prev = _tok_prev()) && (TOK_ERROR() != _prev)) {
		_str = (_str sprintf(" after '%s'", _prev))
		if (_tok_is_saved(_prev))
			_str = (_str sprintf(" with value '%s'", tok_get_text(_prev)))
	}

	_end = rdpg_expect(_arr)
    if (1 <= _end)
        _exp = sprintf("'%s'", _arr[1])
	for (_i = 2; _i <= _end; ++_i)
		_exp = (_exp sprintf(", '%s' ", _arr[_i]))

    lex_usr_err_print(sprintf("%s\n  expected: %s", _str, _exp))

	if_fatal_exit()
}
# </public>
# <private>
function _tok_is_saved(tok) {return (TERM() == tok || NONT() == tok)}
function _tok_prev_set(tok) {_B_tok_prev = tok}
function _tok_prev()        {return _B_tok_prev}
# </private>
# </tok>
# </lexer>
