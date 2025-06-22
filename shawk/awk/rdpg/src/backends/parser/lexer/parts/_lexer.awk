# <lex>
# The backend lexer. It's assumed every single token is separated by space.

# <public>
function EOI() {return "eoi"}
function NAME() {return "name"}

function lex_init() {
	FS = " "
	RS = "\n"
	_lex_make_ir_set()
	lex_next_line()
}

function lex_get_line(    _ln) {
	_ln = $0
	sub("^[[:space:]]*", "", _ln)
	return _ln
}

function lex_get_curr_tok() {return _B_lex_curr_tok}
function lex_get_name()     {return _B_lex_saved_name}
function lex_next_line(    _res) {
	_B_lex_curr_nf = 0
	if ((_res = getline) > 0)
		return 1
	else if (0 == _res)
		return 0
	error_quit(sprintf("getline io with code %s", _res))
}
# </public>
# <private>
function _lex_line_no()      {return FNR}
function _lex_fname()        {return FILENAME}
function _lex_curr_fld_num() {return _B_lex_curr_nf}

function _lex_save_name(nm) {
	if (match(nm, "[_[:alpha:]][_[:alnum:]]*")) {
		_B_lex_saved_name = nm
	} else {
		_lex_err_quit(sprintf("unknown token '%s'", nm))
    }
}

function _lex_err_print(msg) {
	parsing_error_set()
    error_print(sprintf("%s:%d:%d\n%s", _lex_fname(), _lex_line_no(), \
        _lex_curr_fld_num(), _lex_msg_pos_pretty(msg)))
}
function _lex_err_quit(msg) {
    _lex_err_print(msg)
    exit_failure()
}

function _lex_next() {
	++_B_lex_curr_nf
	_B_lex_curr_tok = ""
	if (_B_lex_curr_nf <= NF) {
		_B_lex_curr_tok = $_B_lex_curr_nf
		if (!(_B_lex_curr_tok in _B_lex_ir_set)) {
			_lex_save_name(_B_lex_curr_tok)
			_B_lex_curr_tok = NAME()
		}
	} else if (lex_next_line()) {
		return _lex_next()
	} else {
		_B_lex_curr_tok = EOI()
	}
	return _B_lex_curr_tok
}


function _lex_msg_pos_pretty(msg) {
    return sprintf("%s\n%s", msg, _lex_get_pos_str_pretty())
}
function _lex_get_pos_str_pretty(    _pref, _pos_str) {
    _pref = sprintf("    %d | ", _lex_line_no())
    _pos_str = (_pref _lex_get_pos_str())
    gsub("[^[:space:]|]", " ", _pref)
    sub("\n", ("\n" _pref), _pos_str)
    return _pos_str
}
function _lex_get_pos_str(    _target, _i, _end, _str, _fld, _len) {
	_target = _B_lex_curr_nf
	_end = NF
	for (_i = 1; _i <= _end; ++_i) {
		_fld = $_i
		if (_i < _target)
			_len += length(_fld) + (_i < _end)
		_str = (_str $_i)
		if (_i < _end)
			_str = (_str " ")
	}

	_fld = ""
	_end = _len
	for (_i = 1; _i <= _end; ++_i)
		_fld = (_fld " ")

	return (_str "\n" (_fld "^"))
}


function _lex_make_ir_set() {
	_B_lex_ir_set[IR_ALIAS()]
	_B_lex_ir_set[IR_COMMENT()]
	_B_lex_ir_set[IR_SETS()]
	_B_lex_ir_set[IR_PREDICT()]
	_B_lex_ir_set[IR_EXPECT()]
	_B_lex_ir_set[IR_SYNC()]
	_B_lex_ir_set[IR_ESC()]
	_B_lex_ir_set[IR_FUNC()]
	_B_lex_ir_set[IR_CALL()]
	_B_lex_ir_set[IR_RETURN()]
	_B_lex_ir_set[IR_TRUE()]
	_B_lex_ir_set[IR_FALSE()]
	_B_lex_ir_set[IR_RDPG_PARSE()]
	_B_lex_ir_set[IR_AND()]
	_B_lex_ir_set[IR_BLOCK_OPEN()]
	_B_lex_ir_set[IR_BLOCK_CLOSE()]
	_B_lex_ir_set[IR_IF()]
	_B_lex_ir_set[IR_ELSE_IF()]
	_B_lex_ir_set[IR_ELSE()]
	_B_lex_ir_set[IR_LOOP()]
	_B_lex_ir_set[IR_CONTINUE()]
	_B_lex_ir_set[IR_TOKENS()]
	_B_lex_ir_set[IR_TOK_MATCH()]
	_B_lex_ir_set[IR_TOK_IS()]
	_B_lex_ir_set[IR_TOK_NEXT()]
	_B_lex_ir_set[IR_TOK_CURR()]
	_B_lex_ir_set[IR_TOK_EOI()]
	_B_lex_ir_set[IR_TOK_ERR()]
	_B_lex_ir_set[IR_WAS_NO_ERR()]
}
# </private>
# </lex>
