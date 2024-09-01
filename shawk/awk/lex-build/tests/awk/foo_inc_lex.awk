# <lex_awk>
# generated by lex-awk.awk 1.7

# <lex_usr_defined>
# The user implements the following:
# foo_lex_usr_get_line()
# foo_lex_usr_on_unknown_ch()
# foo_lex_usr_get_word()
# foo_lex_usr_get_number()
# foo_lex_usr_handle_slash()
# </lex_usr_defined>

# <lex_public>
# <lex_constants>

# the only way to have immutable values; use as constants
function FOO_TOK_EQ() {return "="}
function FOO_TOK_EQEQ() {return "=="}
function FOO_TOK_EQEQEQ() {return "==="}
function FOO_TOK_NEQEQEQ() {return "==!"}
function FOO_TOK_NEQ() {return "=!"}
function FOO_TOK_LESS() {return "<"}
function FOO_TOK_GT() {return ">"}
function FOO_TOK_LEQ() {return "<="}
function FOO_TOK_GEQ() {return ">="}
function FOO_TOK_AND() {return "&"}
function FOO_TOK_EOI() {return "EOI"}
function FOO_TOK_SLASH() {return "/"}
function FOO_TOK_IF() {return "if"}
function FOO_TOK_ELSE() {return "else"}
function FOO_TOK_ELIF() {return "elif"}
function FOO_TOK_WHILE() {return "while"}
function FOO_TOK_ID() {return "id"}
function FOO_TOK_NUMBER() {return "number"}
function FOO_TOK_FCALL() {return "function call"}
function FOO_TOK_ERROR() {return "error"}

function FOO_CH_CLS_UNUSED_1() {return 1}
function FOO_CH_CLS_SPACE() {return 2}
function FOO_CH_CLS_WORD() {return 3}
function FOO_CH_CLS_NUMBER() {return 4}
function FOO_CH_CLS_LESS_THAN() {return 5}
function FOO_CH_CLS_UNUSED_2() {return 6}
function FOO_CH_CLS_GRTR_THAN() {return 7}
function FOO_CH_CLS_NEW_LINE() {return 8}
function FOO_CH_CLS_EOI() {return 9}
function FOO_CH_CLS_SLASH() {return 10}
function FOO_CH_CLS_UNUSED_3() {return 11}
function FOO_CH_CLS_AUTO_1_() {return 12}
function FOO_CH_CLS_AUTO_2_() {return 13}
# </lex_constants>

# read the next character; advance the input
function foo_lex_read_ch() {
	# Note: the user defines foo_lex_usr_get_line()

	_B_foo_lex_curr_ch = _B_foo_lex_input_line[_B_foo_lex_line_pos++]
	_B_foo_lex_peek_ch = _B_foo_lex_input_line[_B_foo_lex_line_pos]
	if (_B_foo_lex_peek_ch != "")
		return _B_foo_lex_curr_ch
	else
		split((_B_foo_lex_line_str = foo_lex_usr_get_line()), _B_foo_lex_input_line, "")
	return _B_foo_lex_curr_ch
}

# return the last read character
function foo_lex_curr_ch()
{return _B_foo_lex_curr_ch}

# return the next character, but do not advance the input
function foo_lex_peek_ch()
{return _B_foo_lex_peek_ch}

# return the position in the current line of input
function foo_lex_get_pos()
{return (_B_foo_lex_line_pos-1)}

# return the current line number
function foo_lex_get_line_no()
{return _B_foo_lex_line_no}

# return the last read token
function foo_lex_curr_tok()
{return _B_foo_lex_curr_tok}

# see if your token is the same as the one in the lexer
function foo_lex_match_tok(str)
{return (str == _B_foo_lex_curr_tok)}

# clear the lexer write space
function foo_lex_save_init()
{_B_foo_lex_saved = ""}

# save the last read character
function foo_lex_save_curr_ch()
{_B_foo_lex_saved = (_B_foo_lex_saved _B_foo_lex_curr_ch)}

# return the saved string
function foo_lex_get_saved()
{return _B_foo_lex_saved}

# character classes
function foo_lex_is_ch_cls(ch, cls)
{return (cls == _B_foo_lex_ch_tbl[ch])}

function foo_lex_is_curr_ch_cls(cls)
{return (cls == _B_foo_lex_ch_tbl[_B_foo_lex_curr_ch])}

function foo_lex_is_next_ch_cls(cls)
{return (cls == _B_foo_lex_ch_tbl[_B_foo_lex_peek_ch])}

function foo_lex_get_ch_cls(ch)
{return _B_foo_lex_ch_tbl[ch]}

# see if what's in the lexer's write space is a keyword
function foo_lex_is_saved_a_keyword()
{return (_B_foo_lex_saved in _B_foo_lex_keywords_tbl)}

# generate position string
function foo_lex_get_pos_str(last_tok_txt,    _str, _offs) {
	_offs = (last_tok_txt) ? length(last_tok_txt) : 1
	_str = substr(_B_foo_lex_line_str, 1, foo_lex_get_pos()-_offs)
	gsub("[^[:space:]]", " ", _str)
	return (_B_foo_lex_line_str (_str "^"))
}

