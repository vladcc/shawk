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
