# <lex_awk>
# generated by lex-awk.awk 1.7

# <lex_usr_defined>
# The user implements the following:
# lex_usr_get_line()
# lex_usr_on_unknown_ch()
# lex_usr_new_line_hack()
# lex_usr_read_include()
# lex_usr_read_string()
# lex_usr_eat_comment()
# </lex_usr_defined>

# <lex_public>
# <lex_constants>

# the only way to have immutable values; use as constants
function TOK_L_CURLY() {return "{"}
function TOK_R_CURLY() {return "}"}
function TOK_NEW_LINE() {return "NEW_LINE"}
function TOK_INCLUDE() {return "INCLUDE"}
function TOK_WORD() {return "WORD"}
function TOK_STRING() {return "STRING"}
function TOK_EOI() {return "EOI"}
function TOK_ERROR() {return "error"}

function CH_CLS_SPACE() {return 1}
function CH_CLS_NEW_LINE() {return 2}
function CH_CLS_EOI() {return 3}
function CH_CLS_SEMI() {return 4}
function CH_CLS_L_CURLY() {return 5}
function CH_CLS_R_CURLY() {return 6}
function CH_CLS_HASH() {return 7}
function CH_CLS_QUOTE() {return 8}
# </lex_constants>

# read the next character; advance the input
function lex_read_ch() {
	# Note: the user defines lex_usr_get_line()

	_B_lex_curr_ch = _B_lex_input_line[_B_lex_line_pos++]
	_B_lex_peek_ch = _B_lex_input_line[_B_lex_line_pos]
	if (_B_lex_peek_ch != "")
		return _B_lex_curr_ch
	else
		split((_B_lex_line_str = lex_usr_get_line()), _B_lex_input_line, "")
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
	_offs = (last_tok_txt) ? length(last_tok_txt) : 1
	_str = substr(_B_lex_line_str, 1, lex_get_pos()-_offs)
	gsub("[^[:space:]]", " ", _str)
	return (_B_lex_line_str (_str "^"))
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
	_B_lex_line_no = 1
	_B_lex_line_pos = 1
	_B_lex_peek_ch = ""
	_B_lex_peeked_ch_cache = ""
	_B_lex_saved = ""
	split((_B_lex_line_str = lex_usr_get_line()), _B_lex_input_line, "")
}

# return the next token; constants are inlined for performance
function lex_next() {
	_B_lex_curr_tok = "error"
	while (1) {
		_B_lex_curr_ch_cls_cache = _B_lex_ch_tbl[lex_read_ch()]
		if (1 == _B_lex_curr_ch_cls_cache) { # CH_CLS_SPACE()
			continue
		} else if (2 == _B_lex_curr_ch_cls_cache) { # CH_CLS_NEW_LINE()
			_B_lex_curr_tok = lex_usr_new_line_hack()
		} else if (3 == _B_lex_curr_ch_cls_cache) { # CH_CLS_EOI()
			_B_lex_curr_tok = TOK_EOI()
		} else if (4 == _B_lex_curr_ch_cls_cache) { # CH_CLS_SEMI()
			_B_lex_curr_tok = lex_usr_eat_comment()
		} else if (5 == _B_lex_curr_ch_cls_cache) { # CH_CLS_L_CURLY()
			_B_lex_curr_tok = "{"
		} else if (6 == _B_lex_curr_ch_cls_cache) { # CH_CLS_R_CURLY()
			_B_lex_curr_tok = "}"
		} else if (7 == _B_lex_curr_ch_cls_cache) { # CH_CLS_HASH()
			_B_lex_curr_tok = lex_usr_read_include()
		} else if (8 == _B_lex_curr_ch_cls_cache) { # CH_CLS_QUOTE()
			_B_lex_curr_tok = lex_usr_read_string()
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
}
function _lex_init_ch_tbl() {
	_B_lex_ch_tbl[" "] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\f"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\r"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\t"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\v"] = CH_CLS_SPACE()
	_B_lex_ch_tbl["\n"] = CH_CLS_NEW_LINE()
	_B_lex_ch_tbl[""] = CH_CLS_EOI()
	_B_lex_ch_tbl[";"] = CH_CLS_SEMI()
	_B_lex_ch_tbl["{"] = CH_CLS_L_CURLY()
	_B_lex_ch_tbl["}"] = CH_CLS_R_CURLY()
	_B_lex_ch_tbl["#"] = CH_CLS_HASH()
	_B_lex_ch_tbl["\""] = CH_CLS_QUOTE()
}
# </lex_private>
# </lex_awk>
