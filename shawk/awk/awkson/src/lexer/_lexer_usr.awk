# <lex_usr_implemented>
function _TOK_ERR_UNKNOWN_CH() {return "unknown characters"}
function _TOK_ERR_BAD_STRING() {return "bad string"}
function _TOK_ERR_BAD_NUMBER() {return "bad number"}
function _TOK_ERR_BAD_SIGN() {return "bad sign"}
function _TOK_ERR_BAD_HEX_NUMBER() {return "bad hex number"}
function _TOK_ERR_BAD_ESC_SEQ() {return "bad escape sequence"}

function _lex_usr_on_unknown_ch() {
	_lex_save_init()
	_lex_save_curr_ch()

	while (!_lex_get_ch_cls(_lex_peek_ch())) {
		_lex_read_ch()
		_lex_save_curr_ch()
	}

	return _TOK_ERR_UNKNOWN_CH()
}

function _lex_usr_init_hex_digit() {
	_B_awkson_lex_hex_digit["0"] = 1
	_B_awkson_lex_hex_digit["1"] = 1
	_B_awkson_lex_hex_digit["2"] = 1
	_B_awkson_lex_hex_digit["3"] = 1
	_B_awkson_lex_hex_digit["4"] = 1
	_B_awkson_lex_hex_digit["5"] = 1
	_B_awkson_lex_hex_digit["6"] = 1
	_B_awkson_lex_hex_digit["7"] = 1
	_B_awkson_lex_hex_digit["8"] = 1
	_B_awkson_lex_hex_digit["9"] = 1
	_B_awkson_lex_hex_digit["a"] = 1
	_B_awkson_lex_hex_digit["b"] = 1
	_B_awkson_lex_hex_digit["c"] = 1
	_B_awkson_lex_hex_digit["d"] = 1
	_B_awkson_lex_hex_digit["e"] = 1
	_B_awkson_lex_hex_digit["f"] = 1
	_B_awkson_lex_hex_digit["A"] = 1
	_B_awkson_lex_hex_digit["B"] = 1
	_B_awkson_lex_hex_digit["C"] = 1
	_B_awkson_lex_hex_digit["D"] = 1
	_B_awkson_lex_hex_digit["E"] = 1
	_B_awkson_lex_hex_digit["F"] = 1
}
function _lex_usr_is_hex_digit(ch) {
	return (ch in _B_awkson_lex_hex_digit)
}

function _lex_usr_init_esc_chars() {
	_B_awkson_lex_esc_char["\""] = 1
	_B_awkson_lex_esc_char["\\"] = 1
	_B_awkson_lex_esc_char["/"] = 1
	_B_awkson_lex_esc_char["b"] = 1
	_B_awkson_lex_esc_char["f"] = 1
	_B_awkson_lex_esc_char["n"] = 1
	_B_awkson_lex_esc_char["r"] = 1
	_B_awkson_lex_esc_char["t"] = 1
	_B_awkson_lex_esc_char["u"] = 1
}
function _lex_usr_is_esc_char(ch) {
	return (ch in _B_awkson_lex_esc_char)
}

function _lex_get_line_str() {
	# exists generally for testing
	return _G_current_input_line
}
function _lex_usr_get_line() {
	# _B_getline_code avoids creating a private variable on each call
	_B_getline_code = (getline _G_current_input_line < get_file_name())
		
	if (_B_getline_code > 0) {
		return (_G_current_input_line "\n")
	} else if (0 == _B_getline_code) {
		return ""
	} else {
		error_quit(sprintf("file '%s': %s", get_file_name(), ERRNO))
	} 
}
function _lex_usr_get_string(    _curr_ch, _peek_ch) {
	_lex_save_init()

	# save the opening quote
	_lex_save_curr_ch()

	while (1) {
		_peek_ch = _lex_peek_ch()
		if ("\n" == _peek_ch || "" == _peek_ch)
			break

		_lex_read_ch()
		_lex_save_curr_ch()

		# _peek_ch is now the current char
		if ("\"" == _peek_ch)
			return _TOK_STRING()
			
		if ("\\" == _peek_ch) {
			
			_peek_ch = _lex_peek_ch()
			if (_lex_usr_is_esc_char(_peek_ch)) {
				
				# read and save the escaped character
				_lex_read_ch()
				_lex_save_curr_ch()
				
				if ("u" == _peek_ch) {
					# read four hex digits
					
					_lex_read_ch()
					if (_lex_usr_is_hex_digit(_lex_curr_ch()))
						_lex_save_curr_ch()
					else
						return _TOK_ERR_BAD_HEX_NUMBER()
					
					_lex_read_ch()
					if (_lex_usr_is_hex_digit(_lex_curr_ch()))
						_lex_save_curr_ch()
					else
						return _TOK_ERR_BAD_HEX_NUMBER()
					
					_lex_read_ch()
					if (_lex_usr_is_hex_digit(_lex_curr_ch()))
						_lex_save_curr_ch()
					else
						return _TOK_ERR_BAD_HEX_NUMBER()
					
					_lex_read_ch()
					if (_lex_usr_is_hex_digit(_lex_curr_ch()))
						_lex_save_curr_ch()
					else
						return _TOK_ERR_BAD_HEX_NUMBER()
				}
			} else {
				return _TOK_ERR_BAD_ESC_SEQ()
			}
		}
	}

	return _TOK_ERR_BAD_STRING()
}

function __lex_usr_get_int_part(    _digits) {
	_digits = 0
	while (_lex_is_next_ch_cls(_CH_CLS_NUMBER())) {
		_lex_read_ch()
		_lex_save_curr_ch()
		++_digits
	}
	return _digits
}
function _lex_usr_get_number(    _peek_ch) {
	_lex_save_init()

	_lex_save_curr_ch()
	if (_lex_is_curr_ch_cls(_CH_CLS_SIGN())) {
	
		if (_lex_curr_ch() == "-") {	
			# has to have a number after the sign
			if (!__lex_usr_get_int_part())
				return _TOK_ERR_BAD_NUMBER()
		} else {
			return _TOK_ERR_BAD_SIGN()
		}
	} else if (_lex_curr_ch() != "0"){
		# exactly one zero at the beginning allowed
		__lex_usr_get_int_part()
	}
	
	# optional fraction
	if (_lex_peek_ch() == ".") {
		_lex_read_ch()
		_lex_save_curr_ch()
		if (!__lex_usr_get_int_part())
			return _TOK_ERR_BAD_NUMBER()
	}

	# optional exponent
	_peek_ch = _lex_peek_ch()
	if ("e" == _peek_ch || "E" == _peek_ch) {
		_lex_read_ch()
		_lex_save_curr_ch()

		# optional sign
		if (_lex_is_next_ch_cls(_CH_CLS_SIGN())) {
			_lex_read_ch()
			_lex_save_curr_ch()
		}
		if (!__lex_usr_get_int_part())
			return _TOK_ERR_BAD_NUMBER()
	}

	return _TOK_NUMBER()
}

function _lex_usr_get_kword() {
	_lex_save_init()
	_lex_save_curr_ch()

	while (_lex_is_next_ch_cls(_CH_CLS_WORD())) {
		_lex_read_ch()
		_lex_save_curr_ch()
	}

	return (_lex_is_saved_a_keyword()) ? _lex_get_saved() : _TOK_ERROR()
}

function _lex_pretty_pos(line) {
	return (line "\n" _pretty_pos(line, _lex_get_pos()))
}
# </lex_usr_implemented>
