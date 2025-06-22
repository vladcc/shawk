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
