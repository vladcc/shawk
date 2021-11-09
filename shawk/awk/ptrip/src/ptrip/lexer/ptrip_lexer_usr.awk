# <lex_usr_implementation>
function _file_error(fname) {
	error_print(sprintf("file '%s': %s", fname, ERRNO))
}

function lex_usr_get_line() {
	# _B_getline_code avoids creating a private variable on each call
	_B_getline_code = (getline _B_current_input_line < get_file_name())
		
	if (_B_getline_code > 0) {
		return (_B_current_input_line "\n")
	} else if (0 == _B_getline_code) {
		return ""
	} else {
		_file_error(get_file_name())
		exit_failure()
	} 
}

function _should_read_word_ch(ch) {
	return \
		(\
		!lex_is_ch_cls(ch, CH_CLS_SPACE()) && \
		!lex_is_ch_cls(ch, CH_CLS_L_CURLY()) && \
		!lex_is_ch_cls(ch, CH_CLS_R_CURLY()) && \
		!lex_is_ch_cls(ch, CH_CLS_SEMI()) && \
		!lex_is_ch_cls(ch, CH_CLS_NEW_LINE()) && \
		!lex_is_ch_cls(ch, CH_CLS_EOI()) \
		)
}

function LEX_USR_NO_CURLY() {return "not-a-curly"}
function _read_lex_word(    _ch) {
	lex_save_init()
	while (1) {
		lex_save_curr_ch()
		if (_should_read_word_ch((_ch = lex_peek_ch())))
			lex_read_ch()
		else
			break
	}
	
	# The below hack is needed, since a key, or value are not defined by what
	# characters they are, but rather by what characters they aren't.
	if (lex_is_ch_cls(_ch, CH_CLS_L_CURLY()) || \
		lex_is_ch_cls(_ch, CH_CLS_R_CURLY())) {
		
		# read the curly, so it shows in the error message
		lex_read_ch()
		lex_save_curr_ch()
		_arr[1] = LEX_USR_NO_CURLY()
		ptree_tok_err_exp(_arr, 1)
	}
}

function lex_usr_on_unknown_ch() {
	_read_lex_word()
	return TOK_WORD()
}

function LEX_USR_INCLUDE() {return "#include"}
function lex_usr_read_include(    _arr) {
	_read_lex_word()
	if (LEX_USR_INCLUDE() == lex_get_saved()) {
		return TOK_INCLUDE()
	} else {
		
		# Since the '#include' directive is never mandatory, reading one is
		# never mandatory as well - not returning one does not lead to a syntax
		# error. Therefore, the error needs to be detected here.
		_arr[1] = LEX_USR_INCLUDE()
		ptree_tok_err_exp(_arr, 1)
	}
	return TOK_ERROR()
}

function lex_usr_read_string() {
	# "foo "\
	# "bar "\
	# "baz"
	# becomes "foo bar baz"
	
	lex_save_init()
	while (1) {
		_B_lex_usr_read_string_peek_ch = lex_peek_ch()
		if ("\\" == lex_curr_ch() && "\"" == _B_lex_usr_read_string_peek_ch) {
			lex_save_curr_ch()
			lex_read_ch()
			lex_save_curr_ch()
		} else if ("\"" == _B_lex_usr_read_string_peek_ch) {
				lex_save_curr_ch()
				lex_read_ch()
				lex_save_curr_ch()
				_lex_usr_string_append(lex_get_saved())
			if ("\\" != lex_peek_ch()) {
				return TOK_STRING()
			} else {
				lex_read_ch()
				if (TOK_NEW_LINE() == lex_next()) {
					if (TOK_STRING() == lex_next())
						return TOK_STRING()
					else
						return TOK_ERROR()
				} else {
					return TOK_ERROR()
				}
			}
		} else {
			lex_save_curr_ch()
		}
		
		if (!lex_is_next_ch_cls(CH_CLS_NEW_LINE()) && \
			!lex_is_next_ch_cls(CH_CLS_EOI())) {
			lex_read_ch()
		} else {
			break
		}
	}
	return TOK_ERROR()
}

function lex_usr_eat_comment() {
	while (!lex_is_next_ch_cls(CH_CLS_NEW_LINE()) && \
		!lex_is_next_ch_cls(CH_CLS_EOI())) {
		lex_read_ch()
	}
	return lex_next()
}

function _lex_usr_string_append(str) {
	if (_B_lex_usr_get_saved_string_str) {
		# "foo " "bar" becomes "foo bar"
		sub("\"$", "", _B_lex_usr_get_saved_string_str)
		sub("^\"", "", str)
	}
	_B_lex_usr_get_saved_string_str = (_B_lex_usr_get_saved_string_str str)
}
function lex_usr_get_saved_string(    _ret) {
	_ret = _B_lex_usr_get_saved_string_str
	_B_lex_usr_get_saved_string_str = ""
	return _ret
}
function lex_usr_pos_msg(msg) {
	return sprintf("%s\n%s",
		sprintf("file '%s', line %d, pos %d: %s",
			get_file_name(), lex_get_line_no(), lex_get_pos(), msg),
		_lex_usr_pretty_pos())
}
function _lex_usr_pretty_pos(    _ptr, _arr, _ch, _i, _end) {
	split(_B_current_input_line, _arr, "")
	_end = lex_get_pos()
	for (_i = 1; _i < _end; ++_i) {
		_ch = _arr[_i]
		_ptr = (_ptr (_ch != "\t" ? " " : "\t"))
	}
	return (_B_current_input_line "\n" _ptr "^")
}
# </lex_usr_implementation>
