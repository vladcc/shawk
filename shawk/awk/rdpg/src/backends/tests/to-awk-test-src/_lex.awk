function error_quit(msg) {
	error_print(msg)
	exit(1)
}
function error_print(msg) {
	print msg > "/dev/stderr"
}

function parsing_error_set() {_B_parsing_error_flag = 1}
function parsing_error_happened() {return _B_parsing_error_flag}

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
		lex_fname(), lex_line_num(), lex_pos(), lex_curr_tok())

	if (_prev = _tok_prev())
		_str = (_str sprintf(" after '%s'", _prev))
	_str = (_str "\n")

	if (_lex_str())
		_str = (_str sprintf("%s\n", lex_get_pos_str()))

	_end = rdpg_expect(_arr)
	for (_i = 1; _i <= _end; ++_i) {
		if (_exp)
			_exp = (_exp " ")
		_exp = (_exp sprintf("'%s'", _arr[_i]))
	}

	if (1 == _end)
		_str = (_str sprintf("expected: %s", _exp))
	else if (_end > 1)
		_str = (_str sprintf("expected one of: %s", _exp))

	error_print((_str "\n"))
}

function _lex_getline(    _res) {
	if ((_res = getline) > 0)
		return ($0 "\n")
	else if (0 == _res)
		return ""

	error_quit(sprintf("getline io with code %s", _res))
}
function _lex_next_ln() {
	_B_lex_str = _lex_getline()
	++_B_lex_ln_num
	_B_lex_ln_pos = 1
	_B_lex_ch_arr_len = split(_B_lex_str, _B_lex_ch_arr, "")
}
function _lex_get_ch() {
	return _B_lex_ch_arr[_B_lex_ln_pos++]
}
function _lex_next_ch() {
	return _B_lex_ch_arr[_B_lex_ln_pos]
}
function _lex_str() {
	return _B_lex_str
}

function _lex_is_digit(ch) {return (ch >= "0" && ch <= "9")}

function NUMBER() {return "number"}
function PLUS()   {return "+"}
function MINUS()  {return "-"}
function MUL()    {return "*"}
function DIV()    {return "/"}
function POW()    {return "^"}
function L_PAR()  {return "("}
function R_PAR()  {return ")"}
function SEMI()   {return ";"}
function EOI()    {return "eoi"}
function ERROR()  {return "error"}

function lex_get_num() {return _B_lex_text}

function lex_next() {
	_B_lex_curr_tok = ERROR()

	if ("" == _B_lex_curr_ch)
		_lex_next_ln()

	while (" " == (_B_lex_curr_ch = _lex_get_ch()) || "\t" == _B_lex_curr_ch)
		continue

	if (_lex_is_digit(_B_lex_curr_ch)) {
		_B_lex_text = ""
		while (1) {
			_B_lex_text = (_B_lex_text _B_lex_curr_ch)
			if (_lex_is_digit(_lex_next_ch()))
				_B_lex_curr_ch = _lex_get_ch()
			else
				break
		}
		_B_lex_curr_tok = NUMBER()
	} else if ("+" == _B_lex_curr_ch || "-" == _B_lex_curr_ch \
		|| "*" == _B_lex_curr_ch || "/" == _B_lex_curr_ch     \
		|| "^" == _B_lex_curr_ch || "(" == _B_lex_curr_ch     \
		|| ")" == _B_lex_curr_ch || ";" == _B_lex_curr_ch) {
			_B_lex_curr_tok = _B_lex_curr_ch
	} else if ("\n" == _B_lex_curr_ch) {
		_B_lex_curr_ch = ""
		_B_lex_curr_tok = lex_next()
	} else if (!_B_lex_curr_ch) {
		_B_lex_curr_tok = EOI()
	}

	return _B_lex_curr_tok
}

function lex_fname()    {return FILENAME}
function lex_line_num() {return _B_lex_ln_num}
function lex_pos()      {return _B_lex_ln_pos-1}
function lex_curr_tok() {return _B_lex_curr_tok}

function lex_get_pos_str(    _sp) {
	_sp = substr(_B_lex_str, 1, lex_pos()-1)
	gsub("[^[:space:]]", " ", _sp)
	_sp = (_sp "^")
	return (_B_lex_str _sp)
}