# call this first
function foo_lex_init() {
	# '_B' variables are 'bound' to the lexer, i.e. 'private'
	if (!_B_foo_lex_are_tables_init) {
		_foo_lex_init_ch_tbl()
		_foo_lex_init_keywords()
		_B_foo_lex_are_tables_init = 1
	}
	_B_foo_lex_curr_ch = ""
	_B_foo_lex_curr_ch_cls_cache = ""
	_B_foo_lex_curr_tok = "error"
	_B_foo_lex_line_no = 1
	_B_foo_lex_line_pos = 1
	_B_foo_lex_peek_ch = ""
	_B_foo_lex_peeked_ch_cache = ""
	_B_foo_lex_saved = ""
	split((_B_foo_lex_line_str = foo_lex_usr_get_line()), _B_foo_lex_input_line, "")
}

# return the next token; constants are inlined for performance
function foo_lex_next() {
	_B_foo_lex_curr_tok = "error"
	while (1) {
		_B_foo_lex_curr_ch_cls_cache = _B_foo_lex_ch_tbl[foo_lex_read_ch()]
		if (2 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_SPACE()
			continue
		} else if (3 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_WORD()
			_B_foo_lex_curr_tok = foo_lex_usr_get_word()
		} else if (4 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_NUMBER()
			_B_foo_lex_curr_tok = foo_lex_usr_get_number()
		} else if (5 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_LESS_THAN()
			_B_foo_lex_curr_tok = "<"
			if ("=" == foo_lex_peek_ch()) {
				foo_lex_read_ch()
				_B_foo_lex_curr_tok = "<="
			} 
		} else if (7 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_GRTR_THAN()
			_B_foo_lex_curr_tok = ">"
			if ("=" == foo_lex_peek_ch()) {
				foo_lex_read_ch()
				_B_foo_lex_curr_tok = ">="
			} 
		} else if (8 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_NEW_LINE()
			++_B_foo_lex_line_no
			_B_foo_lex_line_pos = 1
			continue
		} else if (9 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_EOI()
			_B_foo_lex_curr_tok = FOO_TOK_EOI()
		} else if (10 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_SLASH()
			_B_foo_lex_curr_tok = foo_lex_usr_handle_slash()
		} else if (12 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_AUTO_1_()
			_B_foo_lex_curr_tok = "="
			_B_foo_lex_peeked_ch_cache = foo_lex_peek_ch()
			if ("!" == _B_foo_lex_peeked_ch_cache) {
				foo_lex_read_ch()
				_B_foo_lex_curr_tok = "=!"
			} else if ("=" == _B_foo_lex_peeked_ch_cache) {
				foo_lex_read_ch()
				_B_foo_lex_curr_tok = "=="
				_B_foo_lex_peeked_ch_cache = foo_lex_peek_ch()
				if ("!" == _B_foo_lex_peeked_ch_cache) {
					foo_lex_read_ch()
					_B_foo_lex_curr_tok = "==!"
				} else if ("=" == _B_foo_lex_peeked_ch_cache) {
					foo_lex_read_ch()
					_B_foo_lex_curr_tok = "==="
				} 
			} 
		} else if (13 == _B_foo_lex_curr_ch_cls_cache) { # FOO_CH_CLS_AUTO_2_()
			_B_foo_lex_curr_tok = "&"
		} else {
			_B_foo_lex_curr_tok = foo_lex_usr_on_unknown_ch()
		}
		break
	}
	return _B_foo_lex_curr_tok
}
# </lex_public>

# <lex_private>
# initialize the lexer tables
function _foo_lex_init_keywords() {
	_B_foo_lex_keywords_tbl["if"] = 1
	_B_foo_lex_keywords_tbl["else"] = 1
	_B_foo_lex_keywords_tbl["elif"] = 1
	_B_foo_lex_keywords_tbl["while"] = 1
}
function _foo_lex_init_ch_tbl() {
	_B_foo_lex_ch_tbl["*"] = FOO_CH_CLS_UNUSED_1()
	_B_foo_lex_ch_tbl[" "] = FOO_CH_CLS_SPACE()
	_B_foo_lex_ch_tbl["\t"] = FOO_CH_CLS_SPACE()
	_B_foo_lex_ch_tbl["_"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["a"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["b"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["c"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["d"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["e"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["f"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["g"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["h"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["i"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["j"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["k"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["l"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["m"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["n"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["o"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["p"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["q"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["r"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["s"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["t"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["u"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["v"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["w"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["x"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["y"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["z"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["A"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["B"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["C"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["D"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["E"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["F"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["G"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["H"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["I"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["J"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["K"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["L"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["M"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["N"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["O"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["P"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["Q"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["R"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["S"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["T"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["U"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["V"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["W"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["X"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["Y"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["Z"] = FOO_CH_CLS_WORD()
	_B_foo_lex_ch_tbl["0"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["1"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["2"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["3"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["4"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["5"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["6"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["7"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["8"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["9"] = FOO_CH_CLS_NUMBER()
	_B_foo_lex_ch_tbl["<"] = FOO_CH_CLS_LESS_THAN()
	_B_foo_lex_ch_tbl["^"] = FOO_CH_CLS_UNUSED_2()
	_B_foo_lex_ch_tbl[">"] = FOO_CH_CLS_GRTR_THAN()
	_B_foo_lex_ch_tbl["\n"] = FOO_CH_CLS_NEW_LINE()
	_B_foo_lex_ch_tbl[""] = FOO_CH_CLS_EOI()
	_B_foo_lex_ch_tbl["/"] = FOO_CH_CLS_SLASH()
	_B_foo_lex_ch_tbl["$"] = FOO_CH_CLS_UNUSED_3()
	_B_foo_lex_ch_tbl["="] = FOO_CH_CLS_AUTO_1_()
	_B_foo_lex_ch_tbl["&"] = FOO_CH_CLS_AUTO_2_()
}
# </lex_private>
# </lex_awk>
