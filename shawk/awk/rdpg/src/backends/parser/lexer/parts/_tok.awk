# <tok>
# <public>
function tok_next() {
	_tok_prev_set(tok_curr())
	return _lex_next()
}
function tok_curr() {return lex_get_curr_tok()}
function tok_err(    _str, _i, _end, _arr, _exp, _prev) {
	_str = sprintf("unexpected: '%s'", tok_curr())
	if (_prev = _tok_prev())
		_str = (_str sprintf(" after '%s'", _prev))

	_end = rdpg_expect(_arr)
    if (1 <= _end)
        _exp = sprintf("'%s'", _arr[1])
	for (_i = 2; _i <= _end; ++_i)
		_exp = (_exp sprintf(", '%s' ", _arr[_i]))

    _lex_err_quit(sprintf("%s\n  expected: %s", _str, _exp))
}
# </public>
# <private>
function _tok_prev_set(tok) {_B_lex_tok_prev = tok}
function _tok_prev()        {return _B_lex_tok_prev}
# </private>
# </tok>
